<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<style>
.settingWrap{
    width: 85vh;
    height: 100vh;
    margin: 0 auto;
    font-size: x-large;
}
.settingWrap h1{
    text-align:center;
    transform: translateY(100%);
}
.settingWrap .settingTable{
    transform: translateY(10vh);
    border:1px solid black;
}
.settingWrap .settingTable th,
.settingWrap .settingTable td{
    border:1px solid black;
}
.alert-ring{
    width: 100px;
    height: 100px;
    background-color: red;
    display: none; /* 기본적으로 숨겨짐 */
}
</style>
</head>
<body>
    <div class="settingWrap">
        <h1><strong>사용자 지정 설정</strong></h1>
        <table class="settingTable">
            <tr>
                <th>유통기한 경고 알림 그라데이션</th>
                <td>
                    <select class="Notification">
                        <option value="0">켜기</option>
                        <option value="1">끄기</option>
                    </select>
                </td>
            </tr>
        </table>
    </div>
	<script src="jquery-3.7.1.min.js"></script><script src="script.js"></script>
    <script>
        // 페이지 로드 시 로컬 스토리지에서 값 읽어오기
        window.onload = function() {
            var notificationSetting = localStorage.getItem("notificationSetting");
            if (notificationSetting === "1") {
                document.querySelector('.alert-ring').style.display = "none"; // 끄기
                document.querySelector('.alert-ring:nth-child(2)').style.display = "none"; // 끄기
                document.querySelector('.alert-ring:nth-child(3)').style.display = "none"; // 끄기
                document.querySelector('.Notification').value = "1";
            } else {
                document.querySelector('.alert-ring').style.display = "block"; // 켜기
                document.querySelector('.alert-ring:nth-child(2)').style.display = "block"; // 끄기
                document.querySelector('.alert-ring:nth-child(3)').style.display = "block"; // 끄기
                document.querySelector('.Notification').value = "0";
            }
        };

        // 선택 값 변경 시 로컬 스토리지와 display 속성 변경
        document.querySelector('.Notification').addEventListener('change', function() {
            var settingValue = this.value;
            localStorage.setItem("notificationSetting", settingValue); // 로컬 스토리지에 저장
            if (settingValue === "1") {
                document.querySelector('.alert-ring').style.display = "none"; // 끄기
            } else {
                document.querySelector('.alert-ring').style.display = "block"; // 켜기
            }
        });
    </script>
</body>
</html>
