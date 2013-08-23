<%-- 
    Document   : tasklist
    Created on : Apr 9, 2012, 9:38:30 AM
    Author     : rwandell
--%>
<%@ page import="java.sql.*, tools.*, tools.utils.*" %>
<html>
    <head>
        <link rel="stylesheet" type="text/css" href="css/stylesheet.css" title="stylesheet">

    </head>
<script type="text/javascript" src="js/jQuery.js"></script>
<script type="text/javascript" src="js/date-picker.js"></script>
<script type="text/javascript" src="js/CheckDate.js"></script>
<script type="text/javascript" src="js/CheckLength.js"></script>
<script type="text/javascript" src="js/colorpicker.js"></script>
<script type="text/javascript" src="js/datechecker.js"></script>
<script type="text/javascript" src="js/dFilter.js"></script>
<script type="text/javascript" src="js/currency.js"></script>
<script type="text/javascript" src="js/checkemailaddress.js"></script>
<script type="text/javascript" src="js/invertselection.js"></script>
<script type="text/javascript" src="js/setCheckBoxValue.js"></script>

<script>
    var timer = 15;
    function countdown() {
        if(timer > 0) {
            $('#countdown').val(timer);
            timer -= 1;
            setTimeout("countdown()",1000);
        } else {
            location.href = "tasklist.jsp";
        }
    }

    function showTask(id) {
        var url="ajax/gettask.jsp?id=" + id;
        timer=99999999;
        $.ajax({
            url: url,
            success: function(data){
                $('#taskbubble').html(data);
            },
            error: function() {
                alert("There was a problem processing the request");
            },
            complete: function() {
                $('#taskbubble').css('display','');
            }
        });
        
    }

    function closeTaskBubble() {
        $('#taskbubble').css('display','none');
        timer=15;
    }


</script>

<body onLoad="countdown()" style="margin-top: 0px; margin-left: 0px; margin-bottom: 0px;">
    <input type="hidden" name="countdown" id="countdown">
    <div id="taskbubble" name="taskbubble" style="position: absolute; margin-left: 5px; top: 50px; width: 300px; height: 190px; border-radius: 10px; background-color: #a6c3f8; display: none;"></div>
<%
    String databaseName=(String)session.getAttribute("databaseName");
    String showCompleted=request.getParameter("showCompleted");
    String maxDate=(String)session.getAttribute("max_date");

    if(databaseName != null) {

        RWConnMgr io=new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);
        RWHtmlTable htmTb = new RWHtmlTable("300", "0");
        if(showCompleted == null) { showCompleted = ""; } else { showCompleted = "where not completed"; }

    // Show the tasks
        out.print("<input type=\"button\" value=\"new task\" onclick=\"showTask(0)\" class=\"button\"><br/><br/>");
        out.print(htmTb.startTable());
        out.print(htmTb.startRow());
        out.print(htmTb.headingCell("Due Date", "width=\"15%\""));
        out.print(htmTb.headingCell("Task","width=\"85%\""));
        out.print(htmTb.endRow());
        out.print(htmTb.endTable());

        ResultSet tRs = io.opnRS("SELECT *, DATEDIFF(due_date, current_date) as overdue FROM tasklist " + showCompleted + " order by due_date");
        out.print("<div style=\"width: 320px; height: 600px; overflow: auto;\">");
        out.print(htmTb.startTable());
        while(tRs.next()) {
            String rowColor="";
            if(tRs.getBoolean("completed")) { rowColor = "style=\"color: green;\""; }
            else if (tRs.getInt("overdue")<0) { rowColor = "style=\"color: red;\""; }
            out.print(htmTb.startRow("style=\"cursor: pointer;\" onClick=\"showTask(" + tRs.getString("id") + ")\""));
            out.print(htmTb.addCell(Format.formatDate(tRs.getString("due_date"),"MM/dd/yy"),"width=\"15%\" " + rowColor));
            out.print(htmTb.addCell(tRs.getString("task"),"width=\"85%\" " + rowColor));
            out.print(htmTb.endRow());
        }
        out.print(htmTb.endTable());

        ResultSet mRs = io.opnRS("select max(date_entered) as max_date from tasklist where date_entered>'' and not completed");
        if(mRs.next()) {
            if(maxDate != null && maxDate.compareTo(mRs.getString("max_date"))!=0) {
                out.print("<script type=\"text/javascript\">window.focus();</script>");
            }
            session.setAttribute("max_date",mRs.getString("max_date"));
        }
    // Close the Connection
        io.getConnection().close();
        io = null;

        System.gc();
    }
%>
</body>
</html>