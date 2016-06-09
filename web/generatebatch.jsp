<%@ include file="globalvariables.jsp"%>
<script type="text/javascript">
    function win(where){
        window.opener.location.href=where;
        self.close();
    }
</script>
<%
// Set up work variables to process the request parameters
    String parentLocation = (String)session.getAttribute("parentLocation");
    String returnUrl = (String)session.getAttribute("returnUrl");
    String providerId = request.getParameter("providerId");
    String startDate = request.getParameter("startDate");
    String endDate = request.getParameter("endDate");
    String patientId = request.getParameter("patientId");
    int pId = 0;
    Enumeration parms = request.getParameterNames();
    String name;

    try {
        pId = Integer.parseInt(patientId);
    } catch (Exception e) {
    }

    getPatientConditions(io, env, parms, pId, providerId, startDate, endDate);

    if(returnUrl.equals("")) { %>
        <body onLoad="win('<%= parentLocation %>')">
        <body>
<%    }
%>
<%! public void getPatientConditions(RWConnMgr io, Environment env, Enumeration params, int patientId, String providerId, String startDate, String endDate) throws Exception {
        String name="";
        boolean chargesFound=false;

        Batch thisBatch = new Batch(io, 0);
        thisBatch.setId(0);
        thisBatch.setProvider(Integer.parseInt(providerId));
        thisBatch.setDescription("");
        thisBatch.update();
        
        java.util.ArrayList chargeIds = new java.util.ArrayList();
        
        while (params.hasMoreElements()) {
            name=(String)params.nextElement();
            if (name.length()>8 && name.substring(0,8).equals("chargeid")) {                
                chargeIds.add(name.substring(8));
            }
        }

        System.out.println("chargeIds.size()----------> " + chargeIds.size());
        System.out.println("patientId-----------------> " + patientId);
        
        if(chargeIds.size()>0 || patientId != 0) {
            generateBatchForCondition(io, env, patientId, thisBatch, startDate, endDate, chargeIds);
        }

    }

    public void generateBatchForCondition(RWConnMgr io, Environment env, int patientId, Batch thisBatch, String startDate, String endDate, java.util.ArrayList chargeIds) throws Exception {
        boolean wroteCharges = false;
        int supplementalProviderId = 0;
        BatchCharge thisBatchCharge = new BatchCharge(io, 0);
        String chargeQuery = "CALL rwcatalog.prGetChargesForBillingBatch('" + io.getLibraryName() + "', " + patientId + ", " + thisBatch.getProvider() + ", '" + Format.formatDate(startDate, "yyyy-MM-dd") + "','" + Format.formatDate(endDate, "yyyy-MM-dd") + "')";

        System.out.println(chargeQuery);

        ResultSet chgRs = io.opnRS(chargeQuery);
        while(chgRs.next()) {
            
            if(chargeIds.contains(chgRs.getString("chargeId"))) {
                thisBatchCharge.setId(0);
                thisBatchCharge.setBatchId(thisBatch.getId());
                thisBatchCharge.setChargeId(chgRs.getInt("chargeid"));
                thisBatchCharge.update();

                if(!wroteCharges) { wroteCharges = true; }
            }
        }

        chgRs.close();
        chgRs = null;

        if(wroteCharges && env.getBoolean("autobillsupplemental")) {
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
            boolean batchCreated = false;
            int currentProviderId = 0;
            supplementalPs.setInt(1, thisBatch.getId());
            ResultSet supplementalRs = supplementalPs.executeQuery();
            while(supplementalRs.next()) {
                supplementalProviderId = supplementalRs.getInt("providerid");
                if(currentProviderId != supplementalProviderId) {
                    thisBatch.setId(0);
                    thisBatch.setProvider(supplementalProviderId);
                    thisBatch.setDescription("Auto-generated supplemental batch for charges in batch " + thisBatch.getId());
                    thisBatch.update();
                    currentProviderId = supplementalProviderId;
                }
                thisBatchCharge.setId(0);
                thisBatchCharge.setBatchId(thisBatch.getId());
                thisBatchCharge.setChargeId(supplementalRs.getInt("id"));
                thisBatchCharge.update();
           }
        } else if(!wroteCharges) {
            PreparedStatement deleteBatchPs = io.getConnection().prepareStatement("delete from batches where id = " + thisBatch.getId());
            deleteBatchPs.execute();
        }            
    }
%>

