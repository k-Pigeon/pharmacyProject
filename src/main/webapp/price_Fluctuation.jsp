<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.text.*"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Inventory Index</title>
<link rel="stylesheet" href="style.css">

</head>
<body>
	<div id="wrap">
		<header>
			<jsp:include page="header.jsp"></jsp:include>
		</header>
		<input type="text" id="SerialNumber" name="SerialNumber" autofocus="autofocus" style="position: fixed; opacity: 0; transform: translateX(383%);">
		<div id="data" class="data" style="padding-top: 60px; padding-top: 60px; padding-left: 10%;border-collapse:collapse;">
			<table class="table_line" style="max-width: 600px;border-collapse:collapse;">
				<colgroup>
						<col width="7%">
						<col width="13%">
						<col width="6%">
						<col width="9%">
						<col width="9%">
				</colgroup>
				<thead>
					<tr>
						<th>제품코드</th>
						<th>제품명</th>
						<th>규격</th>
						<th>가격</th>
						<th>작업</th>
					</tr>
				</thead>
			</table>
			<div id="scrollTable" style="max-width: 600px; max-height: 250px; overflow-y: hidden; margin: 0 auto;">
				<table class="table_line" style="width: calc(100%); margin-right: 0px;margin-top: -1px;border-collapse:collapse;">
					<colgroup>
						<col width="7%">
						<col width="13%">
						<col width="6%">
						<col width="9%">
						<col width="9%">
					</colgroup>
					<tbody id="table_body">
						<tr>
							<td><input type="text" name="SerialNumber" class="SerialNumber" style="width: 100%; border: none; outline: none; background: none; text-align: center;" readonly></td>
							<td><input type="text" name="medicineName" class="medicineName" style="width: 100%; border: none; outline: none; background: none; text-align: center;" readonly></td>
							<td><input type="text" name="standard" class="standard" style="width: 100%; border: none; outline: none; background: none; text-align: center;" readonly></td>
							<td><input type="text" name="price" class="price" oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');" style="width: 100%; border: none; outline: none; background: none; text-align: center;"></td>
							<td>
								<button type="button" onclick="removeRow(this)">입력란 제거</button>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<table class="table_line" style="max-width: 600px;margin-top: -1px;border-collapse:collapse;">
				<tbody id="dbInsert">
					<tr>
						<td rowspan="2" colspan="3"><button type="button" id="exhaustionInv">판매</button></td>
					</tr>
				</tbody>
			</table>
		</div>
	</div>

	<!-- jQuery 추가 -->
	<script src="jquery-3.7.1.min.js"></script>
	<script>
	$(document).ready(function() {
		//상시 SerialNumber 포커스가 가도록 설정
		$(document).mouseover(function() {
			if (!$("#table_body .inventory, .price, #medicinePrice, #generalPrice").is(":focus")) {
				$('#SerialNumber').focus();
			}
		});$(document).on("click", function() {
			if (!$("#table_body .inventory, .price, #medicinePrice, #generalPrice").is(":focus")) {
				$('#SerialNumber').focus();
			}
		});
		
		function calculateTotalPrice() {
		    var totalPrice = 0;

		    // 테이블의 각 행을 반복하여 총 가격 계산
		    $("#table_body tr").each(function() {
		        var price = parseFloat($(this).find(".price").val());
		        var inventory = parseInt($(this).find(".inventory").val());
		        if (!isNaN(price) && !isNaN(inventory)) {
		            totalPrice += price * inventory;
				    $("#generalPrice").val(Math.round(price * inventory));
		        }
		    });

		    // 조제의약품 가격을 총합계에 추가
		    var medicinePrice = parseFloat($("#medicinePrice").val());
		    if (!isNaN(medicinePrice)) {
		        totalPrice += medicinePrice;
		    }
		    $("#totalPrice").text(Math.round(totalPrice));
		}

		// 조제의약품 가격이 변경될 때마다 총 가격을 다시 계산
		$("#medicinePrice").on("input", calculateTotalPrice);

		// input 요소의 값이 변경될 때마다 총 가격 계산
		$(document).on("input", "#table_body input", calculateTotalPrice);

		$("#SerialNumber").on("keyup", function(event) {
		    if (event.keyCode === 13) {
		        var inputValue = $(this).val();
		        var inventoryIncreased = false; // inventory가 증가되었는지 여부를 나타내는 변수

		        if(inputValue == ""){
		        	return false;
		        }

		        for (var i = 0; i < $("#table_body tr").length; i++) {
		            if (inputValue === $("#table_body tr").eq(i).find(".SerialNumber").val()) {
		                var currentValue = parseInt($("#table_body tr").eq(i).find(".inventory").val());
		                var priceValue = parseInt($("#table_body tr").eq(i).find(".price").val());
		                $("#table_body tr").eq(i).find(".inventory").val(currentValue + 1);
		                inventoryIncreased = true;

		                // 가격(price) 가져오기
		                var price = parseFloat($("#table_body tr").eq(i).find(".price").val());
		                // 기존의 총 가격 가져오기
		                var totalPrice = parseFloat($("#totalPrice").text());
		                // 새로운 총 가격 계산하여 설정
		                $("#generalPrice").val(totalPrice + price);
		                $("#totalPrice").text(totalPrice + price);
		                
		                $("#SerialNumber").val('');
		                break;
		            }
		        }

		        if (!inventoryIncreased) {
		            $.ajax({
		                url: "updateDatabase.jsp",
		                method: "POST",
		                data: {
		                    serialNumber: inputValue
		                },
		                success: function(response) {
		                    if (response && response.SerialNumber) {
		                        fillInputs(response);
		                        addRow();
		                        $("#SerialNumber").val('');
		                        
		                        calculateTotalPrice();
		                    } else {
		                        console.log("데이터가 없습니다.");
		                        $("#SerialNumber").val('');
		                    }
		                },
		                error: function(xhr, status, error) {
		                    console.error("AJAX request failed:", status, error);
		                }
		            });
		        }
		    }
		    calculateTotalPrice(); // 페이지 로드 시 초기 총 가격 계산
		});
	});
	
	function addCommas(number) {
	    return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
	}

	function fillInputs(data) {
	    var lastRow = $("#table_body tr:last-child");
	    lastRow.find(".SerialNumber").val(data.SerialNumber);
	    lastRow.find(".medicineName").val(data.medicineName);
	    lastRow.find(".Buyingprice").val(data.Buyingprice);
	    lastRow.find(".price").val(data.price);
	    lastRow.find(".inventory").val(data.inventory);
	    lastRow.find(".kind").val(data.kind);
	    lastRow.find(".standard").val(data.standard);
	    lastRow.find(".receiptDate").val(data.receiptDate);
	    lastRow.find(".DeliveryDate").val(data.DeliveryDate);
	}

	function addRow() {
	    var lastRow = $("#table_body tr:last-child").clone();
	    lastRow.find('input[type="text"]').val('');
	    lastRow.find('select').val('');
	    $("#table_body").append(lastRow);
	}

	function removeRow(button) {
	    if ($("#wrap .table_line tr").length <= 4) {
	        return false;
	    }
	    var row = $(button).closest("tr");
	    if (row.is(':last-child')) {
	        return false;
	    }
	    var price = parseFloat(row.find(".price").val());
	    var inventory = parseInt(row.find(".inventory").val());
	    var totalPrice = parseFloat($("#totalPrice").text());
	    var generalPrice = parseFloat($("#generalPrice").val());

	    // 해당 행의 가격 * 수량을 총 가격과 일반의약품 가격에서 빼기
	    totalPrice -= price * inventory;
	    generalPrice -= price * inventory;

	    // 행을 제거
	    row.remove();

	    // 변경된 총 가격과 일반의약품 가격을 업데이트
	    $("#totalPrice").text(totalPrice);
	    $("#generalPrice").val(generalPrice);

	    // 총 가격이 0 미만으로 떨어지지 않도록 처리
	    if (totalPrice < 0) {
	        $("#totalPrice").text("0");
	    }
	    if (generalPrice < 0) {
	        $("#generalPrice").val("0");
	    }
	}

	$("#exhaustionInv").on("click", function() {
	    var rowData = [];
	    $("#table_body tr").each(function() {
	        var row = {};
	        row.serialNumber = $(this).find(".SerialNumber").val();
	        row.medicineName = $(this).find(".medicineName").val();
	        row.Buyingprice = $(this).find(".Buyingprice").val();
	        row.price = $(this).find(".price").val();
	        row.inventory = $(this).find(".inventory").val();
	        row.kind = $(this).find(".kind").val();
	        row.standard = $(this).find(".standard").val();
	        row.receiptDate = $(this).find(".receiptDate").val();
	        row.deliveryDate = $(this).find(".DeliveryDate").val();
	        rowData.push(row);
	    });
	    // AJAX 요청
	    $.ajax({
	        url: "statisticsUpdate.jsp", // 통합된 백엔드 스크립트의 URL
	        method: "POST",
	        contentType: "application/json",
	        data: JSON.stringify(rowData)
	    })
	    .then(function(response) {
	        if (response.success) {
	            console.log("데이터 전송 성공!");
	            window.location.href='price_Fluctuation.jsp';
	        } else {
	            console.error("서버 오류: ", response.message);
	        }
	    })
	    .catch(function(error) {
	        console.error("AJAX 요청 중 오류 발생:", error);
	    });
	});
	</script>
</body>
</html>
