<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.util.*, javax.servlet.*"%>
<%@ page import="javax.servlet.http.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="org.json.JSONObject"%>
<%
request.setCharacterEncoding("UTF-8");

// DB 연결 설정
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
String serialNumber = request.getParameter("serialNumber");

try {
    // DB 연결
    Class.forName("com.mysql.cj.jdbc.Driver");
    String jdbcDriver = "jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8";
    String dbUser = "root";
    String dbPwd = "pharmacy@1234";

    conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPwd);

    // SQL 쿼리 실행 - inventory 값이 0보다 큰 경우에 한하여 데이터를 가져옴
    String sql = "SELECT * FROM testTable WHERE SerialNumber=? AND inventory > 0 AND returnInv = 0";
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, serialNumber);
    rs = pstmt.executeQuery();

    JSONObject result = new JSONObject();
    if (rs.next()) {
        result.put("SerialNumber", rs.getString("SerialNumber"));
        result.put("medicineName", rs.getString("medicineName"));
        result.put("Buyingprice", rs.getDouble("Buyingprice"));
        result.put("price", rs.getDouble("price"));
        result.put("inventory", 1);
        result.put("kind", rs.getString("kind"));
        result.put("companyName", rs.getString("companyName"));
        result.put("standard", rs.getString("standard"));
        result.put("DeliveryDate", rs.getString("DeliveryDate"));
    } else {
        // 데이터가 없는 경우 빈 JSON 객체 반환
        result.put("error", "No data found for the given SerialNumber or inventory is 0");
    }
    // JSON 형태로 결과 반환
    out.println(result.toString());
} catch (ClassNotFoundException e) {
    e.printStackTrace();
} catch (SQLException e) {
    e.printStackTrace();
} finally {
    // 리소스 정리
    try {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    } catch (SQLException se) {
        se.printStackTrace();
    }
}
%>
