<%@include file="sessioninfo.jsp" %>
<%
    try {
        int apptId=Integer.parseInt(request.getParameter("apptId"));
//        medical.AppointmentPage apptPage=new medical.AppointmentPage(io, "apptcalendar.jsp");
        medical.AppointmentPage apptPage=(medical.AppointmentPage)session.getAttribute("appointmentpage");
        apptPage.setConnMgr(io);
        apptPage.processRequestParameters(request);
        out.print(apptPage.getApptInfo(io, apptId));
    } catch (Exception e) {
        out.print(e.getMessage());
    }
%>
<%@include file="cleanup.jsp" %>