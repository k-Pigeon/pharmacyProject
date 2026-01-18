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

if (id == null || dbName == null) {
    response.sendRedirect("login.jsp");
    return;
}

jdbcDriver = dbName;
%>
<%
    request.setCharacterEncoding("UTF-8");

    String memoNotice = request.getParameter("memoNotice");
    String clientName = request.getParameter("clientName");
    String clientNuber = request.getParameter("clientNuber");
    String dateVal = request.getParameter("dateVal");

    PreparedStatement pstmt = null;
    
    try {        
        String sql = " UPDATE clientRecord SET memoInfo = ? "
        		   + " WHERE clientName = ? AND clientNumber = ? ";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, memoNotice);
        pstmt.setString(2, clientName);
        pstmt.setString(3, clientNuber);
        
        int rowsUpdated = pstmt.executeUpdate();
        System.out.println("Rows updated: " + rowsUpdated);
        
    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
