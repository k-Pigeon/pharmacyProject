<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
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
	<div id="userInfo">
		
	</div>
</body>
</html>