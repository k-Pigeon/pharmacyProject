<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%
String role = (String) session.getAttribute("role");

if ("admin".equals(role)) {
    out.print("admin");
} else {
    out.print("user");
}
%>
