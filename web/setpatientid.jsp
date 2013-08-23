<%-- 
    Document   : setpatientid
    Created on : Mar 16, 2009, 7:32:30 PM
    Author     : Randy
--%>
<%@include file="ajax/sessioninfo.jsp" %>
<%
    String patientId=request.getParameter("id");

    if(patientId != null) {
        patient.setId(patientId);
        AppointmentPage thisPage = (AppointmentPage)session.getAttribute("appointmentpage");
        if(thisPage != null) {
            try {
                thisPage.setPatient(patient);
                thisPage.setAppointmentId(0);
                session.setAttribute("appointmentpage", thisPage);
            } catch (Exception bbbbb) {
                System.out.println(databaseName + blanks.substring(databaseName.length()) + " : " + new java.util.Date() + " - " + request.getRemoteAddr() + " - Problem setting appointment page class (patientId: " + patientId + ")");

            }
        }
    }
%>
