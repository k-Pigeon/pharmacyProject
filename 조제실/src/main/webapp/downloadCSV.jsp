<%@ page contentType="text/csv; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.net.URLEncoder, java.io.*" %>
<%
    // 한글 파일명을 UTF-8로 인코딩하여 다운로드
    String fileName = "재고차감결과.csv";
    String encodedFileName = URLEncoder.encode(fileName, "UTF-8").replaceAll("\\+", "%20");

    response.setContentType("text/csv; charset=UTF-8");
    response.setHeader("Content-Disposition", "attachment; filename*=UTF-8''" + encodedFileName);

    PrintWriter writer = response.getWriter();

    // ✅ UTF-8 BOM 추가 (엑셀에서 한글 깨짐 방지)
    writer.write("\uFEFF");

    // CSV 헤더
    writer.println("SerialNumber,MedicineName,원래 재고,차감할 재고,남은 차감량,최종 재고");

    String jdbcUrl = "jdbc:mysql://localhost:3306/tutorial2?useUnicode=true&characterEncoding=utf8";
    String dbUser = "root";
    String dbPassword = "pharmacy@1234";

    Connection conn = null;
    PreparedStatement selectStmt = null;
    PreparedStatement updateStmt = null;

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(jdbcUrl, dbUser, dbPassword);
        conn.setAutoCommit(false); // 트랜잭션 시작

        String[] serialNumbers = request.getParameterValues("serialNumber");
        String[] inventories = request.getParameterValues("inventory");

        for (int i = 0; i < serialNumbers.length; i++) {
            String serialNumber = serialNumbers[i];
            String numericInventory = inventories[i].replaceAll("[^0-9.]","");
            double inventoryToDeduct = numericInventory.isEmpty() ? 0 : Double.parseDouble(numericInventory);

            boolean isFirstRow = true;
            String medicineName = "";

            while (inventoryToDeduct > 0) {
                String selectQuery = "SELECT serialNumber, CAST(inventory AS DECIMAL(12,4)) AS inventory, deliveryDate, medicineName " +
                                     "FROM testTable " +
                                     "WHERE serialNumber = ? AND CAST(inventory AS DECIMAL(12,4)) > 0 " +
                                     "ORDER BY STR_TO_DATE(deliveryDate, '%Y-%m-%d') ASC LIMIT 1";

                selectStmt = conn.prepareStatement(selectQuery);
                selectStmt.setString(1, serialNumber);
                ResultSet rs = selectStmt.executeQuery();

                if (rs.next()) {
                    String currentSerial = rs.getString("serialNumber");
                    double originalInventory = rs.getDouble("inventory");
                    double currentInventory = originalInventory;
                    String deliveryDate = rs.getString("deliveryDate");
                    medicineName = rs.getString("medicineName");

                    double deduction = Math.min(inventoryToDeduct, currentInventory);
                    double updatedInventory = currentInventory - deduction;

                    // 재고 업데이트 실행
                    String updateQuery = "UPDATE testTable SET inventory = ? WHERE serialNumber = ? AND deliveryDate = ?";
                    updateStmt = conn.prepareStatement(updateQuery);
                    updateStmt.setDouble(1, updatedInventory);
                    updateStmt.setString(2, currentSerial);
                    updateStmt.setString(3, deliveryDate);
                    updateStmt.executeUpdate();

                    inventoryToDeduct -= deduction;

                    // 첫 번째 행에는 SerialNumber, medicineName 표시, 이후 행에는 빈 값 처리
                    if (isFirstRow) {
                        writer.println(currentSerial + "," + medicineName + "," + String.format("%.2f", originalInventory) + "," +
                                       String.format("%.2f", deduction) + "," + String.format("%.2f", inventoryToDeduct) + "," + 
                                       String.format("%.2f", updatedInventory));
                        isFirstRow = false;
                    } else {
                        writer.println("," + "," + String.format("%.2f", originalInventory) + "," +
                                       String.format("%.2f", deduction) + "," + String.format("%.2f", inventoryToDeduct) + "," + 
                                       String.format("%.2f", updatedInventory));
                    }

                } else {
                    break;
                }
                rs.close();
            }
        }

        conn.commit(); // 트랜잭션 커밋

    } catch (Exception e) {
        e.printStackTrace();
        if (conn != null) conn.rollback(); // 오류 발생 시 롤백
        writer.println("오류 발생: " + e.getMessage());
    } finally {
        try {
            if (selectStmt != null) selectStmt.close();
            if (updateStmt != null) updateStmt.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        writer.close();
    }
%>
