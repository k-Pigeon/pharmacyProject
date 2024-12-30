<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.sql.*" %>
<%@ page import="javax.servlet.*, javax.servlet.http.*" %>
<%@ page import="org.json.*" %>

<%
request.setCharacterEncoding("UTF-8");

String medicineName = request.getParameter("medicineName");

// DB 연결 정보
String jdbcUrl = "jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8&serverTimezone=UTC";
String dbUser = "root";
String dbPwd = "pharmacy@1234";

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

JSONObject resultJson = new JSONObject();

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPwd);

    String sql = " SELECT medicineName, Buyingprice, price, kind, standard "
               + " FROM testTable WHERE medicineName = ? ";
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, medicineName);
    rs = pstmt.executeQuery();

    if (rs.next()) {
        JSONObject rowData = new JSONObject();
        rowData.put("SerialNumber", "한약세트");
        rowData.put("medicineName", rs.getString("medicineName"));
        rowData.put("Buyingprice", rs.getDouble("Buyingprice"));
        rowData.put("price", rs.getDouble("price"));
        rowData.put("inventory", 1);
        rowData.put("kind", rs.getString("kind")); // 예제에서는 inventory 필드를 가져와서 사용
        rowData.put("standard", rs.getString("standard"));
        
        resultJson.put("data", rowData);
    } else {
        resultJson.put("error", "No data found for the given medicineName or inventory is 0");
    }

} catch (ClassNotFoundException e) {
    e.printStackTrace();
    resultJson.put("error", "ClassNotFoundException: " + e.getMessage());
} catch (SQLException e) {
    e.printStackTrace();
    resultJson.put("error", "SQLException: " + e.getMessage());
} finally {
    // 리소스 정리
    try {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    } catch (SQLException se) {
        se.printStackTrace();
        resultJson.put("error", "SQLException in finally: " + se.getMessage());
    }
}

// JSON 문자열로 변환하여 출력
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");
response.getWriter().write(resultJson.toString());
%>
