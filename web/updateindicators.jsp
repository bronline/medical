<%@include file="globalvariables.jsp" %>

<SCRIPT language=JavaScript>
<!-- 
function win(where){
window.opener.location.href=where;
self.close();
//-->
}
</SCRIPT>

<%
    String colorId          = request.getParameter("colorid");
    String patientId        = request.getParameter("patientid");
    String parentLocation   = (String)session.getAttribute("parentLocation");

    if(colorId !=  null && patientId != null) {
      PatientIndicators indicators = new PatientIndicators(io, patientId);
      indicators.setPatientIndicator(colorId);
    }

    response.sendRedirect(parentLocation);
%>


