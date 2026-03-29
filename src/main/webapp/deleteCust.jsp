<%@page import="com.mysql.cj.x.protobuf.MysqlxPrepare.Prepare"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
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
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
<%
	request.setCharacterEncoding("UTF-8");
	String custNumber = request.getParameter("custNo");
	PreparedStatement pstmt = null;
	ResultSet rs = null;
	
	System.out.println(custNumber);
	
	try{
		String sql = "delete from members where customerNumber = ? AND domain_type = ?";
		pstmt = conn.prepareStatement(sql);
		pstmt.setString(1, custNumber);
		pstmt.setString(2, domainType);
		pstmt.executeUpdate();
	}catch(Exception e){
		e.printStackTrace();
	}finally {
	    try { if (rs != null) rs.close(); } catch (Exception ignored) {}
	    try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {} 
	    if (conn != null) {
	        try { conn.close(); } catch (Exception ignore) {}
	    }
	}
%>

</body>
</html>