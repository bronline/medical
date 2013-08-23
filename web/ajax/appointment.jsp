<%-- 
    Document   : appointment
    Created on : Aug 10, 2010, 9:06:56 AM
    Author     : rwandell
--%>

<%@page contentType="text/html" pageEncoding="windows-1252"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
<%@include file="sessioninfo.jsp" %>

<script language="javascript" type="text/javascript">
  function submitForm(action) {
    var frmA=document.forms["frmInput"]
    frmA.method="POST"
    frmA.action=action
    frmA.submit()
  }
</script>

<%
// Initialize local variables
    String myQuery          = "select id, resourceid, date, time, type, emailnotification, intervals, missedreason, notes from appointments ";
    String id               = request.getParameter("id");
    String patientId        = request.getParameter("patientid");
    AppointmentPage thisPage = (AppointmentPage)session.getAttribute("appointmentpage");
// If the id in the request is null or an empty string make it 0 to indicate an add
    if(id == null || id.equals("")) {
        id = "0";
    } else {
        myQuery += "where id=" + id;
        if(patientId == null || patientId.equals("0")) {
            ResultSet tempRs=io.opnRS("select patientid from appointments where id=" + id);
            if(tempRs.next()) { patientId=tempRs.getString("patientid"); }
            tempRs.close();
            tempRs=null;

            if (thisPage==null) {
                int morningStart=6;
                int afternoonStart=13;
                int showAfternoonAfter=11;
                int incrementMinutes=15;

                try {
                    ResultSet tmpRs=io.opnRS("select * from calendarsettings");
                    if(tmpRs.next()) {
                        morningStart=tmpRs.getInt("morningstart");
                        afternoonStart=tmpRs.getInt("afternoonstart");
                        showAfternoonAfter=tmpRs.getInt("showafternoon");
                        incrementMinutes=tmpRs.getInt("increment");
                    }
                    tmpRs.close();
                    tmpRs=null;
                } catch (Exception calendarSettingsException) {
                }

                thisPage = new AppointmentPage(io, "apptcalendar.jsp");
                thisPage.setMorningStart(morningStart);
                thisPage.setAfternoonStart(afternoonStart);
                thisPage.setShowAfternoonAfter(showAfternoonAfter);
                thisPage.setIncrementMinutes(incrementMinutes);
                thisPage.setRowsToGenerate(49);
            }
        }
        
        patient.setId(patientId);
        thisPage.setPatient(patient);
        thisPage.setAppointmentId(Integer.parseInt(id));
    }

// Create a result set of the data for the form
    ResultSet lRs = io.opnRS(myQuery);

// Instantiate an RWInputForm 
    RWInputForm frm = new RWInputForm(lRs);
    RWHtmlTable htmTb = new RWHtmlTable("180","0");

    String [] fields = { "fileName", "patientid", "rcd", "delete" };
    String [] values = { "appointments", patientId, id, "" };

// Set display attributes for the input form
    frm.setShowDatePicker(true);
    frm.setTableWidth("300");
    frm.setTableBorder("0");
    frm.setDftTextBoxSize("35");
    frm.setDftTextAreaCols("35");
    frm.setLabelBold(true);
    frm.setDisplayDeleteButton(false);
    frm.setDisplayUpdateButton(false);
    frm.setUpdateButtonText("  save  ");
    frm.setDeleteButtonText("remove");

    frm.setDbName("rwcatalog");
    frm.setDbCatalog("catalog", 0);
    frm.setDbUser("rwtools");
    frm.setDbPass("rwtools");

    frm.setPreLoadFields(fields);
    frm.setPreLoadValues(values);

// Get an input item with the record id to set the rcd and id fields
    out.print("<v:appointmentEdit id=\"appointment\" style=\"width: 180; height: 330; text-valign: middle; text-align: center;\" arcsize=\".05\">");
    out.print("<div align=\"right\"><b style=\"cursor: pointer;\" onClick=\"closeAppointmentEditBubble()\">close</b></div>");
//    out.print(frm.getInputForm());
    out.print(frm.startForm());
    out.print(htmTb.startTable());
    htmTb.setCellVAlign("TOP");
    out.print(htmTb.startRow("height=\"30\""));
    out.print(htmTb.addCell("<b style=\"font-size: 11px; font-weight: bold;\">Appointment For<br>" + patient.getPatientName() + "</b>", htmTb.CENTER, "colspan=2"));
    out.print(htmTb.endRow());
    out.print(frm.getInputItem("resourceId"));
    out.print(frm.getInputItem("date"));
    out.print(frm.getInputItem("time"));
    if(thisPage.thisAppointment.isInstanceEmailNotification()) {
        out.print(frm.getInputItem("emailnotification"));
    }
    out.print(frm.getInputItem("intervals"));
    out.print(frm.getInputItem("type"));

    htmTb.setCellVAlign("BOTTOM");
    out.print(htmTb.startRow("height=\"25\""));
    out.print(htmTb.addCell("<b>Missed Reason</b>", "colspan=2"));
    out.print(htmTb.endRow());
    out.print(htmTb.startRow());
    out.print(htmTb.addCell(frm.getInputItemOnly("missedreason"), "colspan=2"));
    out.print(htmTb.endRow());

    out.print(htmTb.startRow("height=\"25\""));
    out.print(htmTb.addCell("<b>Notes</b>", "colspan=2"));
    out.print(htmTb.endRow());
    out.print(htmTb.startRow());
    out.print(htmTb.addCell(frm.getInputItemOnly("notes"), "colspan=2"));
    out.print(htmTb.endRow());

    out.print(htmTb.endTable());

    out.print(frm.showHiddenFields());
    out.print(frm.endForm());
    
    out.print("<div align=\"center\">");
    out.print(frm.button("  save  ", "onClick=submitForm('updaterecord.jsp') class=\"button\""));
    out.print(frm.button(" remove ", "onClick=deleteAppointment('updaterecord.jsp') class=\"button\""));
    out.print("</div>");
    out.print("</v:appointmentEdit>");

    session.setAttribute("appointmentpage", thisPage);
    session.setAttribute("patient", patient);
%>
