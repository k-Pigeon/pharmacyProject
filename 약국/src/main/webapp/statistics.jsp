<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.util.*, java.sql.*, javax.servlet.*, javax.servlet.http.*, org.json.JSONArray, org.json.JSONObject, java.util.regex.*"%>
<%@ include file="sessionManager.jsp"%>
<%@ include file="DBconnection.jsp"%>

<%
response.setContentType("application/json; charset=UTF-8");
request.setCharacterEncoding("UTF-8");

String dbName = (session != null) ? (String) session.getAttribute("dbName") : null;
String id = (session != null) ? (String) session.getAttribute("id") : null;
String idSortation = (session != null) ? (String) session.getAttribute("idSortation") : null;

if (id == null || dbName == null) {
    response.sendRedirect("login.jsp");
    return;
}

boolean prevAutoCommit = conn.getAutoCommit();
conn.setAutoCommit(false);
%>

<%!
    private String formatDate(String inputDate) {
        try {
            if (inputDate == null) return null;
            String s = inputDate.trim();
            if (s.isEmpty() || "null".equalsIgnoreCase(s) || "undefined".equalsIgnoreCase(s)) return null;

            s = s.replace('T', ' ');

            if (s.matches("\\d{4}-\\d{2}-\\d{2}\\s+\\d{2}:\\d{2}:\\d{2}")) return s;
            if (s.matches("\\d{4}-\\d{2}-\\d{2}")) return s + " 00:00:00";

            if (s.matches("\\d{2,4}/\\d{1,2}/\\d{1,2}")) {
                String[] p = s.split("/");
                int y = Integer.parseInt(p[0]);
                int m = Integer.parseInt(p[1]);
                int d = Integer.parseInt(p[2]);
                if (y < 100) y += 2000;
                return String.format("%04d-%02d-%02d 00:00:00", y, m, d);
            }
            return null;
        } catch (Exception e) {
            System.err.println("날짜 변환 오류: " + inputDate + " / " + e.getMessage());
            return null;
        }
    }

    private Timestamp findUniqueSaleDate(Connection conn, String idSortation, Timestamp baseTs) throws SQLException {
        Timestamp ts = baseTs;

        final String sqlSales = "SELECT 1 FROM SalesRecord" + idSortation + " WHERE saleDate = ? LIMIT 1";
        final String sqlPrice = "SELECT 1 FROM priceRecord" + idSortation + " WHERE saleDate = ? LIMIT 1";
        final String sqlDisc  = "SELECT 1 FROM discountedDB WHERE sale_date = ? LIMIT 1";

        while (true) {
            boolean exists = false;

            try (PreparedStatement ps = conn.prepareStatement(sqlSales)) {
                ps.setTimestamp(1, ts);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) exists = true;
                }
            }
            if (!exists) {
                try (PreparedStatement ps = conn.prepareStatement(sqlPrice)) {
                    ps.setTimestamp(1, ts);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) exists = true;
                    }
                }
            }
            if (!exists) {
                try (PreparedStatement ps = conn.prepareStatement(sqlDisc)) {
                    ps.setTimestamp(1, ts);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) exists = true;
                    }
                }
            }

            if (!exists) break;
            ts = new Timestamp(ts.getTime() + 1);
        }
        return ts;
    }

    private double getFactor(String standard) {
        if (standard == null) return 1.0;
        standard = standard.trim();
        if (standard.isEmpty()) return 1.0;

        double result = 1.0;
        boolean found = false;
        Matcher m = Pattern.compile("\\d+(\\.\\d+)?").matcher(standard);
        while (m.find()) {
            found = true;
            result *= Double.parseDouble(m.group());
        }
        if (!found) return 1.0;
        return result <= 0 ? 1.0 : result;
    }
    
    private void deductSingleSetFIFO(
            Connection conn,
            String idSortation,
            String medicineName,
            int deductQty
    ) throws SQLException {

        String selectSql =
                "SELECT DeliveryDate, inventory FROM testTable" + idSortation +
                " WHERE medicineName=? AND returnInv='0' AND inventory > 0 " +
                " ORDER BY DeliveryDate ASC";

            String updateSql =
                "UPDATE testTable" + idSortation +
                " SET inventory=? WHERE medicineName=? AND DeliveryDate=? AND returnInv='0'";

            try (PreparedStatement psSel = conn.prepareStatement(selectSql);
                 PreparedStatement psUpd = conn.prepareStatement(updateSql)) {

                psSel.setString(1, medicineName);
                try (ResultSet rs = psSel.executeQuery()) {

                    int remain = deductQty;

                    while (rs.next() && remain > 0) {
                        String ddate = rs.getString("DeliveryDate");
                        int inv = rs.getInt("inventory");

                        if (inv >= remain) {
                            // 이 행에서만 차감하고 끝
                            psUpd.setInt(1, inv - remain);
                            psUpd.setString(2, medicineName);
                            psUpd.setString(3, ddate);
                            psUpd.executeUpdate();
                            remain = 0;
                        } else {
                            // 이 행은 전부 소진
                            psUpd.setInt(1, 0);
                            psUpd.setString(2, medicineName);
                            psUpd.setString(3, ddate);
                            psUpd.executeUpdate();
                            remain -= inv;
                        }
                    }
                }
            }
    }


    private void deductWithStandard(Connection conn, String idSortation, String medicineName, double saleQty, String saleStandard) throws SQLException {
        double saleFactor = getFactor(saleStandard);
        double saleBase   = saleQty * saleFactor;

        double dbBase = 0;
        double storeFactor = 1;

        String selectSql = "SELECT inventory, standard FROM testTable" + idSortation +
                           " WHERE medicineName=? AND returnInv='0' ORDER BY DeliveryDate ASC";

        try (PreparedStatement ps = conn.prepareStatement(selectSql)) {
            ps.setString(1, medicineName);
            try (ResultSet rs = ps.executeQuery()) {
                boolean first = true;
                while (rs.next()) {
                    double inv = rs.getDouble("inventory");
                    double f   = getFactor(rs.getString("standard"));
                    if (first) { storeFactor = f; first = false; }
                    dbBase += inv * f;
                }
            }
        }

        double remainBase = Math.max(0, dbBase - saleBase);
        double finalInv   = remainBase / storeFactor;

        // 모두 0으로 초기화
        try (PreparedStatement ps = conn.prepareStatement(
            "UPDATE testTable" + idSortation + " SET inventory=0 WHERE medicineName=? AND returnInv='0'")) {
            ps.setString(1, medicineName);
            ps.executeUpdate();
        }

        // 가장 오래된 1행에만 최종 재고 저장
        try (PreparedStatement ps = conn.prepareStatement(
            "UPDATE testTable" + idSortation +
            " SET inventory=? WHERE medicineName=? AND returnInv='0' ORDER BY DeliveryDate ASC LIMIT 1")) {
            ps.setDouble(1, finalInv);
            ps.setString(2, medicineName);
            ps.executeUpdate();
        }
    }

    private void checkAndAddWarning(Connection conn, String idSortation, String medicineName,
                                    JSONArray warnList, Set<String> warnedMedicines) throws SQLException {
        if (warnedMedicines.contains(medicineName)) return;

        String sql =
            "SELECT SUM(inventory) AS totalInv, standard, quantity " +
            "FROM testTable" + idSortation + " " +
            "WHERE medicineName=? AND returnInv='0' " +
            "GROUP BY standard, quantity LIMIT 1";

        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, medicineName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double inv = rs.getDouble("totalInv");
                    String std = rs.getString("standard");
                    double qty = rs.getDouble("quantity");

                    if (inv < qty) {
                        JSONObject warn = new JSONObject();
                        warn.put("medicineName", medicineName);
                        warn.put("standard", std);
                        warn.put("realInv", inv);
                        warn.put("quantity", qty);

                        warnList.put(warn);
                        warnedMedicines.add(medicineName);
                    }
                }
            }
        }
    }
