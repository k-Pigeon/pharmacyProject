<%@page import="com.mysql.cj.x.protobuf.MysqlxPrepare.Prepare"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ include file="sessionManager.jsp"%>
<%@ include file="DBconnection.jsp"%>
<%
String dbName = (session != null) ? (String) session.getAttribute("dbName") : null;
String id = (session != null) ? (String) session.getAttribute("id") : null;
String password = (session != null) ? (String) session.getAttribute("password") : null;

String idSortation = (session != null) ? (String) session.getAttribute("idSortation") : null; if (id == null || dbName == null) {
	response.sendRedirect("login.jsp");
	return;
}

jdbcDriver = dbName;

request.setCharacterEncoding("UTF-8");

    request.setCharacterEncoding("UTF-8");
    String memberName = request.getParameter("memberName");
    String memberPhone = request.getParameter("memberPhone");
    String custnumber = request.getParameter("custnumber"); // 사용 안 할 수도 있음
    String memo = request.getParameter("memo");

    System.out.println(memberName + memberPhone);

    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        // 1. memberName과 memberPhone으로 검색
        String selectSql = "SELECT id, customerNumber FROM members WHERE memberName = ? AND memberPhone = ?";
        pstmt = conn.prepareStatement(selectSql);
        pstmt.setString(1, memberName);
        pstmt.setString(2, memberPhone);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            // 기존 고객이 있음 → memoInfo 업데이트
            int existingId = rs.getInt("id");
            pstmt.close();

            String updateSql = "UPDATE members SET memoInfo = ? WHERE id = ?";
            pstmt = conn.prepareStatement(updateSql);
            pstmt.setString(1, memo);
            pstmt.setInt(2, existingId);
            pstmt.executeUpdate();
        } else {
            // 기존 고객 없음 → 새로 삽입
            pstmt.close();
            rs.close();

            // 가장 큰 id 및 customerNumber 찾기
            String maxSql = "SELECT MAX(id) AS maxId, MAX(customerNumber) AS maxCustNum FROM members";
            pstmt = conn.prepareStatement(maxSql);
            rs = pstmt.executeQuery();

            int newId = 1;
            int newCustomerNumber = 1;
            if (rs.next()) {
                newId = rs.getInt("maxId") + 1;
                newCustomerNumber = rs.getInt("maxCustNum") + 1;
            }

            pstmt.close();

            // 새로운 고객 정보 삽입
            String insertSql = "INSERT INTO members (id, memberName, memberPhone, customerNumber, memoInfo, gender, jumin1, jumin2) VALUES (?, ?, ?, ?, ?, 1, NULL, NULL)";
            pstmt = conn.prepareStatement(insertSql);
            pstmt.setInt(1, newId);
            pstmt.setString(2, memberName);
            pstmt.setString(3, memberPhone);
            pstmt.setInt(4, newCustomerNumber);
            pstmt.setString(5, memo);
            pstmt.executeUpdate();
        }

        out.print("success");

    } catch (Exception e) {
        e.printStackTrace();
        out.print("error");
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
    }
%>
<%@ include file="DBclose.jsp" %>