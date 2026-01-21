<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.text.*"%>
<%
    String clientName = request.getParameter("clientName");
    String clientNumber = request.getParameter("clientNumber");

    // DB 연결 정보 설정
    String jdbcDriver = "jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8";
    String dbUser = "root"; // DB 사용자명
    String dbPass = "pharmacy@1234"; // DB 비밀번호
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    List<Map<String, String>> detailsList = new ArrayList<>();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPass);
        
        // 고객 상세 정보를 검색하는 쿼리
        String sql = "SELECT * FROM clientRecord WHERE clientName = ? AND clientNumber = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, clientName);
        pstmt.setString(2, clientNumber);
        rs = pstmt.executeQuery();

        // 검색된 데이터를 리스트에 저장
        while (rs.next()) {
            Map<String, String> record = new HashMap<>();
            record.put("clientName", rs.getString("clientName"));
            record.put("clientNumber", rs.getString("clientNumber"));
            record.put("saleDate", rs.getString("saleDate")); // 다른 데이터가 필요할 경우 추가
            detailsList.add(record);
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
    if (!detailsList.isEmpty()) {
%>
        <table style="display: block;width: 100%;height: 40vh;overflow-y: scroll;border: 1px solid;">
        	<colgroup>
        		<col style="width:25%">
        		<col style="width:25%">
        		<col style="width:25%">
        		<col style="width:25%">
        	</colgroup>
            <thead>
                <tr>
                    <th>성함</th>
                    <th>전화번호</th>
                    <th>판매 날짜</th>
                    <th>수정 / 삭제</th>
                </tr>
            </thead>
            <tbody>
                <%
                    for (Map<String, String> record : detailsList) {
                %>
                <tr>
                    <td><%= record.get("clientName") %></td>
                    <td><%= record.get("clientNumber") %></td>
                    <td><%= record.get("saleDate") %></td> <!-- 추가 데이터 -->
                    <td><button class="updateBtn">수정</button><button class="deleteBtn">삭제</button></td>
                </tr>
                <%
                    }
                %>
            </tbody>
        </table>
<%
    } else {
        out.print(""); // 데이터가 없을 경우
    }
%>
<script src="jquery-3.7.1.min.js"></script>
<script>
$(".updateBtn").on("click", function(event) {
    event.preventDefault();
    
    var row = $(this).closest("tr");
    var timeToset = row.find("td:eq(2)").text();

    if (confirm("해당 날짜의 데이터를 수정하시겠습니까?")) {
        $.ajax({
            url: 'checkSaleDate.jsp',
            type: 'POST',
            data: { saleDate: timeToset },
            success: function(response) {
                if(response.trim() === "deleted") {
                    alert("해당 날짜의 데이터를 수정합니다.");
                } else {
                    alert("해당 날짜에 데이터가 없습니다.");
                }
            },
            error: function(xhr, status, error) {
                console.error('Error:', error);
            }
        });
    } else {
        alert("수정 취소되었습니다.");
    }
});




$(".deleteBtn").on("click", function(event){
    event.preventDefault();
    
    var row = $(this).closest("tr");
    var timeToset = row.find("td:eq(2)").text();

    if (confirm("해당 날짜의 데이터를 삭제하시겠습니까?")) {
        $.ajax({
            url: 'deleteSaleDate.jsp',
            type: 'POST',
            data: { saleDate: timeToset },
            success: function(response) {
                if(response.trim() === "deleted") {
                    alert("해당 날짜의 데이터가 삭제되었습니다.");
                } else {
                    alert("해당 날짜에 데이터가 없습니다.");
                }
            },
            error: function(xhr, status, error) {
                console.error('Error:', error);
            }
        });
    } else {
        alert("삭제가 취소되었습니다.");
    }
});

</script>
