<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    String saleDate = request.getParameter("saleDate");
    boolean exists = false; // 데이터 존재 여부를 체크할 변수
    String errorMessage = null; // 오류 메시지 변수

    // DB 연결 정보 설정
    String jdbcDriver = "jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8";
    String dbUser = "root";
    String dbPass = "pharmacy@1234";
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPass);

        String sql = "SELECT COUNT(*) FROM SalesRecord WHERE saleDate = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, saleDate);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            exists = rs.getInt(1) > 0; // 데이터가 존재하는지 확인
        }
    } catch (Exception e) {
        errorMessage = e.getMessage(); // 오류 발생 시 메시지 저장
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // JSON 형식으로 응답
    response.setContentType("application/json; charset=UTF-8");
    String jsonResponse = "{\"exists\": " + exists + ", \"error\": " + (errorMessage != null ? "\"" + errorMessage + "\"" : "null") + "}";
    out.print(jsonResponse);
%>
