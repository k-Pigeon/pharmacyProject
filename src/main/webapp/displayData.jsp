<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>조회 결과</title>
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
</head>
<body>
    <h1>조회된 데이터</h1>
    <table border="1">
        <thead>
            <tr>
                <th>약품명</th>
                <th>구매가</th>
                <th>판매가</th>
                <th>재고</th>
                <th>메모</th>
            </tr>
        </thead>
        <tbody id="dataTableBody">
            <!-- 데이터가 여기서 추가됩니다. -->
        </tbody>
    </table>

    <script>
    $(document).ready(function() {
        var saleDate = "2024-10-09 12:00:00"; // 조회할 날짜를 설정합니다.

        $.ajax({
            url: 'checkSaleDate.jsp',
            type: 'POST',
            data: { saleDate: saleDate },
            dataType: 'json',
            success: function(data) {
                if (data.error) {
                    alert(data.error); // 오류 메시지 처리
                } else if (data.length === 0) {
                    $('#dataTableBody').append('<tr><td colspan="5">조회된 데이터가 없습니다.</td></tr>');
                } else {
                    $.each(data, function(index, item) {
                        $('#dataTableBody').append('<tr>' +
                            '<td>' + item.medicineName + '</td>' +
                            '<td>' + item.Buyingprice + '</td>' +
                            '<td>' + item.price + '</td>' +
                            '<td>' + item.inventory + '</td>' +
                            '<td>' + item.memoInfo + '</td>' +
                            '</tr>');
                    });
                }
            },
            error: function(xhr, status, error) {
                console.error('Error:', error);
            }
        });
    });

    </script>
</body>
</html>
