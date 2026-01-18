<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.text.*"%>

<%! 
// 문자열을 숫자로 변환, 빈 값이면 기본값 반환
private int parseIntOrDefault(String value, int defaultValue) {
    if (value != null && !value.trim().isEmpty()) {
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            System.err.println("숫자 변환 오류: " + value);
        }
    }
    return defaultValue; // 기본값 반환
}

%>
<%! 
// 날짜 형식을 YYYY-MM-DD로 변환
private String formatDate(String inputDate) {
    try {
        // 입력이 이미 yyyy-mm-dd 형식인지 확인
        if (inputDate.matches("\\d{4}-\\d{2}-\\d{2}")) {
            return inputDate; // 이미 올바른 형식이면 그대로 반환
        }

        // yy/mm/dd 형식일 경우 변환 진행
        String[] parts = inputDate.split("/"); // "25/01/12" → ["25", "01", "12"]
        if (parts.length != 3) {
            throw new IllegalArgumentException("잘못된 날짜 형식: " + inputDate);
        }

        // 연도 변환 (예: "25" → "2025")
        int year = Integer.parseInt(parts[0]);
        if (year < 100) {
            year += (year < 50 ? 2000 : 1900); // 기준 연도 설정
        }

        // 월과 일을 2자리로 유지
        String month = String.format("%02d", Integer.parseInt(parts[1]));
        String day = String.format("%02d", Integer.parseInt(parts[2]));

        // 최종 날짜 형식 반환
        return year + "-" + month + "-" + day;
    } catch (Exception e) {
        System.err.println("날짜 변환 오류: " + inputDate + ", 오류 메시지: " + e.getMessage());
        return inputDate; // 변환 실패 시 원래 값을 반환
    }
}
%>

<%
request.setCharacterEncoding("UTF-8");

// 배열 형태로 데이터 수신
String[] serialNumbers = request.getParameterValues("SerialNumber[]");
String[] medicineNames = request.getParameterValues("medicineName[]");
String[] buyingPrices = request.getParameterValues("Buyingprice[]");
String[] wholesalers = request.getParameterValues("wholesaler[]");
String[] prices = request.getParameterValues("price[]");
String[] inventories = request.getParameterValues("inventory[]");
String[] companyNames = request.getParameterValues("companyName[]");
String[] standards = request.getParameterValues("standard[]");
String[] receiptDates = request.getParameterValues("receiptDate[]");
String[] deliveryDates = request.getParameterValues("DeliveryDate[]");

// 배열 중 가장 짧은 길이를 기준으로 처리
int rowCount = Math.min(
	    serialNumbers != null ? serialNumbers.length : 0,
	    	    Math.min(    wholesalers != null ? wholesalers.length : 0,
	    	    	    Math.min(
        medicineNames != null ? medicineNames.length : 0,
        Math.min(
            prices != null ? prices.length : 0,
            Math.min(
                inventories != null ? inventories.length : 0,
                Math.min(
                    companyNames != null ? companyNames.length : 0,
                    Math.min(
                        standards != null ? standards.length : 0,
                        Math.min(receiptDates != null ? receiptDates.length : 0,
                                 deliveryDates != null ? deliveryDates.length : 0)
                    )
                )
            )
        )
    )
	    	    	    )
);

// DB 연결 정보
String jdbcDriver = "jdbc:mysql://localhost:3306/tutorial2?useUnicode=true&characterEncoding=utf8";
String dbUser = "root";
String dbPwd = "pharmacy@1234";

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPwd);

    // 각 행 데이터를 반복적으로 처리
    for (int i = 0; i < rowCount; i++) {
        // 현재 행의 데이터 가져오기
        String serialNumber = serialNumbers[i] != null ? serialNumbers[i].trim() : "";
        String medicineName = medicineNames[i] != null ? medicineNames[i].trim() : "";
        String wholesaler = wholesalers[i] != null ? wholesalers[i].trim() : "";
        String buyingPrice = buyingPrices[i] != null ? buyingPrices[i].trim() : "0";
        String price = prices[i] != null ? prices[i].trim() : "0";
        String inventory = inventories[i] != null ? inventories[i].trim() : "0";
        String companyName = companyNames[i] != null ? companyNames[i].trim() : "";
        String standard = standards[i] != null ? standards[i].trim() : "";
        String receiptDate = receiptDates[i] != null ? receiptDates[i].trim() : "";
        String deliveryDate = deliveryDates[i] != null ? formatDate(deliveryDates[i].trim()) : "";

        // inventory 숫자 변환 (빈 값은 기본값 0)
        int inventoryValue = parseIntOrDefault(inventory, 0);

        // 데이터 존재 여부 확인
        String checkIfExistsSQL = "SELECT inventory FROM testTable WHERE SerialNumber = ? AND DeliveryDate = ? AND medicineName = ?";
        pstmt = conn.prepareStatement(checkIfExistsSQL);
        pstmt.setString(1, serialNumber);
        pstmt.setString(2, deliveryDate);
        pstmt.setString(3, medicineName);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            // 데이터가 존재하면 inventory 업데이트
            int currentInventory = parseIntOrDefault(rs.getString("inventory"), 0);
            int updatedInventory = currentInventory + inventoryValue;

            String updateSQL = "UPDATE testTable SET inventory = ? WHERE SerialNumber = ? AND DeliveryDate = ? AND medicineName = ?";
            pstmt.close(); // 이전 PreparedStatement 닫기
            pstmt = conn.prepareStatement(updateSQL);
            pstmt.setInt(1, updatedInventory);
            pstmt.setString(2, serialNumber);
            pstmt.setString(3, deliveryDate);
            pstmt.setString(4, medicineName);
            pstmt.executeUpdate();
        } else {
            // 데이터가 없으면 새로 삽입
            String insertSQL = "INSERT INTO testTable (SerialNumber, medicineName, price, inventory, Buyingprice, companyName, standard, receiptDate, DeliveryDate, returnInv, wholesaler) " 
                             + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            pstmt.close(); // 이전 PreparedStatement 닫기
            pstmt = conn.prepareStatement(insertSQL);
            pstmt.setString(1, serialNumber);
            pstmt.setString(2, medicineName);
            pstmt.setString(3, price);
            pstmt.setInt(4, inventoryValue);
            pstmt.setString(5, buyingPrice);
            pstmt.setString(6, companyName);
            pstmt.setString(7, standard);
            pstmt.setString(8, receiptDate);
            pstmt.setString(9, deliveryDate);
            pstmt.setString(10, "0");
            pstmt.setString(11, wholesaler);
            pstmt.executeUpdate();
        }
    }
    String removeData = "delete from testTable where medicineName = '' and serialNumber = ''";
    pstmt = conn.prepareStatement(removeData);
    pstmt.executeUpdate();

    out.println("모든 데이터가 처리되었습니다.");

} catch (Exception e) {
    e.printStackTrace();
    out.println("데이터 처리 중 오류가 발생했습니다: " + e.getMessage());
} finally {
    // 리소스 정리
    try {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    } catch (SQLException se) {
        se.printStackTrace();
    }
}
%>
<jsp:forward page="Product_Registration.jsp"></jsp:forward>
