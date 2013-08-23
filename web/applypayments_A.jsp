<%@include file="globalvariables.jsp" %>

<title>Apply Payments</title>

<script language="javascript">
  function submitForm(action) {
    var isSure = confirm('This Action will reset all changes in the list.  Do you want to continue?');
    if (isSure==true) {
        var frmA=document.forms["frmInput"]
        frmA.method="POST"
        frmA.action=action
        frmA.submit()
    }
  }  
  function postPayments(action) {
    var total=0
    var checkAmount=+frmInput.checkAmount.value
    for (i=0;i<frmInput.elements.length;i++) {
        itemName=frmInput.elements[i].name
        if (itemName!=null && itemName.length>11 && itemName.substring(0,11)=='checkAmount') {
            total+= +Number(frmInput.elements[i].value.replace('$','').replace(',',''))
        }
    }
    if (total > checkAmount) {
        doPost = confirm('You are trying to apply ' + formatCurrency(total) + ' but the payment amount is only ' + formatCurrency(checkAmount) + '.  Do you want to continue?')
    } else {
        doPost = true
    }
    if (doPost) {
        var frmA=document.forms["frmInput"]
        frmA.method="POST"
        frmA.action=action
        frmA.submit()
    }
  }
  function refreshParentPage(where) {
    if(where != null) {
      window.opener.location.href=where;
    }
  }
</script>
<SCRIPT language=JavaScript>
<!-- 
function win(parent){
if(parent != null) { window.opener.location.href=parent }
self.close();
//-->
}
</SCRIPT>

<%
    String parentLocation = (String)session.getAttribute("parentLocation");

// Initialize local variables
    int patientId = patient.getId();
    String myQuery          = "";
    String whereClause      = "";
    String id               = request.getParameter("id");
    String[] preload={"*UNASSIGNED"};
    String[] preload2={};
    StringBuffer iForm = new StringBuffer();
    
    String startDate = "01/01/1901";
    String endDate = "12/31/2100";
    String providerId = "2";
    String checkNumber = "";
    String checkAmount = "0.00";
    String patientName = "";
    String parentPayment = "0";
    String typeDescription = "Payment Amount:";
    double availableToPost = 0.0;
    
// If parameters were passed, use them
    if (request.getParameter("parentPayment")!=null) {
        parentPayment=request.getParameter("parentPayment");
    }
    if (request.getParameter("providerId")!=null) {
        providerId=request.getParameter("providerId");
    }
    if (request.getParameter("patientId")!=null) {
        patientId=Integer.parseInt(request.getParameter("patientId"));
    }
    if (request.getParameter("checkNumber")!=null) {
        checkNumber=request.getParameter("checkNumber");
    }
    if (request.getParameter("checkAmount")!=null) {
        checkAmount=request.getParameter("checkAmount");
        try {
            availableToPost=Double.parseDouble(checkAmount.replaceAll("\\$",""));
        } catch (Exception e) {
        }
    }
    if (request.getParameter("startDate")!=null) {
        startDate=request.getParameter("startDate");
    }
    if (request.getParameter("endDate")!=null) {
        endDate=request.getParameter("endDate");
    }
    if(request.getParameter("coPay") != null) {
        typeDescription = "<b style='color: red;'>Due Today:</b>";
        checkAmount="<b style='color: red;'>" + checkAmount + "</b>";
    }
    
// Instantiate a table and a form
    RWHtmlTable htmTb = new RWHtmlTable("300", "0");
    htmTb.replaceNewLineChar(false);
    htmTb.setWidth("210");

    RWInputForm frm = new RWInputForm();
    frm.setShowDatePicker(true);
    frm.setDftTextBoxSize("25");
    frm.formItemOnOneRow = false;
    frm.setLabelBold(true);
    frm.setLabelPosition(frm.LABEL_ON_LEFT);
    frm.setUseExternalForm(true);

    frm.setDftTextBoxSize("25");
    frm.formItemOnOneRow = false;
    frm.setLabelBold(true);
    frm.setLabelPosition(frm.LABEL_ON_LEFT);
    frm.setUseExternalForm(true);
    frm.setShowDatePicker(true);

    htmTb.setWidth("210");

