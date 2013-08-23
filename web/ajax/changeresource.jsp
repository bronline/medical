<%-- 
    Document   : changeresource
    Created on : Dec 23, 2009, 9:17:42 AM
    Author     : Randy
--%>
<%@include file="sessioninfo.jsp" %>
<%
    String resourceId = request.getParameter("resourceId");
    String visitId = request.getParameter("visitId");

    PreparedStatement lPs=io.getConnection().prepareStatement("update charges set resourceId=? where visitid=?");
    lPs.setString(1, resourceId);
    lPs.setString(2, visitId);
    lPs.execute();

%>
<%@include file="cleanup.jsp" %>