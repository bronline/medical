<%-- 
    Document   : report_statements
    Created on : Aug 17, 2011, 9:42:29 AM
    Author     : Randy Wandell
--%>

<%@ include file="globalvariables.jsp" %>
<style>
    .headingLabel { font-size: 14px; background-color: white; color: black;}
    .headingItem { font-size: 14px; font-weight: bold; }
    .openItem { font-size: 12px; }
    .inquiryAddress { font-weight: bold; }
</style>
<%
    String print = request.getParameter("print");
    String minDays = request.getParameter("minDays");
    String maxDays = request.getParameter("maxDays");
    String complete = request.getParameter("complete");
    String patientType = request.getParameter("patientType");
    String completedTransactions = "";
    String patientTransactions = "bc.id IS NOT NULL AND ";

    if(complete != null && complete.equals("C")) { completedTransactions = "bc.complete and "; }
    
    if(patientType != null && patientType.equals("C")) {
        completedTransactions = "";
        patientTransactions = "pi.patientid is null and ";
    }

    if(patientType != null && complete != null && complete.equals("C") && patientType.equals("A")) {
        completedTransactions = "1=case when pi.patientid IS NULL THEN 1 else case when bc.id is not null and bc.complete then 1 else 0 end end and ";
        patientTransactions = "";
    }

    if(patientType != null && complete != null && complete.equals("A") && patientType.equals("A")) {
        completedTransactions = "";
        patientTransactions = "";
    }

    RWHtmlTable htmTb=new RWHtmlTable("700", "0");

    BillingStatement billingStm = new BillingStatement();
    billingStm.linesPerPage=70;

    Patient statementPatient = new Patient(io, 0);
    String statementQuery = "select p.id, p.lastname, p.firstname, sum(c.chargeamount*c.quantity) charges, sum(ifnull((select sum(amount) from payments where chargeid=c.id),0.00)) payments " +
            "from charges c " +
            "left join items i on i.id=c.itemid " +
            "left join batchcharges bc on bc.chargeid=c.id " +
            "left join visits v on c.visitid=v.id " +
            "left join patients p on p.id=v.patientid " +
            "left join (SELECT patientid, COUNT(*) AS insCount from patientinsurance group by patientid) pi on p.id=pi.patientid " +
            "WHERE (not i.billinsurance and v.`date` between DATE_SUB(CURRENT_DATE, INTERVAL " + maxDays + " DAY) and DATE_SUB(CURRENT_DATE, INTERVAL " + minDays + " DAY)) or (" +
            patientTransactions +
            completedTransactions +
            "v.`date` between DATE_SUB(CURRENT_DATE, INTERVAL " + maxDays + " DAY) and DATE_SUB(CURRENT_DATE, INTERVAL " + minDays + " DAY)) " +
            "group by p.id " +
            "order by p.lastname, p.firstname";
    
    statementQuery = "call rwcatalog.prGetPatientStatementBalance('" + io.getLibraryName() + "','" + patientType + "','" + complete + "'," + maxDays + "," + minDays + ")";

    String chargeQuery = "SELECT DISTINCT vs.id, bc.chargeid " +
            "FROM visits vs " +
            "LEFT JOIN charges vc ON vc.visitid=vs.id " +
            "LEFT JOIN items i ON i.id=vc.itemid " +
            "LEFT JOIN batchcharges bc ON bc.chargeid=vc.id " +
            "left join (SELECT patientid, COUNT(*) AS insCount from patientinsurance group by patientid) pi on vs.patientid=pi.patientid " +
            "WHERE (not i.billinsurance and v.`date` between DATE_SUB(CURRENT_DATE, INTERVAL " + maxDays + " DAY) and DATE_SUB(CURRENT_DATE, INTERVAL " + minDays + " DAY)) OR (" +
            patientTransactions +
            completedTransactions +
            "vs.patientid=? AND vs.`date` between DATE_SUB(CURRENT_DATE, INTERVAL ? DAY) and DATE_SUB(CURRENT_DATE, INTERVAL ? DAY))";

    PreparedStatement chargePs = io.getConnection().prepareStatement(chargeQuery);
    chargePs.setString(2, maxDays);
    chargePs.setString(3, minDays);

    ResultSet lRs = io.opnRS(statementQuery);
    while(lRs.next()) {
        if(request.getParameter("pat" + lRs.getString("id")) != null) {
            chargePs.setInt(1,lRs.getInt("id"));

            statementPatient.setId(lRs.getInt("id"));
            RWConnMgr stmIo = new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);
            htmTb.setBorder("0");
            billingStm.currPage=1;
            billingStm.currentLine=1;
            billingStm.patientType=patientType;
            billingStm.complete=complete;
            billingStm.getHtml(stmIo, htmTb, request, response, statementPatient);
            stmIo.getConnection().close();
            stmIo = null;
        }
        out.flush();
        response.flushBuffer();

        System.gc();
    }
    lRs.close();

%>