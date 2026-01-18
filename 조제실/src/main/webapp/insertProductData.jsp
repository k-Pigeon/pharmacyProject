<%@ page contentType="application/json; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="org.json.JSONArray" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="java.io.BufferedReader" %>

<%
    // DB 연결 설정
    String url = "jdbc:mysql://localhost:3306/tutorial2?useUnicode=true&characterEncoding=utf8";
    String user = "root";
    String password = "pharmacy@1234";

    Connection conn = null;
    PreparedStatement pstmt = null;

    // JSON 데이터 읽기
    StringBuilder sb = new StringBuilder();
    String line;
    BufferedReader reader = request.getReader();
    while ((line = reader.readLine()) != null) {
        sb.append(line);
    }

    try {
        JSONArray jsonArray = new JSONArray(sb.toString());
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(url, user, password);

        String sql = "INSERT INTO testTable (SerialNumber, MedicineName, DeliveryDate, Inventory, BuyingPrice, Price, CompanyName, Standard, ReceiptDate, returnInv) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        pstmt = conn.prepareStatement(sql);

        for (int i = 0; i < jsonArray.length(); i++) {
            JSONObject obj = jsonArray.getJSONObject(i);

            pstmt.setString(1, obj.optString("serialNumber"));
            pstmt.setString(2, obj.optString("medicineName"));
            pstmt.setString(3, obj.optString("deliveryDate"));
            pstmt.setString(4, obj.optString("inventory"));
            pstmt.setString(5, obj.optString("buyingPrice"));
            pstmt.setString(6, obj.optString("price"));
            pstmt.setString(7, obj.optString("companyName"));
            pstmt.setString(8, obj.optString("standard"));
            pstmt.setString(9, obj.optString("receiptDate"));
            pstmt.setString(10, "0");

            pstmt.addBatch(); // 배치 처리
        }

        pstmt.executeBatch(); // 배치 실행
        response.getWriter().print("{\"status\": \"success\"}");
    } catch (Exception e) {
        e.printStackTrace();
        response.getWriter().print("{\"status\": \"error\", \"message\": \"" + e.getMessage() + "\"}");
    } finally {
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>
