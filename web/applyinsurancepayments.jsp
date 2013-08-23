<%--
    Document   : applyinsurancepayments
    Created on : Nov 15, 2010, 3:54:33 PM
    Author     : rwandell
--%>

<%@page contentType="text/html" pageEncoding="windows-1252"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
<%@include file="globalvariables.jsp" %>

<title>Apply Payments</title>
<style type="text/css">
    #payerNotes { color: red; }
</style>

<script language="javascript">
<%
    int eobReasonCount=0;
    String eobArray="";
    ResultSet eRs1=io.opnRS("SELECT 0 as reasonid, ' ' as description, ' ' as type union select id as reasonid, description, type from eobreasons");
    while(eRs1.next()) {
        eobArray += "  eobArray[" + eRs1.getString("reasonid") + "]='" + eRs1.getString("type") + "';\n";
        eobReasonCount ++;
    }
    out.print("  var eobArray=new Array();\n");
    out.print(eobArray);
%>
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
    var checkAmount=+document.getElementById("checkAmount").value
    var frmA=document.forms["frmInput"]
    for (i=0;i<frmA.elements.length;i++) {
        itemName=frmA.elements[i].name
        if (itemName!=null && itemName.length>11 && itemName.substring(0,11)=='checkAmount') {
            total+= +Number(frmA.elements[i].value.replace('$','').replace(',',''))
        }
    }
    if (total > checkAmount) {
        doPost = confirm('You are trying to apply ' + formatCurrency(total) + ' but the payment amount is only ' + formatCurrency(checkAmount) + '.  Do you want to continue?')
    } else {
        doPost = true
    }
    if (doPost) {
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
  function calcWoAmt(field,currentDOS) {
/*
    var patAmt=0
    suffix=""
    if (field.name.substring(0,11)=="checkAmount") {
        suffix=field.name.substring(11)
    }
    if (field.name.substring(0,9)=="patAmount") {
        suffix=field.name.substring(9)
    }
    patAmt=Number(document.getElementById('bal'+suffix).innerHTML.replace('$','').replace(',',''))
    patAmt=patAmt-Number(document.getElementById('checkAmount'+suffix).value.replace('$','').replace(',',''))
    patAmt=patAmt-Number(document.getElementById('patAmount'+suffix).value.replace('$','').replace(',',''))
    if (patAmt<0 || (Number(document.getElementById('checkAmount'+suffix).value.replace('$','').replace(',',''))+Number(document.getElementById('patAmount'+suffix).value.replace('$','').replace(',',''))==0)) {
      patAmt=0
    }
    document.getElementById('adjAmount'+suffix).value=formatCurrency(patAmt)
*/
    totalPayments(currentDOS);

  }

  function calcPatAmt(field,currentDOS) {

    var patAmt=0
    suffix=""
    if (field.name.substring(0,11)=="checkAmount") {
        suffix=field.name.substring(11)
    }
    if (field.name.substring(0,9)=="adjAmount") {
        suffix=field.name.substring(9)
    }
    patAmt=Number(document.getElementById('bal'+suffix).innerHTML.replace('$','').replace(',',''))
    patAmt=patAmt-Number(document.getElementById('checkAmount'+suffix).value.replace('$','').replace(',',''))
    patAmt=patAmt-Number(document.getElementById('adjAmount'+suffix).value.replace('$','').replace(',',''))
//    if (patAmt<0 || Number(document.getElementById('checkAmount'+suffix).value.replace('$','').replace(',',''))==0) {
//      patAmt=0
//    }

    document.getElementById('patAmount'+suffix).value=formatCurrency(patAmt)

    totalPayments(currentDOS);

  }

  function totalPayments(currentDOS) {
    var names=document.getElementsByTagName('input');
    var suffix="";
    var checkTotal=0.0;
    var patientTotal=0.0;
    var adjustmentTotal=0.0;
    var adjustmentsTotal=0.0;

    for(x=0;x<names.length;x++) {
        try {
            if(names[x].type != 'button') {
                if(names[x].name.substr(0,3)=='dos') {
                    if(document.getElementById(names[x].name).value==currentDOS) {
                        suffix=names[x].name.substr(3);
                        checkTotal=checkTotal+Number(document.getElementById('checkAmount'+suffix).value.replace('$','').replace(',',''));
                        patientTotal=patientTotal+Number(document.getElementById('patAmount'+suffix).value.replace('$','').replace(',',''));
                        adjustmentTotal=adjustmentTotal+Number(document.getElementById('adjAmount'+suffix).value.replace('$','').replace(',',''));
//                        if(checkTotal+patientTotal!=0) { adjustmentsTotal=adjustmentsTotal+Number(document.getElementById('adjAmount'+suffix).value.replace('$','').replace(',','')); }
                    }
                }
            }
        } catch (err) {}
    }

    document.getElementById("payments"+currentDOS).value=formatCurrency(checkTotal);
    document.getElementById("patients"+currentDOS).value=formatCurrency(patientTotal);
    document.getElementById("adjustments"+currentDOS).value=formatCurrency(adjustmentTotal);
//    document.getElementById("adjustment"+currentDOS).value=formatCurrency(adjustmentsTotal);

//    Number(frmInput.elements['checkAmount'+suffix].value.replace('$','').replace(',',''));
//    alert(paymentDate);
  }

  function calculateAdjustmentAmount(what,currentDOS) {
    var eobReasonIndex=what.selectedIndex;
    var chargeId=what.name.substr(11);
    var names=document.getElementsByTagName('input');
    var suffix="";

    var deductableTotal=0.0;
    var adjustmentsTotal=0.0;
    var patientAmount=0.0;

    document.getElementById("eobReasonType" + chargeId).value=eobArray[eobReasonIndex];

    if(eobArray[eobReasonIndex] != ' ') {
        for(x=0;x<names.length;x++) {
            try {
                if(names[x].type != 'button') {
                    if(names[x].name.substr(0,3)=='dos') {
                        if(document.getElementById(names[x].name).value==currentDOS && suffix == "") {
                            suffix=names[x].name.substr(3);
                            patientAmount=Number(document.getElementById('bal'+suffix).innerHTML.replace('$','').replace(',',''))-Number(document.getElementById('checkAmount'+suffix).value.replace('$','').replace(',',''))-Number(document.getElementById('adjAmount'+suffix).value.replace('$','').replace(',',''))
                            if(document.getElementById("eobReasonType" + suffix).value == 'A') { adjustmentsTotal=adjustmentsTotal+Number(document.getElementById('adjAmount'+suffix).value.replace('$','').replace(',','')); }
                            if(document.getElementById("eobReasonType" + suffix).value == 'D') { deductableTotal=deductableTotal+Number(document.getElementById('adjAmount'+suffix).value.replace('$','').replace(',','')); }
                            document.getElementById("patAmount"+suffix).value=formatCurrency(patientAmount);
                        }
                    }
                }
            } catch (err) {}
        }
    }

    document.getElementById("deductable"+currentDOS).value=formatCurrency(deductableTotal);
    document.getElementById("adjustment"+currentDOS).value=formatCurrency(adjustmentsTotal);

  }

  function billSecondary(batchId,providerId,patientId) {
    var url = "ajax/billsecondary.jsp?batchId=" + batchId + "&providerId=" + providerId + "&patientId=" + patientId;
    var objName = "#secondary"+providerId;
    $.ajax({
        url: url,
        success: function (data) {
            alert("batch " + data.trim() + " has been created");
            $(objName).html('billed in batch ' + data.trim());
        },
        complete: function(data){
            
        },
        error: function() {
            alert("There was a problem processing the request");
        }
    });
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
    String batchMessage = "";

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
    ResultSet bMsgRs = io.opnRS("SELECT * FROM billbatchcomments WHERE batchid=" + batchId + " AND patientid=" + patientId);
    if(bMsgRs.next()) { batchMessage = bMsgRs.getString("comments"); }
    bMsgRs.close();

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
    if(checkAmount == null || checkAmount.trim().equals("")) { checkAmount="0.0"; }
    out.print("<H1>Apply Payments for " + patientName + ", " + typeDescription +  " " + Format.formatCurrency(checkAmount) + "</H1>");

// Build the form now
    iForm.append(frm.startForm());

    ResultSet iMsgRs = io.opnRS("SELECT p.name, ifnull(i.notes,'') as notes FROM patientinsurance i left join providers p on i.providerid=p.id where i.patientid=" + patient.getId() + " and i.providerid=" + providerId);
    if(iMsgRs.next()) {
        iForm.append("<fieldset style=\"width: 750px; border: 1px solid #666; padding: 10px;\"><legend><b>Notes for " + iMsgRs.getString("name") + "</b></legend>");
        iForm.append("<textarea id=\"payerNotes\" name=\"payerNotes\" rows=\"3\" cols=\"175\" class=\"tAreaText\">" + iMsgRs.getString("notes") + "</textarea>");
        iForm.append("</fieldset>");
    }
    iMsgRs.close();

    iForm.append("<fieldset style=\"width: 750px; border: 1px solid #666; padding: 10px;\"><legend><b>Notes specific to this batch</b></legend>");
    iForm.append(htmTb.addCell("<textarea id=\"batchNotes\" + name=\"batchNotes\" rows=\"2\" cols=\"175\" class=\"tAreaText\">" + batchMessage + "</textarea>", htmTb.RIGHT, "width=\"625\""));
    iForm.append("</fieldset>");

// Now, the groupbox with the Service Dates
    String supplementalInsurances = getSupplementalInsurance(io, patient.getId(), providerId, batchId);
    if(!supplementalInsurances.trim().equals("")) {
        iForm.append("<fieldset style=\"width: 750px; border: 1px solid #666; padding: 10px;\"><legend><b>Secondary Insurances</b></legend>");
//        iForm.append(htmTb.startTable("750"));
//        iForm.append(htmTb.startRow());
    //    iForm.append(htmTb.addCell("<b>Start Date", "width=\"100px\""));
    //    iForm.append(htmTb.addCell(frm.date(startDate,"startDate","width=\"175px\" class=\"tBoxText\"")));
//        iForm.append(htmTb.startCell(""));
//        iForm.append("<div style=\"height: 30px; width: 400px; overflow: auto;\">");
        iForm.append(supplementalInsurances);
//        iForm.append("</div>");
//        iForm.append(htmTb.endCell());
//        iForm.append(htmTb.endRow());

    //    iForm.append(htmTb.startRow());
    //    iForm.append(htmTb.addCell("<b>End Date", "width=\"100px\""));
    //    iForm.append(htmTb.addCell(frm.date(endDate,"endDate","width=\"175px\" class=\"tBoxText\"")));
//        iForm.append(htmTb.endRow());

//        iForm.append(htmTb.endTable());
        iForm.append("</fieldset>");
    }

    iForm.append("<br/>");
    
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
//        whereClause += " and a.id in (select chargeid from batchcharges where batchid=" + batchId + " and not complete)";
        whereClause += " and w.batchid=" + batchId + " and not w.complete ";
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
                      "left outer join (SELECT patientid, chargeid, sum(amount) paidamount FROM payments p where chargeid<>0 " +
                      "group by patientid, chargeid) e on a.id=e.chargeid ";
    }

    ResultSet eRs=io.opnRS("SELECT 0 as reasonid, ' ' as description union select id as reasonid, description from eobreasons");

    myQuery = myQuery + whereClause + " order by a.id";

    String url         = "applypayments.jsp?checkNumber="+checkNumber+"&checkAmount="+checkAmount+"&startDate="+startDate+"&endDate="+endDate;
    String title       = "";

//    out.print(myQuery);

// Create a new paymentform
    htmTb.setWidth("725");
    RWInputForm pFrm = new RWInputForm();
    pFrm.setFormName("payment");

    ResultSet pRs = io.opnRS(myQuery);
    iForm.append(htmTb.startTable("750"));
    iForm.append(htmTb.startRow());
    iForm.append(htmTb.headingCell("Date", "width=58"));
    iForm.append(htmTb.headingCell("Description", "width=276"));
    iForm.append(htmTb.headingCell("Chg<br>Amt", htmTb.RIGHT, "width=58"));
    iForm.append(htmTb.headingCell("Rcvd<br>Amt", htmTb.RIGHT, "width=58"));
    iForm.append(htmTb.headingCell("Bal", htmTb.RIGHT, "width=58"));
    iForm.append(htmTb.headingCell("Pmt<br> Amt", htmTb.RIGHT, "width=71"));
    iForm.append(htmTb.headingCell("Adj<br>Amt", htmTb.RIGHT, "width=71"));
    iForm.append(htmTb.headingCell("Pat<br>Resp", htmTb.RIGHT, "width=71"));
    iForm.append(htmTb.headingCell("Patient<br>Resp Reason", "width=100"));
    iForm.append(htmTb.headingCell("Comp", "width=25"));
    iForm.append(htmTb.endRow());
    iForm.append(htmTb.endTable());

    String chargeId="0";
    iForm.append("<div style=\"height: 300px; width: 795; overflow: auto;\">");
    iForm.append(htmTb.startTable("750"));

    String rowColor="#e0e0e0";
    String currentDateOfService="";
    int tabIndex=1;

    while (pRs.next()) {
        chargeId=pRs.getString("id");
        String defaultPayment="";
        String copayAmount="0.00";

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

        if(defaultPayment.equals("")) { defaultPayment="0.00"; }
        if(copayAmount.equals("")) { copayAmount="0.00"; }
        double woAmtDouble = pRs.getDouble("balance")-Double.valueOf(defaultPayment).doubleValue()-Double.valueOf(copayAmount).doubleValue();
        if (woAmtDouble<0 || availableToPost<=0) {woAmtDouble=0;}
        BigDecimal woAmtBD = BigDecimal.valueOf(woAmtDouble);
        String adjAmount=woAmtBD.toPlainString();

        defaultPayment="0.0";
        adjAmount="0.0";

        if(currentDateOfService.equals("")) { currentDateOfService=pRs.getString("date"); }
        else if(!currentDateOfService.equals(pRs.getString("date"))) {
            iForm.append(htmTb.startRow());
            iForm.append(htmTb.addCell(""));
            iForm.append(htmTb.addCell(""));
            iForm.append(htmTb.addCell("<b>Deductable</b>", htmTb.RIGHT, "style=\"visibility: hidden;\""));
            iForm.append(htmTb.addCell(frm.textBox("$0.00","deductable" + Format.formatDate(currentDateOfService,"yyyyMMdd"),"7","7","style='text-align: right; ' tabindex=\"" + tabIndex + "\" class=tBoxText READONLY" ), htmTb.RIGHT, "style=\"visibility: hidden;\""));
            iForm.append(htmTb.addCell("<b>Pmt Amt</b>", htmTb.RIGHT));
            iForm.append(htmTb.addCell(frm.textBox("$0.00","payments" + Format.formatDate(currentDateOfService,"yyyyMMdd"),"7","7","style='text-align: right; ' class=tBoxText READONLY" ), htmTb.RIGHT, "width=\"60\""));
            iForm.append(htmTb.addCell(frm.textBox("$0.00","adjustments" + Format.formatDate(currentDateOfService,"yyyyMMdd"),"7","7","style='text-align: right; ' class=tBoxText READONLY" ), htmTb.RIGHT, "width=\"60\""));
            iForm.append(htmTb.addCell(frm.textBox("$0.00","patients" + Format.formatDate(currentDateOfService,"yyyyMMdd"),"7","7","style='text-align: right; ' class=tBoxText READONLY" ), htmTb.RIGHT, "width=\"60\""));
            iForm.append(htmTb.addCell("<b>Adj Amt</b> " +frm.textBox("$0.00","adjustment" + Format.formatDate(currentDateOfService,"yyyyMMdd"),"7","7","style='text-align: right; ' class=tBoxText READONLY" ), htmTb.RIGHT, "style=\"visibility: hidden;\""));
            iForm.append(htmTb.endRow());

            iForm.append(htmTb.startRow("height=\"15\""));
            iForm.append(htmTb.addCell("","colspan=9"));
            iForm.append(htmTb.endRow());
            currentDateOfService=pRs.getString("date");
            tabIndex++;
        }

        iForm.append(htmTb.startRow("bgcolor="+rowColor));
        iForm.append(htmTb.addCell(Format.formatDate(pRs.getString("date"), "MM/dd/yy")+frm.hidden(paymentDate,"date"+chargeId)+frm.hidden(Format.formatDate(currentDateOfService,"yyyyMMdd"),"dos"+chargeId),htmTb.CENTER, "width=60"));
        iForm.append(htmTb.addCell(pRs.getString("description"), "width=290"));
        iForm.append(htmTb.addCell(Format.formatCurrency(pRs.getString("chargeamount")), htmTb.RIGHT, "width=60"));
        iForm.append(htmTb.addCell(Format.formatCurrency(pRs.getString("paidamount")), htmTb.RIGHT, "width=60"));
        iForm.append(htmTb.addCell(Format.formatCurrency(pRs.getString("balance")), htmTb.RIGHT, "valign=middle width=60 id=bal"+chargeId));
        iForm.append(htmTb.addCell(frm.textBox(checkNumber, "checkNumber"+chargeId, "15","15","class=tBoxText"), 2, "style=\"visibility: hidden; display: none;\" width=0"));
        iForm.append(htmTb.addCell(frm.textBox(tools.utils.Format.formatCurrency(defaultPayment), "checkAmount"+chargeId, "7","7","tabindex=\"" + tabIndex + "\" style='text-align: right;' class=tBoxText onBlur=\"this.value=formatCurrency(this.value); calcPatAmt(this,'" + Format.formatDate(currentDateOfService,"yyyyMMdd") + "')\""), htmTb.RIGHT, "width=\"60\""));
        iForm.append(htmTb.addCell(frm.textBox(tools.utils.Format.formatCurrency(adjAmount), "adjAmount"+chargeId, "7","7","tabindex=\"" + (tabIndex+1) + "\" style='text-align: right;' class=tBoxText onBlur=\"this.value=formatCurrency(this.value); calcPatAmt(this,'" + Format.formatDate(currentDateOfService,"yyyyMMdd") + "')\""), htmTb.RIGHT, "width=60"));
        if(bulkPayments == null) { iForm.append(htmTb.addCell(frm.textBox(tools.utils.Format.formatCurrency(copayAmount), "patAmount"+chargeId, "7","7","tabindex=\"" + (tabIndex+2) + "\" style='text-align: right;' class=tBoxText onFocus=this.select() READONLY onBlur=\"this.value=formatCurrency(this.value);calcWoAmt(this,'" + Format.formatDate(currentDateOfService,"yyyyMMdd") + "');\""), htmTb.RIGHT, "width=\"60\"")); }
        lRs.beforeFirst();
        iForm.append(htmTb.addCell(frm.comboBox(eRs,"eobReasonId"+chargeId,"reasonid",false,"1",null,"","class=cBoxText style='width: 90px' onChange=calculateAdjustmentAmount(this,'" +Format.formatDate(currentDateOfService,"yyyyMMdd") + "')") + frm.hidden("", "eobReasonType" + chargeId) + frm.comboBox(lRs,"providerId"+chargeId,"id",false,"1",preload2,providerId,"class=cBoxText style='width: 90px; display: none;' READONLY"), 2,"width=100"));
        iForm.append(htmTb.addCell("<input type=\"checkbox\" i\"chk" + chargeId + "\" name=\"chk" + chargeId + "\"", 2,"width=25"));
        iForm.append(htmTb.endRow());
        if (rowColor.equals("#e0e0e0")) {
            rowColor="#bbbbbb";
        } else {
            rowColor="#e0e0e0";
        }

        tabIndex=tabIndex+3;

    }

    iForm.append(htmTb.startRow());
    iForm.append(htmTb.addCell(""));
    iForm.append(htmTb.addCell(""));
    iForm.append(htmTb.addCell("<b>Deductable</b>", htmTb.RIGHT, "style=\"visibility: hidden;\""));
    iForm.append(htmTb.addCell(frm.textBox("$0.00","deductable" + Format.formatDate(currentDateOfService,"yyyyMMdd"),"7","7","style='text-align: right; ' tabindex=\"" + tabIndex + "\" class=tBoxText onBlur=\"this.value=formatCurrency(this.value)\" READONLY" ), htmTb.RIGHT, "style=\"visibility: hidden;\""));
    iForm.append(htmTb.addCell("<b>Pmt Amt</b>", htmTb.RIGHT));
    iForm.append(htmTb.addCell(frm.textBox("$0.00","payments" + Format.formatDate(currentDateOfService,"yyyyMMdd"),"7","7","style='text-align: right; ' class=tBoxText READONLY" ), htmTb.RIGHT, "width=\"60\""));
    iForm.append(htmTb.addCell(frm.textBox("$0.00","adjustments" + Format.formatDate(currentDateOfService,"yyyyMMdd"),"7","7","style='text-align: right; ' class=tBoxText READONLY" ), htmTb.RIGHT, "width=\"60\""));
    iForm.append(htmTb.addCell(frm.textBox("$0.00","patients" + Format.formatDate(currentDateOfService,"yyyyMMdd"),"7","7","style='text-align: right; ' class=tBoxText READONLY" ), htmTb.RIGHT, "width=\"60\""));
    iForm.append(htmTb.addCell("<b>Adj Amt</b> " +frm.textBox("$0.00","adjustment" + Format.formatDate(currentDateOfService,"yyyyMMdd"),"7","7","style='text-align: right; ' class=tBoxText READONLY" ), htmTb.RIGHT, "style=\"visibility: hidden;\""));
    iForm.append(htmTb.endRow());

    iForm.append(htmTb.endTable());
    iForm.append("</div>");
    iForm.append(frm.hidden(batchId,"batchId"));
    iForm.append(frm.hidden(""+patientId,"insurancePatientId"));

// Everything we need is inside the form.  Close it up.
    iForm.append(frm.endForm());

    iForm.append("<br>" + frm.button("Post Payments","class=button onclick=postPayments(\"postinsurancepayments.jsp?parentPayment="+parentPayment+"\")","Filter"));

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
<%! public String getSupplementalInsurance(RWConnMgr io, int patientId, String providerId, String batchId) {
        StringBuffer s = new StringBuffer();
        
        try {
            ResultSet lRs=io.opnRS("SELECT * FROM patientinsurance pi LEFT JOIN providers p ON p.id=pi.providerid WHERE active and patientid=" + patientId + " and providerid<>" + providerId);
            PreparedStatement lPs=io.getConnection().prepareStatement("select * from batches a left join batchcharges b on b.batchid=a.id where b.chargeid in (select chargeid from batchcharges where batchid=?) and a.provider=?");
            lPs.setString(1, batchId);
            if(lRs.next()) {
                lRs.beforeFirst();
                s.append("<table width=\"100%\" colspacing=\"0\" cellpadding=\"0\">");
                while(lRs.next()) {
                    s.append("<tr>");
                    s.append("<td width=\"75%\"><b>" + lRs.getString("name") + "</b></td>");
                    lPs.setInt(2, lRs.getInt("providerid"));
                    ResultSet pRs=lPs.executeQuery();
                    if(!pRs.next()) {
                        s.append("<td id=\"secondary" + lRs.getString("providerid") + "\" width=\"25%\"><a href=\"javascript:billSecondary(" + batchId + "," + lRs.getString("providerid") + "," + patientId + ");\" style=\"font-weight: bold;\">bill insurance</a></td>");
                    } else {
                        s.append("<td id=\"secondary" + lRs.getString("providerid") + "\" width=\"25%\">billed in batch " + pRs.getString("batchid") + "</td>");
                    }
                    s.append("</tr>");
                }
                s.append("</table>");
                lRs.close();
                lRs = null;
            }
        } catch (Exception e) {
        }
        
        return s.toString();
    }
%>

