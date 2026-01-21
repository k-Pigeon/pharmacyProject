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

    String medicineName = request.getParameter("medicineName");
    String medicineNameSet = request.getParameter("medicineNameSet");
    String Buyingprice = request.getParameter("Buyingprice");
    String price = request.getParameter("price");
    String standard = request.getParameter("standard");

    try {
        // DB 연결
        Class.forName("com.mysql.cj.jdbc.Driver");
        String jdbcDriver = "jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8";
        String dbUser = "root";
        String dbPwd = "pharmacy@1234";

        conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPwd);

        String insertSQL = "INSERT INTO testTable (SerialNumber, medicineName, Buyingprice, price, inventory, kind, companyName, standard, receiptDate, DeliveryDate, countNumber, Bookmark, returnInv) " 
				 		 + " VALUES ('', ?, ?, ?, '', '한약류', '', ?, '', '', '', '', '0')";
        pstmt = conn.prepareStatement(insertSQL);
        pstmt.setString(1, medicineNameSet);
        pstmt.setString(2, Buyingprice);
        pstmt.setString(3, price);
        pstmt.setString(4, standard);

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
