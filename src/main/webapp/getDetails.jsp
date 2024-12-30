<%@ page import="java.sql.*, org.json.*" %>
<%
String name = request.getParameter("name");
String standard = request.getParameter("standard");

Class.forName("com.mysql.cj.jdbc.Driver");
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    String jdbcDriver = "jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8";
    String dbUser = "root";
    String dbPwd = "pharmacy@1234";

    conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPwd);
    String sql = "SELECT * FROM testTable WHERE medicineName = ? AND standard = ?";
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, name);
    pstmt.setString(2, standard);

    rs = pstmt.executeQuery();

    // JSON 배열 생성
    JSONArray jsonArray = new JSONArray();

    // 결과가 있을 때만 JSON 객체에 추가
    while (rs.next()) {
        JSONObject jsonObject = new JSONObject();
        
        // 필요한 추가 데이터를 가져옵니다. 
        jsonObject.put("medicineName", name);
        jsonObject.put("standard", standard);
        jsonObject.put("price", rs.getString("price"));
        jsonObject.put("inventory", rs.getString("inventory"));
        jsonObject.put("deliveryDate", rs.getString("DeliveryDate"));
        // 추가로 보여주고 싶은 컬럼을 여기에 추가합니다.

        jsonArray.put(jsonObject);
    }

    // JSON 배열을 클라이언트로 반환
    response.setContentType("application/json; charset=UTF-8");
    response.getWriter().write(jsonArray.toString());
    
} catch (SQLException se) {
    se.printStackTrace();
} finally {
    if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
    if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
}
%>
