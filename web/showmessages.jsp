<%-- 
    Document   : showmessages
    Created on : Jan 24, 2008, 10:18:12 PM
    Author     : Randy
--%>
<%@ include file="globalvariables.jsp" %>
<%
    Messages messages = new Messages(io);

// Show the messages
    out.print("<table border=0 cellpadding=0 cellspacing=0 width='100%'><tr><td align=center><table border=0 cellpadding=0 cellspacing=0><tr><td align=left>");
//    out.print(messages.getMessages(Integer.parseInt(patientId)));
    out.print(messages.getMessages(patient.getId()));
    out.print("</td></tr></table></td></tr></table>");

%>