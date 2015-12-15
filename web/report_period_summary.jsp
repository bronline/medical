<%@include file="template/pagetop.jsp" %>
<%@ page import="java.text.*" %>

<script>
    function printReport(target) {
      window.open(target,'print','height=300,width=640,scrollbars=yes,resizable');
    }
</script>
<%
   RWInputForm frm = new RWInputForm();
   frm.setShowDatePicker(true);

   String startDate = request.getParameter("startdate");
   String endDate = request.getParameter("enddate");
   SimpleDateFormat isoFormat = new SimpleDateFormat("yyyy-MM-dd");
   SimpleDateFormat mdyFormat = new SimpleDateFormat("MM/dd/yyyy");
   NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance(Locale.US);
   String patientTypeFilter = "";

   if (startDate == null) {
       startDate = mdyFormat.format(new java.util.Date());
   }

   if (endDate == null) {
       endDate = startDate;
   }

   String newPatients="0";
   String patientsWithAppt="0";
   String patientsNoAppt="0";
   String patientVisits="0";
   String appointments="0";
   String appointmentsWithVisit="0";
   String appointmentsWithNoVisit="0";
   String resourceFilter = "";
   String resourceId = request.getParameter("resourceId");
   String firstVisitQuery = "";
   int newCashPatients = 0;
   int newInsPatients = 0;
   int cashPatientVisits = 0;
   int insPatientVisits = 0;
   boolean insuranceOnly = false;
   boolean cashOnly = false;

   int totChgCnt=0;
   int totPayCnt=0;
   int totWoCnt=0;
   double totChg=0;
   double totPay=0;
   double totWo=0;

   double totalCharges = 0.0;
   double totalPtPayments = 0.0;
   double totalWriteOff = 0.0;
   double totalPayerAdj = 0.0;
   double totalPayerPmt = 0.0;
   double totalOtherAdj = 0.0;

   ResultSet resourceRs = io.opnRS("Select 0 as resourceId, '-- All --' as name union Select id as resourceid, name from resources order by name");

   out.print(frm.startForm());
   out.print("<table><tr>");
   out.print("<td>Start</td><td>" + frm.date(tools.utils.Format.formatDate(startDate, "MM/dd/yyyy"), "startdate", "class=tBoxText") + "</td>");
   out.print("<td>End</td><td>" + frm.date(tools.utils.Format.formatDate(endDate, "MM/dd/yyyy"), "enddate", "class=tBoxText") + "</td>");
   out.print("<td>Provider</td><td>" + frm.comboBox(resourceRs, "resourceId", "resourceId", false, "1", null, resourceId, "class=\"cBoxText\"") + "</td>");
   out.print("<td>" + frm.submitButton("go", "class=button") + "</td>");
   out.print("</tr></table>");
   out.print(frm.endForm());

   out.print("<div style=\" height: 300; width: 618; overflow: auto;\">");

   String target="print_report_period_summary.jsp?startdate=" + tools.utils.Format.formatDate(startDate, "yyyy-MM-dd") + "&enddate=" + tools.utils.Format.formatDate(endDate, "yyyy-MM-dd");

   startDate=tools.utils.Format.formatDate(startDate, "yyyy-MM-dd");
   endDate=tools.utils.Format.formatDate(endDate, "yyyy-MM-dd");

   if(insuranceOnly) {
        patientTypeFilter=" and patientid  in (select patientid from patientinsurance where active and primaryprovider and current_date>=insuranceeffective)";
   } else if (cashOnly) {
        patientTypeFilter=" and patientid not in (select patientid from patientinsurance where active and primaryprovider and current_date>=insuranceeffective)";
   }

   if(resourceId != null && !resourceId.equals("0")) {
        resourceFilter = " where c.resourceid = " + resourceId + " AND ";
        target += "&resourceId=" + resourceId;
   } else {
       resourceId="0";
   }

   firstVisitQuery = "select `visits`.`patientid` AS `patientid`, min(`visits`.`date`) AS `date` " +
           "from `visits` " +
           "left join (select distinct visitid, resourceid from charges) c on c.visitid=`visits`.id " + resourceFilter.replaceAll("charges.","c.") +
           " group by `visits`.`patientid`";

