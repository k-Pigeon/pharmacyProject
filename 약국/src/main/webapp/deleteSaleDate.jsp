<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.regex.*" %>
<%@ include file="sessionManager.jsp"%>
<%@ include file="DBconnection.jsp"%>
<%
response.setContentType("application/json; charset=UTF-8");

String dbName = (session != null) ? (String) session.getAttribute("dbName") : null;
String id = (session != null) ? (String) session.getAttribute("id") : null;
String idSortation = (session != null) ? (String) session.getAttribute("idSortation") : null;

if (id == null || dbName == null) { response.sendRedirect("login.jsp"); return; }
jdbcDriver = dbName;

request.setCharacterEncoding("UTF-8");
String saleDate = request.getParameter("saleDate");

PreparedStatement psSelect = null, psUpdate = null, psDelSales = null, psDelClient = null;
ResultSet rs = null;
int updated = 0, deletedSales = 0, deletedClient = 0;

try {
    conn.setAutoCommit(false);

    // 1) SalesRecord × testTable JOIN으로 standard까지 가져오기
    String selectSql =
        "SELECT s.medicineName, s.SerialNumber, s.DeliveryDate, s.inventory, t.standard " +
        "FROM SalesRecord" + idSortation + " s " +
        "JOIN testTable"   + idSortation + " t " +
        "  ON s.medicineName = t.medicineName " +
        " AND s.SerialNumber = t.SerialNumber " +                // 필요 없으면 제거
        " AND DATE(s.DeliveryDate) = DATE(t.DeliveryDate) " +    // 타입 불일치 대비
        "WHERE s.saleDate = ?";
    psSelect = conn.prepareStatement(selectSql);
    psSelect.setString(1, saleDate);
    rs = psSelect.executeQuery();

    // 2) UPDATE 준비
    String updateSql =
        "UPDATE testTable" + idSortation +
        " SET inventory = inventory + ? " +
        "WHERE DeliveryDate = ? AND medicineName = ? AND SerialNumber = ?";
    psUpdate = conn.prepareStatement(updateSql);

    Pattern numPattern = Pattern.compile("(\\d+(?:[\\.,]\\d+)?)"); // 숫자 모두 곱셈

    while (rs.next()) {
        String medicineName = rs.getString("medicineName");
        String serialNumber = rs.getString("SerialNumber");
        String deliveryDate = rs.getString("DeliveryDate");
        double invBase = rs.getDouble("inventory");
        String standard = rs.getString("standard");

        double factor = 1.0;
        if (standard != null) {
            Matcher m = numPattern.matcher(standard);
            boolean found = false;
            while (m.find()) {
                found = true;
                String raw = m.group(1).replace(",", "");
                factor *= Double.parseDouble(raw);
            }
            if (!found) factor = 1.0;
        }
        double delta = invBase * factor;                 // ★ inventory * (standard의 모든 숫자 곱)

        psUpdate.setDouble(1, delta);
        psUpdate.setString(2, deliveryDate);
        psUpdate.setString(3, medicineName);
        psUpdate.setString(4, serialNumber);
        updated += psUpdate.executeUpdate();
    }

    // 3) 삭제
    String delSales = "DELETE FROM SalesRecord" + idSortation + " WHERE saleDate = ?";
    psDelSales = conn.prepareStatement(delSales);
    psDelSales.setString(1, saleDate);
    deletedSales = psDelSales.executeUpdate();

    String delClient = "DELETE FROM clientRecord WHERE saleDate = ?";
    psDelClient = conn.prepareStatement(delClient);
    psDelClient.setString(1, saleDate);
    deletedClient = psDelClient.executeUpdate();

    conn.commit();

    out.print("{\"ok\":true,\"updated\":" + updated +
              ",\"deletedSales\":" + deletedSales +
              ",\"deletedClient\":" + deletedClient + "}");
} catch (Exception e) {
    try { if (conn != null) conn.rollback(); } catch (Exception ignore) {}
    e.printStackTrace();
    out.print("{\"ok\":false,\"error\":\"" + e.getMessage().replace("\"","\\\"") + "\"}");
} finally {
    try { if (rs != null) rs.close(); } catch(Exception ignore){}
    try { if (psSelect != null) psSelect.close(); } catch(Exception ignore){}
    try { if (psUpdate != null) psUpdate.close(); } catch(Exception ignore){}
    try { if (psDelSales != null) psDelSales.close(); } catch(Exception ignore){}
    try { if (psDelClient != null) psDelClient.close(); } catch(Exception ignore){}
}
%>
<%@ include file="DBclose.jsp" %>