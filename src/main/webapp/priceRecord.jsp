<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.text.*"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Sales Record</title>
<link rel="stylesheet" href="style.css">
<style>
/* 레이아웃을 위한 CSS */
#content {
	display: flex;
	width: 100%;
	height: calc(100vh - 60px); /* 헤더를 제외한 전체 화면 높이 */
	overflow: hidden; /* 넘치는 부분 숨기기 */
}

#inventory_list.recordList {
	background-color: aqua;
}

#inventory_list tr.selected {
	background-color: #d3d3d3; /* 선택된 행의 배경색 */
}

#tableContainer {
	flex: 3; /* 테이블 영역의 비율 */
	padding: 20px;
	overflow-y: auto;
	overflow-x: scroll;
	border-right: 2px solid #ddd; /* 구분을 위한 우측 경계선 */
	position: relative; /* 테이블을 고정 위치로 설정 */
}

#sidePanel {
	flex: 2; /* 사이드 패널 영역의 비율 */
	background-color: #f5f5f5; /* 부드러운 배경색 */
	padding: 20px;
	overflow-y: auto;
	display: block; /* 항상 표시 */
}

.pagination {
	display: flex;
	justify-content: center;
	list-style: none;
	padding: 0;
	margin: 20px 0;
	position: fixed;
	top: calc(100vh - 60px); /* 페이지 하단 위치 조정 */
	left: 50%;
	transform: translateX(-50%);
}

.pagination li {
	margin: 0 5px;
	padding: 10px 15px;
	cursor: pointer;
	border: 2px solid black;
	border-radius: 5px;
}

.pagination li.active {
	background-color: #007fff;
	color: white;
	border-color: #007bff;
}

.pagination li:hover:not(.active) {
	background-color: #f1f1f1;
}

/* 테이블 스타일 조정 */
table {
	width: 100%;
	border-collapse: collapse;
	margin-bottom: 0; /* 페이지 여백 제거 */
}

th, td {
	border: 1px solid #ddd;
	padding: 8px;
	text-align: left;
}

th {
	background-color: #f4f4f4;
}

.table_line {
	padding: 0;
	margin: 0;
	/* border: 1px solid black; */
	float: right;
	width: calc(65%);
	border-collapse: collapse;
	border-radius: 10px;
	box-shadow: 0 2px 5px rgba(0, 0, 0, 0.25);
}

#inventory_list tr:nth-child(even) td {
	background: #E6E6FA;
}

.custom-btn {
  width: 65px;
  height: 40px;
  border-radius: 5px;
  font-family: 'Lato', sans-serif;
  font-weight: 500;
  background: transparent;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  display: inline-block;
   box-shadow:inset 2px 2px 2px 0px rgba(255,255,255,.5),
   7px 7px 20px 0px rgba(0,0,0,.1),
   4px 4px 5px 0px rgba(0,0,0,.1);
  outline: none;
}

.btn-16 {
	border: none;
	color: #000;
}

.btn-16:after {
	position: absolute;
	content: "";
	width: 0;
	height: 100%;
	top: 0;
	left: 0;
	direction: rtl;
	z-index: -1;
	box-shadow: -7px -7px 20px 0px #fff9, -4px -4px 5px 0px #fff9, 7px 7px
		20px 0px #0002, 4px 4px 5px 0px #0001;
	transition: all 0.3s ease;
}

.btn-16:hover {
	color: #000;
}

.btn-16:hover:after {
	left: auto;
	right: 0;
	width: 100%;
}

