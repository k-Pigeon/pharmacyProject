<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    String medicineName = request.getParameter("medicineName");
    String DeliveryDate = request.getParameter("DeliveryDate");
    String standard = request.getParameter("standard");
    String returnText = request.getParameter("returnText");
    
    // DB 연결 정보
    String jdbcDriver = "jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8";
    String dbUser = "root";
    String dbPwd = "pharmacy@1234";

    Connection conn = null;
    PreparedStatement pstmt = null;
    
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPwd);

        String sql = "";

        if("반품됨".equals(returnText)) {
            sql = "UPDATE testTable SET returnInv = '0' WHERE medicineName = ? AND DeliveryDate = ? AND standard = ? ";
        } else if("반품하기".equals(returnText)) {
            sql = "UPDATE testTable SET returnInv = '1' WHERE medicineName = ? AND DeliveryDate = ? AND standard = ? ";
        }
        
        if (!sql.isEmpty()) {
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, medicineName);
            pstmt.setString(2, DeliveryDate);
            pstmt.setString(3, standard);
            pstmt.executeUpdate();
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
<!-- 여기에 필요한 HTML 내용을 추가 -->
</body>
</html>
