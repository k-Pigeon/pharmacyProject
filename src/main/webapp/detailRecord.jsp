<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%
    String saleDate = request.getParameter("saleDate");
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        String jdbcDriver = "jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8";
        String dbUser = "root";
        String dbPwd = "pharmacy@1234";
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPwd);

        String sql = "SELECT * FROM SalesRecord WHERE saleDate = ?";
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
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>
