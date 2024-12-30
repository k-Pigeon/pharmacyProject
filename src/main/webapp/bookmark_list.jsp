<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Insert title here</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
	<div id="wrap">
		<header>
			<jsp:include page="header.jsp"></jsp:include>
		</header>
		<form action="bookmark_list.jsp" name="data" method="post"
			id="formTeg">
			<input id="barcodeInput" type='text' name="barcodeInput"
				autofocus="autofocus" /> <input type="text" id="nameSearch">
			<table id="table_line">
				<colgroup>
					<col width="20%">
					<col width="10%">
					<col width="10%">
					<col width="10%">
					<col width="15%">
					<col width="15%">
				</colgroup>
				<thead>
					<tr>
						<th>이름<span class="ascendingOrder nameAscendingOrder">↑</span><span
							class="descendingOrder nameDescendingOrder">↓</span></th>
						<th>가격<br> <span
							class="ascendingOrder priceAscendingOrder">↑</span><span
							class="descendingOrder priceDescendingOrder">↓</span></th>
						<th>재고 수량<br> <span
							class="ascendingOrder invAscendingOrder">↑</span><span
							class="ascendingOrder invDescendingOrder">↓</span></th>
						<th>규격</th>
						<th>입고 날짜</th>
						<th>유통기한<br>(유효기간)
						</th>
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

						String SQLCondition = "";

						String sql = "";

						conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPwd);

						if (request.getMethod().equalsIgnoreCase("post")) {
							SQLCondition = request.getParameter("barcodeInput");
							//값을 검색했을 때 사용하는 SQL
							sql = "SELECT "
						            + " MAX(medicineName) AS medicineName, "
						            + " MAX(price) AS price, "
						            + " CAST(SUM(inventory) AS UNSIGNED) AS totalInventory, "
						            + " MAX(kind) AS kind, "
						            + " MAX(PlaceClassification) AS PlaceClassification, "
						            + " MAX(companyName) AS companyName, "
						            + " MAX(standard) AS standard, "
						            + " MAX(receiptDate) AS receiptDate, DeliveryDate "
						            + " FROM testTable WHERE Bookmark = '1' "
						            + " AND PlaceClassification IN ('약국', '지하') "
						            + " AND SerialNumber = ? "
						            + " GROUP BY medicineName, DeliveryDate "
						            + " ORDER BY DeliveryDate ASC";
							pstmt = conn.prepareStatement(sql);
							pstmt.setString(1, SQLCondition); // PreparedStatement를 사용하여 바인딩
						}else {
						    sql = "SELECT "
						            + " MAX(medicineName) AS medicineName, "
						            + " MAX(price) AS price, "
						       		+ " CAST(SUM(inventory) AS UNSIGNED) AS totalInventory, "
						            + " MAX(kind) AS kind, "
						            + " MAX(PlaceClassification) AS PlaceClassification, "
						            + " MAX(companyName) AS companyName, "
						            + " MAX(standard) AS standard, "
						            + " MAX(receiptDate) AS receiptDate, DeliveryDate "
						            + " FROM testTable WHERE Bookmark = '1' "
						            + " AND PlaceClassification IN ('약국', '지하') "
						            + " GROUP BY medicineName, DeliveryDate "
						            + "ORDER BY DeliveryDate ASC";
						        pstmt = conn.prepareStatement(sql);
						    }
						rs = pstmt.executeQuery();

						while (rs.next()) {
					%>
					<tr>
						<td><%=rs.getString("medicineName")%></td>
						<td><%=rs.getString("price")%></td>
						<td><%=rs.getString("totalInventory")%></td>
						<td><%=rs.getString("standard")%></td>
						<td><%=rs.getString("receiptDate")%></td>
						<td><%=rs.getString("DeliveryDate")%></td>
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
		</form>
	</div>
	<script src="jquery-3.7.1.min.js"></script>
	<script type='text/javascript'>
		$(document).ready(
				function() {
					$(document).keydown(function(event) {
						if (event.which === 13) {
							event.preventDefault(); // 기본 제출 동작 방지
							$('#formTeg').submit(); // 폼 제출
						}
					});

					setTimeout(function() {
						if ($("#barcodeInput").val() !== "") {
							$("#wrap #formTeg").submit();
						}
					}, 6000);

					$('#nameSearch').focus(function() {
						$('#barcodeInput').blur();
					});

					// #wrap에 마우스가 올라가거나 #nameSearch에 focus가 없는 경우에는 #barcodeInput으로 포커스가 이동
					$('#wrap #table_line').mouseenter(function() {
						$('#barcodeInput').focus();
					});

					// kindValue가 변경될 때 포커스를 해제합니다.
					$("#kindValue").mouseenter(function() {
						$('#barcodeInput').blur();
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

					//정렬에 사용하는 트리거
					function sortTable(ascending) {
						var rows = $('#table_line tbody tr').get();

						rows.sort(function(rowA, rowB) {
							var priceA = parseFloat($(rowA).find('td:eq(1)')
									.text().replace(/[^\d.-]/g, '')); // 숫자로 변환
							var priceB = parseFloat($(rowB).find('td:eq(1)')
									.text().replace(/[^\d.-]/g, '')); // 숫자로 변환

							if (ascending) {
								return priceA - priceB;
							} else {
								return priceB - priceA;
							}
						});

						$.each(rows, function(index, row) {
							$('#table_line tbody').append(row);
						});
					}
					//이름 오름차순/내림차순에 사용되는 트리거
					function sortByName(ascending) {
						var $tbody = $('#table_line tbody');
						var rows = $tbody.find('tr').get();

						rows.sort(function(rowA, rowB) {
							var nameA = $(rowA).find('td:eq(0)').text()
									.toUpperCase(); // 대소문자 구분 없이 정렬하기 위해 대문자로 변환
							var nameB = $(rowB).find('td:eq(0)').text()
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
						var rows = $('#table_line tbody tr').get();

						rows.sort(function(rowA, rowB) {
							var priceA = parseFloat($(rowA).find('td:eq(2)')
									.text().replace(/[^\d.-]/g, '')); // 숫자로 변환
							var priceB = parseFloat($(rowB).find('td:eq(2)')
									.text().replace(/[^\d.-]/g, '')); // 숫자로 변환

							if (ascending) {
								return priceA - priceB;
							} else {
								return priceB - priceA;
							}
						});

						$.each(rows, function(index, row) {
							$('#table_line tbody').append(row);
						});
					}
				});

		//재품 이름 검색 스크립트
		$("#nameSearch").on("input", function() {
			var searchText = $(this).val().toLowerCase(); // 입력된 텍스트를 소문자로 변환하여 저장

			// 모든 행을 숨김
			$('#table_line tbody tr').hide();

			// 테이블의 각 행을 순회하며 입력된 텍스트와 일치하는 경우에만 보임
			$('#table_line tbody tr').each(function() {
				var rowName = $(this).find('td:eq(0)').text().toLowerCase(); // 현재 행의 이름을 소문자로 가져오기
				if (rowName.indexOf(searchText) !== -1) {
					$(this).show(); // 입력된 텍스트가 현재 행의 이름에 포함되어 있으면 보이기
				}
			});
		});
	</script>
</body>
</html>