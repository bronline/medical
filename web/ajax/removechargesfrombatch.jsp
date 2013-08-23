<%-- 
    Document   : removechargesfrombatch
    Created on : Oct 27, 2011, 12:28:26 PM
    Author     : rwandell
--%>
<%@include file="sessioninfo.jsp" %>
<%
    String batchId = request.getParameter("batchId");
    String patientId = request.getParameter("patientId");
    String status="nothing";

    if(batchId != null && patientId != null) {
        String bcList="";
        String myQuery = "SELECT bc.id FROM batchcharges bc LEFT JOIN charges c ON c.id=bc.chargeid LEFT JOIN visits v ON v.id=c.visitid " +
                "LEFT JOIN (SELECT chargeid, SUM(amount) AS paidamount FROM payments py LEFT JOIN providers p ON p.id=py.provider WHERE NOT p.reserved GROUP BY chargeid) p ON p.chargeid=bc.chargeid " +
                "WHERE NOT bc.complete AND paidamount IS NULL AND bc.batchid=" + batchId + " AND v.patientid=" + patientId + " GROUP BY id";

        ResultSet bcRs = io.opnUpdatableRS(myQuery);
        while(bcRs.next()) {
            if(!bcList.equals("")) { bcList += ","; }
            bcList += bcRs.getString("id");
        }
        bcRs.close();
        bcRs = null;

        System.out.println(bcList);
        
        if(!bcList.equals("")) {
            PreparedStatement lPs = io.getConnection().prepareStatement("delete from batchcharges where id in (" + bcList + ")");
            lPs.execute();

            ResultSet lRs = io.opnRS("SELECT COUNT(*) AS reccount FROM batchcharges where batchid=" + batchId);
            if(lRs.next()) {
                if(lRs.getInt("reccount") == 0) {
                    PreparedStatement bPs = io.getConnection().prepareStatement("delete from batches where id=?");
                    bPs.setString(1, batchId);
                    bPs.execute();
                }
            }
            lRs.close();
            lRs = null;

            status="removed";
        }
    }

    out.println(status);
%>
<%@include file="cleanup.jsp" %>