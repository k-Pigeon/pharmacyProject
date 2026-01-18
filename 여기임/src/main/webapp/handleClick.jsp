<%@ page import="java.sql.*, java.util.*"%>
<%@ page contentType="text/html; charset=UTF-8" language="java"%>
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
    String clickedDate = request.getParameter("date");

    PreparedStatement stmt = null;
    ResultSet rs = null;
    String lastSaleDate = "";

    try {
    	String salesSQL = "(SELECT saleDate, medicineName, " +
                "    CASE " +
                "        WHEN standard REGEXP 'ml|Ml|mL|ML|l|L' THEN inventory " +
                "        ELSE (inventory / standard) " +
                "    END AS realInv, " +
                "    price, DeliveryDate " +
                " FROM SalesRecord " +
                " WHERE DATE(saleDate) = ?) " +
                " UNION ALL " +
                " (SELECT saleDate, '총합' AS medicineName, " +
                "    NULL AS realInv, " +
                "    SUM(price * (CASE " +
                "        WHEN standard REGEXP 'ml|Ml|mL|ML|l|L' THEN inventory " +
                "        ELSE (inventory / standard) " +
                "    END)) AS price, " +
                "    NULL AS DeliveryDate " +
                " FROM SalesRecord " +
                " WHERE DATE(saleDate) = ? " +
                " GROUP BY saleDate) " +
                " ORDER BY saleDate";


        stmt = conn.prepareStatement(salesSQL);
        stmt.setString(1, clickedDate);
        stmt.setString(2, clickedDate);
        rs = stmt.executeQuery();

        boolean hasData = rs.next();

        if (hasData) {
            do {
                String currentSaleDate = rs.getString("saleDate");
                String medicineName = rs.getString("medicineName");
                String realInv = rs.getString("realInv");
                String price = rs.getString("price");
                String deliveryDate = rs.getString("DeliveryDate");

                // 새로운 날짜 그룹이 시작될 때 테이블 생성
                if (!currentSaleDate.equals(lastSaleDate)) {
                    if (!lastSaleDate.isEmpty()) {
                        out.println("</tbody></table>"); // 이전 테이블 닫기
                    }
                    lastSaleDate = currentSaleDate; // 새로운 날짜로 갱신
                    out.println("<h3>날짜: " + currentSaleDate + "</h3>");
                    out.println("<table border='1'>");
                    out.println("<thead><tr><th>제품명</th><th>개수</th><th>가격</th><th>유통기한</th></tr></thead>");
                    out.println("<tbody>");
                }

                // 데이터를 출력
                out.println("<tr>");
                if ("총합".equals(medicineName)) {
                    out.println("<td colspan='2'><strong>" + medicineName + "</strong></td>");
                    out.println("<td colspan='2' style='text-align:center;'><strong>" + (price != null ? price : "0") + "</strong></td>");
                } else {
                    out.println("<td>" + (medicineName != null ? medicineName : "") + "</td>");
                    out.println("<td>" + (realInv != null ? realInv : "") + "</td>");
                    out.println("<td>" + (price != null ? price : "0") + "</td>");
                    out.println("<td>" + (deliveryDate != null ? deliveryDate : "") + "</td>");
                }
                out.println("</tr>");
            } while (rs.next());

            // 마지막 테이블 닫기
            out.println("</tbody></table>");
        } else {
            out.println("<p>No records found for the selected date.</p>");
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