//   ResultSet npRs = io.opnRS("select count(*) from (" + firstVisitQuery + ") a where date between '" + startDate + "' and '" + endDate + "'" + patientTypeFilter);
   ResultSet npRs = io.opnRS("CALL rwcatalog.prGetNewPatientCount('" + databaseName + "','" + resourceFilter + "','" + startDate + "','" + endDate + "'," + resourceId + ")");
   if (npRs.next()) {
       newPatients=npRs.getString(1);
   }
   npRs.close();

//   ResultSet newCashPtRs = io.opnRS("select count(*) from (" + firstVisitQuery + ") a where date between '" + startDate + "' and '" + endDate + "' and patientid not in (select patientid from patientinsurance where active and primaryprovider and current_date>=insuranceeffective)");
   ResultSet newCashPtRs = io.opnRS("CALL rwcatalog.prGetNewCashPatientCount('" + databaseName + "','" + resourceFilter + "','" + startDate + "','" + endDate + "'," + resourceId + ")");
   if(newCashPtRs.next()) { newCashPatients = newCashPtRs.getInt(1); }
   newCashPtRs.close();

//   ResultSet newInsPtRs = io.opnRS("select count(*) from (" + firstVisitQuery + ") a where date between '" + startDate + "' and '" + endDate + "' and patientid in (select patientid from patientinsurance where active and primaryprovider and current_date>=insuranceeffective)");
   ResultSet newInsPtRs = io.opnRS("CALL rwcatalog.prGetNewInsurancePatientCount('" + databaseName + "','" + resourceFilter + "','" + startDate + "','" + endDate + "'," + resourceId + ")");
   if(newInsPtRs.next()) { newInsPatients = newInsPtRs.getInt(1); }
   newInsPtRs.close();

//   ResultSet pvRs = io.opnRS("select count(*) from visits where date between '" + startDate + "' and '" + endDate + "'" + patientTypeFilter);
   ResultSet pvRs = io.opnRS("select count(*) from visits left join (select distinct visitid, resourceid from charges " + resourceFilter + ") c on c.visitid=`visits`.id where date between '" + startDate + "' and '" + endDate + "'" + patientTypeFilter);
   if (pvRs.next()) {
       patientVisits=pvRs.getString(1);
   }
   pvRs.close();

//   ResultSet cashPtVisitsRs = io.opnRS("select count(*) from visits left join (select distinct visitid, resourceid from charges " + resourceFilter + ") c on c.visitid=`visits`.id where date between '" + startDate + "' and '" + endDate + "' and patientid not in (select patientid from patientinsurance where active and primaryprovider and current_date>=insuranceeffective)");
   ResultSet cashPtVisitsRs = io.opnRS("CALL rwcatalog.prGetCashPatientVisits('" + databaseName + "','" + resourceFilter + "','" + startDate + "','" + endDate + "')");
   if (cashPtVisitsRs.next()) { cashPatientVisits=cashPtVisitsRs.getInt(1); }
   cashPtVisitsRs.close();

