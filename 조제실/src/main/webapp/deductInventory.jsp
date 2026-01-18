<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, org.json.*" %>
<%

response.setContentType("application/json; charset=UTF-8");
response.setHeader("Access-Control-Allow-Origin", "*");
response.setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS");
response.setHeader("Access-Control-Allow-Headers", "Content-Type");
request.setCharacterEncoding("UTF-8");

// JSON 응답 생성
JSONObject responseJson = new JSONObject();
JSONArray resultsArray = new JSONArray();

try {
    // 파라미터 가져오기
    String serialNumbersJson = request.getParameter("SerialNumbers");
    String inventoriesJson = request.getParameter("Inventories");

    if (serialNumbersJson == null || inventoriesJson == null) {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        throw new IllegalArgumentException("SerialNumbers와 Inventories가 필요합니다.");
    }

    // JSON 배열로 변환
    JSONArray serialNumbers = new JSONArray(serialNumbersJson);
    JSONArray inventories = new JSONArray(inventoriesJson);

    if (serialNumbers.length() != inventories.length()) {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        throw new IllegalArgumentException("SerialNumbers와 Inventories의 길이가 일치하지 않습니다.");
    }

    // DB 연결 정보
    String jdbcDriver = "jdbc:mysql://localhost:3306/tutorial2?useUnicode=true&characterEncoding=utf8";
    String dbUser = "root";
    String dbPwd = "pharmacy@1234";

    try (Connection conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPwd)) {
        Class.forName("com.mysql.cj.jdbc.Driver");

        for (int i = 0; i < serialNumbers.length(); i++) {
            String serialNumber = serialNumbers.getString(i);
            String inventoryStr = inventories.getString(i);

            // 숫자만 추출
            String numericInventory = inventoryStr.replaceAll("[^0-9]", ""); // 숫자만 남기기
            int inventory = numericInventory.isEmpty() ? 0 : Integer.parseInt(numericInventory);

            // 유통기한이 가장 짧은 순으로 inventory를 가져오기
            String selectSQL = "SELECT inventory, DeliveryDate FROM testTable WHERE SerialNumber = ? ORDER BY DeliveryDate ASC";
            try (PreparedStatement pstmt = conn.prepareStatement(selectSQL)) {
                pstmt.setString(1, serialNumber);
                try (ResultSet rs = pstmt.executeQuery()) {
                    int remainingInventory = inventory;

                    while (rs.next() && remainingInventory > 0) {
                        int currentInventory = rs.getInt("inventory");
                        String deliveryDate = rs.getString("DeliveryDate");

                        int deduction = Math.min(currentInventory, remainingInventory);

                        // 재고 업데이트 쿼리
                        String updateSQL = "UPDATE testTable SET inventory = inventory - ? WHERE SerialNumber = ? AND DeliveryDate = ?";
                        try (PreparedStatement updateStmt = conn.prepareStatement(updateSQL)) {
                            updateStmt.setInt(1, deduction);
                            updateStmt.setString(2, serialNumber);
                            updateStmt.setString(3, deliveryDate);
                            updateStmt.executeUpdate();
                        }

                        remainingInventory -= deduction;
                    }

                    // 처리 결과 추가
                    JSONObject result = new JSONObject();
                    result.put("SerialNumber", serialNumber);
                    result.put("requestedInventory", inventory);
                    result.put("remainingInventory", remainingInventory);
                    result.put("status", (remainingInventory > 0) ? "warning" : "success");
                    resultsArray.put(result);
                }
            }
        }

        // 최종 응답
        responseJson.put("status", "success");
        responseJson.put("results", resultsArray);
        out.print(responseJson.toString());
    }
} catch (IllegalArgumentException e) {
    responseJson.put("status", "error");
    responseJson.put("message", e.getMessage());
    out.print(responseJson.toString());
} catch (Exception e) {
    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
    responseJson.put("status", "error");
    responseJson.put("message", "처리 중 오류 발생: " + e.getMessage());
    out.print(responseJson.toString());
}
%>
