<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
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

String idSortation = (session != null) ? (String) session.getAttribute("idSortation") : null; if (id == null || dbName == null) {
    response.sendRedirect("login.jsp");
    return;
}

jdbcDriver = dbName;
%>
<%
    String saleDate = request.getParameter("saleDate");
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        String sql = "SELECT * FROM SalesRecord"  + idSortation + "  WHERE saleDate = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, saleDate);
        rs = pstmt.executeQuery();

        if (rs.next()) {
%>
<div>
    <p>일자/시간: <%= rs.getString("saleDate") %></p>
    <p>제품이름: <%= rs.getString("medicineName") %></p>
    <p>개수: <%= rs.getString("inventory") %></p>
    <!-- 추가적인 데이터 표시 -->
</div>
<%
        } else {
%>
<div>
    <p>데이터를 찾을 수 없습니다.</p>
</div>
<%
        }
    } catch (SQLException se) {
        se.printStackTrace();
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
    }
%>
<%@ include file="DBclose.jsp" %>