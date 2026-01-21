<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.text.*"%>
<%
	request.setCharacterEncoding("UTF-8");
	String ID = request.getParameter("id");
	
	System.out.printf(ID);

    // DB 연결 정보 설정
    String jdbcDriver = "jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8";
    String dbUser = "root"; // DB 사용자명
    String dbPass = "pharmacy@1234"; // DB 비밀번호
    Connection conn = null;
    PreparedStatement pstmt = null;
    PreparedStatement pstmt2 = null;
    ResultSet rs = null;
    ResultSet rs2 = null;
    List<Map<String, String>> recordList = new ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPass);
        
        //전화번호를 검색했을 경우 데이터 가져오기
        if("selectPhone".equals(ID)){
        	String selectPhone = request.getParameter("selectPhone");
        	// 클라이언트 이름과 전화번호가 동시에 같은 값이 존재할 때 한 개만 가져오기
            String sql = "SELECT DISTINCT clientNumber, clientName FROM clientRecord WHERE clientNumber LIKE ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, "%" + selectPhone + "%");
            rs = pstmt.executeQuery();

            // 검색된 데이터를 리스트에 저장
            while (rs.next()) {
                Map<String, String> record = new HashMap<>();
                record.put("clientName", rs.getString("clientName"));
                record.put("clientNumber", rs.getString("clientNumber"));
                recordList.add(record);
            }
        }
        //이름을 검색했을 경우 데이터 가져오기
        if("selectName".equals(ID)){
        	String selectName = request.getParameter("selectName");
        	// 클라이언트 이름과 전화번호가 동시에 같은 값이 존재할 때 한 개만 가져오기
            String sql = "SELECT DISTINCT clientNumber, clientName FROM clientRecord WHERE clientName LIKE ?";
            pstmt2 = conn.prepareStatement(sql);
            pstmt2.setString(1, "%" + selectName + "%");
            rs2 = pstmt2.executeQuery();

            // 검색된 데이터를 리스트에 저장
            while (rs2.next()) {
                Map<String, String> record = new HashMap<>();
                record.put("clientName", rs2.getString("clientName"));
                record.put("clientNumber", rs2.getString("clientNumber"));
                recordList.add(record);
            }
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

    // 결과를 테이블 형식으로 출력
    if (!recordList.isEmpty()) {
%>

    	<span class="closePopup" style="font-size: 40px;float: right;border: 1px solid black;width: 145px;height: 60px;border-radius: 10px;text-align: center;"><b>닫기 X</b></span>
        <table>
            <thead>
                <tr>
                    <th>성함</th>
                    <th>전화번호</th>
                </tr>
            </thead>
            <tbody>
                <%
                    for (Map<String, String> record : recordList) {
                %>
                <tr>
                    <td><%= record.get("clientName") %></td>
                    <td><%= record.get("clientNumber") %></td>
                </tr>
                <%
                    }
                %>
            </tbody>
        </table>
		<script src="jquery-3.7.1.min.js"></script>
        <script>
			$(".closePopup").on("click", function(){
				$("#resultsContainer").hide();
			});
        </script>
<%
    } else {
%>
        <span class="closePopup" style="font-size: 40px;float: right;border: 1px solid black;width: 145px;height: 60px;border-radius: 10px;text-align: center;"><b>닫기 X</b></span>
        <table>
        	<tr>
        		<th>데이터가 존재하지 않습니다.</th>
        	</tr>
        </table>
        <script>
			$(".closePopup").on("click", function(){
				$("#resultsContainer").hide();
			});
        </script>
<%
    }
%>
