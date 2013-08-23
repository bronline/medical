<%--
    Document   : visitreceipt
    Created on : Mar 28, 2012, 3:15:08 PM
    Author     : rwandell
--%>
<%@ include file="globalvariables.jsp" %>
<style>
    .headingLabel { font-size: 14px; }
    .headingItem { font-size: 14px; font-weight: bold; }
    .openItem { font-size: 10px; }
    .bodyHeading { fonr-size: 10px; font-weight: bold; color: #000000; background-color: #e0e0e0; }
    .diagnosisCodes { font-size: 10px; }
    .diagnosisHeader { font-size: 14px; }
</style>
<style media="print" rel="stylesheet" type="text/css">
    .navStuff { DISPLAY: none }
    a:after { content:' [' attr(href) '] ' }
</style>

<input type="submit" name="print_btn" value="print" onclick="window.print();" class="btn navStuff" />
<%
    String visitId=request.getParameter("visitId");
    String printDetails=request.getParameter("detail");

    boolean unappliedPayment = false;
    boolean chargeHeadingsDisplayed=false;
    double unappliedAmount = 0.0;
    double remainingUnapplied = 0.0;
    double totalPayments = 0.0;
    double totalCharges = 0.0;

    RWHtmlTable htmTb=new RWHtmlTable("700", "0");
    htmTb.replaceNewLineChar(false);

    if(patient.getId() != 0) {
        ResultSet visitRs = io.opnRS("select * from visits where id=" + visitId);
        if(visitRs.next()) {
            double totalReceived=0.0;
            int linesPerPage=50;
            int currentLine=1;
            int currPage=1;
            String balanceQuery="";
            Hashtable parentPayments=new Hashtable();
            Hashtable checks=new Hashtable();
            StringBuffer chargeItems = new StringBuffer();

            String selectionQuery = "select payments.id, date, ifnull(name, 'Cash') as name, checknumber, amount, chargeid, provider, parentpayment, originalamount, patientid from payments left join providers on providers.id=payments.provider where payments.patientid=" + visitRs.getString("patientid") + " and `date`='" + visitRs.getString("date") + "'";

            ResultSet patientRs=io.opnRS("select * from soapnoteheader where id=" + visitRs.getString("patientid"));
            ResultSet envRs = io.opnRS("select * from environment");
            envRs.next();
            patientRs.next() ;

            // Run the query for the payment to see if the payment is part of an unapplied payment or check
            ResultSet paymentRs=io.opnRS(selectionQuery + " order by id");

            out.print(printHeadings(htmTb, patientRs, envRs));

            while(paymentRs.next()) {
                if(paymentRs.getRow()==1) {
                    out.print(htmTb.startTable());
                    out.print(htmTb.startRow());
                    out.print(htmTb.addCell("","width='5%' class=bodyHeading"));
                    out.print(htmTb.headingCell("Date", "width='10%' class=bodyHeading"));
                    out.print(htmTb.headingCell("Payment Type", "width='50%' class=bodyHeading"));
                    out.print(htmTb.headingCell("Check Number", "width='15%' class=bodyHeading"));
                    out.print(htmTb.headingCell("Amount", htmTb.RIGHT, "width='15%' class=bodyHeading"));
                    out.print(htmTb.addCell("","width='5%' class=bodyHeading"));
                    out.print(htmTb.endRow());
                }
                totalPayments += paymentRs.getDouble("amount");
                String checkNumber=paymentRs.getString("checknumber");
                if(checkNumber.equals("0")) { checkNumber=""; }
                out.print(htmTb.startRow());
                out.print(htmTb.addCell(""));
                out.print(htmTb.addCell(tools.utils.Format.formatDate(paymentRs.getString("date"), "MM/dd/yyyy"), htmTb.CENTER, "class=openItem"));
                out.print(htmTb.addCell(paymentRs.getString("name"), "class=openItem"));
                out.print(htmTb.addCell(checkNumber, "class=openItem"));
                out.print(htmTb.addCell(tools.utils.Format.formatCurrency(paymentRs.getDouble("originalamount")), htmTb.RIGHT, "class=openItem"));
                out.print(htmTb.addCell(""));
                out.print(htmTb.endRow());
                currentLine ++;
            }

		if(!paymentRs.isBeforeFirst()) {
                out.print(htmTb.endTable());
                out.print("<br/><br/>");
            }

            out.print(htmTb.startTable());
            out.print(getHeadersForCharges(htmTb));
            chargeHeadingsDisplayed=true;
            currentLine += 2;

            ResultSet chargeRs=io.opnRS("select * from charges left join visits on charges.visitid=visits.id left join items on charges.itemid=items.id where charges.visitid=" + visitRs.getString("id"));
            while(chargeRs.next()) {
                double chargeAmount=chargeRs.getDouble("quantity")*chargeRs.getDouble("chargeamount");
                double balance=chargeAmount;
                out.print(htmTb.startRow("style='background: #e0e0e0;'"));
                out.print(htmTb.startRow());
                out.print(htmTb.addCell(""));
                out.print(htmTb.addCell(Format.formatDate(chargeRs.getString("date"), "MM/dd/yyyy"), htmTb.CENTER, "width='10%'"));
                out.print(htmTb.addCell(chargeRs.getString("code") + " - " + chargeRs.getString("description"), "width='50%'"));
                out.print(htmTb.addCell(chargeRs.getString("quantity"),htmTb.RIGHT, "width='10%'"));
                out.print(htmTb.addCell(Format.formatCurrency(chargeAmount),htmTb.RIGHT, "width='10%'"));
                out.print(htmTb.addCell(""));
                out.print(htmTb.endRow());
            }
            chargeRs.close();

            out.print(htmTb.startRow());
            out.print(htmTb.addCell("<hr>", "colspan=6"));
            out.print(htmTb.endRow());

            paymentRs.close();
            currentLine += 2;

//            out.print(htmTb.startRow());
//            out.print(htmTb.addCell("<b>Total Charges: </b>" + tools.utils.Format.formatCurrency(totalCharges), "colspan=2 class=openItem"));
//            out.print(htmTb.headingCell("Total Received", "class=headingLabel"));
//            out.print(htmTb.addCell(tools.utils.Format.formatCurrency(totalReceived), htmTb.RIGHT, "class=openItem"));
//            out.print(htmTb.endRow());
//            out.print(htmTb.startRow());
//            out.print(htmTb.addCell("", "colspan=2"));
//            out.print(htmTb.headingCell("Credit on Account", "class=headingLabel"));
//            out.print(htmTb.addCell(tools.utils.Format.formatCurrency(remainingUnapplied), htmTb.RIGHT, "class=openItem"));
//            out.print(htmTb.endRow());

//            out.print(htmTb.startRow());
//            out.print(htmTb.addCell("<hr>", "colspan=5"));
//            out.print(htmTb.endRow());

            out.print(htmTb.startRow());
            out.print(htmTb.addCell(getDiagnosisCodes(io, htmTb, patient.getId()), "colspan=6"));
            out.print(htmTb.endRow());

            out.print(htmTb.endTable());

            patientRs.close();
        }
        visitRs.close();
    }
%>
<%! public String printHeadings(RWHtmlTable htmTb, ResultSet patientRs, ResultSet envRs) throws Exception {
       StringBuffer headings = new StringBuffer();
       headings.append(htmTb.startTable());
       headings.append(htmTb.startRow());
       headings.append(htmTb.addCell("Payment Receipt", htmTb.CENTER, "colspan=5 class=headingItem style='height: 30;'"));
       headings.append(htmTb.endRow());
       headings.append(htmTb.startRow());
       headings.append(htmTb.addCell("Patient Name", "width=100 class=headingLabel"));
       headings.append(htmTb.addCell(patientRs.getString("patientname"), "width=250 class=headingItem"));
       headings.append(htmTb.addCell("", "width=50"));
       headings.append(htmTb.addCell("Account Number", "width=125 class=headingLabel"));
       headings.append(htmTb.addCell(patientRs.getString("accountnumber"), "width=300 class=headingItem"));
       headings.append(htmTb.endRow());
       headings.append(htmTb.startRow());
       headings.append(htmTb.addCell("Address", "width=100 class=headingLabel"));
       headings.append(htmTb.addCell(patientRs.getString("patientaddress"), "width=250 class=headingItem"));
       headings.append(htmTb.addCell("", "width=50"));
       headings.append(htmTb.addCell("Doctor Name", "width=125 class=headingLabel"));
       headings.append(htmTb.addCell(patientRs.getString("doctorname"), "width=300 class=headingItem"));
       headings.append(htmTb.endRow());

       headings.append(htmTb.startRow());
       headings.append(htmTb.addCell("", "width=100 class=headingLabel"));
       headings.append(htmTb.addCell(patientRs.getString("patientcsz"), "width=250 class=headingItem"));
       headings.append(htmTb.addCell("", "width=50"));
       headings.append(htmTb.addCell("", "width=125 class=headingLabel"));
       headings.append(htmTb.addCell(patientRs.getString("officeaddress") + "<br>" + patientRs.getString("officecsz"), "width=300 class=headingItem"));
       headings.append(htmTb.endRow());

       headings.append(htmTb.startRow());
       headings.append(htmTb.addCell("&nbsp;&nbsp;", "width=100 class=headingLabel"));
       headings.append(htmTb.addCell("&nbsp;&nbsp;", "width=250 class=headingItem"));
       headings.append(htmTb.addCell("&nbsp;&nbsp;", "width=50"));
       headings.append(htmTb.addCell("NPI", "width=125 class=headingLabel"));
       headings.append(htmTb.addCell(patientRs.getString("NPI"), "width=300 class=headingItem"));
       headings.append(htmTb.endRow());

       headings.append(htmTb.startRow());
       headings.append(htmTb.addCell("&nbsp;&nbsp;", "width=100 class=headingLabel"));
       headings.append(htmTb.addCell("&nbsp;&nbsp;", "width=250 class=headingItem"));
       headings.append(htmTb.addCell("&nbsp;&nbsp;", "width=50"));
       headings.append(htmTb.addCell("Tax ID", "width=125 class=headingLabel"));
       headings.append(htmTb.addCell(envRs.getString("taxid"), "width=300 class=headingItem"));
       headings.append(htmTb.endRow());

       headings.append(htmTb.startRow());
       headings.append(htmTb.addCell("&nbsp;&nbsp;", "width=100 class=headingLabel"));
       headings.append(htmTb.addCell("&nbsp;&nbsp;", "width=250 class=headingItem"));
       headings.append(htmTb.addCell("&nbsp;&nbsp;", "width=50"));
       headings.append(htmTb.addCell("Phone", "width=125 class=headingLabel"));
       headings.append(htmTb.addCell(Format.formatPhone(patientRs.getString("phone")), "width=300 class=headingItem"));
       headings.append(htmTb.endRow());

       headings.append(htmTb.startRow());
       headings.append(htmTb.addCell("<hr>", "colspan=5"));
       headings.append(htmTb.endRow());

       headings.append(htmTb.endTable());

       headings.append("<br><br>");

       return headings.toString();
    }

    public String getHeadersForCharges(RWHtmlTable htmTb) throws Exception {
        StringBuffer pc=new StringBuffer();

        pc.append(htmTb.startRow());
        pc.append(htmTb.addCell("","width='5%' class='bodyHeading'"));
        pc.append(htmTb.addCell("<b>Charge<br>Date</b>", htmTb.CENTER, "width='10%' class='bodyHeading' "));
        pc.append(htmTb.addCell("<b><br>Charge Description</b>", "width='50%' class='bodyHeading' "));
        pc.append(htmTb.addCell("<b>Quantity</b>",htmTb.RIGHT, "width='15%' class='bodyHeading' "));
        pc.append(htmTb.addCell("<b>Charge<br>Amount</b>",htmTb.RIGHT, "width='15%' class='bodyHeading' "));
        pc.append(htmTb.addCell("","width='5%' class='bodyHeading'"));
        pc.append(htmTb.endRow());

        return pc.toString();
    }

    public String getDiagnosisCodes(RWConnMgr io, RWHtmlTable htmTb, int patientId) throws Exception {
        StringBuffer dc = new StringBuffer();
        int currentColumn = 0;

        ResultSet lRs = io.opnRS("SELECT * FROM patientsymptoms a left join diagnosiscodes b on b.id=a.diagnosisid where patientid=" + patientId);
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

        return dc.toString();
    }
%>