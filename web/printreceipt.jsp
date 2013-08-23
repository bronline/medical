<%@ include file="globalvariables.jsp" %>
<style>
    .headingLabel { font-size: 14px; }
    .headingItem { font-size: 14px; font-weight: bold; }
    .openItem { font-size: 12px; }
    .diagnosisCodes { font-size: 10px; }
    .diagnosisHeader { font-size: 14px; }
</style>
<style media="print" rel="stylesheet" type="text/css">
    .navStuff { DISPLAY: none }
    a:after { content:' [' attr(href) '] ' }
</style>

<input type="submit" name="print_btn" value="print" onclick="window.print();" class="btn navStuff" />
<%
    String printOption=request.getParameter("printOption");
    String printDetails=request.getParameter("detail");
    String selectedPayments = "";
    boolean printAllItems = false;
    boolean unappliedPayment = false;
    boolean chargeHeadingsDisplayed=false;
    double unappliedAmount = 0.0;
    double remainingUnapplied = 0.0;
    double totalPayments = 0.0;
    double totalCharges = 0.0;
    RWHtmlTable htmTb=new RWHtmlTable("700", "0");
    htmTb.replaceNewLineChar(false);

    if(printDetails == null) { printDetails="N"; }
    if(printOption != null && printOption.equals("A")) { printAllItems=true; selectedPayments=" where patientId=" + patient.getId(); }
    if(printOption != null && printOption.equals("S")) { selectedPayments=getSelectedPayments(request, patient.getId()); }
    if(patient.getId() != 0) {
        double totalReceived=0.0;
        int linesPerPage=50;
        int currentLine=1;
        int currPage=1;
        String balanceQuery="";
        Hashtable parentPayments=new Hashtable();
        Hashtable checks=new Hashtable();

        String selectionQuery = "select payments.id, date as paymentdate, date, ifnull(name, 'Cash') as name, checknumber, amount, chargeid, provider, parentpayment, originalamount, patientid from payments left join providers on providers.id=payments.provider" + selectedPayments;

        ResultSet patientRs=io.opnRS("select * from soapnoteheader where id=" + patient.getId());
        ResultSet envRs = io.opnRS("select * from environment");
        envRs.next();
        patientRs.next() ;

        // Run the query for the payment to see if the payment is part of an unapplied payment or check
        ResultSet selectionRs=io.opnRS(selectionQuery + " order by date");

        while(selectionRs.next()) {
            unappliedPayment=false;
            chargeHeadingsDisplayed=false;

            if(!checks.containsKey(selectionRs.getString("checknumber")) && !parentPayments.containsKey(selectionRs.getString("id"))) {
                ResultSet paymentRs=io.opnRS(selectionQuery + " and payments.id=" + selectionRs.getString("payments.id"));
                if(!selectionRs.getString("checknumber").equals("") && selectionRs.getInt("chargeId") != 0 && selectionRs.getInt("parentPayment") == 0) {
                   balanceQuery = "select payments.id, date as paymentdate, date, ifnull(name, 'Cash') as name, checknumber, amount, chargeid, provider, parentpayment from payments " +
                                  "left join providers on providers.id=payments.provider " +
                                  "where provider=" + selectionRs.getString("provider") +
                                  " and checknumber='" + selectionRs.getString("checknumber") + "' " +
                                  "and patientid=" + selectionRs.getString("patientid");
                   paymentRs=io.opnRS(balanceQuery);
                   checks.put(selectionRs.getString("checknumber"), selectionRs.getString("id"));

                } else if(selectionRs.getInt("parentpayment") != 0) {

                   balanceQuery = "select payments.id, parent.date as paymentdate, payments.date, ifnull(name, 'Cash') as name, payments.checknumber, payments.amount, payments.chargeid, payments.provider, payments.parentpayment from payments " +
                                  "left join providers on providers.id=payments.provider " +
"left join payments parent ON parent.id=payments.parentpayment " +
                                  "where payments.parentpayment=" + selectionRs.getString("parentpayment");
/*
                   balanceQuery = "select p.id, p.date, parent.date as paymentdate, " +
                             "ifnull(name, 'Cash') as name, p.checknumber, p.amount, " +
                             "p.chargeid, p.provider, p.parentpayment " +
                             "from payments p " +
                             "left join providers on providers.id=p.provider " +
                             "left join payments parent ON parent.id=p.parentpayment " +
                             "where p.parentpayment="+ selectionRs.getString("id");
*/
                   // This is a child of an unapplied payment so we need to get the original amount of the unapplied payment
                   ResultSet tmpRs=io.opnRS("select originalamount from payments where id=" + selectionRs.getString("parentpayment"));
                   if(tmpRs.next()) {
                       unappliedPayment=true;
                       unappliedAmount=tmpRs.getDouble("originalamount");
                       remainingUnapplied += unappliedAmount;
                   }
                   tmpRs.close();

                   paymentRs=io.opnRS(balanceQuery);
                   parentPayments.put(selectionRs.getString("parentpayment"), selectionRs.getString("id"));
                } else if(selectionRs.getInt("chargeid") == 0) {
/*
                    balanceQuery = "select payments.id, date as paymentdate, date, ifnull(name, 'Cash') as name, checknumber, amount, chargeid, provider, parentpayment from payments " +
                                  "left join providers on providers.id=payments.provider " +
                                  "where parentpayment=" + selectionRs.getString("id");
*/
                     balanceQuery = "select p.id, p.date, parent.date as paymentdate, " +
                             "ifnull(name, 'Cash') as name, p.checknumber, p.amount, " +
                             "p.chargeid, p.provider, p.parentpayment " +
                             "from payments p " +
                             "left join providers on providers.id=p.provider " +
                             "left join payments parent ON parent.id=p.parentpayment " +
                             "where p.parentpayment="+ selectionRs.getString("id");

                   unappliedPayment=true;
                   unappliedAmount=selectionRs.getDouble("originalamount");
                   remainingUnapplied += unappliedAmount;
                   ResultSet unappliedRs=io.opnRS(balanceQuery);
                   if(unappliedRs.next()) {
                        paymentRs.close();
                        paymentRs=unappliedRs;
                   }
                   parentPayments.put(selectionRs.getString("id"), selectionRs.getString("id"));
                }

                paymentRs.beforeFirst();

                boolean paymentDetailsDisplayed=false;

                StringBuffer chargeItems=new StringBuffer();
                double received=0.0;

                while(paymentRs.next()) {
                   if(currentLine>linesPerPage || currPage == 1) {
                       if(currPage != 1) {
//                           out.print(htmTb.startRow());
//                           out.print(htmTb.addCell("<hr>", "colspan=5"));
//                           out.print(htmTb.endRow());

//                            out.print(htmTb.startRow());
//                            out.print(htmTb.addCell(getDiagnosisCodes(io, htmTb, patient.getId(), printDetails), "colspan=5"));
//                            out.print(htmTb.endRow());

                           out.print(htmTb.endTable());
                           out.print("<p style='page-break-before: always'>\n");
                       }
                       out.print(printHeadings(htmTb, patientRs, envRs));
                       currPage ++;
                       currentLine=1;
                   }
                   totalPayments += paymentRs.getDouble("amount");
                   received += paymentRs.getDouble("amount");
                   if(unappliedPayment) { remainingUnapplied -= paymentRs.getDouble("amount"); }

                   if(!parentPayments.containsKey(paymentRs.getString("id"))) { parentPayments.put(paymentRs.getString("id"), paymentRs.getString("id")); }
                   if(!paymentDetailsDisplayed) {
                       String checkNumber=paymentRs.getString("checknumber");
                       if(checkNumber.equals("0")) { checkNumber=""; }
                       out.print(htmTb.startRow());
                       out.print(htmTb.addCell(tools.utils.Format.formatDate(paymentRs.getString("paymentdate"), "MM/dd/yyyy"), htmTb.CENTER, "class=openItem"));
                       out.print(htmTb.addCell(tools.utils.Format.formatDate(paymentRs.getString("date"), "MM/dd/yyyy"), htmTb.CENTER, "class=openItem"));
                       out.print(htmTb.addCell(paymentRs.getString("name"), "class=openItem"));
                       out.print(htmTb.addCell(checkNumber, "class=openItem"));
                       paymentDetailsDisplayed=true;
                       currentLine ++;
                   }

                   totalCharges=getTotalChargesForPayment(io, paymentRs.getInt("chargeid"));
                   if(printDetails.equals("Y")) {
                       String paymentCharges=getChargesForPayment(io, htmTb, paymentRs.getInt("chargeid"), paymentRs.getDouble("amount"));
                       if(!paymentCharges.equals("") && !chargeHeadingsDisplayed) {
                            chargeItems.append(getHeadersForCharges(htmTb));
                            chargeHeadingsDisplayed=true;
                            currentLine += 2;
                       }
                       chargeItems.append(paymentCharges);
                   }

                }

                // if this was an unapplied payment, show the original amount
                if(unappliedPayment) { received=unappliedAmount; }

                totalReceived += received;
                out.print(htmTb.addCell(tools.utils.Format.formatCurrency(received), htmTb.RIGHT, "class=openItem"));
                out.print(htmTb.endRow());
                out.print(chargeItems.toString());

                out.print(htmTb.startRow());
                out.print(htmTb.addCell("<hr>", "colspan=5"));
                out.print(htmTb.endRow());

                paymentRs.close();
                currentLine += 2;
            }
        }

        out.print(htmTb.startRow());
        out.print(htmTb.addCell("<b>Total Charges: </b>" + tools.utils.Format.formatCurrency(totalCharges), "colspan=2 class=openItem"));
        out.print(htmTb.headingCell("Total Received", "class=headingLabel colspan=2"));
        out.print(htmTb.addCell(tools.utils.Format.formatCurrency(totalReceived), htmTb.RIGHT, "class=openItem colspan=1"));
        out.print(htmTb.endRow());
        out.print(htmTb.startRow());
        out.print(htmTb.addCell("", "colspan=2"));
        out.print(htmTb.headingCell("Credit on Account", "class=headingLabel colspan=2"));
//        out.print(htmTb.addCell(tools.utils.Format.formatCurrency(remainingUnapplied), htmTb.RIGHT, "class=openItem"));
        out.print(htmTb.addCell(tools.utils.Format.formatCurrency(patient.getUnappliedPaymentTotal()), htmTb.RIGHT, "class=openItem colspan=1"));
        out.print(htmTb.endRow());

        out.print(htmTb.startRow());
        out.print(htmTb.addCell("<hr>", "colspan=5"));
        out.print(htmTb.endRow());

        out.print(htmTb.startRow());
        out.print(htmTb.addCell(getDiagnosisCodes(io, htmTb, patient.getId(), printDetails), "colspan=5"));
        out.print(htmTb.endRow());

        out.print(htmTb.endTable());

        patientRs.close();
    }
