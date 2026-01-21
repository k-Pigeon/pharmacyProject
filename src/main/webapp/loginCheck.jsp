<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>
<%
    String userId = request.getParameter("userId");
    String password = request.getParameter("password");

    // 데이터베이스 연결 정보
    String jdbcDriver = "jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8";
    String dbUser = "root";
    String dbPwd = "pharmacy@1234";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    String sql = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPwd);
        
        sql = "SELECT * FROM users WHERE userId = ? AND password = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userId);
        pstmt.setString(2, password);
        
        rs = pstmt.executeQuery();
        
        if (rs.next()) {
            // 로그인 성공
            session.setAttribute("userId", userId); // 내장된 session 객체 사용
            response.sendRedirect("index.jsp");  // index.jsp로 이동
        } else {
            // 로그인 실패
            out.println("<script>alert('아이디 또는 비밀번호가 잘못되었습니다.'); location.href='login.jsp';</script>");
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>
