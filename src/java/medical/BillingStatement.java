/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package medical;

import java.io.PrintWriter;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Enumeration;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import tools.RWConnMgr;
import tools.RWHtmlTable;
import tools.utils.Format;

/**
 *
 * @author rwandell
 */
public class BillingStatement {

    private  PrintWriter out;
    public int linesPerPage = 90;
    public int currentLine=1;
    public int currPage=1;
    public String printOption;
    public String statements;
    public Patient patient;
    public String complete = "C";
    public String patientType = "A";

    private String completedTransactions = "WHERE complete ";
    private PreparedStatement chgPs;
    private PreparedStatement patChkCmtPs;

    private double totalCharges=0.0;
    private double totalPayorPayments=0.0;
    private double totalPatientPayments=0.0;
    private double totalPayorAdjustments=0.0;
    private double totalPatientAdjustments=0.0;
    private double totalUnappliedPayments=0.0;

    private String selectedCharges;

    private String today = Format.formatDate(new java.util.Date(), "yyyy-MM-dd");

    public BillingStatement() {

    }

    public  void getHtml(RWConnMgr io, RWHtmlTable htmTb, HttpServletRequest request, HttpServletResponse response, Patient patient) throws Exception {
        this.patient=patient;
        out=response.getWriter();
        printOption=request.getParameter("printOption");
        statements=request.getParameter("statements");
        String minDays = request.getParameter("minDays");
        String maxDays = request.getParameter("maxDays");
        selectedCharges = "";
        String specificChargeQry = "";
        linesPerPage = 90;
        boolean printAllItems = false;
        htmTb.replaceNewLineChar(false);
        boolean billedOnly = false;

        totalCharges=0.0;
        totalPayorPayments=0.0;
        totalPatientPayments=0.0;
        totalPayorAdjustments=0.0;
        totalPatientAdjustments=0.0;
        totalUnappliedPayments=0.0;

        // S = Selected Charges
        // O = Open Items only
        // A = All Charge History
        // L = Charge Ledger

        if(printOption != null && (printOption.equals("A") || printOption.equals("L"))) { printAllItems=true; selectedCharges=getSelectedCharges(io, this.patient.getId(), true); }
        if(printOption != null && printOption.equals("S")) { selectedCharges=getSelectedCharges(io, request); }
        if(printOption != null && printOption.equals("O")) { selectedCharges=getSelectedCharges(io, this.patient.getId(), false); }
        if(request.getParameter("statements") != null) { selectedCharges=getSelectedCharges(io, this.patient.getId(), minDays, maxDays); }
        if(complete != null && !complete.equals("C") || printOption.equals("S")) { completedTransactions = ""; }

        chgPs = io.getConnection().prepareStatement("SELECT chargeid from batchcharges where chargeid=?");
//        patCmtPs = io.getConnection().prepareStatement("insert into comments (patientid, visitid, `date`, `comment`, `type`, appointmentid) values (?, ?, ?, ?, ?, ?)");
        patChkCmtPs = io.getConnection().prepareStatement("select * from comments where patientid=? and `date`=? and `type`=?");

        String chargesQuery = "SELECT visitid, ItemCount, ItemCharges FROM (" +
                "SELECT visits.Id as visitid, COUNT(*) AS ItemCount, SUM(charges.chargeamount*charges.quantity) AS ItemCharges " +
                "FROM visits " +
                "LEFT JOIN charges ON charges.visitid=visits.id " +
                "LEFT JOIN items ON items.Id=charges.itemid ";
                if(billedOnly) { chargesQuery += "LEFT JOIN (SELECT DISTINCT chargeid FROM batchcharges) bc ON bc.chargeid=charges.id "; }
                chargesQuery += "WHERE ";
                if(billedOnly) { chargesQuery += "((bc.chargeid IS NOT NULL AND items.billinsurance) OR (bc.chargeid IS NULL AND NOT items.billinsurance)) AND "; }
                chargesQuery += "visits.patientid=" + this.patient.getId() + " " +
                "GROUP BY visits.Id) chargesQuery";

        if(this.patient.getId() != 0) {

            if(printOption != null && (printOption.equals("A") || printOption.equals("S")) && !selectedCharges.equals("")) { specificChargeQry = " AND aa.id IN (select distinct visitid from charges where id in" + selectedCharges + ") "; }

            String balanceQuery = "select aa.id as visitId, aa.`Date`, IFNULL(cc.`Type`,'Office Visit') AS `Type`, ItemCount, " +
                "IFNULL(ItemCharges,0) AS ItemCharges, IFNULL(InsPayments,0) AS InsPayments, IFNULL(PatPayments,0) AS PatPayments, " +
                "IFNULL(Adjustments,0) AS Adjustments, IFNULL(WriteOffs,0) AS WriteOffs, (IFNULL(ItemCharges,0)-IFNULL(inspayments,0)-IFNULL(patpayments,0)-IFNULL(adjustments,0)-IFNULL(writeoffs,0)) as Balance " +
                "from visits aa left join appointments bb on aa.appointmentid=bb.id " +
                "left join appointmenttypes cc on bb.type=cc.id " +
                "LEFT JOIN (SELECT visitid, COUNT(*) AS ItemCount, SUM(chargeamount*quantity) AS ItemCharges FROM charges GROUP BY visitid) AS c ON c.visitid=aa.id " +
                "LEFT JOIN (SELECT v.id AS visitid, SUM(amount) AS Inspayments FROM payments p LEFT JOIN providers pp ON p.provider=pp.id LEFT JOIN charges c ON c.id=p.chargeid LEFT JOIN visits v ON v.id=c.visitid WHERE NOT pp.reserved GROUP BY v.id) AS i ON i.visitid=aa.id " +
                "LEFT JOIN (SELECT v.id AS visitid, SUM(amount) AS PatPayments FROM payments p LEFT JOIN providers pp ON p.provider=pp.id LEFT JOIN charges c ON c.id=p.chargeid LEFT JOIN visits v ON v.id=c.visitid WHERE (pp.reserved AND pp.id<>10 AND NOT pp.isadjustment) OR pp.id IS NULL GROUP BY v.id) AS pat ON pat.visitid=aa.id " +
                "LEFT JOIN (SELECT v.id AS visitid, SUM(amount) AS Adjustments FROM payments p LEFT JOIN providers pp ON p.provider=pp.id LEFT JOIN charges c ON c.id=p.chargeid LEFT JOIN visits v ON v.id=c.visitid WHERE pp.reserved AND pp.id<>10 AND pp.isadjustment GROUP BY v.id) AS adj ON adj.visitid=aa.id " +
                "LEFT JOIN (SELECT v.id AS visitid, SUM(amount) AS WriteOffs FROM payments p LEFT JOIN providers pp ON p.provider=pp.id LEFT JOIN charges c ON c.id=p.chargeid LEFT JOIN visits v ON v.id=c.visitid WHERE pp.reserved AND pp.id=10 GROUP BY v.id) AS wo ON wo.visitid=aa.id " +
                "WHERE aa.patientid=" + this.patient.getId();
            
            if((printOption != null && !printOption.equals("A") && !printOption.equals("S")) || request.getParameter("statements") != null) { balanceQuery += " AND (IFNULL(ItemCharges,0)-IFNULL(inspayments,0)-IFNULL(patpayments,0)-IFNULL(adjustments,0)-IFNULL(writeoffs,0))>0 "; }
            balanceQuery += specificChargeQry +
                " ORDER BY aa.`date` DESC";

           if(this.patient.hasInsurance() && printOption.equals("S")) {
               balanceQuery = "select aa.id as visitId, aa.`Date`, IFNULL(cc.`Type`,'Office Visit') AS `Type`, ItemCount, " +
                       "IFNULL(ItemCharges,0) AS ItemCharges, IFNULL(InsPayments,0) AS InsPayments, IFNULL(PatPayments,0) AS PatPayments, " +
                       "IFNULL(Adjustments,0) AS Adjustments, IFNULL(WriteOffs,0) AS WriteOffs, " +
                       "(IFNULL(ItemCharges,0)-IFNULL(inspayments,0)-IFNULL(patpayments,0)-IFNULL(adjustments,0)-IFNULL(writeoffs,0)) as Balance " +
                       "from visits aa " +
                       "left join appointments bb on aa.appointmentid=bb.id " +
                       "left join appointmenttypes cc on bb.type=cc.id " +
                       "LEFT JOIN (" + chargesQuery + ") AS c ON c.visitid=aa.id " +
                       "LEFT JOIN (SELECT v.id AS visitid, SUM(p.amount) AS Inspayments FROM payments p LEFT JOIN providers pp ON p.provider=pp.id LEFT JOIN charges c ON c.id=p.chargeid LEFT JOIN items i ON i.id=c.itemid LEFT JOIN (select distinct chargeid from batchcharges) AS bc ON bc.chargeid=c.id LEFT JOIN visits v ON v.id=c.visitid WHERE NOT pp.reserved AND ((i.billinsurance AND bc.chargeid IS NOT NULL) OR (NOT i.billinsurance AND bc.chargeid is null)) AND v.patientId=" + patient.getId() + " GROUP BY v.id) AS i ON i.visitid=aa.id " +
                       "LEFT JOIN (SELECT v.id AS visitid, SUM(p.amount) AS PatPayments FROM payments p LEFT JOIN providers pp ON p.provider=pp.id LEFT JOIN charges c ON c.id=p.chargeid LEFT JOIN visits v ON v.id=c.visitid WHERE (pp.reserved AND pp.id<>10 AND NOT pp.isadjustment) OR pp.id IS NULL AND v.patientId=" + patient.getId() + " GROUP BY v.id) AS pat ON pat.visitid=aa.id " +
                       "LEFT JOIN (SELECT v.id AS visitid, SUM(p.amount) AS Adjustments FROM payments p LEFT JOIN providers pp ON p.provider=pp.id LEFT JOIN charges c ON c.id=p.chargeid LEFT JOIN items i ON i.id=c.itemid LEFT JOIN (select distinct chargeid from batchcharges) AS bc ON bc.chargeid=c.id  LEFT JOIN visits v ON v.id=c.visitid WHERE pp.reserved AND pp.id<>10 AND pp.isadjustment AND ((i.billinsurance AND bc.chargeid IS NOT NULL) OR (NOT i.billinsurance AND bc.chargeid is null)) AND v.patientId=" + patient.getId() + " GROUP BY v.id) AS adj ON adj.visitid=aa.id " +
                       "LEFT JOIN (SELECT v.id AS visitid, SUM(p.amount) AS WriteOffs FROM payments p LEFT JOIN providers pp ON p.provider=pp.id LEFT JOIN charges c ON c.id=p.chargeid LEFT JOIN items i ON i.id=c.itemid LEFT JOIN batchcharges bc ON bc.chargeid=c.id LEFT JOIN visits v ON v.id=c.visitid WHERE pp.reserved AND pp.id=10 AND ((i.billinsurance AND bc.id IS NOT NULL) OR (NOT i.billinsurance AND bc.id is null)) AND v.patientId=" + patient.getId() + " GROUP BY v.id) AS wo ON wo.visitid=aa.id " +
                       "WHERE aa.patientid=" + patient.getId() + " ";
               
               if(!printOption.equals("A") && !printOption.equals("S") || request.getParameter("statements") != null) {
                    balanceQuery += " AND (IFNULL(ItemCharges,0)-IFNULL(inspayments,0)-IFNULL(patpayments,0)-IFNULL(adjustments,0)-IFNULL(writeoffs,0))>0 AND ItemCount<>0 ";
               } else {
                   balanceQuery += " AND c.visitid IS NOT NULL ";
               }

               balanceQuery += specificChargeQry;
               balanceQuery += " ORDER BY aa.`date` DESC";
           }

           String patientQuery = "select * from soapnoteheader sh " +
                   "left join (select patientid, count(*) as itemcount from patientinsurance group by patientid) pi on pi.patientid=sh.id " +
                   "where id=" +patient.getId();

           if(patientType != null && patientType.equals("I")) { patientQuery += " and pi.patientid is not null"; }

           ResultSet patientRs=io.opnRS(patientQuery);
           ResultSet openItemRs=io.opnRS(balanceQuery);
           ResultSet envRs = io.opnRS("select * from environment");

           ResultSet unappliedRs = io.opnRS("select ifnull(sum(amount),0) AS unapplied from payments where patientid=" + patient.getId() + " and chargeid=0 and amount>0");
           if(unappliedRs.next()) { totalUnappliedPayments = unappliedRs.getDouble("unapplied"); }
           unappliedRs.close();
           unappliedRs = null;

           envRs.next();

           double balance=0.0;
           boolean hasItems = false;

//           if(printOption.equals("O") || request.getParameter("statements") != null) { linesPerPage=5; }

           if(patientRs.next()) {
               while(openItemRs.next()) {
                   checkForPageBreak(htmTb, patientRs, envRs, today);
                   balance += openItemRs.getDouble("balance");
                   hasItems = true;

                   if(openItemRs.getDouble("balance") != 0.0 || printAllItems || printOption.equals("S")) {
                       out.print(htmTb.startRow());
                       out.print(htmTb.addCell(tools.utils.Format.formatDate(openItemRs.getString("date"), "MM/dd/yyyy"), htmTb.CENTER, "class=openItem"));
                       out.print(htmTb.addCell(openItemRs.getString("itemcount"), htmTb.CENTER, "class=openItem"));
                       out.print(htmTb.addCell(tools.utils.Format.formatCurrency(openItemRs.getString("itemcharges")), htmTb.RIGHT, "class=openItem"));
                       out.print(htmTb.addCell(tools.utils.Format.formatCurrency(openItemRs.getString("inspayments")), htmTb.RIGHT, "class=openItem"));
                       out.print(htmTb.addCell(tools.utils.Format.formatCurrency(openItemRs.getString("patpayments")), htmTb.RIGHT, "class=openItem"));
                       out.print(htmTb.addCell(tools.utils.Format.formatCurrency(openItemRs.getString("adjustments")), htmTb.RIGHT, "class=openItem"));
                       out.print(htmTb.addCell(tools.utils.Format.formatCurrency(openItemRs.getString("writeoffs")), htmTb.RIGHT, "class=openItem"));
                       out.print(htmTb.addCell(tools.utils.Format.formatCurrency(openItemRs.getString("balance")), htmTb.RIGHT, "class=openItem"));
                       out.print(htmTb.endRow());

                       currentLine = currentLine + 2;
                       checkForPageBreak(htmTb, patientRs, envRs, today);
                       
                       if(printOption.equals("O") || printOption.equals("S") || printAllItems) { out.print(getVisitDetails(io, htmTb, openItemRs.getInt("visitid"), currentLine, printOption, today)); }

                       currentLine = currentLine + 2;
                       
                       totalPayorPayments += openItemRs.getDouble("inspayments");
                       totalPatientPayments += openItemRs.getDouble("patpayments");
                       totalPayorAdjustments += openItemRs.getDouble("adjustments");
                       totalPatientAdjustments += openItemRs.getDouble("writeoffs");
                       totalCharges += openItemRs.getDouble("itemcharges");

                   }
               }

               if(hasItems) {
                   out.print(printFooter(io, htmTb, envRs));

                   if(!printOption.equals("L")) { out.print(this.patient.getPatientAging(htmTb, "#ffffff", "#000000", "#e0e0e0", 40, selectedCharges)); }

               }

               patChkCmtPs.setInt(1, patientRs.getInt("id"));
               patChkCmtPs.setString(2, today);
               patChkCmtPs.setInt(3, 99);
               ResultSet patCmtRs = patChkCmtPs.executeQuery();
               if(!patCmtRs.next()) {
                   Comment comment = new Comment(io, "0");
                   comment.setPatientId(patientRs.getInt("id"));
                   comment.setType(99);
                   comment.setDate(today);
                   comment.setComment("Statement Created");
                   comment.update();
               }

               patCmtRs.close();
               patCmtRs = null;

               openItemRs.close();
               patientRs.close();

               openItemRs = null;
               patientRs = null;

           }
           envRs.close();

           envRs = null;

        }
        htmTb = null;
        chgPs = null;
        
        System.gc();
    }

