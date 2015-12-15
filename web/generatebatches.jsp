<%@include file="globalvariables.jsp" %>
<SCRIPT language=JavaScript>
<!--
function win(where){
window.opener.location.href=where;
self.close();
//-->
}
</SCRIPT>
<%
// Set up work variables to process the request parameters
    String myQuery="";

    String startDate = "";
    String endDate = "";

    String parentLocation = (String)session.getAttribute("parentLocation");
    String returnUrl = (String)session.getAttribute("returnUrl");
    Enumeration parms = request.getParameterNames();
    String name;

    if (request.getParameter("startDate")!=null) {
        startDate=Format.formatDate(request.getParameter("startDate"), "yyyy-MM-dd");
    }
    if (request.getParameter("endDate")!=null) {
        endDate=Format.formatDate(request.getParameter("endDate"), "yyyy-MM-dd");
    }

// Set up work variables that will be used to populate each of the payments
    int provider;
    int checkNumber;
    BigDecimal amount;
    int chargeId;
    int patientId;
    boolean wroteCharges = false;
    String amountString;
    java.util.Date date;

    ArrayList batchIds = new ArrayList();

// Instantiate some objects to represent the database relationships
    Batch thisBatch = new Batch(io, 0);
    BatchCharge thisBatchCharge = new BatchCharge(io, 0);

// Roll through all of the parameters. Whenever we find a checkAmount, then there's work to be done.
    while (parms.hasMoreElements()) {
        name=(String)parms.nextElement();

// If this is a chargeId, get the suffix because that represents the charge ID
        if (name.length()>3 && name.substring(0,3).equals("chk")) {

            provider = Integer.parseInt(name.substring(3));

        // Write out a new Batch.
            thisBatch.setId(0);
            thisBatch.setProvider(provider);
            thisBatch.setDescription("");
            thisBatch.update();
/*
            myQuery = "select * from (" +
                          "select " +
                          "a.itemid, " +
                          "a.id, " +
                          "b.date, " +
                          "d.description, " +
                          "a.chargeamount, " +
                          "concat(lastname,', ',firstname) patient, ifnull(sum(p.amount),0) paidamount, " +
                          "cast(a.chargeamount-ifnull(sum(p.amount),0) as decimal(6, 2)) balance " +
                          "from charges a " +
                          "left join items d on a.itemid=d.id " +
                          "left join visits b on a.visitid=b.id " +
                          "left join patientconditions pc on pc.id=b.conditionid " +
                          "join patients c on b.patientid=c.id " +
                          "left outer join payments p on a.id=p.chargeid " +
                          "left join patientinsurance pi on pi.patientid=b.patientid and pi.providerid=" + provider + " " +
                          "where " +
                          "not exists (select id from batchcharges where chargeid=a.id) and " +
                          "c.insuranceactive and " +
                          "pi.active and " +
                          "d.billinsurance and " +
                          "b.patientId in (" +
                          " select " +
                          "   patientid " +
                          " from patientinsurance " +
                          " where " +
                          "   primaryprovider=CASE WHEN pc.providerid=0 THEN 1 ELSE primaryprovider END and " +
                          "   active=1 and " +
                          "   providerid=" + provider + " " +
                          " ) and " +
                          "b.date >=(CASE WHEN pi.insuranceeffective='0001-01-01' THEN '" + startDate + "' ELSE pi.insuranceeffective END) and " +
                          "b.date <= '" + endDate + "' " +
                          "group by " +
                          "a.itemid, " +
                          "a.id, " +
                          "b.date, " +
                          "d.description, " +
                          "a.chargeamount, " +
                          "concat(lastname,', ',firstname) " +
                          ") e " +
                          "where balance <> 0 " +
                          "order by date, description";
*/
            myQuery = "CALL rwcatalog.prGetChargesForBillingBatch('" + databaseName + "', 0, " + provider + ", '" + startDate + "','" + endDate + "')";
    // For each charge that qualifies, write it to the batch
            ResultSet pRs = io.opnRS(myQuery);
            while (pRs.next()) {
                thisBatchCharge.setId(0);
                thisBatchCharge.setBatchId(thisBatch.getId());
                thisBatchCharge.setChargeId(pRs.getInt("chargeid"));
                thisBatchCharge.update();
                wroteCharges = true;
            }
        }
    // If there were no charges, then delete the batch
        if(wroteCharges) {
            if(!batchIds.contains("" + thisBatch.getId()) ) { batchIds.add("" + thisBatch.getId()); }
        }  else {
            thisBatch.delete();
        }
    }

    if(batchIds.size()>0 && env.getBoolean("autobillsupplemental")) {
        String supplementalQuery = "select " +
                "pi.providerid, " +
                "c.id, " +
                "max(0) as complete " +
                "from batches b " +
                "left join batchcharges bc on bc.batchid=b.id " +
                "left join charges c on bc.chargeid=c.id " +
                "left join visits v on c.visitid=v.id " +
                "left join patientinsurance pi on pi.patientid=v.patientid " +
                "where " +
                "  b.id=?" +
                "  and pi.active" +
                "  and not pi.ispip" +
                "  and not pi.primaryprovider " +
                "group by pi.providerid, c.id " +
                "order by pi.providerid, c.id";

        PreparedStatement supplementalPs = io.getConnection().prepareStatement(supplementalQuery);
        for(int x=0;x<batchIds.size();x++) {
            boolean batchCreated = false;
            int currentProviderId = 0;
            supplementalPs.setString(1, (String)batchIds.get(x));
            ResultSet supplementalRs = supplementalPs.executeQuery();
            while(supplementalRs.next()) {
                provider = supplementalRs.getInt("providerid");
                if(currentProviderId != provider) {
                    thisBatch.setId(0);
                    thisBatch.setProvider(provider);
                    thisBatch.setDescription("Auto-generated supplemental batch for charges in batch " + (String)batchIds.get(x));
                    thisBatch.update();
                    currentProviderId = provider;
                }
                thisBatchCharge.setId(0);
                thisBatchCharge.setBatchId(thisBatch.getId());
                thisBatchCharge.setChargeId(supplementalRs.getInt("id"));
                thisBatchCharge.update();
           }
        }
    }
%>
<%
    if(returnUrl.equals("")) { %>
        <body onLoad="win('<%= parentLocation %>')">
        <body>
<%    }
%>
