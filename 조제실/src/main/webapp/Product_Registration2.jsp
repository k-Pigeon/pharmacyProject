<%@ page contentType="text/html; charset=UTF-8"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="org.json.JSONObject"%>
<%@ page import="java.io.BufferedReader"%>

<%
    // JSON 데이터 읽기
    StringBuilder sb = new StringBuilder();
    String line;
    BufferedReader reader = request.getReader();

    while ((line = reader.readLine()) != null) {
        sb.append(line);
    }

    // JSON 데이터가 있을 경우 세션에 저장
    if (sb.length() > 0) {
        JSONArray jsonArray = new JSONArray(sb.toString());
        session.setAttribute("productData", jsonArray); // 세션에 저장
    }
%>
<%
    JSONArray productData = (JSONArray) session.getAttribute("productData");
%>
<html>
<head>
<title>Product Table</title>
<link rel="stylesheet" href="style.css">
<style>
#table_input {
	width: 100%;
	max-width: 100%; /* 화면을 넘지 않도록 설정 */
	background-color: #f9f9f9; /* 아주 밝은 회색 배경 */
	border-radius: 8px;
	border: 1px solid #ddd; /* 밝은 테두리 */
	box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05); /* 부드러운 그림자 */
	table-layout: auto; /* 테이블의 자동 크기 조정 */
	font-size:25px;
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
#table_input input[type="text"], #table_input input[type="date"],
	#table_input select {
	width: 100%;
	padding: 10px;
	margin: -4px;
	background-color: #ffffff; /* 흰색 배경 */
	color: #333333; /* 어두운 텍스트 */
	border: 1px solid #ccc; /* 회색 테두리 */
	border-radius: 4px;
	box-shadow: inset 0 1px 3px rgba(0, 0, 0, 0.05);
	transition: border-color 0.3s ease, box-shadow 0.3s ease;
}

