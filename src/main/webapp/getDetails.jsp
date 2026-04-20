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

String domainType = (session != null) ? (String) session.getAttribute("domainType") : null; if (id == null || dbName == null) {
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
    String sql = "SELECT * FROM testTable  WHERE medicineName = ? AND standard = ? AND domain_type = ?";
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, name);
    pstmt.setString(2, standard);
    pstmt.setString(3, domainType);

    rs = pstmt.executeQuery();

    JSONArray jsonArray = new JSONArray();

    while (rs.next()) {
        JSONObject jsonObject = new JSONObject();
        
        jsonObject.put("medicineName", name);
        jsonObject.put("standard", standard);
        jsonObject.put("price", rs.getString("price"));
        jsonObject.put("inventory", rs.getString("inventory"));
        jsonObject.put("deliveryDate", rs.getString("DeliveryDate"));

        jsonArray.put(jsonObject);
    }
    
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
