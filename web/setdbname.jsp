<%@ include file="globalvariables.jsp" %>
<%
    int launchMonitor=0;
    int launchTaskList=0;
    try {
        launchMonitor=env.getInt("launchmonitor");
        launchTaskList=env.getInt("launchtasklist");
    } catch (Exception e) {
    }
//    response.sendRedirect("patientmaint.jsp");

//  Check for insurance re-newing
/*
    String patInsSQL="UPDATE patientinsurance " +
            "LEFT JOIN providers ON patientinsurance.providerid=providers.id " +
            "SET insuranceeffective=DATE_ADD(providers.effectivedate, INTERVAL 1 YEAR), active=1 " +
            "WHERE (providers.effectivedate<CURRENT_DATE AND " +
            "providers.effectivedate<>'0001-01-01') OR " +
            "(providers.effectivedate<>'0001-01-01' AND patientinsurance.insuranceeffective='0001-01-01')";
    String providerPs="UPDATE providers SET effectivedate=DATE_ADD(effectivedate, INTERVAL 1 YEAR) " +
            "WHERE effectivedate<>'0001-01-01' AND effectivedate<CURRENT_DATE";

    PreparedStatement piPs=io.getConnection().prepareStatement(patInsSQL);
    PreparedStatement pPs=io.getConnection().prepareStatement(providerPs);

    piPs.execute();
    pPs.execute();
*/
%>
<script type="text/javascript">
    function launchApplication(launchMonitor,launchTaskList) {
        if(launchMonitor==1) {  window.open('instantmessages_monitor.jsp','MessageMonitor','width=820,height=100'); }
        if(launchTaskList==1) {  window.open('tasklist.jsp','TaskMonitor','width=320,height=500'); }

        location.href="patientmaint.jsp";
    }
</script>
<body onLoad="launchApplication(<%=launchMonitor%>,<%=launchTaskList%>)">

</body>