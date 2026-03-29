<%@page import="com.mysql.cj.x.protobuf.MysqlxPrepare.Prepare"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ include file="sessionManager.jsp"%>
<%@ include file="DBconnection.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

String dbName = (session != null) ? (String) session.getAttribute("dbName") : null;
String domainType = (session != null) ? (String) session.getAttribute("domainType") : null;
String currentName = request.getParameter("medicineName");

if (currentName == null || currentName.trim().isEmpty()) {
    out.print("error:no_name");
    return;
}

PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    // 현재 약품의 순번 찾기
    String rankSql =
        "SELECT row_num, medicineName FROM ( " +
        "  SELECT ROW_NUMBER() OVER (ORDER BY medicineName) AS row_num, medicineName " +
        "  FROM testTable where domain_type = ? " +
        "  GROUP BY medicineName " +
        ") AS ranked WHERE medicineName = ?";

    pstmt = conn.prepareStatement(rankSql);
    pstmt.setString(1, domainType);
    pstmt.setString(2, currentName);
    rs = pstmt.executeQuery();

    if (rs.next()) {
        int currentRank = rs.getInt("row_num");

        // 이전 순번(=현재 - 1)의 약품명 조회
        String prevSql =
            "SELECT medicineName FROM ( " +
            "  SELECT ROW_NUMBER() OVER (ORDER BY medicineName) AS row_num, medicineName " +
            "  FROM testTable where domain_type = ?  " +
            "  GROUP BY medicineName " +
            ") AS ranked WHERE row_num = ?";

        pstmt.close();
        pstmt = conn.prepareStatement(prevSql);
        pstmt.setString(1, domainType);
        pstmt.setInt(2, currentRank - 1);
        ResultSet prevRs = pstmt.executeQuery();

        if (prevRs.next()) {
            out.print(prevRs.getString("medicineName"));
        } else {
            out.print("first"); // 첫 번째 약품일 경우
        }
        prevRs.close();
    } else {
        out.print("not_found");
    }
} catch (Exception e) {
    out.print("error:" + e.getMessage());
} finally {
    if (rs != null) try { rs.close(); } catch (SQLException e) {}
    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
}
%>
