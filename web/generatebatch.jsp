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
    String parentLocation = (String)session.getAttribute("parentLocation");
    String returnUrl = (String)session.getAttribute("returnUrl");
    String providerId = request.getParameter("providerId");
    String startDate = request.getParameter("startDate");
    String endDate = request.getParameter("endDate");
    Enumeration parms = request.getParameterNames();
    String name;

    /*
// Set up work variables that will be used to populate each of the payments
    int provider;
    int checkNumber;
    BigDecimal amount;
    int chargeId;
    int patientId;
    boolean wroteCharges = false;
    String amountString;
    java.util.Date date;

// Instantiate some objects to represent the database relationships
    Charge thisCharge = new Charge(io, "0");
    Visit thisVisit = new Visit(io, "0");
    Patient thisPatient = new Patient(io, "0");
    Batch thisBatch = new Batch(io, 0);
    BatchCharge thisBatchCharge = new BatchCharge(io, 0);

// If the provider came in, use it.  Otherwise, use 0.
    if (request.getParameter("providerId")!=null) {
        provider = Integer.parseInt(request.getParameter("providerId"));
    } else {
        provider = 0;
    }

// Write out a new Batch.
    thisBatch.setId(0);
    thisBatch.setProvider(provider);
    thisBatch.setDescription("");
    thisBatch.update();

    if(request.getParameter("secondary") != null) {
        PreparedStatement sPs=io.getConnection().prepareStatement("update batches set issecondary=1 where id=" + thisBatch.getId());
        sPs.execute();
    }

// Roll through all of the parameters. Whenever we find a checkAmount, then there's work to be done.
    while (parms.hasMoreElements()) {
        name=(String)parms.nextElement();

// If this is a chargeId, get the suffix because that represents the charge ID
        if (name.length()>8 && name.substring(0,8).equals("chargeid")) {

            chargeId = Integer.parseInt(name.substring(8));

// Set up the BatcbCharge Instance and write the record
            thisBatchCharge.setId(0);
            thisBatchCharge.setBatchId(thisBatch.getId());
            thisBatchCharge.setChargeId(chargeId);
            thisBatchCharge.update();
            wroteCharges = true;
        }
    }

// If there were no charges, then delete the batch
    if (!wroteCharges) {
        thisBatch.delete();
    }
*/
    getPatientConditions(io, parms, providerId, startDate, endDate);

    if(returnUrl.equals("")) {
        out.print("<body onLoad=\"win('" + parentLocation + "')\">\n");
        out.print("<body>\n");
    }
%>
<%! public void getPatientConditions(RWConnMgr io, Enumeration params, String providerId, String startDate, String endDate) throws Exception {
        String conditionQuery = "SELECT DISTINCT conditionid, patientid FROM visits where id in (" +
                "SELECT charges.visitid from charges left join batchcharges on batchcharges.chargeid=charges.id where charges.id in (";
        String name="";
        StringBuffer chargeList = new StringBuffer();

        boolean chargesFound=false;

        Batch thisBatch = new Batch(io, 0);
        thisBatch.setId(0);
        thisBatch.setProvider(Integer.parseInt(providerId));
        thisBatch.setDescription("");
        thisBatch.update();

        while (params.hasMoreElements()) {
            name=(String)params.nextElement();
            if (name.length()>8 && name.substring(0,8).equals("chargeid")) {
                if(chargesFound) { chargeList.append(","); }
                chargeList.append(name.substring(8));
                chargesFound = true;
            }
        }

        conditionQuery += chargeList.toString() + ") and batchcharges.id is null)";
        conditionQuery += " and `date` between '" + Format.formatDate(startDate, "yyyy-MM-dd") + "' and '" + Format.formatDate(endDate, "yyyy-MM-dd") + "'";

        if(chargesFound) {
            ResultSet pcRs = io.opnRS(conditionQuery);
            while(pcRs.next()) {
                generateBatchForCondition(io, pcRs, chargeList, thisBatch.getId(), startDate, endDate);
            }
            pcRs.close();
            pcRs = null;
        }

    }

    public void generateBatchForCondition(RWConnMgr io, ResultSet pcRs, StringBuffer shargeList, int batchId, String startDate, String endDate) throws Exception {
        String chargeQuery = "SELECT charges.* from charges " +
                "left join items on items.id=charges.itemid " +
                "left join batchcharges on batchcharges.chargeid=charges.id " +
                "where visitid in (SELECT id FROM visits where conditionid=" + pcRs.getString("conditionid") +
                " and `date` between '" + Format.formatDate(startDate, "yyyy-MM-dd") + "' and '" + Format.formatDate(endDate, "yyyy-MM-dd") + "' " +
                 ") and batchcharges.id is null " +
                "and items.billinsurance";

        String providerQuery = "select " +
                " case when pc.providerid=0 then pi.providerid else pc.providerid end as providerid " +
                "from patientconditions pc " +
                "left join patientinsurance pi on pc.patientid and pi.active and pi.primaryprovider " +
                "where pc.id=" + pcRs.getString("conditionid") + " and pi.patientid=" + pcRs.getString("patientid") +
                " order by pi.id";

        ResultSet conditionRs = io.opnRS(providerQuery);

//        Batch thisBatch = new Batch(io, 0);
        BatchCharge thisBatchCharge = new BatchCharge(io, 0);

        if(conditionRs.next()) {
/*
            thisBatch.setId(0);
            thisBatch.setProvider(conditionRs.getInt("providerid"));
            thisBatch.setDescription("");
            thisBatch.update();
*/
            ResultSet chgRs = io.opnRS(chargeQuery);
            while(chgRs.next()) {
                thisBatchCharge.setId(0);
//                thisBatchCharge.setBatchId(thisBatch.getId());
                thisBatchCharge.setBatchId(batchId);
                thisBatchCharge.setChargeId(chgRs.getInt("id"));
                thisBatchCharge.update();
            }

            chgRs.close();
            chgRs = null;
        }

        conditionRs.close();
        conditionRs = null;
    }
%>

