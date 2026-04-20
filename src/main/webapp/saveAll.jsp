<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.sql.*, org.json.*, java.util.*, java.util.regex.*" %>
<%@ include file="sessionManager.jsp" %>
<%@ include file="DBconnection.jsp" %>

<%!
/* 쉼표 제거 함수 */
private String cleanNumber(String value) {
    if (value == null) return null;
    return value.replaceAll(",", "").trim();
}

/* 날짜 형식 변환 (yy/MM/dd → yyyy-MM-dd) */
private String formatDate(String inputDate) {
    if (inputDate == null || inputDate.trim().isEmpty()) return null;
    inputDate = inputDate.trim();

    try {
        // 이미 yyyy-MM-dd 형태
        if (inputDate.matches("^20\\d{2}-\\d{2}-\\d{2}$")) 
            return inputDate;

        // yy/MM/dd 형태
        if (inputDate.matches("^\\d{2}/\\d{2}/\\d{2}$")) {
            String[] p = inputDate.split("/");
            return "20" + p[0] + "-" + p[1] + "-" + p[2];
        }

        return inputDate;
    } catch (Exception e) {
        return inputDate; // 실패해도 원본 리턴
    }
}
%>

<%
request.setCharacterEncoding("UTF-8");

String dbName = (session != null) ? (String) session.getAttribute("dbName") : null;
String id = (session != null) ? (String) session.getAttribute("id") : null;
String password = (session != null) ? (String) session.getAttribute("password") : null;

/* out.println(password);
out.println(dbName);
out.println(id);
out.println(password); */

if (id == null || dbName == null) {
    response.sendRedirect("login.jsp");
    return;
}

String domainType = (session != null) ? (String) session.getAttribute("domainType") : null;

StringBuilder sb = new StringBuilder();
BufferedReader reader = request.getReader();
String line;
while ((line = reader.readLine()) != null) sb.append(line);

PreparedStatement pstmt = null;

try {
    JSONObject data = new JSONObject(sb.toString());

    conn.setAutoCommit(false);

    for (String key : data.keySet()) {

        JSONObject row = data.getJSONObject(key);

        String[] parts = key.split("\\|");
        if (parts.length < 3) continue;

        String medicineName = parts[0];
        String deliveryDate = formatDate(parts[1]);
        String standard = parts[2];

        /* ---------------- 숫자 필드 처리 ---------------- */
        String[] numericFields = { "inventory", "price", "buyingPrice" };
        for (String f : numericFields) {
            if (row.has(f)) {
                row.put(f, cleanNumber(row.getString(f)));
            }
        }

        /* ---------------- 날짜 처리 ---------------- */
        if (row.has("receiptDate")) {
            row.put("receiptDate", formatDate(row.getString("receiptDate")));
        }

        if (row.has("DeliveryDate")) {
            row.put("DeliveryDate", formatDate(row.getString("DeliveryDate")));
        }

        /* ---------------- SQL 생성 ---------------- */
        List<String> columns = new ArrayList<>();
        List<String> values = new ArrayList<>();

        for (Iterator<String> it = row.keys(); it.hasNext();) {
            String col = it.next();
            columns.add(col + "=?");
            values.add(row.getString(col));
        }

        String sql = "UPDATE testTable SET "
                   + String.join(",", columns)
                   + " WHERE medicineName=? AND DeliveryDate=? AND standard=? AND domain_type=?";

        pstmt = conn.prepareStatement(sql);

        int idx = 1;

        // SET 값
        for (String val : values) {
            pstmt.setString(idx++, val);
        }

        // WHERE 값 (버그 수정됨)
        pstmt.setString(idx++, medicineName);
        pstmt.setString(idx++, deliveryDate);
        pstmt.setString(idx++, standard);
        pstmt.setString(idx++, domainType);

        pstmt.executeUpdate();
    }

    conn.commit();
    out.print("{\"status\":\"success\"}");

} catch (Exception e) {
    try { conn.rollback(); } catch (Exception ignore) {}
    e.printStackTrace();
    out.print("{\"status\":\"error\", \"message\":\"" + e.getMessage() + "\"}");

} finally {
    try { if (pstmt != null) pstmt.close(); } catch (Exception ignore) {}
    try { if (conn != null) conn.close(); } catch (Exception ignore) {}
}
%>