<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%
// 기존 session 변수 사용
HttpSession sessions = request.getSession(false);
String userId = (sessions != null) ? (String) sessions.getAttribute("userId") : null;

if (userId == null) {
	// 로그인되지 않은 경우, 로그인 페이지로 리다이렉트
	response.sendRedirect("login.jsp");
	return;
}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Insert title here</title>
<link rel="stylesheet" href="style.css">
<style>
#table_body {
	max-height: 200px; /* 원하는 최대 높이로 설정 */
	overflow-y: auto; /* 세로 스크롤을 표시할 수 있도록 설정 */
}

table {
	width: 100%;
	border-collapse: collapse;
}

thead {
	position: sticky;
	top: 0;
	background-color: white;
	z-index: 1;
}

tbody {
	display: block;
	max-height: 300px; /* 원하는 높이로 설정 */
	overflow-y: scroll; /* Y축 스크롤 */
	width: 100%;
}

/* X축은 자동으로 같이 움직이도록 */
table thead, table tbody {
	display: table;
	width: 100%;
	table-layout: fixed; /* 각 셀의 크기가 고정되도록 */
}

/* 스크롤바 숨기기 */
tbody::-webkit-scrollbar {
	display: none;
}

tbody {
	-ms-overflow-style: none; /* IE and Edge */
	scrollbar-width: none; /* Firefox */
}

/* 셀 높이 지정 */
thead th, tbody td {
	width: 150px; /* 셀 너비 고정 */
}

.toggle-button {
	display: inline-flex;
	align-items: center;
	justify-content: space-between;
	width: 150px;
	height: 40px;
	background-color: #ccc;
	border-radius: 20px;
	position: relative;
	cursor: pointer;
	transition: background-color 0.3s;
	padding: 0 10px;
	color: white;
	font-weight: bold;
	font-size: 14px;
}

.toggle-button.on {
	background-color: #4caf50;
}

.toggle-knob {
	width: 36px;
	height: 36px;
	background-color: #fff;
	border-radius: 50%;
	position: absolute;
	top: 2px;
	left: 2px;
	transition: left 0.3s;
}

.toggle-button.on .toggle-knob {
	left: 112px;
}

.toggle-text {
	position: absolute;
	width: 100%;
	text-align: center;
	z-index: 1;
	color: #ffffff;
}

.hidden {
	display: none; /* 숨기기 스타일 */
}

.updateInfo, .deleteInfo{
	position: relative;
    border: none;
    display: inline-block;
    padding: 6px 20px;
    border-radius: 15px;
    font-family: "paybooc-Light", sans-serif;
    box-shadow: 0 15px 35px rgba(0, 0, 0, 0.2);
    text-decoration: none;
    font-weight: 600;
    transition: 0.25s;
    background: linear-gradient(-45deg, #33ccff 0%, #ff99cc 100%);
    color: white;
}
#bookmark_button{
	position: relative;
    border: none;
    min-width: 115px;
    min-height: 33px;
    background: linear-gradient(
        90deg,
        rgba(129, 230, 217, 1) 0%,
        rgba(79, 209, 197, 1) 100%
    );
    border-radius: 1000px;
    color: darkslategray;
    cursor: pointer;
    box-shadow: 12px 12px 24px rgba(79, 209, 197, 0.64);
    font-weight: 700;
    transition: 0.3s;
}
#bookmark_button:hover{
	transform: scale(1.2);
}
#bookmark_button:hiver::after{
	content: "";
    width: 30px;
    height: 30px;
    border-radius: 100%;
    border: 6px solid #00ffcb;
    position: absolute;
    z-index: -1;
    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);
    animation: ring 1.5s infinite;
}
.table_line th:nth-child(3), 
.table_line td:nth-child(3){
	width:250px;
}
.table_line th:nth-child(1), 
.table_line td:nth-child(1){
	width:100px;
}
#inventory_list .custom-btn {
	width: 90px;
	height: 33px;
	line-height: 33px;
	border: 2px solid #000;
	font-family: 'Lato', sans-serif;
	font-weight: 500;
	background: transparent;
	cursor: pointer;
	transition: all 0.3s ease;
	position: relative;
	display: inline-block;
}


