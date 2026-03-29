<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, org.json.*, java.util.*, java.math.*" %>
<%@ include file="sessionManager.jsp" %>
<%@ include file="DBconnection.jsp" %>
<%
response.setContentType("application/json; charset=UTF-8");
request.setCharacterEncoding("UTF-8");

String domainType = (session != null) ? (String) session.getAttribute("domainType") : null;

String day = request.getParameter("day");
if (day == null || !day.matches("^\\d{4}-\\d{2}-\\d{2}$")) {
    new JSONObject().put("error","invalid day").write(response.getWriter());
    return;
}
%><%! 
String toNum(String s){
    if (s == null) return "0";
    String t = s.replaceAll("[^0-9.]", "");
    return t.isEmpty() ? "0" : t;
}
%><%
PreparedStatement pstmt = null;
ResultSet rs = null;
JSONArray rows = new JSONArray();

try {
    String sql =
      "SELECT medicineName, Buyingprice, price " +
      "FROM SalesRecord " +
      "WHERE DATE(saleDate) = ? AND domain_type = ? " +
      "ORDER BY saleDate ASC";
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, day);
    pstmt.setString(2, domainType);
    rs = pstmt.executeQuery();

    while (rs.next()) {
        String name = rs.getString("medicineName");
        BigDecimal buy = new BigDecimal(toNum(rs.getString("Buyingprice")));
        BigDecimal unit = new BigDecimal(toNum(rs.getString("price")));
        BigDecimal margin = unit.subtract(buy);
        BigDecimal rate = BigDecimal.ZERO;
        if (unit.compareTo(BigDecimal.ZERO) != 0) {
            rate = margin.multiply(new BigDecimal("100"))
                         .divide(unit, 2, RoundingMode.HALF_UP);
        }

        JSONObject o = new JSONObject();
        o.put("medicineName", name == null ? "" : name);
        o.put("buyingPrice", buy.toPlainString());
        o.put("price", unit.toPlainString());
        o.put("margin", margin.toPlainString());
        o.put("marginRate", rate.toPlainString()); // %
        rows.put(o);
    }

    new JSONObject().put("day", day).put("rows", rows).write(response.getWriter());
} catch (Exception e) {
    new JSONObject().put("error", e.getMessage()).write(response.getWriter());
} finally {
    if (rs != null) try { rs.close(); } catch(Exception ig){}
    if (pstmt != null) try { pstmt.close(); } catch(Exception ig){}
    if (conn != null) try { conn.close(); } catch(Exception ig){}
}
%>
