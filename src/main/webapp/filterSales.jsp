<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.text.*, java.util.*" %>
<%@ include file="sessionManager.jsp" %>
<%@ include file="DBconnection.jsp" %>

<%
String dbName = (session != null) ? (String) session.getAttribute("dbName") : null;
String id = (session != null) ? (String) session.getAttribute("id") : null;

String domainType = (session != null) ? (String) session.getAttribute("domainType") : null; if (id == null || dbName == null) {
    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
    return;
}

jdbcDriver = dbName;
request.setCharacterEncoding("UTF-8");

String filterValue = request.getParameter("filterValue");
int months = 1;

try {
    if (filterValue != null && !filterValue.trim().isEmpty()) {
        months = Integer.parseInt(filterValue);
    }
} catch (NumberFormatException e) {
    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
    return;
}

// 날짜 계산
SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

Calendar cal = Calendar.getInstance();
String rawEnd = sdf.format(cal.getTime());
cal.add(Calendar.MONTH, -months);
String rawStart = sdf.format(cal.getTime());

// 시간 포함된 시작일
String startDate = rawStart + " 00:00:00";

// endDate: 다음날 00:00:00
Calendar endCal = Calendar.getInstance();
endCal.setTime(sdf.parse(rawEnd));
endCal.add(Calendar.DATE, 1);
String endDate = sdf.format(endCal.getTime()) + " 23:59:59.999";


PreparedStatement pstmt = null;
ResultSet rs = null;
ResultSet detailRs = null;
ResultSet summaryRs = null;
PreparedStatement detailPstmt = null;
PreparedStatement summaryPstmt = null;

try {
    // 월별 목록 추출
    String monthSql = "SELECT DATE_FORMAT(saleDate, '%Y-%m') AS SalesMonth " +
                      "FROM SalesRecord  " +
                      "WHERE saleDate >= ? AND saleDate < ? " +
                      "GROUP BY SalesMonth ORDER BY SalesMonth DESC";
    pstmt = conn.prepareStatement(monthSql);
    pstmt.setString(1, startDate);
    pstmt.setString(2, endDate);
    rs = pstmt.executeQuery();

    while (rs.next()) {
        String currentMonth = rs.getString("SalesMonth");

        // 1. 해당 월의 상세 데이터
String detailSql =
    "SELECT " +
    " DATE(saleDate) AS SalesDate, " +

    " FORMAT(SUM(CAST(price AS DECIMAL)), 0) AS totalPrice, " +
    " FORMAT(SUM(CAST(Buyingprice AS DECIMAL)), 0) AS totalBuyingprice, " +

    " FORMAT(SUM(CAST(price AS DECIMAL)) - SUM(CAST(Buyingprice AS DECIMAL)), 0) AS margin, " +

    " CONCAT(ROUND( " +
    "   (SUM(CAST(price AS DECIMAL)) - SUM(CAST(Buyingprice AS DECIMAL))) / " +
    "   NULLIF(SUM(CAST(price AS DECIMAL)), 0) * 100 " +
    " , 2), '%') AS marginRate " +

    " FROM SalesRecord" +
    " WHERE DATE_FORMAT(saleDate, '%Y-%m') = ? AND domain_type = ? " +
    " GROUP BY DATE(saleDate) " +
    " ORDER BY DATE(saleDate) ASC";


        detailPstmt = conn.prepareStatement(detailSql);
        detailPstmt.setString(1, currentMonth);
        detailPstmt.setString(2, domainType);
        detailRs = detailPstmt.executeQuery();

        while (detailRs.next()) {
%>
<tr class="glanceSummary">
    <td><%= detailRs.getString("SalesDate") %></td>
    <td><%= detailRs.getString("totalPrice") %></td>
    <td><%= detailRs.getString("totalBuyingprice") %></td>
    <td><%= detailRs.getString("margin") %></td>
    <td><%= detailRs.getString("marginRate") %></td>
    <%-- <td style="display:none;"><%= detailRs.getString("baseDate") %></td> --%>
</tr>
<%
        }

        // 2. 해당 월의 합계
        String summarySql = "SELECT DATE_FORMAT(saleDate, '%Y-%m') AS SalesMonth, " +
            " FORMAT(SUM(CAST(price AS DECIMAL)), 0) AS totalPrice, " +
            " FORMAT(SUM(CAST(Buyingprice AS DECIMAL)), 0) AS totalBuyingprice, " +
            " FORMAT(SUM(CAST(price AS DECIMAL)) - SUM(CAST(Buyingprice AS DECIMAL)), 0) AS margin, " +
            " CONCAT(ROUND((SUM(CAST(price AS DECIMAL)) - SUM(CAST(Buyingprice AS DECIMAL))) / SUM(CAST(price AS DECIMAL)) * 100, 2), '%') AS marginRate " +
            " FROM SalesRecord " +
            " WHERE DATE_FORMAT(saleDate, '%Y-%m') = ? " +
            " GROUP BY SalesMonth";
        summaryPstmt = conn.prepareStatement(summarySql);
        summaryPstmt.setString(1, currentMonth);
        summaryPstmt.setString(2, domainType);
        summaryRs = summaryPstmt.executeQuery();

        if (summaryRs.next()) {
%>
<tr class="group-summary">
    <td><%= summaryRs.getString("SalesMonth") %> 합계</td>
    <td><%= summaryRs.getString("totalPrice") %></td>
    <td><%= summaryRs.getString("totalBuyingprice") %></td>
    <td><%= summaryRs.getString("margin") %></td>
    <td><%= summaryRs.getString("marginRate") %></td>
</tr>
<%
        }
        summaryRs.close();
        summaryPstmt.close();
    }

} catch (Exception e) {
    e.printStackTrace();
    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
} finally {
    try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
    try { if (rs != null) rs.close(); } catch (Exception ignored) {}
    try { if (detailRs != null) detailRs.close(); } catch (Exception ignored) {}
    try { if (summaryRs != null) summaryRs.close(); } catch (Exception ignored) {}
    try { if (detailPstmt != null) detailPstmt.close(); } catch (Exception ignored) {}
    try { if (summaryPstmt != null) summaryPstmt.close(); } catch (Exception ignored) {}
	if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
}
%>
