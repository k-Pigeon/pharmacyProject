<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>재고 부족 경고</title>
</head>
<body>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<script>
function checkInventory() {
    $.ajax({
        url: "statistics.jsp",
        method: "POST",
        data: JSON.stringify(yourDataArray), // 실제 데이터 전송
        contentType: "application/json; charset=UTF-8",
        dataType: "json",
        success: function (res) {
            if (res.result === "success") {
                showWarningUI(res.warnings);
            } else {
                alert("서버 오류: " + res.message);
            }
        },
        error: function () {
            alert("서버 통신 오류 발생");
        }
    });
}

function showWarningUI(warnings) {
    let box = document.createElement("div");
    box.id = "warningBox";
    box.innerHTML = `
        <div id="warningList">
            <h3>🚨 재고 부족 경고</h3>
            ${warnings.length === 0 
                ? "<p>✅ 모든 재고가 충분합니다.</p>"
                : warnings.map(w => `
                    <div class="warn">
                        <b>${w.medicineName}</b> (${w.standard})<br>
                        남은 재고: <span style="color:red;">${w.realInv}</span> / 필요 수량: ${w.quantity}
                    </div>`).join("")
            }
            <button id="closeWarning">닫기</button>
        </div>`;
    document.body.appendChild(box);

    // 스타일 적용
    Object.assign(box.style, {
        position: "fixed",
        right: "20px",
        bottom: "20px",
        background: "#fff8f8",
        border: "1px solid #ffb3b3",
        borderRadius: "12px",
        padding: "20px",
        boxShadow: "0 4px 15px rgba(0,0,0,0.2)",
        zIndex: "9999"
    });

    document.getElementById("closeWarning").onclick = () => box.remove();
}
</script>

</body>
</html>
