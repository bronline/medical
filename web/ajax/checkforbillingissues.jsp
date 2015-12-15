<%-- 
    Document   : checkforbillingissues
    Created on : Sep 18, 2014, 3:32:30 PM
    Author     : Randy
--%>
<%@include file="sessioninfo.jsp" %>
<%
    String myQuery = "CALL rwcatalog.prGetUnverifiedInsuranceList('" + databaseName + "')";
    PreparedStatement lPs = io.getConnection().prepareStatement("update patientinsurance set verified=? where id=?" );
    ResultSet lRs = io.opnRS(myQuery);
    while(lRs.next()) {
        lPs.setBoolean(1, false);
        lPs.setString(2, lRs.getString("ptinsuranceid"));
        
        lPs.execute();
    }
%>
<%@include file="cleanup.jsp" %>
