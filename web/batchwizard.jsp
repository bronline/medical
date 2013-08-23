<%-- 
    Document   : batchwizzard
    Created on : Jan 18, 2008, 9:13:49 AM
    Author     : Randy
--%>

<%@include file="template/pagetop.jsp" %>
<%@ page import="java.text.*, tools.utils.Format" %>

<title>Payment Wizard</title>

<script language="javascript">
  function submitForm(action) {
    var frmA=document.forms["frmInput"]
    frmA.method="POST"
    frmA.action=action
    frmA.submit()
  }  
  function openwindow(url, a) {
    //alert(id);

    if (frmInput.checkNumber.value == "") {
      alert("Check Number Must Be Entered");
    } else {
      window.open(url + "&checkNumber="+ frmInput.checkNumber.value + "&checkAmount="+ frmInput.checkAmount.value + "&paymentDate="+ frmInput.paymentDate.value,"","width=920,height=530,scrollbars=no,left=100,top=100,");
    }
  }  
</script>

<%
// Initialize local variables
    SimpleDateFormat mdyFormat = new SimpleDateFormat("MM/dd/yyyy");

    String myQuery          = "";
    String whereClause      = "";
    String id               = request.getParameter("id");
    String[] preload={"*UNASSIGNED"};
    String[] preload2={};
    StringBuffer iForm = new StringBuffer();
    
    String startDate = "01/01/1901";
    String endDate = "12/31/2100";
    String paymentDate = Format.formatDate(new java.util.Date(), "MM/dd/yyyy");
    String providerId = "2";
    String checkNumber = "";
    String checkAmount = "0.00";
    String lowDate = "01/01/1901";
    String highDate = "12/31/2100";
    String params="";
    
    Calendar startCal = Calendar.getInstance();
    endDate = mdyFormat.format(startCal.getTime());
    startCal.add(Calendar.DAY_OF_MONTH, -7);
    startDate = mdyFormat.format(startCal.getTime());

    // If parameters were passed, use them
    if (request.getParameter("providerId")!=null) {
        providerId=request.getParameter("providerId");
        params+="&providerId="+providerId;
    }
    if (request.getParameter("checkNumber")!=null) {
        checkNumber=request.getParameter("checkNumber");
        params+="&checkNumber="+checkNumber;
    }
    if (request.getParameter("checkAmount")!=null) {
        checkAmount=request.getParameter("checkAmount");
        params+="&checkAmount="+checkAmount;
    }
    if (request.getParameter("startDate")!=null) {
        startDate=request.getParameter("startDate");
        params+="&startDate="+startDate;
    }
    if (request.getParameter("endDate")!=null) {
        endDate=request.getParameter("endDate");
        params+="&endDate="+endDate;
    }
    if (request.getParameter("paymentDate")!=null) {
        paymentDate=request.getParameter("paymentDate");
        params+="&paymentDate="+paymentDate;
    }
    
// Instantiate a table and a form
    RWHtmlTable htmTb = new RWHtmlTable("500", "0");
    htmTb.replaceNewLineChar(false);

    RWInputForm frm = new RWInputForm();
    frm.setShowDatePicker(true);
    frm.setDftTextBoxSize("25");
    frm.formItemOnOneRow = false;
    frm.setLabelBold(true);
    frm.setLabelPosition(frm.LABEL_ON_LEFT);
    frm.setUseExternalForm(true);

// Instantiate result sets for use in the comboboxes
    ResultSet lRs = io.opnRS("select id, name from providers where not reserved order by name");

    frm.setDftTextBoxSize("25");
    frm.formItemOnOneRow = false;
    frm.setLabelBold(true);
    frm.setLabelPosition(frm.LABEL_ON_LEFT);
    frm.setUseExternalForm(true);
    frm.setShowDatePicker(true);

    htmTb.setWidth("210");
// Print The Title
    out.print("<H1>Apply Payments Wizard</H1>");
    
// Build the form now
    iForm.append(frm.startForm());
    
// First is the group box containing the insurance provider
    iForm.append("<fieldset style=\"width: 500; border: 1px solid #666; padding: 10px;\"><legend><b>Insurance</b></legend>");
    iForm.append(htmTb.startTable());
    iForm.append(htmTb.startRow());
    iForm.append(htmTb.addCell("<b>Provider"));
    lRs.beforeFirst();
    iForm.append(htmTb.addCell(frm.comboBox(lRs,"providerId","id",false,"1",preload2,providerId,"class=cBoxText onchange=submitForm(\"batchwizard.jsp\")")));
    iForm.append(htmTb.endRow());
    iForm.append(htmTb.endTable());
    iForm.append("</fieldset>");

