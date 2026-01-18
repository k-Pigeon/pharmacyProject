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

            // 데이터 추출
            String medicineName = row.optString("medicineName", "");
            String standard = row.optString("standard", "");
            String deliveryDate = row.optString("deliveryDate", "");
            // 정규식 유통기한 변환
            String result;
            if (deliveryDate.matches("\\d{2}/\\d{2}/\\d{2}")) {
                String[] parts = deliveryDate.split("/");
                result = "20" + parts[0] + "-" + parts[1] + "-" + parts[2];
            } else {
                result = deliveryDate;
            }

            // 업데이트 쿼리
            String updateQuery = " Delete from testTable "
            				   + " where medicineName = ? AND standard = ? AND DeliveryDate = ?";
            PreparedStatement updateStmt = conn.prepareStatement(updateQuery);
            updateStmt.setString(1, medicineName);
            updateStmt.setString(2, standard);
            updateStmt.setString(3, result);

            int rowsUpdated = updateStmt.executeUpdate();
            updateStmt.close();

            // 디버깅
            System.out.println("Updated Rows: " + rowsUpdated);
            System.out.println("Updated DeliveryDate: " + result);
        }

        // 빈 약품명 삭제
        String deleteQuery = "DELETE FROM testTable WHERE medicineName = ''";
        PreparedStatement deleteStmt = conn.prepareStatement(deleteQuery);
        deleteStmt.executeUpdate();
        deleteStmt.close();
        
    out.println("데이터 처리가 완료되었습니다.");
    conn.close();
} catch (Exception e) {
    e.printStackTrace();
    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
    out.println("데이터베이스 오류 발생: " + e.getMessage());
}
%>

