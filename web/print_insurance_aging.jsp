<%-- 
    Document   : print_insurance_aging
    Created on : Jul 16, 2012, 12:15:52 PM
    Author     : Randy
--%>
<%@include file="globalvariables.jsp" %>
<style type="text/css">
    .providerTotals { font-size: 11px; }
    .grandTotals { font-size: 11px; }
</style>
<style media="print" rel="stylesheet" type="text/css">
    .navStuff { DISPLAY: none }
    a:after { content:' [' attr(href) '] ' }
</style>
<%
String providerId = request.getParameter("providerId");
String showZeroBalances = request.getParameter("showZeroBalances");
String patientKey = "";
String providerKey = "";
String providerName = "";
String patientName = "";
String patientId = "";
String rowColor="#e0e0e0";
String delinquentDays = request.getParameter("delinquentDays");
String patientTypeSelection = "";
String pType = request.getParameter("patientType");

if (showZeroBalances==null) showZeroBalances="false";
if (providerId==null) providerId="0";
if (delinquentDays==null) delinquentDays="0";
boolean zeroBalances = (showZeroBalances.equals("false")) ? false:true;
boolean pipOnly = false;
boolean insuranceOnly = false;


if(request.getParameter("patientType") != null) { 
    if(request.getParameter("patientType").equals("P")) { patientTypeSelection = " and patientinsurance.ispip "; }
    if(request.getParameter("patientType").equals("I")) { patientTypeSelection = " and not patientinsurance.ispip "; }
}

String myQuery="select providers.id as providerid, patients.id as patientid, batches.id as batchid, patients.accountnumber, providers.name, concat(patients.firstname, ' ', patients.lastname) as patientname, DATEDIFF(current_date,billed) as daysold, " +
        "  substr(concat(providers.name,' - ',REPLACE(substr(providers.address,1,locate(_latin1'\r',providers.address)-1),'\r\n',''),' - ', " +
        "   case when substr(providers.address,length(providers.address)-4,1)='-' then " +
        "     replace(substr(providers.address,(locate(_latin1'\r',providers.address) + 2),length(providers.address)-10-(locate(_latin1'\r',providers.address) + 2)),'\r\n',' ') " +
        "   else " +
        "     replace(substr(providers.address,(locate(_latin1'\r',providers.address) + 2),length(providers.address)-5-(locate(_latin1'\r',providers.address) + 2)),'\r\n',' ') " +
        "   end),1,55) as headingname, providers.address, " +
        "patientinsurance.providernumber, patientinsurance.providergroup, batches.billed, batches.lastbilldate, visits.`date` as dateofservice, items.code, case when patients.ssn=0 then '' else patients.ssn end as ssn, patients.dob, providers.phonenumber, providers.extension, " +
        "(charges.chargeamount*charges.quantity)-ifnull((select sum(amount) from payments where chargeid=charges.id),0) AS delinquent " +
        "from batches " +
        "left join batchcharges on batches.id=batchcharges.batchid " +
        "left join charges on charges.id=batchcharges.chargeid " +
        "left join visits on visits.id=charges.visitid " +
        "left join items on items.id=charges.itemid " +
        "left join providers on providers.id=batches.provider " +
        "left join patients on patients.id=visits.patientid " +
        "left join patientinsurance on patientinsurance.patientid=patients.id and patientinsurance.providerid=batches.provider " +
        "where (charges.chargeamount*charges.quantity)-ifnull((select sum(amount) from payments where chargeid=charges.id),0)>0 " +
//        "and ifnull((select sum(amount) from payments where chargeid=charges.id),0)=0 " +
        "and not complete " +
        patientTypeSelection +
        "and DATEDIFF(current_date,billed)>=" + delinquentDays;

    RWConnMgr localIo = new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);

    RWHtmlTable htmTb=new RWHtmlTable("800","0");
    htmTb.replaceNewLineChar(false);

    ArrayList ageItemHeading=new ArrayList();
    ArrayList ageItemMaxDays=new ArrayList();
    ArrayList ageItemMinDays=new ArrayList();
    String providerSQL;
    if (!providerId.equals("0")) {
        myQuery += " and batches.provider = " + providerId;
    }
    myQuery += " order by providers.name, providers.address, CONCAT(patients.lastname, patients.firstname)";
    ResultSet insuranceRs=io.opnRS(myQuery);

    ResultSet agingItemRs=io.opnRS("select * from agingitems order by seq");
    while(agingItemRs.next()) {
        ageItemHeading.add(agingItemRs.getString("description"));
        ageItemMaxDays.add(agingItemRs.getString("maxdays"));
        ageItemMinDays.add(agingItemRs.getString("mindays"));
    }
    ageItemHeading.add("Total");

    double [] patientTotals = new double[ageItemHeading.size()];
    double [] payerTotals = new double[ageItemHeading.size()];
    double [] grandTotals = new double[ageItemHeading.size()];

    Hashtable providers=new Hashtable();

    out.print("<input type=\"button\" name=\"print_btn\" value=\"print\" onclick=\"window.print();\" class=\"btn navStuff\" >");
%>
<%@include file="insurance_aging_body.jsp" %>
<%
    agingItemRs.close();
    insuranceRs.close();

    localIo.getConnection().close();
    localIo=null;
    System.gc();
%>
<%! public String getPatientHeading(ResultSet lRs) {
        return "";
    }
%>
