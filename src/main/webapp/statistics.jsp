<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.util.*, javax.servlet.*"%>
<%@ page import="javax.servlet.http.*"%>
<%@ page import="java.sql.*"%>
<%@ page import="org.json.JSONArray"%>
<%@ page import="org.json.JSONObject"%>
<%
request.setCharacterEncoding("UTF-8");

java.util.Date today = new java.util.Date();
java.sql.Timestamp sqlDate = new java.sql.Timestamp(today.getTime());

// 데이터베이스 연결 정보
String url = "jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8";
String username = "root";
String password = "pharmacy@1234";

Connection connection = null;
PreparedStatement pstmt = null;
PreparedStatement clientpstmt = null;
PreparedStatement ptement = null;
PreparedStatement statement2 = null;
PreparedStatement statement3 = null;

try {
    // 데이터베이스 연결
    Class.forName("com.mysql.cj.jdbc.Driver");
    connection = DriverManager.getConnection(url, username, password);
    connection.setAutoCommit(false); // 트랜잭션 시작

    // 받은 JSON 데이터 파싱
    StringBuilder sb = new StringBuilder();
    try {
        BufferedReader reader = request.getReader();
        String line;
        while ((line = reader.readLine()) != null) {
            sb.append(line);
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    JSONArray jsonArray = new JSONArray(sb.toString());

    // 개별 파라미터 처리
    JSONObject paramObj = jsonArray.getJSONObject(jsonArray.length() - 1);
    String medicinePrice = paramObj.getString("medicinePrice");
    String generalPrice = paramObj.getString("generalPrice");
    String clientName = paramObj.getString("clientName");
    String clientNumber = paramObj.getString("clientNumber");

    // 개별 파라미터 삽입
    String priceSql = "INSERT INTO priceRecord (saleDate, maxmedicinePrice, generalPrice) VALUES (?, ?, ?)";
    pstmt = connection.prepareStatement(priceSql);
    pstmt.setTimestamp(1, sqlDate);
    pstmt.setString(2, medicinePrice);
    pstmt.setString(3, generalPrice);
    pstmt.executeUpdate();

    // 고객에 대한 구매 정보 갱신
    String clientSQL = "INSERT INTO clientRecord (saleDate, clientName, clientNumber) VALUES (?, ?, ?)";
    clientpstmt = connection.prepareStatement(clientSQL);
    clientpstmt.setTimestamp(1, sqlDate);
    clientpstmt.setString(2, clientName);
    clientpstmt.setString(3, clientNumber);
    clientpstmt.executeUpdate();

    // JSON 배열을 순회하며 데이터베이스 업데이트
    for (int i = 0; i < jsonArray.length() - 2; i++) {
        JSONObject obj = jsonArray.getJSONObject(i);

        // inventory 필드의 값 존재 여부 확인
        double inventoryAdjustment = obj.optDouble("inventory", 0.0); // 값이 없으면 기본값 0.0 설정

        // price 필드의 값 존재 여부 확인
        int price = obj.optInt("price", 0); // 값이 없으면 기본값 0 설정

        // 종류 검색
        String sortationSQL = "SELECT kind FROM testTable WHERE SerialNumber = ? AND medicineName = ?";
        ptement = connection.prepareStatement(sortationSQL);
        ptement.setString(1, obj.optString("serialNumber", ""));
        ptement.setString(2, obj.optString("medicineName", ""));
        ResultSet rs = ptement.executeQuery();

        // 규격에 대한 개수 가져오기
        String standardSQL = "SELECT REGEXP_REPLACE(?, '[^0-9]', '') AS standard FROM testTable WHERE medicineName = ?";
        statement2 = connection.prepareStatement(standardSQL);
        statement2.setString(1, obj.optString("standard", ""));
        statement2.setString(2, obj.optString("medicineName", ""));
        ResultSet standRS = statement2.executeQuery();

        // 뒤 두글자를 제외한 이름 가져오기
        String NameSQL = "SELECT SUBSTRING(REPLACE(?, ' ', ''), 1, CHAR_LENGTH(REPLACE(?, ' ', '')) - 2) AS Result FROM testTable";
        statement3 = connection.prepareStatement(NameSQL);
        statement3.setString(1, obj.optString("medicineName", ""));
        statement3.setString(2, obj.optString("medicineName", ""));
        ResultSet NameRS = statement3.executeQuery();

        String kind = null;
        String standard = null;
        String medicineName = null;
        if (rs.next()) {
            kind = rs.getString("kind");
        }
        if (standRS.next()) {
            standard = standRS.getString("standard");
        }
        if (NameRS.next()) {
            medicineName = NameRS.getString("Result");
        }

        if ("일반세트".equals(obj.optString("serialNumber", ""))) {
            // vitalSet 테이블에서 medicineName 검색
            String vitalSetSQL = "SELECT resource1, resource2, resource3, resource4, resource5 FROM vitalSet WHERE medicineName = ?";
            PreparedStatement vitalSetStmt = connection.prepareStatement(vitalSetSQL);
            vitalSetStmt.setString(1, obj.optString("medicineName", ""));
            ResultSet vitalSetRS = vitalSetStmt.executeQuery();

            if (vitalSetRS.next()) {
                // 리소스 값 가져오기
                String[] resources = {
                    vitalSetRS.getString("resource1"), 
                    vitalSetRS.getString("resource2"),
                    vitalSetRS.getString("resource3"), 
                    vitalSetRS.getString("resource4"),
                    vitalSetRS.getString("resource5")
                };

                // 각 리소스에 대해 재고 차감
                for (int count = 0; count < resources.length; count++) {
                    String resource = resources[count];
                    if (resource != null && !resource.isEmpty()) {
                        System.out.println("Processing resource: " + resource); // 디버깅 로그 추가

                        double remainingAdjustment = inventoryAdjustment; // 각 리소스 별로 남은 재고 조정
                        while (remainingAdjustment > 0) {
                            // 가장 유통기한이 짧은 날짜 선택
                            String selectDateSQL = "SELECT DeliveryDate, inventory FROM testTable "
                                    + "WHERE medicineName = ? AND returnInv = '0' AND inventory > 0 "
                                    + "ORDER BY DeliveryDate ASC LIMIT 1";
                            PreparedStatement selectDateStmt = connection.prepareStatement(selectDateSQL);
                            selectDateStmt.setString(1, resource);
                            ResultSet dateRS = selectDateStmt.executeQuery();

                            if (!dateRS.next()) {
                                break; // 더 이상 차감할 날짜가 없음
                            }

                            String minDeliveryDate = dateRS.getString("DeliveryDate");
                            double availableInventory = dateRS.getDouble("inventory");
                            dateRS.close();
                            selectDateStmt.close();

                            // 재고 차감
                            double deductedInventory = Math.min(remainingAdjustment, availableInventory);
                            String updateSQL = "UPDATE testTable SET inventory = inventory - ? "
                                    + "WHERE medicineName = ? AND DeliveryDate = ?";
                            PreparedStatement updateStmt = connection.prepareStatement(updateSQL);
                            updateStmt.setDouble(1, deductedInventory);
                            updateStmt.setString(2, resource);
                            updateStmt.setString(3, minDeliveryDate);
                            int rowsAffected = updateStmt.executeUpdate();
                            System.out.println("Rows affected by inventory update for resource " + resource + ": " + rowsAffected); // 디버깅 로그 추가
                            updateStmt.close();

                            // 차감된 재고량을 업데이트
                            remainingAdjustment -= deductedInventory;
                        }
                    }
                }
            }

            vitalSetRS.close();
            vitalSetStmt.close();
        } else if ("한약세트".equals(obj.optString("serialNumber", ""))) {
            // 한약세트의 경우
            while (inventoryAdjustment > 0) {
                // 가장 유통기한이 짧은 날짜 선택
                String selectDateSQL = "SELECT DeliveryDate, inventory FROM testTable "
                        + "WHERE medicineName = ? AND returnInv = '0' AND inventory > 0 "
                        + "ORDER BY DeliveryDate ASC LIMIT 1";
                PreparedStatement selectDateStmt = connection.prepareStatement(selectDateSQL);
                selectDateStmt.setString(1, medicineName);
                ResultSet dateRS = selectDateStmt.executeQuery();

                if (!dateRS.next()) {
                    break; // 더 이상 차감할 날짜가 없음
                }

                String minDeliveryDate = dateRS.getString("DeliveryDate");
                double availableInventory = dateRS.getDouble("inventory");
                dateRS.close();
                selectDateStmt.close();

                // 재고 차감
                double deductedInventory = Math.min(inventoryAdjustment, availableInventory);
                String updateSQL = "UPDATE testTable SET inventory = inventory - ? "
                        		 + "WHERE medicineName = ? AND DeliveryDate = ?";
                PreparedStatement updateStmt = connection.prepareStatement(updateSQL);
                updateStmt.setDouble(1, deductedInventory);
                updateStmt.setString(2, medicineName);
                updateStmt.setString(3, minDeliveryDate);
                int rowsAffected = updateStmt.executeUpdate();
                System.out.println("Rows affected by inventory update for herbal set: " + rowsAffected); // 디버깅 로그 추가
                updateStmt.close();

                // 차감된 재고량을 업데이트
                inventoryAdjustment -= deductedInventory;
            }
        } else {
            // 기타 경우 처리
        	while (inventoryAdjustment > 0) {
        	    // 가장 유통기한이 짧은 날짜 선택
        	    String selectDateSQL = "SELECT DeliveryDate, inventory FROM testTable "
        	            + "WHERE SerialNumber = ? AND medicineName = ? AND returnInv = '0' AND inventory > 0 "
        	            + "ORDER BY DeliveryDate ASC LIMIT 1";
        	    PreparedStatement selectDateStmt = connection.prepareStatement(selectDateSQL);
        	    selectDateStmt.setString(1, obj.optString("serialNumber", ""));
        	    selectDateStmt.setString(2, obj.optString("medicineName", ""));
        	    ResultSet dateRS = selectDateStmt.executeQuery();

        	    if (!dateRS.next()) {
        	        break; // 더 이상 차감할 날짜가 없음
        	    }

        	    String minDeliveryDate = dateRS.getString("DeliveryDate");
        	    double availableInventory = dateRS.getDouble("inventory");
        	    dateRS.close();
        	    selectDateStmt.close();

        	    // 재고 차감량 계산
        	    double deductedInventory = Math.min(inventoryAdjustment, availableInventory);

        	    // standard 값에서 숫자만 추출하거나 단순 차감
        	    standard = obj.optString("standard", "");
        	    double standardFactor = 1.0; // 기본 값은 1

        	    if (standard.contains("ml")) {
        	        // ml 단위일 경우, 단순히 재고를 차감
        	        standardFactor = 1.0;
        	    } else {
        	        // ml이 아닌 경우, standard에서 숫자만 추출
        	        try {
        	            String numericStandard = standard.replaceAll("[^0-9]", "");
        	            if (!numericStandard.isEmpty()) {
        	                standardFactor = Double.parseDouble(numericStandard);
        	            } else {
        	                throw new NumberFormatException("Invalid standard format: No numeric value found.");
        	            }
        	        } catch (NumberFormatException e) {
        	            System.err.println("Invalid standard format: " + e.getMessage());
        	        }
        	    }

        	    // 재고 업데이트 쿼리 실행
        	    String updateSQL = "UPDATE testTable SET inventory = inventory - (? * ?) "
        	                     + "WHERE medicineName = ? AND DeliveryDate = ?";
        	    PreparedStatement updateStmt = connection.prepareStatement(updateSQL);
        	    updateStmt.setDouble(1, deductedInventory);
        	    updateStmt.setDouble(2, standardFactor); // ml일 경우 1.0, 아닌 경우 계산된 standardFactor 사용
        	    updateStmt.setString(3, obj.optString("medicineName", ""));
        	    updateStmt.setString(4, minDeliveryDate);

        	    int rowsAffected = updateStmt.executeUpdate();
        	    System.out.println("Rows affected by inventory update: " + rowsAffected); // 디버깅 로그 추가
        	    updateStmt.close();

        	    // 차감된 재고량 업데이트
        	    inventoryAdjustment -= deductedInventory;
        	}

        }

        // 판매 날짜 입력
        try {
            double inventory = obj.optDouble("inventory", 0.0);
            String standardStr = obj.optString("standard", ""); // 문자열로 가져오기
            double standardValue = 1.0; // 기본값 설정

            if (standardStr.contains("ml")) {
                // ml 단위인 경우 inventory 그대로 사용
                standardValue = inventory;
            } else {
                // ml이 아닌 경우 standard에서 숫자만 추출
                try {
                    String numericStandard = standardStr.replaceAll("[^0-9]", "");
                    if (!numericStandard.isEmpty()) {
                        standardValue = Double.parseDouble(numericStandard) * inventory;
                    } else {
                        throw new NumberFormatException("Invalid standard format: No numeric value found.");
                    }
                } catch (NumberFormatException e) {
                    System.err.println("Invalid standard format: " + e.getMessage());
                }
            }

            String salesSql = "INSERT INTO SalesRecord (saleDate, medicineName, Buyingprice, price, inventory, SerialNumber, DeliveryDate) "
                            + "VALUES (?, ?, ?, ?, ?, ?, ?)";
            pstmt = connection.prepareStatement(salesSql);
            pstmt.setTimestamp(1, sqlDate);
            pstmt.setString(2, obj.optString("medicineName", ""));
            pstmt.setString(3, obj.optString("Buyingprice", ""));
            pstmt.setInt(4, price); // 변환된 price 값을 사용
            pstmt.setDouble(5, standardValue); // 계산된 standardValue 사용
            pstmt.setString(6, obj.optString("serialNumber", ""));
            pstmt.setString(7, obj.optString("deliveryDate", ""));
            pstmt.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
            throw new SQLException("Error inserting into SalesRecord: " + e.getMessage());
        }

    }

    // 트랜잭션 커밋
    connection.commit();
    out.println("{\"result\":\"success\"}");
    

} catch (Exception e) {
    // 오류 발생 시 롤백
    try {
        if (connection != null) {
            connection.rollback();
        }
    } catch (SQLException rollbackEx) {
        rollbackEx.printStackTrace();
    }
    e.printStackTrace();
    out.println("{\"result\":\"error\", \"message\":\"" + e.getMessage() + "\"}");
} finally {
    // 자원 정리
    try {
        if (pstmt != null) pstmt.close();
        if (clientpstmt != null) clientpstmt.close();
        if (ptement != null) ptement.close();
        if (statement2 != null) statement2.close();
        if (statement3 != null) statement3.close();
        if (connection != null) connection.close();
    } catch (SQLException e) {
        e.printStackTrace();
    }
}
%>
