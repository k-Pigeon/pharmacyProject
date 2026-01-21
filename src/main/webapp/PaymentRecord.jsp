<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.text.*"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>판매 내역</title>
    <link rel="stylesheet" href="style.css">
    <style>
        /* 기본 레이아웃 설정 */
        #wrap {
            display: block;
            width: 100%;
            height: 100vh;
        }
        #wrap #flex_screen {
            display: flex;
            width: 100%;
            height: 100vh;
        }
        .filter_UI {
            position: absolute;
    		display: block;
    		width: 100%;
   			transform: translateY(15vh);
    		text-align: center;
        }
        #wrap #flex_screen .leftScreen,
        #wrap #flex_screen .rightScreen {
            display: block;
            flex: 1;
            width: 100%;
            height: 100%;
            padding-top: 20vh;
            overflow-y: auto; /* 스크롤 추가 */
        }
        .filter_UI #selectPhone,
        .filter_UI #selectName {
     	  	height: 40px;
    		width: 210px;
    		font-size: 20px;
        }

        /* 테이블 스타일링 */
        table {
            width: 90%;
            margin: 20px auto; /* 수평 중앙 정렬 및 간격 */
            border-collapse: collapse;
            border-radius: 8px;
            overflow: hidden; /* 테두리 반경 적용을 위한 요소 */
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1); /* 그림자 효과 */
        }
        th, td {
            padding: 12px 15px;
            text-align: center;
        }
        th {
            background-color: #f2f2f2;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 1px;
        }
        td {
            background-color: #ffffff;
        }
        tr:nth-child(even) td {
            background-color: #f9f9f9;
        }
        tr:hover td {
            background-color: #e9e9e9; /* hover 효과 */
            cursor: pointer; /* 클릭 가능 표시 */
        }

        /* 팝업 스타일 */
        #resultsContainer {
            width: 80%; /* 너비 설정 */
            max-width: 1000px; /* 최대 너비 설정 */
            height: 600px; /* 높이 설정 */
            margin: 0 auto; /* 수평 중앙 정렬 */
            padding: 20px; /* 내부 여백 */
            overflow-y: auto; /* 스크롤 가능 */
            border: 1px solid #ddd; /* 테두리 */
            background-color: #fff; /* 배경색 */
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1); /* 그림자 효과 */
            position: fixed; /* 고정 위치 설정 */
            top: 50%; /* 수직 중앙 */
            left: 50%; /* 수평 중앙 */
            transform: translate(-50%, -50%); /* 중앙 정렬 */
            display: none; /* 기본적으로 숨김 */
            z-index: 999; /* 다른 요소 위에 표시 */
            border-radius: 10px; /* 테두리 반경 추가 */
        }
        .rightScreen tr.selected {
    	    background-color: #007bff; /* 선택된 행의 배경색 */
    	    color: white; /* 선택된 행의 텍스트 색상 */
    	}
    	.rightScreen tr.selected:hover {
    	    background-color: #0056b3; /* 선택된 행이 마우스로 커서가 올려졌을 때 배경색 */
    	}
    	/* 헤더 텍스트 스타일링 */
h3 {
    width: 80%;
    padding: 10px 0;
    margin: 20px auto;
    text-align: center;
    font-size: 24px; /* 글자 크기 조정 */
    color: #333; /* 텍스트 색상 */
    background-color: #f7f7f7; /* 배경 색상 */
    border-radius: 8px; /* 둥근 테두리 */
    box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.1); /* 그림자 효과 */
    text-transform: uppercase; /* 대문자 변환 */
    letter-spacing: 1.2px; /* 글자 간격 */
    font-weight: bold;
}

/* Memo란 스타일링 */
textarea.personalMemo,
textarea.salesMemo {
    display: block;
    width: 80%;
    height: 25%;
    margin: 20px auto; /* 수평 중앙 정렬 및 간격 */
    padding: 15px; /* 패딩 추가 */
    border: 1px solid #ccc; /* 테두리 색상 조정 */
    border-radius: 10px; /* 둥근 테두리 */
    box-shadow: 0px 4px 8px rgba(0, 0, 0, 0.1); /* 그림자 효과 */
    resize: none;
    font-size: 16px; /* 글자 크기 조정 */
    font-family: Arial, sans-serif; /* 글꼴 */
    color: #555; /* 텍스트 색상 */
    background-color: #f9f9f9; /* 배경 색상 */
    transition: border-color 0.3s ease; /* 테두리 색상 전환 효과 */
}

/* Memo란 포커스 상태 스타일링 */
textarea.personalMemo:focus,
textarea.salesMemo:focus {
    border-color: #007bff; /* 포커스 시 테두리 색상 변경 */
    outline: none; /* 기본 포커스 효과 제거 */
}
#wrap #flex_screen .leftScreen .memoAjax,
#wrap #flex_screen .rightScreen .memoAjax{
	display: block;
    width: 80%;
    height: 7%;
    margin: 0 auto;
    font-size: 25px;
    border-radius: 12px;
    background-color: powderblue;
}
    	
    </style>
