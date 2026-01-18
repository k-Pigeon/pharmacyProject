<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ include file="sessionManager.jsp"%>
<%@ include file="DBconnection.jsp"%>
<%
String dbName = (session != null) ? (String) session.getAttribute("dbName") : null;
String id = (session != null) ? (String) session.getAttribute("id") : null;
String password = (session != null) ? (String) session.getAttribute("password") : null;

if (id == null || dbName == null) {
    response.sendRedirect("login.jsp");
    return;
}

jdbcDriver = dbName;
%>
<%
    String medicineName = request.getParameter("medicineName");
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    boolean hasResult = false; // while 문 외부에서 선언

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");

        String sql = " SELECT medicineName, standard, FORMAT(buyingprice, 0) AS byPrice, FORMAT(price, 0) AS price, "
        		   + " countNumber, lowerAndHigest "
			       + " FROM RegistTable "
	 			   + " WHERE medicineName LIKE ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, "%" + medicineName + "%");
        rs = pstmt.executeQuery();
%>
<% while (rs.next()) { 
     hasResult = true;
%>
<tr class='result-row' style='cursor: pointer;'
    data-medicinename='<%= rs.getString("medicineName") %>'
    data-standard='<%= rs.getString("standard") %>'
    data-buyingprice='<%= "1" %>'
    data-price='<%= rs.getString("price") %>'
    data-lowerandhigest='<%= rs.getString("lowerAndHigest") %>'
    >
    <td style='border: 1px solid #ccc; padding: 5px;'><%= rs.getString("medicineName") %></td>
    <td style='border: 1px solid #ccc; padding: 5px;'><%= rs.getString("standard") %></td>
    <td style='border: 1px solid #ccc; padding: 5px;'><%= rs.getString("byPrice") %></td>
    <td style='border: 1px solid #ccc; padding: 5px;'><%= rs.getString("price") %></td>
    <td style='border: 1px solid #ccc; padding: 5px;'><%= rs.getString("lowerAndHigest") %></td>
</tr>

<% } %>
<tr>
    <td colspan="9" style="text-align: center;">
        <div style="margin-top: 10px;">
            <button class="addProduct" data-medicinename="<%= medicineName %>">등록하러 가기</button>
        </div>
    </td>
</tr>
<% if (!hasResult) { %>
<tr>
    <td colspan="9" style="text-align: center; padding: 10px;">검색 결과가 없습니다.</td>
</tr>
<tr>
    <td colspan="9" style="text-align: center; padding: 10px;">제품 등록을 하시겠습니까?</td>
</tr>
<tr>
    <td colspan="9" style="text-align: center;">
        <div style="margin-top: 10px;">
            <button class="addProduct" data-medicinename="<%= medicineName %>">등록하러 가기</button>
        </div>
    </td>
</tr>
<% } %>


<%
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    }
%>
<!-- 모달 뼈대 추가 -->
<div class="addMedicine" style="display:none; position:fixed; top:0; left:0; right:0; bottom:0; z-index:9999; justify-content:center; align-items:center;">
  <div class="modal-content" style="background:white; padding:20px; border-radius:10px; width:80%; max-height:80%; overflow:auto;">
    <!-- addProduct.jsp가 여기 삽입됨 -->
  </div>
</div>

<script>
$(document).ready(function() {
    // 결과 행 클릭 이벤트
    $(".result-row").on("click", function() {
        if (window.opener && !window.opener.closed) {
            const focused = window.opener.document.querySelector("input[name='medicineName[]']:focus");
            if (focused) {
                const tr = $(focused).closest("tr");
                tr.find("input[name='medicineName[]']").val($(this).data("medicinename"));
                tr.find("input[name='standard[]']").val($(this).data("standard"));
                tr.find("input[name='price[]']").val($(this).data("price"));
                tr.find("input[name='lowerandhigest[]']").val($(this).data("lowerandhigest"));
            }
            window.close();
        }
    });

    // "등록하러 가기" 버튼 클릭 이벤트
    $(".addProduct").on("click", function() {
        const medicineName = $(this).data("medicinename");

        $.ajax({
            url: "addProduct.jsp",
            method: "GET",
            data: { medicineName: medicineName },
            success: function(response) {
                $(".addMedicine .modal-content").html(response);
                $(".addMedicine").css("display", "flex"); // 모달 보이게
            },
            error: function(xhr, status, error) {
                console.error(error);
                alert("등록 페이지를 불러오는 중 오류가 발생했습니다.");
            }
        });
    });

    // 모달 바깥쪽 클릭하면 모달 닫기
    $(".addMedicine").on("click", function(e) {
        if (e.target === this) {
            $(this).hide();
            $(".modal-content").empty(); // 닫을 때 안에 내용 비워주기
        }
    });
});

</script>