<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.json.*" %>
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

BufferedReader reader = request.getReader();
StringBuilder sb = new StringBuilder();
String line;

while ((line = reader.readLine()) != null) {
    sb.append(line);
}

JSONObject json = new JSONObject(sb.toString());
JSONArray arr = json.getJSONArray("customerNumbers");

PreparedStatement pstmt = null;

conn.setAutoCommit(false); // 🔥 핵심

try {

    if(arr.length() < 2){
        throw new Exception("최소 2개 필요");
    }

    // 1️⃣ 대표값
    String master = arr.getString(0);

    // 2️⃣ 나머지 (삭제 대상)
    List<String> targets = new ArrayList<>();
    for(int i=1; i<arr.length(); i++){
        targets.add(arr.getString(i));
    }

    // 3️⃣ salesdata 업데이트
    StringBuilder updateSql = new StringBuilder(
        "UPDATE salesdata SET customer_id=? WHERE customer_id IN ("
    );

    for(int i=0;i<targets.size();i++){
        updateSql.append("?");
        if(i < targets.size()-1) updateSql.append(",");
    }
    updateSql.append(")");

    PreparedStatement ps1 = conn.prepareStatement(updateSql.toString());

    ps1.setString(1, master);
    for(int i=0;i<targets.size();i++){
        ps1.setString(i+2, targets.get(i));
    }

    ps1.executeUpdate();

    // 4️⃣ members 삭제
    StringBuilder deleteSql = new StringBuilder(
        "DELETE FROM members WHERE customerNumber IN ("
    );

    for(int i=0;i<targets.size();i++){
        deleteSql.append("?");
        if(i < targets.size()-1) deleteSql.append(",");
    }
    deleteSql.append(")");

    PreparedStatement ps2 = conn.prepareStatement(deleteSql.toString());

    for(int i=0;i<targets.size();i++){
        ps2.setString(i+1, targets.get(i));
    }

    ps2.executeUpdate();

    conn.commit(); // 🔥 성공 시 확정

    out.print("{\"success\":true}");

} catch(Exception e){
    conn.rollback(); // 🔥 실패 시 복구
    out.print("{\"success\":false}");
    e.printStackTrace();
}
%>