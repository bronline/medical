<%@include file="sessioninfo.jsp" %>
<%
    visit.setId(request.getParameter("visitId"));
    out.print(visit.getConditions());
%>
<%@include file="cleanup.jsp" %>
