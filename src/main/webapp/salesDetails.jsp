<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%
String saleDate = request.getParameter("saleDate");
String clientName = request.getParameter("clientName");
String clientNumber = request.getParameter("clientNumber");

    // DB 연결 설정
    String jdbcDriver = "jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8";
    String dbUser = "root"; // DB 사용자명
    String dbPass = "pharmacy@1234"; // DB 비밀번호
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    PreparedStatement pstmt1 = null;
    ResultSet rs1 = null;
    List<Map<String, String>> salesList = new ArrayList<>();
    String salesMemo = ""; // memoInfo 값을 저장할 변수
    String clientMemo = ""; // memoInfo 값을 저장할 변수

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPass);

        // saleDate에 따른 데이터 검색 쿼리
        String sql = "SELECT * FROM SalesRecord WHERE saleDate = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, saleDate);
        rs = pstmt.executeQuery();
        
		String memoSQL = " select memoInfo from clientRecord "
					   + " where clientName = ? AND clientNumber = ?";
		pstmt1 = conn.prepareStatement(memoSQL);
		pstmt1.setString(1, clientName);
		pstmt1.setString(2, clientNumber);
		rs1 = pstmt1.executeQuery();

        // 검색된 데이터를 리스트에 저장
        while (rs.next()) {
            Map<String, String> record = new HashMap<>();
            record.put("medicineName", rs.getString("medicineName"));
            record.put("Buyingprice", rs.getString("Buyingprice"));
            record.put("price", rs.getString("price"));
            record.put("inventory", rs.getString("inventory"));
            salesMemo = rs.getString("memoInfo"); // memoInfo 값을 가져옴
            salesList.add(record);
        }
        if(rs1.next()){
            clientMemo = rs1.getString("memoInfo");
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
                    <th>판매 가격</th>
                    <th>재고</th>
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
                    <td><%= record.get("inventory") %></td>
                </tr>
                <%
                    }
                %>
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
