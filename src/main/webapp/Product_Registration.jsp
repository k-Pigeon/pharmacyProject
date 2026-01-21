<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>바코드 스캔</title>
<link rel="stylesheet" href="style.css">
<style>
html, body {
    overflow-x: hidden; /* 가로 스크롤 방지 */
    overflow-y: auto;   /* 세로 스크롤 자동 */
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

/* 테이블 스타일 */
#table_input {
    width: 100%;
    max-width: 100%; /* 화면을 넘지 않도록 설정 */
    background-color: #f9f9f9; /* 아주 밝은 회색 배경 */
    border-radius: 8px;
    border: 1px solid #ddd; /* 밝은 테두리 */
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05); /* 부드러운 그림자 */
    table-layout: auto; /* 테이블의 자동 크기 조정 */
}

/* 테이블 헤더 스타일 */
#table_input th, #table_input td {
    word-wrap: break-word; /* 긴 텍스트 줄바꿈 */
}
/* 테이블 스타일 */
#table_input {
    width: 100%;
    background-color: #f9f9f9; /* 아주 밝은 회색 배경 */
    border-radius: 8px;
    border: 1px solid #ddd; /* 밝은 테두리 */
    box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05); /* 부드러운 그림자 */
}

/* 테이블 헤더 스타일 */
#table_input th {
    background-color: #f0f0f0; /* 밝은 회색 */
    color: #333333; /* 어두운 회색 텍스트 */
    font-weight: 600;
    text-align: left;
    padding: 12px;
    border-bottom: 2px solid #4CAF50; /* 초록색 선 강조 */
}

/* 테이블 데이터 입력란 스타일 */
#table_input td {
    padding: 12px;
    background-color: #ffffff; /* 흰색 배경 */
    border-bottom: 1px solid #e0e0e0; /* 얇은 회색 선 */
}

/* 입력창 스타일 */
#table_input input[type="text"],
#table_input input[type="date"],
#table_input select {
    width: 90%;
    padding: 10px;
    background-color: #ffffff; /* 흰색 배경 */
    color: #333333; /* 어두운 텍스트 */
    border: 1px solid #ccc; /* 회색 테두리 */
    border-radius: 4px;
    box-shadow: inset 0 1px 3px rgba(0, 0, 0, 0.05);
    transition: border-color 0.3s ease, box-shadow 0.3s ease;
}

/* 입력창 포커스 시 스타일 */
#table_input input[type="text"]:focus,
#table_input input[type="date"]:focus,
#table_input select:focus {
    border-color: #4CAF50; /* 포커스 시 초록색 테두리 */
    box-shadow: 0 0 5px rgba(76, 175, 80, 0.3); /* 초록빛 하이라이트 */
    outline: none;
}

/* 테이블의 제출 버튼 스타일 */
#table_input input[type="submit"] {
    padding: 10px 15px;
    background-color: #4CAF50; /* 초록색 버튼 */
    color: white;
    border: none;
    border-radius: 5px;
    cursor: pointer;
    transition: background-color 0.3s ease;
}

#table_input input[type="submit"]:hover {
    background-color: #388E3C; /* 호버 시 더 짙은 초록색 */
}
</style>

