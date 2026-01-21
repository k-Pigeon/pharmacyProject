<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String startDate = request.getParameter("startDate");
    String endDate = request.getParameter("endDate");
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    response.setContentType("text/html;charset=UTF-8");

    try {
        String jdbcDriver = "jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8";
        String dbUser = "root";
        String dbPwd = "pharmacy@1234";
        conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPwd);

        String sql = "SELECT DISTINCT A.saleDate AS saleDate, "
                   + "B.maxmedicinePrice AS maxmedicinePrice, B.generalPrice AS generalPrice, "
                   + "(B.maxmedicinePrice + B.generalPrice) AS totalPrice "
                   + "FROM SalesRecord A "
                   + "JOIN priceRecord B ON A.saleDate = B.saleDate "
                   + "WHERE A.saleDate BETWEEN ? AND ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, startDate);
        pstmt.setString(2, endDate);
        rs = pstmt.executeQuery();
        while (rs.next()) {
%>
        <tr data-sale-date="<%= rs.getString("saleDate") %>">
            <td><%= rs.getString("saleDate") %></td>
            <td><%= rs.getString("maxmedicinePrice") %></td>
            <td><%= rs.getString("generalPrice") %></td>
            <td><%= rs.getString("totalPrice") %></td>
        </tr>
<%
        }
    } catch (SQLException se) {
        se.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>
