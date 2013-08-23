<%@include file="sessioninfo.jsp" %>
<%
    visit.setId(request.getParameter("visitId"));
    visit.undoVisit(Integer.parseInt(request.getParameter("visitId")));

%>
<%@include file="cleanup.jsp" %>