<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%
    String medicineName = request.getParameter("medicineName");
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        // 데이터베이스 연결 설정
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/tutorial2?useUnicode=true&characterEncoding=utf8", "root", "pharmacy@1234");

        // SQL 실행
        String sql = "SELECT * FROM testTable WHERE medicineName LIKE ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, "%" + medicineName + "%");
        rs = pstmt.executeQuery();

        // 테이블 행 반환
        while (rs.next()) {
            out.println("<tr class='result-row' style='cursor: pointer;'"
                    + " data-medicinename='" + rs.getString("medicineName") + "'"
                    + " data-companyname='" + rs.getString("companyName") + "'"
	                + " data-wholesaler='" + rs.getString("wholesaler") + "'"
                    + " data-standard='" + rs.getString("standard") + "'"
                    + " data-inventory='" + rs.getString("inventory") + "'"
                    + " data-serialnumber='" + rs.getString("serialNumber") + "'"
                    + " data-receiptdate='" + rs.getString("receiptDate") + "'"
                    + " data-deliverydate='" + rs.getString("deliveryDate") + "'"
                    + " data-buyingprice='" + rs.getString("buyingPrice") + "'"
                    + " data-price='" + rs.getString("price") + "'>"
                    + "<td style='border: 1px solid #ccc; padding: 5px;'>" + rs.getString("medicineName") + "</td>"
                    + "<td style='border: 1px solid #ccc; padding: 5px;'>" + rs.getString("companyName") + "</td>"
                    + "<td style='border: 1px solid #ccc; padding: 5px;'>" + rs.getString("inventory") + "</td>"
                    + "<td style='border: 1px solid #ccc; padding: 5px;'>" + rs.getString("serialNumber") + "</td>"
                    + "<td style='border: 1px solid #ccc; padding: 5px;'>" + rs.getString("receiptDate") + "</td>"
                    + "<td style='border: 1px solid #ccc; padding: 5px;'>" + rs.getString("deliveryDate") + "</td>"
                    + "</tr>");
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>