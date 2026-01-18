<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.*, java.sql.*, org.json.*" %>
<%@ include file="sessionManager.jsp"%>
<%@ include file="DBconnection.jsp"%>
<%
String dbName = (session != null) ? (String) session.getAttribute("dbName") : null;
String id = (session != null) ? (String) session.getAttribute("id") : null;

JSONObject responseJson = new JSONObject();
PreparedStatement psMain = null;
PreparedStatement psDetail = null;

ResultSet rs = null;

try {
    String idSortation = (session != null) ? (String) session.getAttribute("idSortation") : null;
    if (id == null || dbName == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    jdbcDriver = dbName;
    conn.setAutoCommit(false);

    // 1️⃣ JSON 파싱
    BufferedReader reader = request.getReader();
    StringBuilder sb = new StringBuilder();
    String line;
    while ((line = reader.readLine()) != null) sb.append(line);
    JSONObject json = new JSONObject(sb.toString());

    String setName = json.optString("setName", "").trim();
    String setType = json.optString("setType", "product"); // 기본값: 일반세트
    int buyingprice = json.optInt("buyingprice", 0);
    int price = json.optInt("price", 0);
    int inventory = json.optInt("inventory", 1);
    JSONArray products = json.getJSONArray("products");

    if (setType.equals("product")) {
        // 🟢 일반세트 → productSet + productSet_detail
        String sqlSet = "INSERT INTO productSet (setName, buyingprice, price, inventory) VALUES (?, ?, ?, ?)";
        psMain = conn.prepareStatement(sqlSet, Statement.RETURN_GENERATED_KEYS);
        psMain.setString(1, setName);
        psMain.setInt(2, buyingprice);
        psMain.setInt(3, price);
        psMain.setInt(4, inventory);
        psMain.executeUpdate();

        rs = psMain.getGeneratedKeys();
        int setId = 0;
        if (rs.next()) setId = rs.getInt(1);
        rs.close();

        String sqlDetail = "INSERT INTO productSet_detail (productSet_id, medicineName, standard) VALUES (?, ?, ?)";
        psDetail = conn.prepareStatement(sqlDetail);
        for (int i = 0; i < products.length(); i++) {
            JSONObject p = products.getJSONObject(i);
            psDetail.setInt(1, setId);
            psDetail.setString(2, p.optString("medicineName", ""));
            psDetail.setString(3, p.optString("standard", ""));
            psDetail.addBatch();
        }
        psDetail.executeBatch();

    } else if (setType.equals("regular")) {
        // 🔵 한약세트 → regularSet에 직접 저장
        String sqlRegular = "INSERT INTO regularSet (setName, medicineName, Buyingprice, price, inventory, standard) VALUES (?, ?, ?, ?, ?, ?)";
        psMain = conn.prepareStatement(sqlRegular);

        for (int i = 0; i < products.length(); i++) {
            JSONObject p = products.getJSONObject(i);
            psMain.setString(1, setName);
            psMain.setString(2, p.optString("medicineName", ""));
            psMain.setString(3, String.valueOf(buyingprice));
            psMain.setString(4, String.valueOf(price));
            psMain.setInt(5, inventory);
            psMain.setString(6, p.optString("standard", ""));
            psMain.addBatch();
        }
        psMain.executeBatch();
    }

    conn.commit();

    responseJson.put("status", "success");
    responseJson.put("message", "세트 저장 완료");
    responseJson.put("setType", setType);

} catch (Exception e) {
    if (conn != null) try { conn.rollback(); } catch (Exception ex) {}
    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
    responseJson.put("status", "error");
    responseJson.put("message", "오류 발생: " + e.getMessage());
    e.printStackTrace();
} finally {
    try { if (psDetail != null) psDetail.close(); } catch (Exception e) {}
    try { if (psMain != null) psMain.close(); } catch (Exception e) {}
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    out.print(responseJson.toString());
}
%>
<%@ include file="DBclose.jsp" %>