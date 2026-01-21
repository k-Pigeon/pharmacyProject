<%@ page import="javax.servlet.http.*, javax.servlet.*"%>
<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%
    // 세션에서 데이터 가져오기
    HttpSession userSession = request.getSession();  // 'session' 대신 'userSession' 사용
    
    String serialNumber = (String) userSession.getAttribute("SerialNumber");
    String medicineName = (String) userSession.getAttribute("medicineName");
    String buyingPrice = (String) userSession.getAttribute("Buyingprice");
    String price = (String) userSession.getAttribute("price");
    String inventory = (String) userSession.getAttribute("inventory");
    String kind = (String) userSession.getAttribute("kind");
    String companyName = (String) userSession.getAttribute("companyName");
    String standard = (String) userSession.getAttribute("standard");
    String receiptDate = (String) userSession.getAttribute("receiptDate");
    String deliveryDate = (String) userSession.getAttribute("DeliveryDate");
    String countNumber = (String) userSession.getAttribute("countNumber");
%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>약품 수정 페이지</title>
<style>
body {
	font-family: Arial, sans-serif;
}

.container {
	display: block;
	max-width: 600px;
	min-width: 600px;
	height: 65vh;
	margin: auto;
	padding: 20px;
	border: 1px solid #ccc;
	border-radius: 10px;
	background-color: #f9f9f9;
	overflow: scroll;
}

.form-group {
	margin-bottom: 15px;
}

label {
	display: block;
	margin-bottom: 5px;
}

input[type="text"] {
	width: 100%;
	padding: 8px;
	box-sizing: border-box;
}

input[type="submit"] {
	background-color: #4CAF50;
	color: white;
	border: none;
	padding: 10px 15px;
	cursor: pointer;
}

input[type="submit"]:hover {
	background-color: #45a049;
}
.custom-btn {
  width: 130px;
  height: 40px;
  color: #fff;
  border-radius: 5px;
  padding: 10px 25px;
  font-family: 'Lato', sans-serif;
  font-weight: 500;
  background: transparent;
  cursor: pointer;
  transition: all 0.3s ease;
  position: relative;
  display: inline-block;
   box-shadow:inset 2px 2px 2px 0px rgba(255,255,255,.5),
   7px 7px 20px 0px rgba(0,0,0,.1),
   4px 4px 5px 0px rgba(0,0,0,.1);
   outline: none;
   left: 50%;
   transform: translateX(-65px);
}
.btn-3 {
  background: rgb(0,172,238);
  background: linear-gradient(0deg, rgba(0,172,238,1) 0%, rgba(2,126,251,1) 100%);
  width: 130px;
  height: 40px;
  line-height: 42px;
  padding: 0;
  border: none;
}
.btn-3 span {
  position: relative;
  display: block;
  width: 100%;
  height: 100%;
}
.btn-3:before,
.btn-3:after {
  position: absolute;
  content: "";
  right: 0;
  top: 0;
   background: rgba(2,126,251,1);
  transition: all 0.3s ease;
}
.btn-3:before {
  height: 0%;
  width: 2px;
}
.btn-3:after {
  width: 0%;
  height: 2px;
}
.btn-3:hover{
   background: transparent;
  box-shadow: none;
}
.btn-3:hover:before {
  height: 100%;
}
.btn-3:hover:after {
  width: 100%;
}
.btn-3 span:hover{
   color: rgba(2,126,251,1);
}
.btn-3 span:before,
.btn-3 span:after {
  position: absolute;
  content: "";
  left: 0;
  bottom: 0;
   background: rgba(2,126,251,1);
  transition: all 0.3s ease;
}
.btn-3 span:before {
  width: 2px;
  height: 0%;
}
.btn-3 span:after {
  width: 0%;
  height: 2px;
}
.btn-3 span:hover:before {
  height: 100%;
}
.btn-3 span:hover:after {
  width: 100%;
}
</style>

</head>
<body>
	<header>
		<jsp:include page="header.jsp"></jsp:include>
	</header>
	<div id="wrap">
		<div class="container">
			<h2>약품 수정</h2>
			<div class="form-group">
				<label for="serialNumber">일련번호</label> <input type="text" id="serialNumber" name="serialNumber" value="<%= serialNumber %>" readonly>
			</div>
			<div class="form-group">
				<label for="medicineName">약품명</label> <input type="text" id="medicineName" name="medicineName" value="<%= medicineName %>">
			</div>
			<div class="form-group">
				<label for="buyingPrice">구매가</label> <input type="text" id="buyingPrice" name="buyingPrice" value="<%= buyingPrice %>">
			</div>
			<div class="form-group">
				<label for="price">판매가</label> <input type="text" id="price" name="price" value="<%= price %>">
			</div>
			<div class="form-group">
				<label for="inventory">재고</label> <input type="text" id="inventory" name="inventory" value="<%= inventory %>">
			</div>
			<div class="form-group">
				<label for="kind">종류</label> <input type="text" id="kind" name="kind" value="<%= kind %>">
			</div>
			<div class="form-group">
				<label for="companyName">제조사</label> <input type="text" id="companyName" name="companyName" value="<%= companyName %>">
			</div>
			<div class="form-group">
				<label for="standard">기준</label> <input type="text" id="standard" name="standard" value="<%= standard %>">
			</div>
			<div class="form-group">
				<label for="receiptDate">입고 날짜</label> <input type="text" id="receiptDate" name="receiptDate" value="<%= receiptDate %>">
			</div>
			<div class="form-group">
				<label for="deliveryDate">유통기한</label> <input type="text" id="deliveryDate" name="deliveryDate" value="<%= deliveryDate %>">
			</div>
			<button type="button" id="updateButton" class="custom-btn btn-3"><span>수정하기</span></button>
		</div>
	</div>
	<div style="display:none">
		<input type="text" id="testName" value="<%= medicineName%>" readonly>
		<input type="text" id="testStandard" value="<%= standard%>" readonly>
		<input type="text" id="testDate" value="<%= deliveryDate%>" readonly>
	</div>
	<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
	<script>
$(document).ready(function() {
    $('#updateButton').on('click', function(event) {
        event.preventDefault(); // 기본 폼 제출 방지

        // 입력 필드 값 가져오기
        var serialNumber = $('#serialNumber').val();
        var medicineName = $('#medicineName').val();
        var buyingPrice = $('#buyingPrice').val();
        var price = $('#price').val();
        var inventory = $('#inventory').val();
        var kind = $('#kind').val();
        var companyName = $('#companyName').val();
        var standard = $('#standard').val();
        var receiptDate = $('#receiptDate').val();
        var deliveryDate = $('#deliveryDate').val();
		var tipMedicineName = $('#testName').val();
		var tipstandard = $('#testStandard').val();
		var tipDeliveryDate = $('#testDate').val();
        
        // AJAX 요청
        $.ajax({
            url: 'updateData.jsp',
            type: 'POST',
            data: {
                serialNumber: serialNumber,
                medicineName: medicineName,
                buyingPrice: buyingPrice,
                price: price,
                inventory: inventory,
                kind: kind,
                companyName: companyName,
                standard: standard,
                receiptDate: receiptDate,
                deliveryDate: deliveryDate,
                tipMedicineName : tipMedicineName,
                tipstandard : tipstandard,
                tipDeliveryDate : tipDeliveryDate
            },
            success: function(response) {
                alert("변경이 완료되었습니다.");
                location.href='index.jsp';
            },
            error: function(xhr, status, error) {
                console.error('Error updating data:', error);
            }
        });
    });
});
</script>
</body>
</html>

