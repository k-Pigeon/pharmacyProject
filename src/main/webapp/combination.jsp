<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ include file="sessionManager.jsp"%>
<%@ include file="DBconnection.jsp"%>
<%
String dbName = (session != null) ? (String) session.getAttribute("dbName") : null;
String id = (session != null) ? (String) session.getAttribute("id") : null;
String password = (session != null) ? (String) session.getAttribute("password") : null;
String domainType = (session != null) ? (String) session.getAttribute("domainType") : null; 

if (id == null || dbName == null) {
	response.sendRedirect("login.jsp");
	return;
}

jdbcDriver = dbName;

request.setCharacterEncoding("UTF-8");

String memberName = request.getParameter("memberName");
System.out.println(memberName);

String sql = " select memberName, customerNumber from members "
		   + " where memberName = ? AND domain_type = ? ";
PreparedStatement pstmt = null;
ResultSet rs = null;

try{
	pstmt = conn.prepareStatement(sql);
	pstmt.setString(1, memberName);
	pstmt.setString(2, domainType);
	rs = pstmt.executeQuery();
	
	while(rs.next()){
		%>
			<div class="addUpLine">
				<span class="checkLine"><input type="checkbox" class="check"></span>
				<span class="NameLine"><%= rs.getString("memberName") %></span>
				<span class="numberLine"><%= rs.getString("customerNumber") %></span>
			</div>
		<%
	}
}catch(Exception e){
	e.printStackTrace();
}finally{
    if (rs != null) try { rs.close(); } catch (SQLException e) {}
    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
    if (conn != null) try { conn.close(); } catch (Exception ignore) {}
}

%>