%>
<%! public String printHeadings(RWHtmlTable htmTb, ResultSet patientRs, ResultSet envRs) throws Exception {
       StringBuffer headings = new StringBuffer();
       if(envRs.getInt("statementheading") == 0) {
           headings.append(htmTb.startTable());
           headings.append(htmTb.startTable());
           headings.append(htmTb.startRow());
           headings.append(htmTb.addCell("Payment Receipt", htmTb.CENTER, "colspan=3 class=headingItem style=\"height: 30px; font-size: 18;\""));
           headings.append(htmTb.endRow());
           headings.append(htmTb.startRow());
           if(envRs.getString("suppliername") != null && !envRs.getString("suppliername").equals("")) {
               headings.append(htmTb.addCell(envRs.getString("suppliername"), "width=300 class=headingItem"));
           } else {
               headings.append(htmTb.addCell(envRs.getString("supplier"), "width=300 class=headingItem"));
           }
           headings.append(htmTb.addCell("Date:", "class=\"headingLabel\" width=\"150\""));
           headings.append(htmTb.addCell(Format.formatDate(new java.util.Date(), "MM/dd/yyyy"), "width=\"150\" class=\"headingItem\""));
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

       headings.append(htmTb.startTable());
       headings.append(htmTb.startRow());
       headings.append(htmTb.headingCell("Payment<br/>Date", "width=100 class=headingLabel"));
       headings.append(htmTb.headingCell("Date<br/>Applied", "width=100 class=headingLabel"));
       headings.append(htmTb.headingCell("Payment Type", "width=200 class=headingLabel"));
       headings.append(htmTb.headingCell("Check Number", "width=100 class=headingLabel"));
//       headings.append(htmTb.headingCell("Paid<br>Amount", htmTb.RIGHT, "width=100 class=headingLabel"));
       headings.append(htmTb.headingCell("Payment<br>Amount", htmTb.RIGHT, "width=100 class=headingLabel"));
       headings.append(htmTb.endRow());

       headings.append(htmTb.addCell("<hr>", "colspan=5"));
       return headings.toString();
    }

    public String getSelectedPayments(HttpServletRequest request, int patientId) {
        StringBuffer si=new StringBuffer();
        boolean selectedItemFound=false;
        si.append(" where patientid=" + patientId);
        for(Enumeration e=request.getParameterNames(); e.hasMoreElements();) {
            String field=(String)e.nextElement();
            if(field.substring(0,3).equals("chk")) {
                if(!selectedItemFound) { si.append(" and payments.id in("); }
                if(selectedItemFound) { si.append(","); }
                si.append(field.substring(3));
                selectedItemFound=true;
            }
        }
        if(selectedItemFound) { si.append(") "); }
        return si.toString();
    }

    public String getChargesForPayment(RWConnMgr io, RWHtmlTable htmTb, int chargeId, double paymentAmount) throws Exception {
        int numberOfCharges=0;
        StringBuffer pc=new StringBuffer();
        double balance=0.0;
        double chargeAmount=0.0;

        ResultSet lRs=io.opnRS("select * from charges left join visits on charges.visitid=visits.id left join items on charges.itemid=items.id where charges.id=" + chargeId);
        while(lRs.next()) {
            chargeAmount=lRs.getDouble("quantity")*lRs.getDouble("chargeamount");
            balance=chargeAmount-paymentAmount;
            pc.append(htmTb.startRow("style='background: #e0e0e0;'"));
//            pc.append(htmTb.addCell(""));
            pc.append(htmTb.startCell(htmTb.LEFT, "colspan=4"));
            pc.append(htmTb.startTable("100%"));
            pc.append(htmTb.startRow());
            pc.append(htmTb.addCell(Format.formatDate(lRs.getString("date"), "MM/dd/yyyy"), htmTb.CENTER, "width='10%'"));
            pc.append(htmTb.addCell(lRs.getString("code") + " - " + lRs.getString("description"), "width='50%'"));
            pc.append(htmTb.addCell(lRs.getString("quantity"),htmTb.RIGHT, "width='10%'"));
            pc.append(htmTb.addCell(Format.formatCurrency(chargeAmount),htmTb.RIGHT, "width='10%'"));
            pc.append(htmTb.addCell(Format.formatCurrency(paymentAmount),htmTb.RIGHT, "width='10%'"));
            pc.append(htmTb.addCell(Format.formatCurrency(balance),htmTb.RIGHT, "width='10%'"));
            pc.append(htmTb.endCell());
            pc.append(htmTb.endRow());
            pc.append(htmTb.endTable());
            pc.append(htmTb.addCell("", "colspan=1"));
            pc.append(htmTb.endRow());
            numberOfCharges ++;
        }
        lRs.close();

        if(numberOfCharges==0) { pc.delete(0,pc.length()); }

        return pc.toString();
    }

    public double getTotalChargesForPayment(RWConnMgr io, int chargeId) throws Exception {
        double totalCharges=0.0;

        ResultSet lRs=io.opnRS("select * from charges left join visits on charges.visitid=visits.id left join items on charges.itemid=items.id where charges.id=" + chargeId);
        while(lRs.next()) {
            totalCharges += lRs.getDouble("quantity")*lRs.getDouble("chargeamount");
        }

        lRs.close();

        return totalCharges;
    }

    public String getHeadersForCharges(RWHtmlTable htmTb) throws Exception {
        StringBuffer pc=new StringBuffer();
        pc.append(htmTb.startRow("style='background: #e0e0e0;'"));
//        pc.append(htmTb.addCell(""));
        pc.append(htmTb.startCell(htmTb.LEFT, "colspan=4"));

        pc.append(htmTb.startTable("100%"));
        pc.append(htmTb.startRow());
        pc.append(htmTb.addCell("<b>Charge<br>Date</b>", htmTb.CENTER, "width='10%' "));
        pc.append(htmTb.addCell("<b><br>Charge Description</b>", "width='50%' "));
        pc.append(htmTb.addCell("<b>Quantity</b>",htmTb.RIGHT, "width='10%' "));
        pc.append(htmTb.addCell("<b>Charge<br>Amount</b>",htmTb.RIGHT, "width='10%' "));
        pc.append(htmTb.addCell("<b>Payment<br>Amount</b>",htmTb.RIGHT, "width='10%' "));
        pc.append(htmTb.addCell("<b><br>Balance</b>",htmTb.RIGHT, "width='10%' "));
        pc.append(htmTb.endCell());
        pc.append(htmTb.endRow());
        pc.append(htmTb.endTable());

        pc.append(htmTb.addCell("", "colspan=1"));
        pc.append(htmTb.endRow());

        return pc.toString();
    }

    public String getDiagnosisCodes(RWConnMgr io, RWHtmlTable htmTb, int patientId, String printDetails) throws Exception {
        StringBuffer dc = new StringBuffer();
        int currentColumn = 0;
        if(printDetails.equals("Y")) {
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
        }
        return dc.toString();
    }
%>