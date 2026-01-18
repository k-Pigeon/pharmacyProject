<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="sessionManager.jsp" %>
<%@ include file="DBconnection.jsp" %>
<%
request.setCharacterEncoding("UTF-8");

String dbName = (session != null) ? (String) session.getAttribute("dbName") : null;
if (dbName == null) {
    response.setStatus(401);
    out.print("세션이 만료되었습니다.");
    return;
}
jdbcDriver = dbName;

if (!"true".equals(request.getParameter("submitted"))) {
    response.setStatus(400);
    out.print("잘못된 요청입니다.");
    return;
}

PreparedStatement countStmt = null;
ResultSet countRs = null;
PreparedStatement pstmt = null;

String medicineName = request.getParameter("medicineName");
String[] standardList = request.getParameter("standardList").split(",");
String[] priceList = request.getParameter("priceList").split(",");
String[] buyingPriceList = request.getParameter("buyingPriceList").split(",");

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPwd);

    String countQuery = "SELECT MAX(CAST(countNumber AS UNSIGNED)) FROM RegistTable";
    countStmt = conn.prepareStatement(countQuery);
    countRs = countStmt.executeQuery();

    int nextCount = 1;
    if (countRs.next()) {
        nextCount = countRs.getInt(1) + 1;
    }

    String sql = "INSERT INTO RegistTable (medicineName, standard, buyingPrice, price, countNumber) VALUES (?, ?, ?, ?, ?)";
    pstmt = conn.prepareStatement(sql);

    int maxLength = Math.max(Math.max(standardList.length, priceList.length), buyingPriceList.length);

    for (int i = 0; i < maxLength; i++) {
        String standard = (i < standardList.length) ? standardList[i].trim() : "";
        String price = (i < priceList.length) ? priceList[i].trim() : "";
        if (standard.isEmpty() || price.isEmpty()) continue;

        String buyingPrice = (i < buyingPriceList.length && !buyingPriceList[i].trim().isEmpty())
                ? buyingPriceList[i].trim()
                : price;

        pstmt.setString(1, medicineName);
        pstmt.setString(2, standard);
        pstmt.setString(3, buyingPrice);
        pstmt.setString(4, price);
        pstmt.setString(5, String.valueOf(nextCount++));
        pstmt.executeUpdate();
    }

    pstmt.close();
    out.print("success");
} catch (Exception e) {
    response.setStatus(500);
    out.print("에러: " + e.getMessage());
} finally {
    try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
    try { if (countStmt != null) countStmt.close(); } catch (Exception ignored) {}
    try { if (countRs != null) countRs.close(); } catch (Exception ignored) {}
}
%>
<%@ include file="DBclose.jsp" %>
