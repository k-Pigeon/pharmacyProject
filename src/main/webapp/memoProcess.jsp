<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.text.*"%>
<%
    request.setCharacterEncoding("UTF-8");

    String memoNotice = request.getParameter("memoNotice");
    String dateVal = request.getParameter("dateVal");

    System.out.printf("Memo: %s, Date: %s\n", memoNotice, dateVal);
    
    String jdbcDriver = "jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8";
    String dbUser = "root"; // DB 사용자명
    String dbPass = "pharmacy@1234"; // DB 비밀번호
    Connection conn = null;
    PreparedStatement pstmt = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPass);
        
        String sql = "UPDATE SalesRecord SET memoInfo = ? WHERE saleDate = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, memoNotice);
        pstmt.setString(2, dateVal);
        
        int rowsUpdated = pstmt.executeUpdate();
        System.out.println("Rows updated: " + rowsUpdated);
        
    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
