<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.io.*"%>

<!DOCTYPE html>
<html>
<head>
<title>Sales Profit Graph</title>
<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
</head>
<body>
	<div id="wrap">
		<header>
			<jsp:include page="header.jsp"></jsp:include>
		</header>
		<div id="chart_div" style="width: 900px; height: 500px; margin: 0 auto; transform: translateY(10%); background-color: rgba(127, 127, 127, 0.2);"></div>
	</div>

	<script type="text/javascript">
        google.charts.load('current', {packages: ['corechart', 'line']});
        google.charts.setOnLoadCallback(drawChart);

        function drawChart() {
            var data = google.visualization.arrayToDataTable([
                ['Date', 'Profit'],
                <%-- Database connection parameters --%>
                <%// Your Java code for database connection and retrieving sales records goes here
// Make sure to properly close database connections and handle exceptions
Connection conn = null;
Statement stmt = null;
ResultSet rs = null;
try {
	Class.forName("com.mysql.cj.jdbc.Driver");

	String jdbcDriver = "jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8";
	String dbUser = "root";
	String dbPwd = "pharmacy@1234";

	conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPwd);
	stmt = conn.createStatement();
	String query = "SELECT DATE(saleDate) AS saleDate, SUM((price - Buyingprice) * inventory) AS profit FROM SalesRecord GROUP BY DATE(saleDate)";
	rs = stmt.executeQuery(query);

	while (rs.next()) {
		String saleDate = rs.getString("saleDate");
		double profit = rs.getDouble("profit");
		out.print("['" + saleDate + "', " + profit + "],");
	}
} catch (SQLException e) {
	e.printStackTrace();
} catch (ClassNotFoundException e) {
	e.printStackTrace();
} finally {
	try {
		if (rs != null)
			rs.close();
		if (stmt != null)
			stmt.close();
		if (conn != null)
			conn.close();
	} catch (SQLException e) {
		e.printStackTrace();
	}
}%>
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