    public  String printHeadings(RWHtmlTable htmTb, ResultSet patientRs, ResultSet envRs, String printOption, String statementDate) throws Exception {
       StringBuffer headings = new StringBuffer();
//       headings.append("<p class=\"page\">&nbsp;&nbsp;</p>");
       if(envRs.getInt("statementheading") == 0) {
           headings.append(htmTb.startTable());
           headings.append(htmTb.startRow());
           headings.append(htmTb.addCell("Statement", htmTb.CENTER, "colspan=3 class=headingItem style=\"height: 30px; font-size: 18;\""));
           headings.append(htmTb.endRow());
           headings.append(htmTb.startRow());
           headings.append(htmTb.addCell(envRs.getString("suppliername"), "width=300 class=headingItem"));
           headings.append(htmTb.addCell("Date:", "class=\"headingLabel\" width=\"150\""));
           headings.append(htmTb.addCell(Format.formatDate(statementDate, "MM/dd/yyyy"), "width=\"150\" class=\"headingItem\""));
           headings.append(htmTb.endRow());
           headings.append(htmTb.startRow());
           headings.append(htmTb.addCell(patientRs.getString("officeaddress"), "width=300 class=headingItem"));
           headings.append(htmTb.addCell("", "width=\"300\" colspan=\"2\""));
           headings.append(htmTb.endRow());
           headings.append(htmTb.startRow());
           headings.append(htmTb.addCell(patientRs.getString("officecsz"), "width=300 class=headingItem"));
           headings.append(htmTb.addCell("Account Number", "width=150 class=headingLabel"));
           headings.append(htmTb.addCell(patientRs.getString("accountnumber"), "width=150 class=headingItem"));
           headings.append(htmTb.endRow());
           headings.append(htmTb.startRow());
           headings.append(htmTb.addCell(Format.formatPhone(patientRs.getString("phone")), "width=300 class=headingItem"));
           headings.append(htmTb.addCell("", "width=\"300\" colspan=\"2\""));
           headings.append(htmTb.endRow());
           headings.append(htmTb.startRow());
           headings.append(htmTb.addCell(patientRs.getString("NPI"), "width=300 class=headingItem"));
           headings.append(htmTb.addCell(patientRs.getString("patientname"), "width=\"300\" colspan=\"2\" class=headingItem"));
           headings.append(htmTb.endRow());
           headings.append(htmTb.startRow());
           headings.append(htmTb.addCell(envRs.getString("taxid"), "width=300 class=headingItem"));
           headings.append(htmTb.addCell(patientRs.getString("patientaddress"), "width=\"300\" colspan=\"2\" class=headingItem"));
           headings.append(htmTb.endRow());
           headings.append(htmTb.startRow());
           headings.append(htmTb.addCell("", "width=300 class=headingItem"));
           headings.append(htmTb.addCell(patientRs.getString("patientcsz"), "width=\"300\" colspan=\"2\" class=headingItem"));
           headings.append(htmTb.endRow());
           headings.append(htmTb.endTable());
       } else if(envRs.getInt("statementheading") == 1) {
           headings.append(htmTb.startTable());
           headings.append(htmTb.startRow());
           headings.append(htmTb.addCell("Patient Name", "width=100 class=headingLabel"));
           headings.append(htmTb.addCell(patientRs.getString("patientname"), "width=250 class=headingItem"));
           headings.append(htmTb.addCell("", "width=50"));
           headings.append(htmTb.addCell("Account Number", "width=150 class=headingLabel"));
           headings.append(htmTb.addCell(patientRs.getString("accountnumber"), "width=300 class=headingItem"));
           headings.append(htmTb.endRow());
           headings.append(htmTb.startRow());
           headings.append(htmTb.addCell("Address", "width=100 class=headingLabel"));
           headings.append(htmTb.addCell(patientRs.getString("patientaddress"), "width=250 class=headingItem"));
           headings.append(htmTb.addCell("", "width=50"));
           headings.append(htmTb.addCell("Doctor Name", "width=150 class=headingLabel"));
           headings.append(htmTb.addCell(patientRs.getString("doctorname"), "width=300 class=headingItem"));
           headings.append(htmTb.endRow());

           headings.append(htmTb.startRow());
           headings.append(htmTb.addCell("", "width=100 class=headingLabel"));
           headings.append(htmTb.addCell(patientRs.getString("patientcsz"), "width=250 class=headingItem"));
           headings.append(htmTb.addCell("", "width=50"));
           headings.append(htmTb.addCell("", "width=150 class=headingLabel"));
           headings.append(htmTb.addCell(patientRs.getString("officeaddress") + "<br>" + patientRs.getString("officecsz"), "width=300 class=headingItem"));
           headings.append(htmTb.endRow());

           headings.append(htmTb.startRow());
           headings.append(htmTb.addCell("&nbsp;&nbsp;", "width=100 class=headingLabel"));
           headings.append(htmTb.addCell("&nbsp;&nbsp;", "width=250 class=headingItem"));
           headings.append(htmTb.addCell("&nbsp;&nbsp;", "width=50"));
           headings.append(htmTb.addCell("NPI", "width=150 class=headingLabel"));
           headings.append(htmTb.addCell(patientRs.getString("NPI"), "width=300 class=headingItem"));
           headings.append(htmTb.endRow());

           headings.append(htmTb.startRow());
           headings.append(htmTb.addCell("&nbsp;&nbsp;", "width=100 class=headingLabel"));
           headings.append(htmTb.addCell("&nbsp;&nbsp;", "width=250 class=headingItem"));
           headings.append(htmTb.addCell("&nbsp;&nbsp;", "width=50"));
           headings.append(htmTb.addCell("Tax ID", "width=150 class=headingLabel"));
           headings.append(htmTb.addCell(envRs.getString("taxid"), "width=300 class=headingItem"));
           headings.append(htmTb.endRow());

           headings.append(htmTb.startRow());
           headings.append(htmTb.addCell("&nbsp;&nbsp;", "width=100 class=headingLabel"));
           headings.append(htmTb.addCell("&nbsp;&nbsp;", "width=250 class=headingItem"));
           headings.append(htmTb.addCell("&nbsp;&nbsp;", "width=50"));
           headings.append(htmTb.addCell("Phone", "width=150 class=headingLabel"));
           headings.append(htmTb.addCell(Format.formatPhone(patientRs.getString("phone")), "width=300 class=headingItem"));
           headings.append(htmTb.endRow());

           headings.append(htmTb.endTable());
       }
       headings.append("<br><br>");

       headings.append(htmTb.startTable("700"));
       headings.append(htmTb.startRow());
       headings.append(htmTb.headingCell("Date", "width=75 class=headingLabel"));
       headings.append(htmTb.headingCell("Items", "width=75 class=headingLabel"));
       headings.append(htmTb.headingCell("Chg Amt", htmTb.RIGHT, "width=90 class=headingLabel"));
       headings.append(htmTb.headingCell("Payor Pmts", htmTb.RIGHT, "width=90 class=headingLabel"));
       headings.append(htmTb.headingCell("Pat Pmts", htmTb.RIGHT, "width=90 class=headingLabel"));
       headings.append(htmTb.headingCell("Payor Adj", htmTb.RIGHT, "width=90 class=headingLabel"));
       headings.append(htmTb.headingCell("Pat Adj", htmTb.RIGHT, "width=90 class=headingLabel"));
       headings.append(htmTb.headingCell("Balance", htmTb.RIGHT, "width=100 class=headingLabel"));
       headings.append(htmTb.endRow());

       headings.append(htmTb.addCell("<hr>", "colspan=\"8\""));

       return headings.toString();
    }

