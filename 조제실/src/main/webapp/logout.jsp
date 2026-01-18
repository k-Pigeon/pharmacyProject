<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, javax.servlet.http.*, javax.servlet.*"%>
<%
    // 현재 세션을 가져옵니다.
    HttpSession sessions = request.getSession(false);

    if (sessions != null) {
        // 세션에서 로그인 정보를 삭제합니다.
        sessions.removeAttribute("userId");

        // 세션을 무효화합니다.
        sessions.invalidate();
    }

    // 클라이언트에게 "success" 응답을 보냄
    response.setContentType("application/json");
    response.getWriter().write("{\"status\":\"success\"}");
%>
