<%@include file="sessioninfo.jsp" %>
<%
    visit.setId(request.getParameter("visitId"));
    out.print(visit.getSOAPNotes());
%>
<%@include file="cleanup.jsp" %>