<%@ page contentType="application/json; charset=UTF-8" %>
<%@ page import="java.sql.*, java.io.*, org.json.*" %>
<%@ page import="java.util.Date" %>
<%@ include file="sessionManager.jsp" %>
<%@ include file="DBconnection.jsp" %>
<%!
private String formatDate(String input) {
    if (input == null || input.trim().isEmpty()) return null;

    input = input.trim();

    try {
        // yyyy-MM-dd
        if (input.matches("\\d{4}-\\d{2}-\\d{2}")) {
            return input;
        }

        // yyyy/MM/dd
        if (input.matches("\\d{4}/\\d{2}/\\d{2}")) {
            return input.replace("/", "-");
        }

        // yy/MM/dd → 20yy-MM-dd
        if (input.matches("\\d{2}/\\d{2}/\\d{2}")) {
            String[] p = input.split("/");
            return "20" + p[0] + "-" + p[1] + "-" + p[2];
        }

        return null;

    } catch (Exception e) {
        return null;
    }
}
%>
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

// JSON 읽기
StringBuilder sb = new StringBuilder();
BufferedReader reader = request.getReader();
String line;

while((line = reader.readLine()) != null){
    sb.append(line);
}

JSONArray arr = new JSONArray(sb.toString());

PreparedStatement pstmt = null;

try {

    conn.setAutoCommit(false); // 트랜잭션 시작

    for(int i=0; i<arr.length(); i++){

        JSONObject obj = arr.getJSONObject(i);

        boolean hasId = obj.has("id") && !obj.isNull("id");
        boolean isDelete = obj.getBoolean("delete");

        // ✅ DELETE
        if(hasId && isDelete){

            String sql = "DELETE FROM testTable WHERE id=?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, obj.getInt("id"));
            pstmt.executeUpdate();

            continue;
        }

        // ✅ UPDATE
        if(hasId){

        	String sql = "UPDATE testTable SET " +
        		    "SerialNumber=?, medicineName=?, quantity=?, inventory=?, DeliveryDate=?, receiptDate=?, " +
        		    "kind=?, Buyingprice=?, price=?, companyName=?, standard=?, returnInv=? " +
        		    "WHERE id=? AND domain_type=?";
            pstmt = conn.prepareStatement(sql);

            pstmt.setString(1, obj.getString("serialNumber"));
            pstmt.setString(2, obj.getString("medicineName"));
            pstmt.setDouble(3, Double.parseDouble(obj.getString("quantity")));
            pstmt.setDouble(4, Double.parseDouble(obj.getString("inventory")));
            String rawDate = obj.getString("deliveryDate");
            String formattedDate = formatDate(rawDate);

            if (formattedDate != null) {
                pstmt.setDate(5, java.sql.Date.valueOf(formattedDate));
            } else {
                pstmt.setNull(5, java.sql.Types.DATE);
            }
            pstmt.setString(6, obj.getString("receiptDate"));
            pstmt.setString(7, obj.getString("kind"));
            pstmt.setString(8, obj.getString("buyingPrice"));
            pstmt.setString(9, obj.getString("price"));
            pstmt.setString(10, obj.getString("companyName"));
            pstmt.setString(11, obj.getString("standard"));
            pstmt.setString(12, "0"); // returnInv

            pstmt.setInt(13, obj.getInt("id"));
            pstmt.setString(14, domainType);

            pstmt.executeUpdate();

            pstmt.executeUpdate();

        } else {
        // ✅ INSERT

        	String sql = "INSERT INTO testTable (" +
        		    "SerialNumber, medicineName, quantity, inventory, DeliveryDate, receiptDate, " +
        		    "kind, Buyingprice, price, companyName, standard, domain_type, returnInv" +
        		") VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        		pstmt = conn.prepareStatement(sql);

        		pstmt.setString(1, obj.getString("serialNumber"));
        		pstmt.setString(2, obj.getString("medicineName"));
        		pstmt.setDouble(3, Double.parseDouble(obj.getString("quantity")));
        		pstmt.setDouble(4, Double.parseDouble(obj.getString("inventory")));
        		String rawDate = obj.getString("deliveryDate");
        		String formattedDate = formatDate(rawDate);

        		if (formattedDate != null) {
        		    pstmt.setDate(5, java.sql.Date.valueOf(formattedDate));
        		} else {
        		    pstmt.setNull(5, java.sql.Types.DATE);
        		}
        		pstmt.setString(6, obj.getString("receiptDate"));
        		pstmt.setString(7, obj.getString("kind"));
        		pstmt.setString(8, obj.getString("buyingPrice"));
        		pstmt.setString(9, obj.getString("price"));
        		pstmt.setString(10, obj.getString("companyName"));
        		pstmt.setString(11, obj.getString("standard"));
        		pstmt.setString(12, domainType);
        		pstmt.setString(13, "0");
        }
        
        pstmt.executeUpdate();
    }

    conn.commit(); // 성공

    out.print("{\"success\": true}");

} catch(Exception e){
    conn.rollback(); // 실패 시 롤백
    e.printStackTrace();
    out.print("{\"success\": false}");
} finally {
    try { if (pstmt != null) pstmt.close(); } catch(Exception ignored){}
}
%>
