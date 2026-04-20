<%@ page contentType="text/html; charset=UTF-8" language="java"%>
<%@ page import="java.sql.*, java.util.*"%>
<%@ include file="sessionManager.jsp"%>
<%@ include file="DBconnection.jsp"%>
<%
String dbName = (session != null) ? (String) session.getAttribute("dbName") : null;
String id = (session != null) ? (String) session.getAttribute("id") : null;
String password = (session != null) ? (String) session.getAttribute("password") : null;

/* out.println(password);
out.println(dbName);
out.println(id);
out.println(password); */

String domainType = (session != null) ? (String) session.getAttribute("domainType") : null; if (id == null || dbName == null) {
    response.sendRedirect("login.jsp");
    return;
}

jdbcDriver = dbName;

Statement stmt = null;
ResultSet rs = null;

try {
	// 클라이언트에서 전달된 값 받기 (POST 방식으로 값 받기)
	String value = request.getParameter("value");

	// 쿼리 작성 (실제 column 이름으로 수정 필요)
	String sql = "SELECT saleDate, (inventory / REGEXP_REPLACE(standard, '[^0-9]+', '')) AS letters, price, (inventory * price) AS sumPrice, DeliveryDate "
			   + "  FROM SalesRecord WHERE medicineName = ? AND domain_type = ? ";

	// PreparedStatement 사용하여 쿼리 실행
	PreparedStatement preparedStatement = conn.prepareStatement(sql);
	preparedStatement.setString(1, value);
	preparedStatement.setString(2, domainType);
	rs = preparedStatement.executeQuery();
	boolean hasResults = rs.next();
	if (hasResults) {
%>
<div class='popupDown'>닫기 X</div>
<table border='1' style='width: 100%; height: auto;'>
	<tr>
		<th>판매날짜</th>
		<th>개수</th>
		<th>낱개가격</th>
		<th>총 가격</th>
		<th>유통기한</th>
	</tr>
	<%
	do {
	%>
	<tr>
		<td><%=rs.getString("saleDate")%></td>
		<td><%=rs.getString("letters") != null ? rs.getString("letters") : "0"%></td>
		<td><%=rs.getString("price") != null ? rs.getString("price") : "0"%></td>
		<td><%=rs.getString("sumPrice") != null ? rs.getString("sumPrice") : "0"%></td>
		<td><%=rs.getString("DeliveryDate")%></td>
	</tr>
	<%
	} while (rs.next());
	%>
</table>
<%
} else {
%>
<div class='popupDown'>닫기 X</div>
<div class='no_data_Record'>데이터가 없습니다.</div>
<%
}

} catch (Exception e) {
e.printStackTrace();
out.println("오류 발생: " + e.getMessage());
} finally {
try {
    try { if (stmt != null) stmt.close(); } catch (Exception ignored) {}
    try { if (rs != null) rs.close(); } catch (Exception ignored) {}
    try { if (conn != null) conn.close(); } catch (Exception ignored) {}
} catch (Exception e) {
e.printStackTrace();
}
}
%>
