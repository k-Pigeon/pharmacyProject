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
<style>
    /* 테이블 전체 스타일 */
    .table_line {
        width: 100%;
        max-width: 750px; 
        margin: 0 auto;
        border-collapse: collapse; /* 테이블 경계선 겹침 방지 */
        background-color: #f9f9f9; /* 밝은 회색 배경 */
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05); /* 부드러운 그림자 */
    }

    /* 테이블 헤더 스타일 */
    .table_line th {
        background-color: #4CAF50; /* 초록색 배경 */
        color: black; /* 흰색 텍스트 */
        padding: 12px;
        text-align: center; /* 중앙 정렬 */
        border-bottom: 2px solid #ddd; /* 밝은 회색 선 */
    }

    /* 테이블 데이터 스타일 */
    .table_line td {
        padding: 10px; /* 셀 안 여백 */
        text-align: center; /* 중앙 정렬 */
        border-bottom: 1px solid #ddd; /* 밝은 회색 선 */
    }

    /* 입력창 스타일 */
    .table_line input[type="text"] {
        width: 100%;
        padding: 8px;
        border: 1px solid #ccc; /* 회색 테두리 */
        border-radius: 4px;
        box-shadow: inset 0 5px 10px rgba(0, 0, 0, 0.1); /* 내부 그림자 */
        transition: border-color 0.3s ease; /* 테두리 변화 시 부드러운 전환 */
    }

    /* 입력창 포커스 시 스타일 */
    .table_line input[type="text"]:focus {
        border-color: #4CAF50; /* 포커스 시 초록색 테두리 */
        outline: none; /* 기본 아웃라인 제거 */
        box-shadow: 0 0 5px rgba(76, 175, 80, 0.3); /* 초록빛 하이라이트 */
    }

    /* 버튼 스타일 */
    .table_line button {
        padding: 10px 15px;
        background-color: RGBA(0,0,0,0.3); /* 초록색 버튼 */
        color: white;
        border: none;
        border-radius: 5px;
        cursor: pointer;
        transition: background-color 0.3s ease;
    }

    .table_line button:hover {
        background-color: #388E3C; /* 호버 시 더 짙은 초록색 */
    }
