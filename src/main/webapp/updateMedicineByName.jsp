<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, org.json.*" %>
<%@ include file="sessionManager.jsp" %>
<%@ include file="DBconnection.jsp" %>

<%
String dbName = (session != null) ? (String) session.getAttribute("dbName") : null;
String id = (session != null) ? (String) session.getAttribute("id") : null;
String domainType = (session != null) ? (String) session.getAttribute("domainType") : null;

if (id == null || dbName == null) {
    response.sendRedirect("login.jsp");
    return;
}

request.setCharacterEncoding("UTF-8");
String medicineName = request.getParameter("medicineName");

PreparedStatement pstmt = null;
ResultSet rs = null;

try {
	String keyword = request.getParameter("medicineName");

	// 1) 완전 일치 검색 먼저
	String sqlExact = 
	    "SELECT SerialNumber, medicineName, Buyingprice, price, inventory, kind, standard, receiptDate, DeliveryDate " +
	    "FROM testTable WHERE medicineName like ? AND domain_type = ? " 
	    + " ORDER BY receiptDate DESC";

	PreparedStatement ps = conn.prepareStatement(sqlExact);
	ps.setString(1, "%" + keyword + "%");
	ps.setString(2, domainType);
	rs = ps.executeQuery();

	JSONArray items = new JSONArray();

	while (rs.next()) {
	    JSONObject o = new JSONObject();
	    o.put("SerialNumber", rs.getString("SerialNumber"));
	    o.put("medicineName", rs.getString("medicineName"));
	    o.put("Buyingprice", rs.getDouble("Buyingprice"));
	    o.put("price", rs.getDouble("price"));
	    o.put("inventory", rs.getDouble("inventory"));
	    o.put("kind", rs.getString("kind"));
	    o.put("standard", rs.getString("standard"));
	    o.put("receiptDate", rs.getString("receiptDate"));
	    o.put("DeliveryDate", rs.getString("DeliveryDate"));
	    items.put(o);
	}

	rs.close();
	ps.close();

	// 2) 완전일치 검색 결과가 있을 때
	if (items.length() > 0) {
	    if (items.length() == 1) out.print(items.getJSONObject(0));
	    else {
	        JSONObject result = new JSONObject();
	        result.put("items", items);
	        result.put("rowCount", items.length());
	        out.print(result);
	    }
	    conn.close();
	    return;
	}

	// 3) 없음 → LIKE 검색
	String sqlLike =
	    "SELECT SerialNumber, medicineName, Buyingprice, price, inventory, kind, standard, receiptDate, DeliveryDate " +
	    "FROM testTable WHERE medicineName LIKE ? AND domain_type = ? "
	    + " ORDER BY receiptDate DESC";

	ps = conn.prepareStatement(sqlLike);
	ps.setString(1, "%" + keyword + "%");
	ps.setString(2, domainType);
	rs = ps.executeQuery();

	items = new JSONArray();

	while (rs.next()) {
	    JSONObject o = new JSONObject();
	    o.put("SerialNumber", rs.getString("SerialNumber"));
	    o.put("medicineName", rs.getString("medicineName"));
	    o.put("Buyingprice", rs.getDouble("Buyingprice"));
	    o.put("price", rs.getDouble("price"));
	    o.put("inventory", rs.getDouble("inventory"));
	    o.put("kind", rs.getString("kind"));
	    o.put("standard", rs.getString("standard"));
	    o.put("receiptDate", rs.getString("receiptDate"));
	    o.put("DeliveryDate", rs.getString("DeliveryDate"));
	    items.put(o);
	}

} catch (Exception e) {
    e.printStackTrace();
} finally {
    if (rs != null) try { rs.close(); } catch (Exception e) {}
    if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
    if (conn != null) try { conn.close(); } catch (Exception e) {}
}
%>
