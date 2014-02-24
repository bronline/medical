<%-- 
    Document   : saveaccountinformation
    Created on : Sep 9, 2013, 9:42:28 AM
    Author     : Randy
--%>
<%@include file="sessioninfo.jsp" %>
<%
    int rcd = Integer.parseInt(request.getParameter("recordId"));
    if(io.updateRecord(request, "patients", rcd, "ID=" + rcd)) {
        out.print("Information saved successfully");
    } else {
        out.print("Error updating record");
//                lCn.close();
    }
%>
<%@include file="cleanup.jsp" %>