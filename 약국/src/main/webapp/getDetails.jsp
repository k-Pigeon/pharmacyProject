<%@ page import="java.sql.*, org.json.*" %>
<%@ include file="sessionManager.jsp"%>
<%@ include file="DBconnection.jsp"%>
<%
String dbName = (session != null) ? (String) session.getAttribute("dbName") : null;
String id = (session != null) ? (String) session.getAttribute("id") : null;
String password = (session != null) ? (String) session.getAttribute("password") : null;

/* out.println(password);
out.println(dbName);
out.println(id);
out.println(password); */

String idSortation = (session != null) ? (String) session.getAttribute("idSortation") : null; if (id == null || dbName == null) {
    response.sendRedirect("login.jsp");
    return;
}

jdbcDriver = dbName;
%>
<%
String name = request.getParameter("name");
String standard = request.getParameter("standard");

PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPwd);
    String sql = "SELECT * FROM testTable"  + idSortation + "  WHERE medicineName = ? AND standard = ?";
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
}
%>
<%@ include file="DBclose.jsp" %>