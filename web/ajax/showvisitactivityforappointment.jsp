<%-- 
    Document   : showvisitactivityforappointment
    Created on : Mar 21, 2016, 10:48:52 AM
    Author     : Randy
--%>

<%@include file="sessioninfo.jsp" %>
<%
    String appointmentId = request.getParameter("id");
    ResultSet lRs = io.opnRS("select patientid from appointments where id=" + appointmentId);
    if(lRs.next()) {
        
    } else {
        
    }
%>
