package testTable;

import java.sql.Connection;
import java.sql.PreparedStatement;

import Util.databaseUtil;

public class testTableUpdateDAO {
    public int updateTestTable(String inventory, String countNumber, String SerialNumber) {
        String SQL = "UPDATE testTable SET inventory = inventory + ? WHERE countNumber = ? AND SerialNumber = ? ";
        try {
            Connection conn = databaseUtil.getConnection();
            PreparedStatement pstmt = conn.prepareStatement(SQL);
            pstmt.setString(1, inventory);
            pstmt.setString(2, SerialNumber);
            pstmt.setString(3, countNumber);
            return pstmt.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }
}