<%@include file="sessioninfo.jsp" %>
<%
    String conditionId = request.getParameter("conditionId");
    String visitId = request.getParameter("visitId");
    
    if(conditionId.equals("undefined") && visitId != null) {
        Visit v = new Visit(io,visitId);
        conditionId = ""+v.getCurrentCondition();
    }
    
    Symptoms symptoms=new Symptoms(io);
    out.print(symptoms.getConditionSymptoms(conditionId));
%>
<%@include file="cleanup.jsp" %>