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

if (id == null || dbName == null) {
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
	String regiDate = request.getParameter("regiDate");
	PreparedStatement pstmt = null;
	try{
		String sql = "delete from salesdata where sale_date = ?";
		pstmt = conn.prepareStatement(sql);
		pstmt.setString(1, regiDate);
		pstmt.executeUpdate();
	}catch(Exception e){
		e.printStackTrace();
	}
%>
</body>
</html>