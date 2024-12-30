package testTable;

import java.sql.*;

import Util.databaseUtil;

public class testTableDAO {
    public int store(String SerialNumber, String medicineName , String price , String inventory , String kind, String PlaceClassification, String companyName, String standard, String receiptDate , String DeliveryDate, String countNumber) {
        // 데이터베이스 연결 및 SQL 문
        String insertSQL = "INSERT INTO testTable VALUES (? , ? , ? , ? , ? , ? , ? , ? , ? , ? , ?)";
        
        try {
            Connection conn = databaseUtil.getConnection();
            
            // 새로운 행 추가
            PreparedStatement insertStmt = conn.prepareStatement(insertSQL);
            insertStmt.setString(1, SerialNumber);
            insertStmt.setString(2, medicineName);
            insertStmt.setString(3, price);
            insertStmt.setString(4, inventory);
            insertStmt.setString(5, kind);
            insertStmt.setString(6, PlaceClassification);
            insertStmt.setString(7, companyName);
            insertStmt.setString(8, standard);
            insertStmt.setString(9, receiptDate);
            insertStmt.setString(10, DeliveryDate);
            insertStmt.setString(11, countNumber);
            int rowsInserted = insertStmt.executeUpdate();
            return rowsInserted;
        } catch(SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }
}
