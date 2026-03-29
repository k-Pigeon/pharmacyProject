<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, org.json.*, java.io.*, java.util.regex.*" %>
<%@ include file="sessionManager.jsp" %>
<%@ include file="DBconnection.jsp" %>
<%!
double getStandardFactor(String standard) {
    if (standard == null || standard.trim().isEmpty()) return 1.0;

    Matcher m = Pattern.compile("\\d+(\\.\\d+)?").matcher(standard);
    double result = 1.0;

    boolean found = false;

    while (m.find()) {
        found = true;
        result *= Double.parseDouble(m.group());
    }

    return found ? result : 1.0;
}
%>
<%
String dbName = (String) session.getAttribute("dbName");
String id = (String) session.getAttribute("id");
String domainType = (session != null) ? (String) session.getAttribute("domainType") : null;

if (id == null || dbName == null) return;

jdbcDriver = dbName;

String medicineName = request.getParameter("medicineName");

PreparedStatement pstmt = null;
ResultSet rs = null;
double factor = 0.0;
double inventoryVal = 0.0;

try {
    String sql = 
        "SELECT SerialNumber, medicineName, inventory, DeliveryDate, receiptDate, kind,"
    + " format(Buyingprice,0) realBuying, format(price,0) realP, companyName, standard, quantity " +
        "FROM testTable  WHERE medicineName = ? AND domain_type = ?"
     + " order by medicineName asc";
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, medicineName);
    pstmt.setString(2, domainType);
    rs = pstmt.executeQuery();

    while (rs.next()) {

%>

<tr class="leftEditRow">
    <td><input type="text" class="SerialNumber" value="<%= rs.getString("SerialNumber") %>" readonly></td>
    <td><input type="text" class="medicineName" value="<%= rs.getString("medicineName") %>"></td>
    <td><input type="text" class="Buyingprice" value="<%= rs.getString("realBuying") %>"></td>
    <td><input type="text" class="price" value="<%= rs.getString("realP") %>"></td>
    <td><input type="text" class="quantity" value="<%= rs.getString("quantity") %>"></td>
    <td><input type="text" class="inventory" value="<%= rs.getString("inventory") %>"></td>
    <td><input type="text" class="DeliveryDate" value="<%= rs.getString("DeliveryDate") %>"></td>
    <td><input type="text" class="receiptDate" value="<%= rs.getString("receiptDate") %>"></td>

    <td>
        <select class="kind">
            <option value="건강기능식품" <%= "건강기능식품".equals(rs.getString("kind")) ? "selected" : "" %>>건강기능식품</option>
            <option value="일반의약품" <%= "일반의약품".equals(rs.getString("kind")) ? "selected" : "" %>>일반의약품</option>
            <option value="파스류" <%= "파스류".equals(rs.getString("kind")) ? "selected" : "" %>>파스류</option>
            <option value="연고류" <%= "연고류".equals(rs.getString("kind")) ? "selected" : "" %>>연고류</option>
            <option value="드링크류" <%= "드링크류".equals(rs.getString("kind")) ? "selected" : "" %>>드링크류</option>
            <option value="비타민류" <%= "비타민류".equals(rs.getString("kind")) ? "selected" : "" %>>비타민류</option>
            <option value="한약류" <%= "한약류".equals(rs.getString("kind")) ? "selected" : "" %>>한약류</option>
            <option value="기타" <%= "기타".equals(rs.getString("kind")) ? "selected" : "" %>>기타</option>
        </select>
    </td>
    <td><input type="text" class="companyName" value="<%= rs.getString("companyName") %>"></td>
    <td><input type="text" class="standard" value="<%= rs.getString("standard") %>"></td>
</tr>
<%
    }
} catch (Exception e) {
    out.print("<tr><td colspan='10'>오류: " + e.getMessage() + "</td></tr>");
} finally {
    try { if (pstmt != null) pstmt.close(); } catch (Exception ignored) {}
    try { if (rs != null) rs.close(); } catch (Exception ignored) {}
    try { if (conn != null) conn.close(); } catch (Exception ignored) {}
}
%>
