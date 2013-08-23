<%@ include file="template/pagetop.jsp" %>
<%@ include file="ajax/autocomplete.jsp" %>
<body OnLoad="document.Search.srchString.focus()" >
<style type="text/css">
th	    { font-size: 11px;
              font-family: Arial, Helvetica, sans-serif;
	      background-color: silver;
	      color: black;  }
</style>
<script type="text/javascript" src="js/prtscreen.js"></script>
<script type="text/javascript" src="ajax/apptcalendar.js"></script>
<div id="txtHint" style="text-align: left; background-color: transparent; position: absolute; visibility: hidden; display: none; z-index: 99;"></div>
<v:shadow id="shadow" style='position: absolute; text-align: center; z-index: 98; visibility: hidden; ' arcsize='.05' fillcolor='#666666' >&nbsp;&nbsp;</v:shadow>

<%
    boolean appointmentExistsForToday=false;
    String apptDate="";
    String apptTime="";
    String resourceId="";
    String sched=request.getParameter("sched");
    
    AppointmentPage thisPage = (AppointmentPage)session.getAttribute("appointmentpage");
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

        thisPage = new AppointmentPage(io, self);
        thisPage.setMorningStart(morningStart);
        thisPage.setAfternoonStart(afternoonStart);
        thisPage.setShowAfternoonAfter(showAfternoonAfter);
        thisPage.setIncrementMinutes(incrementMinutes);
        thisPage.setRowsToGenerate(49);
    }
    
    thisPage.setPatient(patient);

    // Schedule an appointment
    if (request.getParameter("apptTime")!=null && (patient.getId()>0 || thisPage.thisPatient.getId()!=0) && sched==null && thisPage.getApptId()==0) {
        apptDate = request.getParameter("apptDate");
        apptTime = request.getParameter("apptTime");
        resourceId = request.getParameter("resourceId");
        appointmentExistsForToday=patientAppointmentExistsForToday(io,resourceId,patient.getId(),apptDate);
    }
    
    if (request.getParameterNames().hasMoreElements()) {
        if(appointmentExistsForToday) {
            out.print("<script type='text/javascript'>confirmAppointment(" + resourceId + ",'" + apptDate + "','" + apptTime + "'," + patient.getId() +")</script>");
        } else {
//            if(patient.getId()>0) {
                thisPage.processRequestParameters(request);
                patient=thisPage.getPatient();
                session.setAttribute("patient", patient);
                response.sendRedirect(self);
//            } else {
//                response.sendRedirect(self);
//            }
        }
    } else {
//        thisPage.setAppointmentId(0); // This is the issue for moving appointments and not being able to de-select appointments
        out.print("<script type='text/javascript'>apptPatient=" + patient.getId() +";apptId=" + thisPage.getApptId() + "</script>");
        out.print(thisPage.getHtml(request));
        thisPage.thisApptCal.scrollToTime=null;
        session.setAttribute("srchString", "*EMPTY");
    }

    session.setAttribute("appointmentpage", thisPage);
    session.setAttribute("parentLocation", "apptcalendar.jsp");
    session.setAttribute("returnUrl", "apptcalendar.jsp");

%>
<%! public boolean patientAppointmentExistsForToday(RWConnMgr io, String resourceId, int patientId, String date) throws Exception {
        boolean appointmentExists=false;
        ResultSet lRs=io.opnRS("select * from appointments where patientId=" + patientId + " and date='" + date + "' and resourceId=" + resourceId);
        appointmentExists=lRs.next();
        lRs.close();
        return appointmentExists;
    }
%>
<iframe width=100% height=75 src='instantmessages.jsp' frameborder=0 />
<%@ include file="template/pagebottom.jsp" %>
