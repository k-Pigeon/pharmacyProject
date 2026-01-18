<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
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
#cyberpunkButton {
	font-family: 'Orbitron', sans-serif;
	font-size: 18px;
	color: #00f9ff;
	border: 2px solid #00f9ff;
	padding: 14px 28px;
	border-radius: 8px;
	cursor: pointer;
	letter-spacing: 2px;
	position: relative;
	overflow: hidden;
	box-shadow: 0 0 10px #00f9ff, 0 0 20px #00f9ff inset;
	transition: all .3s ease;
	text-transform: uppercase;
	display: inline-block;
	background: transparent;
}

/* 빛 스치는 효과 */
#cyberpunkButton::before {
	content: '';
	position: absolute;
	top: 0;
	left: -75%;
	width: 50%;
	height: 100%;
	background: linear-gradient(120deg, transparent, rgba(0, 255, 255, .5), transparent);
	transform: skewX(-30deg);
}

#cyberpunkButton:hover::before {
	animation: shine .7s ease-in-out;
}

@keyframes shine {
	0% { left: -75%; }
	100% { left: 125%; }
}

#cyberpunkButton:hover {
	background: rgba(0, 255, 255, .1);
	box-shadow: 0 0 15px #00f9ff, 0 0 40px #00f9ff inset;
	color: black;
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
			<input type="file" id="fileInput" accept=".xlsx, .xls" style="opacity:0;"/>
			<label for="fileInput" id="cyberpunkButton">Choose File
			</label>
			<!-- <button onclick="downloadCSV()">CSV 다운로드</button> -->
			<table id="excelTable" style="display: none; margin-top: 20px;"></table>
		</div>
	</div>

