window.addEventListener("beforeunload", function () {
    navigator.sendBeacon("backup.jsp");
});
