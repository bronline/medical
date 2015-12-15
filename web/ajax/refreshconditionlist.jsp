<%@include file="sessioninfo.jsp" %>
<%
    String visitId = request.getParameter("visitId");
    String conditionId = request.getParameter("conditionId");
    
    if(visitId != null) {
    visit.setId(request.getParameter("visitId"));
        out.print(visit.getConditions());
    } else {
        out.print(patient.getConditions());
    }
    
%>
<%@include file="cleanup.jsp" %>
