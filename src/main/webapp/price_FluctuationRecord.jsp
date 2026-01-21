<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Sales Record</title>
<link rel="stylesheet" href="style.css">
<style>
/* 테이블 전체 폭을 100%로 설정 */
.table_line {
	width: 100%;
	margin: 0 auto;
	table-layout: fixed;
	border-collapse: separate; /* 테두리가 분리된 상태 */
	border-spacing: 0; /* 셀 간격 제거 */
	border-radius: 15px; /* 테두리 둥글게 */
	border: 1px solid #ddd; /* 테이블 전체 외곽 테두리 */
	overflow: hidden; /* 테두리 밖으로 나오는 셀 내용 숨김 */
}

.table_line th, .table_line td {
	border: 1px solid #ddd; /* 셀 경계 */
	padding: 8px;
}

/* 각 모서리를 둥글게 설정 */
.first_table_line thead tr:first-child th:first-child {
	border-top-left-radius: 15px; /* 왼쪽 상단 둥글게 */
}

.first_table_line thead tr:first-child th:last-child {
	border-top-right-radius: 15px; /* 오른쪽 상단 둥글게 */
}

.second_table_line tbody tr:last-child td:first-child {
	border-bottom-left-radius: 15px; /* 왼쪽 하단 둥글게 */
}

.second_table_line tbody tr:last-child td:last-child {
	border-bottom-right-radius: 15px; /* 오른쪽 하단 둥글게 */
}

/* 스크롤을 위한 처리 */
.scrollable_table {
	display: block;
	height: 600px;
	overflow-y: auto; /* 세로 스크롤만 */
}
</style>
</head>
<body>
	<div id="wrap" style="display: block;">
		<header>
			<%@ include file="header.jsp"%>
		</header>
		<%
		// 오늘 날짜로부터 최근 3개월을 계산
		java.util.Calendar cal = java.util.Calendar.getInstance();
		java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM");
		String currentMonth = sdf.format(cal.getTime()); // 현재 월 (2024-09)
		cal.add(java.util.Calendar.MONTH, -1);
		String prevMonth1 = sdf.format(cal.getTime()); // 전월 (2024-08)
		cal.add(java.util.Calendar.MONTH, -1);
		String prevMonth2 = sdf.format(cal.getTime()); // 두 달 전 (2024-07)
		%>
		<!-- 테이블 헤더 -->
		<div id="data_wrap" style="width: 1000px;margin: 0 auto;padding: 0;transform: translateY(15vh);height: 30px;">
			<input type="text" id="medicineSearch" style="float: right;height: 30px;width: 200px;" Placeholder="제품 검색">
		</div>
		<table class="table_line first_table_line" style="margin-top: 10%; height: 50px; border-collapse: collapse;">
			<colgroup>
				<col width="20%">
				<col width="20%">
				<col width="20%">
				<col width="20%">
				<col width="20%">
			</colgroup>
			<thead>
				<tr>
					<th>제품명</th>
					<th><%=currentMonth%></th>
					<th><%=prevMonth1%></th>
					<th><%=prevMonth2%></th>
					<th>최종 가격</th>
				</tr>
			</thead>
		</table>

		<!-- 데이터 표시를 위한 스크롤 가능한 테이블 -->
		<div class="scrollable_table">
			<table class="table_line second_table_line" style="margin-top: 0; border-collapse: collapse;">
				<colgroup>
					<col width="16%">
					<col width="16%">
					<col width="16%">
					<col width="16%">
					<col width="16%">
				</colgroup>
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

						// SQL 쿼리 수정: 중복된 제품명에 대해 최근 날짜를 가져오고, 그에 해당하는 최종 가격을 구함
						String sql = "SELECT medicineName, "
						+ "       MAX(CASE WHEN saleDate LIKE CONCAT(?, '%') THEN price END) AS price_current, "
						+ "       MAX(CASE WHEN saleDate LIKE CONCAT(?, '%') THEN price END) AS price_prev1, "
						+ "       MAX(CASE WHEN saleDate LIKE CONCAT(?, '%') THEN price END) AS price_prev2, "
						+ "       MAX(saleDate) AS latestSaleDate, " + "       MAX(price) AS latestPrice "
						+ "  FROM fluctuationRecord " + " GROUP BY medicineName" + " order by medicineName ASC";

						pstmt = conn.prepareStatement(sql);
						pstmt.setString(1, currentMonth); // 2024-09
						pstmt.setString(2, prevMonth1); // 2024-08
						pstmt.setString(3, prevMonth2); // 2024-07
						rs = pstmt.executeQuery();

						while (rs.next()) {
					%>
					<tr>
						<td><%=rs.getString("medicineName")%></td>
						<td><%=(rs.getString("price_current") != null) ? rs.getString("price_current") : ""%> <!-- 2024-09 --></td>
						<td><%=(rs.getString("price_prev1") != null) ? rs.getString("price_prev1") : ""%> <!-- 2024-08 --></td>
						<td><%=(rs.getString("price_prev2") != null) ? rs.getString("price_prev2") : ""%> <!-- 2024-07 --></td>
						<td><%=rs.getString("latestPrice")%> <!-- 최종 가격 (최근 날짜의 가격) --></td>
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
		</div>
	</div>

	<script>
	document.getElementById('medicineSearch').addEventListener('keyup', function () {
	      var searchValue = this.value.toLowerCase();
	      var rows = document.querySelectorAll('#inventory_list tr');

	      rows.forEach(function (row) {
	        var medicineName = row.querySelector('td').textContent.toLowerCase();
	        if (medicineName.includes(searchValue)) {
	          row.style.display = '';
	        } else {
	          row.style.display = 'none';
	        }
	      });
	    });
	</script>
</body>
</html>
