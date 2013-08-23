<%-- 
    Document   : applybatchpayments
    Created on : Jan 18, 2008, 10:28:34 AM
    Author     : Randy
--%>

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
//    alert(frmInput.elements['patAmount'+suffix].hasFocus())
//    if (frmInput.elements['patAmount'+suffix].hasFocus()) {
//        frmInput.elements['patAmount'+suffix].select()
//    }
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
    String multiplePayments = (String)session.getAttribute("multiplePayments");
    String[] preload={"*UNASSIGNED"};
    String[] preload2={};
    StringBuffer iForm = new StringBuffer();
    
    String startDate = "01/01/1901";
    String endDate = "12/31/2100";
    String paymentDate = Format.formatDate(new java.util.Date(), "MM/dd/yyyy");
    String providerId = "2";
    String batchId = "";
    String checkNumber = "";
    String checkAmount = "0.00";
    String patientName = "";
    String parentPayment = "0";
    String typeDescription = "Payment Amount:";
    double availableToPost = 0.0;
    
// If parameters were passed, use them
    if (request.getParameter("providerId")!=null) {
        providerId=request.getParameter("providerId");
    }

    if (request.getParameter("checkNumber")!=null) {
        checkNumber=request.getParameter("checkNumber");
    }
    
    if (request.getParameter("checkAmount")!=null) {
        checkAmount=request.getParameter("checkAmount");
        try {
            availableToPost=Double.parseDouble(checkAmount.replaceAll("\\$","").replaceAll(",",""));
        } catch (Exception e) {
        }
    }

    if(request.getParameter("paymentDate") != null) {
        paymentDate=Format.formatDate(request.getParameter("paymentDate"), "MM/dd/yyyy");
    }
    
    if(request.getParameter("batchId") != null) {
        batchId=request.getParameter("batchId");
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
    ResultSet lRs = io.opnRS("select id, name from providers where id=" + providerId);
    
// Print The Title
    out.print("<H1>Apply Payments for Batch: " + batchId + " (Check #: " + checkNumber + " Amount: " + checkAmount + ")</H1>");
    
// Build the form now
    iForm.append(frm.startForm());
    
// Now, the hidden stuff
    iForm.append(frm.hidden(providerId,"providerId"));
    iForm.append(frm.hidden(checkNumber,"checkNumber"));
    iForm.append(frm.hidden(checkAmount,"checkAmount"));

// Now, tack on the filtered list containing all patients that may qualify to have their charges paid by this check
    myQuery     = "select pb.id, c.itemid, pb.date, patients.lastname, patients.firstname, pb.description, " + 
                  "pb.chargeamount, pb.paidamount, pb.balance " +
                  "from batches b " +
                  "left join providers p on p.id=b.provider " +
                  "left join batchcharges bc on bc.batchid=b.id " +
                  "left join patientbalance pb on pb.id=bc.chargeid " +
                  "left join patients on patients.id=pb.patientid " + 
                  "left join charges c on c.id=pb.id " +
                  "where b.id=" + batchId + 
                  " order by lastname, firstname, pb.date ";
    
    String url         = "applybatchpayments.jsp?checkNumber="+checkNumber+"&checkAmount="+checkAmount+"&startDate="+startDate+"&endDate="+endDate;
    String title       = "";

// Create a new paymentform
    htmTb.setWidth("900");
    RWInputForm pFrm = new RWInputForm();
    pFrm.setFormName("payment");

    ResultSet pRs = io.opnRS(myQuery);
    iForm.append(htmTb.startTable());
    iForm.append(htmTb.startRow());
    iForm.append(htmTb.headingCell("Date", "width=50"));
    iForm.append(htmTb.headingCell("Patient Name", "width=100"));
    iForm.append(htmTb.headingCell("Description", "width=250"));
    iForm.append(htmTb.headingCell("Copay", "width=50"));
    iForm.append(htmTb.headingCell("Charge Amount", "width=50"));
    iForm.append(htmTb.headingCell("Paid Amount", "width=50"));
    iForm.append(htmTb.headingCell("Bal", "width=50"));
    iForm.append(htmTb.headingCell("Check<br>Number", "width=80"));
    iForm.append(htmTb.headingCell("Payment<br> Amount", "width=60"));
    iForm.append(htmTb.headingCell("Writeoff", "width=60"));
    iForm.append(htmTb.headingCell("Pat Amt", "width=60"));
    iForm.append(htmTb.headingCell("Provider", "width=90"));
    iForm.append(htmTb.endRow());
    iForm.append(htmTb.endTable());

    String chargeId="0";
    iForm.append("<div style=\" height: 300; width: 920; overflow: auto;\">");
    iForm.append(htmTb.startTable());
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

        iForm.append(htmTb.startRow("bgcolor="+rowColor));
        iForm.append(htmTb.addCell(Format.formatDate(pRs.getString("date"), "MM/dd/yy"), "width=50"));
        iForm.append(htmTb.addCell(pRs.getString("lastname") + ", " + pRs.getString("firstname"), "width=100"));      
        iForm.append(htmTb.addCell(pRs.getString("description"), "width=300"));
        iForm.append(htmTb.addCell(Format.formatCurrency(copayAmount), 1, "width=50"));
        iForm.append(htmTb.addCell(Format.formatCurrency(pRs.getString("chargeamount")), 1, "width=50"));
        iForm.append(htmTb.addCell(Format.formatCurrency(pRs.getString("paidamount")), 1, "width=50"));
        iForm.append(htmTb.addCell(Format.formatCurrency(pRs.getString("balance")), 1, "valign=middle width=50 id=bal"+chargeId));
        iForm.append(htmTb.addCell(frm.textBox(checkNumber, "checkNumber"+chargeId, "10","10","class=tBoxText"), 2, "width=80"));
        iForm.append(htmTb.addCell(frm.textBox(tools.utils.Format.formatCurrency(defaultPayment), "checkAmount"+chargeId, "8","8","style='text-align: right;' class=tBoxText onBlur=\"this.value=formatCurrency(this.value);calcPatAmt(this)\""), 2, "width=60"));
        iForm.append(htmTb.addCell(frm.textBox(tools.utils.Format.formatCurrency(woAmount), "woAmount"+chargeId, "8","8","style='text-align: right;' class=tBoxText onBlur=\"this.value=formatCurrency(this.value);calcPatAmt(this)\""), 2, "width=60"));
        iForm.append(htmTb.addCell(frm.textBox(tools.utils.Format.formatCurrency(copayAmount), "patAmount"+chargeId, "8","8","style='text-align: right;' class=tBoxText onFocus=this.select() onBlur=\"this.value=formatCurrency(this.value);\""), 2, "width=60"));
        lRs.beforeFirst();
        iForm.append(htmTb.addCell(frm.comboBox(lRs,"providerId"+chargeId,"id",false,"1",preload2,providerId,"class=cBoxText style='width:90px'"), 2,"width=90"));
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

    iForm.append("<br>" + frm.button("Post Payments","class=button onclick=postPayments(\"postpayments.jsp?parentPayment="+parentPayment+"\")","Filter"));

// Spit the results out to the browser
    out.print(iForm.toString());
    
// Save the session variables
    session.setAttribute("returnUrl", "applypayments.jsp");
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