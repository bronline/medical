<%--
    Document   : report_insurance_delinquency
    Created on : Jul 7, 2010, 9:40:53 AM
    Author     : rwandell
--%>
<%@include file="template/pagetop.jsp" %>
<script type="text/javascript">
    function printReport(providerId,delinquentDays) {
        window.open("insurance_delinquency_print.jsp?providerId="+providerId+"&delinquentDays="+delinquentDays,"Insurance_Delinquency");
    }
</script>
<style type="text/css">
    .patientHeading { font-size: 11px; font-weight: bold; }
</style>
<%
/*
String providerId = request.getParameter("providerId");
String showZeroBalances = request.getParameter("showZeroBalances");
String patientKey = "";
String providerKey = "";
String providerName = "";
String delinquentDays = request.getParameter("delinquentDays");

if (showZeroBalances==null) showZeroBalances="false";
if (providerId==null) providerId="0";
if (delinquentDays==null) delinquentDays="30";
boolean zeroBalances = (showZeroBalances.equals("false")) ? false:true;

// Get a list of providers
String myQuery="select providers.id as providerid, patients.id as patientid, batches.id as batchid, patients.accountnumber, providers.name, concat(patients.firstname, ' ', patients.lastname) as patientname, DATEDIFF(current_date,billed) as daysold, " +
        "  substr(concat(providers.name,' - ',REPLACE(substr(providers.address,1,locate(_latin1'\r',providers.address)-1),'\r\n',''),' - ', " +
        "   case when substr(providers.address,length(providers.address)-4,1)='-' then " +
        "     replace(substr(providers.address,(locate(_latin1'\r',providers.address) + 2),length(providers.address)-10-(locate(_latin1'\r',providers.address) + 2)),'\r\n',' ') " +
        "   else " +
        "     replace(substr(providers.address,(locate(_latin1'\r',providers.address) + 2),length(providers.address)-5-(locate(_latin1'\r',providers.address) + 2)),'\r\n',' ') " +
        "   end),1,55) as headingname, " +
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
        "and DATEDIFF(current_date,billed)>=" + delinquentDays;
*/
String provider = request.getParameter("providerId");
String dDays = request.getParameter("delinquentDays");
String pType = request.getParameter("patientType");

if (provider==null) provider="0";
if (dDays==null) dDays="30";

String providerQuery="SELECT 0 as providerid, '*All' as name union select id as providerid, substr(concat(name,' - ',REPLACE(substr(address,1,locate(_latin1'\r',address)-1),'\r\n',''),' - '," +
        "    case when substr(providers.address,length(providers.address)-4,1)='-' then" +
        "      replace(substr(address,(locate(_latin1'\r',address) + 2),length(address)-10-(locate(_latin1'\r',address) + 2)),'\r\n',' ')" +
        "    else" +
        "      replace(substr(address,(locate(_latin1'\r',address) + 2),length(address)-5-(locate(_latin1'\r',address) + 2)),'\r\n',' ')" +
        "    end),1,55) as name from providers where not reserved order by name";

ResultSet providerRs=io.opnRS(providerQuery);
//ResultSet agingComboRs=io.opnRS("select mindays as delinquentDays from agingitems order by seq");
ResultSet agingComboRs=io.opnRS("select mindays, mindays as delinquentDays, seq from agingitems union select 'All' as mindays, 'All' as delinquentdays, 999999 as seq order by seq");
ResultSet patientTypeRs=io.opnRS("select 'A' as patientType, 'All' As description union select 'I' as patientType, 'Insurance' As description union select 'P' as patientType, 'PIP' As description");
// Set up an RWHtmlForm
RWHtmlForm frm = new RWHtmlForm("frmInput", "", "POST");

// Show the resource combobox
out.print(frm.startForm());
out.print("<b>Insurance: </b>" + frm.comboBox(providerRs, "providerId", "providerId", false, "1", null, provider, "class=cBoxText") + "</b>&nbsp;&nbsp;");
out.print("<b>Delinquent Days: </b>" + frm.comboBox(agingComboRs, "delinquentDays", "delinquentDays", false, "1", null, dDays, "class=cBoxText") + "</b>&nbsp;&nbsp;");
out.print("<b>Patient Type: " + frm.comboBox(patientTypeRs, "patientType", "patientType", false, "1", null, pType, "class=cBoxText") + "</b>&nbsp;&nbsp;");

//out.print("<b>Delinquent Days</b>&nbsp;&nbsp;<input type=\"text\" value=\"" + delinquentDays + "\" name=\"delinquentDays\" size=\"3\" maxlength=\"3\" id=\"delinquentDays\" class=\"tBoxText\" style=\"text-align: right;\">&nbsp;&nbsp;");

out.print(frm.submitButton("go", "class=button") + "</b>&nbsp;&nbsp;");
out.print(frm.button("print", "onClick=\"printReport('" + provider + "','" + dDays + "')\" class=\"button\""));
out.print(frm.endForm());

// Only generate the report if this is a post
if (request.getMethod().equals("POST")) {
%>
<%@include file="insurance_delinquency_body.jsp" %>

<div align="center"><input type="button" onClick="printReport('<%=provider%>',<%=dDays%>)" class="button" value="print"></div>
<%
}
%>

<%@ include file="template/pagebottom.jsp" %>