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

java.util.Date today = new java.util.Date();
java.sql.Timestamp sqlDate = new java.sql.Timestamp(today.getTime());

// 데이터베이스 연결 정보
String url = "jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8";
String username = "root";
String password = "pharmacy@1234";

Connection connection = null;
PreparedStatement statement = null;
PreparedStatement statement1 = null;
PreparedStatement ptement = null;
PreparedStatement pstement = null;
PreparedStatement pstmt = null;

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

    // 개별 파라미터 처리
    JSONObject paramObj = jsonArray.getJSONObject(jsonArray.length() - 1);
    String medicinePrice = paramObj.getString("medicinePrice");
    String generalPrice = paramObj.getString("generalPrice");

    // 개별 파라미터 삽입
    String priceSql = "INSERT INTO priceRecord (saleDate, maxmedicinePrice, generalPrice) VALUES (?, ?, ?)";
    pstmt = connection.prepareStatement(priceSql);
    pstmt.setTimestamp(1, sqlDate);
    pstmt.setString(2, medicinePrice);
    pstmt.setString(3, generalPrice);
    pstmt.executeUpdate();

    // JSON 배열을 순회하며 데이터베이스 업데이트
    for (int i = 0; i < jsonArray.length() - 1; i++) {
        JSONObject obj = jsonArray.getJSONObject(i);

        String sortationSQL = "SELECT kind FROM testTable WHERE SerialNumber = ? AND medicineName = ?";
        ptement = connection.prepareStatement(sortationSQL);
        ptement.setString(1, obj.getString("serialNumber"));
        ptement.setString(2, obj.getString("medicineName"));
        ResultSet rs = ptement.executeQuery();

        String kind = null;
        if (rs.next()) {
            kind = rs.getString("kind");
        }

        String standardSortationSQL = "SELECT standard FROM testTable WHERE standard LIKE '%10병%' "
                                    + "AND medicineName = ? "
                                    + "AND DeliveryDate = (SELECT minDate FROM (SELECT MIN(DeliveryDate) AS minDate "
                                    + "FROM testTable WHERE SerialNumber = ? AND medicineName = ? AND returnInv = '0') AS subquery)";
        pstement = connection.prepareStatement(standardSortationSQL);
        pstement.setString(1, obj.getString("medicineName"));
        pstement.setString(2, obj.getString("serialNumber"));
        pstement.setString(3, obj.getString("medicineName"));
        ResultSet rs2 = pstement.executeQuery();

        String standard = null;
        if (rs2.next()) {
            standard = rs2.getString("standard");
        }

        String sql;
        if ("드링크류".equals(kind) && "10병".equals(standard)) {
            sql = "UPDATE testTable SET inventory = inventory - ? "
                 + "WHERE medicineName = ? "
                 + "AND DeliveryDate = (SELECT minDate FROM (SELECT MIN(DeliveryDate) AS minDate "
                 + "FROM testTable WHERE SerialNumber = ? AND medicineName = ? AND returnInv = '0') AS subquery)";
            statement1 = connection.prepareStatement(sql);
            // 파라미터 설정
            statement1.setInt(1, obj.getInt("inventory") * 10);
            statement1.setString(2, obj.getString("medicineName"));
            statement1.setString(3, obj.getString("serialNumber"));
            statement1.setString(4, obj.getString("medicineName"));
            statement1.executeUpdate();
        } else {
            // SQL 쿼리 작성
            sql = "UPDATE testTable SET inventory = inventory - ? "
                 + "WHERE SerialNumber = ? AND medicineName = ?"
                 + "AND DeliveryDate = (SELECT minDate FROM (SELECT MIN(DeliveryDate) AS minDate "
                 + "FROM testTable WHERE SerialNumber = ? AND medicineName = ? AND returnInv = '0') AS subquery)";
            statement = connection.prepareStatement(sql);

            // 파라미터 설정
            statement.setInt(1, obj.getInt("inventory"));
            statement.setString(2, obj.getString("serialNumber"));
            statement.setString(3, obj.getString("medicineName"));
            statement.setString(4, obj.getString("serialNumber"));
            statement.setString(5, obj.getString("medicineName"));
            statement.executeUpdate();
        }

        // 판매 날짜 입력
        String salesSql = "INSERT INTO SalesRecord (saleDate, medicineName, Buyingprice, price, inventory) VALUES (?, ?, ?, ?, ?)";
        pstmt = connection.prepareStatement(salesSql);
        pstmt.setTimestamp(1, sqlDate);
        pstmt.setString(2, obj.getString("medicineName"));
        pstmt.setInt(3, obj.getInt("Buyingprice"));
        pstmt.setInt(4, obj.getInt("price"));
        pstmt.setInt(5, obj.getInt("inventory"));
        pstmt.executeUpdate();
    }

    // 데이터베이스 작업이 성공하면 성공 메시지를 응답
    JSONObject successObj = new JSONObject();
    successObj.put("success", true);
    response.getWriter().write(successObj.toString());
} catch (Exception e) {
    // 오류 응답
    JSONObject errorObj = new JSONObject();
    errorObj.put("success", false);
    errorObj.put("message", "Error: " + e.getMessage());
    response.getWriter().write(errorObj.toString());
} finally {
    // 연결 및 리소스 정리
    if (ptement != null) {
        ptement.close();
    }
    if (pstement != null) {
        pstement.close();
    }
    if (statement != null) {
        statement.close();
    }
    if (statement1 != null) {
        statement1.close();
    }
    if (pstmt != null) {
        pstmt.close();
    }
    if (connection != null) {
        connection.close();
    }
}
%>