</head>
<body>
	<div id="wrap">
		<%
		Class.forName("com.mysql.cj.jdbc.Driver");
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		request.setCharacterEncoding("UTF-8");

		try {
			String jdbcDriver = "jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8";
			String dbUser = "root";
			String dbPwd = "pharmacy@1234";

			String SQLCondition = "";

			String sql = "";

			conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPwd);

			//값을 검색했을 때 사용하는 SQL
			sql = " select CAST(max(countNumber) + 1 as signed integer) countNumber from testTable ";
			pstmt = conn.prepareStatement(sql);
			rs = pstmt.executeQuery();

			rs.next();
		} catch (SQLException se) {
			se.printStackTrace();
		}
		%>
		<header>
			<jsp:include page="header.jsp"></jsp:include>
		</header>
		<form action="./testTableStore.jsp" name="data" method="post" id="formTeg" onsubmit="return medicine()" style="width: 80%">
			<table style="border: 1px solid black; min-width: 70%" id="table_input">
				<colgroup>
					<col width="50%">
					<col width="50%">
				</colgroup>
				<tr>
					<th style="background: none; border: hidden;">제품코드<br>
					</th>
					<td style="border: none;"><input type="text" name="SerialNumber" class="SerialNumber" onkeypress="return isNumberKey(event)" placeholder="바코드 스캐너 사용"></td>
				</tr>
				<tr>
					<th style="background: none; border: hidden;">제품명</th>
					<td style="border: none;"><input type="text" name="medicineName" class="medicineName"></td>
				</tr>
				<tr>
					<th style="background: none; border: hidden;">사익가격</th>
					<td style="border: none;"><input type="text" name="Buyingprice" class="Buyingprice" oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');"></td>
				</tr>
				<tr>
					<th style="background: none; border: hidden;">판매가격</th>
					<td style="border: none;"><input type="text" name="price" class="price" oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1');"></td>
				</tr>
				<tr>
					<th style="background: none; border: hidden;">입고 수량</th>
					<td style="border: none;"><input type="text" name="inventory" class="inventory" oninput="this.value = this.value.replace(/[^0-9.]/g, '').replace(/(\..*)\./g, '$1').replace(/\s| /gi, '');"></td>
				</tr>
				<tr>
					<th style="background: none; border: hidden;">종류<br>
					</th>
					<td style="border: none;"><select name="kind" class="kind">
							<option value="건강기능식품">건강기능식품</option>
							<option value="일반의약품">일반의약품</option>
							<option value="파스류">파스류</option>
							<option value="연고류">연고류</option>
							<option value="드링크류">드링크류</option>
							<option value="비타민류">비타민류</option>
							<option value="한약류">한약류</option>
							<option value="기타">기타</option>
					</select></td>
				</tr>
				<tr>
					<th style="background: none; border: hidden;">회사명</th>
					<td style="border: none;"><input type="text" name="companyName" class="companyName"></td>
				</tr>
				<tr>
					<th style="background: none; border: hidden;">규격</th>
					<td style="border: none;"><input type="text" name="standard" class="standard"></td>
				</tr>
				<tr>
					<th style="background: none; border: hidden;">입고 날짜</th>
					<td style="border: none;"><input type="date" name="receiptDate" size=20 class="receiptDate"></td>
				</tr>
				<tr>
					<th style="background: none; border: hidden;">유통기한</th>
					<td style="border: none;"><input type="date" name="DeliveryDate" size=20 class="DeliveryDate" style="text-align: center;"> <input type="text" id="countNumber" class="countNumber" name="countNumber" style="opacity: 0; transform: translate(0px, 17px); position: absolute;"></td>
				</tr>
				<tr>
					<th style="background: none; border: hidden;">즐겨찾기</th>
					<td style="border: none;"><input type="radio" name="bookmark" class="Bookmark" value="0" checked>미추가 <input type="radio" name="bookmark" class="Bookmark" value="1">추가</td>
				</tr>
				<tr>
					<td colspan="2" style="border: none;"><input type="submit" value="수량입력"></td>
				</tr>
			</table>
		</form>
	</div>
	<script src="jquery-3.7.1.min.js"></script>
	<script>
	$(document).ready(function(){
		
	    const barcodeInput = $('#wrap #table_input .SerialNumber');
	    let inputCleared = false;

	    barcodeInput.focus(function() {
	        inputCleared = false; // Reset the flag when the input gets focus
	    });

	    barcodeInput.keydown(function(event) {
	        if (!inputCleared && isNumberKey(event)) {
	            barcodeInput.val(''); // Clear the input field on first keydown after focus
	            inputCleared = true;
	        }
	    });

	    function isNumberKey(event) {
	        // Check if the pressed key is a number key
	        return (event.keyCode >= 48 && event.keyCode <= 57) || (event.keyCode >= 96 && event.keyCode <= 105);
	    }

	    barcodeInput.focus(); // To focus the input field automatically (optional)
		
		
	    // 다음 포커스를 설정하기 위한 변수
	    var nextInput = null;

	    $("#wrap #table_input .SerialNumber").keypress(function(event) {
	    	
	        // Enter 키의 keycode는 13
	        if (event.which == 13) {
	            // SerialNumber 값 가져오기
	            var serialNumber = $(this).val();

	            // AJAX 요청 설정
	            $.ajax({
	                type: "POST",
	                url: "fetchDataFromDB.jsp", // 실제로 데이터를 DB에서 가져올 서버 파일 경로
	                data: { serialNumber: serialNumber }, // SerialNumber를 서버에 전송
	                success: function(response) {
	                    if (response.error) {
	                        console.error("DB 조회 오류:", response.error);
	                        return;
	                    }

	                    if (response.SerialNumber) {
	                        var confirmation = confirm("기존에 있는 데이터를 사용하시겠습니까?");
	                        if (confirmation) {
	                            // 서버에서 받은 응답을 각각의 input 상자에 설정
	                            $("#table_input .medicineName").val(response.medicineName);
	                            $("#table_input .Buyingprice").val(response.Buyingprice);
	                            $("#table_input .price").val(response.price);
	                            $("#table_input .inventory").val(response.inventory);
	                            $("#table_input select[name='kind']").val(response.kind);
	                            $("#table_input .standard").val(response.standard);
	                            $("#table_input .companyName").val(response.companyName);
	                            $("#table_input .DeliveryDate").val(response.DeliveryDate);
	                            $("#table_input .countNumber").val(response.countNumber);
	                            $("#table_input input[name='bookmark'][value='" + response.Bookmark + "']").prop('checked', true);

	                            // 다음 포커스를 medicineName으로 설정
	                            nextInput = $("#table_input .medicineName");
	                        } else {
	                            // 다음 포커스를 SerialNumber로 설정
	                            nextInput = $("#table_input .SerialNumber");
	                        }
	                    } else {
	                        // 데이터가 없는 경우 입력 필드를 비움
	                        $("#table_input input, #table_input select").val("");

	                        // 다음 포커스를 medicineName으로 설정
	                        nextInput = $("#table_input .medicineName");
	                    }
	                },
	                error: function(xhr, status, error) {
	                    console.error("AJAX 요청 에러:", error);
	                }
	            });

	            // 다음 포커스를 설정한 input으로 이동
	            if (nextInput) {
	                nextInput.focus();
	                nextInput = null; // 다음 포커스를 null로 초기화하여 다음에 Enter 키를 누를 때에도 영향을 받지 않도록 함
	            }

	            // Enter 키에 대한 기본 동작 방지
	            event.preventDefault();
	        }
	    });
	});
	
	$(document).on('keydown', function(event) {
	    if (event.ctrlKey && (event.key === 's' || event.key === 'S')) {
	        event.preventDefault();
	        $('#formTeg').submit();
	    }
	    if(event.keyCode == 118){
	        event.preventDefault();
	        window.location.href="Product_Registration.jsp";
	    }
	    if(event.keyCode == 122){
	        event.preventDefault();
	        $('#formTeg').submit();
	    }
	    if(event.keyCode == 116){
	        event.preventDefault();
	    }
	});
		// 입력란 변수
		var $SerialNumber = $("#table_input .SerialNumber");
		var $medicineName = $("#table_input .medicineName");
		var $Buyingprice = $("#table_input .Buyingprice");
		var $price = $("#table_input .price");
		var $inventory = $("#table_input .inventory");
		var $kind = $("#table_input .kind");
		var $companyName = $("#table_input .companyName");
		var $standard = $("#table_input .standard");
		var $receiptDate = $("#table_input .receiptDate");
		var $DeliveryDate = $("#table_input .DeliveryDate");
		

		$("#wrap").mouseover(function() {
			if (!($medicineName.is(':focus') || $price.is(':focus') || $Buyingprice.is(':focus') ||
				  $inventory.is(':focus') || $kind.is(':focus') || 
				  $companyName.is(':focus') || $standard.is(':focus') || 
				  $receiptDate.is(':focus') || $DeliveryDate.is(':focus'))) {
				$SerialNumber.focus();
			}
		});
		$("#wrap").on("click", function() {
			if (!($medicineName.is(':focus') || $price.is(':focus') || $Buyingprice.is(':focus') ||
				  $inventory.is(':focus') || $kind.is(':focus') || 
				  $companyName.is(':focus') || $standard.is(':focus') || 
				  $receiptDate.is(':focus') || $DeliveryDate.is(':focus'))) {
				$SerialNumber.focus();
			}
		});
		
		function medicine() {
			// 입력란 정규식

			//시리얼넘버가 공백일 때
			if ($SerialNumber.val() == null || $SerialNumber.val() == "") {
				alert("제품 바코드를 스캔하세요");
				$SerialNumber.focus();
				return false;
			}
			//제품이름이 공백일 때
			if ($medicineName.val() == null || $medicineName.val() == "") {
				alert("제품명을 입력하세요");
				$medicineName.focus();
				return false;
			}
			//가격이 공백일 때
			if ($price.val() == null || $price.val() == "") {
				alert("가격을 입력하세요");
				$price.focus();
				return false;
			}
			//수량이 공백일 때
			if ($inventory.val() == null || $inventory.val() == "") {
				alert("입고 수량을 입력하세요"); // 수정: "수량을 입력하세요" -> "입고 수량을 입력하세요"
				$inventory.focus();
				return false;
			}
			//입고 날짜가 공백일 때
			if ($receiptDate.val() == null || $receiptDate.val() == "") {
				alert("입고 날짜를 입력하세요");
				$receiptDate.focus();
				return false;
			}
			//유통기한이 공백일 때
			if ($DeliveryDate.val() == null || $DeliveryDate.val() == "") {
				alert("유통기한을 입력하세요");
				$DeliveryDate.focus();
				return false;
			} else {
				alert("제품 입력이 완료되었습니다.");
			}
		}
		$("#wrap #table_input .receiptDate").val(new Date().toISOString().split('T')[0]);
	</script>
</body>
</html>
