<%@ include file="globalvariables.jsp" %>
<script>
    function submitForm(option) {
        var returnLocation=document.getElementById("returnLocation").value;
        location.href="instantmessages_d.jsp?option=" + option + "&returnLocation=" + returnLocation;
    }

    function win(where){
        window.opener.location.href=where;
        self.close();
    }
    
</script>
<title>Message</title>

<%
// Initialize local variables
    String id           = request.getParameter("id");
    String option       = request.getParameter("option");

    String returnLocation = request.getParameter("returnLocation");
    if(returnLocation == null) { returnLocation="instantmessages.jsp"; }

    Messages messages   = (Messages)session.getAttribute("messages");

// Check to see if a Message object has been instantiated
    if(messages == null) { messages = new Messages(io); }

    if(option == null) {
    // Set the message id
        out.print("<body topmargin=5 leftmargin=5 bgcolor=#cccccc>");
        if(id != null && !id.equals("") && !id.equals("0")) {
            messages.setId(Integer.parseInt(id));

    // Display the message information
            out.print(messages.getMessage());
            out.print("<input type=\"hidden\" name=\"returnLocation\" id=\"returnLocation\" value=\"" + returnLocation + "\">");

    // Set the session variable for the Messages object
            session.setAttribute("messages", messages);
        } else {
            out.print("Patient not set");
        }
        out.print("</body>");
    } else {
        if(option.equals("S")) {
            messages.updateSnooze(messages.getId());
        } else if(option.equals("O")) {
            messages.updateComplete(messages.getId());
        }
    }
    if(option != null) { %>
        <body onLoad="win('<%=returnLocation%>')">
        <body>
<%    }
%>