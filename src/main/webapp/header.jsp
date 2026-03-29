<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ include file="DBconnection.jsp"%>
<%
String userId = (session != null) ? (String) session.getAttribute("id") : null;
String SystemID = (session != null) ? (String) session.getAttribute("programID") : null;
String userInformation = null;

if (SystemID.equals("a")) {
	userInformation = "서가종로온누리약국";
} else if (SystemID.equals("D")) {
	userInformation = "시스템관리자";
} else {
	userInformation = "사무실";
}
%>
<link rel="stylesheet" href="style.css">
</head>
<header id="header" class="inv-header-scope">
	<ul>
		<li><a href="#">재고</a>
			<ul>
				<li><a href="index.jsp">재고 확인</a></li>
				<li><a href="index2.jsp">재고 수정 및 검색</a></li>
				<li><a href="Product_Registration.jsp">재고 입력</a></li>
				<li><a href="price_Fluctuation.jsp" class="onlyAdministrators">가격
						변동</a></li>
				<li><a href="batchModification.jsp">제품 일괄 수정</a></li>
			</ul></li>
		<li><a href="inventory_Exhaustion.jsp">판매</a>
			<ul>
				<li><a href="inventory_Exhaustion.jsp">판매</a></li>
			</ul></li>
		<li><a href="#">기록</a>
			<ul>
				<li><a href="priceRecord.jsp">결제기록</a></li>
				<li><a href="price_fluctuationRecord.jsp"
					class="onlyAdministrators">변동 기록</a></li>
				<li><a href="total_list.jsp" class="onlyAdministrators">통계</a></li>
			</ul></li>

		<li><a href="#">고객</a>
			<ul>
				<li><a href="salesRegistration.jsp">판매등록</a></li>
				<li><a href="customerRegistration.jsp">고객등록 / 고객수정</a></li>
			</ul></li>
		<li><a href="#">수정</a>
			<ul>
				<li><a href="modifyMedicine.jsp">제품 수정</a></li>
				<li><a href="modifyExhaustion.jsp">판매 수정</a></li>
			</ul></li>
		<li><a href="#">
				<button id="logoutButton" class="btn-4"><%=userInformation%></button>
		</a></li>
		<li><a href="#"><button id="ManagerAccount">관리자 계정
					전환</button></a></li>
	</ul>
</header>
<section id="changeBG" class="inv-admin-popup-scope">
	<div class="changeAcc">
		<div class="form-container">
			<div class="logo-container">관리자 계정 전환</div>
			<div class="closePopup">닫기 X</div>
			<div class="form">
				<div class="form-group">
					ID : <input type="text" id="AccID" placeholder="Enter your ID">
					PASSWROD : <input type="password" id="AccPassword"
						placeholder="Enter your password">
				</div>
				<button class="form-submit-btn" type="button">관리자 권한으로 실행</button>
			</div>
			<div class="loadingAcc">
				<div id="loadingBarWrapper">
					<div id="loadingBar"></div>
				</div>
				<div class="managerAcc">관리자 모드로 전환합니다.</div>
			</div>
		</div>
	</div>
</section>
<div id="warningLetter" class="inv-admin-warning-scope">
	<div class="Phrase">
		<h1>※경고!※</h1>
		<h3>관리자 권한이 필요합니다.</h3>
		<div class="warningClose">닫기 X[ESC]</div>
	</div>
</div>
<script src="jquery-3.7.1.min.js"></script>
<script src="script.js"></script>
<script>
	$(document).ready(function() {
		const currentPage = window.location.pathname.split("/").pop(); // ex: salesRegistration.jsp

	    $("#header a").each(function () {
	        const hrefPage = $(this).attr("href").split("/").pop();

	        if (currentPage === hrefPage) {
	            $(this).addClass("selectLabel");
	        }
	    });
		$("#warningLetter .Phrase .warningClose").on("click", function(){
			$("#warningLetter").hide();
		});
		$(document).on("click",  ".onlyAdministrators",function(e){
			if($("#logoutButton").text().trim() != "시스템관리자"){
				$("#warningLetter").show();
				return false;
			}
		});
		$(document).on("keydown", function(e){
			if($("#changeBG").is(":visible")){
				if(e.keyCode == 27){
					$("#changeBG").hide();
				}
			}
		});
		$("#changeBG .form-submit-btn").on("click", function () {
		    const accId = $("#AccID").val();
		    const accPw = $("#AccPassword").val();

		    $.ajax({
		        url: "loginCheck.jsp",
		        method: "POST",
		        data: {
		            userId: accId,
		            password: accPw,
		            ajax: "true" // ✅ Ajax 요청임을 명시
		        },
		        success: function (res) {
		            res = res.trim(); // ✅ 이 줄 추가

		            console.log("서버 응답:", res); // 디버깅용 콘솔 유지

		            if (res === "admin") {
		                // ✅ 관리자 애니메이션 실행
		                $("#changeBG .form-container .form, .closePopup, .logo-container").fadeOut(300);

		                setTimeout(function () {
		                    $("#changeBG .form-container").animate({ height: "110px" }, 500);
		                    $(".loadingAcc").fadeIn(300);

		                    $("#loadingBar").css("width", "0%");
		                    setTimeout(() => $("#loadingBar").css("width", "80%"), 200);
		                    setTimeout(() => {
		                        $("#loadingBar").css("width", "100%");
		                        setTimeout(function () {
		                            $("#loadingBarWrapper").fadeOut(500);
		                            setTimeout(function () {
		                                $(".managerAcc").fadeIn(500);
		                                setTimeout(() => location.reload(), 1000);
		                            }, 500);
		                        }, 500);
		                    }, 1000);
		                }, 300);

		            } else if (res === "user") {
		                alert("관리자 권한이 없는 계정입니다.");
		                $("#changeBG").hide();
		            } else {
		                alert("아이디 또는 비밀번호가 틀렸습니다.");
		            }
		        },
		        error: function () {
		            alert("서버 오류: 로그인 확인 실패");
		        }
		    });
		});




        // 로그아웃 버튼 클릭 시 AJAX 요청
        $("#logoutButton").click(function() {
            $.ajax({
                url: "logout.jsp", // 로그아웃 처리 JSP
                method: "POST",
                success: function(response) {
                    // 서버 응답이 "success"이면 로그인 페이지로 리다이렉트
                    if (response.status === "success") {
                        window.location.href = "login.jsp"; // 로그인 페이지로 리다이렉트
                    }
                },
                error: function() {
                    alert("로그아웃 처리 중 오류가 발생했습니다.");
                }
            });
        });
        $("#ManagerAccount").on("click", function(){
        	$("#changeBG").show();
        });

        $(".closePopup").on("click", function(){
        	$("#changeBG").hide();
        });
        $(document).keydown(function(e){
        	if(e.keyCode == 27 || e.key == "Escape"){
        		if($("#warningLetter").is(":visible")){
        			$("#warningLetter").hide();
        		}
        	}
        });
	});
</script>