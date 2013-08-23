<%-- 
    Document   : getinstantmessages
    Created on : Jun 22, 2010, 12:52:57 PM
    Author     : Randy
--%>
<%@ include file="sessioninfo.jsp" %>
<%
    String startDate=request.getParameter("startDate");

    String myQuery = "select case when MAX(m.displayed) IS NULL THEN 'NONE' ELSE '' END AS MessagesExist, ifNull(MAX(m.displayed),current_timestamp) AS MaximumTime " +
        "from patientmessages m" +
        "join patients p on p.id=m.patientid where date<=current_date and " +
        "displayed<>'0001-01-01 00:00:00.0' and complete='0001-01-01 00:00:00.0' " +
        "and displayed>'" + startDate + "' order by patientid, date";
    ResultSet lRs=io.opnRS(myQuery);
    lRs.next();

    if(lRs.getString("MessagesExist").equals("")) {
        Messages messages = new Messages(io);

        if(startDate==null) { startDate=Format.formatDate(new java.util.Date(), "yyyy-MM-dd HH:mm:ss"); }
    // Show the messages
        out.print("<v:instantMessagesBubble style='width: 830; height: 85; text-valign: middle; text-align: center;' arcsize='.05' fillcolor='#3399bb'>");

        out.print("<br>");
        out.print("<table border=0 cellpadding=0 cellspacing=0 width='100%'><tr><td align=center><table border=0 cellpadding=0 cellspacing=0><tr><td align=left>");
    //    out.print(messages.getMessages(Integer.parseInt(patientId)));
        out.print(messages.getMessagesForPopup(startDate));
        out.print("</td></tr></table></td></tr></table>");

        out.print("</v:instantMessagesBubble>");
    } else {
        out.print("NONE:" + lRs.getString("MaximumTime"));
    }
    lRs.close();
%>
<%@include file="cleanup.jsp" %>