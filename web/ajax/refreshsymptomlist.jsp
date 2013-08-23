<%@include file="sessioninfo.jsp" %>
<%
    Symptoms symptoms=new Symptoms(io);
    out.print(symptoms.getConditionSymptoms(request.getParameter("conditionId")));
%>
<%@include file="cleanup.jsp" %>