    public String printFooter(RWConnMgr io, RWHtmlTable htmTb, ResultSet envRs) {
        StringBuffer footer = new StringBuffer();

        try {
            String [] addressLines = envRs.getString("supplieraddress").split("\r\n");

            if(envRs.getInt("statementFooter") == 0) {
                out.print(htmTb.startRow());
                out.print(htmTb.addCell("<hr>", "colspan=8"));
                out.print(htmTb.endRow());
                out.print(htmTb.startRow());
                out.print(htmTb.addCell("", "colspan=\"3\""));
                out.print(htmTb.addCell("", "colspan=\"2\""));
                out.print(htmTb.addCell("Total Charges", "colspan=\"2\" style=\"font-weight: bold; font-size: 14;\""));
                out.print(htmTb.addCell(Format.formatCurrency(totalCharges), htmTb.RIGHT, "style=\"font-weight: bold; font-size: 14;\""));
                out.print(htmTb.endRow());
                out.print(htmTb.startRow());
                out.print(htmTb.addCell("", "colspan=\"3\""));
                out.print(htmTb.addCell("", "colspan=\"2\""));
                out.print(htmTb.addCell("Payor Payments", "colspan=\"2\" style=\"font-weight: bold; font-size: 14;\""));
                out.print(htmTb.addCell(Format.formatCurrency(totalPayorPayments), htmTb.RIGHT, "style=\"font-weight: bold; font-size: 14;\""));
                out.print(htmTb.endRow());
                out.print(htmTb.startRow());
                out.print(htmTb.addCell("", "colspan=\"3\""));
                out.print(htmTb.addCell("", "colspan=\"2\""));
                out.print(htmTb.addCell("Patient Payments", "colspan=\"2\" style=\"font-weight: bold; font-size: 14;\""));
                out.print(htmTb.addCell(Format.formatCurrency(totalPatientPayments), htmTb.RIGHT, "style=\"font-weight: bold; font-size: 14;\""));
                out.print(htmTb.endRow());
                out.print(htmTb.startRow());
                out.print(htmTb.addCell("", "colspan=\"3\""));
                out.print(htmTb.addCell("", "colspan=\"2\""));
                out.print(htmTb.addCell("Payor Adjustments", "colspan=\"2\" style=\"font-weight: bold; font-size: 14;\""));
                out.print(htmTb.addCell(Format.formatCurrency(totalPayorAdjustments), htmTb.RIGHT, "style=\"font-weight: bold; font-size: 14;\""));
                out.print(htmTb.endRow());
                out.print(htmTb.startRow());
                out.print(htmTb.addCell("", "colspan=\"3\""));
                out.print(htmTb.addCell("", "colspan=\"2\""));
                out.print(htmTb.addCell("Patient Adjustments", "colspan=\"2\" style=\"font-weight: bold; font-size: 14;\""));
                out.print(htmTb.addCell(Format.formatCurrency(totalPatientAdjustments), htmTb.RIGHT, "style=\"font-weight: bold; font-size: 14;\""));
                out.print(htmTb.endRow());
                out.print(htmTb.startRow());
                out.print(htmTb.addCell("", "colspan=\"3\""));
                out.print(htmTb.addCell("", "colspan=\"2\""));
                out.print(htmTb.addCell("Unapplied Payments", "colspan=\"2\" style=\"font-weight: bold; font-size: 14; background-color: #e0e0e0;\""));
                out.print(htmTb.addCell(Format.formatCurrency(totalUnappliedPayments), htmTb.RIGHT, "style=\"font-weight: bold; font-size: 14; background-color: #e0e0e0;\""));
                out.print(htmTb.endRow());
                out.print(htmTb.startRow());
                out.print(htmTb.addCell("", "colspan=\"3\""));
                out.print(htmTb.addCell("", "colspan=\"2\""));
                out.print(htmTb.addCell("Balance", "colspan=\"2\" style=\"font-weight: bold; font-size: 14;\""));
                out.print(htmTb.addCell(Format.formatCurrency(totalCharges - totalPayorPayments - totalPatientPayments - totalPayorAdjustments - totalPatientAdjustments - totalUnappliedPayments), htmTb.RIGHT, "style=\"border-top: 1px solid black; font-weight: bold; font-size: 14;\""));
                out.print(htmTb.endRow());
                out.print(htmTb.startRow());
                out.print(htmTb.addCell(getDiagnosisCodes(io, htmTb, this.patient.getId(), "Y", selectedCharges), "colspan=8"));
                out.print(htmTb.endRow());
                out.print(htmTb.endTable());
            } else if(envRs.getInt("statementfooter") == 1) {
                out.print(htmTb.startRow());
                out.print(htmTb.addCell("<hr>", "colspan=8"));
                out.print(htmTb.endRow());
                out.print(htmTb.startRow());
//                out.print(htmTb.addCell(""));
                out.print(htmTb.addCell("Send Inquiries/payments to:", "class=\"inquiryAddress\" colspan=\"5\""));
//                out.print(htmTb.addCell(""));
                out.print(htmTb.addCell("Total Charges", "colspan=\"2\" style=\"font-weight: bold; font-size: 14;\""));
                out.print(htmTb.addCell(Format.formatCurrency(totalCharges), htmTb.RIGHT, "style=\"font-weight: bold; font-size: 14;\""));
                out.print(htmTb.endRow());
                out.print(htmTb.startRow());
//                out.print(htmTb.addCell(""));

                out.print(htmTb.startCell("style=\"margin-left: 30px;\" colspan=\"5\" rowspan=\"5\""));
                out.print(htmTb.startTable("100%"));
                out.print(htmTb.startRow());
                out.print(htmTb.addCell(envRs.getString("facilityname"), "class=\"inquiryAddress\""));
                out.print(htmTb.endRow());
                out.print(htmTb.startRow());
                if(addressLines.length>0) {                  
                    out.print(htmTb.addCell(addressLines[0], "class=\"inquiryAddress\""));
                } else {
                    out.print(htmTb.addCell(""));
                }
                out.print(htmTb.startRow());
                out.print(htmTb.endRow());
                if(addressLines.length>1) {
                    out.print(htmTb.addCell(addressLines[1], "class=\"inquiryAddress\""));
                } else {
                    out.print(htmTb.addCell(""));
                }
                out.print(htmTb.startRow());
                out.print(htmTb.endRow());
                if(addressLines.length>2) {
                    out.print(htmTb.addCell(addressLines[2], "class=\"inquiryAddress\""));
                } else {
                    out.print(htmTb.addCell(""));
                }
                out.print(htmTb.endRow());
                out.print(htmTb.startRow());
                if(addressLines.length>3) {
                    out.print(htmTb.addCell(addressLines[3] + "<br/>", "class=\"inquiryAddress\""));
                } else {
                    out.print(htmTb.addCell(""));
                }
                out.print(htmTb.endRow());
                out.print(htmTb.startRow());
                out.print(htmTb.addCell(Format.formatPhone(envRs.getString("supplierphone")) + "<br/>For your convenience, credit card payments can be made by phone", "class=\"inquiryAddress\""));
                out.print(htmTb.endRow());
                out.print(htmTb.endTable());
                out.print(htmTb.endCell());

//                out.print(htmTb.addCell(""));
                out.print(htmTb.addCell("Payor Payments", "colspan=\"2\" style=\"font-weight: bold; font-size: 14;\""));
                out.print(htmTb.addCell(Format.formatCurrency(totalPayorPayments), htmTb.RIGHT, "style=\"font-weight: bold; font-size: 14;\""));
                out.print(htmTb.endRow());
                out.print(htmTb.startRow());
//                out.print(htmTb.addCell(""));
//                out.print(htmTb.addCell("", "colspan=\"2\""));
//                out.print(htmTb.addCell(""));
                out.print(htmTb.addCell("Patient Payments", "colspan=\"2\" style=\"font-weight: bold; font-size: 14;\""));
                out.print(htmTb.addCell(Format.formatCurrency(totalPatientPayments), htmTb.RIGHT, "style=\"font-weight: bold; font-size: 14;\""));
                out.print(htmTb.endRow());
                out.print(htmTb.startRow());
//                out.print(htmTb.addCell(""));
//                out.print(htmTb.addCell("", "colspan=\"2\""));
//                out.print(htmTb.addCell(""));
                out.print(htmTb.addCell("Payor Adjustments", "colspan=\"2\" style=\"font-weight: bold; font-size: 14;\""));
                out.print(htmTb.addCell(Format.formatCurrency(totalPayorAdjustments), htmTb.RIGHT, "style=\"font-weight: bold; font-size: 14;\""));
                out.print(htmTb.endRow());
                out.print(htmTb.startRow());
//                out.print(htmTb.addCell(""));
//                out.print(htmTb.addCell("", "colspan=\"2\""));
//                out.print(htmTb.addCell(""));
                out.print(htmTb.addCell("Patient Adjustments", "colspan=\"2\" style=\"font-weight: bold; font-size: 14;\""));
                out.print(htmTb.addCell(Format.formatCurrency(totalPatientAdjustments), htmTb.RIGHT, "style=\"font-weight: bold; font-size: 14;\""));
                out.print(htmTb.endRow());
                out.print(htmTb.startRow());
//                out.print(htmTb.addCell(""));
//                out.print(htmTb.addCell("", "colspan=\"2\""));
//                out.print(htmTb.addCell(""));
                out.print(htmTb.addCell("Balance", "colspan=\"2\" style=\"font-weight: bold; font-size: 14;\""));
                out.print(htmTb.addCell(Format.formatCurrency(totalCharges - totalPayorPayments - totalPatientPayments - totalPayorAdjustments - totalPatientAdjustments), htmTb.RIGHT, "style=\"border-top: 1px solid black; font-weight: bold; font-size: 14;\""));
                out.print(htmTb.endRow());
                out.print(htmTb.startRow());
                out.print(htmTb.addCell(getDiagnosisCodes(io, htmTb, this.patient.getId(), "Y", selectedCharges), "colspan=8"));
                out.print(htmTb.endRow());
                out.print(htmTb.endTable());
            }
        } catch (Exception ex) {
            Logger.getLogger(BillingStatement.class.getName()).log(Level.SEVERE, null, ex);
        }

        return footer.toString();
    }

