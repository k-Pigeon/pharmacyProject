<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%
    String saleDate = request.getParameter("saleDate");
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        String jdbcDriver = "jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8";
        String dbUser = "root";
        String dbPwd = "pharmacy@1234";
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPwd);

        String sql = " SELECT a.saleDate saleDate, a.medicineName medicineName, a.inventory inventory, "
        		   + " format(b.maxmedicinePrice, 0) AS maxmedicinePrice, format(b.generalPrice, 0) AS generalPrice, "
        		   + " format((B.maxmedicinePrice + B.generalPrice), 0) AS totalPrice "
        		   + " FROM SalesRecord A "
                   + " JOIN priceRecord B ON A.saleDate = B.saleDate"
        		   + " WHERE a.saleDate = b.saleDate "
        		   + " and a.saleDate = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, saleDate);
        rs = pstmt.executeQuery();

        boolean hasRecords = false;
%>
<table class="table_line" style="text-align:center;border:1px solid black;width: calc(95%);margin:0 auto;">
	<colgroup>
		<col width="30%">
		<col width="10%">
		<col width="20%">
		<col width="20%">
		<col width="20%">
	</colgroup>
    <thead>
        <tr>
            <th>제품이름</th>
            <th>개수</th>
            <th>조제의약품</th>
            <th>일반의약품</th>
            <th>총합계</th>
        </tr>
    </thead>
    <tbody>
<%
        while (rs.next()) {
            hasRecords = true;
%>
        <tr>
            <td><%=rs.getString("medicineName")%></td>
            <td><%=rs.getString("inventory")%></td>
            <td><%=rs.getString("maxmedicinePrice")%></td>
            <td><%=rs.getString("generalPrice")%></td>
            <td><%=rs.getString("totalPrice")%></td>
        </tr>
<%
        }

        if (!hasRecords) {
%>
        <tr>
            <td colspan="3">해당 날짜에 대한 기록이 없습니다.</td>
        </tr>
<%
        }
%>
    </tbody>
</table>
<%
    } catch (SQLException se) {
        se.printStackTrace();
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ignore) {}
        if (conn != null) try { conn.close(); } catch (SQLException ignore) {}
    }
%>
