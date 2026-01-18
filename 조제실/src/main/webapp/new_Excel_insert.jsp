<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*"%>
<%@ page import="java.sql.*, java.time.LocalDate, java.time.format.DateTimeFormatter"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>엑셀 파일 데이터 가져오기</title>
<link rel="stylesheet" href="style.css">
<style>
body {
	font-family: Arial, sans-serif;
	margin: 20px;
}

table {
	border-collapse: collapse;
	width: 100%;
	margin-top: 20px;
}

th, td {
	border: 1px solid #ddd;
	padding: 8px;
	text-align: center;
}

th {
	background-color: #f2f2f2;
}

input[type="file"] {
	display: block;
	margin-bottom: 10px;
}

#uploadButton {
	display: block;
	width: 170px;
	height: 50px;
	border-radius: 10px;
	margin-top: 20px;
}
</style>
</head>
<body>
	<div id="wrap2" style="width: 100%; height: 80vh;">
		<header style="margin: -20px;">
			<jsp:include page="header.jsp"></jsp:include>
		</header>
		<div class="printer" style="width: 60vh; height: 50vh; padding-top: 20vh; margin: 0 auto;">
			<h1>엑셀 파일 데이터 가져오기</h1>
			<input type="file" id="fileInput" accept=".xlsx, .xls" />
			<table id="excelTable" style="display: block; margin-top: 20px;"></table>
		</div>
	</div>
	<table class="move_Data">
		<%
    request.setCharacterEncoding("UTF-8");
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String jdbcUrl = "jdbc:mysql://localhost:3306/tutorial2?useUnicode=true&characterEncoding=utf8";
        String dbUser = "root";
        String dbPassword = "pharmacy@1234";

        Connection conn = null;
        PreparedStatement updateStmt = null;
        PreparedStatement insertStmt = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);

            // 현재 날짜 가져오기
            LocalDate now = LocalDate.now();
            String receiptDate = now.format(DateTimeFormatter.ofPattern("yyyy-MM-dd"));

            // 요청 데이터 수집
            String[] medicineNames = request.getParameterValues("medicineName");
            String[] companyNames = request.getParameterValues("companyName");
            String[] standards = request.getParameterValues("standard");
            String[] inventories = request.getParameterValues("inventory");
            String[] buyingPrices = request.getParameterValues("buyingPrice");
            String[] deliveryDates = request.getParameterValues("deliveryDate");

            if (medicineNames != null) {
                for (int i = 0; i < medicineNames.length; i++) {
                    String medicineName = medicineNames[i];
                    String companyName = companyNames[i];
                    String standard = standards[i];
                    String inventory = inventories[i];
                    String buyingPrice = buyingPrices[i];
                    String sixDigitDate = deliveryDates[i]; // 여기서 각 행의 날짜를 가져옴
                    String formattedDate = "0000-00-00"; // 기본값

                    // 날짜 변환 (6자리 -> yyyy-MM-dd)
                    if (sixDigitDate != null && sixDigitDate.length() == 6) {
                        String year = "20" + sixDigitDate.substring(0, 2);
                        String month = sixDigitDate.substring(2, 4);
                        String day = sixDigitDate.substring(4, 6);
                        formattedDate = year + "-" + month + "-" + day;
                    }

                    // SerialNumber 찾기
                    String findSerialQuery = "SELECT serialNumber FROM testTable WHERE medicineName LIKE ?";
                    PreparedStatement findStmt = conn.prepareStatement(findSerialQuery);
                    findStmt.setString(1, "%" + medicineName + "%");
                    ResultSet rsSerial = findStmt.executeQuery();
                    String serialNumber = rsSerial.next() ? rsSerial.getString("serialNumber") : null;
                    rsSerial.close();
                    findStmt.close();

                    if (serialNumber == null || serialNumber.isEmpty()) {
    %>
                    <tr>
                        <td>
                            <input type="text" class="rollback_text" value="<%= medicineName %>" size="50">
                        </td>
                    </tr>
    <%
                        continue; // 다음 루프로 이동
                    }

                    // 데이터 업데이트 시도
                    String updateQuery = "UPDATE testTable SET inventory = inventory + ? WHERE medicineName = ? AND deliveryDate = ?";
                    updateStmt = conn.prepareStatement(updateQuery);
                    updateStmt.setString(1, inventory);
                    updateStmt.setString(2, medicineName);
                    updateStmt.setString(3, formattedDate);

                    int updatedRows = updateStmt.executeUpdate();
                    updateStmt.close();

                    if (updatedRows == 0) {
                        // 데이터가 없으면 삽입
                        String insertQuery = "INSERT INTO testTable (medicineName, companyName, standard, inventory, serialNumber, receiptDate, deliveryDate, buyingPrice, price, returnInv) "
                                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                        insertStmt = conn.prepareStatement(insertQuery);
                        insertStmt.setString(1, medicineName);
                        insertStmt.setString(2, companyName);
                        insertStmt.setString(3, standard);
                        insertStmt.setString(4, inventory);
                        insertStmt.setString(5, serialNumber);
                        insertStmt.setString(6, receiptDate);
                        insertStmt.setString(7, formattedDate);
                        insertStmt.setString(8, buyingPrice);
                        insertStmt.setString(9, "0"); // price 기본값
                        insertStmt.setString(10, "0"); // returnInv 기본값
                        insertStmt.executeUpdate();
                        insertStmt.close();
                    }
                }
            }

            out.println("<p>데이터 처리가 완료되었습니다.</p>");
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<p>데이터베이스 처리 중 오류가 발생했습니다: " + e.getMessage() + "</p>");
        } finally {
            try {
                if (updateStmt != null) updateStmt.close();
                if (insertStmt != null) insertStmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
    %>

		<tr>
			<td><button id="newInsertBtn"></button></td>
		</tr>
	</table>
	<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
	<script>
    let selectedFile;

    function processExcel() {
        const reader = new FileReader();

        reader.onload = (e) => {
            const data = new Uint8Array(e.target.result);
            const workbook = XLSX.read(data, { type: 'array' });

            const sheetName = workbook.SheetNames[0];
            const sheet = workbook.Sheets[sheetName];

            const jsonData = XLSX.utils.sheet_to_json(sheet, { header: 1, defval: '' });

            // 엑셀 데이터를 처리하여 yyyy-MM-dd로 변환
            const formattedData = jsonData.map((row) =>
                row.map((cell) => {
                    if (typeof cell === 'number') {
                        // 숫자인 경우 날짜 코드인지 확인하고 변환
                        return isExcelDate(cell) ? convertExcelDate(cell) : cell;
                    }
                    return cell; // 다른 값은 그대로 반환
                })
            );

            displayExcelData(formattedData);

            // **2초 후 서버로 데이터 자동 전송**
            setTimeout(() => {
                submitDataToServerFromTable();
            }, 2000); // 2초 (2000밀리초)
        };

        reader.onerror = () => {
            alert('파일을 읽는 중 오류가 발생했습니다.');
        };

        reader.readAsArrayBuffer(selectedFile);
    }


    // Excel 날짜인지 확인 (예: 숫자 값이 30000~50000 사이)
    function isExcelDate(value) {
        return value > 30000 && value < 50000;
    }

    // Excel 날짜를 yyyy-MM-dd로 변환
    function convertExcelDate(excelDate) {
        const excelEpoch = new Date(1899, 11, 30); // Excel 기준일: 1900-01-00
        const date = new Date(excelEpoch.getTime() + excelDate * 86400000);
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    }

    function displayExcelData(data) {
        const table = document.getElementById('excelTable');
        table.innerHTML = '';

        data.forEach((row, rowIndex) => {
            const tr = document.createElement('tr');

            row.forEach((cell) => {
                const cellElement = document.createElement(rowIndex === 0 ? 'th' : 'td');
                cellElement.textContent = cell !== null && cell !== undefined ? cell : '';
                tr.appendChild(cellElement);
            });

            table.appendChild(tr);
        });
    }

    document.getElementById('fileInput').addEventListener('change', (event) => {
        selectedFile = event.target.files[0];
        if (selectedFile) {
            processExcel();
        }
    });


    function submitDataToServerFromTable() {
        const rows = document.querySelectorAll('#excelTable tr'); // 테이블의 모든 행 가져오기
        const form = document.createElement('form');
        form.method = 'POST';

        rows.forEach((row, rowIndex) => {
            if (rowIndex === 0) return; // 헤더는 무시

            // 각 행의 td 가져오기
            const cells = row.querySelectorAll('td');
            
            // 각 셀 값 디버깅 (Console 확인용)
            console.log(`Row ${rowIndex} cells:`, cells);

            // 셀 개수 확인
            if (cells.length < 11) {
                console.warn(`Row ${rowIndex} does not have enough cells.`);
                return; // 셀이 부족하면 무시
            }

            // 각 값 가져오기
            const medicineName = cells[3]?.textContent.trim() || '';
            const companyName = cells[1]?.textContent.trim() || '';
            const standard = cells[5]?.textContent.trim() || '';
            const inventory = cells[6]?.textContent.trim() || '0';
            const buyingPrice = cells[7]?.textContent.trim() || '0';
            const deliveryDate = cells[10]?.textContent.trim() || ''; // 정확하게 10번째 셀 읽기

            console.log(`Row ${rowIndex} deliveryDate: ${deliveryDate}`); // deliveryDate 디버깅 로그

            // hidden input 생성 및 폼에 추가
            appendHiddenInput(form, 'medicineName', medicineName);
            appendHiddenInput(form, 'companyName', companyName);
            appendHiddenInput(form, 'standard', standard);
            appendHiddenInput(form, 'inventory', inventory);
            appendHiddenInput(form, 'buyingPrice', buyingPrice);
            appendHiddenInput(form, 'deliveryDate', deliveryDate);
        });

        document.body.appendChild(form);
        form.submit(); // 폼 자동 제출
    }

    // hidden input을 동적으로 생성하는 함수
    function appendHiddenInput(form, name, value) {
        const input = document.createElement('input');
        input.type = 'hidden';
        input.name = name;
        input.value = value;
        form.appendChild(input);
    }





    document.addEventListener("keydown", function(event) {
        if (event.keyCode === 106) { // '*' 키
            event.preventDefault();

            let rows = [];

            // 데이터 수집
            $(".move_Data tr").each(function() {
                let medicineName = {
                		medicineName : $(this).find('.rollback_text').val()?.trim() || ""
                };
                rows.push(medicineName);
            });

            console.log("전송할 데이터:", JSON.stringify(rows)); // JSON 확인용

            // 데이터가 없으면 중단
            if (rows.length === 0) {
                alert("전송할 데이터가 없습니다.");
                return;
            }

            // AJAX 전송
            $.ajax({
                url: 'Product_Registration2.jsp',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify(rows), // JSON 배열로 전송
                success: function(response) {
                    console.log("서버 응답:", response);
                    alert("데이터가 성공적으로 처리되었습니다.");
                    location.href = 'Product_Registration2.jsp';
                },
                error: function(xhr, status, error) {
                    console.error("데이터 전송 실패:", error);
                    alert("데이터 전송에 실패했습니다.");
                }
            });
        }
    });



    
</script>
</body>
</html>
