<%@ page language="java" contentType="application/json; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.util.*, javax.servlet.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.time.*" %>
<%@ page import="org.json.JSONArray" %>
<%@ page import="org.json.JSONObject" %>
<%
request.setCharacterEncoding("UTF-8");
// 데이터베이스 연결 정보
String url = "jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8";
String username = "root";
String password = "pharmacy@1234";

java.util.Date today = new java.util.Date();
java.sql.Timestamp sqlDate = new java.sql.Timestamp(today.getTime());

Connection connection = null;
PreparedStatement ptement = null;
PreparedStatement recordPtement = null;

try {
    // 데이터베이스 연결
    Class.forName("com.mysql.cj.jdbc.Driver");
    connection = DriverManager.getConnection(url, username, password);

    // 받은 JSON 데이터 파싱
    StringBuilder sb = new StringBuilder();
    try {
        BufferedReader reader = request.getReader();
        String line;
        while ((line = reader.readLine()) != null) {
            sb.append(line);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    JSONArray jsonArray = new JSONArray(sb.toString());

    // JSON 배열을 순회하며 데이터베이스 업데이트
    for (int i = 0; i < jsonArray.length() - 1; i++) {
        JSONObject obj = jsonArray.getJSONObject(i);

        String sortationSQL = "UPDATE testTable "
        		   + "SET price = ? "
        		   + "WHERE serialNumber = ? AND medicineName = ? AND standard = ?";
        ptement = connection.prepareStatement(sortationSQL);
        ptement.setString(1, obj.getString("price"));
        ptement.setString(2, obj.getString("serialNumber"));
        ptement.setString(3, obj.getString("medicineName"));
        ptement.setString(4, obj.getString("standard"));
        
        // 콘솔 디버깅 출력
        System.out.println("Updating price to: " + obj.getString("price") + " for serialNumber: " + obj.getString("serialNumber") + ", medicineName: " + obj.getString("medicineName") + ", standard: " + obj.getString("standard"));
        
        ptement.executeUpdate();
        
        String recordSQL = "INSERT INTO fluctuationRecord(saleDate, medicineName, price) "
        				 + "VALUES(?, ?, ?)";
        recordPtement = connection.prepareStatement(recordSQL);
        recordPtement.setTimestamp(1, sqlDate);
        recordPtement.setString(2, obj.getString("medicineName"));
        recordPtement.setString(3, obj.getString("price"));
        
        recordPtement.executeUpdate();
    }

    // 데이터베이스 작업이 성공하면 성공 메시지를 응답
    JSONObject successObj = new JSONObject();
    successObj.put("success", true);
    response.setContentType("application/json");
    response.getWriter().write(successObj.toString());
} catch (Exception e) {
    e.printStackTrace();
    // 오류 응답
    JSONObject errorObj = new JSONObject();
    errorObj.put("success", false);
    errorObj.put("message", "Error: " + e.getMessage());
    response.setContentType("application/json");
    response.getWriter().write(errorObj.toString());
} finally {
    // 연결 및 리소스 정리
    if (ptement != null) {
        ptement.close();
    }
    if (recordPtement != null) {
        recordPtement.close();
    }
    if (connection != null) {
        connection.close();
    }
}
%>
