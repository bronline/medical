<%-- 
    Document   : setinsuranceverified
    Created on : Sep 2, 2014, 2:16:14 PM
    Author     : Randy
--%>
<%@include file="sessioninfo.jsp" %>
<%
    String id = request.getParameter("id");
    String patientId = request.getParameter("patientId");

    PreparedStatement chgPs = io.getConnection().prepareStatement("update patientinsurance set verified=? where id=?");
    chgPs.setBoolean(1, true);
    chgPs.setString(2,id);
    chgPs.execute();
%>
<%@include file="cleanup.jsp" %>
