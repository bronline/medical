<%-- 
    Document   : closechargesinbatch.jsp
    Created on : Aug 6, 2012, 10:35:26 AM
    Author     : rwandell
--%>
<%@include file="sessioninfo.jsp" %>
<%
    String batchId = request.getParameter("batchId");
    String patientId = request.getParameter("patientId");
    String status="nothing";

    if(batchId != null && patientId != null) {
        String bcList="";
        String myQuery = "select bc.* from batches b " +
                         "left join batchcharges bc on bc.batchid=b.id " +
                         "left join charges c on bc.chargeid=c.id " +
                         "left join visits v on v.id=c.visitid " +
                         "where b.id=" + batchId + " and v.patientid=" + patientId;

        ResultSet bcRs = io.opnUpdatableRS(myQuery);
        while(bcRs.next()) {
            if(!bcList.equals("")) { bcList += ","; }
            bcList += bcRs.getString("id");
        }
        bcRs.close();
        bcRs = null;
        
        if(!bcList.equals("")) {
            PreparedStatement lPs = io.getConnection().prepareStatement("update batchcharges set complete=1 where id in (" + bcList + ")");
            lPs.execute();

		status = "closed";
        }
    }

    out.println(status);
%>
<%@include file="cleanup.jsp" %>