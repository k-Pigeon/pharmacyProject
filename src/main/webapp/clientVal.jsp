<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.text.*"%>
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
%>
<%
	request.setCharacterEncoding("UTF-8");
	String medicineName = request.getParameter("medicineVal");
	ResultSet rs = null;
	PreparedStatement pstmt = null;
	try{
		String SQL = "select a.saleDate saleDate, (a.inventory / a.standard) AS  inventory, "
			+ " b.clientName clientName, a.medicineName medicineName"
			+ "	from SalesRecord  a, clientrecord b "
 			+ " where a.saleDate = b.saleDate "
			+ " and b.clientName like ?"
			+ " and domain_type = ?";
		
		pstmt = conn.prepareStatement(SQL);
		pstmt.setString(1, "%" + medicineName + "%");
		pstmt.setString(2, domainType);
		rs = pstmt.executeQuery();
		
		while(rs.next()){
			%>
				<tr>
					<td><%= rs.getString("saleDate") %></td>
					<td><%= rs.getString("clientName") %></td>
					<td><%= rs.getString("inventory") %></td>
					<td><%= rs.getString("medicineName") %></td>
				</tr>
			<%
		}
	}catch(Exception e){
		e.printStackTrace();
	}finally {
	    if (rs != null) {
	        try { rs.close(); } catch (Exception ignore) {}
	    }
	    if (pstmt != null) {
	        try { pstmt.close(); } catch (Exception ignore) {}
	    }
	    if (conn != null) {
	        try { conn.close(); } catch (Exception ignore) {}
	    }
	}
%>
