<%-- 
    Document   : setinsuranceactive
    Created on : Sep 2, 2014, 1:19:35 PM
    Author     : Randy
--%>
<%@include file="sessioninfo.jsp" %>
<%
    String id = request.getParameter("id");
    String patientId = request.getParameter("patientId");
    String activeState = request.getParameter("activeState");
    RWHtmlTable htmTb = new RWHtmlTable("800");

    PreparedStatement chgPs = io.getConnection().prepareStatement("update patientinsurance set active=? where id=?");
    if(activeState.equals("true")) { chgPs.setBoolean(1, true); } else { chgPs.setBoolean(1, false); }
    chgPs.setString(2,id);
    chgPs.execute();
    
    int patientIdInt = Integer.parseInt(patientId);
    out.print(patient.getMiniContactInfo(htmTb));
%>
<%@include file="cleanup.jsp" %>
