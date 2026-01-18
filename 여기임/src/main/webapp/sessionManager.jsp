<%-- <%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="javax.servlet.http.*, javax.servlet.*" %>
<%@ page import="java.sql.*"%>
<%
    // 세션 객체만 가져오기, 변수는 선언하지 않음
    session = request.getSession(false);
    if (session == null) {
        session = request.getSession(true); // 세션이 없다면 새로 생성
    }
%>
 --%>