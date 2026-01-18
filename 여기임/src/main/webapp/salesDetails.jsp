<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ include file="sessionManager.jsp"%>
<%@ include file="DBconnection.jsp"%>
<%
String dbName = (session != null) ? (String) session.getAttribute("dbName") : null;
String id = (session != null) ? (String) session.getAttribute("id") : null;
String password = (session != null) ? (String) session.getAttribute("password") : null;

/* out.println(password);
out.println(dbName);
out.println(id);
out.println(password); */

if (id == null || dbName == null) {
    response.sendRedirect("login.jsp");
    return;
}

jdbcDriver = dbName;
%>
<%
String saleDate = request.getParameter("saleDate");
String clientName = request.getParameter("clientName");
String clientNumber = request.getParameter("clientNumber");

	PreparedStatement pstmt = null;
	ResultSet rs = null;
	PreparedStatement pstmt2 = null;
	ResultSet rs2 = null;
    PreparedStatement pstmt1 = null;
    ResultSet rs1 = null;
    List<Map<String, String>> salesList = new ArrayList<>();
    String salesMemo = ""; // memoInfo 값을 저장할 변수
    String clientMemo = ""; // memoInfo 값을 저장할 변수
    String allTotal = "";

    try {
        // saleDate에 따른 데이터 검색 쿼리
        String sql = " SELECT medicineName, Buyingprice, price, inventory, memoInfo, "
        		   + " (price * inventory) AS total "
        		   + " FROM SalesRecord WHERE saleDate = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, saleDate);
        rs = pstmt.executeQuery();
        
		String memoSQL = " select memoInfo from clientRecord "
					   + " where clientName = ? AND clientNumber = ?";
		pstmt1 = conn.prepareStatement(memoSQL);
		pstmt1.setString(1, clientName);
		pstmt1.setString(2, clientNumber);
		rs1 = pstmt1.executeQuery();
		
		String totalSQL = " SELECT  '총합계' AS medicineName, NULL AS Buyingprice, NULL AS price,  "
					    + " NULL AS inventory, NULL AS memoInfo, SUM(price * inventory) AS Alltotal  "   
		 			    + " FROM SalesRecord WHERE saleDate = ?";
        pstmt2 = conn.prepareStatement(totalSQL);
        pstmt2.setString(1, saleDate);
        rs2 = pstmt2.executeQuery();

        // 검색된 데이터를 리스트에 저장
        while (rs.next()) {
            Map<String, String> record = new HashMap<>();
            record.put("medicineName", rs.getString("medicineName"));
            record.put("Buyingprice", rs.getString("Buyingprice"));
            record.put("price", rs.getString("price"));
            record.put("total", rs.getString("total"));
            record.put("inventory", rs.getString("inventory"));
            record.put("total", rs.getString("total"));
            salesMemo = rs.getString("memoInfo"); // memoInfo 값을 가져옴
            salesList.add(record);
        }
        if(rs1.next()){
            clientMemo = rs1.getString("memoInfo");
        }
        if(rs2.next()){
        	allTotal = rs2.getString("Alltotal");
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // 결과를 테이블로 출력
    if (!salesList.isEmpty()) {
%>
        <table>
            <thead>
                <tr>
                    <th>의약품 이름</th>
                    <th>구매 가격</th>
                    <th>판매 단가</th>
                    <th>총 가격</th>
                    <th>수량</th>
                </tr>
            </thead>
            <tbody>
                <%
                    for (Map<String, String> record : salesList) {
                %>
                <tr>
                    <td><%= record.get("medicineName") %></td>
                    <td><%= record.get("Buyingprice") %></td>
                    <td><%= record.get("price") %></td>
                    <td><%= record.get("total") %></td>
                    <td><%= record.get("inventory") %></td>
                </tr>
                <%
                    }
                %>
                <tr>
                	<td colspan="2">총합계</td>
                	<td colspan="3">
                    	<%= allTotal %>
                	</td>
                </tr>
            </tbody>
        </table>
        
        <!-- 이미 존재하는 salesMemo 요소에 memoInfo 값 출력 -->
        <script>
        	document.querySelector("#wrap #flex_screen .rightScreen .salesMemo").textContent = "<%= salesMemo %>";
        	document.querySelector("#wrap #flex_screen .leftScreen .personalMemo").textContent = "<%= clientMemo %>";
        </script>
<%
    } else {
        out.print("fail"); // 데이터가 없을 경우
    }
%>