    public String printSecondPageHeadings(RWHtmlTable htmTb) {
       StringBuffer headings = new StringBuffer();
       headings.append("<p class=\"page\">&nbsp;&nbsp;</p>");
       headings.append(htmTb.startTable());
       headings.append(htmTb.startRow());
       headings.append(htmTb.addCell("Statement", htmTb.CENTER, "colspan=5 class=headingItem style='height: 30;'"));
       headings.append(htmTb.endRow());

       headings.append(htmTb.endTable());

       headings.append("<br><br>");

       headings.append(htmTb.startTable("700"));
       headings.append(htmTb.startRow());
       headings.append(htmTb.headingCell("Date", "width=75 class=headingLabel"));
       headings.append(htmTb.headingCell("Items", "width=75 class=headingLabel"));
       headings.append(htmTb.headingCell("Chg Amt", htmTb.RIGHT, "width=90 class=headingLabel"));
       headings.append(htmTb.headingCell("Payor Pmts", htmTb.RIGHT, "width=90 class=headingLabel"));
       headings.append(htmTb.headingCell("Pat Pmts", htmTb.RIGHT, "width=90 class=headingLabel"));
       headings.append(htmTb.headingCell("Payor Adj", htmTb.RIGHT, "width=90 class=headingLabel"));
       headings.append(htmTb.headingCell("Pat Adj", htmTb.RIGHT, "width=90 class=headingLabel"));
       headings.append(htmTb.headingCell("Balance", htmTb.RIGHT, "width=100 class=headingLabel"));
       headings.append(htmTb.endRow());

       headings.append(htmTb.addCell("<hr>", "colspan=\"8\""));

       return headings.toString();
    }