</style>
</head>
<body>
	<div id="wrap" style="overflow-y: hidden;">
		<header>
			<jsp:include page="header.jsp"></jsp:include>
		</header>
		<input type="text" id="SerialNumber" name="SerialNumber" autofocus="autofocus" style="position: fixed; opacity: 0; transform: translateX(520%);" oninput="this.value=this.value.replace(/[^0-9]/g,'')">
		<div style="display: block;position: absolute;width: 100%;height: calc(10%);text-align: center;margin-top: 3%;">
			<h1>제품 판매</h1>
		</div>
		<div id="data" class="data" style="padding-left: 10%;margin-top:8%">
			<table class="table_line" style="padding: 0;max-width: 750px;float: right;margin: 0;">
				<colgroup>
					<col width="7%">
					<col width="13%">
					<col width="6%">
					<col width="7%">
					<col width="9%">
					<col width="4%">
					<col width="9%">
				</colgroup>
				<thead>
					<tr>
						<th>제품코드</th>
						<th>제품명</th>
						<th>규격</th>
						<th>사입가</th>
						<th>가격</th>
						<th>수량</th>
						<th>작업</th>
					</tr>
				</thead>
			</table>
			<div id="scrollTable" style="max-width: 750px;max-height: calc(35vh);overflow-y: auto;float: right;">
				<table class="table_line" style="width: calc(100%);padding: 0;margin: 0;">
					<colgroup>
						<col width="7%">
						<col width="13%">
						<col width="6%">
						<col width="7%">
						<col width="9%">
						<col width="4%">
						<col width="9%">
					</colgroup>
					<tbody id="table_body">
						<tr>
							<td><input type="text" name="SerialNumber" class="SerialNumber" style="width: 100%; border: revert-layer; outline: none; background: none; text-align: center;" readonly></td>
							<td><input type="text" name="medicineName" class="medicineName" style="width: 100%; border: revert-layer; outline: none; background: none; text-align: center;" readonly></td>
							<td><input type="text" name="standard" class="standard" style="width: 100%; border: revert-layer; outline: none; background: none; text-align: center;" readonly></td>
							<td><input type="text" name="Buyingprice" class="Buyingprice" oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');" style="width: 100%; border: revert-layer; outline: none; background: none; text-align: center;" readonly></td>
							<td><input type="text" name="price" class="price" oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');" style="width: 100%; border: revert-layer; outline: none; background: none; text-align: center;"></td>
							<td><input type="text" name="inventory" class="inventory" oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');" style="width: 100%; border: revert-layer; outline: none; background: none; text-align: center;"> <input type="text" id="countNumber" name="countNumber" style="width: 100%; opacity: 0; transform: translate(0px, 500px); position: absolutetext-align:center;"></td>
							<td>
								<button type="button" onclick="removeRow(this)">입력란 제거</button>
							</td>
						</tr>
					</tbody>
				</table>
			</div>
			<table class="table_line" style="max-width: 750px; margin-right: 0px; font-weight: bold;">
				<tbody id="generalMedicine">
					<tr>
						<td style="text-align: center">일반의약품</td>
						<td><input type="text" id="generalPrice" style="border: revert-layer; outline: none; text-align: center; width: 40%;" oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');"> 원</td>
						<td>고객 성함</td>
						<td><input type="text" class="clientName" style="border: revert-layer; outline: none; text-align: center; width: 95%; height: 100%;"></td>
					</tr>
				</tbody>
				<tbody id="preparations">
					<tr>
						<td style="text-align: center">조제의약품</td>
						<td style="text-align: center"><input type="text" id="medicinePrice" style="border: revert-layer; outline: none; text-align: center; width: 40%;" oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');"> 원</td>
						<td>고객 번호</td>
						<td><input type="text" class="clientNumber" style="border: revert-layer; outline: none; text-align: center; width: 95%; height: 100%;"></td>
					</tr>
				</tbody>
				<tbody id="dbInsert">
					<tr>
						<td colspan="2" style="text-align: center">총합계</td>
						<td colspan="2" style="text-align: center"><span id="totalPrice">0</span>원</td>
					</tr>
					<tr>
						<td rowspan="2" colspan="4"><button type="button" id="exhaustionInv" style="width: 100%;height: 110%;line-height: 100%;font-size:25px;">판매</button></td>
					</tr>
				</tbody>
			</table>
		</div>
		<div id="setData" style="margin-top:8%;">
			<table class="table_line" class="set_line" style="width: 600px;line-height: 40px;margin-left: 0px;margin-top:0;">
				<colgroup>
					<col width="100%">
				</colgroup>
				<tr>
					<th colspan="7">한약세트</th>
				</tr>
				<%
				request.setCharacterEncoding("UTF-8");
				// DB 연결 정보
				String jdbcDriver = "jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8";
				String dbUser = "root";
				String dbPwd = "pharmacy@1234";

				Connection conn = null;
				PreparedStatement pstmt = null;
				ResultSet rs = null;

				try {
					Class.forName("com.mysql.cj.jdbc.Driver");
					conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPwd);

					String sql = " SELECT medicineName FROM testTable " 
							   + " WHERE kind = '한약류' AND medicineName LIKE '%세트%';";
					pstmt = conn.prepareStatement(sql);
					rs = pstmt.executeQuery();

					while (rs.next()) {
				%>
				<tr>
					<td><input type="text" name="medicineName" value="<%=rs.getString("medicineName")%>" style="width: 100%;border: none;outline: none;background: none;text-align: center;font-size: 25px;font-weight: 400;" readonly><br>
						<div style="width: 100%; display: flex;">
							<span class="plusBtn" style="flex: 1;border:1px solid black;">+</span><span class="minusBtn" style="flex: 1;border:1px solid black;">-</span>
						</div>
					</td>
				</tr>
				<%
				}
					}
						catch (SQLException se) {
							se.printStackTrace();
					} 
				%>
				<tr>
					<td id="plusOrientalSet" style="cursor: pointer;">한약세트 추가하기</td>
				</tr>
				<tr>
					<th>세트류</th>
				</tr>
				<%
				try {
					Class.forName("com.mysql.cj.jdbc.Driver");
					conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPwd);

					String sql = " SELECT medicineName FROM vitalSet ";
					pstmt = conn.prepareStatement(sql);
					rs = pstmt.executeQuery();

					while (rs.next()) {
				%>
				<tr>
					<td><input type="text" name="medicineName" value="<%=rs.getString("medicineName")%>" style="width: 100%;border: none;outline: none;background: none;text-align: center;font-size: 25px;font-weight: 400;" readonly><br>
						<div style="width: 100%; display: flex;">
							<span class="plus2Btn" style="flex: 1;border:1px solid black;">+</span><span class="minusBtn" style="flex: 1;border:1px solid black;">-</span>
						</div>
					</td>
				</tr>
				<%
					}
				} catch (SQLException se) {
				se.printStackTrace();
				} finally {
				// 리소스 정리
				try {
				if (rs != null)
					rs.close();
				if (pstmt != null)
					pstmt.close();
				if (conn != null)
					conn.close();
				} catch (SQLException se) {
				se.printStackTrace();
				}
				}
				%>
				<tr>
					<td id="plusGeneralSet" style="cursor: pointer;">세트 추가하기</td>
				</tr>
			</table>
		</div>
	</div>

	<!-- jQuery 추가 -->
	<script src="jquery-3.7.1.min.js"></script>
	<script>
	$(document).ready(function() {
		function addCommas(number) {
		    return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
		}
		//상시 SerialNumber 포커스가 가도록 설정
		$(document).mouseover(function() {
			if (!$("#table_body .inventory, .table_line .clientName, .table_line .clientNumber, .price, #medicinePrice, #generalPrice").is(":focus")) {
				$('#SerialNumber').focus();
			}
		});$(document).on("click", function() {
			if (!$("#table_body .inventory, .table_line .clientName, .table_line .clientNumber, .price, #medicinePrice, #generalPrice").is(":focus")) {
				$('#SerialNumber').focus();
			}
		});

		// 조제의약품 가격이 변경될 때마다 총 가격을 다시 계산
		$("#medicinePrice").on("input", function(){
			
		});

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
		                var currentValue = parseFloat($("#table_body tr").eq(i).find(".inventory").val());
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
		$("#setData .table_line #plusOrientalSet").on("click", function(){
			window.location.href="plusOrientalSet.jsp";
		});
		$("#setData .table_line #plusGeneralSet").on("click", function(){
			window.location.href="plusGeneralSet.jsp";
		});
	});
	
	$(document).on('keydown', function(event) {
		if ((event.ctrlKey && (event.key === 's' || event.key === 'S')) || event.keyCode == 122) {
	        event.preventDefault();
	        $("#exhaustionInv").click(); // #exhaustionInv 버튼의 클릭 이벤트 트리거
	    }
	    if(event.keyCode == 122){
	        event.preventDefault();
	        $("#exhaustionInv").click();
	    }
		if(event.keyCode == 118){
	        event.preventDefault();
	        window.location.href="inventory_Exhaustion.jsp";
	    }
		if(event.keyCode == 116){
	        event.preventDefault();
	    }
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
	    let inventory = parseFloat(row.find(".inventory").val());
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
		if($("#wrap #data #scrollTable .table_line #table_body tr").length <= 1){
			alert("판매 제품을 스캔하세요");
			return false;
		}
		
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
	    // #generalPrice와 #medicinePrice 값을 rowData에 추가
	    var medicinePrice = $("#medicinePrice").val();
	    var generalPrice = $("#generalPrice").val();
        var clientNumber = $(".table_line #preparations .clientNumber").val();
        var clientName = $(".table_line #generalMedicine .clientName").val();
	    rowData.push({ generalPrice: generalPrice, medicinePrice: medicinePrice, clientNumber: clientNumber, clientName: clientName });

	    // AJAX 요청
	    $.ajax({
	        url: "statistics.jsp", // 통합된 백엔드 스크립트의 URL
	        method: "POST",
	        contentType: "application/json",
	        data: JSON.stringify(rowData)
	    })
	    .then(function(response) {
	        console.log("데이터 전송 성공!");
	        console.log(response); // 요청의 응답
	        console.log("medicinePrice:", medicinePrice);
	        console.log("generalPrice:", generalPrice);
	        // 요청이 성공하면 페이지 리디렉션
	        //window.location.href = 'inventory_Exhaustion.jsp';
	    })
	    .catch(function(error) {
	        console.error("AJAX 요청 중 오류 발생:", error);
	    });
	    alert("판매가 완료되었습니다.");
	    location.href='inventory_Exhaustion.jsp';
	});

	function updateGeneralPrice() {
	    var totalGeneralPrice = 0;

	    // #table_body의 각 행을 반복하여 총 가격 계산
	    $("#table_body tr").each(function() {
	        var price = parseFloat($(this).find(".price").val());
	        var inventory = parseFloat($(this).find(".inventory").val());
	        if (!isNaN(price) && !isNaN(inventory)) {
	            totalGeneralPrice += price * inventory;
	        }
	    });

	    // 총 가격을 #generalPrice에 업데이트
	    $("#generalPrice").val(totalGeneralPrice.toFixed(2)); // 소수점 2자리까지 표시
	}


    // 페이지 로드 시 초기 총 가격 계산
    updateGeneralPrice();

    // 입력 요소의 값이 변경될 때마다 총 가격 업데이트
    $(document).on("input", "#table_body input", function() {
        updateGeneralPrice();
    });

    // 행이 추가될 때마다 #generalPrice 업데이트
    $(document).on("DOMNodeInserted", function() {
        updateGeneralPrice();
    });

    function calculateTotalPrice() {
        var totalPrice = 0;//최종값

        // #table_body의 각 행을 반복하여 총 가격 계산
        $("#table_body tr").each(function() {
            var price = parseFloat($(this).find(".price").val());
            var inventory = parseFloat($(this).find(".inventory").val());
            //일반의약품(재고) 가격을 셀 때
            if (!isNaN(price) && !isNaN(inventory)) {
                totalPrice += price * inventory;
                $("#totalPrice").text(totalPrice); // 소수점 2자리까지 표시, 총합계
            }
        });

        // 총 가격을 #totalPrice와 #generalPrice에 업데이트
        $("#generalPrice").val(totalPrice); // #generalPrice의 값도 업데이트
    }

    
    $(".plusBtn").click(function() {
        var medicineName = $(this).closest('td').find('input[name="medicineName"]').val();
        console.log("Requesting data for medicineName:", medicineName); // 디버깅 메시지 추가
        var inventoryIncreased = false; // Inventory increase flag

        $("#table_body tr").each(function() {
            if (medicineName === $(this).find(".medicineName").val()) {
                var currentValue = parseFloat($(this).find(".inventory").val());
                $(this).find(".inventory").val(currentValue + 1);
                
                // Update the total price
                calculateTotalPrice();
                
                inventoryIncreased = true;
                return false; // Break out of the each loop
            }
        });

        if (!inventoryIncreased) {
            // Use AJAX to get data and add a new row
            $.ajax({
                type: 'POST',
                url: 'updateMedicineCount.jsp',
                data: {
                    medicineName: medicineName
                },
                success: function(response) {
                    console.log("Response from server:", response); // 디버깅 메시지 추가
                    if (response && response.data) {
                        insertRowAboveLast(response.data); // 테이블에 새로운 행 추가
                        calculateTotalPrice(); // 총 가격 재계산
                    } else {
                        console.log("데이터가 없습니다." + medicineName);
                    }
                },
                error: function(xhr, status, error) {
                    console.error("AJAX 요청 실패:", status, error);
                }
            });
        }
    });
    $(".plus2Btn").click(function() {
        var medicineName = $(this).closest('td').find('input[name="medicineName"]').val();
        console.log("Requesting data for medicineName:", medicineName); // 디버깅 메시지 추가
        var inventoryIncreased = false; // Inventory increase flag

        $("#table_body tr").each(function() {
            if (medicineName === $(this).find(".medicineName").val()) {
                var currentValue = parseFloat($(this).find(".inventory").val());
                $(this).find(".inventory").val(currentValue + 1);
                
                // Update the total price
                calculateTotalPrice();
                
                inventoryIncreased = true;
                return false; // Break out of the each loop
            }
        });

        if (!inventoryIncreased) {
            // Use AJAX to get data and add a new row
            $.ajax({
                type: 'POST',
                url: 'updateVitalCount.jsp',
                data: {
                    medicineName: medicineName
                },
                success: function(response) {
                    console.log("Response from server:", response); // 디버깅 메시지 추가
                    if (response && response.data) {
                        insertRowAboveLast(response.data); // 테이블에 새로운 행 추가
                        calculateTotalPrice(); // 총 가격 재계산
                    } else {
                        console.log("데이터가 없습니다." + medicineName);
                    }
                },
                error: function(xhr, status, error) {
                    console.error("AJAX 요청 실패:", status, error);
                }
            });
        }
    });

    // Function to insert a new row above the last row
    function insertRowAboveLast(data) {
        var lastRow = $("#table_body tr:last-child");
        var newRow = lastRow.clone();
        newRow.find('.SerialNumber').val(data.SerialNumber);
        newRow.find('.medicineName').val(data.medicineName);
        newRow.find('.Buyingprice').val(data.Buyingprice);
        newRow.find('.price').val(data.price);
        newRow.find('.inventory').val(data.inventory);
        newRow.find('.kind').val(data.kind);
        newRow.find('.standard').val(data.standard);
        newRow.find('.receiptDate').val(data.receiptDate);
        newRow.find('.DeliveryDate').val(data.DeliveryDate);
        lastRow.before(newRow);
    }
	</script>
</body>
</html>
