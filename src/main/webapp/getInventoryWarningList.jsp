<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ include file="sessionManager.jsp"%>
<%@ include file="DBconnection.jsp"%>

<%
response.setContentType("application/json; charset=UTF-8");
out.clear();

String domainType = (session != null) ? (String) session.getAttribute("domainType") : null;

boolean found = false;
StringBuilder html = new StringBuilder();

PreparedStatement ps = null;
ResultSet rs = null;

try {

    String sql =
        "SELECT " +
        "medicineName, " +
        "MAX(DeliveryDate) AS DeliveryDate, " +
        "SUM(inventory) AS totalInv, " +
        "MAX(quantity) AS quantity, " +
        "MAX(price) AS price, " +
        "MAX(standard) AS standard, " +
        "MAX(kind) AS kind, " +
        "MAX(companyName) AS companyName, " +
        "MAX(receiptDate) AS receiptDate " +
        "FROM testTable " +
        "WHERE returnInv='0' AND domain_type = ? " +
        "GROUP BY medicineName " +
        "HAVING SUM(inventory) <= MIN(quantity) " +
        "ORDER BY medicineName ASC";

    ps = conn.prepareStatement(sql);
    ps.setString(1, domainType);
    rs = ps.executeQuery();

    while (rs.next()) {

        found = true;

        html.append("<tr>");
        html.append("<td>").append(rs.getString("medicineName")).append("</td>");
        html.append("<td>").append(rs.getString("DeliveryDate")).append("</td>");
        html.append("<td>").append(rs.getDouble("totalInv")).append("</td>");
        html.append("<td>").append(rs.getString("price")).append("</td>");
        html.append("<td>").append(rs.getString("standard")).append("</td>");
        html.append("<td>").append(rs.getString("kind")).append("</td>");
        html.append("<td>").append(rs.getString("companyName")).append("</td>");
        html.append("<td>").append(rs.getString("receiptDate")).append("</td>");
        html.append("<td>").append(rs.getDouble("quantity")).append("</td>");
        html.append("</tr>");
    }

} catch (Exception e) {
    out.print("{\"error\":\"" + e.getMessage().replace("\"","\\\"") + "\"}");
} finally {
    try { if (rs != null) rs.close(); } catch (Exception ignore) {}
    try { if (ps != null) ps.close(); } catch (Exception ignore) {}
    try { if (conn != null) conn.close(); } catch (Exception ignore) {}
}

String json = "{\"found\": " + found + ", \"html\": \"" +
              html.toString().replace("\"","\\\"") + "\"}";

out.print(json);
%>