    public String getSelectedCharges(RWConnMgr io, HttpServletRequest request) throws Exception {
        StringBuffer si=new StringBuffer();
        boolean selectedItemFound=false;
        for(Enumeration e=request.getParameterNames(); e.hasMoreElements();) {
            String field=(String)e.nextElement();
            if(field.substring(0,3).equals("chk")) {
                if(!selectedItemFound) { si.append(" ("); }
                if(selectedItemFound) { si.append(","); }
                si.append(field.substring(3));
                selectedItemFound=true;
            } 
        }
        if(selectedItemFound) { si.append(") "); }

        ResultSet dosRs = io.opnRS("SELECT id FROM charges where visitid in (select distinct visitid from charges where id IN " + si.toString() + ")");
        si = new StringBuffer();
        while(dosRs.next()) {
            if(si.length() == 0) { si.append("("); } else { si.append(","); }
            si.append(dosRs.getString("id"));
        }
        if(si.length()>0) { si.append(") "); }
        return si.toString();
    }

    public String getSelectedCharges(RWConnMgr io, int patientId, String minDays, String maxDays) {
        StringBuffer si = new StringBuffer();
        String ct = "";
        String pt = "";

        if(complete != null && complete.equals("C")) { ct = "bc.complete and "; }

        if(patientType != null && patientType.equals("C")) {
            ct = "";
            pt = "pi.id is null and ";
        }

        if(patientType != null && complete != null && complete.equals("C") && patientType.equals("A")) {
            ct = "1=case when pi.patientid IS NULL THEN 1 else case when bc.id is not null and bc.complete then 1 else 0 end end and ";
            pt = "";
        }

        if(patientType != null && complete != null && complete.equals("A") && patientType.equals("A")) {
            ct = "";
            pt = "";
        }

        try {
        String chargeQuery = "SELECT DISTINCT vs.id, bc.chargeid " +
                "FROM visits vs " +
                "LEFT JOIN charges vc ON vc.visitid=vs.id " +
                "LEFT JOIN batchcharges bc ON bc.chargeid=vc.id " +
                "left join (SELECT patientid, COUNT(*) AS insCount from patientinsurance group by patientid) pi on vs.patientid=pi.patientid " +
                "WHERE " +
                pt +
                ct +
                "vs.patientid=" + patientId + " AND vs.`date` between DATE_SUB(CURRENT_DATE, INTERVAL " + maxDays + " DAY) and DATE_SUB(CURRENT_DATE, INTERVAL " + minDays + " DAY)";

//            String chargeQuery = "select c.id from charges c left join visits v on v.id=c.visitid " + "WHERE v.`date` between DATE_SUB(CURRENT_DATE, INTERVAL " + maxDays + " DAY) and DATE_SUB(CURRENT_DATE, INTERVAL " + minDays + " DAY) and v.patientid=" + patientId;
            boolean selectedItemFound = false;
            ResultSet lRs = io.opnRS(chargeQuery);
            while (lRs.next()) {
                if (!selectedItemFound) {
                    si.append(" (");
                }
                if (selectedItemFound) {
                    si.append(",");
                }
                si.append(lRs.getString("chargeid"));
                selectedItemFound = true;
            }
            if (selectedItemFound) {
                si.append(") ");
            }

            lRs.close();
            lRs = null;
            System.gc();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return si.toString();
    }

    public String getSelectedCharges(RWConnMgr io, int patientId, boolean printAll) {
        StringBuffer si = new StringBuffer();
        String ct = "bc.chargeid is not null and ";
        String pt = "";

        if(printAll) { ct=""; }

        try {
        String chargeQuery = "SELECT DISTINCT vs.id, ";
                if(printAll) {
                    chargeQuery += "vc.id as chargeid ";
                } else {
                    chargeQuery += "bc.chargeid ";
                }
                chargeQuery += "FROM visits vs " +
                "LEFT JOIN charges vc ON vc.visitid=vs.id ";
                if(patient.hasInsurance() && !printAll) { chargeQuery += "LEFT JOIN batchcharges bc ON bc.chargeid=vc.id "; }
                chargeQuery += "left join (SELECT patientid, COUNT(*) AS insCount from patientinsurance group by patientid) pi on vs.patientid=pi.patientid " +
                "WHERE " +
                pt +
                ct +
                "vs.patientid=" + patientId;

            boolean selectedItemFound = false;
            ResultSet lRs = io.opnRS(chargeQuery);
            while (lRs.next()) {
                if (!selectedItemFound) {
                    si.append(" (");
                }
                if (selectedItemFound) {
                    si.append(",");
                }

                si.append(lRs.getString("chargeid"));
                selectedItemFound = true;

            }
            if (selectedItemFound) {
                si.append(") ");
            }

            lRs.close();
            lRs = null;
            System.gc();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return si.toString();
    }

    public String getVisitDetails(RWConnMgr io, RWHtmlTable htmTb, int visitId, int currentLine, String printOption, String statementDate) throws Exception {
        StringBuffer d = new StringBuffer();
        String visitQuery="SELECT c.id, CONCAT(i.code,' - ', i.description) AS description, c.quantity, c.quantity*c.chargeamount AS chargeamount, " +
                "IFNULL(Payments,0) AS Payments, (c.Quantity*c.ChargeAmount)-IFNULL(Payments,0) AS Balance, IFNULL(r.name, 'Office') as name, comments  " +
                "FROM charges c " +
                "LEFT JOIN items i on i.id=c.itemid " +
                "LEFT JOIN resources r ON r.id=c.resourceid " +
                "LEFT JOIN (SELECT chargeid, SUM(amount) AS Payments FROM payments GROUP BY chargeid) p on p.chargeid=c.id " +
                "WHERE c.visitid=" + visitId;

        if(this.patient.hasInsurance() && !printOption.equals("S")) { visitQuery += " AND c.id IN (SELECT DISTINCT chargeid FROM batchcharges) "; }
        visitQuery += " ORDER BY c.id";
        d.append(htmTb.startRow());
        d.append(htmTb.startCell("colspan=\"8\""));

        htmTb.setCellVAlign("bottom");
        d.append(htmTb.startTable());
        d.append(htmTb.startRow("style=\"height: 15; font-weight: bold;\""));
        d.append(htmTb.addCell("Procedure", "width=\"400\""));
        d.append(htmTb.addCell("Qty", htmTb.CENTER, "width=\"100\""));
        d.append(htmTb.addCell("Charge", htmTb.RIGHT, "width=\"100\""));
        d.append(htmTb.addCell("Balance", htmTb.RIGHT, "width=\"100\""));
        d.append(htmTb.endRow());

        currentLine ++;
        checkForPageBreak(htmTb, null, null, statementDate);

        htmTb.setCellVAlign("top");

        ResultSet chargeRs=io.opnRS(visitQuery);
        while(chargeRs.next()) {
            d.append(htmTb.startRow("style=\"background-color: #cccccc;\""));
            d.append(htmTb.addCell(chargeRs.getString("name") + " - " + chargeRs.getString("description")));
            d.append(htmTb.addCell(""+chargeRs.getInt("quantity"), htmTb.CENTER));
            d.append(htmTb.addCell(Format.formatCurrency(chargeRs.getString("chargeamount")), htmTb.RIGHT));
            d.append(htmTb.addCell(Format.formatCurrency(chargeRs.getString("balance")), htmTb.RIGHT));
            d.append(htmTb.endRow());

            currentLine ++;

            if(chargeRs.getString("comments") != null && !chargeRs.getString("comments").equals("")) {
                d.append(htmTb.startRow("style=\"background-color: #cccccc;\""));
                d.append(htmTb.addCell(chargeRs.getString("comments"), "colspan=4"));
                d.append(htmTb.endRow());
                currentLine ++;
                checkForPageBreak(htmTb, null, null, statementDate);
            }

            checkForPageBreak(htmTb, null, null, statementDate);

            d.append(getPaymentsForCharge(io, htmTb, chargeRs.getInt("id"), currentLine, statementDate));
        }
        chargeRs.close();
        chargeRs = null;

        d.append(htmTb.startRow("style=\"height: 15;\""));
        d.append(htmTb.addCell(""));
        d.append(htmTb.endRow());

        currentLine ++;
        checkForPageBreak(htmTb, null, null, statementDate);

        d.append(htmTb.endTable());

        d.append(htmTb.endCell());
        d.append(htmTb.endRow());

        currentLine ++;
        checkForPageBreak(htmTb, null, null, statementDate);
        
        return d.toString();
    }

    public String getPaymentsForCharge(RWConnMgr io, RWHtmlTable htmTb, int chargeId, int currentLine, String statementDate) throws Exception {
        StringBuffer pc=new StringBuffer();
        boolean paymentsFound = false;
        String paymentQuery="SELECT 0 AS sequence, charges.id, CASE WHEN payments.id IS NULL THEN '' ELSE DATE_FORMAT(payments.`date`,'%m/%d/%y') END AS paymentdate, " +
                "CASE WHEN payments.id IS NULL THEN '' ELSE payments.checknumber END AS checknumber, CASE WHEN payments.id IS NULL THEN '' ELSE payments.amount END AS paymentamount, " +
                "'Cash' as name " +
                "FROM charges " +
                "LEFT JOIN payments ON charges.id=payments.chargeid " +
                "LEFT JOIN items ON items.id=charges.itemid " +
                "WHERE charges.id=" + chargeId + "  AND payments.provider=0 " +
                "UNION " +
                "SELECT 1 AS sequence, charges.id, CASE WHEN payments.id IS NULL THEN '' ELSE DATE_FORMAT(payments.`date`,'%m/%d/%y') END AS paymentdate, " +
                "CASE WHEN payments.id IS NULL THEN '' ELSE payments.checknumber END AS checknumber, CASE WHEN payments.id IS NULL THEN '' ELSE payments.amount END AS paymentamount, " +
                "providers.name " +
                "FROM charges " +
                "LEFT JOIN payments ON charges.id=payments.chargeid " +
                "LEFT JOIN items ON items.id=charges.itemid " +
                "LEFT JOIN providers ON providers.id=payments.provider " +
                "WHERE charges.id=" + chargeId + " AND NOT providers.reserved " +
                "UNION " +
                "SELECT 2 AS sequence, charges.id,CASE WHEN payments.id IS NULL THEN '' ELSE DATE_FORMAT(payments.`date`,'%m/%d/%y') END AS paymentdate," +
                "CASE WHEN payments.id IS NULL THEN '' ELSE payments.checknumber END AS checknumber,CASE WHEN payments.id IS NULL THEN '' ELSE payments.amount END AS paymentamount," +
                "providers.name " +
                "FROM charges " +
                "LEFT JOIN payments ON charges.id=payments.chargeid " +
                "LEFT JOIN items ON items.id=charges.itemid " +
                "LEFT JOIN providers ON providers.id=payments.provider " +
                "WHERE charges.id=" + chargeId + " AND providers.reserved " +
                "UNION " +
                "SELECT DISTINCT 3 AS sequence, charges.id, CASE WHEN eobexceptions.id IS NULL THEN '' ELSE DATE_FORMAT(eobexceptions.`date`,'%m/%d/%y') END AS paymentdate, " +
                "'' AS checknumber, eobexceptions.amount AS paymentamount, eobreasons.description AS name " +
                "FROM charges " +
                "LEFT JOIN items ON items.id=charges.itemid " +
                "LEFT JOIN eobexceptions ON charges.id=eobexceptions.chargeid " +
                "LEFT JOIN eobreasons ON eobexceptions.reasonid=eobreasons.id " +
                "WHERE charges.id=" + chargeId + " AND eobreasons.id IS NOT NULL AND eobreasons.`type`<>'A' " +
                "ORDER BY id, sequence, `paymentdate`, checknumber, name";

        pc.append(htmTb.startRow("style=\"background-color: #e0e0e0;\""));
        pc.append(htmTb.startCell(htmTb.CENTER, "colspan=\"8\""));

        htmTb.setCellVAlign("bottom");
        pc.append(htmTb.startTable("600"));
        pc.append(htmTb.startRow("style=\"height: 15; background-color: #e0e0e0; font-weight: bold;\""));
        pc.append(htmTb.addCell("Date", htmTb.CENTER, "width=\"100\""));
        pc.append(htmTb.addCell("Payor Name", htmTb.CENTER, "width=\"400\""));
        pc.append(htmTb.addCell("Amount", htmTb.RIGHT, "width=\"100\""));
        pc.append(htmTb.endRow());

        currentLine ++;
        checkForPageBreak(htmTb, null, null, statementDate);

        htmTb.setCellVAlign("top");

        ResultSet pmtRs=io.opnRS(paymentQuery);
        while(pmtRs.next()) {
            pc.append(htmTb.startRow());
            pc.append(htmTb.addCell(Format.formatDate(pmtRs.getString("paymentdate"), "MM/dd/yy"), htmTb.CENTER));
            pc.append(htmTb.addCell(pmtRs.getString("name")));
            pc.append(htmTb.addCell(Format.formatCurrency(pmtRs.getDouble("paymentamount")), htmTb.RIGHT));
            pc.append(htmTb.endRow());

            currentLine ++;
            checkForPageBreak(htmTb, null, null, statementDate);

            paymentsFound=true;
        }
        pmtRs.close();
        pmtRs = null;
        pc.append(htmTb.endTable());

        pc.append(htmTb.endCell());
        pc.append(htmTb.endRow());

        currentLine ++;
        checkForPageBreak(htmTb, null, null, statementDate);
        
        if(!paymentsFound) { pc.delete(0, pc.length()); }

        System.gc();

        return pc.toString();
    }

    public void checkForPageBreak(RWHtmlTable htmTb, ResultSet patientRs, ResultSet envRs, String statementDate) throws Exception {
        if(currentLine>linesPerPage || currPage == 1) {
            if(currPage != 1) {
                out.print(htmTb.startRow());
                out.print(htmTb.addCell("<hr>", "colspan=8"));
                out.print(htmTb.endRow());
                out.print(htmTb.endTable());
                out.print("<p style='page-break-before: always'>\n");
            }
            if(currPage == 1) {
                out.print(printHeadings(htmTb, patientRs, envRs, printOption, statementDate));
                currentLine=1;
            } else {
                out.print(printSecondPageHeadings(htmTb));
                currentLine=1;
            }
            currPage ++;
        } else {
            currentLine ++;
        }
    }

    public String getDiagnosisCodes(RWConnMgr io, RWHtmlTable htmTb, int patientId, String printDetails, String selectedCharges) throws Exception {
        String specificChargeInfo = "";
        if(!selectedCharges.equals("")) { specificChargeInfo = " AND id IN " + selectedCharges; }
        String symptomQuery = "(SELECT DISTINCT conditionid FROM visits WHERE id IN (SELECT DISTINCT visitid FROM patientchargesummary aa WHERE patientid=" + patientId + specificChargeInfo + "))";

        StringBuffer dc = new StringBuffer();
        int currentColumn = 0;
        if(printDetails.equals("Y")) {
            ResultSet lRs = io.opnRS("SELECT * FROM patientsymptoms a left join diagnosiscodes b on b.id=a.diagnosisid where patientid=" + patientId + " AND conditionid in " + symptomQuery  + " order by sequence");
            if(lRs.next()) {
                dc.append(htmTb.startTable("100%"));
                dc.append(htmTb.startRow());
                dc.append(htmTb.addCell("Diagnosis Codes", htmTb.CENTER, "class=diagnosisHeader colspan=4"));
                dc.append(htmTb.endRow());
            }
            lRs.beforeFirst();
            while(lRs.next()) {
                if(currentColumn == 0) { dc.append(htmTb.startRow()); }
                dc.append(htmTb.addCell(lRs.getString("code"), "width=50 class=diagnosisCodes"));
                dc.append(htmTb.addCell(lRs.getString("description"), "width=250 class=diagnosisCodes"));
                if(currentColumn == 1) { dc.append(htmTb.endRow()); currentColumn = -1; }
                currentColumn ++;
            }

            lRs.close();
            lRs=null;
            System.gc();

            if(currentColumn == 1) { dc.append(htmTb.addCell("", "class=diagnosisCodes colspan=2")); dc.append(htmTb.endRow()); }

            if(dc.length()>0) { dc.append(htmTb.endTable()); }
        }
        return dc.toString();
    }
}
