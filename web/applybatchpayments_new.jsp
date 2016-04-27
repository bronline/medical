<%-- 
    Document   : applybatchpayments
    Created on : Jan 18, 2008, 10:28:34 AM
    Author     : Randy
--%>

<%@include file="globalvariables.jsp" %>

<title>Apply Payments</title>

<script language="javascript">
  function postPayments(patientId,checkNumber,batchId) {
    var url = "http://chiropracticeonline.net/medical/applyinsurancepayments.jsp?patientId=" + patientId + "&batchId=" + batchId + "&checkNumber=" + checkNumber + "&batchesOnly=Y";
    window.open(url,"patientpayment","width=800,height=600,target=_blank");
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
    String multiplePayments = (String)session.getAttribute("multiplePayments");
    String[] preload={"*UNASSIGNED"};
    String[] preload2={};
    StringBuffer iForm = new StringBuffer();
    
    String startDate = "01/01/1901";
    String endDate = "12/31/2100";
    String paymentDate = Format.formatDate(new java.util.Date(), "MM/dd/yyyy");
    String providerId = "";
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
    myQuery     = "CALL rwcatalog.prGetPatientsInBatch('" + io.getLibraryName() + "'," + batchId + ")";
    
    String url         = "applybatchpayments.jsp?checkNumber="+checkNumber+"&checkAmount="+checkAmount+"&startDate="+startDate+"&endDate="+endDate;
    String title       = "";

// Create a new paymentform
    htmTb.setWidth("900");
    RWInputForm pFrm = new RWInputForm();
    pFrm.setFormName("payment");

    ResultSet pRs = io.opnRS(myQuery);
    iForm.append(htmTb.startTable());
    iForm.append(htmTb.startRow());
    iForm.append(htmTb.headingCell("Patient Name", "width=100"));
    iForm.append(htmTb.headingCell("Charges", RWHtmlTable.RIGHT, "width=100"));
    iForm.append(htmTb.headingCell("Credits", RWHtmlTable.RIGHT, "width=100"));
    iForm.append(htmTb.headingCell("Balance", RWHtmlTable.RIGHT, "width=100"));
    iForm.append(htmTb.headingCell("Post", RWHtmlTable.CENTER, "width=\"100\""));
    iForm.append(htmTb.endRow());
    iForm.append(htmTb.endTable());

    String chargeId="0";
    iForm.append("<div style=\" height: 300; width: 920; overflow: auto;\">");
    iForm.append(htmTb.startTable());
    String rowColor="lightgrey";
    while (pRs.next()) {
        iForm.append(htmTb.startRow("bgcolor="+rowColor));
        iForm.append(htmTb.addCell("<b>" + pRs.getString("lastname") + ", " + pRs.getString("firstname") + "</b>", "width=100"));
        iForm.append(htmTb.addCell("$"+pRs.getString("charges"), RWHtmlTable.RIGHT, "width=100"));
        iForm.append(htmTb.addCell("$"+pRs.getString("credits"), RWHtmlTable.RIGHT, "width=100"));
        iForm.append(htmTb.addCell("$"+pRs.getString("balance"), RWHtmlTable.RIGHT, "width=100"));
        iForm.append(htmTb.addCell("<input type=\"button\" value=\"post payments\" class=\"button\" onClick=\"postPayments(" + pRs.getInt("patientId") + ",'" + checkNumber + "'," + batchId + ")\" />", RWHtmlTable.CENTER, "width=100"));
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

// Spit the results out to the browser
    out.print(iForm.toString());
    
// Save the session variables
    session.setAttribute("returnUrl", "applybatchpayments_new.jsp");
    session.setAttribute("myParent", "applybatchpayments_new.jsp?providerId=" + providerId+"&batchId=" + batchId + "&checkNumber=" + checkNumber + "&checkAmount=" + checkAmount + "&paymentDate=" + paymentDate);
    session.setAttribute("batchId", ""+batchId);
%>


</body>