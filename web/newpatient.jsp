<%@include file="globalvariables.jsp" %>
<%
    patient.setId(0);
    patient.refresh();

    AppointmentPage thisPage=(AppointmentPage)session.getAttribute("appointmentpage");
    if(thisPage != null && thisPage.thisAppointment != null) {
            thisPage.thisAppointment.setId(0);
            thisPage.setAppointmentId(0);
    }

    response.sendRedirect("patientmaint.jsp?srchString=*EMPTY");
%>