//   ResultSet insPtVisitsRs = io.opnRS("select count(*) from visits left join (select distinct visitid, resourceid from charges " + resourceFilter + ") c on c.visitid=`visits`.id where date between '" + startDate + "' and '" + endDate + "' and patientid in (select patientid from patientinsurance where active and primaryprovider and current_date>=insuranceeffective)");
   ResultSet insPtVisitsRs = io.opnRS("CALL rwcatalog.prGetInsurancePatientVisits('" + databaseName + "','" + resourceFilter + "','" + startDate + "','" + endDate + "')");
   if (insPtVisitsRs.next()) { insPatientVisits=insPtVisitsRs.getInt(1); }
   insPtVisitsRs.close();

   ResultSet pwaRs = io.opnRS("select count(*) from visits left join (select distinct visitid, resourceid from charges " + resourceFilter + ") c on c.visitid=`visits`.id where appointmentid in (select id from appointments) and date between '" + startDate + "' and '" + endDate + "'" + patientTypeFilter);
   if (pwaRs.next()) {
       patientsWithAppt=pwaRs.getString(1);
   }
   pwaRs.close();

   ResultSet pnaRs = io.opnRS("select count(*) from visits left join (select distinct visitid, resourceid from charges " + resourceFilter + ") c on c.visitid=`visits`.id where appointmentid not in (select id from appointments) and date between '" + startDate + "' and '" + endDate + "'" + patientTypeFilter);
   if (pnaRs.next()) {
       patientsNoAppt=pnaRs.getString(1);
   }
   pnaRs.close();

//   if(resourceId != null) {
       resourceFilter.replaceAll("where", "and");
//   }

   ResultSet aRs = io.opnRS("select count(*) from appointments where date between '" + startDate + "' and '" + endDate + "'" + patientTypeFilter + resourceFilter.replaceAll("charges.","").replaceAll("where","and"));
   if (aRs.next()) {
       appointments=aRs.getString(1);
   }
   aRs.close();

   ResultSet awvRs = io.opnRS("select count(*) from appointments where date between '" + startDate + "' and '" + endDate + "' and id in (select appointmentid from visits)"  + patientTypeFilter + resourceFilter.replaceAll("charges.","").replaceAll("where","and"));
   if (awvRs.next()) {
       appointmentsWithVisit=awvRs.getString(1);
   }
   awvRs.close();

   ResultSet anvRs = io.opnRS("select count(*) from appointments where date between '" + startDate + "' and '" + endDate + "' and id not in (select appointmentid from visits)"  + patientTypeFilter + resourceFilter.replaceAll("charges.","").replaceAll("where","and"));
   if (anvRs.next()) {
       appointmentsWithNoVisit=anvRs.getString(1);
   }
   anvRs.close();

   out.print("<table width=500>");

   out.print("<tr><th colspan=3>Summary from " + tools.utils.Format.formatDate(startDate,"MM/dd/yyyy") + " to " + tools.utils.Format.formatDate(endDate, "MM/dd/yyyy") + "</td><tr>");

   out.print("<tr>");
   out.print("<td width=\"50%\"><b>Total New Patients:</b></td>");
   out.print("<td width=\"25%\" align=right><b>" + newPatients + "</b></td>");
   out.print("<td width=\"25%\"></td>");
   out.print("</tr>");

   out.print("<tr>");
   out.print("<td width=\"50%\">- New Cash Patients:</td>");
   out.print("<td width=\"25%\" align=right>" + newCashPatients + "</td>");
   out.print("<td width=\"25%\"></td>");
   out.print("</tr>");

   out.print("<tr>");
   out.print("<td width=\"50%\">- New Insurance Patients:</td>");
   out.print("<td width=\"25%\" align=right>" + newInsPatients + "</td>");
   out.print("<td width=\"25%\"></td>");
   out.print("</tr>");

   out.print("<tr><td colspan=2 style='height:2px; font-size:2px; border-top:1px dotted black'>&nbsp;</td>");

   out.print("<tr>");
   out.print("<td><b>Total Visits With Appointment:</b></td>");
   out.print("<td align=right><b>" + patientsWithAppt + "</b></td>");
   out.print("<td></td>");
   out.print("</tr>");

   out.print("<tr>");
   out.print("<td><b>Total Visits Without Appointment:</b></td>");
   out.print("<td align=right><b>" + patientsNoAppt + "</b></td>");
   out.print("<td></td>");
   out.print("</tr>");

   out.print("<tr>");
   out.print("<td><b>Total Visits:</b></td>");
   out.print("<td align=right><b>" + patientVisits + "</b></td>");
   out.print("<td></td>");
   out.print("</tr>");

   out.print("<tr>");
   out.print("<td>- Cash Patients:</td>");
   out.print("<td align=right>" + cashPatientVisits + "</td>");
   out.print("<td></td>");
   out.print("</tr>");

   out.print("<tr>");
   out.print("<td>- Insurance Patients:</td>");
   out.print("<td align=right>" + insPatientVisits + "</td>");
   out.print("<td></td>");
   out.print("</tr>");

   out.print("<tr><td colspan=2 style='height:2px; font-size:2px; border-top:1px dotted black'>&nbsp;</td>");

   out.print("<tr>");
   out.print("<td><b>Total Appointments:</b></td>");
   out.print("<td align=right><b>" + appointments + "</b></td>");
   out.print("<td></td>");
   out.print("</tr>");

   out.print("<tr>");
   out.print("<td>- Appointments With a Visit:</td>");
   out.print("<td align=right>" + appointmentsWithVisit + "</td>");
   out.print("<td></td>");
   out.print("</tr>");

   out.print("<tr>");
   out.print("<td>- Appointments Without a Visit:</td>");
   out.print("<td align=right>" + appointmentsWithNoVisit + "</td>");
   out.print("<td></td>");
   out.print("</tr>");

   out.print("<tr><th colspan=3>Charges</td><tr>");

    out.flush();
    
   String chargeFilter = "select " +
           "`a`.`id` AS `chargeid`, " +
           "`a`.`resourceid`, "+
           "`b`.`date` AS `chargedate`, " +
           "`c`.`description` AS `chargeitem`, " +
           "`a`.`chargeamount` AS `chargeamount` " +
           "from `charges` `a` " +
           "join `visits` `b` on `a`.`visitid` = `b`.`id` " +
           "join `items` `c` on `a`.`itemid` = `c`.`id` ";

   String paymentFilter = "";

   if(cashOnly || insuranceOnly) {
//        chargeFilter  += " and chargeid in (select id from charges where visitid in (select id from visits where 1=1 " + patientTypeFilter + resourceFilter.replaceAll("where", "and").replaceAll("charges.","a.") + "))";
        chargeFilter  += " and `a`.`id` in (select id from charges where visitid in (select id from visits where 1=1 " + patientTypeFilter + "))";
   }

   chargeFilter +=  resourceFilter.replaceAll("where", "and").replaceAll("charges.","a.");

