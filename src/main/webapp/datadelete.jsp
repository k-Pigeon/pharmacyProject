<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import = "java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Delete Record</title>
</head>
<body>
<%
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = null;
    PreparedStatement pstmt = null;

    request.setCharacterEncoding("UTF-8");
    String medicineName = request.getParameter("secondData");
    String standard = request.getParameter("eighthData");
    String deliveryDate = request.getParameter("ninthData");
    System.out.printf(medicineName, standard, deliveryDate);

    try {
        String jdbcDriver = "jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8";
        String dbUser = "root";
        String dbPwd = "pharmacy@1234";
        conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPwd);

        // SQL DELETE 쿼리 수정
        String sql = "DELETE FROM testTable WHERE medicineName = ? AND standard = ? AND DeliveryDate = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, medicineName);
        pstmt.setString(2, standard);
        pstmt.setString(3, deliveryDate);

        // 쿼리 실행
        int rowsAffected = pstmt.executeUpdate();
        if (rowsAffected > 0) {
            out.println("약품이 성공적으로 삭제되었습니다."); // 삭제 성공 메시지
        } else {
            out.println("삭제할 약품이 없습니다."); // 삭제 실패 메시지
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("에러가 발생했습니다: " + e.getMessage()); // 에러 메시지 출력
    } finally {
        // 자원 해제
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>
<!-- JSP 스크립트 코드 종료 후 페이지 이동 -->
<jsp:forward page="index.jsp"/>
</body>
</html>
