<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="org.json.JSONArray, org.json.JSONObject" %>
<%@ include file="sessionManager.jsp"%>
<%@ include file="DBconnection.jsp"%>

<%
response.setContentType("application/json; charset=UTF-8");
request.setCharacterEncoding("UTF-8");

String domainType = (session != null) ? (String) session.getAttribute("domainType") : null;
String dbName = (session != null) ? (String) session.getAttribute("dbName") : null;
String id = (session != null) ? (String) session.getAttribute("id") : null;

if (domainType == null || dbName == null || id == null) {
    response.sendRedirect("login.jsp");
    return;
}

boolean prevAutoCommit = conn.getAutoCommit();
conn.setAutoCommit(false);
%>

<%!
    // ===============================
    // FIFO 방식으로 일반 상품 재고 차감
    // ===============================
    private void deductFIFO(Connection conn, String medicineName, double deductQty, String domainType) throws SQLException {

        String selectSql =
            "SELECT DeliveryDate, inventory " +
            "FROM testTable " +
            "WHERE medicineName = ? " +
            "  AND returnInv = '0' " +
            "  AND inventory > 0 " +
            "  AND domain_type = ? " +
            "ORDER BY DeliveryDate ASC";

        String updateSql =
            "UPDATE testTable " +
            "SET inventory = ? " +
            "WHERE medicineName = ? " +
            "  AND DeliveryDate = ? " +
            "  AND returnInv = '0' " +
            "  AND domain_type = ?";

        try (
            PreparedStatement psSel = conn.prepareStatement(selectSql);
            PreparedStatement psUpd = conn.prepareStatement(updateSql)
        ) {
            psSel.setString(1, medicineName);
            psSel.setString(2, domainType);

            try (ResultSet rs = psSel.executeQuery()) {
                double remain = deductQty;

                while (rs.next() && remain > 0) {
                    String deliveryDate = rs.getString("DeliveryDate");
                    double inv = rs.getDouble("inventory");

                    if (inv >= remain) {
                        psUpd.setDouble(1, inv - remain);
                        psUpd.setString(2, medicineName);
                        psUpd.setString(3, deliveryDate);
                        psUpd.setString(4, domainType);
                        psUpd.executeUpdate();
                        remain = 0;
                    } else {
                        psUpd.setDouble(1, 0);
                        psUpd.setString(2, medicineName);
                        psUpd.setString(3, deliveryDate);
                        psUpd.setString(4, domainType);
                        psUpd.executeUpdate();
                        remain -= inv;
                    }
                }

                if (remain > 0) {
                    throw new SQLException("재고 부족: " + medicineName + " / 부족 수량: " + remain);
                }
            }
        }
    }

    // ===============================
    // 경고 리스트 추가
    // ===============================
    private void checkAndAddWarning(
        Connection conn,
        String medicineName,
        JSONArray warnList,
        Set<String> warnedMedicines,
        String domainType
    ) throws SQLException {

        if (warnedMedicines.contains(medicineName)) return;

        String sql =
            "SELECT SUM(inventory) AS totalInv, quantity " +
            "FROM testTable " +
            "WHERE medicineName = ? " +
            "  AND returnInv = '0' " +
            "  AND domain_type = ? " +
            "GROUP BY quantity " +
            "LIMIT 1";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, medicineName);
            ps.setString(2, domainType);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double totalInv = rs.getDouble("totalInv");
                    double quantity = rs.getDouble("quantity");

                    if (totalInv < quantity) {
                        JSONObject warn = new JSONObject();
                        warn.put("medicineName", medicineName);
                        warn.put("realInv", totalInv);
                        warn.put("quantity", quantity);

                        warnList.put(warn);
                        warnedMedicines.add(medicineName);
                    }
                }
            }
        }
    }

    // ===============================
    // 일반 세트(productSet) 여부 확인
    // ===============================
    private boolean isNormalSet(Connection conn, String setName, String domainType) throws SQLException {
        String sql =
            "SELECT COUNT(*) " +
            "FROM productSet " +
            "WHERE setName = ? " +
            "  AND domain_type = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, setName);
            ps.setString(2, domainType);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getDouble(1) > 0;
            }
        }
    }

    // ===============================
    // 한약 세트(regularSet) 여부 확인
    // ===============================
    private boolean isHerbalSet(Connection conn, String setName, String domainType) throws SQLException {
        String sql =
            "SELECT COUNT(*) " +
            "FROM regularSet " +
            "WHERE setName = ? " +
            "  AND domain_type = ?";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, setName);
            ps.setString(2, domainType);

            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getDouble(1) > 0;
            }
        }
    }

    // ===============================
    // 일반 세트 구성품 차감
    // productSet_detail(setName, medicineName, quantity, domain_type)
    // ===============================
