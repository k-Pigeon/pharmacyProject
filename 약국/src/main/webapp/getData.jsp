<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, java.util.*, java.util.regex.*" %>
<%@ include file="sessionManager.jsp"%>
<%@ include file="DBconnection.jsp"%>
<%
String dbName = (session != null) ? (String) session.getAttribute("dbName") : null;
String id = (session != null) ? (String) session.getAttribute("id") : null;
String password = (session != null) ? (String) session.getAttribute("password") : null;

String idSortation = (session != null) ? (String) session.getAttribute("idSortation") : null; if (id == null || dbName == null) {
    response.sendRedirect("login.jsp");
    return;
}

jdbcDriver = dbName;
%>
<%
request.setCharacterEncoding("UTF-8");
String nameSearch = request.getParameter("nameSearch");
PreparedStatement pstmt = null;
ResultSet rs = null;

if (nameSearch != null && !nameSearch.trim().isEmpty()) {


    try {
        String sql = "SELECT medicineName, price, quantity, inventory, companyName, standard, receiptDate, DeliveryDate, returnInv "
                   + "FROM testTable"  + idSortation + "  WHERE medicineName LIKE ? ORDER BY medicineName ASC";

        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, "%" + nameSearch + "%");

        rs = pstmt.executeQuery();

        while (rs.next()) {
%>
            <tr>
                <td><input type="checkbox" class="isOrdered"></td>
                <td>
                    <button type="button" class="updateInfo">수정</button>
                    <button class="deleteInfo">삭제</button>
                </td>
                <td><%= rs.getString("medicineName") %></td>
                <td><%= rs.getString("DeliveryDate") %></td>
                <td><%= rs.getString("quantity") %></td>
                <td><%= rs.getString("inventory") %></td>
                <td><%= rs.getString("standard") %></td>
                <td><%= rs.getString("price") %></td>
                <td><%= rs.getString("companyName") %></td>
                <td><%= rs.getString("receiptDate") %></td>
                <td>
                    <input type="button" value="<%= rs.getInt("returnInv") == 1 ? "반품됨" : "반품하기" %>">
                </td>
            </tr>
<%
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
        try { if (rs != null) rs.close(); } catch (Exception ignored) {}
    }
}
%>
<%@ include file="DBclose.jsp" %>