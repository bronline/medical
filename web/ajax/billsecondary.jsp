<%-- 
    Document   : billsecondary
    Created on : Aug 30, 2011, 9:09:59 AM
    Author     : Randy Wandell
--%>

<%@include file="sessioninfo.jsp" %>
<script type="text/javascript">
function billSupplemental(batchId,providerId,patientId) {
//  window.open('billing.jsp?secondary=Y&batchId='+batchId+'&patientId='+patientId,'CreateBatch','width=800,height=550,scrollbars=no,left=100,top=100,');
    var url="ajax/billsecondary.jsp?batchId="+batchId+"&providerId="+providerId+"&patientId="+patientId;

    var chkBoxField='#chk'+providerId;
    var chkBox = $(chkBoxField).is(':checked');
    if(chkBox == true) { url += "&allDates=Y"; }

    $.ajax({
        type: "POST",
        url: url,
        success: function(data) {
            $('#secondaryInsuranceBubble').html(data);
        },
        complete: function(data) {
            $('#secondaryInsuranceBubble').css('visibility', 'visible');
            $('#secondaryInsuranceBubble').css('display','');
        }

    });
}
</script>
<%
    String batchId = request.getParameter("batchId");
    String providerId = request.getParameter("providerId");
    String patientId = request.getParameter("patientId");
    boolean billAllDates = false;

    if(request.getParameter("allDates") != null) { billAllDates = true; }

    if(batchId != null && providerId != null) {
        out.print("<div style=\"float: right; font-weight: bold; cursor: pointer;\" onClick=\"closeSupplementalInsuranceBubble()\">close</div>");
        out.print("Batch number " + billInsurance(io, batchId, providerId, patientId, billAllDates) + " has been created");
    } else {
        ResultSet batchRs = io.opnRS("SELECT * FROM batches WHERE id=" + batchId);
        if(batchRs.next()) {
            out.print(getSupplementalInsurance(io, patientId, batchRs.getInt("provider"), batchRs.getInt("id")));
        }
        batchRs.close();
    }

%>
<%!
    public int billInsurance(RWConnMgr io, String batchId, String providerId, String patientId, boolean billAllDates)  {
        int newBatchId = 0;
        try {
            String selectedCharges = "insert into batchcharges select null, ?, chargeid, 0 from batchcharges bc left join charges c on c.id=bc.chargeid left join visits v on v.id=c.visitid where batchid=" + batchId + " and patientid=" + patientId;

            if(billAllDates) {
                selectedCharges = "insert into batchcharges " +
                    "select null, ?, c.id, 0 " +
                    "from visits v " +
                    "left join charges c on c.visitid=v.id " +
                    "left join batchcharges bc on bc.chargeid=c.id " +
                    "left join batches b on bc.batchid=b.id " +
                    "where " +
                    "  v.patientid=" + patientId +
                    "  and b.id=" + batchId +
                    "  and c.id not in (select c.id from batches b " +
                                       "left join batchcharges bc on bc.batchid=b.id " +
                                       "left join charges c on c.id=bc.chargeid " +
                                       "left join visits v on v.id=c.visitid " +
                                       "where " +
                                       "  b.provider=" + providerId + " and " +
                                       "  v.patientid=" + patientId +
                    ")";
            }

            PreparedStatement batchPs = io.getConnection().prepareStatement("insert into batches select null, description, current_date, null, ?, null, 1, 0 from batches where id=?");
            PreparedStatement chargePs = io.getConnection().prepareStatement(selectedCharges);

            batchPs.setString(1, providerId);
            batchPs.setString(2, batchId);
            batchPs.execute();

            io.setMySqlLastInsertId();
            newBatchId = io.getLastInsertedRecord();

            chargePs.setInt(1, newBatchId);
//            chargePs.setString(2, batchId);
//            chargePs.setString(3, patientId);
            chargePs.execute();
        } catch (Exception e) {
            e.printStackTrace();
        }

        return newBatchId;
    }

    public String getSupplementalInsurance(RWConnMgr io, String patientId, int providerId, int thisBatchId) throws Exception {
        StringBuffer s = new StringBuffer();
 
        ResultSet lRs=io.opnRS("SELECT * FROM patientinsurance pi LEFT JOIN providers p ON p.id=pi.providerid WHERE active and patientid=" + patientId + " and providerid<>" + providerId);
        PreparedStatement lPs=io.getConnection().prepareStatement("select * from batches a left join batchcharges b on b.batchid=a.id where b.chargeid in (select chargeid from batchcharges where batchid=?) and a.provider=?");
        lPs.setInt(1, thisBatchId);
        if(lRs.next()) {
            lRs.beforeFirst();
            s.append("<div style=\"float: right; font-weight: bold; cursor: pointer;\" onClick=\"closeSupplementalInsuranceBubble()\">close</div>");
            s.append("<table width=\"100%\" colspacing=\"0\" cellpadding=\"0\">");
            while(lRs.next()) {
                s.append("<tr>");
                s.append("<td width=\"50%\"><b>" + lRs.getString("name") + "</b></td>");
                lPs.setInt(2, lRs.getInt("providerid"));
                ResultSet pRs=lPs.executeQuery();
                if(!pRs.next()) {
                    s.append("<td width=\"20%\">Bill all dates&nbsp;&nbsp;<input type=\"checkbox\" id=\"chk" + lRs.getString("providerid") + "\" name=\"chk" + lRs.getString("providerid") + "\" checked></td>");
                    s.append("<td id=\"secondary" + lRs.getString("providerid") + "\" width=\"30%\"><a href=\"javascript:billSupplemental(" + thisBatchId + "," + lRs.getString("providerid") + "," + patientId + ");\" style=\"font-weight: bold;\">bill insurance</a></td>");
                } else {
                    s.append("<td width=\"20%\">&nbsp;&nbsp;</td>");
                    s.append("<td id=\"secondary" + lRs.getString("providerid") + "\" width=\"30%\">billed in batch " + pRs.getString("batchid") + "</td>");
                }
                s.append("</tr>");
            }
            s.append("</table>");
            lRs.close();
            lRs = null;
        }

        return s.toString();
    }
%>


