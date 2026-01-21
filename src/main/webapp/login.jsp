<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>로그인</title>
<link rel="stylesheet" href="style.css">
<style>
body {
	font-family: Arial, sans-serif;
	background-color: #f0f0f0;
	display: flex;
	justify-content: center;
	align-items: center;
	height: 100vh;
	margin: 0;
}

#roundUI {
	background-color: white;
	padding: 40px;
	border-radius: 20px;
	box-shadow: 0 8px 16px rgba(0, 0, 0, 0.1);
	width: 300px;
	text-align: center;
}

h2 {
	margin-bottom: 20px;
	font-size: 24px;
	color: #4A4A4A;
}

form {
	display: flex;
	flex-direction: column;
}

label {
	font-size: 16px;
	margin-bottom: 5px;
	color: #4A4A4A;
}

input[type="text"], input[type="password"] {
	padding: 10px;
	margin-bottom: 20px;
	border: 1px solid #cccccc;
	border-radius: 10px;
	font-size: 16px;
}

input[type="submit"] {
	background-color: #6a0dad;
	color: white;
	border: none;
	padding: 10px;
	border-radius: 10px;
	cursor: pointer;
	font-size: 16px;
	transition: background-color 0.3s;
}

input[type="submit"]:hover {
	background-color: #540d9e;
}
</style>
</head>
<body>
	<div id="roundUI">
		<h2>로그인 페이지</h2>
		<form action="loginCheck.jsp" method="post">
			<label for="userId">아이디:</label> <input type="text" id="userId" name="userId" required><br>
			<br> <label for="password">비밀번호:</label> <input type="password" id="password" name="password" required><br>
			<br> <input type="submit" value="로그인">
		</form>
	</div>
</body>
</html>
