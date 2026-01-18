<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.sql.*" %>
<%@ page import="javax.servlet.*, javax.servlet.http.*" %>
<%@ page import="org.json.*" %>
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

if (id == null || dbName == null) {
    response.sendRedirect("login.jsp");
    return;
}

jdbcDriver = dbName;
%>
<%
request.setCharacterEncoding("UTF-8");

String medicineName = request.getParameter("medicineName");

PreparedStatement pstmt = null;
ResultSet rs = null;

JSONObject resultJson = new JSONObject();

try {
    String sql = " SELECT * from vitalSet "
    		   + " where medicineName = ?";
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, medicineName);
    rs = pstmt.executeQuery();

    if (rs.next()) {
        JSONObject rowData = new JSONObject();
        rowData.put("SerialNumber", "일반세트");
        rowData.put("medicineName", rs.getString("medicineName"));
        rowData.put("Buyingprice", rs.getDouble("Buyingprice"));
        rowData.put("price", rs.getDouble("price"));
        rowData.put("inventory", 1);
        
        resultJson.put("data", rowData);
    } else {
        resultJson.put("error", "No data found for the given medicineName or inventory is 0");
    }

} catch (SQLException e) {
    e.printStackTrace();
    resultJson.put("error", "SQLException: " + e.getMessage());
} finally {
    // 리소스 정리
    try {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    } catch (SQLException se) {
        se.printStackTrace();
        resultJson.put("error", "SQLException in finally: " + se.getMessage());
    }
}

// JSON 문자열로 변환하여 출력
response.setContentType("application/json");
response.setCharacterEncoding("UTF-8");
response.getWriter().write(resultJson.toString());
%>
