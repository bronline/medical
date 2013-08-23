<%-- 
    Document   : instantmessages_monitor
    Created on : Sep 2, 2010, 8:45:47 AM
    Author     : rwandell
--%>

<%@ page import="tools.*, tools.utils.Format, java.sql.ResultSet, medical.Messages" %>
<link rel="stylesheet" type="text/css" href="css/stylesheet.css" title="stylesheet">
<script>
  var timer = 60;
  function countdown() {
    if(timer > 0) {
      document.frmInput.countdown.value = timer;
      timer -= 1;
      setTimeout("countdown()",1000);
    } else {
        var startDate=document.getElementById("startDate").value;
        location.href="instantmessages_monitor.jsp?startDate=" + startDate;
    }
  }
</script>

<body onLoad="countdown();" topmargin="0" leftmargin="0" bottommargin="0" style="background: 000066">
    <form name=frmInput>
    <input type=hidden name=countdown>
    </form>

<%
    String databaseName=(String)session.getAttribute("databaseName");
    if(databaseName != null) {
        String startDate=request.getParameter("startDate");

        RWConnMgr io=new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);

        Messages messages = new Messages(io);
        messages.setDivHeight(70);
        String patientId  = request.getParameter("patientId");

    // If patient id is null, set the patient id 0 to get all messages
        if(patientId == null) { patientId = "0"; }

        if(startDate == null) { startDate="0001-01-01 00:00:00"; }

        String myQuery="select m.*, concat(p.firstname, ' ', p.lastname) as name from patientmessages m " +
                        "join patients p on p.id=m.patientid where date<=current_date and " +
                        "displayed>='" + startDate + "' and complete='0001-01-01 00:00:00.0' " +
                        "order by patientid, date";
    // Check to see if there are any new messages
        ResultSet lRs=io.opnRS(myQuery);

    // Show the messages
        out.print("<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\"><tr><td align=center><table border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><tr><td align=left>");
        out.print(messages.getMessagesForPopup(startDate));
        out.print("</td></tr></table></td></tr></table>");
        out.print("<input type=\"hidden\" name=\"startDate\" id=\"startDate\" value=\"" + startDate + "\">");

        if(lRs.next()) {
            out.print("<script type=\"text/javascript\">window.focus()</script>");
        }
    // Close the Connection
        io.getConnection().close();
        io = null;
        messages = null;

        System.gc();
    }
%>
</body>
