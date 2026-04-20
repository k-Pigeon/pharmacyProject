<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ include file="sessionManager.jsp"%>
<%@ include file="DBconnection.jsp"%>

<%
response.setContentType("text/plain; charset=UTF-8");

String domainType = (session != null) ? (String) session.getAttribute("domainType") : null;

PreparedStatement ps = null;
ResultSet rs = null;

try {
    String sql = "SELECT inventory, quantity FROM testTable WHERE returnInv='0' domain_type = ? ";
    ps = conn.prepareStatement(sql);
    ps.setString(1, domainType);
    rs = ps.executeQuery();

    boolean warning = false;

    while(rs.next()){
        double inventory = rs.getDouble("inventory");
        double quantity  = rs.getDouble("quantity");

        if (quantity > inventory) {
            warning = true;
            break;
        }
    }

    out.print(warning ? "Y" : "N");

} catch(Exception e) {
    out.print("ERROR: " + e.getMessage());
} finally {
    try { if (rs != null) rs.close(); } catch(Exception e){}
    try { if (ps != null) ps.close(); } catch(Exception e){}
    try { if (conn != null) conn.close(); } catch(Exception e){}
}
%>
