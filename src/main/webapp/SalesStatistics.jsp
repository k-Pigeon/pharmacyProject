<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>
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

String domainType = (session != null) ? (String) session.getAttribute("domainType") : null; if (id == null || dbName == null) {
    response.sendRedirect("login.jsp");
    return;
}

jdbcDriver = dbName;
%>
<!DOCTYPE html>
<html>
<head>
    <title>Sales Profit Graph</title>
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
</head>
<body>
    <div id="chart_div" style="width: 900px; height: 500px;"></div>

    <script type="text/javascript">
        google.charts.load('current', {packages: ['corechart', 'line']});
        google.charts.setOnLoadCallback(drawChart);

        function drawChart() {
            var data = google.visualization.arrayToDataTable([
                ['Date', 'Profit'],
                <%-- Database connection parameters --%>
                <% 
                // Your Java code for database connection and retrieving sales records goes here
                // Make sure to properly close database connections and handle exceptions
                PreparedStatement stmt = null;
                ResultSet rs = null;
                try {
                	String query = "SELECT DATE(saleDate) AS saleDate, SUM((price - Buyingprice)) "
                            + "FROM SalesRecord WHERE domain_type = ? GROUP BY DATE(saleDate)";

               		stmt = conn.prepareStatement(query);
               		stmt.setString(1, domainType);

               		rs = stmt.executeQuery();

                    while (rs.next()) {
                        String saleDate = rs.getString("saleDate");
                        double profit = rs.getDouble("profit");
                        out.print("['" + saleDate + "', " + profit + "],");
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    try {
                        try { if (stmt != null) stmt.close(); } catch (Exception ignored) {}
                        try { if (rs != null) rs.close(); } catch (Exception ignored) {}
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                %>
                
            ]);
            var options = {
                title: 'Sales Profit Graph',
                hAxis: {
                    title: 'Date',
                    format: 'yyyy-MM-dd'
                },
                vAxis: {
                    title: 'Profit'
                },
                legend: { position: 'bottom' }
            };
            var chart = new google.visualization.LineChart(document.getElementById('chart_div'));
            chart.draw(data, options);
        }
    </script>
</body>
</html>