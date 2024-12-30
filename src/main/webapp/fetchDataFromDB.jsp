<%@ page language="java" contentType="application/json; charset=UTF-8" %>
<%@ page import="java.sql.*" %>

<%
// 받은 SerialNumber
String serialNumber = request.getParameter("serialNumber");

// DB 연결 정보
String jdbcDriver = "jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8";
String dbUser = "root";
String dbPwd = "pharmacy@1234";

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    // DB 연결
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPwd);

    // SQL 실행
    // SQL 실행
String sql = "SELECT * FROM testTable WHERE SerialNumber = ?";
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, serialNumber);
    rs = pstmt.executeQuery();

    // 결과를 JSON 형식으로 변환하여 출력
    if (rs.next()) {
        // JSON 형식으로 데이터 생성
        String jsonData = "{\"SerialNumber\":\"" + rs.getString("SerialNumber") + "\","
                        + "\"medicineName\":\"" + rs.getString("medicineName") + "\","
                        + "\"Buyingprice\":\"" + rs.getString("Buyingprice") + "\","
                        + "\"price\":\"" + rs.getString("price") + "\","
                        + "\"inventory\":\"" + rs.getString("inventory") + "\","
                        + "\"kind\":\"" + rs.getString("kind") + "\","
                        + "\"companyName\":\"" + rs.getString("companyName") + "\","
                        + "\"standard\":\"" + rs.getString("standard") + "\","
                        + "\"receiptDate\":\"" + rs.getString("receiptDate") + "\","
                        + "\"DeliveryDate\":\"" + rs.getString("DeliveryDate") + "\","
                        + "\"countNumber\":\"" + rs.getString("countNumber") + "\","
                        + "\"Bookmark\":\"" + rs.getString("Bookmark") + "\"}";

        // JSON 형식으로 출력
        out.println(jsonData);
    } else {
        // 해당 SerialNumber에 대한 데이터가 없을 때
        out.println("{\"error\":\"No data found for SerialNumber " + serialNumber + "\"}");
    }
} catch (SQLException se) {
    se.printStackTrace();
    out.println("{\"error\":\"Database error occurred\"}");
} catch (ClassNotFoundException e) {
    e.printStackTrace();
    out.println("{\"error\":\"Database driver error occurred\"}");
} finally {
    // 리소스 해제
    try {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    } catch (SQLException se) {
        se.printStackTrace();
    }
}
%>
