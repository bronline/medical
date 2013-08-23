<%-- 
    Document   : releaseappointment
    Created on : Nov 29, 2010, 10:24:07 AM
    Author     : rwandell
--%>
<%@include file="sessioninfo.jsp" %>
<%
    AppointmentPage thisPage=(AppointmentPage)session.getAttribute("appointmentpage");
    if(thisPage != null && thisPage.thisAppointment != null) {
            thisPage.thisAppointment.setId(0);
            thisPage.setAppointmentId(0);
    }
%>
<%@include file="cleanup.jsp" %>