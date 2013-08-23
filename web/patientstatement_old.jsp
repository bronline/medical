<%@ include file="globalvariables.jsp" %>
<style>
    .headingLabel { font-size: 14px; background-color: white; color: black;}
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

    if(printOption != null && (printOption.equals("A") || printOption.equals("L"))) { printAllItems=true; }
    if(printOption != null && printOption.equals("S")) { selectedCharges=getSelectedCharges(request); }
    if(printOption != null && printOption.equals("I")) { selectedCharges=getInsuranceCharges(io, patient.getId()); }
    if(printOption != null && printOption.equals("C")) { selectedCharges=getNonInsuranceCharges(io, patient.getId()); }
    if(patient.getId() != 0) {
        String balanceQuery = "select a.id , a.date , a.description , a.chargeamount, CAST(a.quantity AS decimal(5,2)) as quantity, " +
                              "ifnull(e.paidamount,0) AS paidamount, cast(((a.chargeamount) - ifnull(e.paidamount,0)) as decimal(10,2)) AS balance, " +
                              "a.patientid AS patientid from " +
                              "(SELECT * FROM patientchargesummary c where c.patientid=" + patient.getId() + selectedCharges + ") a " +
                              "left join paidamounts e on a.id = e.chargeid";

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
                       out.print(htmTb.addCell("<hr>", "colspan=6"));
                       out.print(htmTb.endRow());
                       out.print(htmTb.endTable());
                       out.print("<p style='page-break-before: always'>\n");
                   }
                   out.print(printHeadings(htmTb, patientRs, envRs, printOption));
                   currPage ++;
                   currentLine=1;
               }

               totalCharges += openItemRs.getDouble("chargeamount");
               if(!printOption.equals("L")) { totalPayments += openItemRs.getDouble("paidamount"); }

               balance += openItemRs.getDouble("balance");
               if(openItemRs.getDouble("balance") != 0.0 || printAllItems || printOption.equals("S")) {
                   out.print(htmTb.startRow());
                   out.print(htmTb.addCell(tools.utils.Format.formatDate(openItemRs.getString("date"), "MM/dd/yyyy"), htmTb.CENTER, "class=openItem"));
                   out.print(htmTb.addCell(openItemRs.getString("description"), "class=openItem"));
                   out.print(htmTb.addCell(openItemRs.getString("quantity"),htmTb.RIGHT, "class=openItem"));
                   out.print(htmTb.addCell(tools.utils.Format.formatCurrency(openItemRs.getString("chargeamount")), htmTb.RIGHT, "class=openItem"));
                   if(!printOption.equals("L")) { out.print(htmTb.addCell(tools.utils.Format.formatCurrency(openItemRs.getString("paidamount")), htmTb.RIGHT, "class=openItem")); }
                   if(!printOption.equals("L")) { out.print(htmTb.addCell(tools.utils.Format.formatCurrency(openItemRs.getString("balance")), htmTb.RIGHT, "class=openItem")); }
                   if(!printOption.equals("L")) { out.print(getPaymentsForCharge(io, htmTb, openItemRs.getInt("id"))); }
                   out.print(htmTb.endRow());
                   currentLine ++;
               }
           }

           out.print(htmTb.startRow());
           out.print(htmTb.addCell("<hr>", "colspan=6"));
           out.print(htmTb.endRow());

           out.print(htmTb.startRow());
           if(!printOption.equals("L")) {
               out.print("<td colspan=4>");
               out.print("<table width=\"500\">");
               out.print(htmTb.startRow());
               out.print(htmTb.headingCell("Charges", "width=\"25%\" class=headingLabel"));
               out.print(htmTb.addCell(tools.utils.Format.formatCurrency(totalCharges), htmTb.RIGHT, "width=\"25%\" style=\"border: 1px solid black;\" class=openItem"));
               out.print(htmTb.headingCell("Payments", "width=\"25%\" class=headingLabel"));
               out.print(htmTb.addCell(tools.utils.Format.formatCurrency(totalPayments), htmTb.RIGHT, "width=\"25%\" style=\"border: 1px solid black;\" class=openItem"));
               out.print(htmTb.endRow());
               out.print(htmTb.endTable());
           } else {
               out.print("<td colspan=2>");
           }
           out.print(htmTb.endCell());
           out.print(htmTb.headingCell("Balance", "class=headingLabel"));
           if(!printOption.equals("L")) { 
               out.print(htmTb.addCell(tools.utils.Format.formatCurrency(balance), htmTb.RIGHT, "style=\"border: 1px solid black;\" class=openItem"));
           } else {
               out.print(htmTb.addCell(tools.utils.Format.formatCurrency(totalCharges), htmTb.RIGHT, "width=\"25%\" style=\"border: 1px solid black;\" class=openItem"));
           }
           out.print(htmTb.endRow());

           out.print(htmTb.startRow());
           if(!printOption.equals("L")) { 
               out.print(htmTb.addCell(getDiagnosisCodes(io, htmTb, patient.getId(), "Y", selectedCharges), "colspan=6"));
           } else {
               out.print(htmTb.addCell(getDiagnosisCodes(io, htmTb, patient.getId(), "Y", selectedCharges), "colspan=4"));
           }
           out.print(htmTb.endRow());

           out.print(htmTb.endTable());

           if(!printOption.equals("L")) { out.print(patient.getPatientAging(htmTb, "#ffffff", "#000000", "#e0e0e0", 40, selectedCharges)); }

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
       headings.append(htmTb.headingCell("Date", "width=75 class=headingLabel"));
       if(!printOption.equals("L")) {
           headings.append(htmTb.headingCell("Charge Description", "width=300 class=headingLabel"));
       } else {
           headings.append(htmTb.headingCell("Charge Description", "width=450 class=headingLabel"));
       }
       headings.append(htmTb.headingCell("Qty", htmTb.RIGHT, "width=50 class=headingLabel"));
       headings.append(htmTb.headingCell("Charge", htmTb.RIGHT, "width=75 class=headingLabel"));
       if(!printOption.equals("L")) {
           headings.append(htmTb.headingCell("Adj Amt", htmTb.RIGHT, "width=75 class=headingLabel"));
           headings.append(htmTb.headingCell("Balance", htmTb.RIGHT, "width=75 class=headingLabel"));
       }
       headings.append(htmTb.endRow());

       if(!printOption.equals("L")) {
           headings.append(htmTb.addCell("<hr>", "colspan=6"));
       } else {
           headings.append(htmTb.addCell("<hr>", "colspan=4"));
       }
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

    public String getInsuranceCharges(RWConnMgr io, int patientId) throws Exception {
        StringBuffer insuranceCharges=new StringBuffer();
        ResultSet lRs=io.opnRS("select batchcharges.chargeid from batchcharges left join batches on batches.id=batchcharges.batchid left join providers on providers.id=batches.provider left join payments on payments.chargeid=batchcharges.chargeid where payments.patientid=" + patientId + " and not reserved");
        while(lRs.next()) {
            if(lRs.getRow() == 1) { insuranceCharges.append(" and id in("); } else { insuranceCharges.append(","); }
            insuranceCharges.append(lRs.getString("chargeid"));
        }
        if(insuranceCharges.length() != 0) { insuranceCharges.append(") "); }
        lRs.close();
        return insuranceCharges.toString();
    }

    public String getNonInsuranceCharges(RWConnMgr io, int patientId) throws Exception {
        StringBuffer insuranceCharges=new StringBuffer();
        ResultSet lRs=io.opnRS("select batchcharges.chargeid from batchcharges left join charges on charges.id=batchcharges.chargeid left join visits on visits.id=charges.visitid where visits.patientid=" + patientId);
        while(lRs.next()) {
            if(lRs.getRow() == 1) { insuranceCharges.append(" and id not in("); } else { insuranceCharges.append(","); }
            insuranceCharges.append(lRs.getString("chargeid"));
        }
        if(insuranceCharges.length() != 0) { insuranceCharges.append(") "); }
        lRs.close();
        return insuranceCharges.toString();
    }

    public String getPaymentsForCharge(RWConnMgr io, RWHtmlTable htmTb, int chargeId) throws Exception {
        StringBuffer pc=new StringBuffer();
        ResultSet lRs=io.opnRS("select * from payments left join providers on payments.provider=providers.id where payments.chargeid=" + chargeId);

        while(lRs.next()) {
            String providerName=lRs.getString("name");

            if(lRs.getRow()==1) { pc.append(getHeadersForPayments(io, htmTb)); }
            pc.append(htmTb.startRow("style='background: #e0e0e0;'"));
            pc.append(htmTb.addCell(""));
            pc.append(htmTb.startCell(htmTb.LEFT));

            if(providerName == null) { providerName="Cash"; }

            pc.append(htmTb.startTable("100%"));
            pc.append(htmTb.startRow());
            pc.append(htmTb.addCell(Format.formatDate(lRs.getString("date"), "MM/dd/yyyy"), htmTb.CENTER, "width='20%'"));
            pc.append(htmTb.addCell(providerName, "width='60%'"));
            pc.append(htmTb.addCell(Format.formatCurrency(lRs.getDouble("amount")),htmTb.RIGHT, "width='20%'"));
            pc.append(htmTb.endCell());
            pc.append(htmTb.endRow());
            pc.append(htmTb.endTable());

            pc.append(htmTb.addCell("", "colspan=4"));
            pc.append(htmTb.endRow());
        }
        lRs.close();

        return pc.toString();
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