//   ResultSet csRs = io.opnRS("select chargeitem, count(*), sum(chargeamount) from chargesummary where chargedate between '" + startDate + "' and '" + endDate + "'" + chargeFilter + resourceFilter.replaceAll("where", "and").replaceAll("charges.","a.") + " group by chargeitem order by 1");
   ResultSet csRs = io.opnRS("select chargeitem, count(*), sum(chargeamount) from (" + chargeFilter + ") chargesummary where chargedate between '" + startDate + "' and '" + endDate + "' group by chargeitem order by 1");
   while (csRs.next()) {
       out.print("<tr>");
       out.print("<td>" + csRs.getString(1) + "</td>");
       out.print("<td align=right>" + csRs.getString(2) + "</td>");
       out.print("<td align=right>" + currencyFormatter.format(csRs.getDouble(3)) + "</td>");
       out.print("</tr>");
       totChgCnt+=csRs.getInt(2);
       totChg+=csRs.getDouble(3);
       totalCharges += csRs.getDouble(3);
   }
   out.print("<tr>");
   out.print("<td style=\"border-top: 1px solid black\">TOTALS</td>");
   out.print("<td align=right style=\"border-top: 1px solid black\">" + totChgCnt + "</td>");
   out.print("<td align=right style=\"border-top: 1px solid black\">" + currencyFormatter.format(totChg) + "</td>");
   out.print("</tr>");

   out.print("<tr><th colspan=3>Cash Payments</td><tr>");

   String unappliedQuery="SELECT 'Unapplied' as chargeitem, count(*), sum(ifnull(originalamount-(select sum(amount) " +
                         "from payments where parentpayment=p.id and date between '" + startDate + "' and '" + endDate + "'), originalamount)) " +
                         "FROM payments p where chargeid=0 and date between '" + startDate + "' and '" + endDate + "' " +
                         "group by 'Unapplied'";

   String paymentSummaryQuery = "select `a`.`id` AS `paymentid`, `a`.`amount` AS `paymentamount`, " +
                        "`b`.`chargeamount` AS `chargeamount`, ifnull(`e`.`name`,_latin1'Cash') AS `provider`, " +
                        "`d`.`description` AS `chargeitem`, `a`.`date` AS `paymentdate`, `c`.`date` AS `chargedate`, " +
                        "`a`.`parentpayment` AS `parentpayment` " +
                        "from `payments` `a` " +
                        "join `charges` `b` on `a`.`chargeid` = `b`.`id` " +
                        "join `visits` `c` on `b`.`visitid` = `c`.`id` " +
                        "join `items` `d` on `b`.`itemid` = `d`.`id` " +
                        "left join `providers` `e` on `a`.`provider` = `e`.`id` where `a`.`amount` > 0" +
                        resourceFilter.replaceAll("where", "and").replaceAll("charges.", "b.");

   String paymentsQuery="select chargeitem, count(*), sum(paymentamount) " +
                        "from ( " +
                        paymentSummaryQuery +
                        ") pqs " +
                        "where provider = 'cash' AND " +
                        "pqs.paymentdate between '" + startDate + "' and '" + endDate + "' " +
