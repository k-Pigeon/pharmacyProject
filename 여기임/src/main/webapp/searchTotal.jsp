<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ include file="sessionManager.jsp"%>
<%@ include file="DBconnection.jsp"%>
<%
String dbName = (session != null) ? (String) session.getAttribute("dbName") : null;
String id = (session != null) ? (String) session.getAttribute("id") : null;

if (id == null || dbName == null) {
    response.sendRedirect("login.jsp");
    return;
}

jdbcDriver = dbName;

String searchSystem = request.getParameter("searchSystem");

PreparedStatement pstmt = null;
ResultSet rs = null;
%>

<html>
<head>
<meta charset="UTF-8">
<style>
.table-container {
    position: absolute;
    height: 80%;
    overflow-y: auto;
    border: 1px solid #ccc;
}

/* 전체 테이블 스타일 */
.sticky-header-table {
	width: 100%;
	border-collapse: collapse;
	table-layout: fixed;
}

/* 테이블 셀 공통 스타일 */
.sticky-header-table th, .sticky-header-table td {
	border: 1px solid #ccc;
	padding: 8px;
	text-align: center;
}

/* 헤더 고정 */
.sticky-header-table thead th {
	position: sticky;
    top: 0;
    background-color: #D8BFD8;
    z-index: 1;
    color: #141145;
}
.sticky-header-table tbody tr:nth-child(even){
	background-color:#EFFFFF;
}
</style>
</head>
<body>
	<%
try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPwd);

    String sql = "SELECT * FROM members WHERE memberName LIKE ? OR memberPhone LIKE ?";
    pstmt = conn.prepareStatement(sql);
    pstmt.setString(1, "%" + searchSystem + "%");
    pstmt.setString(2, "%" + searchSystem + "%");
    rs = pstmt.executeQuery();

    if (rs.next()) {
%>
	<div class="table-container">
		<table class="sticky-header-table table_line">
			<thead>
				<tr>
					<th>회원 이름</th>
					<th>회원 번호</th>
					<th>주민등록번호</th>
					<th>성별</th>
					<th>고객번호</th>
				</tr>
			</thead>
			<tbody>
				<%
        do {
        %>
				<tr>
					<td><%= rs.getString("memberName") %></td>
					<td><%= rs.getString("memberPhone") %></td>
					<td><%= rs.getString("jumin1") %>-<%= rs.getString("jumin2") %></td>
					<td><%= rs.getString("gender") %></td>
					<td><%= rs.getString("customerNumber") %></td>
				</tr>
				<%
        } while (rs.next());
        %>
			</tbody>
		</table>
	</div>
	<%
    } else {
%>
	<p style="margin-top: 40px; text-align: center;">검색 결과가 없습니다.</p>
	<%
    }
} catch(Exception e) {
    e.printStackTrace();
} finally {
    if(rs != null) rs.close();
    if(pstmt != null) pstmt.close();
    if(conn != null) conn.close();
}
%>
</body>
</html>
