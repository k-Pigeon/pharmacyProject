<%@ page language="java" contentType="application/json; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.util.*, javax.servlet.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="org.json.JSONArray" %>
<%@ page import="org.json.JSONObject" %>

<%
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
        
        // SQL 쿼리 실행
        String sql = "SELECT * FROM testTable WHERE SerialNumber = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, serialNumber);
        rs = pstmt.executeQuery();
        
        JSONObject result = new JSONObject();
        if (rs.next()) {
            result.put("SerialNumber", rs.getString("SerialNumber"));
            result.put("medicineName", rs.getString("medicineName"));
            result.put("price", rs.getDouble("price"));
            result.put("inventory", rs.getInt("inventory"));
            result.put("kind", rs.getString("kind"));
            result.put("companyName", rs.getString("companyName"));
            result.put("standard", rs.getString("standard"));
            result.put("receiptDate", rs.getString("receiptDate"));
            result.put("DeliveryDate", rs.getString("DeliveryDate"));
        } else {
            // 데이터가 없는 경우 빈 JSON 객체 반환
            result.put("error", "No data found for the given SerialNumber");
        }
        // JSON 형태로 결과 반환
        out.println(result.toString());
    } catch (Exception e) {
        // 예외 처리
        e.printStackTrace();
        // JSON 형태로 오류 메시지 반환
        JSONObject errorResult = new JSONObject();
        errorResult.put("error", "An error occurred while processing the request: " + e.getMessage());
        out.println(errorResult.toString());
    } finally {
        // 연결 및 자원 해제
        if (rs != null) try { rs.close(); } catch(Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>