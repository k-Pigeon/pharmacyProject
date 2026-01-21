<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.util.*, javax.servlet.*"%>
<%@ page import="javax.servlet.http.*"%>
<%@ page import="java.sql.*"%>
<%
    request.setCharacterEncoding("UTF-8");
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");

    // DB 연결 설정
    Connection conn = null;
    PreparedStatement pstmt = null;

    String medicineNameSet = request.getParameter("medicineNameSet");
    String Buyingprice = request.getParameter("Buyingprice");
    String price = request.getParameter("price");
    String standard = request.getParameter("standard");
    String resource1 = request.getParameter("resource1");
    String resource2 = request.getParameter("resource2");
    String resource3 = request.getParameter("resource3");
    String resource4 = request.getParameter("resource4");
    String resource5 = request.getParameter("resource5");

    try {
        // DB 연결
        Class.forName("com.mysql.cj.jdbc.Driver");
        String jdbcDriver = "jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8";
        String dbUser = "root";
        String dbPwd = "pharmacy@1234";

        conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPwd);

        String insertSQL = "INSERT INTO vitalSet (medicineName,  price, Buyingprice, resource1, resource2, resource3, resource4, resource5) " 
				 		 + " VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        pstmt = conn.prepareStatement(insertSQL);
        pstmt.setString(1, medicineNameSet);
        pstmt.setString(2, price);
        pstmt.setString(3, Buyingprice);
        pstmt.setString(4, resource1);
        pstmt.setString(5, resource2);
        pstmt.setString(6, resource3);
        pstmt.setString(7, resource4);
        pstmt.setString(8, resource5);

        int rowCount = pstmt.executeUpdate();

        if (rowCount > 0) {
            out.write("{\"success\": true}");
        } else {
            out.write("{\"success\": false}");
        }

    } catch (ClassNotFoundException e) {
        e.printStackTrace();
        out.write("{\"error\": \"ClassNotFoundException: " + e.getMessage() + "\"}");
    } catch (SQLException e) {
        e.printStackTrace();
        out.write("{\"error\": \"SQLException: " + e.getMessage() + "\"}");
    } finally {
        // 리소스 정리
        try {
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException se) {
            se.printStackTrace();
            out.write("{\"error\": \"SQLException in finally: " + se.getMessage() + "\"}");
        }
    }
%>
