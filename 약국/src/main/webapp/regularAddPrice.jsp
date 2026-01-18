<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.util.*"%>
<%@ page import="javax.servlet.*, javax.servlet.http.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.math.BigDecimal"%>
<%@ page import="org.json.JSONObject"%>
<%@ include file="sessionManager.jsp"%>
<%@ include file="DBconnection.jsp"%>
<%
response.setContentType("application/json; charset=UTF-8");

String dbName = (session != null) ? (String) session.getAttribute("dbName") : null;
String id = (session != null) ? (String) session.getAttribute("id") : null;
String idSortation = (session != null) ? (String) session.getAttribute("idSortation") : null;

if (id == null || dbName == null) {
    response.sendRedirect("login.jsp");
    return;
}

request.setCharacterEncoding("UTF-8");

PreparedStatement pstmt = null;
ResultSet rs = null;
%>
<%!
// 헬퍼: 쉼표 제거하고 숫자로 변환
String stripNum(String s) {
    if (s == null) return null;
    return s.replaceAll(",", "");
}

BigDecimal toBigDecimal(String s) {
    try {
        String v = stripNum(s);
        if (v == null || v.isEmpty()) return null;
        return new BigDecimal(v);
    } catch (Exception e) {
        return null;
    }
}
%>
<%
try {
    String clickName = request.getParameter("clickName");

    String sql = "SELECT setName, Buyingprice, price FROM regularSet WHERE setName = ?";
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, clickName);
    rs = pstmt.executeQuery();

    JSONObject result = new JSONObject();

    if (rs.next()) {
        String setName = rs.getString("setName");

        // 문자열로 먼저 읽어온 뒤 쉼표 제거 → BigDecimal 변환
        String buyingRaw = rs.getString("Buyingprice");  // VARCHAR일 수 있음
        String priceRaw = rs.getString("price");        // VARCHAR일 수 있음

        BigDecimal buyingPrice = toBigDecimal(buyingRaw);
        BigDecimal price = toBigDecimal(priceRaw);

        // 숫자 변환 실패 시 0으로 대체(원하면 null로도 보낼 수 있음)
        if (buyingPrice == null) buyingPrice = BigDecimal.ZERO;
        if (price == null) price = BigDecimal.ZERO;

        result.put("medicineName", setName);
        // JSON 숫자로 넣고 싶으면 BigDecimal 그대로 put 가능
        result.put("Buyingprice", buyingPrice);
        result.put("price", price);
        result.put("inventory", 1); // 기본 수량 1
    } else {
        result.put("error", "No data found for the given medicineName");
    }

    out.println(result.toString());

} catch (SQLException e) {
    e.printStackTrace();
    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
    out.println("{\"error\":\"Database error occurred: " + e.getMessage() + "\"}");
} finally {
    try { if (rs != null) rs.close(); } catch (SQLException se) { se.printStackTrace(); }
    try { if (pstmt != null) pstmt.close(); } catch (SQLException se) { se.printStackTrace(); }
}
%>
<%@ include file="DBclose.jsp" %>
