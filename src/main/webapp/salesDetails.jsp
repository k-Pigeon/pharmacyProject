<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="sessionManager.jsp"%>
<%@ include file="DBconnection.jsp"%>

<%
response.setContentType("text/html; charset=UTF-8");
request.setCharacterEncoding("UTF-8");

String dbName = (session != null) ? (String) session.getAttribute("dbName") : null;
String id = (session != null) ? (String) session.getAttribute("id") : null;
String password = (session != null) ? (String) session.getAttribute("password") : null;

String domainType = (session != null) ? (String) session.getAttribute("domainType") : null; if (id == null || dbName == null) {
    response.sendRedirect("login.jsp");
    return;
}

// 예) 2025-08 형태 기대
String month = request.getParameter("saleDate"); 
System.out.println(month);

PreparedStatement ps = null;
ResultSet rs = null;

try {
    String sql =
        "SELECT DATE(saleDate) AS d " +
        "FROM salesRecord " +
        "WHERE saleDate LIKE ? AND domain_type = ? " +
        "GROUP BY DATE(saleDate) " +
        "ORDER BY d";

    ps = conn.prepareStatement(sql);
    ps.setString(1, (month == null ? "" : month) + "%");
    ps.setString(2, domainType);
    rs = ps.executeQuery();
%>
    <ul>
<%
    
while (rs.next()) {
        java.sql.Date d = rs.getDate("d");     // DATE 컬럼
        %>
        	<li class='salesCheck'><%= d.toString()  %></li>
        <%
        
    }
%>
	</ul>
<%
} catch(Exception e){
    out.println("<p style='color:red;'>에러: " + e.getMessage() + "</p>");
} finally {
    if (rs != null) try{rs.close();}catch(Exception ig){}
    if (ps != null) try{ps.close();}catch(Exception ig){}
    if (conn != null) try{conn.close();}catch(Exception ig){}
}
%>
