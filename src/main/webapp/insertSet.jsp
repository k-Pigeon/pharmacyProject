<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ include file="sessionManager.jsp"%>
<%@ include file="DBconnection.jsp"%>
<%
request.setCharacterEncoding("UTF-8");

String dbName = (session != null) ? (String) session.getAttribute("dbName") : null;
String id = (session != null) ? (String) session.getAttribute("id") : null;
String password = (session != null) ? (String) session.getAttribute("password") : null;

String domainType = (session != null) ? (String) session.getAttribute("domainType") : null; 
if (id == null || dbName == null) {
    response.sendRedirect("login.jsp");
    return;
}

jdbcDriver = dbName;

// 파라미터 받기 (buyingPrice 대소문자 혼용 방지)
String setName = request.getParameter("setName");
String medicineName   = request.getParameter("medicineName");
String buyingPriceStr = request.getParameter("buyingPrice");
String standard = request.getParameter("standard");
if (buyingPriceStr == null) buyingPriceStr = request.getParameter("Buyingprice");
if (buyingPriceStr == null) buyingPriceStr = request.getParameter("buyingprice");

String priceStr = request.getParameter("price");
String invStr   = request.getParameter("inventory");
%>
<%!
// 쉼표 제거 헬퍼
String strip(String s) {
    return (s == null) ? "" : s.replaceAll(",", "").trim();
}
%>
<%
// 숫자 변환
int buyingPrice = 0;
int price = 0;
int inventory = 0;

try { buyingPrice = Integer.parseInt(strip(buyingPriceStr)); } catch (Exception ignore) {}
try { price = Integer.parseInt(strip(priceStr)); } catch (Exception ignore) {}
try { inventory = Integer.parseInt(strip(invStr)); } catch (Exception ignore) {}

PreparedStatement pstmt = null;
try {
    String sql = "INSERT INTO regularSet (setName, medicineName, Buyingprice, price, inventory, standard, domain_type) VALUES (?, ?, ?, ?, ?, ?, ?)";
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, setName);
    pstmt.setString(2, medicineName);
    pstmt.setInt(3, buyingPrice);
    pstmt.setInt(4, price);
    pstmt.setInt(5, inventory);
    pstmt.setString(6, standard);
    pstmt.setString(7, domainType);

    int result = pstmt.executeUpdate();
    out.print(result > 0 ? "success" : "fail");
} catch (Exception e) {
    e.printStackTrace();
    response.setStatus(500);
    out.print("fail");
} finally {
    if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
    if (conn != null) try { conn.close(); } catch (Exception e) {}
}
%>
