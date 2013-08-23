<%-- 
    Document   : updatepatientvitals
    Created on : Dec 7, 2011, 2:37:08 PM
    Author     : rwandell
--%>
<%@include file="sessioninfo.jsp" %>

<%
    if(request.getParameter("update") == null && request.getParameter("delete") == null) {
        String id = request.getParameter("id");
        if(id == null || id.trim().equals("")) { id="0"; }

        PatientVitals pv = new PatientVitals(io,0);

        pv.setId(id);
        pv.refresh();
        pv.setPatientId(patient.getId());

        pv.getVitalsForm(out);
    } else {
        PatientVitals pv = new PatientVitals(io, 0);

        out.print(pv.processInputForm(request));
    }
%>