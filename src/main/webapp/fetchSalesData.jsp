<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="org.json.JSONObject"%>
<%@ include file="sessionManager.jsp"%>
<%@ include file="DBconnection.jsp"%>
<%
String dbName = (session != null) ? (String) session.getAttribute("dbName") : null;
String id = (session != null) ? (String) session.getAttribute("id") : null;
String password = (session != null) ? (String) session.getAttribute("password") : null;

String domainType = (session != null) ? (String) session.getAttribute("domainType") : null; if (id == null || dbName == null) {
	response.sendRedirect("login.jsp");
	return;
}

jdbcDriver = dbName;
String custnumber = request.getParameter("custnumber");
String newMem = request.getParameter("newMem");
System.out.println(custnumber);

PreparedStatement ps = null;
ResultSet rs = null;
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>판매 내역</title>
</head>
<body>
	<table class="custVal" style="border-collapse: collapse;">
		<thead>
			<tr>
				<th>판매일자</th>
				<th>판매가격</th>
				<th>약품명</th>
				<th>test</th>
			</tr>
		</thead>
		<tbody>
			<%
			try {
				String query = "";
				if ("1".equals(newMem)) {
			// newMem이 1인 경우: 가장 큰 customer_id를 조건으로 사용
			query = "SELECT date(sale_date) as viewDate, sale_date, FORMAT(sum(total_price), 0) AS price,"
					+ " MIN(medicine_name) AS medicine_name, MIN(customer_id) AS customer_id " // ← 여기!
					+ " FROM salesdata WHERE customer_id = (SELECT MAX(CAST(customer_id AS UNSIGNED)) FROM salesdata) "
					+ " GROUP BY sale_date " + " ORDER BY sale_date DESC";

			ps = conn.prepareStatement(query);
			} else {
			// 그 외의 경우: 전달된 custnumber 사용
			query = "SELECT date(sale_date) as viewDate, sale_date, FORMAT(sum(total_price), 0) AS price,"
					+ " MIN(medicine_name) AS medicine_name, MIN(customer_id) AS customer_id " // ← 여기!
					+ " FROM salesdata WHERE customer_id = ? " + " GROUP BY sale_date " + " ORDER BY sale_date DESC";

			ps = conn.prepareStatement(query);
			ps.setString(1, custnumber);
			}
			rs = ps.executeQuery();

			while (rs.next()) {
			%>
			<tr>
				<td><%=rs.getString("viewDate")%></td>
				<td><%=rs.getString("price")%></td>
				<td><%=rs.getString("medicine_name")%></td>
				<td><%=rs.getString("sale_date")%></td>
				<td style="display: none;"><%=rs.getString("customer_id")%></td>
			</tr>
			<%
			}
			} catch (Exception e) {
			e.printStackTrace();
			%>
			<tr>
				<td colspan="4">오류 발생: <%=e.getMessage()%></td>
			</tr>
			<%
			} finally {
		        try { if (ps != null) ps.close(); } catch (Exception ignored) {}
		        try { if (rs != null) rs.close(); } catch (Exception ignored) {}
		        if (conn != null) { try { conn.close(); } catch (Exception ignore) {}
		        }
			}
			%>
		</tbody>
	</table>
	
	<script src="jquery-3.7.1.min.js"></script>
	<script>
	  $(document).ready(function(){
		    var isNewMem = "<%= newMem %>";
		    if (isNewMem === "1") {
		      var val1 = $(".custVal").find("tbody tr td:eq(4)").text();
		      $(document).find(".custnumber").val(val1);
		    }
		  });
	</script>
</body>
</html>
