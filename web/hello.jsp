<%@include file="template/pagetop.jsp" %>
<style>
#messageText { font-size: 26px;  color:red; }
</style>
<%
    RWHtmlTable htmTb  = new RWHtmlTable();
    RWFilteredList lst = new RWFilteredList(io);
    StringBuffer pm    = new StringBuffer();
    String returnPoint = (String)session.getAttribute("locationReturnPoint");
    Messages messages  = (Messages)session.getAttribute("messages");

//    returnPoint="soapsurvey.jsp";
    returnPoint="swipeinlocation.jsp";

// Check to see if there is an existing messages object. If not, create one
    if(messages == null) { messages = new Messages(io); }

// Check to see if the patient was found
    if(patient.next()) {
        if(returnPoint != null) { out.print("<body onload=setTimeout(\"location.href='" + returnPoint + "'\",3000)> "); }

        htmTb.setWidth("650");
        htmTb.setBorder("0");
        htmTb.replaceNewLineChar(false);

        pm.append(htmTb.startTable());

        pm.append(htmTb.startRow());
        pm.append(htmTb.headingCell("Welcome " + patient.getPatientName(), htmTb.CENTER, "style=\"color: #2c57a7; font-size: 20px; font-weight: bold; background: #ffffff;\""));
        pm.append(htmTb.endRow());

        pm.append(htmTb.startRow());
        pm.append(htmTb.addCell(""));
        pm.append(htmTb.endRow());

        messages.setPatientId(patient.getId());

        messages.updateDisplayed(patient.getId());

        session.setAttribute("messages", messages);

        boolean messageDisplayed=false;
        // 10/24/07 Check to see if the appointment type has an instantmessage
        ResultSet visitRs=io.opnRS("select * from visits left join appointments on visits.appointmentid=appointments.id left join appointmenttypes on appointments.type=appointmenttypes.id where visits.id=" + visit.getId());
        if(visitRs.next()) {
            if(visitRs.getBoolean("instantmessage")) {
                pm.append(htmTb.startRow("height=300"));
                pm.append(htmTb.startCell(htmTb.CENTER));
                pm.append(htmTb.startTable());

                pm.append(htmTb.startRow());
                pm.append(htmTb.addCell("Please stop at the front desk.  Thank you", "id=messageText"));
                pm.append(htmTb.endRow());
                pm.append(htmTb.endTable());
                pm.append(htmTb.endCell());
                pm.append(htmTb.endRow());
                messageDisplayed=true;
            }
        }

        if(!messageDisplayed) {
            ResultSet mRs = io.opnRS("select * from patientmessages where display and patientid=" + patient.getId() + " and date<=current_date and date(displayed)<>'0001-01-01' and date(complete)='0001-01-01'");

            pm.append(htmTb.startRow("height=300"));
            pm.append(htmTb.startCell(htmTb.CENTER));
            pm.append(htmTb.startTable());
            if(mRs.next()) {
                pm.append(htmTb.startRow());
                pm.append(htmTb.addCell("Please stop at the front desk.  Thank you", "id=messageText"));
    //            pm.append(htmTb.addCell(mRs.getString("message"), htmTb.LEFT, "id=messageText"));
                pm.append(htmTb.endRow());
            }
            pm.append(htmTb.endTable());
            pm.append(htmTb.endCell());
            pm.append(htmTb.endRow());
            mRs.close();
        }
        visitRs.close();

        pm.append(htmTb.endTable());

        htmTb.setWidth("800");
        out.print(htmTb.getFrame(htmTb.BOTH, "", "#ffffff", 3, pm.toString()));

        if(returnPoint != null) { out.print("</body>"); }

    }
%>

<%@include file="template/pagebottom.jsp" %>