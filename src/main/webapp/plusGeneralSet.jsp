<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.sql.*"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>바코드 스캔</title>
<link rel="stylesheet" href="style.css">
</head>
<body>
    <div id="wrap">
        <header>
            <jsp:include page="header.jsp"></jsp:include>
        </header>
        <h1 style="display:block;position:absolute;right:40%;top: 5%;">한약 세트 추가</h1>
        <table style="margin-top: 12%;border: 1px solid black;border-collapse: collapse;min-width: 50%;height: 500px;" id="table_input">
            <colgroup>
                <col width="50%">
                <col width="50%">
            </colgroup>
            <tr>
                <th>제품코드<br>(바코드 스캐너 사용)</th>
                <td><input type="text" name="SerialNumber" class="SerialNumber"></td>
            </tr>
            <tr>
                <th>세트명</th>
                <td><input type="text" name="medicineNameSet" class="medicineNameSet"></td>
            </tr>
            <tr>
                <th>총가격</th>
                <td><input type="text" name="price" class="price"></td>
            </tr>
            <tr>
                <th>사입가격</th>
                <td><input type="text" name="Buyingprice" class="Buyingprice"></td>
            </tr>
            <tr>
                <th>1번제품명</th>
                <td><input type="text" name="resource1" class="resource1"></td>
            </tr>
            <tr>
                <th>2번제품명</th>
                <td><input type="text" name="resource2" class="resource2"></td>
            </tr>
            <tr>
                <th>3번제품명</th>
                <td><input type="text" name="resource3" class="resource3"></td>
            </tr>
            <tr>
                <th>4번제품명</th>
                <td><input type="text" name="resource4" class="resource4"></td>
            </tr>
            <tr>
                <th>5번제품명</th>
                <td><input type="text" name="resource5" class="resource5"></td>
            </tr>
            <tr>
                <td colspan="2"><input type="button" value="세트추가" id="addSetButton"></td>
            </tr>
        </table>
    </div>
    <script src="jquery-3.7.1.min.js"></script>
    <script>
    $(document).ready(function() {
        
        const barcodeInput = $('#wrap #table_input .SerialNumber');
        let inputCleared = false;
        barcodeInput.focus(); // To focus the input field automatically (optional)
        
        // 다음 포커스를 설정하기 위한 변수
        var nextInput = null;

        $("#wrap #table_input .SerialNumber").keypress(function(event) {
            // Enter 키의 keycode는 13
            if (event.which == 13) {
                // SerialNumber 값 가져오기
                var serialNumber = $(this).val();

                // AJAX 요청 설정
                $.ajax({
                    type: "POST",
                    url: "fetchDataFromDB2.jsp", // 실제로 데이터를 DB에서 가져올 서버 파일 경로
                    data: { serialNumber: serialNumber }, // SerialNumber를 서버에 전송
                    dataType: "json",
                    success: function(response) {
                        if (response.error) {
                            console.error("DB 조회 오류:", response.error);
                            return;
                        }

                        if (response.SerialNumber) {
                            var confirmation = confirm("기존에 있는 데이터를 사용하시겠습니까?");
                            if (confirmation) {
                             	// 현재 텍스트 필드에서 값을 가져와서 숫자로 변환
                                var currentBuyingPrice = parseFloat($("#table_input .Buyingprice").val()) || 0;
                                var responseBuyingPrice = parseFloat(response.Buyingprice) || 0;
                             	// 두 숫자를 더함
                                var totalBuyingPrice = currentBuyingPrice + responseBuyingPrice;
                             	// 결과를 텍스트 필드에 다시 설정
                                $("#table_input .Buyingprice").val(totalBuyingPrice);

                                // 빈 필드를 찾아서 medicineName을 설정
                                var fields = ["resource1", "resource2", "resource3", "resource4", "resource5"];
                                var i = 0;
                                while (i < fields.length && $("#table_input ." + fields[i]).val() !== "") {
                                    i++;
                                }
                                if (i < fields.length) {
                                    $("#table_input ." + fields[i]).val(response.medicineName);
                                }

                                // 다음 포커스를 medicineNameSet으로 설정
                                nextInput = $("#table_input .medicineNameSet");
                                
                            } else {
                                // 다음 포커스를 SerialNumber로 설정
                                nextInput = $("#table_input .SerialNumber");
                            }
                        } else {
                            // 데이터가 없는 경우 입력 필드를 비움
                            $("#table_input input, #table_input select").val("");

                            // 다음 포커스를 빈 필드로 설정
                            nextInput = $("#table_input .medicineNameSet");
                        }
                    },
                    error: function(xhr, status, error) {
                        console.error("AJAX 요청 에러:", error);
                    }
                });

                // 다음 포커스를 설정한 input으로 이동
                if (nextInput) {
                    nextInput.focus();
                    nextInput = null; // 다음 포커스를 null로 초기화하여 다음에 Enter 키를 누를 때에도 영향을 받지 않도록 함
                }

                // Enter 키에 대한 기본 동작 방지
                event.preventDefault();
            }
        });

        // 세트 추가 버튼 클릭 이벤트 핸들러
        $("#addSetButton").click(function() {
            // 입력 필드 값 가져오기
            var serialNumber = $("#table_input .SerialNumber").val();
            var medicineNameSet = $("#table_input .medicineNameSet").val();
            var price = $("#table_input .price").val();
            var Buyingprice = $("#table_input .Buyingprice").val();
            var resource1 = $("#table_input .resource1").val();
            var resource2 = $("#table_input .resource2").val();
            var resource3 = $("#table_input .resource3").val();
            var resource4 = $("#table_input .resource4").val();
            var resource5 = $("#table_input .resource5").val();

            // 각 resource의 Buyingprice 합산
            var totalBuyingprice = 0;
            var resources = [resource1, resource2, resource3, resource4, resource5];
            resources.forEach(function(resource) {
                if (resource) {
                    totalBuyingprice += parseFloat(Buyingprice) || 0;
                }
            });

            // AJAX 요청 설정
            $.ajax({
                type: "POST",
                url: "addvibrancySet.jsp", // 데이터를 서버로 보낼 서버 파일 경로
                data: {
                    serialNumber: serialNumber,
                    medicineNameSet: medicineNameSet,
                    Buyingprice: totalBuyingprice.toFixed(2),
                    price: price,
                    resource1: resource1,
                    resource2: resource2,
                    resource3: resource3,
                    resource4: resource4,
                    resource5: resource5
                },
                success: function(response) {
                    if (response.error) {
                        console.error("데이터 전송 오류:", response.error);
                        alert("데이터 전송 중 오류가 발생했습니다. 다시 시도해주세요.");
                        return;
                    }
                    alert("세트 추가가 성공적으로 완료되었습니다!");
                },
                error: function(xhr, status, error) {
                    console.error("AJAX 요청 에러:", error);
                    alert("서버와 통신 중 오류가 발생했습니다. 다시 시도해주세요.");
                }
            });
        });

        // 입력란 변수
        var $SerialNumber = $("#table_input .SerialNumber");
        var $medicineNameSet = $("#table_input .medicineNameSet");
        var $Buyingprice = $("#table_input .Buyingprice");
        var $price = $("#table_input .price");
        var $resource1 = $("#table_input .resource1");
        var $resource2 = $("#table_input .resource2");
        var $resource3 = $("#table_input .resource3");
        var $resource4 = $("#table_input .resource4");
        var $resource5 = $("#table_input .resource5");

        $("#wrap").mouseover(function() {
            if (!($SerialNumber.is(':focus') || $medicineNameSet.is(':focus') || $price.is(':focus') ||
                  $resource1.is(':focus') || $resource2.is(':focus') || $resource3.is(':focus') ||
                  $resource4.is(':focus') || $resource5.is(':focus') || $Buyingprice.is(':focus'))) {
                $SerialNumber.focus();
            }
        });
        $("#wrap").on("click", function() {
            if (!($SerialNumber.is(':focus') || $medicineNameSet.is(':focus') || $price.is(':focus') ||
                  $resource1.is(':focus') || $resource2.is(':focus') || $resource3.is(':focus') ||
                  $resource4.is(':focus') || $resource5.is(':focus') || $Buyingprice.is(':focus'))) {
                $SerialNumber.focus();
            }
        });
    });
    </script>
</body>
</html>
