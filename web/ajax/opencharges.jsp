<%-- 
    Document   : opencharges
    Created on : Aug 30, 2011, 2:19:38 PM
    Author     : rwandell
--%>

<%@include file="sessioninfo.jsp" %>

<%
    String visitId = request.getParameter("visitId");

    if(visitId != null) {
        PreparedStatement chgPs = io.getConnection().prepareStatement("update batchcharges set complete=0 where chargeid in (select id from charges where visitid=?)");
        chgPs.setString(1, visitId);

        chgPs.execute();
        
    }
%>
