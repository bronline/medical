<%-- 
    Document   : saveinsuranceinformation
    Created on : Sep 9, 2013, 10:51:54 AM
    Author     : Randy
--%>

<%@include file="sessioninfo.jsp" %>
<%
    int rcd = Integer.parseInt(request.getParameter("rcd"));
    if(io.updateRecord(request, "patientinsurance", rcd, "ID=" + rcd)) {
        out.print("Information saved successfully");
    } else {
        out.print("Error updating record");
//                lCn.close();
    }
%>
<%@include file="cleanup.jsp" %>