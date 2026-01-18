<%@ page import="java.sql.*, java.util.*, java.text.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
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

    request.setCharacterEncoding("UTF-8");

    String startDate = request.getParameter("startDate");
    String endDate = request.getParameter("endDate");
	
    System.out.println(startDate + "  " + endDate);
    
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        String sql =
            "SELECT medicineName, price, inventory, companyName, standard, receiptDate, DeliveryDate, returnInv " +
            "FROM testTable " +
            "WHERE STR_TO_DATE(DeliveryDate, '%Y-%m-%d') >= ? " +
            "AND STR_TO_DATE(DeliveryDate, '%Y-%m-%d') <= ? " +
            "AND inventory > 0 " +
            "ORDER BY DeliveryDate ASC";

        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, startDate);
        pstmt.setString(2, endDate);

        rs = pstmt.executeQuery();

        while (rs.next()) {
%>
<tr>
    <td><button class="toggle-details custom-btn btn-13">▼</button></td>
    <td>
        <button type="button" class="updateInfo">수정</button>
        <button class="deleteInfo">삭제</button>
    </td>
    <td><%= rs.getString("medicineName") %></td>
    <td><%= rs.getString("DeliveryDate") %></td>
    <td><%= rs.getString("inventory") %></td>
    <td><%= rs.getString("standard") %></td>
    <td><%= rs.getString("price") %></td>
    <td><%= rs.getString("companyName") %></td>
    <td><%= rs.getString("receiptDate") %></td>
    <td>
        <input type="button" value="<%= rs.getInt("returnInv") == 1 ? "반품됨" : "반품하기" %>" class="returnProduct">
    </td>
</tr>
<%
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        response.getWriter().write("Server error: " + e.getMessage());
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
    }
%>
<%@ include file="DBclose.jsp" %>