</head>
<body>
    <header>
        <%@ include file="header.jsp" %>
    </header>
    <h1 style="position: fixed; top: 7%; width: 100%; height: 50px; text-align: center;">판매내역</h1>
    <div class="filter_UI">
        <input type="text" id="selectPhone" placeholder="전화번호를 입력하세요">
        <input type="text" id="selectName" placeholder="성함을 입력하세요">
    </div>
    <div id="wrap">
        <div id="flex_screen">
            <div class="leftScreen">
                <!-- 초기 로드 시 빈 테이블 -->
                <h3 style="width:80%;padding:0;margin:0 auto;">회원 메모</h3>
                <textarea class="personalMemo" style="display: block;width: 80%;height: 25%;border: 1px solid black;resize: none;border-radius:10px;box-shadow: 0px 0px 5px black;padding: 0;margin: 0 auto;"></textarea>
        		<input type="button" class="memoAjax" value="저장" name="individualMemo">
                <table>
                    <thead>
                        <tr>
                            <th>의약품 이름</th>
                            <th>구매 가격</th>
                            <th>판매 가격</th>
                            <th>재고</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td colspan="4">No data available</td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <div class="rightScreen">
                <!-- 초기 로드 시 빈 테이블 -->
                <h3 style="width:80%;padding:0;margin:0 auto;">판매 메모</h3>
                <textarea class="salesMemo" style="display: block;width: 80%;height: 25%;border: 1px solid black;resize: none;border-radius:10px;box-shadow: 0px 0px 5px black;padding: 0;margin: 0 auto;"></textarea>
		        <input type="button" class="memoAjax" value="저장" name="salesMemo">
                <table>
                    <thead>
                        <tr>
                            <th>성함</th>
                            <th>전화번호</th>
                            <th>판매 날짜</th>
                            <th>수정 / 삭제<th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td colspan="5">No data available</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    
    <!-- 결과를 표시할 영역을 wrap 밖으로 이동 -->
    <div class="rightScreen" id="resultsContainer">
    <span class="closePopup" style="font-size: 40px;float: right;border: 1px solid black;width: 145px;height: 60px;border-radius: 10px;text-align: center;"><b>닫기 X</b></span>
    </div>
    
