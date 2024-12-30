<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // 데이터베이스 연결 설정
    String url = "jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8"; // 데이터베이스 URL
    String user = "root"; // 데이터베이스 사용자 이름
    String password = "pharmacy@1234"; // 데이터베이스 비밀번호

    // DB 업데이트 쿼리 실행
    try {
        Class.forName("com.mysql.cj.jdbc.Driver"); // JDBC 드라이버 로드
        Connection conn = DriverManager.getConnection(url, user, password);
        
        // 필요한 경우 추가적인 업데이트할 값들을 여기에서 받아올 수 있습니다.
        // 예: String newPrice = request.getParameter("newPrice");
        
        String query = "UPDATE testTable SET medicineName = ?, " +
                       "Buyingprice = ?, price = ?, inventory = ?, kind = ?, companyName = ?, standard = ?, receiptDate = ?, deliveryDate = ? " +
                       "WHERE medicineName = ? AND standard = ? AND deliveryDate = ?";
        
        PreparedStatement pstmt = conn.prepareStatement(query);
        
        // 추가적인 업데이트할 값들을 여기에서 가져와야 합니다.
        // 예시: 새로운 가격과 같은 값을 가져오세요.
        String medicineName = request.getParameter("medicineName");
        String buyingPrice = request.getParameter("buyingPrice");
        String price = request.getParameter("price");
        String inventory = request.getParameter("inventory");
        String kind = request.getParameter("kind");
        String companyName = request.getParameter("companyName");
        String standard = request.getParameter("standard");
        String receiptDate = request.getParameter("receiptDate");
        String deliveryDate = request.getParameter("deliveryDate");
        
        String tipMedicineName = request.getParameter("tipMedicineName");
        String tipstandard = request.getParameter("tipstandard");
        String tipDeliveryDate = request.getParameter("tipDeliveryDate");

        pstmt.setString(1, medicineName);
        pstmt.setString(2, buyingPrice);
        pstmt.setString(3, price);
        pstmt.setString(4, inventory);
        pstmt.setString(5, kind);
        pstmt.setString(6, companyName);
        pstmt.setString(7, standard);
        pstmt.setString(8, receiptDate);
        pstmt.setString(9, deliveryDate);
        pstmt.setString(10, tipMedicineName); // WHERE 조건
        pstmt.setString(11, tipstandard); // WHERE 조건
        pstmt.setString(12, tipDeliveryDate); // WHERE 조건

        int rowsAffected = pstmt.executeUpdate(); // 업데이트 실행
        if (rowsAffected > 0) {
            out.println("데이터가 성공적으로 업데이트되었습니다.");
        } else {
            out.println("업데이트할 데이터가 없습니다.");
        }

        // 자원 해제
        pstmt.close();
        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        out.println("데이터베이스 오류 발생: " + e.getMessage());
    }
%>