// Now, the groupbox with the Payment Info
    iForm.append("<br><fieldset style=\"width: 500; border: 1px solid #666; padding: 10px;\"><legend><b>Payment</b></legend>");
    iForm.append(htmTb.startTable());
    iForm.append(htmTb.startRow());
    iForm.append(htmTb.addCell("<b>Check Number"));
    lRs.beforeFirst();
    iForm.append(htmTb.addCell(frm.textBox(checkNumber, "checkNumber", "15","15","class=tBoxText")));
    iForm.append(htmTb.endRow());

    iForm.append(htmTb.startRow());
    iForm.append(htmTb.addCell("<b>Check Amount"));
    lRs.beforeFirst();
    iForm.append(htmTb.addCell(frm.textBox(checkAmount, "checkAmount", "10","10","class=tBoxText onBlur=\"this.value=formatCurrency(this.value);\"")));
    iForm.append(htmTb.endRow());

    iForm.append(htmTb.startRow());
    iForm.append(htmTb.addCell("<b>Payment Date"));
    lRs.beforeFirst();
    iForm.append(htmTb.addCell(frm.date(paymentDate, "paymentDate", "class=tBoxText")));
    iForm.append(htmTb.endRow());

    iForm.append(htmTb.endTable());
    iForm.append("</fieldset>");

    iForm.append("<br>" + frm.button("Get Charges","class=button onclick=submitForm(\"batchwizard.jsp\")","Filter"));

// Everything we need is inside the form.  Close it up.
    iForm.append(frm.endForm());

    String url         = "applybatchpayments.jsp?providerId="+providerId;
    String title       = "";
    String [] cw       = {"0", "80", "80", "80", "50", "75", "75", "75" };

    lowDate = tools.utils.Format.formatDate(startDate, "yyyy-MM-dd");
    highDate = tools.utils.Format.formatDate(endDate, "yyyy-MM-dd");
    
    myQuery =   "select b.id as batchId, b.created as Date, " +
                "min(pb.date) as Start, max(pb.date) as End, "+
                "count(pb.id) as Charges, " +
                "sum(chargeamount) as Charges, sum(paidamount) as Payments, sum(balance) as Balance  " +
                "from batches b " +
                "left join providers p on p.id=b.provider " +
                "left join batchcharges bc on bc.batchid=b.id " +
                "left join patientbalance pb on pb.id=bc.chargeid " +
                "where billed " +
                "and balance>0 " + 
                "and b.provider=" + providerId +
                " group by b.id, b.created " +
                "order by b.created";

// Create an RWFiltered List object
    RWFilteredList lst = new RWFilteredList(io);

// Set special attributes on the filtered list object
    lst.setTableWidth("500");
    lst.setTableBorder("0");
    lst.setCellPadding("3");
    lst.setColumnWidth(cw);
    lst.setAlternatingRowColors("#ffffff", "#cccccc");
    lst.setRoundedHeadings("#030089", "");
    lst.setTableHeading(title);
    lst.setUrlField(0);
    lst.setNumberOfColumnsForUrl(2);
    lst.setRowUrl(url);
    lst.setShowRowUrl(true);
    lst.setOnClickAction("openwindow");
    lst.setOnClickOption("\"a\"");
    lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    lst.setShowComboBoxes(false);
    lst.setUseCatalog(true);
    lst.setDivHeight(140);
    lst.setColumnFormat(5, "MONEY");
    lst.setColumnFormat(6, "MONEY");
    lst.setColumnFormat(7, "MONEY");
    //lst.setShowComboBoxes(true);

// Show the filtered list
    iForm.append(lst.getHtml(request, myQuery) );

// Spit the results out to the browser
    out.print(iForm.toString());
    
// Save the session variables
    if (params.trim().equals("")) {
        session.setAttribute("returnUrl", "batchwizard.jsp");
        session.setAttribute("myParent", "batchwizard.jsp");
    } else {
        session.setAttribute("returnUrl", "batchwizard.jsp?params=true"+params);
        session.setAttribute("myParent", "batchwizard.jsp?params=true"+params);
    }           
%>
<%@ include file="template/pagebottom.jsp" %>