</body>
<script src="jquery-3.7.1.min.js"></script>
<script>
$(document).ready(function(){
    // 전화번호로 고객 검색
    $("#selectPhone").on("keyup", function(e){
        if(e.keyCode == 13){
            var selectPhone = $(this).val();
            var phoneID = $(this).attr('id');
            $.ajax({
                url: "phoneAjax.jsp", // AJAX 요청할 JSP 파일
                type: "POST",
                data: { 
                	selectPhone: selectPhone,
                	id: phoneID
                },
                success: function(response){
                    if(response.trim() !== "fail"){
                        // 결과를 rightScreen에 삽입하고 표시
                        $("#resultsContainer").html(response).show();

                        // 각 행 클릭 이벤트 추가
                        $("#resultsContainer tr").on("click", function(){
                            var clientName = $(this).find("td").eq(0).text(); // 성함
                            var clientNumber = $(this).find("td").eq(1).text(); // 전화번호
                            fetchClientDetails(clientName, clientNumber); // 상세정보 가져오기

                            // 팝업을 닫기 위한 코드
                            $("#resultsContainer").hide(); // 결과 컨테이너 숨김
                        });
                    } else {
                        alert("데이터가 없습니다");
                        $("#resultsContainer").html("").hide(); // 이전 결과 제거
                    }
                },
                error: function(){
                    alert("데이터가 없습니다");
                    $("#resultsContainer").html("").hide(); // 이전 결과 제거
                }
            });
        }
    });
    
    $("#selectName").on("keyup", function(e){
        if(e.keyCode == 13){
            var selectName = $(this).val();
            var nameID = $(this).attr('id');
            $.ajax({
                url: "phoneAjax.jsp", // AJAX 요청할 JSP 파일
                type: "POST",
                data: { 
                	selectName: selectName,
                	id: nameID
                },
                success: function(response){
                    if(response.trim() !== "fail"){
                        // 결과를 rightScreen에 삽입하고 표시
                        $("#resultsContainer").html(response).show();

                        // 각 행 클릭 이벤트 추가
                        $("#resultsContainer tr").on("click", function(){
                            var clientName = $(this).find("td").eq(0).text(); // 성함
                            var clientNumber = $(this).find("td").eq(1).text(); // 전화번호
                            fetchClientDetails(clientName, clientNumber); // 상세정보 가져오기

                            // 팝업을 닫기 위한 코드
                            $("#resultsContainer").hide(); // 결과 컨테이너 숨김
                        });
                    } else {
                        alert("데이터가 없습니다");
                        $("#resultsContainer").html("").hide(); // 이전 결과 제거
                    }
                },
                error: function(){
                    alert("데이터가 없습니다");
                    $("#resultsContainer").html("").hide(); // 이전 결과 제거
                }
            });
        }
    });

    // 선택된 고객의 상세 정보를 가져오는 함수
	function fetchClientDetails(clientName, clientNumber) {
	    $.ajax({
	        url: "clientDetails.jsp", // 고객 상세 정보 요청할 JSP
	        type: "POST",
	        data: { clientName: clientName, clientNumber: clientNumber },
    	    success: function(response) {
	            $(".rightScreen table").remove(); // 기존 테이블 제거
	            $(".rightScreen").append(response); // 결과를 rightScreen에 추가
	
	            // rightScreen에 삽입된 테이블의 각 행 클릭 이벤트 추가
	            $(".rightScreen tr").on("click", function(){
	                $(".rightScreen tr").removeClass("selected"); // 모든 tr에서 선택 클래스 제거
	                $(this).addClass("selected"); // 클릭된 tr에 선택 클래스 추가
	
	                var saleDate = $(this).find("td").eq(2).text(); // saleDate를 가져옴
	                fetchSalesDetails(saleDate); // leftScreen에 saleDate 기준 정보 가져오기
	            });
	        },
	        error: function() {
	            alert("상세 정보를 가져오지 못했습니다.");
	        }
	    });
	}
	
	// 선택된 판매 날짜로 판매 내역을 가져오는 함수
	function fetchSalesDetails(saleDate) {
		var clientName = $("#wrap #flex_screen .rightScreen table tr.selected td:eq(0)").text();//회원이름
		var clientNumber = $("#wrap #flex_screen .rightScreen table tr.selected td:eq(1)").text();//회원번호
	    $.ajax({
	        url: "salesDetails.jsp", // 판매 내역 요청할 JSP
	        type: "POST",
	        data: { 
	        	saleDate: saleDate,
	        	clientName : clientName,
	        	clientNumber : clientNumber
	        },
	        success: function(response) {
	            $(".leftScreen table").remove(); // 기존 테이블 제거
	            $(".leftScreen").append(response); // 결과를 leftScreen에 추가
	        },
	        error: function() {
	            alert("판매 내역을 가져오지 못했습니다.");
	        }
	    });
	}

    // 방향키로 tr 이동 및 스크롤 이동
    $(document).keydown(function(e) {
	    var selected = $(".rightScreen tr.selected");
	
	    if (selected.length > 0) { // 선택된 tr이 있는 경우
	        var newSelected;
	        if (e.keyCode == 38) { // 위쪽 방향키
	            newSelected = selected.prev("tr");
	        } else if (e.keyCode == 40) { // 아래쪽 방향키
	            newSelected = selected.next("tr");
	        }
	
	        // newSelected가 존재하고, 요소가 있는지 확인
	        if (newSelected && newSelected.length > 0) {
	            selected.removeClass("selected");
	            newSelected.addClass("selected");
	
	            // 선택된 tr이 화면에 보이도록 스크롤 조정
	            var container = $(".rightScreen");
	            var containerTop = container.scrollTop();
	            var containerHeight = container.height();
	            var selectedTop = newSelected.position().top;
	
	            if (selectedTop < 0) {
	                container.scrollTop(containerTop + selectedTop);
	            } else if (selectedTop > containerHeight) {
	                container.scrollTop(containerTop + selectedTop - containerHeight + newSelected.height());
	            }
	
	            // 새로 선택된 행 클릭 이벤트 트리거
	            newSelected.trigger('click');
	        }
	    }
	});

    //회원 전용 메모
    $("#wrap #flex_screen .leftScreen .memoAjax").on("click", function(){
		var memoNotice = $("#wrap #flex_screen .leftScreen").find(".personalMemo").val();//메모로 저장할 내용
		var clientName = $("#wrap #flex_screen .rightScreen table tr.selected td:eq(0)").text();//회원이름
		var clientNuber = $("#wrap #flex_screen .rightScreen table tr.selected td:eq(1)").text();//회원번호
		var dateVal = $("#wrap #flex_screen .rightScreen table tr.selected td:eq(2)").text();
		
		$.ajax({
			url : 'memoProcess2.jsp',
			type:'POST',
			data:{
				memoNotice : memoNotice,
				clientName : clientName,
				clientNuber : clientNuber,
				dateVal : dateVal
			},
			success : function(response){
				alert("메모가 저장되었습니다.");
			},
			error : function(xhr, status, error){
				alert("메모 저장 오류 : " + response);
			}
		});
	});
    
    //판매란 전용 메모
    $("#wrap #flex_screen .rightScreen .memoAjax").on("click", function(){
		var memoNotice = $("#wrap #flex_screen .rightScreen").find(".salesMemo").val();
		var dateVal = $("#wrap #flex_screen .rightScreen table tr.selected td:eq(2)").text();
		$.ajax({
			url : 'memoProcess.jsp',
			type:'POST',
			data:{
				memoNotice : memoNotice,
				dateVal : dateVal
			},
			success : function(response){
				alert("메모가 저장되었습니다.");
			},
			error : function(xhr, status, error){
				alert("메모 저장 오류 : " + response);
			}
		});
	});
});



</script>
</html>
