<%@include file="sessioninfo.jsp" %>
<%
    VisitActivity visitActivity=new VisitActivity(io,visit,patient,Integer.parseInt(request.getParameter("visitId")),"");
    visit.setId(request.getParameter("visitId"));
    String itemOrder=request.getParameter("itemOrder");
    visitActivity.insertNote(request, io, Integer.parseInt(request.getParameter("noteId")), visit, patient, itemOrder);

    visitActivity = null;
%>
<%@include file="cleanup.jsp" %>