// Instantiate result sets for use in the comboboxes
    ResultSet lRs;
    if (parentPayment.equals("0") && request.getParameter("coPay") == null ) {
        lRs = io.opnRS("select id, name from providers where id in (select providerid from patientinsurance where patientid=" + patientId + ") order by name ");
    } else if(request.getParameter("coPay") != null){
        lRs = io.opnRS("select 0, 'Cash' as name union select id, name from providers where reserved");
    } else {
        lRs = io.opnRS("select 0, 'Cash' as name union select id, name from providers where reserved order by name ");
    }
    
// Print The Title
    patient.setId(patientId);
    patient.beforeFirst();
    if (patient.next()) {
        patientName = patient.getString("firstname") + " " + patient.getString("lastname") ;
    }
    out.print("<H1>Apply Payments for " + patientName + ", " + typeDescription +  " " + checkAmount + "</H1>");
    
// Build the form now
    iForm.append(frm.startForm());
    
// Now, the groupbox with the Service Dates
    iForm.append("<fieldset style=\"width: 247 ; border: 1px solid #666; padding: 10px;\"><legend><b>Services Performed</b></legend>");
    iForm.append(htmTb.startTable());
    iForm.append(htmTb.startRow());
    iForm.append(htmTb.addCell("<b>Start Date"));
    iForm.append(htmTb.addCell(frm.date(startDate,"startDate","class=tBoxText")));
    iForm.append(htmTb.endRow());

    iForm.append(htmTb.startRow());
    iForm.append(htmTb.addCell("<b>End Date"));
    iForm.append(htmTb.addCell(frm.date(endDate,"endDate","class=tBoxText")));
    iForm.append(htmTb.endRow());
    
    iForm.append(htmTb.endTable());
    iForm.append("</fieldset>");

    iForm.append("<br>" + frm.button("Get Charges","class=button onclick=submitForm(\"applypayments.jsp\")","Filter"));

// Now, the hidden stuff
    iForm.append(frm.hidden(providerId,"providerId"));
    iForm.append(frm.hidden(checkNumber,"checkNumber"));
    iForm.append(frm.hidden(checkAmount,"checkAmount"));
    iForm.append(frm.hidden(parentPayment,"parentPayment"));

// Now, tack on the filtered list containing all patients that may qualify to have their charges paid by this check
    whereClause = "where (paidamount<>chargeamount or paidamount is null) and b.patientid = " + patientId + 
                  " and date >= '" + Format.formatDate(startDate, "yyyy-MM-dd") + "' " +
                  " and date <= '" + Format.formatDate(endDate, "yyyy-MM-dd") + "' ";

    myQuery     = "select a.itemid, a.id, b.date, d.description, a.copayamount, a.chargeamount, ifnull(paidamount,0) paidamount, " +
                  "cast(a.chargeamount-ifnull(paidamount,0) as decimal(6, 2)) balance " + 
                  "from charges a join items d on a.itemid=d.id join visits b on a.visitid=b.id join patients c on b.patientid=c.id " + 
                  "left outer join (SELECT patientid, chargeid, sum(amount) paidamount FROM payments p " +
                  "group by patientid, chargeid) e on a.id=e.chargeid " +
            whereClause +
                  " order by date, description ";
    String url         = "applypayments.jsp?checkNumber="+checkNumber+"&checkAmount="+checkAmount+"&startDate="+startDate+"&endDate="+endDate;
    String title       = "";

//    out.print(myQuery);

