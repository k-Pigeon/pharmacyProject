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

String idSortation = (session != null) ? (String) session.getAttribute("idSortation") : null; if (id == null || dbName == null) {
	response.sendRedirect("login.jsp");
	return;
}

jdbcDriver = dbName;
request.setCharacterEncoding("UTF-8");

String startDate = request.getParameter("startDate");
String endDate = request.getParameter("endDate");

PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    String sql = "SELECT A.saleDate FROM SalesRecord"  + idSortation + "  A " +
                 "JOIN priceRecord"  + idSortation + "  B ON A.saleDate = B.saleDate " +
                 "WHERE A.saleDate BETWEEN ? AND ? " +
                 "GROUP BY A.saleDate ORDER BY A.saleDate DESC";

    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, startDate + " 00:00:00");
    pstmt.setString(2, endDate + " 23:59:59");
    rs = pstmt.executeQuery();

    while (rs.next()) {
        String saleDate = rs.getString("saleDate");
%>
    <tr data-date="<%= saleDate %>">
        <td><%= saleDate %></td>
        <td>
            <button class="updateBtn custom-btn btn-16">수정</button>
            <button class="deleteBtn custom-btn btn-16">삭제</button>
        </td>
    </tr>
<%
    }

} catch (Exception e) {
    e.printStackTrace();
    out.println("<tr><td colspan='2'>오류 발생: " + e.getMessage() + "</td></tr>");
} finally {
    try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
    try { if (rs != null) rs.close(); } catch (Exception ignored) {}
}
%>
<%@ include file="DBclose.jsp" %>