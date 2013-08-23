<%-- 
    Document   : batchfunctions
    Created on : Aug 15, 2013, 11:00:49 AM
    Author     : Randy
--%>
<%@include file="sessioninfo.jsp" %>
<%
    String chargeId = request.getParameter("chargeId");
    String providerId = request.getParameter("providerId");

    ResultSet bcRs = io.opnRS("select * from batchcharges left join batches on batchcharges.batchid=batches.id where chargeid = " + chargeId + " and batches.provider = " + providerId);
    if(bcRs.next()) {
        ResultSet chargeCountRs = io.opnRS("select count(*) as chargecount from batchcharges where batchid=" + bcRs.getString("batchId"));
        if(chargeCountRs.next()) {
            if(chargeCountRs.getInt("chargecount")<=1) {
                PreparedStatement dbPs = io.getConnection().prepareStatement("delete from batches where id=" + bcRs.getString("batchid"));
                dbPs.execute();
            }
        }
        PreparedStatement bcPs = io.getConnection().prepareStatement("delete from batchcharges where id=" + bcRs.getString("id"));
        bcPs.execute();
        chargeCountRs.close();
        chargeCountRs = null;
    } else {
        int batchId = 0;
        ResultSet bRs = io.opnRS("select * from batches where provider = " + providerId + " and billed is null and DATEDIFF(CURRENT_DATE, created)<30 order by created desc");
        if(!bRs.next()) {
            Batch batch = new Batch(io,0);
            batch.setProvider(Integer.parseInt(providerId));
            batch.setDescription("Batch created from Un-billed charges report on " + Format.formatDate(new java.util.Date(),"MM/dd/yyyy"));
            batch.update();
            batchId=batch.getId();
        } else {
            batchId=bRs.getInt("id");
        }
        PreparedStatement bcPs = io.getConnection().prepareStatement("insert into batchcharges (batchid, chargeid) values(?,?)");
        bcPs.setInt(1, batchId);
        bcPs.setString(2, chargeId);
        bcPs.execute();
    }
%>
<%@include file="cleanup.jsp" %>
