<%@page import="com.mysql.cj.x.protobuf.MysqlxPrepare.Prepare"%>
<%@ page import="java.sql.*, java.io.*, javax.servlet.http.*, javax.servlet.*, org.json.*"%>
<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%
request.setCharacterEncoding("UTF-8");
%>
<%
// 데이터베이스 연결 설정
String url = "jdbc:mysql://localhost:3306/tutorial2?useUnicode=true&characterEncoding=utf8";
String user = "root";
String password = "pharmacy@1234";

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(url, user, password);

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
        	out.println(rows);
			
            // 데이터 추출
            String serialNumber = row.optString("serialNumber", "");
            String medicineName = row.optString("medicineName", "");
            String buyingPrice = row.optString("buyingPrice", "0");
            String price = row.optString("price", "0");
            String inventory = row.optString("inventory", "0");
            String companyName = row.optString("companyName", "");
            String standard = row.optString("standard", "");
            String receiptDate = row.optString("receiptDate", "");
            String wholesaler = row.optString("wholesaler", "");
            String deliveryDate = row.optString("deliveryDate", ""); // 변하는 값
            String tipMedicineName = row.optString("tipMedicineName", "");
            String tipStandard = row.optString("tipstandard", "");
            String testDate = row.optString("tipDeliveryDate", ""); // 조건

            // 정규식 유통기한 변환
            String result;
            if (deliveryDate.matches("\\d{2}/\\d{2}/\\d{2}")) {
                String[] parts = deliveryDate.split("/");
                result = "20" + parts[0] + "-" + parts[1] + "-" + parts[2];
            } else {
                result = deliveryDate;
            }

            // 업데이트 쿼리
            String updateQuery = "UPDATE testTable SET medicineName = ?, buyingPrice = ?, price = ?, "
                    + "inventory = ?, companyName = ?, standard = ?, receiptDate = ?, deliveryDate = ?, wholesaler = ? "
                    + "WHERE serialNumber = ? AND medicineName = ? AND DeliveryDate = ?";
            PreparedStatement updateStmt = conn.prepareStatement(updateQuery);
            updateStmt.setString(1, medicineName);
            updateStmt.setString(2, buyingPrice);
            updateStmt.setString(3, price);
            updateStmt.setString(4, inventory);
            updateStmt.setString(5, companyName);
            updateStmt.setString(6, standard);
            updateStmt.setString(7, receiptDate);
            updateStmt.setString(8, result);
            updateStmt.setString(9, wholesaler);
            updateStmt.setString(10, serialNumber);
            updateStmt.setString(11, tipMedicineName); // 기존값
            updateStmt.setString(12, testDate);       // 기존 유통기한

            int rowsUpdated = updateStmt.executeUpdate();
            updateStmt.close();
            out.println(testDate);
        }
        
    out.println("데이터 처리가 완료되었습니다.");
    conn.close();
} catch (Exception e) {
    e.printStackTrace();
    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
    out.println("데이터베이스 오류 발생: " + e.getMessage());
}
%>

