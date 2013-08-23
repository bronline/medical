<%-- 
    Document   : getpatientcontactinfo
    Created on : Jul 8, 2013, 9:10:28 AM
    Author     : Randy
--%>

<%@include file="sessioninfo.jsp" %>
<%
    String appointmentId = request.getParameter("appointmentId");

    ResultSet lRs=io.opnRS("select patientId from appointments where id=" + appointmentId);
    RWHtmlTable htmTb = new RWHtmlTable();

    if(lRs.next()) {
        Patient appointmentPatient = new Patient(io, lRs.getString("patientid"));

        out.print(appointmentPatient.getMiniContactInfo(htmTb));
    }

%>
<%@include file="cleanup.jsp" %>
