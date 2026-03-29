<%@ page import="java.sql.*, org.json.*"%>
<%@ include file="DBconnection.jsp"%>
<%
String dbName = (session != null) ? (String) session.getAttribute("dbName") : null;
String id = (session != null) ? (String) session.getAttribute("id") : null;
String password = (session != null) ? (String) session.getAttribute("password") : null;

/* out.println(password);
out.println(dbName);
out.println(id);
out.println(password); */

String domainType = (session != null) ? (String) session.getAttribute("domainType") : null;
if (id == null || dbName == null) {
	response.sendRedirect("login.jsp");
	return;
}

jdbcDriver = dbName;

request.setCharacterEncoding("UTF-8");
String medicineName = request.getParameter("medicineName");

JSONObject obj = new JSONObject();
PreparedStatement ps = null;
ResultSet rs = null;
try {
    ps = conn.prepareStatement(
        "SELECT inventory, standard FROM testTable " +
        " WHERE medicineName=? AND returnInv='0' LIMIT 1 AND domain_type = ? "
    );
    ps.setString(1, medicineName);
    ps.setString(2, domainType);

    rs = ps.executeQuery();
    if (rs.next()) {
        obj.put("inventory", rs.getDouble("inventory"));
        obj.put("standard", rs.getString("standard"));
    } else {
        obj.put("inventory", 0);
        obj.put("standard", "1");
    }
} catch (Exception e) {
    obj.put("error", e.getMessage());
}finally{
	try{ if(ps != null) ps.close(); } catch(Exception ignore) {}
	try{ if(rs != null) rs.close(); } catch(Exception ignore) {}
	try{ if(conn != null) conn.close(); } catch(Exception ignore) {}
}

out.print(obj.toString());
%>

