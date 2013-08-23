<%@include file="sessioninfo.jsp" %>
<%
    String subItemOrder=request.getParameter("itemOrder");
    VisitActivity visitActivity=new VisitActivity(io,visit,patient,Integer.parseInt(request.getParameter("visitId")),"");
    visit.setId(request.getParameter("visitId"));
    visitActivity.setResourceId(Integer.parseInt(request.getParameter("resourceId")));
    visitActivity.insertCharge(request, io, Integer.parseInt(request.getParameter("itemId")), visit, patient, subItemOrder);

    visitActivity = null;
%>
<%@include file="cleanup.jsp" %>