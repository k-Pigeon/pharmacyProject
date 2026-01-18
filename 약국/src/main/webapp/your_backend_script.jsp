<%@ page language="java" contentType="application/json; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.util.*, javax.servlet.*" %>
<%@ page import="javax.servlet.http.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.time.*" %>
<%@ page import="org.json.JSONArray" %>
<%@ page import="org.json.JSONObject" %>
<%@ include file="sessionManager.jsp"%>
<%@ include file="DBconnection.jsp"%>
<%
String dbName = (session != null) ? (String) session.getAttribute("dbName") : null;
String id = (session != null) ? (String) session.getAttribute("id") : null;
String password = (session != null) ? (String) session.getAttribute("password") : null;

/* out.println(password);
out.println(dbName);
out.println(id);
out.println(password); */

String idSortation = (session != null) ? (String) session.getAttribute("idSortation") : null; if (id == null || dbName == null) {
    response.sendRedirect("login.jsp");
    return;
}

jdbcDriver = dbName;
%>
<%
request.setCharacterEncoding("UTF-8");

java.util.Date today = new java.util.Date();
java.sql.Timestamp sqlDate = new java.sql.Timestamp(today.getTime());

PreparedStatement statement = null;
PreparedStatement statement1 = null;
PreparedStatement ptement = null;
PreparedStatement pstement = null;
PreparedStatement pstmt = null;

ResultSet rs = null;
ResultSet rs2 = null;

try {
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
    String priceSql = "INSERT INTO priceRecord"  + idSortation + "  (saleDate, maxmedicinePrice, generalPrice) VALUES (?, ?, ?)";
    pstmt = conn.prepareStatement(priceSql);
    pstmt.setTimestamp(1, sqlDate);
    pstmt.setString(2, medicinePrice);
    pstmt.setString(3, generalPrice);
    pstmt.executeUpdate();

    // JSON 배열을 순회하며 데이터베이스 업데이트
    for (int i = 0; i < jsonArray.length() - 1; i++) {
        JSONObject obj = jsonArray.getJSONObject(i);

        String sortationSQL = "SELECT kind FROM testTable"  + idSortation + "  WHERE SerialNumber = ? AND medicineName = ?";
        ptement = conn.prepareStatement(sortationSQL);
        ptement.setString(1, obj.getString("serialNumber"));
        ptement.setString(2, obj.getString("medicineName"));
        rs = ptement.executeQuery();

        String kind = null;
        if (rs.next()) {
            kind = rs.getString("kind");
        }

        String standardSortationSQL = "SELECT standard FROM testTable"  + idSortation + "  WHERE standard LIKE '%10병%' "
                                    + "AND medicineName = ? "
                                    + "AND DeliveryDate = (SELECT minDate FROM (SELECT MIN(DeliveryDate) AS minDate "
                                    + "FROM testTable"  + idSortation + "  WHERE SerialNumber = ? AND medicineName = ? AND returnInv = '0') AS subquery)";
        pstement = conn.prepareStatement(standardSortationSQL);
        pstement.setString(1, obj.getString("medicineName"));
        pstement.setString(2, obj.getString("serialNumber"));
        pstement.setString(3, obj.getString("medicineName"));
        rs2 = pstement.executeQuery();

        String standard = null;
        if (rs2.next()) {
            standard = rs2.getString("standard");
        }

        String sql;
        if ("드링크류".equals(kind) && "10병".equals(standard)) {
            sql = "UPDATE testTable"  + idSortation + "  SET inventory = inventory - ? "
                 + "WHERE medicineName = ? "
                 + "AND DeliveryDate = (SELECT minDate FROM (SELECT MIN(DeliveryDate) AS minDate "
                 + "FROM testTable"  + idSortation + "  WHERE SerialNumber = ? AND medicineName = ? AND returnInv = '0') AS subquery)";
            statement1 = conn.prepareStatement(sql);
            // 파라미터 설정
            statement1.setInt(1, obj.getInt("inventory") * 10);
            statement1.setString(2, obj.getString("medicineName"));
            statement1.setString(3, obj.getString("serialNumber"));
            statement1.setString(4, obj.getString("medicineName"));
            statement1.executeUpdate();
        } else {
            // SQL 쿼리 작성
            sql = "UPDATE testTable"  + idSortation + "  SET inventory = inventory - ? "
                 + "WHERE SerialNumber = ? AND medicineName = ?"
                 + "AND DeliveryDate = (SELECT minDate FROM (SELECT MIN(DeliveryDate) AS minDate "
                 + "FROM testTable"  + idSortation + "  WHERE SerialNumber = ? AND medicineName = ? AND returnInv = '0') AS subquery)";
            statement = conn.prepareStatement(sql);

            // 파라미터 설정
            statement.setInt(1, obj.getInt("inventory"));
            statement.setString(2, obj.getString("serialNumber"));
            statement.setString(3, obj.getString("medicineName"));
            statement.setString(4, obj.getString("serialNumber"));
            statement.setString(5, obj.getString("medicineName"));
            statement.executeUpdate();
        }

        // 판매 날짜 입력
        String salesSql = "INSERT INTO SalesRecord"  + idSortation + "  (saleDate, medicineName, Buyingprice, price, inventory) VALUES (?, ?, ?, ?, ?)";
        pstmt = conn.prepareStatement(salesSql);
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
    try { if (statement != null) statement.close(); } catch (Exception e) {}
    try { if (statement1 != null) statement1.close(); } catch (Exception e) {}
    try { if (ptement != null) ptement.close(); } catch (Exception e) {}
    try { if (pstement != null) pstement.close(); } catch (Exception e) {}
    try { if (pstmt != null) pstmt.close(); } catch (Exception e) {}
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    try { if (rs2 != null) rs2.close(); } catch (Exception e) {}
}
%>
<%@ include file="DBclose.jsp" %>