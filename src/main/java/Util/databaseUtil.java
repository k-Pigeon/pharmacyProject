package Util;

import java.sql.*;

public class databaseUtil {
	
	public static Connection getConnection() {
		try {
			String url = "jdbc:mysql://localhost:3306/tutorial?createDatabaseIfNotExist=true";
			String dbID = "root";
			String dbPw = "pharmacy@1234";
			Class.forName("com.mysql.cj.jdbc.Driver");
			return DriverManager.getConnection(url, dbID, dbPw);
		}catch(Exception e){
			e.printStackTrace();
		}
		return null;
	}
}