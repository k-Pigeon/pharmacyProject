<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8" trimDirectiveWhitespaces="true"%>
<%
request.setCharacterEncoding("UTF-8");
HttpSession sessionObj = request.getSession();
String medicineName = request.getParameter("medicineName");

if (medicineName != null && !medicineName.trim().isEmpty()) {
    sessionObj.setAttribute("medicineName", medicineName.trim());
    out.print("ok");
} else {
    out.print("error:no_name");
}
%>
