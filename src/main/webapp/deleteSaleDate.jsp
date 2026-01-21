<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%
    request.setCharacterEncoding("UTF-8");
    String saleDate = request.getParameter("saleDate");
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    PreparedStatement pstmt2 = null;
    PreparedStatement pstmtSelect = null;
    PreparedStatement pstmtUpdate = null;
    ResultSet rs = null;

    try {
        String jdbcDriver = "jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8";
        String dbUser = "root";
        String dbPwd = "pharmacy@1234";
        
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPwd);

        // SalesRecord에서 saleDate로 데이터 검색
        String selectSql = "SELECT medicineName, SerialNumber, DeliveryDate, inventory FROM SalesRecord WHERE saleDate = ?";
        pstmtSelect = conn.prepareStatement(selectSql);
        pstmtSelect.setString(1, saleDate);
        rs = pstmtSelect.executeQuery();

        // 검색된 데이터로 testTable 업데이트
        while (rs.next()) {
            String medicineName = rs.getString("medicineName");
            String serialNumber = rs.getString("SerialNumber");
            String deliveryDate = rs.getString("DeliveryDate");
            double inventoryToAdd = rs.getDouble("inventory");

            // testTable의 해당 행에 inventory를 더하기
            String updateSql = "UPDATE testTable SET inventory = inventory + ? WHERE DeliveryDate = ? AND medicineName = ?";
            pstmtUpdate = conn.prepareStatement(updateSql);
            pstmtUpdate.setDouble(1, inventoryToAdd);
            pstmtUpdate.setString(2, deliveryDate);
            pstmtUpdate.setString(3, medicineName);

            int rowsUpdated = pstmtUpdate.executeUpdate();
            System.out.println("Rows updated: " + rowsUpdated);
        }

        // SalesRecord 데이터 삭제
        String sql = "DELETE FROM SalesRecord WHERE saleDate = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, saleDate);
        
        String sql2 = "DELETE FROM clientRecord WHERE saleDate = ?";
        pstmt2 = conn.prepareStatement(sql2);
        pstmt2.setString(1, saleDate);
        
        int rowsAffected1 = pstmt.executeUpdate();
        int rowsAffected2 = pstmt2.executeUpdate();  // 두 번째 쿼리 실행

        if (rowsAffected1 > 0 || rowsAffected2 > 0) {
            out.print("deleted"); // 데이터가 삭제됨
        } else {
            out.print("no_data"); // 삭제할 데이터가 없음
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pstmtSelect != null) try { pstmtSelect.close(); } catch (Exception e) {}
        if (pstmtUpdate != null) try { pstmtUpdate.close(); } catch (Exception e) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
        if (pstmt2 != null) try { pstmt2.close(); } catch (Exception e) {} 
        if (conn != null) try { conn.close(); } catch (Exception e) {}
    }
%>