/* 입력창 포커스 시 스타일 */
#table_input input[type="text"]:focus, #table_input input[type="date"]:focus,
	#table_input select:focus {
	border-color: #4CAF50; /* 포커스 시 초록색 테두리 */
	box-shadow: 0 0 5px rgba(76, 175, 80, 0.3); /* 초록빛 하이라이트 */
	outline: none;
}
</style>
</head>
<body>
	<div id="wrap">
		<header>
			<jsp:include page="header.jsp"></jsp:include>
		</header>
		<h1 style="text-align: center; margin: 70px; position: fixed; width: 100%;">미입력 재품</h1>
		<b style="width: 1500px;margin: 0 auto;padding: 0;display: block;position: fixed;transform: translate(170px, 160px);">
			<span>**</span>제품명의 일부가 잘리는 경우가 있으니, 한번 더 검토해주시기 바랍니다.<span>**</span>
		</b>
		<table style="display:block;border: 1px solid black; min-width: 1500px; height:600px;padding: 0; margin: 0 auto;margin-top: 20vh;overflow: scroll;" id="table_input">
			<thead>
				<tr>
					<th style="background: none; border: hidden;">제품코드<br></th>
					<th style="background: none; border: hidden; width:350px;">제품명</th>
					<th style="background: none; border: hidden;">유통기한</th>
					<th style="background: none; border: hidden;">입고 수량</th>
					<th style="background: none; border: hidden;">판매가격</th>
					<th style="background: none; border: hidden;">사입가격</th>
					<th style="background: none; border: hidden;">회사명</th>
					<th style="background: none; border: hidden;">규격</th>
					<th style="background: none; border: hidden;">입고 날짜</th>
				</tr>
			</thead>
			<tbody>
				<%
                if (productData != null) {
                    int rowCount = 0; // 번호 출력을 위해 추가

                    for (int i = 0; i < productData.length(); i++) {
                        JSONObject obj = productData.getJSONObject(i);
                        String medicineName = obj.optString("medicineName", "").trim();

                        // "사입합계"와 공백 제외
                        if (!medicineName.isEmpty() && !"사입합계".equals(medicineName)) {
                            rowCount++; // 유효한 데이터만 번호 증가
            %>
				<tr class="insertTR">
					<td style="border: none;"><input type="text" name="SerialNumber[]" class="SerialNumber" placeholder="일련번호 입력" autocomplete="off"></td>
					<td style="border: none;"><input type="text" name="medicineName" class="medicineName" value="<%= medicineName %>"></td>
					<td style="border: none;"><input type="text" name="DeliveryDate[]" class="DeliveryDate" placeholder="yy/mm/dd" pattern="\d{2}/\d{2}/\d{2}" required></td>
					<td style="border: none;"><input type="text" name="inventory[]" class="inventory"></td>
					<td style="border: none;"><input type="text" name="Buyingprice[]" class="Buyingprice"></td>
					<td style="border: none;"><input type="text" name="price[]" class="price"></td>
					<td style="border: none;"><input type="text" name="companyName[]" class="companyName"></td>
					<td style="border: none;"><input type="text" name="standard[]" class="standard"></td>
					<td style="border: none;"><input type="date" name="receiptDate[]" class="receiptDate"></td>
				</tr>
				<%
                        }
                    }

                    // 유효한 데이터가 없을 경우 메시지 출력
                    if (rowCount == 0) {
            %>
				<tr>
					<td colspan="2">유효한 데이터가 없습니다.</td>
				</tr>
				<%
                    }
                } else {
            %>
				<tr>
					<td colspan="2">데이터가 없습니다.</td>
				</tr>
				<%
                }
            %>
			</tbody>
		</table>
	</div>
	<script src="jquery-3.7.1.min.js"></script>
	<script>
		let elements = document.getElementsByClassName('receiptDate');
		let today = new Date().toISOString().substring(0, 10); // YYYY-MM-DD 형식의 날짜
	
		for (let i = 0; i < elements.length; i++) {
		    elements[i].value = today; // 각 요소에 날짜 설정
		}
		
		document.addEventListener("input", function (event) {
		    if (event.target.classList.contains("DeliveryDate") || event.target.classList.contains("receiptDate")) {
		        let input = event.target.value.replace(/[^0-9]/g, ""); // 숫자 외 제거
		        let formatted = "";

		        if (input.length > 2) {
		            formatted += input.substring(0, 2) + "/"; // 첫 번째 슬래시 추가
		        } else {
		            formatted += input;
		        }

		        if (input.length > 4) {
		            formatted += input.substring(2, 4) + "/"; // 두 번째 슬래시 추가
		            formatted += input.substring(4, 6); // 나머지 추가
		        } else if (input.length > 2) {
		            formatted += input.substring(2); // 첫 슬래시 뒤 나머지 추가
		        }
		        event.target.value = formatted.slice(0, 8); // 최대 8자리 유지
		    }
		});

		document.addEventListener("keydown", function(event) {
		    if (event.key === "F11" || event.keyCode === 106) { // F11 또는 숫자 키패드 '*'
		        event.preventDefault();

		        let rows = [];
		        let isValid = true;

		        // 데이터 수집
		        document.querySelectorAll('.insertTR').forEach(function(row) {
		            let rowData = {
		                serialNumber: row.querySelector('.SerialNumber').value.trim(),
		                medicineName: row.querySelector('.medicineName').value.trim(),
		                deliveryDate: row.querySelector('.DeliveryDate').value.trim(),
		                inventory: row.querySelector('.inventory').value.trim(),
		                buyingPrice: row.querySelector('.Buyingprice').value.trim(),
		                price: row.querySelector('.price').value.trim(),
		                companyName: row.querySelector('.companyName').value.trim(),
		                standard: row.querySelector('.standard').value.trim(),
		                receiptDate: row.querySelector('.receiptDate').value.trim()
		            };

		            // 데이터 유효성 검사
		            if (!rowData.medicineName || !rowData.serialNumber) {
		                alert("제품명과 제품코드는 반드시 입력해야 합니다.");
		                isValid = false;
		                return;
		            }

		            rows.push(rowData);
		        });

		        // 데이터가 없거나 유효하지 않으면 중단
		        if (!isValid || rows.length === 0) {
		            alert("전송할 데이터가 없습니다.");
		            return;
		        }

		        // AJAX 전송
		        $.ajax({
		            url: 'insertProductData.jsp', // 데이터 삽입 처리용 JSP 파일
		            type: 'POST',
		            contentType: 'application/json; charset=utf-8',
		            data: JSON.stringify(rows), // JSON 형식으로 데이터 전송
		            success: function(response) {
		                alert("데이터가 성공적으로 입력되었습니다!");
		                console.log("서버 응답:", response);
		                location.reload(); // 새로고침
		            },
		            error: function(xhr, status, error) {
		                console.error("데이터 전송 실패:", error);
		                alert("데이터 입력 중 오류가 발생했습니다.");
		            }
		        });
		    }
		});

	</script>
</body>
</html>