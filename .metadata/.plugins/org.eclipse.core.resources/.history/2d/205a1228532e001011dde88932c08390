<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*, java.io.*, org.json.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ include file="sessionManager.jsp"%>
<%@ include file="DBconnection.jsp"%>

<%
String dbName = (session != null) ? (String) session.getAttribute("dbName") : null;
String id = (session != null) ? (String) session.getAttribute("id") : null;
String password = (session != null) ? (String) session.getAttribute("password") : null;

if (id == null || dbName == null) {
    response.sendRedirect("login.jsp");
    return;
}

jdbcDriver = dbName;

try {
    BufferedReader reader = request.getReader();
    StringBuilder jsonBuilder = new StringBuilder();
    String line;
    while ((line = reader.readLine()) != null) {
        jsonBuilder.append(line);
    }
    String jsonData = jsonBuilder.toString();

    JSONArray rows = new JSONArray(jsonData);
    
    for (int i = 0; i < rows.length(); i++) {
        JSONObject row = rows.getJSONObject(i);

        // 데이터 추출
        String serialNumber = row.optString("serialNumber", "");
        String medicineName = row.optString("medicineName", "");
        String buyingPrice = row.optString("buyingPrice", "0");
        String price = row.optString("price", "0");
        double inventory = row.optDouble("inventory", 0.0); // 숫자로 변환
        String companyName = row.optString("companyName", "");
        String standard = row.optString("standard", "");
        String kind = row.optString("kind", "");
        String receiptDate = row.optString("receiptDate", "");
        String deliveryDate = row.optString("deliveryDate", ""); // 변하는 값
        String tipMedicineName = row.optString("tipMedicineName", "");
        String tipStandard = row.optString("tipstandard", "");
        String testDate = row.optString("tipDeliveryDate", ""); // 기존 유통기한

        // 정규식 유통기한 변환
        String result;
        if (deliveryDate.matches("\\d{2}/\\d{2}/\\d{2}")) {
            String[] parts = deliveryDate.split("/");
            result = "20" + parts[0] + "-" + parts[1] + "-" + parts[2];
        } else {
            result = deliveryDate;
        }

        // 🔹 `standard`에 따라 `inventory` 값 조정
        double adjustedInventory = inventory; // 기본값

        if (standard.contains(" ")) { 
            // 띄어쓰기가 있는 경우, 숫자 두 개를 추출해 곱한 후 inventory와 곱하기
            String[] parts = standard.split(" ");
            List<Double> numbers = new ArrayList<>();

            for (String part : parts) {
                String numStr = part.replaceAll("[^0-9]", ""); // 숫자만 추출
                if (!numStr.isEmpty()) {
                    numbers.add(Double.parseDouble(numStr));
                }
            }

            if (numbers.size() >= 2) {
                adjustedInventory = inventory * (numbers.get(0) * numbers.get(1));
            }
        } else {
            // 단위가 포함된 경우 (ml, g, l, 포) → inventory * standard 숫자 값
            String numericStandard = standard.replaceAll("[^0-9]", "");
            if (!numericStandard.isEmpty()) {
                adjustedInventory = inventory * Double.parseDouble(numericStandard);
            }
        }

        // 업데이트 쿼리
        String updateQuery = "UPDATE testTable SET medicineName = ?, buyingPrice = ?, price = ?, "
                + "inventory = ?, companyName = ?, standard = ?, receiptDate = ?, deliveryDate = ?, kind = ? "
                + "WHERE serialNumber = ? AND medicineName = ? AND DeliveryDate = ?";
        PreparedStatement updateStmt = conn.prepareStatement(updateQuery);
        updateStmt.setString(1, medicineName);
        updateStmt.setString(2, buyingPrice);
        updateStmt.setString(3, price);
        updateStmt.setDouble(4, adjustedInventory); // 계산된 inventory 값 저장
        updateStmt.setString(5, companyName);
        updateStmt.setString(6, standard);
        updateStmt.setString(7, receiptDate);
        updateStmt.setString(8, result);
        updateStmt.setString(9, kind);
        updateStmt.setString(10, serialNumber);
        updateStmt.setString(11, tipMedicineName); // 기존값
        updateStmt.setString(12, testDate);       // 기존 유통기한

        int rowsUpdated = updateStmt.executeUpdate();
        updateStmt.close();
    }
    
    out.println("데이터 처리가 완료되었습니다.");
    conn.close();
} catch (Exception e) {
    e.printStackTrace();
    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
    out.println("데이터베이스 오류 발생: " + e.getMessage());
}
%>
