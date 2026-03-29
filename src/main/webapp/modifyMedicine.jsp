<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ include file="sessionManager.jsp"%>
<%@ include file="DBconnection.jsp"%>
<%
String dbName = (session != null) ? (String) session.getAttribute("dbName") : null;
String id = (session != null) ? (String) session.getAttribute("id") : null;
String password = (session != null) ? (String) session.getAttribute("password") : null;

String domainType = (session != null) ? (String) session.getAttribute("domainType") : null;
if (id == null || dbName == null) {
	response.sendRedirect("login.jsp");
	return;
}

jdbcDriver = dbName;
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<link rel="stylesheet" href="style.css">
<link rel="stylesheet" href="modify/style.css">
</head>
<body>
	<div id="wrap">
		<header>
			<jsp:include page="header.jsp"></jsp:include>
		</header>
		<h1>제품 정보 검색/수정</h1>
		<section id="section">
			<span class="title">약품명 검색 : <input type="text"
				class="medicineName" placeholder=" 약품명을 입력하세요">
				<button class="search">검색</button> <br> <br> 검색 결과: <strong><span
					class="ofCases"></span>건</strong> <br>
			</span> <br> <br> <br>
			<div class="tableScroll">
				<table class="modify_table">
					<colgroup>
						<col width="10%">
						<col width="10%">
						<col width="5%">
						<col width="5%">
						<col width="10%">
						<col width="10%">
						<col width="10%">
						<col width="5%">
						<col width="5%">
						<col width="5%">
						<col width="10%">
						<col width="10%">
					</colgroup>
					<thead>
						<tr>
							<th>일련번호</th>
							<th>약품명</th>
							<th>주문최소수량</th>
							<th>재고</th>
							<th>유통기한</th>
							<th>입고 날짜</th>
							<th>종류</th>
							<th>구매가</th>
							<th>판매가</th>
							<th>제약회사</th>
							<th>규격</th>
							<th>삭제</th>
						</tr>
					</thead>
					<tbody class="tableLine_body">

					</tbody>
				</table>
			</div>
			<div class="manipulationBtn">
				<button class="save">🗂️ 저장 [F11]</button>
				<button class="plus">➕ 행 추가 [F4]</button>
				<button class="reset" type="reset">X 초기화 [F7]</button>
			</div>
		</section>
	</div>
	<div id="popup">
		<h3>검색 결과</h3>
		<div class="closeMedicine">닫기 X</div>
		<div class="popup-content">
			
		</div>
	</div>
	<script src="jquery-3.7.1.min.js"></script>
	<script>
		$(document).ready(function() {
			// enter 시 검색 버튼 클릭
			$("#wrap #section .title .medicineName").on("keydown", function(e){
				if(e.key === "Enter"){
					$("#wrap #section .title .search").click();
				}
			});
			
			//글자를 검색해서 팝업창으로 띄우기
			$("#wrap #section .title .search").on("click", function() {
				var $medicineName = $("#wrap #section .title .medicineName");
				if (!$medicineName.val()) {
					alert("제품명을 입력하세요");
					$medicineName.focus();
					return false;
				}
                $.ajax({
                    url: "productSearch.jsp", // 데이터 검색 JSP
                    method: "POST",
                    data: { medicineName: $medicineName.val() }, // LIKE 검색 조건
                    success: function (response) {
                        $(".popup-content").html(response); // 결과를 테이블에 표시
                        $("#popup").show(); // 팝업 표시
                    },
                    error: function () {
                        return false;
                    }
                });
			});
			
			//팝업창으로 나타난 데이터들을 클릭해서 불러오기
		    $("#popup").on("click", ".result-row", function () {
		    	var $medicineName = $(this).find("td:eq(0)").text().trim();
		    	console.log($medicineName);
		        var tr = $(this);
		        var targetRow = $(".list_line tr.focusTr");

		        targetRow.data("id", tr.data("id")); // ⭐ 핵심
 				$.ajax({
					url : 'modifyData.jsp',
					type : 'POST',
					data : {medicineName : $medicineName},
					success : function(response) {
						$("#wrap #section .modify_table .tableLine_body").html(response);
						$("#popup").hide();
						$("#wrap #section .ofCases").text($(".tableScroll").find(".modify_table tr").length - 1);
					},
					error : function(xhr,status,error) {
						console.error("Error:", error);
						console.log("Response:",xhr.responseText);
					}
				});
		    });
			
			$("#wrap .tableScroll").on("input",".DeliveryDate", function(){
			    if (event.target.classList.contains("DeliveryDate")) {
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
			//input box 클릭 시 전체 글자 선택
			$("#wrap #section").on("click", ".updateList input", function () {
			    // 1. 전체 초기화
			    $(".updateList").removeClass("focusRow");
			    $(".updateList td").removeClass("focusCol");
			    $(".updateList input").removeClass("focusCell");

			    // 2. 현재 요소
			    var $this = $(this);
			    var $td = $this.closest("td");
			    var $tr = $this.closest("tr");

			    // 3. row 강조
			    $tr.addClass("focusRow");

			    // 4. column index 구하기
			    var colIndex = $td.index();

			    // 5. column 전체 강조
			    $(".updateList").each(function () {
			        $(this).find("td").eq(colIndex).addClass("focusCol");
			    });

			    // 6. 현재 셀 강조
			    $this.addClass("focusCell");

			    // 7. 전체 선택
			    setTimeout(() => {
			        $this.select();
			    }, 0);
			});
			// 콤마 제거(저장용);
			function removeComma(value) {
			    return value.replace(/,/g, "");
			}
			// 저장 버튼 기능
			$("#wrap #section .manipulationBtn .save").on("click", function(){
			    var list = [];

			    $(".updateList").each(function(){

			        var row = $(this);

			        var data = {
		        	    id: row.data("id") || null,
		        	    delete: row.attr("data-delete") === "true",
			            
		        	    serialNumber: row.find(".serialNumber").val(),
			            medicineName: row.find(".medicineName").val(),
			            quantity: removeComma(row.find(".quantity").val()),
			            inventory: removeComma(row.find(".inventory").val()),
			            deliveryDate: row.find(".DeliveryDate").val(),
			            receiptDate: row.find(".receiptDate").val(),
			            kind: row.find(".kindValue").val(),
			            buyingPrice: removeComma(row.find(".buyingPrice").val()),
			            price: removeComma(row.find(".price").val()),
			            companyName: row.find(".companyName").val(),
			            standard: row.find(".standard").val()
			        };

			        list.push(data);
			    });

			    console.log("보내는 데이터:", list);

			    $.ajax({
			        url: "updateAllMedicine.jsp",
			        method: "POST",
			        contentType: "application/json",
			        data: JSON.stringify(list),

			        success: function(res){
			            if(res.success){
			                alert("저장 완료");
			            }else{
			                alert("실패");
			            }
			        }
			    });
			});
			

			//행 복사 기능
			$("#wrap .plus").on("click", function () {
			    let cloned = $(".focusRow").clone();

			    // tr 자체의 클래스 제거
			    cloned.removeClass("focusCol focusRow");
			    cloned.attr("data-id", "");

			    // 클론한 tr을 붙이기
			    $(".modify_table .tableLine_body").append(cloned);
			});

			//초기화(새로고침) 기능
			$("#wrap .reset").on("click", function () {
				location.reload();
			});
			//팝업창 닫기
			$("#popup .closeMedicine").on("click", function(){
				$("#popup").hide();
			});
			//특정 부분 행만 삭제
			$("#wrap #section .tableLine_body").on("click", ".removeTR", function(){
			    const $tr = $(this).closest("tr");
			    const id = $tr.attr("data-id");
			    if (id) {
			        // 기존 데이터 → 삭제 대상 표시
			        $tr.attr("data-delete", "true");
			        $tr.hide(); // UI에서만 숨김
			    } else {
			        // 신규 데이터 → 그냥 제거
			        $tr.remove();
			    }
			});
			
			//단축키 설정
			$(document).on("keydown", "#wrap #section .tableLine_body input, #wrap #section .tableLine_body select", function (e) {
			    const $currentInput = $(this);
			    const $currentTd = $currentInput.closest("td");
			    const colIndex = $currentTd.index();
			    const $currentTr = $currentInput.closest("tr");

			    let $targetInput = $();

			    if (e.key === "ArrowUp") {
			        e.preventDefault();
			        const $targetTr = $currentTr.prev("tr");
			        $targetInput = $targetTr.find("td").eq(colIndex).find("input, select").first().click();

			    } else if (e.key === "ArrowDown") {
			        e.preventDefault();
			        const $targetTr = $currentTr.next("tr");
			        $targetInput = $targetTr.find("td").eq(colIndex).find("input, select").first().click();

			    } else if (e.key === "ArrowLeft") {
			        e.preventDefault();
			        const $tds = $currentTr.find("td");
			        if (colIndex > 0) {
			            $targetInput = $tds.eq(colIndex - 1).find("input, select").first().click();
			        }

			    } else if (e.key === "ArrowRight") {
			        e.preventDefault();
			        const $tds = $currentTr.find("td");
			        if (colIndex < $tds.length - 1) {
			            $targetInput = $tds.eq(colIndex + 1).find("input, select").first().click();
			        }

			    }
			    else {
			        return;
			    }

			    if ($targetInput.length) {
			        $targetInput.focus();
			        if ($targetInput.is("input")) {
			            $targetInput.select();
			        }
			    }
			});
			$(document).on("keydown", function(e){
				//저장 단축키
				if(e.key === "F11"){
					e.preventDefault(); 
					$("#wrap #section .manipulationBtn .save").click();
				}
				//행 추가 단축키
				if(e.key === "F4"){
					e.preventDefault(); 
					$("#wrap #section .manipulationBtn .plus").click();
				}
				//새로고침 단축키(F5 -> F7로 변경)
				if(e.key === "F7"){
					e.preventDefault(); 
					$("#wrap #section .manipulationBtn .reset").click();
				}
				//기존 새로고침 단축키 방지
				if(e.key === "F5"){
					e.preventDefault(); 
				}
			});
			//숫자 쉼표 정규식
			function addComma(value) {
			    if (!value) return "";
			    return value.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
			}
			//입력할 때 정규식 적용(숫자 쉼표)
			$("#wrap .modify_table .tableLine_body").on("input", ".price, .buyingprice, .inventory, .quantity", function(){
				var $value = $(this).val();
				$value = $value.replace(/[^0-9]/g, "")
				$(this).val(addComma($value));
			});
		});
	</script>
</body>
</html>