private void processNormalSet(
    Connection conn,
    String setName,
    Double saleQty,
    JSONArray warnList,
    Set<String> warnedMedicines,
    String domainType
) throws SQLException {

    // 1. setName → id 조회
    String getIdSql =
        "SELECT id FROM productSet WHERE setName=? AND domain_type=?";

    int setId = -1;

    try (PreparedStatement ps = conn.prepareStatement(getIdSql)) {

        ps.setString(1, setName);
        ps.setString(2, domainType);

        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                setId = rs.getInt("id");
            } else {
                throw new SQLException("세트 없음: " + setName);
            }
        }
    }

    // 2. id로 구성품 조회
    String detailSql =
        "SELECT medicineName, quantity FROM productSet_detail " +
        "WHERE productSet_id=? AND domain_type=?";

    try (PreparedStatement ps = conn.prepareStatement(detailSql)) {

        ps.setDouble(1, setId);
        ps.setString(2, domainType);

        try (ResultSet rs = ps.executeQuery()) {

            boolean hasComponent = false;

            while (rs.next()) {

                hasComponent = true;

                String subMed = rs.getString("medicineName");
                double qty = rs.getDouble("quantity") * saleQty;

                deductFIFO(conn, subMed, qty, domainType);
                checkAndAddWarning(conn, subMed, warnList, warnedMedicines, domainType);
            }

            if (!hasComponent) {
                throw new SQLException("세트 구성 없음: " + setName);
            }
        }
    }
}

    // ===============================
    // 한약 세트 구성품 차감
    // regularSet(setName, medicineName, quantity, domain_type)
    // ===============================
private void processHerbalSet(
    Connection conn,
    String setName,
    Double saleQty,
    JSONArray warnList,
    Set<String> warnedMedicines,
    String domainType
) throws SQLException {

    String sql =
        "SELECT medicineName " +
        "FROM regularSet " +
        "WHERE setName = ? " +
        "AND domain_type = ?";

    try (PreparedStatement ps = conn.prepareStatement(sql)) {

        ps.setString(1, setName);
        ps.setString(2, domainType);

        try (ResultSet rs = ps.executeQuery()) {

            boolean hasComponent = false;

            while (rs.next()) {

                hasComponent = true;

                String subMedName = rs.getString("medicineName");

                // ⭐ 핵심: quantity 없음 → 1개 기준
                Double totalDeductQty = saleQty;

                deductFIFO(conn, subMedName, totalDeductQty, domainType);
                checkAndAddWarning(conn, subMedName, warnList, warnedMedicines, domainType);
            }

            if (!hasComponent) {
                throw new SQLException("한약 세트 구성품 없음: " + setName);
            }
        }
    }
}

    // ===============================
    // 판매 기록 저장
    // 세트든 일반 상품이든 화면에 찍힌 이름 그대로 1줄 저장
    // ===============================
    private void insertSalesRecord(
        Connection conn,
        Timestamp now,
        String itemName,
        double buyPrice,
        double salePrice,
        Double saleQty,
        String domainType
    ) throws SQLException {

        String sql =
            "INSERT INTO SalesRecord " +
            "(saleDate, medicineName, Buyingprice, price, inventory, domain_type) " +
            "VALUES (?, ?, ?, ?, ?, ?)";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setTimestamp(1, now);
            ps.setString(2, itemName);
            ps.setDouble(3, buyPrice);
            ps.setDouble(4, salePrice);
            ps.setDouble(5, saleQty);
            ps.setString(6, domainType);
            ps.executeUpdate();
        }
    }
%>

<%
JSONObject result = new JSONObject();
JSONArray warnList = new JSONArray();

try {
    StringBuilder sb = new StringBuilder();
    BufferedReader br = request.getReader();
    String line;

    while ((line = br.readLine()) != null) {
        sb.append(line);
    }

    JSONArray jsonArr = new JSONArray(sb.toString());
    Timestamp now = new Timestamp(System.currentTimeMillis());

    Set<String> warnedMedicines = new HashSet<String>();

    for (int i = 0; i < jsonArr.length(); i++) {

        JSONObject item = jsonArr.getJSONObject(i);

        String medName = item.optString("medicineName", "").trim();
        double qtySale = item.optDouble("inventory", 0);

        if (medName.isEmpty() || qtySale <= 0) {
            continue;
        }

        String priceStr = item.optString("price", "0");
        String buyingPriceStr = item.optString("Buyingprice", "0");

        if (priceStr == null || priceStr.trim().isEmpty()) priceStr = "0";
        if (buyingPriceStr == null || buyingPriceStr.trim().isEmpty()) buyingPriceStr = "0";

        double salePrice = Double.parseDouble(priceStr.replaceAll("[^\\d.]", ""));
        double buyPrice = Double.parseDouble(buyingPriceStr.replaceAll("[^\\d.]", ""));

        // ===============================
        // 분기 처리
        // 1. 일반 세트
        // 2. 한약 세트
        // 3. 일반 상품
        // ===============================
        if (isNormalSet(conn, medName, domainType)) {

            processNormalSet(conn, medName, qtySale, warnList, warnedMedicines, domainType);

        } else if (isHerbalSet(conn, medName, domainType)) {

            processHerbalSet(conn, medName, qtySale, warnList, warnedMedicines, domainType);

        } else {

            deductFIFO(conn, medName, qtySale, domainType);
            checkAndAddWarning(conn, medName, warnList, warnedMedicines, domainType);
        }

        // 판매 기록은 화면에 표시된 이름으로 저장
        insertSalesRecord(conn, now, medName, buyPrice, salePrice, qtySale, domainType);
    }

    conn.commit();

    result.put("result", "success");
    result.put("warnings", warnList);

} catch (Exception e) {

    conn.rollback();
    e.printStackTrace();

    result.put("result", "error");
    result.put("message", e.getMessage());

} finally {
    try {
        conn.setAutoCommit(prevAutoCommit);
    } catch (Exception ignore) {}

    try { if (conn != null) conn.close(); } catch (Exception ignore) {}
}

out.print(result.toString());
%>