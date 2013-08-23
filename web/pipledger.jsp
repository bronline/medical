<%-- 
    Document   : pipledger
    Created on : Jul 18, 2011, 11:38:14 AM
    Author     : rwandell
--%>
<%@ include file="globalvariables.jsp" %>
<style>
    .headingLabel { font-size: 14px; }
    .headingItem { font-size: 14px; font-weight: bold; }
    .openItem { font-size: 12px; }
</style>
<%
    String printOption=request.getParameter("printOption");
    String selectedCharges = "";
    boolean printAllItems = false;
    RWHtmlTable htmTb=new RWHtmlTable("700", "0");
    htmTb.replaceNewLineChar(false);

    double totalPayments=0.0;
    double totalCharges=0.0;
    double totalWriteOff=0.0;
    double totalPatPayments=0.0;

    printAllItems=true;

    if(patient.getId() != 0) {
        String balanceQuery = "SELECT v.id, v.`date`, i.description, CAST(c.quantity AS DECIMAL(8,2)) AS Quantity, " +
                "c.chargeamount, c.quantity*c.chargeamount AS ExtendedAmount, IFNULL(inspayments,0) as InsPayments, IFNULL(patpayments,0) AS PatPayments, " +
                "IFNULL(Adjustments,0) AS Adjustments,  IFNULL(WriteOffs,0) AS WriteOffs, " +
                "(c.chargeamount*c.quantity)-IfNull(inspayments,0)-ifnull(patpayments,0)-ifnull(writeoffs,0)-ifnull(adjustments,0) AS balance " +
                "FROM visits v " +
                "LEFT JOIN charges c ON c.visitid=v.id " +
                "LEFT JOIN items i ON i.id=c.itemid " +
                "LEFT JOIN (SELECT chargeid, SUM(amount) AS Inspayments FROM payments p LEFT JOIN providers pp ON p.provider=pp.id WHERE NOT pp.reserved GROUP BY chargeid) AS ins ON ins.chargeid=c.id " +
                "LEFT JOIN (SELECT chargeid, SUM(amount) AS PatPayments FROM payments p LEFT JOIN providers pp ON p.provider=pp.id WHERE (pp.reserved AND pp.id<>10 AND NOT pp.isadjustment) OR pp.id IS NULL GROUP BY chargeid) AS pat ON pat.chargeid=c.id " +
                "LEFT JOIN (SELECT chargeid, SUM(amount) AS Adjustments FROM payments p LEFT JOIN providers pp ON p.provider=pp.id WHERE pp.reserved AND pp.id<>10 AND pp.isadjustment GROUP BY chargeid) AS adj ON adj.chargeid=c.id " +
                "LEFT JOIN (SELECT chargeid, SUM(amount) AS WriteOffs FROM payments p LEFT JOIN providers pp ON p.provider=pp.id WHERE pp.reserved AND pp.id=10 GROUP BY chargeid) AS wo ON wo.chargeid=c.id " +
                "WHERE v.patientid=" + patient.getId() + getSelectedCharges(request);

       ResultSet patientRs=io.opnRS("select * from soapnoteheader where id=" + patient.getId());
       ResultSet openItemRs=io.opnRS(balanceQuery);
       ResultSet envRs = io.opnRS("select * from environment");

       envRs.next();

       double balance=0.0;
       int linesPerPage=25;
       int currentLine=1;
       int currPage=1;

       if(patientRs.next()) {
           while(openItemRs.next()) {
               if(currentLine>linesPerPage || currPage == 1) {
                   if(currPage != 1) {
                       out.print(htmTb.startRow());
                       out.print(htmTb.addCell("<hr>", "colspan=8"));
                       out.print(htmTb.endRow());
                       out.print(htmTb.endTable());
                       out.print("<p style='page-break-before: always'>\n");
                   }
                   out.print(printHeadings(htmTb, patientRs, envRs, printOption));
                   currPage ++;
                   currentLine=1;
               }

               totalCharges += openItemRs.getDouble("ExtendedAmount");
               totalPayments += openItemRs.getDouble("InsPayments");
               totalWriteOff += openItemRs.getDouble("WriteOffs");
               totalPatPayments += openItemRs.getDouble("PatPayments");

               balance += openItemRs.getDouble("balance");
               if(openItemRs.getDouble("balance") != 0.0 || printAllItems || printOption.equals("S")) {
                   out.print(htmTb.startRow());
                   out.print(htmTb.addCell(tools.utils.Format.formatDate(openItemRs.getString("date"), "MM/dd/yyyy"), htmTb.CENTER, "class=openItem"));
                   out.print(htmTb.addCell(openItemRs.getString("description"), "class=openItem"));
                   out.print(htmTb.addCell(openItemRs.getString("quantity"),htmTb.RIGHT, "class=openItem"));
//                   out.print(htmTb.addCell(tools.utils.Format.formatCurrency(openItemRs.getString("chargeamount")), htmTb.RIGHT, "class=openItem"));
                   out.print(htmTb.addCell(tools.utils.Format.formatCurrency(openItemRs.getString("ExtendedAmount")), htmTb.RIGHT, "class=openItem"));
                   out.print(htmTb.addCell(tools.utils.Format.formatCurrency(openItemRs.getString("InsPayments")), htmTb.RIGHT, "class=openItem"));
                   out.print(htmTb.addCell(tools.utils.Format.formatCurrency(openItemRs.getString("WriteOffs")), htmTb.RIGHT, "class=openItem"));
                   out.print(htmTb.addCell(tools.utils.Format.formatCurrency(openItemRs.getString("PatPayments")), htmTb.RIGHT, "class=openItem"));
                   out.print(htmTb.addCell(tools.utils.Format.formatCurrency(openItemRs.getString("balance")), htmTb.RIGHT, "class=openItem"));
                   out.print(htmTb.endRow());
                   currentLine ++;
               }
           }

           out.print(htmTb.startRow());
           out.print(htmTb.addCell("<hr>", "colspan=8"));
           out.print(htmTb.endRow());
           out.print(htmTb.endTable());

           out.print(htmTb.startTable());
           out.print(htmTb.startRow());
           out.print(htmTb.headingCell("Charges", "width=\"12.5%\" class=headingLabel"));
           out.print(htmTb.addCell(tools.utils.Format.formatCurrency(totalCharges), htmTb.RIGHT, "width=\"12.5%\" style=\"border: 1px solid black;\" class=openItem"));
           out.print(htmTb.headingCell("Ins Pmts", "width=\"12.5%\" class=headingLabel"));
           out.print(htmTb.addCell(tools.utils.Format.formatCurrency(totalPayments), htmTb.RIGHT, "width=\"12.5%\" style=\"border: 1px solid black;\" class=openItem"));
           out.print(htmTb.headingCell("Write-off", "width=\"12.5%\" class=headingLabel"));
           out.print(htmTb.addCell(tools.utils.Format.formatCurrency(totalWriteOff), htmTb.RIGHT, "width=\"12.5%\" style=\"border: 1px solid black;\" class=openItem"));
           out.print(htmTb.headingCell("Pat Pmts", "width=\"12.5%\" class=headingLabel"));
           out.print(htmTb.addCell(tools.utils.Format.formatCurrency(totalPatPayments), htmTb.RIGHT, "width=\"12.5%\" style=\"border: 1px solid black;\" class=openItem"));
           out.print(htmTb.endRow());
           out.print(htmTb.endTable());

/*
           out.print(htmTb.headingCell("Balance", "class=headingLabel"));
           out.print(htmTb.addCell(tools.utils.Format.formatCurrency(totalCharges), htmTb.RIGHT, "width=\"25%\" style=\"border: 1px solid black;\" class=openItem"));
           out.print(htmTb.endRow());

           out.print(htmTb.startRow());
           out.print(htmTb.addCell(getDiagnosisCodes(io, htmTb, patient.getId(), "Y", selectedCharges), "colspan=8"));

           out.print(htmTb.endRow());

           out.print(htmTb.endTable());
*/
           out.print(patient.getPatientAging(htmTb, "#e0e0e0", 40, selectedCharges));

           openItemRs.close();
           patientRs.close();

       }
    }
