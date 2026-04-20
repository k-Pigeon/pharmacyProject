<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.regex.*"%>
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
%>

<%
String medicineName = request.getParameter("medicineName");
PreparedStatement pstmt = null;
ResultSet rs = null;

boolean hasResult = false;

try {
    String sql = "SELECT medicineName, companyName, standard, kind, inventory, serialNumber, " +
                 "receiptDate, deliveryDate, FORMAT(buyingprice, 0) AS buyingprice," + 
    			 " FORMAT(price, 0) AS price " +
                 "FROM testTable  WHERE medicineName LIKE ? AND domain_type = ?";
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, "%" + medicineName + "%");
    pstmt.setString(2, domainType);
    rs = pstmt.executeQuery();
%>

<%
while (rs.next()) {
    hasResult = true;
%>
<div class='result-row'
	style='display: block; cursor: pointer; width: 80%; height: 50px; line-height: 50px; border-radius: 10px; border: 1px solid black; font-size: 20px;'
	data-medicinename='<%= rs.getString("medicineName") %>'
	data-companyname='<%= rs.getString("companyName") %>'
	data-standard='<%= rs.getString("standard") %>'
	data-inventory='<%= rs.getString("inventory") %>'
	data-kind='<%= rs.getString("kind") %>'
	data-serialnumber='<%= rs.getString("serialNumber") %>'
	data-receiptdate='<%= rs.getString("receiptDate") %>'
	data-deliverydate='<%= rs.getString("deliveryDate") %>'
	data-buyingprice='<%= rs.getString("buyingprice") %>'
	data-price='<%= rs.getString("price") %>'>
	<%= rs.getString("medicineName") %>
	<%= rs.getString("companyName") %>
	<%= rs.getString("inventory") %>
	<%= rs.getString("price") %>
	<%= rs.getString("Buyingprice") %>
</div>
<% } %>

<% if (!hasResult) { %>

<% } %>

<%
} catch (Exception e) {
    e.printStackTrace();
} finally {
    try { if (rs != null) rs.close(); } catch (Exception ignored) {}
    try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
    try { if (conn != null) conn.close(); } catch (Exception ignored) {}
}
%>