%>

<%
JSONObject result = new JSONObject();
JSONArray warnList = new JSONArray();

try {
    // 1) 요청 본문 파싱
    StringBuilder sb = new StringBuilder();
    try (BufferedReader br = request.getReader()) {
        String line;
        while ((line = br.readLine()) != null) sb.append(line);
    }

    JSONArray jsonArr = new JSONArray(sb.toString());
    if (jsonArr.length() == 0) throw new RuntimeException("요청 JSON이 비어있습니다.");

    JSONObject meta = jsonArr.getJSONObject(jsonArr.length() - 1);

    String medicinePrice = meta.optString("medicinePrice", "0");
    String generalPrice  = meta.optString("generalPrice", "0");
    String clientName    = meta.optString("discounted", "");

    String raw = meta.has("ScheduleDate") ? meta.optString("ScheduleDate", "") : meta.optString("scheduleDate", "");
    raw = (raw == null) ? "" : raw.trim();

    // 2) saleDate 결정
    String formatted = formatDate(raw);
    Timestamp baseNow = (formatted == null || formatted.isEmpty())
            ? new Timestamp(System.currentTimeMillis())
            : Timestamp.valueOf(formatted);

    Timestamp now = findUniqueSaleDate(conn, idSortation, baseNow);

    // 3) priceRecord / discountedDB는 1번만 기록
    try (PreparedStatement ps = conn.prepareStatement(
        "INSERT INTO priceRecord" + idSortation + " (saleDate, maxmedicinePrice, generalPrice) VALUES (?, ?, ?)")) {
        ps.setTimestamp(1, now);
        ps.setString(2, medicinePrice);
        ps.setString(3, generalPrice);
        ps.executeUpdate();
    }

    try (PreparedStatement ps = conn.prepareStatement(
        "INSERT INTO discountedDB (sale_date, discounted) VALUES (?, ?)")) {
        ps.setTimestamp(1, now);
        ps.setString(2, clientName);
        ps.executeUpdate();
    }

    // (선택) 빈 이름 행 청소는 루프 전에 1번만
    try (PreparedStatement deleteTmt = conn.prepareStatement(
        "DELETE FROM SalesRecord" + idSortation + " WHERE medicineName = ''")) {
        deleteTmt.executeUpdate();
    }

    Set<String> warnedMedicines = new HashSet<>();

    // 4) 아이템 루프
    for (int i = 0; i < jsonArr.length() - 1; i++) {
        JSONObject item = jsonArr.getJSONObject(i);

        String serial   = item.optString("serialNumber", "").trim();
        String medName  = item.optString("medicineName", "").trim();
        int qtySale = item.optInt("inventory", 0);

        if (medName.isEmpty() || qtySale <= 0) {
            continue; // 입력 이상치는 스킵
        }

        String priceStr = item.optString("price", "0").replaceAll("[^\\d.]", "");
        String buyStr   = item.optString("Buyingprice", "0").replaceAll("[^\\d.]", "");

        double salePrice = 0.0, buyPrice = 0.0;
        try { salePrice = Double.parseDouble(priceStr); } catch (Exception ignore) {}
        try { buyPrice  = Double.parseDouble(buyStr); } catch (Exception ignore) {}

        boolean isMixedSet = false;
        boolean isRegularSet = false;

        String innerMedName = null;
        int unitQty = 1;

        // 혼합세트 여부
        try (PreparedStatement ck = conn.prepareStatement(
            "SELECT 1 FROM productSet" + idSortation + " WHERE setName=? LIMIT 1")) {
            ck.setString(1, medName);
            try (ResultSet rs = ck.executeQuery()) {
                if (rs.next()) isMixedSet = true;
            }
        }

        // 일반세트 여부
        if (!isMixedSet) {
            try (PreparedStatement ps = conn.prepareStatement(
                "SELECT medicineName, inventory FROM regularSet" + idSortation + " WHERE setName=? LIMIT 1")) {
                ps.setString(1, medName);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        isRegularSet = true;
                        innerMedName = rs.getString("medicineName");
                        unitQty = rs.getInt("inventory");
                    }
                }
            }
        }

        if (isMixedSet) {

            // 🔥 혼합세트
            try (PreparedStatement ps = conn.prepareStatement(
                "SELECT psd.medicineName, psd.standard " +
                "FROM productSet_detail" + idSortation + " psd " +
                "JOIN productSet" + idSortation + " ps ON ps.id = psd.productSet_id " +
                "WHERE ps.setName=?")) {
                ps.setString(1, medName);
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String innerMed = rs.getString("medicineName");
                        String innerStd = rs.getString("standard");
                        if (innerMed == null || innerMed.trim().isEmpty()) continue;

                        deductWithStandard(conn, idSortation, innerMed, qtySale, innerStd);
                        checkAndAddWarning(conn, idSortation, innerMed, warnList, warnedMedicines);
                    }
                }
            }

        } else if (isRegularSet) {

            // ✅ 일반세트
            int deductQty = unitQty * qtySale;
            deductSingleSetFIFO(conn, idSortation, innerMedName, deductQty);
            checkAndAddWarning(conn, idSortation, innerMedName, warnList, warnedMedicines);

        } else {

            // 🟢 단일제품
            deductSingleSetFIFO(conn, idSortation, medName, qtySale);
            checkAndAddWarning(conn, idSortation, medName, warnList, warnedMedicines);
        }


        // ★ 판매기록은 혼합/일반 상관없이 항상 저장
        try (PreparedStatement ps = conn.prepareStatement(
            "INSERT INTO SalesRecord" + idSortation +
            " (saleDate, medicineName, Buyingprice, price, " + 
            "inventory, SerialNumber, DeliveryDate, standard, memberName) " +
            " VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)")) {
            ps.setTimestamp(1, now);
            ps.setString(2, medName);
            ps.setDouble(3, buyPrice);
            ps.setDouble(4, salePrice);
            ps.setInt(5, qtySale);
            ps.setString(6, serial);
            ps.setString(7, item.optString("deliveryDate", ""));
            ps.setString(8, item.optString("standard", ""));
            ps.setString(9, item.optString("memberName", ""));
            ps.executeUpdate();
        }
    }

    // 5) 모든 처리 성공 시 commit 1번
    conn.commit();

    result.put("result", "success");
    result.put("warnings", warnList);

} catch (Exception e) {
    try { conn.rollback(); } catch (SQLException ignore) {}

    e.printStackTrace();

    result.put("result", "error");
    result.put("message", String.valueOf(e.getMessage()).replace("\"", "'"));
} finally {
    try { conn.setAutoCommit(prevAutoCommit); } catch (SQLException ignore) {}
}

out.print(result.toString());
%>

<%@ include file="DBclose.jsp" %>
