<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, org.json.*, java.util.*" %>
<%@ include file="sessionManager.jsp" %>
<%@ include file="DBconnection.jsp" %>
<%
response.setContentType("application/json; charset=UTF-8");
request.setCharacterEncoding("UTF-8");

String domainType = (session != null) ? (String) session.getAttribute("domainType") : null;

PreparedStatement pstmt = null;
ResultSet rs = null;
JSONArray array = new JSONArray();

try {
    String sql =
      "SELECT DATE(saleDate) AS d, COUNT(*) AS cnt " +
      "FROM SalesRecord where domain_type = ? " +
      "GROUP BY DATE(saleDate) " +
      "ORDER BY d DESC " +
      "LIMIT 180";  // 최근 6개월 정도

    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, domainType);
    rs = pstmt.executeQuery();
    while (rs.next()) {
        JSONObject o = new JSONObject();
        o.put("day", rs.getString("d"));  // YYYY-MM-DD
        o.put("count", rs.getInt("cnt"));
        array.put(o);
    }
    array.write(response.getWriter());
} catch (Exception e) {
    new JSONObject().put("error", e.getMessage()).write(response.getWriter());
} finally {
    if (rs != null) try { rs.close(); } catch(Exception ig){}
    if (pstmt != null) try { pstmt.close(); } catch(Exception ig){}
    if (conn != null) try { conn.close(); } catch(Exception ig){}
}
%>
