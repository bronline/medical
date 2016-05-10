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
  function calcWoAmt(field) {
    var patAmt=0
    //alert(field.name)
    suffix=""
    if (field.name.substring(0,11)=="checkAmount") {
        suffix=field.name.substring(11)
    }
    if (field.name.substring(0,9)=="patAmount") {
        suffix=field.name.substring(9)
    }
    patAmt=Number(document.getElementById('bal'+suffix).innerHTML.replace('$','').replace(',',''))
    patAmt=patAmt-Number(frmInput.elements['checkAmount'+suffix].value.replace('$','').replace(',',''))
    patAmt=patAmt-Number(frmInput.elements['patAmount'+suffix].value.replace('$','').replace(',',''))
    if (patAmt<0) { 
      patAmt=0
    }
    frmInput.elements['woAmount'+suffix].value=formatCurrency(patAmt)
  }

  function calcPatAmt(field) {
    var patAmt=0
    //alert(field.name)
    suffix=""
    if (field.name.substring(0,11)=="checkAmount") {
        suffix=field.name.substring(11)
    }
    if (field.name.substring(0,8)=="woAmount") {
        suffix=field.name.substring(8)
    }
    patAmt=Number(document.getElementById('bal'+suffix).innerHTML.replace('$','').replace(',',''))
    patAmt=patAmt-Number(frmInput.elements['checkAmount'+suffix].value.replace('$','').replace(',',''))
    patAmt=patAmt-Number(frmInput.elements['woAmount'+suffix].value.replace('$','').replace(',',''))
    if (patAmt<0) { 
      patAmt=0
    }
    frmInput.elements['patAmount'+suffix].value=formatCurrency(patAmt)
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
    String batchesOnly      = request.getParameter("batchesOnly");
    String multiplePayments = (String)session.getAttribute("multiplePayments");
    String batchId          = (String)session.getAttribute("batchId");
    String today            = (String)session.getAttribute("today");
    String bulkPayments     = request.getParameter("bulkPayments");
    
    String[] preload={"*UNASSIGNED"};
    String[] preload2={};
    StringBuffer iForm = new StringBuffer();
    
    String startDate = "01/01/1901";
    String endDate = "12/31/2100";
    String paymentDate = Format.formatDate(new java.util.Date(), "MM/dd/yyyy");
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
    } else if(request.getParameter("provider") != null) {
        providerId=request.getParameter("provider");        
    }
    
    if (request.getParameter("patientId")!=null) {
        patientId=Integer.parseInt(request.getParameter("patientId"));
    } else if(request.getParameter("patientid") != null) {
        patientId=Integer.parseInt(request.getParameter("patientid"));        
    }
    
    if (request.getParameter("checkNumber")!=null) {
        checkNumber=request.getParameter("checkNumber");
    } else if(request.getParameter("checknumber") != null) {
        checkNumber=request.getParameter("checknumber");        
    }
    
    if (request.getParameter("checkAmount")!=null ) {
        checkAmount=request.getParameter("checkAmount");
        try {
            availableToPost=Double.parseDouble(checkAmount.replaceAll("\\$","").replaceAll(",",""));
        } catch (Exception e) {
        }
    } else if (request.getParameter("amount")!=null ) {
        checkAmount=request.getParameter("amount");
        try {
            availableToPost=Double.parseDouble(checkAmount.replaceAll("\\$","").replaceAll(",",""));
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
    if(request.getParameter("date") != null) {
        paymentDate=Format.formatDate(request.getParameter("date"), "yyyy-MM-dd");
    }
    if (batchesOnly==null) {
        batchesOnly="N";
    }

    if (batchesOnly.equals("Y")) {
        
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

    if(io.getConnection().isClosed()) { io.opnmySqlConn(); }
    
// Instantiate result sets for use in the comboboxes
    ResultSet lRs;
    if (!parentPayment.equals("0")) {
        if(!providerId.equals("0")) {
            lRs = io.opnRS("select id as providerId, name from providers where id=" + providerId );        
        } else {
            lRs = io.opnRS("select 0 as providerid, 'Cash' as name");
        }
    } else if(batchId != null && !batchId.equals("")) {
        lRs = io.opnRS("select id, name from providers where id in (select provider from batches where id=" + batchId + ")");        
    } else if(today != null && !today.equals("")) {    
        lRs = io.opnRS("select id, name from providers where id=" + providerId );        
    } else if (parentPayment.equals("0") && request.getParameter("coPay") == null ) {
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
    out.print("<H1>Apply Payments for " + patientName + ", " + typeDescription +  " " + Format.formatCurrency(checkAmount) + "</H1>");
    
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

    if(batchId != null && !batchId.equals("")) { 
        whereClause += " and a.id in (select chargeid from batchcharges where batchid=" + batchId + ")";
        batchesOnly="Y";
    }
    
    if (batchesOnly.equals("Y")) {
        myQuery     = "select DISTINCT a.itemid, a.id, b.date, concat(d.code,' - ',d.description) as description, a.copayamount, a.chargeamount*a.quantity as chargeamount, ifnull(paidamount,0) paidamount, " +
                      "cast((a.chargeamount*a.quantity)-ifnull(paidamount,0) as decimal(6, 2)) balance " + 
                      "from charges a " +
                      "join batchcharges w on a.id=w.chargeid " +
                      "join items d on a.itemid=d.id " + 
                      "join visits b on a.visitid=b.id join patients c on b.patientid=c.id " +
                      "left outer join (SELECT patientid, chargeid, sum(amount) paidamount FROM payments p group by patientid, chargeid) e on a.id=e.chargeid ";

    } else {
        myQuery     = "select distinct a.itemid, a.id, b.date, concat(d.code,' - ',d.description) as description, a.copayamount, a.chargeamount*a.quantity as chargeamount, ifnull(paidamount,0) paidamount, " +
                      "cast((a.chargeamount*a.quantity)-ifnull(paidamount,0) as decimal(6, 2)) balance " + 
                      "from charges a join " +
                      "items d on a.itemid=d.id join visits b on a.visitid=b.id join patients c on b.patientid=c.id " + 
                      "left outer join (SELECT patientid, chargeid, sum(amount) paidamount FROM payments p " +
                      "group by patientid, chargeid) e on a.id=e.chargeid ";
    }
    
    myQuery = myQuery + whereClause + " order by a.id";

    String url         = "applypayments.jsp?checkNumber="+checkNumber+"&checkAmount="+checkAmount+"&startDate="+startDate+"&endDate="+endDate;
    String title       = "";

//    out.print(myQuery);

// Create a new paymentform
    htmTb.setWidth("775");
    RWInputForm pFrm = new RWInputForm();
    pFrm.setFormName("payment");

    ResultSet pRs = io.opnRS(myQuery);
    iForm.append(htmTb.startTable("775"));
    iForm.append(htmTb.startRow());
    iForm.append(htmTb.headingCell("Date", "width=75"));
    iForm.append(htmTb.headingCell("Description", "width=225"));
    iForm.append(htmTb.headingCell("Charge<br>Amount", htmTb.RIGHT, "width=75"));
    iForm.append(htmTb.headingCell("Recvd<br>Amount", htmTb.RIGHT, "width=75"));
    iForm.append(htmTb.headingCell("Balance", htmTb.RIGHT, "width=75"));
    iForm.append(htmTb.headingCell("Copay", "width=75"));
//    iForm.append(htmTb.headingCell("Check Number", "width=80"));
    iForm.append(htmTb.headingCell("Trans<br> Amount", "width=75"));
//    iForm.append(htmTb.headingCell("Writeoff", "width=60"));
    if(bulkPayments == null) { iForm.append(htmTb.headingCell("Pat<br>Amt", "width=75")); }
    iForm.append(htmTb.headingCell("Provider", "width=100"));
    iForm.append(htmTb.endRow());
    iForm.append(htmTb.endTable());

    String chargeId="0";
    iForm.append("<div style=\" height: 300; width: 795; overflow: auto;\">");
    iForm.append(htmTb.startTable("775"));
    String rowColor="lightgrey";
    while (pRs.next()) {
        chargeId=pRs.getString("id");
        String defaultPayment="";
        String copayAmount="0.00";

        // 03-09-07 if we're processing co-pay, apply default payments to co-pay items only
        if(request.getParameter("coPay") == null) {
            if(availableToPost > 0.0) {

                BigDecimal bDDefaultPayment = patient.getDefaultPayment(pRs.getInt("itemid"), Integer.parseInt(providerId));
                BigDecimal bDCopay= patient.getCopay(pRs.getInt("itemid"), Integer.parseInt(providerId));
                defaultPayment = ""+bDDefaultPayment;
                copayAmount = ""+bDCopay;
                double balance=pRs.getDouble("balance");
                if (balance < bDDefaultPayment.doubleValue() || bDDefaultPayment.doubleValue()==0.0) {
                    defaultPayment=pRs.getString("balance");
                }
                double dpDouble = Double.valueOf(defaultPayment).doubleValue();
                if (availableToPost<dpDouble ) {
                    defaultPayment="" + availableToPost;
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

        if(defaultPayment.equals("")) { defaultPayment="0.00"; }
        if(copayAmount.equals("")) { copayAmount="0.00"; }
        double woAmtDouble = pRs.getDouble("balance")-Double.valueOf(defaultPayment).doubleValue()-Double.valueOf(copayAmount).doubleValue();
        if (woAmtDouble<0 || availableToPost<=0) {woAmtDouble=0;}
        BigDecimal woAmtBD = BigDecimal.valueOf(woAmtDouble);
        String woAmount=woAmtBD.toPlainString();

//        BigDecimal bDCopay = patient.getCopay(pRs.getInt("itemid"), Integer.parseInt(providerId));
//        String copay = ""+bDCopay;

        defaultPayment="0.0";

        iForm.append(htmTb.startRow("bgcolor="+rowColor));
        iForm.append(htmTb.addCell(Format.formatDate(pRs.getString("date"), "MM/dd/yy")+frm.hidden(paymentDate,"date"+chargeId),htmTb.CENTER, "width=50"));
        iForm.append(htmTb.addCell(pRs.getString("description"), "width=250"));
//        iForm.append(htmTb.addCell(copayAmount, 1, "width=50"));
        iForm.append(htmTb.addCell(Format.formatCurrency(pRs.getString("chargeamount")), htmTb.RIGHT, "width=75"));
        iForm.append(htmTb.addCell(Format.formatCurrency(pRs.getString("paidamount")), htmTb.RIGHT, "width=75"));
        iForm.append(htmTb.addCell(Format.formatCurrency(pRs.getString("balance")), htmTb.RIGHT, "valign=middle width=75 id=bal"+chargeId));
        iForm.append(htmTb.addCell(Format.formatCurrency(pRs.getString("copayamount")), 1, "width=50"));
        iForm.append(htmTb.addCell(frm.textBox(checkNumber, "checkNumber"+chargeId, "15","15","class=tBoxText"), 2, "style=\"visibility: hidden; display: none;\" width=0"));
        iForm.append(htmTb.addCell(frm.textBox(tools.utils.Format.formatCurrency(defaultPayment), "checkAmount"+chargeId, "10","10","style='text-align: right;' class=tBoxText onBlur=\"this.value=formatCurrency(this.value);calcPatAmt(this)\""), htmTb.RIGHT, "width=75"));
        iForm.append(htmTb.addCell(frm.textBox(tools.utils.Format.formatCurrency(woAmount), "woAmount"+chargeId, "10","10","style='text-align: right;' class=tBoxText onBlur=\"this.value=formatCurrency(this.value);calcPatAmt(this)\""), htmTb.RIGHT, "style=\"visibility: hidden; display: none;\" width=0"));
        if(bulkPayments == null) { iForm.append(htmTb.addCell(frm.textBox(tools.utils.Format.formatCurrency(copayAmount), "patAmount"+chargeId, "10","10","style='text-align: right;' class=tBoxText onFocus=this.select() onBlur=\"this.value=formatCurrency(this.value);calcWoAmt(this);\""), htmTb.RIGHT, "width=75")); }
        lRs.beforeFirst();
        iForm.append(htmTb.addCell(frm.comboBox(lRs,"providerId"+chargeId,"id",false,"1",preload2,providerId,"class=cBoxText style='width:90px' READONLY"), 2,"width=100"));
        iForm.append(htmTb.endRow());
        if (rowColor.equals("lightgrey")) {
            rowColor="#cccccc";
        } else {
            rowColor="lightgrey";
        }
        // Hidden Date Field
        iForm.append(frm.hidden(Format.formatDate(paymentDate,"yyyy-MM-dd"), "date"+chargeId));

    }
    iForm.append(htmTb.endTable());
    iForm.append("</div>");

// Everything we need is inside the form.  Close it up.
    iForm.append(frm.endForm());

    iForm.append("<br>" + frm.button("Post Payments","class=button onclick=postPayments(\"postcashpayments.jsp?parentPayment="+parentPayment+"\")","Filter"));

// Spit the results out to the browser
    out.print(iForm.toString());
    
// Save the session variables
    if(batchId == null || batchId.equals("") || today == null || today.equals("")) {
        session.setAttribute("returnUrl", "applypayments.jsp");
    }
%>
<%
    if(multiplePayments == null && request.getParameter("posted")!=null && request.getParameter("posted").equalsIgnoreCase("Y")) { %>
        <body onLoad="self.close()">
        <body>
<%  } else if(multiplePayments != null && request.getParameter("posted") != null) {
        response.sendRedirect("applymultiplepayments.jsp");
    } else {   %>
        <body onUnLoad="refreshParentPage('<%= (String)session.getAttribute("myParent") %>')">
<%  } 
%>

</body>