#inventory_list .btn-13 {
   background: #000;
  color: #fff;
  z-index: 1;
}
#inventory_list .btn-13:after {
  position: absolute;
  content: "";
  width: 100%;
  height: 0;
  bottom: 0;
  left: 0;
  z-index: -1;
   background: #e0e5ec;
  transition: all 0.3s ease;
}
#inventory_list .btn-13:hover {
  color: #000;
}
#inventory_list .btn-13:hover:after {
  top: 0;
  height: 100%;
}
#inventory_list .btn-13:active {
  top: 2px;
}
.pagination-dots {
    margin: 0 5px;
    font-size: 14px;
    color: #888;
    vertical-align: middle;
}
.pagination-button{
	width: 40px;
    height: 30px;
    margin: 0 5px;
}
.filter .finterButton .custom-btn {
  width: 130px;
  height: 40px;
  color: #fff;
  border-radius: 5px;
  padding: 10px 25px;
  font-family: 'Lato', sans-serif;
  font-weight: 500;
  background: transparent;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  display: inline-block;
  outline: none;
}
.btn-12{
  position: relative;
  right: 20px;
  bottom: 20px;
  border:none;
  box-shadow: none;
  width: 130px;
  height: 40px;
  line-height: 42px;
  -webkit-perspective: 230px;
  perspective: 230px;
}
.btn-12 span {
  background: rgb(0,172,238);
background: linear-gradient(0deg, rgba(0,172,238,1) 0%, rgba(2,126,251,1) 100%);
  display: block;
  position: absolute;
  width: 130px;
  height: 40px;
  box-shadow:inset 2px 2px 2px 0px rgba(255,255,255,.5),
   7px 7px 20px 0px rgba(0,0,0,.1),
   4px 4px 5px 0px rgba(0,0,0,.1);
  border-radius: 5px;
  margin:0;
  text-align: center;
  -webkit-box-sizing: border-box;
  -moz-box-sizing: border-box;
  box-sizing: border-box;
  -webkit-transition: all .3s;
  transition: all .3s;
}
.btn-12 span:nth-child(1) {
  box-shadow:
   -7px -7px 20px 0px #fff9,
   -4px -4px 5px 0px #fff9,
   7px 7px 20px 0px #0002,
   4px 4px 5px 0px #0001;
  -webkit-transform: rotateX(90deg);
  -moz-transform: rotateX(90deg);
  transform: rotateX(90deg);
  -webkit-transform-origin: 50% 50% -20px;
  -moz-transform-origin: 50% 50% -20px;
  transform-origin: 50% 50% -20px;
}
.btn-12 span:nth-child(2) {
  -webkit-transform: rotateX(0deg);
  -moz-transform: rotateX(0deg);
  transform: rotateX(0deg);
  -webkit-transform-origin: 50% 50% -20px;
  -moz-transform-origin: 50% 50% -20px;
  transform-origin: 50% 50% -20px;
}
.btn-12:hover span:nth-child(1) {
  box-shadow:inset 2px 2px 2px 0px rgba(255,255,255,.5),
   7px 7px 20px 0px rgba(0,0,0,.1),
   4px 4px 5px 0px rgba(0,0,0,.1);
  -webkit-transform: rotateX(0deg);
  -moz-transform: rotateX(0deg);
  transform: rotateX(0deg);
}
.btn-12:hover span:nth-child(2) {
  box-shadow:inset 2px 2px 2px 0px rgba(255,255,255,.5),
   7px 7px 20px 0px rgba(0,0,0,.1),
   4px 4px 5px 0px rgba(0,0,0,.1);
 color: transparent;
  -webkit-transform: rotateX(-90deg);
  -moz-transform: rotateX(-90deg);
  transform: rotateX(-90deg);
}
</style>
</head>
<body>
	<div id="wrap">
		<header>
			<jsp:include page="header.jsp"></jsp:include>
		</header>
		<form action="index.jsp" name="data" method="post" id="formTeg" style="min-width:1200px;max-width:1200px;">
			<div>
				<div class="filter" style='display: flex; position: fixed; width: 110px; height: 40px; float: left;'>
					<input type="text" id="nameSearch" style="position: relative; top: 5%; height: 40px;" placeholder="제품명을 입력하세요">
					<div class="finterButton"  style="display: block;position: fixed;width: 75vh;">
						<button class="custom-btn btn-12" data-value="1"><span>Click!</span><span>1개월 이내</span></button>
						<button class="custom-btn btn-12" data-value="2"><span>Click!</span><span>3개월 이내</span></button>
						<button class="custom-btn btn-12" data-value="3"><span>Click!</span><span>6개월 이내</span></button>
						<button class="custom-btn btn-12" data-value="4"><span>Click!</span><span>1년 이상</span></button>
					</div>
				</div>
				<h1 style="text-align: center; margin-top: 40px;">재고 목록</h1>
				<div class="toggle-button" id="toggleButton">
					<div class="toggle-text" id="toggleText">반품 OFF</div>
					<div class="toggle-knob"></div>
				</div>
			</div>
			<input id="barcodeInput" type='text' name="barcodeInput" autofocus="autofocus" autocomplete="off" />
			<table class="table_line" style="min-width: 100%; max-width: 100%; height: calc(70vh); display: block; overflow: auto;border-radius: 20px 20px 0 0; padding: 0; margin: 0 auto;">
				<thead style="background-color: #4169E1;width:960px;color:white">
					<tr>
						<th>모두보기</th>
						<th>수정 / 삭제<br>
						<th>이름<span class="ascendingOrder nameAscendingOrder">↑</span><span class="descendingOrder nameDescendingOrder">↓</span></th>
						<th>유통기한<br>(유효기간)
						<th>실제 수량<span class="ascendingOrder invAscendingOrder">↑</span><span class="ascendingOrder invDescendingOrder">↓</span></th>
						<th>규격</th>
						<th>가격<span class="ascendingOrder priceAscendingOrder">↑</span><span class="descendingOrder priceDescendingOrder">↓</span></th>
						<th>회사명</th>
						<th>입고 날짜</th>
						<th>반품개시<br>
					</tr>
				</thead>
				<tbody id="inventory_list" style="background-color: RGBA(255, 255, 255, 0.8);min-width:960px;">
					<%
					Class.forName("com.mysql.cj.jdbc.Driver");
					Connection conn = null;
					PreparedStatement pstmt = null;
					ResultSet rs = null;
					request.setCharacterEncoding("UTF-8");

					try {
						String jdbcDriver = "jdbc:mysql://localhost:3306/tutorial2?useUnicode=true&characterEncoding=utf8";
						String dbUser = "root";
						String dbPwd = "pharmacy@1234";

						String sql = "SELECT medicineName, price, inventory, "
							      + " inventory, "
							      + "  companyName,  standard,  receiptDate,  DeliveryDate, returnInv " 
							      + " FROM testTable "
							      + " ORDER BY medicineName ASC, DeliveryDate ASC, standard ASC";


						conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPwd);
						pstmt = conn.prepareStatement(sql);
						rs = pstmt.executeQuery();

						while (rs.next()) {
							String currentName = rs.getString("medicineName");
							String currentStandard = rs.getString("standard");
					%>
					<tr>
						<td><button class="toggle-details custom-btn btn-13" style="z-index:0">▼</button></td>
						<td>
							<button class="updateInfo">수정</button>
							<button class="deleteInfo">삭제</button>
						</td>
						<td><%=currentName%></td>
						<td><%=rs.getString("DeliveryDate")%></td>
						<td><%=rs.getString("inventory")%></td>
						<td><%=currentStandard%></td>
						<td><%=rs.getString("price")%></td>
						<td><%=rs.getString("companyName")%></td>
						<td><%=rs.getString("receiptDate")%></td>
						<td><input type="button" value="<%=rs.getInt("returnInv") == 1 ? "반품됨" : "반품하기"%>" id="returnProduct"></td>
					</tr>
					<%
					}
					} catch (SQLException se) {
					se.printStackTrace();
					} finally {
					if (rs != null)
					rs.close();
					if (pstmt != null)
					pstmt.close();
					if (conn != null)
					conn.close();
					}
					%>
				</tbody>
			</table>
			<div id="pagination" style="text-align: center; margin-top: 20px;"></div>
		</form>
	</div>
	<script src="jquery-3.7.1.min.js"></script>
	<script type="text/javascript">
		$(document).ready(function() {
			// 버튼 클릭 이벤트
		    $('.filterButton').on('click', function() {
		    	 event.preventDefault();
		        // 모든 버튼의 'active' 클래스 제거
		        $('.filterButton').removeClass('active');
		        
		        // 현재 클릭된 버튼에 'active' 클래스 추가
		        $(this).addClass('active');
		        
		        // 선택된 필터 값 가져오기
		        var filterMonths = parseInt($(this).data('value'), 10);
		        
		        // 오늘 날짜 계산
		        var today = new Date();
		        
		        // 필터링 처리
		        $('#inventory tr').each(function() {
		            // 4번째 열의 값을 가져옴
		            var expiryDateText = $(this).find('td:eq(3)').text();
		            
		            // 날짜가 유효하지 않으면 넘어감
		            if (!expiryDateText.match(/^\d{4}-\d{2}-\d{2}$/)) {
		                $(this).hide(); // 잘못된 데이터는 숨김
		                return;
		            }

		            // YYYY-MM-DD 형식의 텍스트를 Date 객체로 변환
		            var expiryDate = new Date(expiryDateText);

		            // 남은 일수 계산
		            var diffTime = expiryDate - today;
		            var diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

		            // 조건에 맞는 행만 표시
		            if (diffDays <= filterMonths * 30 && diffDays > 0) {
		                $(this).show(); // 조건에 맞으면 표시
		            } else {
		                $(this).hide(); // 조건에 맞지 않으면 숨김
		            }
		        });
		    });
			
			$("#wrap .table_line #inventory_list tr").each(function() {
				var tenthTd = $(this).find("td").eq(11).find("#returnProduct").val(); // 0-based index, so 9 is the 10th td
				if (tenthTd === "반품됨") {
					$(this).css({"text-decoration" : "line-through", "opacity" : "0.6"});
				}
			});
			$(document).keydown(function(event) {
				if (event.which === 13) {
					if ($("#wrap #barcodeInput").val() === '') {
						return false;
					}
					event.preventDefault();
					$('#formTeg').submit(); // 폼 제출
				}
			});
			$('#nameSearch').focus(function() {
				$('#barcodeInput').blur();
			});

			// #wrap에 마우스가 올라가거나 #nameSearch에 focus가 없는 경우에는 #barcodeInput으로 포커스가 이동
			$("#wrap").mouseover(function() {
				if (!$("#nameSearch, #position_filter").is(":focus")) {
					$('#barcodeInput').focus();
				}
			});
			$("#wrap").on("click",function() {
				if (!$("#nameSearch, #position_filter").is(":focus")) {
					$('#barcodeInput').focus();
				}
			});
			//가격 정렬
			$(".priceAscendingOrder").click(function() {
				sortTable(true); // 오름차순 정렬 함수 호출
			});
			$(".priceDescendingOrder").click(function() {
				sortTable(false); // 내림차순 정렬 함수 호출
			});
			//이름 정렬
			$(".nameAscendingOrder").click(function() {
				sortByName(true); // 이름을 오름차순으로 정렬하는 함수 호출
			});
			$(".nameDescendingOrder").click(function() {
				sortByName(false); // 이름을 내림차순으로 정렬하는 함수 호출
			});
			//재고 수량 정렬
			$(".invAscendingOrder").click(function() {
				sortByinv(true); // 이름을 오름차순으로 정렬하는 함수 호출
			});
			$(".invDescendingOrder").click(function() {
				sortByinv(false); // 이름을 내림차순으로 정렬하는 함수 호출
			});
			//일정 유통기한 확인 스크립트
			// 일정 유통기한 확인 스크립트
			$("#wrap #formTeg #deliveryDateCh").on("input",function() {
				var inputDate = new Date($(this).val()); // 사용자가 입력한 날짜 가져오기
				var today = new Date(); // 오늘 날짜 가져오기
				if (inputDate == "") {
					$("#wrap .table_line #inventory_list tr").show(); // 유통기한 선택이 없으면 전체 보여주기
				}
				if (!isNaN(inputDate)) {
					var inputYear = inputDate.getFullYear();
					var inputMonth = inputDate.getMonth(); // 월은 0부터 11까지이므로 주의
					var inputDay = inputDate.getDate(); // 일자 추가

					$("#wrap .table_line #inventory_list tr").each(function() {
						var dateText = $(this).find("td:eq(9)").text().trim(); // 8번째 셀(td)의 유통기한 텍스트 가져오기
						var date = new Date(dateText); // 유통기한을 Date 객체로 변환
						if (!isNaN(date)) {
							// 선택된 날짜가 오늘부터 이후 날짜인지 확인
							if (date >= today && date <= inputDate) {
								$(this).show();
							} else {
								$(this).hide();
							}
						} else {
							$(this).hide();
						}
				});
				} else {
					$("#wrap .table_line #inventory_list tr").hide(); // 날짜 형식이 유효하지 않으면 모든 행 숨기기
				}
			});

							//정렬에 사용하는 트리거
							function sortTable(ascending) {
								var rows = $('.table_line tbody tr').get();

								rows.sort(function(rowA, rowB) {
									var priceA = parseFloat($(rowA).find(
											'td:eq(3)').text().replace(
											/[^\d.-]/g, '')); // 숫자로 변환
									var priceB = parseFloat($(rowB).find(
											'td:eq(3)').text().replace(
											/[^\d.-]/g, '')); // 숫자로 변환

									if (ascending) {
										return priceA - priceB;
									} else {
										return priceB - priceA;
									}
								});

								$.each(rows, function(index, row) {
									$('.table_line tbody').append(row);
								});
							}
							//이름 오름차순/내림차순에 사용되는 트리거
							function sortByName(ascending) {
								var $tbody = $('.table_line tbody');
								var rows = $tbody.find('tr').get();

								rows.sort(function(rowA, rowB) {
									var nameA = $(rowA).find('td:eq(1)').text()
											.toUpperCase(); // 대소문자 구분 없이 정렬하기 위해 대문자로 변환
									var nameB = $(rowB).find('td:eq(1)').text()
											.toUpperCase(); // 대소문자 구분 없이 정렬하기 위해 대문자로 변환

									if (ascending) {
										return (nameA < nameB) ? -1
												: (nameA > nameB) ? 1 : 0; // 오름차순 정렬
									} else {
										return (nameA > nameB) ? -1
												: (nameA < nameB) ? 1 : 0; // 내림차순 정렬
									}
								});

								$.each(rows, function(index, row) {
									$tbody.append(row);
								});
							}

							//재고 수량 정렬 트리거
							function sortByinv(ascending) {
								var rows = $('.table_line tbody tr').get();

								rows.sort(function(rowA, rowB) {
									var priceA = parseFloat($(rowA).find(
											'td:eq(4)').text().replace(
											/[^\d.-]/g, '')); // 숫자로 변환
									var priceB = parseFloat($(rowB).find(
											'td:eq(4)').text().replace(
											/[^\d.-]/g, '')); // 숫자로 변환

									if (ascending) {
										return priceA - priceB;
									} else {
										return priceB - priceA;
									}
								});

								$.each(rows, function(index, row) {
									$('.table_line tbody').append(row);
								});
							}
						});

		if ($("tbody").height() <= 200) {
			$(this).css("overflow-Y", "scroll");
		}

		//재품 이름 검색 스크립트
		$("#nameSearch").on("input", function() {
			var searchText = $(this).val().toLowerCase(); // 입력된 텍스트를 소문자로 변환하여 저장

			// 모든 행을 숨김
			$('.table_line tbody tr').hide();

			// 테이블의 각 행을 순회하며 입력된 텍스트와 일치하는 경우에만 보임
			$('.table_line tbody tr').each(function() {
				var rowName = $(this).find('td:eq(1)').text().toLowerCase(); // 현재 행의 이름을 소문자로 가져오기
				if (rowName.indexOf(searchText) !== -1) {
					$(this).show(); // 입력된 텍스트가 현재 행의 이름에 포함되어 있으면 보이기
				}
			});
		});
		//제품 즐겨찾기 트리거
		$(document).on(
				'click',
				'#bookmark_button',
				function() {
					var buttonText = $(this).val().trim(); // 버튼 텍스트 가져오기
					var medicineName = $(this).closest('tr').find('td:eq(1)')
							.text().trim(); // 약물 이름 가져오기
					var DeliveryDate = $(this).closest('tr').find('td:eq(9)')
							.text().trim(); // 전달 날짜 가져오기

					if (buttonText === '즐겨찾기 제거') {
						alert('즐겨찾기에서 제거하시겠습니까?');
					} else if (buttonText === '즐겨찾기 추가') {
						alert('즐겨찾기에 추가하시겠습니까?');
					}

					$.ajax({
						url : "bookmark_update.jsp",
						type : 'POST',
						data : {
							medicineName : medicineName,
							DeliveryDate : DeliveryDate,
							buttonText : buttonText
						},
						success : function(response) {
							alert("즐겨찾기에(서) "
									+ (buttonText.charAt(5) + buttonText
											.charAt(6)) + "되었습니다.");
							window.location.href = "index.jsp";
						},
						error : function(xhr, status, error) {
							alert("실패: " + error);
							window.location.href = "index.jsp";
						}
					});
				});
		$("#wrap .table_line #inventory_list #returnProduct").on(
				"click",
				function() {
					//버튼을 누른 제품의 반품 여부 확인
					var returnText = $(this).val().trim();
					//해당 제품의 이름 가져오기
					var medicineName = $(this).closest('tr').find('td:eq(1)')
							.text().trim();
					//해당 제품의 유통기한 가져오기
					var DeliveryDate = $(this).closest('tr').find('td:eq(9)')
							.text().trim();
					//해당 제품의 규격 가져오기
					var standard = $(this).closest('tr').find('td:eq(7)')
							.text().trim();

					$
							.ajax({
								url : "returnUpdate.jsp",
								type : 'POST',
								data : {
									medicineName : medicineName,
									DeliveryDate : DeliveryDate,
									standard : standard,
									returnText : returnText
								},
								success : function(response) {
									console.log(returnText, medicineName,
											DeliveryDate);
									window.location.href = "index.jsp";
								},
								error : function(xhr, status, error) {
									alert("실패: " + error);
									window.location.href = "index.jsp";
								}
							});
				});
		const toggleButton = document.getElementById('toggleButton');
	    const toggleText = document.getElementById('toggleText');
	    let isOn = false;

	    toggleButton.addEventListener('click', () => {
	        isOn = !isOn;
	        toggleButton.classList.toggle('on', isOn);
	        toggleText.textContent = isOn ? '반품 ON' : '반품 OFF';
	    });
	    
	    $(".updateInfo").on("click", function(event) {
	        event.preventDefault();  // 기본 이벤트 차단

	        var row = $(this).closest("tr");
	        var secondTdText = row.find("td:eq(2)").text();  // 2번째 td : 제품이름
	        var eighthTdText = row.find("td:eq(5)").text();  // 8번째 td : 규격
	        var ninthTdText = row.find("td:eq(3)").text();    // 9번째 td : 유통기한

	        $.ajax({
	            url: 'dataUpdate.jsp',
	            type: 'POST',
	            data: {
	                secondData: secondTdText,
	                eighthData: eighthTdText,
	                ninthData: ninthTdText
	            },
	            success: function(response) {
	                // 성공적으로 데이터 전송 후 처리할 코드
	                console.log('Data sent successfully');
	                alert(secondTdText);
	                location.href='editPage.jsp';
	                // 필요한 경우 페이지 이동이나 업데이트 처리 추가
	            },
	            error: function(xhr, status, error) {
	                console.error('Error fetching data:', error);
	            }
	        });
	    });

	    $('.deleteInfo').on('click', function(event) {
	        event.preventDefault();  // 기본 동작 차단, 함수 맨 위에 위치
	        if (confirm('삭제하시겠습니까?')) {
	            // 사용자가 "예"를 클릭했을 때
	            var row = $(this).closest("tr");
	            var secondTdText = row.find("td:eq(2)").text();  // 2번째 td
	            var eighthTdText = row.find("td:eq(5)").text();  // 8번째 td
	            var ninthTdText = row.find("td:eq(3)").text();    // 9번째 td
				console.log(secondTdText, eighthTdText, ninthTdText);
	            $.ajax({
	                url: 'datadelete.jsp',
	                type: 'POST',
	                data: {
	                    secondData: secondTdText,
	                    eighthData: eighthTdText,
	                    ninthData: ninthTdText
	                },
	                success: function(response) {
	                    console.log('Data sent successfully');
	                    location.href='index.jsp';// 서버의 응답 출력
	                },
	                error: function(xhr, status, error) {
	                    console.error('Error fetching data:', error);
	                }
	            });
	        } else {
	            // 사용자가 "아니오"를 클릭했을 때
	            alert('NO');
	        }
	    });
	    $(document).ready(function() {
	        let isHidden = false; // 행이 숨겨져 있는 상태를 추적

	        $('#toggleButton').click(function() {
	            $('#inventory_list tr').each(function() { // 각 행을 반복
	                let returnVal = $(this).find('td:nth-child(11) button').text(); // 11번째 td 안의 버튼 텍스트 가져오기
	                
	                // button이 존재하고, 텍스트가 '반품됨'인지 확인
	                if (returnVal === '반품됨') {
	                    let row = $(this); // 현재 행을 가져옴
	                    
	                    if (isHidden) {
	                        row.show(); // 행을 표시
	                    } else {
	                        row.hide(); // 행을 숨김
	                    }
	                }
	            });

	            // 토글 텍스트 변경
	            $('#toggleText').text(isHidden ? '반품 OFF' : '반품 ON');
	            isHidden = !isHidden; // 상태 토글
	        });
	    });
	    
	    function showFirstToggleButton() {
	        const rows = Array.from(document.querySelectorAll('#inventory_list tr'));

	        // 같은 제품 이름을 가진 tr들을 그룹화
	        const groupedRows = {};

	        rows.forEach(row => {
	            const medicineName = row.cells[2].textContent; // 제품 이름
	            const toggleButton = row.querySelector('.toggle-details');

	            if (!groupedRows[medicineName]) {
	                groupedRows[medicineName] = [];
	            }
	            groupedRows[medicineName].push(row);

	            // 첫 번째 tr만 .toggle-details 버튼 보이기, 나머지는 숨기기
	            if (groupedRows[medicineName].length > 1) {
	                toggleButton.style.display = 'none'; // 숨기기
	            } else {
	                toggleButton.style.display = ''; // 보이기
	            }
	        });
	    }
	    
	    document.addEventListener('DOMContentLoaded', function () {
	    	
	    	showFirstToggleButton();
	    	
	        // 제품 이름별 클릭 상태를 저장하는 객체
	        const toggleStates = {}; // 각 제품 이름별 클릭 상태를 저장

	        // 각 버튼에 클릭 이벤트 리스너 추가
	        document.querySelectorAll('.toggle-details').forEach(button => {
	            button.addEventListener('click', function (event) {
	                event.preventDefault(); // 기본 동작 방지

	                const row = this.closest('tr'); // 현재 행
	                const medicineName = row.cells[2].textContent; // 제품 이름

	                // 같은 제품들 찾기
	                const rows = Array.from(document.querySelectorAll('tr'));
	                const sameProducts = rows.filter(r => {
	                    return r.cells[2].textContent === medicineName;
	                });

	                // 유통기한이 가장 짧은 제품 찾기
	                let minExpiryRow = null;
	                let minExpiryDate = null;

	                sameProducts.forEach(r => {
	                    const expiryDate = new Date(r.cells[9].textContent); // 유통기한
	                    if (!minExpiryDate || expiryDate < minExpiryDate) {
	                        minExpiryDate = expiryDate;
	                        minExpiryRow = r;
	                    }
	                });

	                // 해당 제품 이름의 상태를 가져옴
	                const isHidden = toggleStates[medicineName] || false;

	                if (isHidden) {
	                    // 모든 제품 보이게 함
	                    sameProducts.forEach(r => {
	                        r.style.display = ''; // 모든 제품 보이기
	                    });
	                    toggleStates[medicineName] = false; // 상태 업데이트
	                } else {
	                    // 모두 숨김
	                    sameProducts.forEach(r => {
	                        r.style.display = 'none'; // 기본적으로 숨김
	                    });
	                    // 유통기한이 가장 짧은 제품만 보이게 함
	                    if (minExpiryRow) {
	                        minExpiryRow.style.display = ''; // 보이기
	                    }
	                    toggleStates[medicineName] = true; // 상태 업데이트
	                }
	            });
	        });

	        // 페이지가 로드될 때 각 제품 이름에 대해 한 번씩 클릭
	        document.querySelectorAll('.toggle-details').forEach(button => {
	            const row = button.closest('tr');
	            const medicineName = row.cells[2].textContent; // 제품 이름

	            // 이미 클릭한 제품은 건너뛰기
	            if (!toggleStates[medicineName]) {
	                button.click(); // 버튼 한 번씩 클릭
	            }
	        });
	    });
	    
	    document.addEventListener("DOMContentLoaded", () => {
	        const rowsPerPage = 20; // 페이지당 표시할 행 수
	        const tableBody = document.getElementById("inventory_list");
	        const rows = Array.from(tableBody.querySelectorAll("tr"));
	        const paginationDiv = document.getElementById("pagination");

	        const totalPages = Math.ceil(rows.length / rowsPerPage);
	        const maxVisibleButtons = 5; // 표시할 최대 버튼 개수

	        function createPagination(currentPage) {
	            paginationDiv.innerHTML = ""; // 기존 버튼 초기화

	            // "처음" 버튼
	            if (currentPage > 1) {
	                const firstButton = document.createElement("button");
	                firstButton.textContent = "1";
	                firstButton.className = "pagination-button";
	                firstButton.addEventListener("click", () => showPage(1));
	                paginationDiv.appendChild(firstButton);

	                if (currentPage > maxVisibleButtons) {
	                    const dots = document.createElement("span");
	                    dots.textContent = "...";
	                    dots.className = "pagination-dots";
	                    paginationDiv.appendChild(dots);
	                }
	            }

	            // 중앙 페이지 버튼
	            const startPage = Math.max(1, currentPage - Math.floor(maxVisibleButtons / 2));
	            const endPage = Math.min(totalPages, startPage + maxVisibleButtons - 1);

	            for (let i = startPage; i <= endPage; i++) {
	                const button = document.createElement("button");
	                button.textContent = i;
	                button.className = "pagination-button";
	                if (i === currentPage) {
	                    button.style.backgroundColor = "#4169E1";
	                    button.style.color = "white";
	                }
	                button.addEventListener("click", () => showPage(i));
	                paginationDiv.appendChild(button);
	            }

	            // "마지막" 버튼
	            if (currentPage < totalPages - Math.floor(maxVisibleButtons / 2)) {
	                if (currentPage + maxVisibleButtons - 1 < totalPages) {
	                    const dots = document.createElement("span");
	                    dots.textContent = "...";
	                    dots.className = "pagination-dots";
	                    paginationDiv.appendChild(dots);
	                }

	                const lastButton = document.createElement("button");
	                lastButton.textContent = totalPages;
	                lastButton.className = "pagination-button";
	                lastButton.addEventListener("click", () => showPage(totalPages));
	                paginationDiv.appendChild(lastButton);
	            }
	        }

	        // 페이지 표시 함수
	        function showPage(page) {
	            const start = (page - 1) * rowsPerPage;
	            const end = start + rowsPerPage;

	            rows.forEach((row, index) => {
	                row.style.display = index >= start && index < end ? "table-row" : "none";
	            });

	            // 페이지네이션 업데이트
	            createPagination(page);
	        }

	        // 초기화
	        showPage(1);
	    });document.addEventListener("DOMContentLoaded", function () {
            const searchInput = document.getElementById("nameSearch");
            const tableRows = document.querySelectorAll("#inventory_list tr");

            // 입력 필드의 값에 따라 행 표시/숨김
            searchInput.addEventListener("input", function () {
                const searchValue = searchInput.value.trim().toLowerCase();

                tableRows.forEach(row => {
                    const rowText = row.cells[2].textContent.trim().toLowerCase(); // 첫 번째 셀의 텍스트 가져오기
                    if (searchValue && rowText.includes(searchValue)) {
                        row.style.display = "table-row"; // 일치하면 보이기
                    } else {
                        row.style.display = "none"; // 일치하지 않으면 숨기기
                    }
                });
            });
        });
	</script>
</body>
</html>
