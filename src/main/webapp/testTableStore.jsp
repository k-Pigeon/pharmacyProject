<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%
request.setCharacterEncoding("UTF-8");

java.util.Date today = new java.util.Date();
java.sql.Date sqlDate = new java.sql.Date(today.getTime());

String SerialNumber = request.getParameter("SerialNumber");
String medicineName = request.getParameter("medicineName");
String Buyingprice = request.getParameter("Buyingprice");
String price = request.getParameter("price");
String inventory = request.getParameter("inventory");
String kind = request.getParameter("kind");
String companyName = request.getParameter("companyName");
String standard = request.getParameter("standard");
String receiptDate = request.getParameter("receiptDate");
String DeliveryDate = request.getParameter("DeliveryDate");
String countNumber = request.getParameter("countNumber");
String Bookmark = request.getParameter("bookmark");

out.println(Bookmark);

// DB 연결 정보
String jdbcDriver = "jdbc:mysql://localhost:3306/tutorial?useUnicode=true&characterEncoding=utf8";
String dbUser = "root";
String dbPwd = "pharmacy@1234";

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
ResultSet res = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(jdbcDriver, dbUser, dbPwd);

    // SerialNumber와 countNumber를 이용하여 해당 제품이 이미 존재하는지 확인
    String checkIfExistsSQL = "SELECT COUNT(*) AS count FROM testTable WHERE SerialNumber = ? AND countNumber = ? AND DeliveryDate = ?";
    pstmt = conn.prepareStatement(checkIfExistsSQL);
    pstmt.setString(1, SerialNumber);
    pstmt.setString(2, countNumber);
    pstmt.setString(3, DeliveryDate);
    rs = pstmt.executeQuery();

    rs.next();
    int rowCount = rs.getInt("count");

    if (rowCount > 0) {
        // 이미 해당 제품이 존재하는 경우
        String selectBookmarkSQL = "SELECT Bookmark, kind FROM testTable WHERE SerialNumber = ? AND countNumber = ?";
        pstmt.close(); // 이전 PreparedStatement 닫기
        pstmt = conn.prepareStatement(selectBookmarkSQL);
        pstmt.setString(1, SerialNumber);
        pstmt.setString(2, countNumber);
        res = pstmt.executeQuery(); // rs 열기
        if (res.next()) {
            String existingBookmark = res.getString("Bookmark");
            String existingkind = res.getString("kind");{
            if (!existingBookmark.equals(Bookmark)) {
                // Bookmark 값이 다르면 재고와 함께 업데이트
                String updateSQL = "UPDATE testTable SET inventory = inventory + ?, Bookmark = ? WHERE SerialNumber = ? AND countNumber = ? ";
                pstmt.close(); // 이전 PreparedStatement 닫기
                pstmt = conn.prepareStatement(updateSQL);
                pstmt.setString(1, inventory);
                pstmt.setString(2, Bookmark);
                pstmt.setString(3, SerialNumber);
                pstmt.setString(4, countNumber);
                int rowsAffected = pstmt.executeUpdate();
                if (rowsAffected > 0) {
                    out.println("재고 및 Bookmark 값이 업데이트되었습니다.");
                } else {
                    out.println("재고 및 Bookmark 값 업데이트에 실패했습니다.");
                }
            }if(existingkind.equals("드링크류")){
            	String updateSQL = " UPDATE testTable SET inventory = inventory + ? "
            					 + " where medicineName = ? AND DeliveryDate = ? ";
            	pstmt.close(); // 이전 PreparedStatement 닫기
                pstmt = conn.prepareStatement(updateSQL);
                pstmt.setString(1, inventory);
                pstmt.setString(2, medicineName);
                pstmt.setString(3, DeliveryDate);
                pstmt.executeUpdate();
            }
            
            else {
                // Bookmark 값이 같으면 재고 수량만 업데이트
                String updateInventorySQL = "UPDATE testTable SET inventory = inventory + ? WHERE SerialNumber = ? AND countNumber = ? ";
                pstmt.close(); // 이전 PreparedStatement 닫기
                pstmt = conn.prepareStatement(updateInventorySQL);
                pstmt.setString(1, inventory);
                pstmt.setString(2, SerialNumber);
                pstmt.setString(3, countNumber);
                int rowsAffected = pstmt.executeUpdate();
                if (rowsAffected > 0) {
                    out.println("재고 수량이 업데이트되었습니다.");
                } else {
                    out.println("재고 수량 업데이트에 실패했습니다.");
                }
            }
            }
        }else {
            out.println("Bookmark 조회에 실패했습니다.");
        }
    } else {
        // 해당 제품이 존재하지 않는 경우, 삽입 수행
        String insertSQL = "INSERT INTO testTable (SerialNumber, medicineName, price, inventory, Buyingprice, kind, companyName, standard, receiptDate, DeliveryDate, countNumber, Bookmark, returnInv) " 
        				 + " VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, '0')";
        if (standard != null && standard.contains("ml")) {
            try {
                // standard에서 숫자만 추출
                int standardValue = Integer.parseInt(standard.replaceAll("[^0-9]", ""));
                int inventoryValue = Integer.parseInt(inventory);

                // 계산된 inventory 값 설정
                inventory = String.valueOf(standardValue * inventoryValue);
            } catch (NumberFormatException e) {
                // 숫자 변환 실패 시 로그 출력 또는 기본값 설정
                System.err.println("Invalid standard or inventory format: " + e.getMessage());
            }
        }
        pstmt.close(); // 이전 PreparedStatement 닫기
        pstmt = conn.prepareStatement(insertSQL);
        pstmt.setString(1, SerialNumber);
        pstmt.setString(2, medicineName);
        pstmt.setString(3, price);
        pstmt.setString(4, inventory);
        pstmt.setString(5, Buyingprice);
        pstmt.setString(6, kind);
        pstmt.setString(7, companyName);
        pstmt.setString(8, standard);
        pstmt.setString(9, receiptDate);
        pstmt.setString(10, DeliveryDate);
        pstmt.setString(11, countNumber);
        pstmt.setString(12, Bookmark);
        
        int rowsAffected = pstmt.executeUpdate();
        if (rowsAffected > 0) {
            out.println("제품이 성공적으로 등록되었습니다.");
        } else {
            out.println("제품 등록에 실패했습니다.");
        }
    }
} catch (SQLException se) {
    se.printStackTrace();
} catch (ClassNotFoundException e) {
    e.printStackTrace();
} finally {
    // 리소스 해제
    try {
        if (rs != null) rs.close(); // rs 닫기
        if (res != null) rs.close(); // rs 닫기
        if (pstmt != null) pstmt.close();
        if (conn != null) conn.close();
    } catch (SQLException se) {
        se.printStackTrace();
    }
}
%>
<jsp:forward page="Product_Registration.jsp"></jsp:forward>