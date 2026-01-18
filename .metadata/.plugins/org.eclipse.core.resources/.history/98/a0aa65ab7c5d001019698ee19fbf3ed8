<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.io.BufferedReader, java.io.IOException, java.sql.*, org.json.JSONObject, org.json.JSONArray" %>
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
%>
<%
    PreparedStatement pstmt = null;
    JSONObject responseJson = new JSONObject();
    
    try {
        // JSON 데이터 읽기
        StringBuilder sb = new StringBuilder();
        String line;
        BufferedReader reader = request.getReader();
        
        while ((line = reader.readLine()) != null) {
            sb.append(line);
        }

        // JSON 파싱
        JSONObject jsonData = new JSONObject(sb.toString());

        String setName = jsonData.getString("setName");
        JSONArray products = jsonData.getJSONArray("products");

        // 총 사입 가격, 총 판매 가격 직접 계산
        int totalBuyingPrice = 0;
        int totalSellingPrice = 0;

        // 제품 목록 (최대 4개)
        String medicineName_1 = null, medicineName_2 = null, medicineName_3 = null, medicineName_4 = null;

        for (int i = 0; i < products.length(); i++) {
            JSONObject product = products.getJSONObject(i);
            String medicineName = product.has("medicineName") ? product.getString("medicineName") : null;
            int buyingPrice = product.has("buyingPrice") ? product.getInt("buyingPrice") : 0;
            int sellingPrice = product.has("sellingPrice") ? product.getInt("sellingPrice") : 0;

            // 순서에 따라 medicineName 변수에 할당
            if (i == 0) medicineName_1 = medicineName;
            else if (i == 1) medicineName_2 = medicineName;
            else if (i == 2) medicineName_3 = medicineName;
            else if (i == 3) medicineName_4 = medicineName;

            // 가격 합산
            totalBuyingPrice += buyingPrice;
            totalSellingPrice += sellingPrice;
        }

        Class.forName("com.mysql.cj.jdbc.Driver");

        // SQL 실행
        String sql = "INSERT INTO productSet (medicineName, medicineName_1, medicineName_2, medicineName_3, medicineName_4, buyingprice, price, inventory) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, setName);
        pstmt.setString(2, medicineName_1);
        pstmt.setString(3, medicineName_2);
        pstmt.setString(4, medicineName_3);
        pstmt.setString(5, medicineName_4);
        pstmt.setInt(6, totalBuyingPrice);
        pstmt.setInt(7, totalSellingPrice);
        pstmt.setInt(8, 1); // inventory는 1로 설정

        int result = pstmt.executeUpdate();

        if (result > 0) {
            responseJson.put("status", "success");
            responseJson.put("message", "데이터 저장 완료");
        } else {
            responseJson.put("status", "fail");
            responseJson.put("message", "데이터 저장 실패");
        }
    } catch (Exception e) {
        responseJson.put("status", "error");
        responseJson.put("message", "오류 발생: " + e.getMessage());
        e.printStackTrace();
    } finally {
        // 자원 해제
        try { if (pstmt != null) pstmt.close(); } catch (SQLException e) {}
        try { if (conn != null) conn.close(); } catch (SQLException e) {}
    }

    out.print(responseJson.toString());
%>
