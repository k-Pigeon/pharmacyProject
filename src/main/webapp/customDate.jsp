<%@ page import="java.sql.*, java.util.*, java.text.*" %>
<%@ page contentType="text/html; charset=UTF-8" %>
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
<%
    // UTF-8 설정
    request.setCharacterEncoding("UTF-8");

    // filterValue 파라미터 가져오기
    String customDateVal = request.getParameter("customDateVal");

    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        // SQL 쿼리
        String sql = " SELECT medicineName, price, quantity, ROUND((inventory / standard), 2) AS realInv, "
        		   + " companyName, standard, receiptDate, DeliveryDate, returnInv " 
                   + " FROM testTable"
           		   + " WHERE receiptDate = ? "
           		   + " and domain_type = ? "
                   + " ORDER BY DeliveryDate ASC, medicineName DESC";

        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, customDateVal); // 시작 날짜
        pstmt.setString(2, domainType);

        rs = pstmt.executeQuery();

        // 결과 출력
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
                    <td><%= rs.getString("quantity") %></td>
                    <td><%= rs.getString("realInv") %></td>
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
        if (rs != null) {
            try { rs.close(); } catch (Exception ignore) {}
        }
        if (pstmt != null) {
            try { pstmt.close(); } catch (Exception ignore) {}
        }
        if (conn != null) {
            try { conn.close(); } catch (Exception ignore) {}
        }
    }
%>
