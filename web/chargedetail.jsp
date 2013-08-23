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
    var frmA=document.forms["frmInput"]
    frmA.method="POST"
    frmA.action=action
    frmA.submit()
  }  
  function win(where){
    //alert('test')
    window.opener.location.href=where;
    self.close();
  }
</script>
<%
// Initialize local variables

    int patientId = patient.getId();
    int id = 0;
    String myQuery          = "";
    String whereClause      = "";
    String idString         = "0";
    String[] preload={"*UNASSIGNED"};
    String[] preload2={};
    StringBuffer iForm = new StringBuffer();
    String date = "";
    String checkNumber = "00000";
    String checkAmount = "0.00";
    String patientName = "";
    
// If parameters were passed, use them
    if (request.getParameter("id")!=null) {
        idString=request.getParameter("id");
    }
    id = Integer.parseInt(idString);
    
// Get all of the charge specific info
    ResultSet cRs = io.opnRS("select * from patientchargesummary where id =" + id);
    if (cRs.next()) {
        date = cRs.getString("date");
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
    ResultSet lRs = io.opnRS("select 0 as id, 'Cash' as name  union select * from (select id, name from providers where reserved or id in (select providerid from patientinsurance where patientid=" + patientId + ")) a order by name ");

// Print The Title
    patient.setId(patientId);
    patient.beforeFirst();
    if (patient.next()) {
        patientName = patient.getString("firstname") + " " + patient.getString("lastname") ;
    }
    out.print("<H1>Apply Payments for " + patientName + "</H1>");
    
// Build the form now
    iForm.append(frm.startForm());
    
// Now, tack on the filtered list containing all patients that may qualify to have their charges paid by this check
    whereClause = "where a.id = " + id; 

    myQuery     = "select a.itemid, a.id, b.date, d.description, a.Quantity, a.quantity*a.chargeamount chargeamount, ifnull(paidamount,0) paidamount, cast((a.quantity*a.chargeamount)-ifnull(paidamount,0) as decimal(6, 2)) balance " + 
                  "from charges a join items d on a.itemid=d.id join visits b on a.visitid=b.id join patients c on b.patientid=c.id " + 
                  "left outer join (SELECT patientid, chargeid, sum(amount) paidamount FROM payments p " +
                  "group by patientid, chargeid) e on a.id=e.chargeid " +
            whereClause;
    String url         = "applypayments.jsp?id=" +id;
    String title       = "";

//    out.print(myQuery);

// Create a new paymentform
    htmTb.setWidth("650");
    RWInputForm pFrm = new RWInputForm();
    pFrm.setFormName("payment");

    ResultSet pRs = io.opnRS(myQuery);
    iForm.append("<fieldset style=\"width: 700 ; border: 1px solid #666; padding: 10px;\"><legend><b>Patient Charge</b></legend><br>");
    iForm.append(htmTb.startTable());
    iForm.append(htmTb.startRow());
    iForm.append(htmTb.headingCell("Date", "width=60"));
    iForm.append(htmTb.headingCell("Description", "width=150"));
    iForm.append(htmTb.headingCell("Qty", "width=50"));
    iForm.append(htmTb.headingCell("Charge Amount", "width=50"));
    iForm.append(htmTb.headingCell("Paid Amount", "width=50"));
    iForm.append(htmTb.headingCell("Balance", "width=50"));
    iForm.append(htmTb.headingCell("Check Number", "width=100"));
    iForm.append(htmTb.headingCell("Check Amount", "width=100"));
    iForm.append(htmTb.headingCell("Provider", "width=100"));
    iForm.append(htmTb.endRow());
    iForm.append(htmTb.endTable());

    String chargeId="0";
    iForm.append("<div style=\" height: 30; width: 668; overflow: auto;\">");
    iForm.append(htmTb.startTable());
    String rowColor="lightgrey";
    while (pRs.next()) {
        chargeId=pRs.getString("id");
        BigDecimal bDDefaultPayment = patient.getDefaultPayment(pRs.getInt("itemid"));
        String defaultPayment = ""+bDDefaultPayment;
//        long balance=pRs.getLong("balance");
//        if (balance < bDDefaultPayment.longValue()) {
        double balance=pRs.getDouble("balance");
        if (balance < bDDefaultPayment.doubleValue()) {

            defaultPayment=pRs.getString("balance");
        }
        if (defaultPayment.equals("0") && balance != 0) {
            defaultPayment=pRs.getString("balance");
        }
        iForm.append(htmTb.startRow("bgcolor="+rowColor));
        iForm.append(htmTb.addCell(pRs.getString("date"), "width=60"));
        iForm.append(htmTb.addCell(pRs.getString("description"), "width=150"));
        iForm.append(htmTb.addCell(pRs.getString("quantity"),htmTb.RIGHT, "width=50"));
        iForm.append(htmTb.addCell(Format.formatCurrency(pRs.getString("chargeamount")), 1, "width=50"));
        iForm.append(htmTb.addCell(Format.formatCurrency(pRs.getString("paidamount")), 1, "width=50"));
        iForm.append(htmTb.addCell(Format.formatCurrency(pRs.getString("balance")), 1, "width=50"));
        iForm.append(htmTb.addCell(frm.textBox(checkNumber, "checkNumber"+chargeId, "10","10","class=tBoxText"), 2, "width=100"));
        iForm.append(htmTb.addCell(frm.textBox(defaultPayment, "checkAmount"+chargeId, "10","10","class=tBoxText onBlur=\"this.value=formatCurrency(this.value);\""), 2, "width=100"));
        lRs.beforeFirst();
        iForm.append(htmTb.addCell(frm.comboBox(lRs,"providerId"+chargeId,"id",false,"1",preload2,"0","class=cBoxText"), 2,"width=100"));
        iForm.append(htmTb.endRow());

        if (rowColor.equals("lightgrey")) {
            rowColor="#cccccc";
        } else {
            rowColor="lightgrey";
        }
    }
    iForm.append(htmTb.endTable());
    iForm.append("</div>");

    iForm.append(frm.button("Post Payment","class=button onclick=postPayments(\"postpayments.jsp\")","Filter"));

// Hidden Date Field
    iForm.append(frm.hidden(Format.formatDate(new java.util.Date(),"yyyy-MM-dd"), "date"+chargeId));
    
// Everything we need is inside the form.  Close it up.
    iForm.append(frm.endForm());
    iForm.append("</fieldset>");

// Now, show all of the payments currently posted against this charge
    iForm.append("<fieldset style=\"width: 700 ; border: 1px solid #666; padding: 10px;\"><legend><b>Payments Posted Against This Charge</b></legend><br>");

// Set this as the parent location
    session.setAttribute("parentLocation", "chargedetail.jsp?id="+id);   

// Set up the SQL statement
    myQuery     = "select a.id, date, ifnull(name,'Cash') name, checknumber, amount from payments a " +
                  "left outer join providers b on provider = b.id where chargeid=" + chargeId +
                  " order by date desc, id desc";
    url         = "payments_d.jsp?";
    title       = "Payments";

// Create an RWFiltered List object
    RWFilteredList lst = new RWFilteredList(io);
    htmTb.replaceNewLineChar(false);
    
// Set special attributes on the filtered list object
    String [] cw       = {"0", "100", "100", "100", "100" };
    String [] ch       = {"","Date", "Provider", "Check Number", "Paid Amount"};

    lst.setTableWidth("650");
    lst.setTableBorder("0");
    lst.setCellPadding("3");
    lst.setAlternatingRowColors("#ffffff", "#cccccc");
    lst.setUrlField(0);
    lst.setNumberOfColumnsForUrl(6);
    lst.setRowUrl(url);
    lst.setShowRowUrl(true);
    lst.setOnClickAction("window.open");
    lst.setOnClickOption("\"" + title + "\",\"width=300,height=150,scrollbars=no,left=120,top=170,\"");
    lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    lst.setShowComboBoxes(false);
    lst.setUseCatalog(true);
    lst.setDivHeight(240);
    lst.setColumnWidth(cw);
    iForm.append(lst.getHtml(myQuery, ch));
    iForm.append("</fieldset>");

  // Spit the results out to the browser
    out.print(iForm.toString());
    
// Save the session variables
    session.setAttribute("returnUrl", "chargedetail.jsp?id="+id);
%>