// Create a new paymentform
    htmTb.setWidth("650");
    RWInputForm pFrm = new RWInputForm();
    pFrm.setFormName("payment");

    ResultSet pRs = io.opnRS(myQuery);
    iForm.append(htmTb.startTable());
    iForm.append(htmTb.startRow());
    iForm.append(htmTb.headingCell("Date", "width=50"));
    iForm.append(htmTb.headingCell("Description", "width=150"));
    iForm.append(htmTb.headingCell("Copay", "width=50"));
    iForm.append(htmTb.headingCell("Charge Amount", "width=50"));
    iForm.append(htmTb.headingCell("Paid Amount", "width=50"));
    iForm.append(htmTb.headingCell("Balance", "width=50"));
    iForm.append(htmTb.headingCell("Check Number", "width=80"));
    iForm.append(htmTb.headingCell("Payment<br> Amount", "width=80"));
    iForm.append(htmTb.headingCell("Provider", "width=90"));
    iForm.append(htmTb.endRow());
    iForm.append(htmTb.endTable());

    String chargeId="0";
    iForm.append("<div style=\" height: 300; width: 668; overflow: auto;\">");
    iForm.append(htmTb.startTable());
    String rowColor="lightgrey";
    while (pRs.next()) {
        chargeId=pRs.getString("id");
        String defaultPayment="";

        // 03-09-07 if we're processing co-pay, apply default payments to co-pay items only
        if(request.getParameter("coPay") == null) {
            if(availableToPost > 0.0) {

                BigDecimal bDDefaultPayment = patient.getDefaultPayment(pRs.getInt("itemid"), Integer.parseInt(providerId));
                defaultPayment = ""+bDDefaultPayment;
                long balance=pRs.getLong("balance");
                if (balance < bDDefaultPayment.longValue() || bDDefaultPayment.longValue()==0.0) {
                    defaultPayment=pRs.getString("balance");
                }
                double dpDouble = Double.valueOf(defaultPayment).doubleValue();
                if (availableToPost<dpDouble ) {
                    defaultPayment=BigDecimal.valueOf(Double.valueOf(availableToPost)).toString();
                    availableToPost=0.00;
                } else {
                    availableToPost -= dpDouble;
                }
            } else {
                defaultPayment="0.00";
            }
        } else {
            if(availableToPost > 0.0) {
                defaultPayment=pRs.getString("copayamount");
                if (pRs.getDouble("copayamount")==0.0) {
                    defaultPayment=pRs.getString("balance");
                    availableToPost -= pRs.getDouble("balance");
                } else {
                    availableToPost -= pRs.getDouble("copayamount");
                }
                if(availableToPost < 0.0) {
                    defaultPayment=""+(availableToPost*-1);
                    availableToPost=0.0;
                }
            }
        }
//        BigDecimal bDCopay = patient.getCopay(pRs.getInt("itemid"), Integer.parseInt(providerId));
//        String copay = ""+bDCopay;
        iForm.append(htmTb.startRow("bgcolor="+rowColor));
        iForm.append(htmTb.addCell(pRs.getString("date"), "width=50"));
        iForm.append(htmTb.addCell(pRs.getString("description"), "width=150"));
        iForm.append(htmTb.addCell(pRs.getString("copayamount"), 1, "width=50"));
        iForm.append(htmTb.addCell(pRs.getString("chargeamount"), 1, "width=50"));
        iForm.append(htmTb.addCell(pRs.getString("paidamount"), 1, "width=50"));
        iForm.append(htmTb.addCell(pRs.getString("balance"), 1, "width=50"));
        iForm.append(htmTb.addCell(frm.textBox(checkNumber, "checkNumber"+chargeId, "15","15","class=tBoxText"), 2, "width=80"));
        iForm.append(htmTb.addCell(frm.textBox(defaultPayment, "checkAmount"+chargeId, "10","10","class=tBoxText onBlur=\"this.value=formatCurrency(this.value);\""), 2, "width=80"));
        lRs.beforeFirst();
        iForm.append(htmTb.addCell(frm.comboBox(lRs,"providerId"+chargeId,"id",false,"1",preload2,providerId,"class=cBoxText style='width:90px'"), 2,"width=90"));
        iForm.append(htmTb.endRow());
        if (rowColor.equals("lightgrey")) {
            rowColor="#cccccc";
        } else {
            rowColor="lightgrey";
        }
        // Hidden Date Field
        iForm.append(frm.hidden(Format.formatDate(new java.util.Date(),"yyyy-MM-dd"), "date"+chargeId));

    }
    iForm.append(htmTb.endTable());
    iForm.append("</div>");

// Everything we need is inside the form.  Close it up.
    iForm.append(frm.endForm());

    iForm.append("<br>" + frm.button("Post Payments","class=button onclick=postPayments(\"postpayments.jsp?parentPayment="+parentPayment+"\")","Filter"));

// Spit the results out to the browser
    out.print(iForm.toString());
    
// Save the session variables
    session.setAttribute("returnUrl", "applypayments.jsp");
%>
<%
    if(request.getParameter("posted")!=null && request.getParameter("posted").equalsIgnoreCase("Y")) { %>
        <body onLoad="self.close()">
        <body>
<%    } else { %>
        <body onUnLoad="refreshParentPage('<%= (String)session.getAttribute("myParent") %>')">
<% } 
%>

</body>