//                        "and (pqs.parentpayment=0 || (pqs.parentpayment<>0 and paymentdate=(select date from payments p where p.id=pqs.parentpayment))) " +
                        "group by pqs.chargeitem";

   ResultSet psRs = io.opnRS(paymentsQuery + " union " + unappliedQuery);
   while (psRs.next()) {
       out.print("<tr>");
       out.print("<td>" + psRs.getString(1) + "</td>");
       out.print("<td align=right>" + psRs.getString(2) + "</td>");
       out.print("<td align=right>" + currencyFormatter.format(psRs.getDouble(3)) + "</td>");
       out.print("</tr>");
       totPayCnt+=psRs.getInt(2);
       totPay+=psRs.getDouble(3);
       totalPtPayments += psRs.getDouble(3);
   }
   out.print("<tr>");
   out.print("<td style=\"border-top: 1px solid black\">TOTALS</td>");
   out.print("<td align=right style=\"border-top: 1px solid black\">" + totPayCnt + "</td>");
   out.print("<td align=right style=\"border-top: 1px solid black\">" + currencyFormatter.format(totPay) + "</td>");
   out.print("</tr>");

   out.flush();
   
   ResultSet rsvRs = io.opnRS("select id, name, isadjustment from providers where reserved order by name");
   while(rsvRs.next()) {
       totWoCnt=0;
       totWo=0.0;
       boolean typeHasDetail = false;

       ResultSet paRs = io.opnRS("select chargeitem, count(*), sum(paymentamount) from (" + paymentSummaryQuery + ") pqs where provider = '" + rsvRs.getString("name") + "' && paymentdate between '" + startDate + "' and '" + endDate + "' group by chargeitem having count(*)>0 order by 1");
       while (paRs.next()) {
           typeHasDetail = true;
           if(paRs.getRow() == 1) { out.print("<tr><th colspan=3>" + rsvRs.getString("name") + "</td><tr>"); }
           out.print("<tr>");
           out.print("<td>" + paRs.getString(1) + "</td>");
           out.print("<td align=right>" + paRs.getString(2) + "</td>");
           out.print("<td align=right>" + currencyFormatter.format(paRs.getDouble(3)) + "</td>");
           out.print("</tr>");
           totWoCnt+=paRs.getInt(2);
           totWo+=paRs.getDouble(3);
           if(rsvRs.getInt("id") == 10) { totalWriteOff += paRs.getDouble(3); }
           else if(rsvRs.getBoolean("isadjustment")) { totalPayerAdj += paRs.getDouble(3); }
           else { totalOtherAdj += paRs.getDouble(3); }
       }
       if(typeHasDetail) {
           out.print("<tr>");
           out.print("<td style=\"border-top: 1px solid black\">TOTALS</td>");
           out.print("<td align=right style=\"border-top: 1px solid black\">" + totWoCnt + "</td>");
           out.print("<td align=right style=\"border-top: 1px solid black\">" + currencyFormatter.format(totWo) + "</td>");
           out.print("</tr>");
           
           out.flush();
         }
   }

   String insuranceQuery = "select" +
           "  id as providerid," +
           "  concat(name,' - ',replace(substr(address,(locate(_latin1'\r',address) + 1),length(address)-(locate(_latin1'\r',address))),'\r\n',' ')) as name " +
           "from providers " +
           "where not reserved " +
           "order by name";

   String insuranceDetailQuery = "select " +
           "  `d`.`description` AS `chargeitem`, " +
           "  count(*), " +
           "  SUM(`a`.`amount`) AS `paymentamount`" +
           "from `payments` `a` " +
           "join `charges` `b` on `a`.`chargeid` = `b`.`id` " +
           "join `visits` `c` on `b`.`visitid` = `c`.`id` " +
           "join `items` `d` on `b`.`itemid` = `d`.`id` " +
           "left join `providers` `e` on `a`.`provider` = `e`.`id` " +
           "where " +
           "  `a`.`amount` > 0 and " +
           "  not reserved and " +
           "  (parentpayment=0 || (parentpayment<>0 and a.`date`=(select date from payments p where p.id=a.parentpayment))) and " +
           "  `a`.`date` between '" + startDate + "' and '" + endDate + "' and " +
           "  e.id=#### " +
           resourceFilter.replaceAll("where","and").replaceAll("charges.", "b.") + " " +
           "group by d.description " +
           "having count(*)>0 " +
           "order by 1";

   ResultSet insRs = io.opnRS(insuranceQuery);
   while(insRs.next()) {
       totWoCnt=0;
       totWo=0.0;
       boolean payerHasDetail = false;

//       ResultSet paRs = io.opnRS(insuranceDetailQuery.replaceAll("####", insRs.getString("providerid")));
       ResultSet paRs = io.opnRS("CALL rwcatalog.prGetPaymentsForProvider('" + databaseName + "','" + resourceFilter + "','" + startDate + "','" + endDate + "'," + insRs.getString("providerid") + ")");
       while (paRs.next()) {
           payerHasDetail = true;
           if(paRs.getRow() == 1) { out.print("<tr><th colspan=3>Payments from (" + insRs.getString("name") + ")</td><tr>"); }
           out.print("<tr>");
           out.print("<td>" + paRs.getString(1) + "</td>");
           out.print("<td align=right>" + paRs.getString(2) + "</td>");
           out.print("<td align=right>" + currencyFormatter.format(paRs.getDouble(3)) + "</td>");
           out.print("</tr>");
           totWoCnt+=paRs.getInt(2);
           totWo+=paRs.getDouble(3);
           totalPayerPmt += paRs.getDouble(3);
       }
       if(payerHasDetail) {
           out.print("<tr>");
           out.print("<td style=\"border-top: 1px solid black\">TOTALS</td>");
           out.print("<td align=right style=\"border-top: 1px solid black\">" + totWoCnt + "</td>");
           out.print("<td align=right style=\"border-top: 1px solid black\">" + currencyFormatter.format(totWo) + "</td>");
           out.print("</tr>");
           
           out.flush();
       }
   }

   out.print("</table></div>");

   out.flush();
   
   out.print("<br/><br/>");

   String cashPtPayments = "select sum(amount) from payments p left join charges c on c.id=p.chargeid left join providers pr on pr.id=p.provider left join patientinsurance pi on pi.patientid=p.patientid and (pi.active or not pi.active and pi.insuranceeffective<='" + startDate + "') and pi.primaryprovider  where   `date` between '" + startDate + "' and '" + endDate + "' and ((reserved   and not pr.isadjustment  and pr.id<>10) or p.provider=0) and p.chargeid<>0 and pi.id is null " + resourceFilter.replaceAll("where","and").replaceAll("charges.", "c.");
   String insPtPayments = "select sum(amount) from payments p left join charges c on c.id=p.chargeid left join providers pr on pr.id=p.provider left join patientinsurance pi on pi.patientid=p.patientid and (pi.active or not pi.active and pi.insuranceeffective<='" + startDate + "') and pi.primaryprovider  where   `date` between '" + startDate + "' and '" + endDate + "' and ((reserved   and not pr.isadjustment  and pr.id<>10) or p.provider=0) and p.chargeid<>0 and pi.id is not null " + resourceFilter.replaceAll("where","and").replaceAll("charges.", "c.");
   String cashPtWriteOff = "select sum(amount) from payments p left join charges c on c.id=p.chargeid left join providers pr on pr.id=p.provider left join patientinsurance pi on pi.patientid=p.patientid and (pi.active or not pi.active and pi.insuranceeffective<='" + startDate + "') and pi.primaryprovider  where  `date` between '" + startDate + "' and '" + endDate + "' and pr.id=10 and p.chargeid<>0 and pi.id is null " + resourceFilter.replaceAll("charges.", "c.").replaceAll("where","and");
   String insPtWriteOff = "select sum(amount) from payments p left join charges c on c.id=p.chargeid left join providers pr on pr.id=p.provider left join patientinsurance pi on pi.patientid=p.patientid and (pi.active or not pi.active and pi.insuranceeffective<='" + startDate + "') and pi.primaryprovider  where  `date` between '" + startDate + "' and '" + endDate + "' and pr.id=10 and p.chargeid<>0 and pi.id is not null " + resourceFilter.replaceAll("charges.", "c.").replaceAll("where","and");
   String insPtPayerAdjustment = "select sum(amount) from payments p left join charges c on c.id=p.chargeid left join providers pr on pr.id=p.provider left join patientinsurance pi on pi.patientid=p.patientid and (pi.active or not pi.active and pi.insuranceeffective<='" + startDate + "') and pi.primaryprovider  where  `date` between '" + startDate + "' and '" + endDate + "' and pr.isadjustment and p.chargeid<>0 and pi.id is not null " + resourceFilter.replaceAll("charges.", "c.").replaceAll("where","and");
   String insPtPayerPayments = "select sum(amount) from payments p left join charges c on c.id=p.chargeid left join patientinsurance pi on pi.patientid=p.patientid and pi.providerid=p.provider left join providers pr on pr.id=p.provider where  `date` between '" + startDate + "' and '" + endDate + "'  and pi.id is not null and not pr.isadjustment and p.chargeid<>0 and not pi.ispip " + resourceFilter.replaceAll("charges.", "c.").replaceAll("where","and");
   String pipPtPayerPayments = "select sum(amount) from payments p left join charges c on c.id=p.chargeid left join patientinsurance pi on pi.patientid=p.patientid and pi.providerid=p.provider left join providers pr on pr.id=p.provider where  `date` between '" + startDate + "' and '" + endDate + "'  and pi.id is not null and not pr.isadjustment and p.chargeid<>0 and pi.ispip " + resourceFilter.replaceAll("charges.", "c.").replaceAll("where","and");

   ResultSet cashPtPaymentsRs = io.opnRS(cashPtPayments);
   ResultSet insPtPaymentsRs = io.opnRS(insPtPayments);
   ResultSet cashPtWriteOffRs = io.opnRS(cashPtWriteOff);
   ResultSet insPtWriteOffRs = io.opnRS(insPtWriteOff);
   ResultSet insPtPayerAdjustmentRs = io.opnRS(insPtPayerAdjustment);
   ResultSet insPtPayerPaymentsRs = io.opnRS(insPtPayerPayments);
   ResultSet pipPtPayerPaymentsRS = io.opnRS(pipPtPayerPayments );

   cashPtPaymentsRs.next();
   insPtPaymentsRs.next();
   cashPtWriteOffRs.next();
   insPtWriteOffRs.next();
   insPtPayerAdjustmentRs.next();
   insPtPayerPaymentsRs.next();
   pipPtPayerPaymentsRS.next();

   out.print("<table width=\"500\" colspan=\"0\" colspacing=\"0\">");
   out.print("<tr><td width=\"75%\" style=\"font-size: 12px;\">Total Services Rendered (Charges)</td><td width=\"25%\" align=\"right\" style=\"font-size: 12px;\">" + tools.utils.Format.formatCurrency(totalCharges) + "</td></tr>");
   out.print("<tr><td width=\"75%\" style=\"font-size: 12px;\">Total Payments Received From Cash Patients</td><td width=\"25%\" align=\"right\" style=\"font-size: 12px;\">" + tools.utils.Format.formatCurrency(cashPtPaymentsRs.getDouble(1)) + "</td></tr>");
   out.print("<tr><td width=\"75%\" style=\"font-size: 12px;\">Total Write-Off For Cash Patients</td><td width=\"25%\" align=\"right\" style=\"font-size: 12px;\">" + tools.utils.Format.formatCurrency(cashPtWriteOffRs.getDouble(1)) + "</td></tr>");
   out.print("<tr><td width=\"75%\" style=\"font-size: 12px;\">Total Payments Received From Insurance Patients</td><td width=\"25%\" align=\"right\" style=\"font-size: 12px;\">" + tools.utils.Format.formatCurrency(insPtPaymentsRs.getDouble(1)) + "</td></tr>");
   out.print("<tr><td width=\"75%\" style=\"font-size: 12px;\">Total Insurance Payments Received For Insurance Patients</td><td width=\"25%\" align=\"right\" style=\"font-size: 12px;\">" + tools.utils.Format.formatCurrency(insPtPayerPaymentsRs.getDouble(1)) + "</td></tr>");
   out.print("<tr><td width=\"75%\" style=\"font-size: 12px;\">Total PI Payments Received For PI Cases </td><td width=\"25%\" align=\"right\" style=\"font-size: 12px;\">" + tools.utils.Format.formatCurrency(pipPtPayerPaymentsRS.getDouble(1)) + "</td></tr>");
   out.print("<tr><td width=\"75%\" style=\"font-size: 12px;\">Total Payer Adjustments For Insurance Patients</td><td width=\"25%\" align=\"right\" style=\"font-size: 12px;\">" + tools.utils.Format.formatCurrency(insPtPayerAdjustmentRs.getDouble(1)) + "</td></tr>");
   out.print("<tr><td width=\"75%\" style=\"font-size: 12px;\">Total Write-Off For Insurance Patients</td><td width=\"25%\" align=\"right\" style=\"font-size: 12px;\">" + tools.utils.Format.formatCurrency(insPtWriteOffRs.getDouble(1)) + "</td></tr>");
   out.print("<tr><td width=\"75%\" style=\"font-weight: bold; font-size: 12px; border-top: 1px solid black;\">Total Outstanding Balance</td><td width=\"25%\" align=\"right\" style=\"font-weight: bold; font-size: 12px; border-top: 1px solid black;\">" + tools.utils.Format.formatCurrency(totalCharges-cashPtPaymentsRs.getDouble(1)-cashPtWriteOffRs.getDouble(1)-insPtPaymentsRs.getDouble(1)-insPtPayerPaymentsRs.getDouble(1)-insPtPayerAdjustmentRs.getDouble(1)-insPtWriteOffRs.getDouble(1)-pipPtPayerPaymentsRS.getDouble(1)) + "</td></tr>");
   out.print("</table>");

   out.print("<br/><br/>");

   out.print("<input type=button class=button value=print onClick=printReport('"+ target + "')>");

   %>
<%@ include file="template/pagebottom.jsp" %>