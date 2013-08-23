<%@include file="../globalvariables.jsp" %>
<%
    String currentResource=(String)session.getAttribute("currentResource");

    visit.setId(request.getParameter("visitId"));
    visit.undoVisit(Integer.parseInt(request.getParameter("visitId")));
    visit.duplicateLastVisit(Integer.parseInt(request.getParameter("visitId")));

    PreparedStatement lPs=io.getConnection().prepareStatement("update charges set resourceid=" + currentResource + " where visitid=" + request.getParameter("visitId"));
    lPs.executeUpdate();

%>
<%@include file="cleanup.jsp" %>

