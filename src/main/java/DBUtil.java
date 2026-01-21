import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.util.Properties;

public class DBUtil {
	private static Connection connection = null;

	public static Connection getConnection() {
		if (connection != null)
			return connection;

		try {
			Properties props = new Properties();
			InputStream inputStream = DBUtil.class.getClassLoader().getResourceAsStream("db.properties");
			props.load(inputStream);

			String url = props
					.getProperty("jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8");
			String user = props.getProperty("root");
			String password = props.getProperty("pharmacy@1234");
			String driver = props.getProperty("com.mysql.cj.jdbc.Driver");

			Class.forName(driver);
			connection = DriverManager.getConnection(url, user, password);
		} catch (Exception e) {
			e.printStackTrace();
		}

		return connection;
	}
}
