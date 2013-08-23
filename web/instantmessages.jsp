<%@ page import="tools.*, medical.Messages" %>
<link rel="stylesheet" type="text/css" href="css/stylesheet.css" title="stylesheet">
<script>
  var timer = 15;
  function countdown() {
    if(timer > 0) {
      document.frmInput.countdown.value = timer;
      timer -= 1;
      setTimeout("countdown()",1000);
    } else {
      location.href="instantmessages.jsp";
    }
  }
</script>

<body onLoad="countdown()" topmargin="0" leftmargin="0" bottommargin="0" style="background: 000066">
    <form name=frmInput>
    <input type=hidden name=countdown>
    </form>

<%
    String databaseName=(String)session.getAttribute("databaseName");
    if(databaseName != null) {

        RWConnMgr io=new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);

        Messages messages = new Messages(io);
        String patientId  = request.getParameter("patientId");

    // If patient id is null, set the patient id 0 to get all messages
        if(patientId == null) { patientId = "0"; }

    // Show the messages
        out.print("<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\"><tr><td align=center><table border=\"0\" cellpadding=\"0\" cellspacing=\"0\"><tr><td align=left>");
    //    out.print(messages.getMessages(Integer.parseInt(patientId)));
        out.print(messages.getMessages(0));
        out.print("</td></tr></table></td></tr></table>");

    // Close the Connection
        io.getConnection().close();
        io = null;
        messages = null;

        System.gc();
    }
%>
</body>
