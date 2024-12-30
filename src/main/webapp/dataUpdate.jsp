<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // 데이터베이스 연결 설정
    String url = "jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8"; // 데이터베이스 URL
    String user = "root"; // 데이터베이스 사용자 이름
    String password = "pharmacy@1234"; // 데이터베이스 비밀번호

    // 요청 파라미터 읽기
    String secondData = request.getParameter("secondData");
    String eighthData = request.getParameter("eighthData");
    String ninthData = request.getParameter("ninthData");

    // DB 쿼리 실행
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver"); // JDBC 드라이버 로드
        conn = DriverManager.getConnection(url, user, password);
        String query = "SELECT * FROM testTable WHERE medicineName = ? AND standard = ? AND DeliveryDate = ?";
        pstmt = conn.prepareStatement(query);
        pstmt.setString(1, secondData);
        pstmt.setString(2, eighthData);
        pstmt.setString(3, ninthData);

        rs = pstmt.executeQuery();

        // 결과를 세션에 저장
        if (rs.next()) {
            HttpSession userSession = request.getSession(); // 변수 이름 변경
            userSession.setAttribute("SerialNumber", rs.getString("SerialNumber"));
            userSession.setAttribute("medicineName", rs.getString("medicineName"));
            userSession.setAttribute("Buyingprice", rs.getString("Buyingprice"));
            userSession.setAttribute("price", rs.getString("price"));
            userSession.setAttribute("inventory", rs.getString("inventory"));
            userSession.setAttribute("kind", rs.getString("kind"));
            userSession.setAttribute("companyName", rs.getString("companyName"));
            userSession.setAttribute("standard", rs.getString("standard"));
            userSession.setAttribute("receiptDate", rs.getString("receiptDate"));
            userSession.setAttribute("DeliveryDate", rs.getString("DeliveryDate"));
            userSession.setAttribute("countNumber", rs.getString("countNumber"));
            userSession.setAttribute("Bookmark", rs.getString("Bookmark"));
            userSession.setAttribute("returnInv", rs.getString("returnInv"));

            // 수정 페이지로 리디렉션
            response.sendRedirect("editPage.jsp"); // 수정 페이지 URL
        } else {
            out.println("No data found.");
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
    } finally {
        // 자원 해제
        if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>
