<%-- 
    Document   : testGeoLocation
    Created on : Aug 29, 2013, 2:43:40 PM
    Author     : Randy
--%>
<script type="text/javascript" src="js/jQuery.js"></script>
<script type="text/javascript">
        $(document).ready(function(){
            $("#btnSubmit").click(function() {

                $.ajax({
                    type: "POST",
                    url: "http://localhost:8084/GeoLocation/Hello",
//                    data: "{'lat1': 42.098100},{'lon1': -76.233900},{'radius': 50.00}",
                    data: "{}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response)
                    {
                       alert("Response Recieved and Value is "+response.d);
                    },
                    error: function(msg) {
                        if (msg.status != 0) {
                            if (typeof onGlobalError == "function") {
                                onGlobalError([msg],
                                "Error while calling GeoLocation", ERRORTYPE.error);
                            }
                            if (typeof onError == "function") {
                                onError(msg);
                            }
                        }
                    }
                });

            });
        });
</script>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=windows-1252">
        <title>testGeoLocation</title>
    </head>
    <body>
    <form id="form1" runat="server">
        <input id="btnSubmit" type="button" value="Get Service Respnse" />
        <br />
        <br />
    </form>
    </body>
</html>