%>
<%! public String printHeadings(RWHtmlTable htmTb, ResultSet patientRs, ResultSet envRs, String printOption) throws Exception {
       StringBuffer headings = new StringBuffer();
       headings.append(htmTb.startTable());
       headings.append(htmTb.startRow());
       headings.append(htmTb.addCell("Statement", htmTb.CENTER, "colspan=5 class=headingItem style='height: 30;'"));
       headings.append(htmTb.endRow());
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

       headings.append("<br><br>");

       headings.append(htmTb.startTable("700"));

       headings.append(htmTb.startRow());
       headings.append(htmTb.headingCell("", "width=75 class=headingLabel"));
       headings.append(htmTb.headingCell("", "width=300 class=headingLabel"));
       headings.append(htmTb.headingCell("", htmTb.RIGHT, "width=50 class=headingLabel"));
       headings.append(htmTb.headingCell("Charge", htmTb.RIGHT, "width=75 class=headingLabel"));
       headings.append(htmTb.headingCell("Ins", htmTb.RIGHT, "width=75 class=headingLabel"));
       headings.append(htmTb.headingCell("Write", htmTb.RIGHT, "width=75 class=headingLabel"));
       headings.append(htmTb.headingCell("Pat", htmTb.RIGHT, "width=75 class=headingLabel"));
       headings.append(htmTb.headingCell("", htmTb.RIGHT, "width=75 class=headingLabel"));
       headings.append(htmTb.endRow());

       headings.append(htmTb.startRow());
       headings.append(htmTb.headingCell("Date", "width=75 class=headingLabel"));
       headings.append(htmTb.headingCell("Charge Description", "width=300 class=headingLabel"));
       headings.append(htmTb.headingCell("Qty", htmTb.RIGHT, "width=50 class=headingLabel"));
       headings.append(htmTb.headingCell("Amount", htmTb.RIGHT, "width=75 class=headingLabel"));
       headings.append(htmTb.headingCell("Pmts", htmTb.RIGHT, "width=75 class=headingLabel"));
       headings.append(htmTb.headingCell("Off", htmTb.RIGHT, "width=75 class=headingLabel"));
       headings.append(htmTb.headingCell("Pmts", htmTb.RIGHT, "width=75 class=headingLabel"));
       headings.append(htmTb.headingCell("Balance", htmTb.RIGHT, "width=75 class=headingLabel"));
       headings.append(htmTb.endRow());

       headings.append(htmTb.addCell("<hr>", "colspan=8"));

       return headings.toString();
    }

    public String getSelectedCharges(HttpServletRequest request) {
        StringBuffer si=new StringBuffer();
        boolean selectedItemFound=false;
        for(Enumeration e=request.getParameterNames(); e.hasMoreElements();) {
            String field=(String)e.nextElement();
            if(field.substring(0,3).equals("chk")) {
                if(!selectedItemFound) { si.append(" and c.id in("); }
                if(selectedItemFound) { si.append(","); }
                si.append(field.substring(3));
                selectedItemFound=true;
            }
        }
        if(selectedItemFound) { si.append(") "); }
        return si.toString();
    }

    public String getHeadersForPayments(RWConnMgr io, RWHtmlTable htmTb) throws Exception {
        StringBuffer pc=new StringBuffer();
        pc.append(htmTb.startRow("style='background: #e0e0e0;'"));
        pc.append(htmTb.addCell(""));
        pc.append(htmTb.startCell(htmTb.LEFT));

        pc.append(htmTb.startTable("100%"));
        pc.append(htmTb.startRow());
        pc.append(htmTb.addCell("<b>Date</b>", htmTb.CENTER, "width='20%' "));
        pc.append(htmTb.addCell("<b>Source</b>", "width='60%' "));
        pc.append(htmTb.addCell("<b>Amount</b>",htmTb.RIGHT, "width='20%' "));
        pc.append(htmTb.endCell());
        pc.append(htmTb.endRow());
        pc.append(htmTb.endTable());

        pc.append(htmTb.addCell("", "colspan=4"));
        pc.append(htmTb.endRow());

        return pc.toString();
    }

    public String getDiagnosisCodes(RWConnMgr io, RWHtmlTable htmTb, int patientId, String printDetails, String selectedCharges) throws Exception {
        String symptomQuery = "(SELECT DISTINCT conditionid FROM visits WHERE id IN (SELECT DISTINCT visitid FROM patientchargesummary c WHERE patientid=" + patientId + selectedCharges + "))";

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

            if(currentColumn == 1) { dc.append(htmTb.addCell("", "class=diagnosisCodes colspan=2")); dc.append(htmTb.endRow()); }

            if(dc.length()>0) { dc.append(htmTb.endTable()); }
        }
        return dc.toString();
    }
%>