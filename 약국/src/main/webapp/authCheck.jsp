<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
String role = (String) session.getAttribute("role");

// 세션 role이 없거나 관리자("D")가 아니라면 차단
if (role == null || !"D".equals(role)) {
    response.sendRedirect("accessDenied.jsp");
}
%>