<%
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String jdbcUrl = "jdbc:mysql://localhost:3306/tutorial2?useUnicode=true&characterEncoding=utf8";
        String dbUser = "root";
        String dbPassword = "pharmacy@1234";

        Connection conn = null;
        PreparedStatement selectStmt = null;
        PreparedStatement updateStmt = null;
        PreparedStatement insertStmt = null; // ✅ 판매 기록 저장을 위한 Statement

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);
            
            // 트랜잭션 시작
            conn.setAutoCommit(false);

            String[] serialNumbers = request.getParameterValues("serialNumber");
            String[] inventories = request.getParameterValues("inventory");

            out.println("<html><head><style>");
            out.println("table { width: 100%; border-collapse: collapse; margin: 20px 0; }");
            out.println("th, td { border: 1px solid black; padding: 10px; text-align: center; }");
            out.println("th { background-color: #f2f2f2; }");
            out.println(".same-medicine { border-top: 2px solid blue; }");
            out.println("</style></head><body>");
            out.println("<h2>재고 차감 및 판매 내역 저장 결과</h2>");
            out.println("<table>");
            out.println("<tr><th>Serial Number</th><th>유통기한</th><th>의약품명</th><th>원래 개수</th><th>차감량</th><th>남은 차감량</th><th>현재 재고</th></tr>");

            String previousMedicineName = "";

            for (int i = 0; i < serialNumbers.length; i++) {
                String serialNumber = serialNumbers[i];
                String numericInventory = inventories[i].replaceAll("[^0-9.]","");
                double inventoryToDeduct = numericInventory.isEmpty() ? 0 : Double.parseDouble(numericInventory);

                while (inventoryToDeduct > 0) {
                    // ✅ 가장 유통기한이 짧고 재고가 남아있는 제품을 찾음
                    String selectQuery = "SELECT serialNumber, CAST(inventory AS DECIMAL(12,4)) AS inventory, deliveryDate, medicineName, Buyingprice, price " +
                                         "FROM testTable " +
                                         "WHERE CAST(serialNumber AS UNSIGNED) = ? AND CAST(inventory AS DECIMAL(12,4)) > 0 " +
                                         " AND STR_TO_DATE(deliveryDate, '%Y-%m-%d') >= CURDATE() " +
                                         "ORDER BY STR_TO_DATE(deliveryDate, '%Y-%m-%d') ASC LIMIT 1";

                    selectStmt = conn.prepareStatement(selectQuery);
                    selectStmt.setString(1, serialNumber);
                    ResultSet rs = selectStmt.executeQuery();

                    if (rs.next()) {
                        String currentSerial = rs.getString("serialNumber");
                        double originalInventory = rs.getDouble("inventory");
                        double currentInventory = originalInventory;
                        String deliveryDate = rs.getString("deliveryDate");
                        String medicineName = rs.getString("medicineName");
                        String buyingPrice = rs.getString("Buyingprice");
                        String sellingPrice = rs.getString("price");

                        double deduction = Math.min(inventoryToDeduct, currentInventory);
                        double updatedInventory = currentInventory - deduction;

                        // ✅ 재고 업데이트
                        String updateQuery = "UPDATE testTable SET inventory = ? WHERE serialNumber = ? AND deliveryDate = ?";
                        updateStmt = conn.prepareStatement(updateQuery);
                        updateStmt.setDouble(1, updatedInventory);
                        updateStmt.setString(2, currentSerial);
                        updateStmt.setString(3, deliveryDate);

                        int updatedRows = updateStmt.executeUpdate();
                        if (updatedRows == 0) {
                            out.println("<tr><td colspan='7' style='color:red;'>❌ 업데이트 실패! SerialNumber: " + currentSerial + " / DeliveryDate: " + deliveryDate + "</td></tr>");
                        }

                        // ✅ 판매 내역 저장 (salesRecord 테이블)
                        String insertQuery = "INSERT INTO salesRecord (saleDate, medicineName, Buyingprice, price, inventory, SerialNumber, DeliveryDate) " +
                                             "VALUES (NOW(), ?, ?, ?, ?, ?, ?)";
                        insertStmt = conn.prepareStatement(insertQuery);
                        insertStmt.setString(1, medicineName);
                        insertStmt.setString(2, buyingPrice);
                        insertStmt.setString(3, sellingPrice);
                        insertStmt.setString(4, String.format("%.2f", deduction));
                        insertStmt.setString(5, currentSerial);
                        insertStmt.setString(6, deliveryDate);

                        insertStmt.executeUpdate();

                        inventoryToDeduct -= deduction;

                        // ✅ 같은 medicineName이면 CSS 추가
                        String rowClass = medicineName.equals(previousMedicineName) ? "same-medicine" : "";
                        out.println("<tr class='" + rowClass + "'><td>" + currentSerial + "</td><td>" + deliveryDate + "</td><td>" + medicineName + "</td><td>" +
                                    String.format("%.2f", originalInventory) + "</td><td>" +
                                    String.format("%.2f", deduction) + "</td><td>" +
                                    String.format("%.2f", inventoryToDeduct) + "</td><td>" +
                                    String.format("%.2f", updatedInventory) + "</td></tr>");

                        previousMedicineName = medicineName;
                    } else {
                        out.println("<tr><td colspan='7'>✅ SerialNumber " + serialNumber + "에 대한 모든 차감이 완료되었습니다.</td></tr>");
                        break;
                    }
                    rs.close();
                }
            }

            // ✅ 모든 차감이 완료되면 커밋
            conn.commit();

            out.println("</table></body></html>");

        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) conn.rollback(); // 오류 발생 시 롤백
            out.println("<p style='color: red;'>❌ 데이터베이스 처리 중 오류 발생: " + e.getMessage() + "</p>");
        } finally {
            try {
                if (selectStmt != null) selectStmt.close();
                if (updateStmt != null) updateStmt.close();
                if (insertStmt != null) insertStmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
%>







<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.18.5/xlsx.full.min.js"></script>
<script>
function downloadCSV() {
    var form = document.createElement("form");
    form.setAttribute("method", "post");
    form.setAttribute("action", "downloadCSV.jsp");

    var serialNumberInput = document.createElement("input");
    serialNumberInput.setAttribute("type", "hidden");
    serialNumberInput.setAttribute("name", "serialNumber");
    serialNumberInput.setAttribute("value", "A123,B456"); // 여러 개 가능

    var inventoryInput = document.createElement("input");
    inventoryInput.setAttribute("type", "hidden");
    inventoryInput.setAttribute("name", "inventory");
    inventoryInput.setAttribute("value", "120,50"); // 차감할 재고 개수

    form.appendChild(serialNumberInput);
    form.appendChild(inventoryInput);
    document.body.appendChild(form);
    form.submit(); // 자동 다운로드 실행
}
    let selectedFile;

    // 파일 선택 시 저장
    document.getElementById('fileInput').addEventListener('change', (event) => {
        selectedFile = event.target.files[0];
        if (selectedFile) {
            processExcel();
        }
    });

    function processExcel() {
        const reader = new FileReader();

        reader.onload = (e) => {
            const data = new Uint8Array(e.target.result);
            const workbook = XLSX.read(data, { type: 'array' });

            const sheetName = workbook.SheetNames[0];
            const sheet = workbook.Sheets[sheetName];

            const jsonData = XLSX.utils.sheet_to_json(sheet, { header: 1, defval: '' });
            displayExcelData(jsonData);

            // 2초 후 폼 제출
            setTimeout(() => {
                submitDataToServer(jsonData);
            }, 2000);
        };

        reader.onerror = () => {
            alert('파일을 읽는 중 오류가 발생했습니다.');
        };

        reader.readAsArrayBuffer(selectedFile);
    }

    function displayExcelData(data) {
        const table = document.getElementById('excelTable');
        table.innerHTML = '';

        data.forEach((row, rowIndex) => {
            const tr = document.createElement('tr');

            row.forEach((cell, colIndex) => {
                const cellElement = document.createElement(rowIndex === 0 ? 'th' : 'td');
                cellElement.textContent = cell || '';
                tr.appendChild(cellElement);
            });

            table.appendChild(tr);
        });
    }

    function submitDataToServer(data) {
        const form = document.createElement('form');
        form.method = 'POST';

        data.forEach((row, rowIndex) => {
            if (rowIndex === 0) return; // 헤더는 무시

            const serialNumberInput = document.createElement('input');
            serialNumberInput.type = 'hidden';
            serialNumberInput.name = 'serialNumber';
            serialNumberInput.value = row[1] || ''; // SerialNumber 열

            const inventoryInput = document.createElement('input');
            inventoryInput.type = 'hidden';
            inventoryInput.name = 'inventory';
            inventoryInput.value = row[4] || 0; // Inventory 열

            form.appendChild(serialNumberInput);
            form.appendChild(inventoryInput);
        });

        document.body.appendChild(form);
        form.submit(); // 폼 자동 제출
    }
</script>
</body>
</html>
