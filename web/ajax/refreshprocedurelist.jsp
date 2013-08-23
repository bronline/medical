<%@include file="sessioninfo.jsp" %>
<%
    visit.setId(request.getParameter("visitId"));
    out.print(visit.getProcedures());
%>
<%@include file="cleanup.jsp" %>