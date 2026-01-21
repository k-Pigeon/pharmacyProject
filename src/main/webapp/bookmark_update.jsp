<%@page import="com.mysql.cj.x.protobuf.MysqlxPrepare.Prepare"%>
<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.util.*, javax.servlet.*"%>
<%@ page import="javax.servlet.http.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="org.json.JSONObject"%>
<%
    // DB 연결 설정
    Connection conn = null;
    PreparedStatement pstmt = null;
    PreparedStatement chPstmt = null;
    PreparedStatement ch2Pstmt = null;
    ResultSet rs = null;
    ResultSet chRS = null;
    
    String medicineName = request.getParameter("medicineName");
    String DeliveryDate = request.getParameter("DeliveryDate");
    String placeClassification = request.getParameter("placeClassification");
    String buttonText = request.getParameter("buttonText");
    
    System.out.printf(medicineName + " , " + DeliveryDate);
    
    JSONObject jsonResponse = new JSONObject(); // JSON 객체 생성
    
    try {
        // DB 연결
        Class.forName("com.mysql.cj.jdbc.Driver");
        String jdbcDriver = "jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8";
        String dbUser = "root";
        String dbPwd = "pharmacy@1234";
        
        conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPwd);
        
        // 쿼리 작성
        String sql = "SELECT Bookmark FROM testTable "
                   + "WHERE medicineName = ? AND DeliveryDate = ? AND placeClassification = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, medicineName);
        pstmt.setString(2, DeliveryDate);
        pstmt.setString(3, placeClassification);
        rs = pstmt.executeQuery();
        
        String bookmark = ""; // 초기화
        
        if(rs.next()) {
            bookmark = rs.getString("Bookmark"); // Bookmark 값 가져오기
            
            //0일 경우 1로 바꾸어 즐겨찾기에 추가
            if("0".equals(bookmark)){ // 문자열 비교 수정
                String chSQL = " UPDATE testTable SET Bookmark = '1' "
                             + " WHERE medicineName = ? AND DeliveryDate = ?";
                chPstmt = conn.prepareStatement(chSQL);
                chPstmt.setString(1, medicineName);
                chPstmt.setString(2, DeliveryDate);
                chPstmt.executeUpdate(); // executeUpdate로 변경
            }
            //1일 경우 0으로 바꾸어 즐겨찾기에서 제거
            if("1".equals(bookmark)){ // 문자열 비교 수정
                String chSQL = " UPDATE testTable SET Bookmark = '0' "
                             + " WHERE medicineName = ? AND DeliveryDate = ?";
                ch2Pstmt = conn.prepareStatement(chSQL);
                ch2Pstmt.setString(1, medicineName);
                ch2Pstmt.setString(2, DeliveryDate);
                ch2Pstmt.executeUpdate(); // executeUpdate로 변경
            }
        }
        
        // 클라이언트로 JSON 응답 생성
        jsonResponse.put("bookmarkStatus", bookmark); // JSON 객체에 Bookmark 상태 추가
        
        // 응답 전송
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(jsonResponse.toString());
        
    } catch(Exception e) {
        e.printStackTrace();
    } finally {
        // 리소스 해제
        if(rs != null) {
            try { rs.close(); } catch(SQLException e) { e.printStackTrace(); }
        }
        if(pstmt != null) {
            try { pstmt.close(); } catch(SQLException e) { e.printStackTrace(); }
        }
        if(chPstmt != null) { // 변경된 PreparedStatement를 추가로 닫아야 함
            try { chPstmt.close(); } catch(SQLException e) { e.printStackTrace(); }
        }
        if(conn != null) {
            try { conn.close(); } catch(SQLException e) { e.printStackTrace(); }
        }
    }

%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<link rel="styleshee" href="style.css">
</head>
<body>
	<jsp:forward page="bookmark_list.jsp"></jsp:forward>
</body>
</html>