.btn-16:active {
	top: 2px;
}
</style>
</head>
<body>
	<div id="wrap" style="display: block; overflow-x: hidden;">
		<header>
			<%@ include file="header.jsp"%>
		</header>

		<div class="filter_line" style="width: 1200px; line-height: 50px; margin: 0 auto; padding: 0; background: skyblue; display: flex; margin-top: 40px;">
			<div style="flex: 1;">
				<input type="date" class="startDate" id="startDate" style='margin-top: 5%;'> <input type="date" class="endDate" id="endDate">
			</div>
			<div style="flex: 1;">
				<input type="text" id="searchName" placeholder="이름 검색" style='position: relative; display: block; height: 40px; vertical-align: middle; float: right; margin-right: 20px; top: 50%; transform: translateY(-50%);'> <input type="text" id="searchPhone" placeholder="전화번호 검색" style='position: relative; display: block; height: 40px; vertical-align: middle; float: right; margin-right: 20px; top: 50%; transform: translateY(-50%);'>
			</div>
		</div>

		<h1 style="text-align: center;">결제 내역</h1>

		<!-- 테이블과 사이드 패널을 포함하는 컨테이너 -->
		<div id="content" style="height: calc(60vh);">
			<!-- 테이블 컨테이너 -->
			<div id="tableContainer">
				<table class="table_line" style="float: right; width: calc(65%); overflow: hidden">
					<colgroup>
						<col style="width: 150px;">
						<col style="width: 150px;">
						<col style="width: 150px;">
						<col style="width: 150px;">
					</colgroup>
					<thead style="background-color: #B0E0E6; color: white;">
						<tr>
							<th>고객성함</th>
							<th>고객번호</th>
							<th>일자/시간</th>
							<th>수정 / 삭제</th>
						</tr>
					</thead>
					<tbody id="inventory_list">
						<%
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        Connection conn = null;
                        PreparedStatement pstmt = null;
                        ResultSet rs = null;
                        request.setCharacterEncoding("UTF-8");
                        try {
                            String jdbcDriver = "jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8";
                            String dbUser = "root";
                            String dbPwd = "pharmacy@1234";
                            conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPwd);

                            String sql = " SELECT DISTINCT "
                                    + " c.clientName, c.clientNumber, "
                                    + " A.saleDate AS saleDate, "
                                    + " B.maxmedicinePrice AS maxmedicinePrice, "
                                    + " B.generalPrice AS generalPrice, "
                                    + " (B.maxmedicinePrice + B.generalPrice) AS totalPrice "
                                    + " FROM SalesRecord A "
                                    + " JOIN priceRecord B ON A.saleDate = B.saleDate "
                                    + " JOIN clientRecord C ON A.saleDate = C.saleDate ";
                            pstmt = conn.prepareStatement(sql);
                            rs = pstmt.executeQuery();
                            while (rs.next()) {
                        %>
						<tr data-date="<%= rs.getString("saleDate") %>">
							<td><%= rs.getString("clientName") %></td>
							<td><%= rs.getString("clientNumber") %></td>
							<td><%= rs.getString("saleDate") %></td>
							<td><button class="updateBtn custom-btn btn-16">수정</button>
								<button class="deleteBtn custom-btn btn-16">삭제</button></td>
						</tr>
						<%
                            }
                        } catch (Exception se) {
                            se.printStackTrace();
                        } finally {
                            if (rs != null) rs.close();
                            if (pstmt != null) pstmt.close();
                            if (conn != null) conn.close();
                        }
                        %>
					</tbody>
				</table>
				<ul class="pagination"></ul>
			</div>

			<!-- 사이드 패널 -->
			<div id="sidePanel">
				<div id="panel_content"></div>
			</div>
		</div>
	</div>

	<script src="jquery-3.7.1.min.js"></script>
	<script>
        function showSidePanel(saleDate) {
            var xhr = new XMLHttpRequest();
            xhr.open("POST", "detailRecord2.jsp?saleDate=" + saleDate, true);
            xhr.onreadystatechange = function() {
                if (xhr.readyState == 4 && xhr.status == 200) {
                    var panelContent = document.getElementById("panel_content");
                    panelContent.innerHTML = xhr.responseText;
                } else if (xhr.readyState == 4) {
                    console.error("AJAX request failed with status " + xhr.status);
                }
            };
            xhr.send();
        }

        $(document).ready(function() {
            var numPerPage = 10;
            var currentPage = 1;
            var selectedRowIndex = -1;

            function filterRows() {
                var nameFilter = $('#searchName').val().toLowerCase();
                var phoneFilter = $('#searchPhone').val().toLowerCase();
                var startDate = $('#startDate').val();
                var endDate = $('#endDate').val();

                // endDate를 23:59:59로 설정
                if (endDate) {
                    endDate += ' 23:59:59';
                }

                $('#inventory_list tr').each(function() {
                    var name = $(this).find('td').eq(0).text().toLowerCase();
                    var phone = $(this).find('td').eq(1).text().toLowerCase();
                    var date = $(this).find('td').eq(2).text();

                    var dateMatch = true;
                    if (startDate && endDate) {
                        dateMatch = (date >= startDate && date <= endDate);
                    } else if (startDate) {
                        dateMatch = (date >= startDate);
                    } else if (endDate) {
                        dateMatch = (date <= endDate);
                    }

                    // 필터 조건에 맞지 않는 행은 숨김
                    if (name.includes(nameFilter) && phone.includes(phoneFilter) && dateMatch) {
                        $(this).show();
                    } else {
                        $(this).hide();
                    }
                });
            }

            function showPage(page) {
                filterRows(); // 페이지를 표시하기 전에 필터 적용
                var visibleRows = $('#inventory_list tr:visible');
                visibleRows.hide(); // 모든 필터링된 행 숨김
                visibleRows.slice((page - 1) * numPerPage, page * numPerPage).show(); // 필터링된 행만 표시
            }

            function updatePagination() {
                var visibleRows = $('#inventory_list tr:visible');
                var numRows = visibleRows.length;
                var numPages = Math.ceil(numRows / numPerPage);
                $('.pagination').empty();

                if (numPages <= 1) return;

                for (var i = 1; i <= numPages; i++) {
                    $('.pagination').append('<li>' + i + '</li>');
                }
                $('.pagination li').first().addClass('active');
            }

            function setSelectedRow(index) {
                $('#inventory_list tr').removeClass('selected');
                var visibleRows = $('#inventory_list tr:visible');
                if (index >= 0 && index < visibleRows.length) {
                    visibleRows.eq(index).addClass('selected');
                    visibleRows.eq(index)[0].scrollIntoView({ behavior: 'smooth', block: 'center' });
                    selectedRowIndex = index;
                }
            }

            function changePage(newPage) {
                currentPage = newPage;
                showPage(currentPage);
                setSelectedRow((currentPage - 1) * numPerPage);
                $('.pagination li').removeClass('active');
                $('.pagination li').eq(currentPage - 1).addClass('active');
            }

            $(document).on('click', '.pagination li', function() {
                var pageIndex = $(this).index();
                changePage(pageIndex + 1);
            });

            $('#inventory_list').on('click', 'tr', function() {
                var saleDate = $(this).data('date');
                $(this).addClass('recordList').siblings().removeClass('recordList');
                showSidePanel(saleDate);
            });

            $(document).on('keydown', function(e) {
                var visibleRows = $('#inventory_list tr:visible');
                var totalRows = visibleRows.length;
                var totalPages = Math.ceil(totalRows / numPerPage);
                if (totalRows === 0) return;

                if (e.key === 'ArrowDown') {
                    e.preventDefault();
                    if (selectedRowIndex === -1) {
                        setSelectedRow(0);
                    } else {
                        var newIndex = selectedRowIndex + 1;
                        if (newIndex >= totalRows) {
                            newIndex = 0;
                            changePage(1);
                        } else if (newIndex >= currentPage * numPerPage) {
                            changePage(currentPage + 1);
                        }
                        setSelectedRow(newIndex);
                    }
                    $('#inventory_list tr:visible').eq(selectedRowIndex).click();
                } else if (e.key === 'ArrowUp') {
                    e.preventDefault();
                    if (selectedRowIndex === -1) {
                        setSelectedRow(0);
                    } else {
                        var newIndex = selectedRowIndex - 1;
                        if (newIndex < 0) {
                            newIndex = totalRows - 1;
                            changePage(totalPages);
                        } else if (newIndex < (currentPage - 1) * numPerPage) {
                            changePage(currentPage - 1);
                        }
                        setSelectedRow(newIndex);
                    }
                    $('#inventory_list tr:visible').eq(selectedRowIndex).click();
                }
            });

            function setDefaultDateFilter() {
                var today = new Date().toISOString().split('T')[0]; // ISO 문자열의 날짜 부분만 추출
                $('#startDate').val(today);
                $('#endDate').val(today);
                filterRows(); // 페이지 로딩 시 필터링 적용
                updatePagination(); // 페이지네이션 업데이트
                showPage(currentPage); // 현재 페이지 표시
            }

            $('#searchName, #searchPhone, #startDate, #endDate').on('input', function() {
                currentPage = 1; // 필터링 후 페이지를 첫 페이지로 이동
                filterRows(); // 필터링 적용
                updatePagination(); // 페이지네이션 업데이트
                showPage(currentPage); // 현재 페이지 표시
            });

            setDefaultDateFilter(); // 페이지 로딩 시 기본 날짜 필터 설정
        });
        $(".updateBtn").on("click", function(event) {
            event.preventDefault();
            
            var row = $(this).closest("tr");
            var timeToset = row.find("td:eq(2)").text();

            if (confirm("해당 날짜의 데이터를 수정하시겠습니까?")) {
                $.ajax({
                    url: 'checkSaleDate.jsp',
                    type: 'POST',
                    data: { saleDate: timeToset },
                    success: function(response) {
                        if(response.trim() === "deleted") {
                            alert("해당 날짜의 데이터를 수정합니다.");
                        } else {
                            alert("해당 날짜에 데이터가 없습니다.");
                        }
                    },
                    error: function(xhr, status, error) {
                        console.error('Error:', error);
                    }
                });
            } else {
                alert("수정 취소되었습니다.");
            }
        });
        $(".deleteBtn").on("click", function(event){
            event.preventDefault();
            
            var row = $(this).closest("tr");
            var timeToset = row.find("td:eq(2)").text();

            if (confirm("해당 날짜의 데이터를 삭제하시겠습니까?")) {
                $.ajax({
                    url: 'deleteSaleDate.jsp',
                    type: 'POST',
                    data: { saleDate: timeToset },
                    success: function(response) {
                        if(response.trim() === "deleted") {
                            alert("해당 날짜의 데이터가 삭제되었습니다.");
                        } else {
                            alert("해당 날짜에 데이터가 없습니다.");
                        }
                    },
                    error: function(xhr, status, error) {
                        console.error('Error:', error);
                    }
                });
            } else {
                alert("삭제가 취소되었습니다.");
            }
        });
    </script>
</body>
</html>