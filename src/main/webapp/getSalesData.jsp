<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
<%@ include file="sessionManager.jsp"%>
<%@ include file="DBconnection.jsp"%>
<%
String domainType = (session != null) ? (String) session.getAttribute("domainType") : null;
    String period = request.getParameter("period"); // 'week' 또는 'month' 값을 받음
    Statement stmt = null;
    ResultSet rs = null;
    String query = "";

    // period에 따라 다른 쿼리 실행
    if ("week".equals(period)) {
        query = "SELECT DATE(saleDate) AS saleDate, SUM(price * (inventory / standard)) AS profit " +
                "FROM SalesRecord"+ 
                "WHERE saleDate >= CURDATE() - INTERVAL 7 DAY AND domain_type = "  + domainType +
                "GROUP BY DATE(saleDate)";
    }
    else if ("month1".equals(period)) {
        query = "SELECT DATE(saleDate) AS saleDate, SUM(price * (inventory/standard)) AS profit " +
                "FROM SalesRecord" + 
                "WHERE saleDate >= CURDATE() - INTERVAL 1 MONTH AND domain_type = "  + domainType +
                "GROUP BY DATE(saleDate)";
    }
    else if ("month3".equals(period)) {
        query = "SELECT DATE(saleDate) AS saleDate, SUM(price * (inventory/standard)) AS profit " +
                "FROM SalesRecord" +
                "WHERE saleDate >= CURDATE() - INTERVAL 3 MONTH AND domain_type = "  + domainType +
                "GROUP BY DATE(saleDate)";
    }
    else if ("month6".equals(period)) {
        query = "SELECT DATE(saleDate) AS saleDate, SUM(price * (inventory/standard)) AS profit " +
                "FROM SalesRecord" + 
                "WHERE saleDate >= CURDATE() - INTERVAL 6 MONTH AND domain_type = "  + domainType +
                "GROUP BY DATE(saleDate)";
    }

    try {
        stmt = conn.createStatement();
        rs = stmt.executeQuery(query);

        List<String> data = new ArrayList<>();
        data.add("[\"Date\", \"Profit\"]"); // 헤더 추가

        while (rs.next()) {
            String saleDate = rs.getString("saleDate");
            double profit = rs.getDouble("profit");
            // 날짜와 이익을 배열 형식으로 추가
            data.add("[\"" + saleDate + "\", " + profit + "]");
        }

        // 배열 형식으로 데이터를 JSON 형태로 변환하여 출력
        String jsonResponse = String.join(",", data);
        out.print("[" + jsonResponse + "]");
    } catch (SQLException e) {
        e.printStackTrace();
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try {
            try { if (stmt != null) stmt.close(); } catch (Exception ignored) {}
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>
