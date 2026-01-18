<%@ page import="java.sql.*, java.util.*, java.text.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%
    request.setCharacterEncoding("UTF-8");

    String filterValue = request.getParameter("filterValue");

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        String jdbcDriver = "jdbc:mysql://localhost:3306/tutorial2?useUnicode=true&characterEncoding=utf8";
        String dbUser = "root";
        String dbPwd = "pharmacy@1234";

        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPwd);

        String sql = "";
        boolean isExpired = "expired".equals(filterValue);

        if (isExpired) {
            // ✅ 유통기한이 지난 제품만 조회
            sql = "SELECT medicineName, price, inventory, wholesaler, companyName, standard, receiptDate, DeliveryDate, returnInv " +
                  "FROM testTable WHERE STR_TO_DATE(DeliveryDate, '%Y-%m-%d') < CURDATE() "
                  + " AND inventory > 0 "
            	+ " ORDER BY DeliveryDate ASC";
            pstmt = conn.prepareStatement(sql);
        } else {
            // ✅ 기본: 오늘부터 N개월 이내 조회
            int months = 1; // 기본값
            try {
                months = Integer.parseInt(filterValue);
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Invalid filter value");
                return;
            }

            Calendar cal = Calendar.getInstance();
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            String today = sdf.format(cal.getTime());
            cal.add(Calendar.MONTH, months);
            String endDate = sdf.format(cal.getTime());

            sql = "SELECT medicineName, price, inventory, wholesaler, companyName, standard, receiptDate, DeliveryDate, returnInv " +
                  "FROM testTable WHERE STR_TO_DATE(DeliveryDate, '%Y-%m-%d') BETWEEN ? AND ? ORDER BY DeliveryDate ASC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, today);
            pstmt.setString(2, endDate);
        }

        rs = pstmt.executeQuery();

        while (rs.next()) {
%>
<tr>
    <td><button>▼</button></td>
    <td>
        <button type="button" class="updateInfo">수정</button>
        <button class="deleteInfo">삭제</button>
    </td>
    <td><%= rs.getString("medicineName") %></td>
    <td><%= rs.getString("DeliveryDate") %></td>
    <td><%= rs.getString("wholesaler") %></td>
    <td><%= rs.getString("inventory") %></td>
    <td><%= rs.getString("standard") %></td>
    <td><%= rs.getString("price") %></td>
    <td><%= rs.getString("companyName") %></td>
    <td><%= rs.getString("receiptDate") %></td>
    <td>
        <input type="button" value="<%= rs.getInt("returnInv") == 1 ? "반품됨" : "반품하기" %>">
    </td>
</tr>
<%
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        response.getWriter().write("Server error: " + e.getMessage());
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
        if (conn != null) try { conn.close(); } catch (SQLException e) {}
    }
%>
