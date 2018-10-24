<%-- 
    Document   : patientstatement
    Created on : Aug 10, 2011, 1:01:31 PM
    Author     : Randy Wandell
--%>
<%@ include file="globalvariables.jsp" %>
<style>
    .headingLabel { font-size: 14px; background-color: white; color: black;}
    .headingItem { font-size: 14px; font-weight: bold; }
    .openItem { font-size: 12px; }
</style>
<%
    BillingStatement billingStm = new BillingStatement();
    RWHtmlTable htmTb=new RWHtmlTable("700", "0");

    billingStm.linesPerPage=70;
    billingStm.getHtml(io, htmTb, request, response, patient);
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

    public String getSelectedCharges(HttpServletRequest request) {
        String selectedItems="";
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
        return si.toString();
    }

    public String getVisitDetails(RWConnMgr io, RWHtmlTable htmTb, int visitId) throws Exception {
        StringBuffer d = new StringBuffer();
        String visitQuery="SELECT c.id, CONCAT(i.code,' - ', i.description) AS description, c.quantity, c.quantity*c.chargeamount AS chargeamount, " +
                "IFNULL(Payments,0) AS Payments, (c.Quantity*c.ChargeAmount)-IFNULL(Payments,0) AS Balance, IFNULL(r.name, 'Office') as name  " +
                "FROM charges c " +
                "LEFT JOIN items i on i.id=c.itemid " +
                "LEFT JOIN resources r ON r.id=c.resourceid " +
                "LEFT JOIN (SELECT chargeid, SUM(amount) AS Payments FROM payments GROUP BY chargeid) p on p.chargeid=c.id " +
                "WHERE c.visitid=" + visitId + " ORDER BY c.id";
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

        htmTb.setCellVAlign("top");
        
        ResultSet chargeRs=io.opnRS(visitQuery);
        while(chargeRs.next()) {
            d.append(htmTb.startRow("style=\"background-color: #cccccc;\""));
            d.append(htmTb.addCell(chargeRs.getString("name") + " - " + chargeRs.getString("description")));
            d.append(htmTb.addCell(""+chargeRs.getInt("quantity"), htmTb.CENTER));
            d.append(htmTb.addCell(Format.formatCurrency(chargeRs.getInt("chargeamount")), htmTb.RIGHT));
            d.append(htmTb.addCell(Format.formatCurrency(chargeRs.getInt("balance")), htmTb.RIGHT));
            d.append(htmTb.endRow());
            d.append(getPaymentsForCharge(io, htmTb, chargeRs.getInt("id")));
        }
        chargeRs.close();

        d.append(htmTb.startRow("style=\"height: 15;\""));
        d.append(htmTb.addCell(""));
        d.append(htmTb.endRow());

        d.append(htmTb.endTable());

        d.append(htmTb.endCell());
        d.append(htmTb.endRow());
        return d.toString();
    }

    public String getPaymentsForCharge(RWConnMgr io, RWHtmlTable htmTb, int chargeId) throws Exception {
        StringBuffer pc=new StringBuffer();
        boolean paymentsFound = false;
        String paymentQuery="SELECT 0 AS sequence, charges.id, CASE WHEN payments.id IS NULL THEN '' ELSE DATE_FORMAT(payments.`date`,'%m/%d/%y') END AS paymentdate, " +
                "CASE WHEN payments.id IS NULL THEN '' ELSE payments.checknumber END AS checknumber, CASE WHEN payments.id IS NULL THEN '' ELSE payments.amount END AS paymentamount, " +
                "providers.name " +
                "FROM charges " +
                "LEFT JOIN payments ON charges.id=payments.chargeid " +
                "LEFT JOIN items ON items.id=charges.itemid " +
                "LEFT JOIN providers ON providers.id=payments.provider " +
                "WHERE charges.id=" + chargeId + " AND providers.id IS NOT NULL " +
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
        htmTb.setCellVAlign("top");

        ResultSet pmtRs=io.opnRS(paymentQuery);
        while(pmtRs.next()) {
            pc.append(htmTb.startRow());
            pc.append(htmTb.addCell(Format.formatDate(pmtRs.getString("paymentdate"), "MM/dd/yy"), htmTb.CENTER));
            pc.append(htmTb.addCell(pmtRs.getString("name")));
            pc.append(htmTb.addCell(Format.formatCurrency(pmtRs.getDouble("paymentamount")), htmTb.RIGHT));
            pc.append(htmTb.endRow());
            paymentsFound=true;
        }
        pmtRs.close();
        pc.append(htmTb.endTable());

        pc.append(htmTb.endCell());
        pc.append(htmTb.endRow());

        if(!paymentsFound) { pc.delete(0, pc.length()); }
        return pc.toString();
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

            if(currentColumn == 1) { dc.append(htmTb.addCell("", "class=diagnosisCodes colspan=2")); dc.append(htmTb.endRow()); }

            if(dc.length()>0) { dc.append(htmTb.endTable()); }
        }
        return dc.toString();
    }
%>