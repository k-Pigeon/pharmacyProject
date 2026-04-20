<%@ page contentType="application/json; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ include file="DBconnection.jsp" %>
<%
request.setCharacterEncoding("UTF-8");

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
String medicineName = request.getParameter("medicineName");
String standard = request.getParameter("standard");
PreparedStatement pstmt = null;
ResultSet rs = null;

try{
	String query = "SELECT FORMAT(price, 0) AS price, standard FROM RegistTable "
				 + " WHERE medicineName = ? AND standard = ? AND domain_type = ? ";
	pstmt = conn.prepareStatement(query);
	pstmt.setString(1, medicineName);
	pstmt.setString(2, standard);
	pstmt.setString(3, domainType);
	rs = pstmt.executeQuery();

	if (rs.next()) {
	    String json = String.format(
	        "{\"1\": \"%s\", \"price\": \"%s\", \"standard\": \"%s\"}",
	        rs.getString(1),
	        rs.getString("price"),
	        rs.getString("standard")
	    );
	    out.print(json); // 🔥 JSON만 출력!
	}
}finally{
    try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
    try { if (rs != null) rs.close(); } catch (Exception ignored) {}
    try { if (conn != null) conn.close(); } catch (Exception ignored) {}
}
%>

