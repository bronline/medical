<%--
    Document   : applybatchpayments
    Created on : Jan 18, 2008, 10:28:34 AM
    Author     : Randy
--%>

<%@include file="globalvariables.jsp" %>

<title>Apply Payments</title>
<style type="text/css">
    .postingItem { font-size: 11; }
</style>
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
//    frmInput.elements['patAmount'+suffix].value=formatCurrency(patAmt)
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

    if (request.getParameter("startDate")!=null) {
        startDate=request.getParameter("startDate");
    }
    if (request.getParameter("endDate")!=null) {
        endDate=request.getParameter("endDate");
    }

    if (request.getParameter("paymentDate") != null) {
        paymentDate=Format.formatDate(request.getParameter("paymentDate"), "yyyy-MM-dd");
    }

// Build the patient list
    String patientList="";
    String var="";
    ArrayList elem = new ArrayList();

    for(Enumeration e = request.getParameterNames(); e.hasMoreElements();) {
       var=(String)e.nextElement();
       if(var.length()>=3 && var.substring(0,3).equals("chk")) { elem.add(var.substring(3)); }
    }

    for(int x=0; x<elem.size(); x++) {
       if(!patientList.equals("")) { patientList += ", "; }
       patientList +=(String)elem.get(x);
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

// Build the form now
    iForm.append(frm.startForm());

// Now, the hidden stuff
    iForm.append(frm.hidden(providerId,"providerId"));
    iForm.append(frm.hidden(checkNumber,"checkNumber"));
    iForm.append(frm.hidden(checkAmount,"checkAmount"));

// Now, tack on the filtered list containing all patients that may qualify to have their charges paid by this check
    myQuery   = "select a.id, a.itemid, b.date, c.lastname, c.firstname, " +
                "concat(case when code<>'' then concat(d.code,' - ') else '' end,d.description) as description, " +
                "a.chargeamount*a.quantity as chargeamount, ifnull(paidamount,0) paidamount, " +
                "cast((a.chargeamount*a.quantity)-ifnull(paidamount,0) as decimal(6, 2)) balance, e.patientid " +
                "from charges a join batchcharges w on a.id=w.chargeid join " +
                "items d on a.itemid=d.id join visits b on a.visitid=b.id join patients c on b.patientid=c.id " +
                "left outer join (SELECT patientid, chargeid, sum(amount) paidamount FROM payments p " +
                "group by patientid, chargeid) e on a.id=e.chargeid " +
                "where (paidamount<>chargeamount or paidamount is null) and b.patientid in ( " + patientList + ") " +
                " and date >= '" + Format.formatDate(startDate, "yyyy-MM-dd") + "' " +
                " and date <= '" + Format.formatDate(endDate, "yyyy-MM-dd") + "' " +
                " and not complete " +
                " order by lastname, firstname, b.date, a.id";

    String url         = "applybatchpayments.jsp?checkNumber="+checkNumber+"&checkAmount="+checkAmount+"&startDate="+startDate+"&endDate="+endDate;
    String title       = "";

// Create a new paymentform
    htmTb.setWidth("850");
    RWInputForm pFrm = new RWInputForm();
    pFrm.setFormName("payment");

    ResultSet pRs = io.opnRS(myQuery);

    pRs.next();
// Print The Title
    out.print("<H1>Apply Payments for multiple patients (Check #: " + checkNumber + " Amount: " + checkAmount + ")</H1>");
    out.print("<H1>From " + startDate + " to " + endDate + "</H1>");
//    out.print("<H2>Current Patient: "  + pRs.getString("firstname") + " " +  pRs.getString("lastname") + "</h2>");
    iForm.append(htmTb.startTable());
    iForm.append(htmTb.startRow());
    iForm.append(htmTb.headingCell("Date", "width=75"));
    iForm.append(htmTb.headingCell("Patient Name", "width=100"));
    iForm.append(htmTb.headingCell("Description", "width=300"));
//    iForm.append(htmTb.headingCell("Copay", "width=50"));
    iForm.append(htmTb.headingCell("Charge Amount", "width=50"));
    iForm.append(htmTb.headingCell("Recvd Amount", "width=50"));
    iForm.append(htmTb.headingCell("Bal", "width=50"));
    iForm.append(htmTb.headingCell("Check<br>Number", "width=0 style=\"visibility: hidden; display: none;\""));
    iForm.append(htmTb.headingCell("Trans<br>Amount", "width=60"));
    iForm.append(htmTb.headingCell("Writeoff", "width=60"));
//    iForm.append(htmTb.headingCell("Pat Amt", "width=60"));
    iForm.append(htmTb.headingCell("Provider", "width=0 style=\"visibility: hidden; display: none;\""));
    iForm.append(htmTb.headingCell("Comp","width=50"));
    iForm.append(htmTb.endRow());
    iForm.append(htmTb.endTable());

    String chargeId="0";
    iForm.append("<div style=\" height: 300; width: 870; overflow: auto;\">");
    iForm.append(htmTb.startTable());
    String rowColor="#e0e0e0";

    String patDftPmt="select (case when ifnull(d.amount,0)=0 then ifnull(p.amount,0) else d.amount end) as amount, " +
                     "(case when ifnull(d.copay,0)=0 then ifnull(p.copay,0) else d.copay end) as writeoff " +
                     "from items i " +
                     "left join defaultpayments p on p.providerid=? and p.patientid=0 and p.itemid=i.id " +
                     "left join defaultpayments d on d.providerid=? and d.patientid=? and d.itemid=i.id " +
                     "where i.id=?";
    PreparedStatement dftPs=io.getConnection().prepareStatement(patDftPmt);

    htmTb.setCellVAlign("MIDDLE");
    
    pRs.beforeFirst();
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

                dftPs.setString(1, providerId);
                dftPs.setString(2, providerId);
                dftPs.setString(3, pRs.getString("patientid"));
                dftPs.setString(4, pRs.getString("itemid"));

                ResultSet dftRs=dftPs.executeQuery();
                if(dftRs.next()) {
//                    defaultPayment=dftRs.getString("amount");
//                    copayAmount=dftRs.getString("writeoff");
                    bDDefaultPayment=dftRs.getBigDecimal("amount");
                    bDCopay=dftRs.getBigDecimal("writeoff");
                }
                dftRs.close();

                double balance=pRs.getDouble("balance");
                if (balance < bDDefaultPayment.doubleValue() && bDDefaultPayment.doubleValue()!= 0.0) {
//                    defaultPayment=pRs.getString("balance");
                    defaultPayment=""+bDDefaultPayment;
                }
                double dpDouble = Double.valueOf(defaultPayment).doubleValue();
                if (availableToPost<dpDouble ) {
                    defaultPayment="" + availableToPost;
//                    defaultPayment=""+bDDefaultPayment;
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
        double woAmtDouble = 0.0;
        
        if(Double.valueOf(copayAmount).doubleValue()!=0) {
            woAmtDouble=pRs.getDouble("balance")-Double.valueOf(defaultPayment).doubleValue()-Double.valueOf(copayAmount).doubleValue();
        }

        if (woAmtDouble<0 || availableToPost<=0) {woAmtDouble=0;}
        BigDecimal woAmtBD = BigDecimal.valueOf(woAmtDouble);
        String woAmount=woAmtBD.toPlainString();

        iForm.append(htmTb.startRow("bgcolor="+rowColor));
        iForm.append(htmTb.addCell(Format.formatDate(pRs.getString("date"), "MM/dd/yy"), "width=75 class=\"postingItem\""));
        iForm.append(htmTb.addCell(pRs.getString("lastname") + ", " + pRs.getString("firstname"), "width=100 class=\"postingItem\""));
        iForm.append(htmTb.addCell(pRs.getString("description"), "width=300 class=\"postingItem\""));
//        iForm.append(htmTb.addCell(Format.formatCurrency(copayAmount), 1, "width=50"));
        iForm.append(htmTb.addCell(Format.formatCurrency(pRs.getString("chargeamount")), 1, "width=50 class=\"postingItem\""));
        iForm.append(htmTb.addCell(Format.formatCurrency(pRs.getString("paidamount")), 1, "width=50 class=\"postingItem\""));
        iForm.append(htmTb.addCell(Format.formatCurrency(pRs.getString("balance")), 1, "valign=middle width=50 class=\"postingItem\" id=bal"+chargeId));
        iForm.append(htmTb.addCell(frm.textBox(checkNumber, "checkNumber"+chargeId, "10","10","class=tBoxText"), 2, "width=0 style=\"visibility: hidden; display: none;\""));
        iForm.append(htmTb.addCell(frm.textBox(tools.utils.Format.formatCurrency(defaultPayment), "checkAmount"+chargeId, "8","8","style='text-align: right;' class=tBoxText onBlur=\"this.value=formatCurrency(this.value);calcPatAmt(this)\""), 2, "width=60 class=\"postingItem\""));
        iForm.append(htmTb.addCell(frm.textBox(tools.utils.Format.formatCurrency(woAmount), "woAmount"+chargeId, "8","8","style='text-align: right;' class=tBoxText onBlur=\"this.value=formatCurrency(this.value);calcPatAmt(this)\"")+ frm.hidden(copayAmount, "patAmount"+chargeId), 2, "width=60 class=\"postingItem\""));
//        iForm.append(htmTb.addCell(frm.textBox(tools.utils.Format.formatCurrency(copayAmount), "patAmount"+chargeId, "8","8","style='text-align: right;' class=tBoxText onFocus=this.select() onBlur=\"this.value=formatCurrency(this.value);\""), 2, "width=60"));
        lRs.beforeFirst();
        iForm.append(htmTb.addCell(frm.comboBox(lRs,"providerId"+chargeId,"id",false,"1",preload2,providerId,"class=cBoxText style='width: 90px;'"), 2,"width=0 style=\"visibility: hidden; display: none;\""));
        iForm.append(htmTb.addCell("<input type=\"checkbox\" name=\"chk" + chargeId + "\" id=\"chk" + chargeId + "\">","width=\"50\""));
        iForm.append(htmTb.endRow());
        if (rowColor.equals("#e0e0e0")) {
            rowColor="#bbbbbb";
        } else {
            rowColor="#e0e0e0";
        }
        // Hidden Date Field
        iForm.append(frm.hidden(Format.formatDate(paymentDate,"yyyy-MM-dd"), "date"+chargeId));

    }
    iForm.append(htmTb.endTable());
    iForm.append("</div>");

// Everything we need is inside the form.  Close it up.
    iForm.append(frm.endForm());

    iForm.append("<br>" + frm.button("Post Payments","class=button onclick=postPayments(\"postpaymentwizard.jsp?parentPayment="+parentPayment+"\")","Filter"));

// Spit the results out to the browser
    out.print(iForm.toString());

// Save the session variables
    session.setAttribute("returnUrl", "applymultpatpayments.jsp");
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