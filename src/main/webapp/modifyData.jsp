<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ include file="sessionManager.jsp"%>
<%@ include file="DBconnection.jsp"%>

<%
String dbName = (session != null) ? (String) session.getAttribute("dbName") : null;
String id = (session != null) ? (String) session.getAttribute("id") : null;
String password = (session != null) ? (String) session.getAttribute("password") : null;
String domainType = (session != null) ? (String) session.getAttribute("domainType") : null;

if (id == null || dbName == null) {
	response.sendRedirect("login.jsp");
	return;
}

jdbcDriver = dbName;

request.setCharacterEncoding("UTF-8");

String medicineName = request.getParameter("medicineName");

PreparedStatement ps = null;
ResultSet rs = null;

try {
	String sql = " SELECT *, format(inventory, 0) AS Inv, format(quantity, 0) AS Quant, format(buyingprice, 0) AS Buyingp, format(price, 0) AS Pr "
			   + " FROM testTable WHERE medicineName LIKE ? AND inventory > 0 AND returnInv = 0 AND domain_type = ? ";
	ps = conn.prepareStatement(sql);
	ps.setString(1, "%" + medicineName + "%");
	ps.setString(2, domainType);
	rs = ps.executeQuery();

	boolean hasData = false;

	while (rs.next()) {
		hasData = true;

		String serialNumber = rs.getString("SerialNumber");
		String medicineNames = rs.getString("medicineName");
		String inventory = rs.getString("Inv");
		String deliveryDate = rs.getString("DeliveryDate");
		String receiptDate = rs.getString("receiptDate");
		String kind = rs.getString("kind");
		String buyingPrice = rs.getString("Buyingp");
		String price = rs.getString("Pr");
		String companyName = rs.getString("companyName");
		String standard = rs.getString("standard");
		String quantity = rs.getString("Quant");
%>

<tr class='updateList'
    data-id='<%= rs.getInt("id") %>'>
	<td><input type="text" class="serialNumber" value="<%=serialNumber%>" readonly></td>
	<td><input type="text" class="medicineName" value="<%=medicineNames%>"></td>
	<td><input type="text" class="quantity" value="<%=quantity%>"></td>
	<td><input type="text" class="inventory" value="<%=inventory%>"></td>
	<td><input type="text" class="DeliveryDate" value="<%=deliveryDate%>"></td>
	<td><input type="text" class="receiptDate" value="<%=receiptDate%>"></td>

	<td>
		<select class="kindValue">
			<option value="건강기능식품" <%= "건강기능식품".equals(kind) ? "selected" : "" %>>건강기능식품</option>
			<option value="일반의약품" <%= "일반의약품".equals(kind) ? "selected" : "" %>>일반의약품</option>
			<option value="파스류" <%= "파스류".equals(kind) ? "selected" : "" %>>파스류</option>
			<option value="연고류" <%= "연고류".equals(kind) ? "selected" : "" %>>연고류</option>
			<option value="드링크류" <%= "드링크류".equals(kind) ? "selected" : "" %>>드링크류</option>
			<option value="비타민류" <%= "비타민류".equals(kind) ? "selected" : "" %>>비타민류</option>
			<option value="한약류" <%= "한약류".equals(kind) ? "selected" : "" %>>한약류</option>
			<option value="기타" <%= "기타".equals(kind) ? "selected" : "" %>>기타</option>
		</select>
	</td>

	<td><input type="text" class="buyingPrice" value="<%=buyingPrice%>"></td>
	<td><input type="text" class="price" value="<%=price%>"></td>
	<td><input type="text" class="companyName" value="<%=companyName%>"></td>
	<td><input type="text" class="standard" value="<%=standard%>"></td>

	<td>
		<button class="removeTR">🗑️</button>
	</td>
</tr>

<%
	}

	if (!hasData) {
%>
<tr>
	<td colspan="12">검색 결과가 없습니다</td>
</tr>
<%
	}

} catch (Exception e) {
	out.println("<tr><td colspan='12'>오류: " + e.getMessage() + "</td></tr>");
} finally {
	if (rs != null) try { rs.close(); } catch (Exception e) {}
	if (ps != null) try { ps.close(); } catch (Exception e) {}
	if (conn != null) try { conn.close(); } catch (Exception e) {}
}
%>