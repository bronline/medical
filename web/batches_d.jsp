<%@include file="globalvariables.jsp" %>

<title>Maintain Billing Batch</title>

<script language="javascript">
  function submitForm(action) {
        var frmA=document.forms["frmInput"]
        frmA.method="POST"
        frmA.action=action
        frmA.submit()
  }
  function deleteBatch(action) {
    var isSure = confirm('Are you sure you want to delete this entire batch?');
    if (isSure==true) {
      var frmA=document.forms["frmInput"]
      frmA.method="POST"
      frmA.action=action
      frmA.submit()
    }
  }
  function deleteBatchCharges(action) {
    var isSure = confirm('Are you sure you want to delete these entries?');
    if (isSure==true) {
      var frmA=document.forms["frmInput"]
      frmA.method="POST"
      frmA.action=action
      frmA.submit()
    }
  }
  function printBatchBills(action) {
    var isSure = confirm('Are you sure you want to print these bills?');
    if (isSure==true) {
      var frmA=document.forms["frmInput"]
      frmA.method="POST"
      frmA.action=action
      frmA.submit()
    }
  }

  function updatePrintType(batchId) {
    var batchType="";
    if(printAsPDF.checked) {
        batchType="PDF";
    } else {
        batchType="TEXT";
    }

    var url="ajax/setbatchtype.jsp?id="+batchId+"&batchType="+batchType+"&sid="+Math.random();

    $.ajax({
        url: url,
        success: function(data){
            alert("Batch type changed to " + batchType);
        },
        error: function() {
            alert("There was a problem processing the request");
        }
    });
  }

  function updateDosPerPage(batchId) {
    var allowMultipleDatesPerPage="";

    if(dosPerPage.checked) {
        allowMultipleDatesPerPage="true";
    } else {
        allowMultipleDatesPerPage="false";
    }

    var url="ajax/setmultipledosperpage.jsp?id="+batchId+"&allowMultipleDos="+allowMultipleDatesPerPage+"&sid="+Math.random();

    $.ajax({
        url: url,
        success: function(data){
            alert("Print Multiple DOS per Page is now " + batchType);
        },
        error: function() {
            alert("There was a problem processing the request");
        }
    });
  }
</script>

<%
// Initialize local variables

    String myQuery          = "";
    String whereClause      = "";
    String[] preload={"*UNASSIGNED"};
    String printAsPDF = "";
    String allowMultipleDOS = "";
    String[] preload2={};
    StringBuffer iForm = new StringBuffer();

// If parameters were passed, use them
    String batchId          = request.getParameter("id");
    int batchIdInt = Integer.parseInt(batchId);
// Instantiate the Batch
    Batch thisBatch = new Batch(io, batchIdInt);
    thisBatch.next();
    java.util.Date billedDate = thisBatch.getBilled();

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

    htmTb.setWidth("600");

// Instantiate result sets for use in the comboboxes
//    ResultSet lRs = io.opnRS("select 0 as id, '*ALL' as name union select id, name from providers where not reserved order by name");
//    ResultSet patRs = io.opnRS("select 0 as id, '*ALL' as name union select id, concat(lastname, ' ', firstname) name from patients where lastname<>'' order by name");

// Print The Title
    out.print("<H1>Maintain Billing Batch Number " + batchId + "</H1>");
    out.print("<H1>Created: " + thisBatch.getCreated() + "</H1>");
    if (billedDate != null) {
        out.print("<H1>Originally Billed: " + billedDate + "</H1>");
    }

    if(thisBatch.isSecondary()) { printAsPDF = "checked"; }
    if(thisBatch.isAllowMultipleDOS()) { allowMultipleDOS = "checked"; }

    out.print("<h3>Print as PDF <input type=\"checkbox\" name=\"printAsPDF\" id=\"printAsPDF\" " + printAsPDF + " onClick=\"updatePrintType(" + thisBatch.getId() + ")\"></h3>");
    out.print("<h3>Print more than 1 DOS per page <input type=\"checkbox\" name=\"dosPerPage\" id=\"dosPerPage\" " + allowMultipleDOS + " onClick=\"updateDosPerPage(" + thisBatch.getId() + ")\"></h3>");

// Build the form now
    iForm.append(frm.startForm());

// Now, tack on the filtered list containing all patients that may qualify to have their charges paid by this check
    whereClause = "where batchid = " + batchId;

    //myQuery     = "select y.id as thischarge, z.* from batchcharges y join " +
    //              "(select a.itemid, a.id, b.date, d.description, a.chargeamount, ifnull(paidamount,0) paidamount, " +
    //              "cast(a.chargeamount-ifnull(paidamount,0) as decimal(6, 2)) balance, " +
    //              "concat(lastname,', ',firstname) patient " +
    //              "from charges a join items d on a.itemid=d.id join visits b on a.visitid=b.id join patients c on b.patientid=c.id " +
    //              "left outer join (SELECT patientid, chargeid, sum(amount) paidamount FROM payments p " +
    //              "group by patientid, chargeid) e on a.id=e.chargeid) z on y.chargeid=z.id " +
    //              whereClause +
    //              " order by date, description ";
    myQuery =   "select  bc.id as thischarge, b.chargeid as id, v.date, concat(p.lastname,', ',firstname) as Patient, i.description, " +
                "a.quantity*a.chargeamount as chargeamount, ifnull(b.paidamount,0) as paidamount, (a.quantity*a.chargeamount)-ifnull(b.paidamount,0) " +
                "as balance from (select aa.id as chargeid, visitid, itemid, quantity, chargeamount from charges aa where " +
                "aa.id in (select chargeid from batchcharges where batchid=" + batchId + ")) a left outer join " +
                "(SELECT chargeid, sum(paidamount) as paidamount FROM paidamounts where chargeid in " +
                "(select chargeid from batchcharges where batchid=" + batchId + ") group by chargeid) b " +
                "on a.chargeid=b.chargeid " +
                "join visits v on a.visitid=v.id " +
                "join patients p on v.patientid=p.id " +
                "join items i on a.itemid=i.id " +
                "join batchcharges bc on batchid=" + batchId + " and a.chargeid=bc.chargeid "+
                "order by p.lastname, p.firstname, date, description";

    String url         = "billing.jsp";
    String title       = "";

//    out.print(myQuery);

// Create a new billing form
    htmTb.setWidth("650");
    RWInputForm pFrm = new RWInputForm();
    pFrm.setFormName("billing");

    ResultSet pRs = io.opnRS(myQuery);
    iForm.append("<table><tr><td align=left>");
    iForm.append(htmTb.startTable());
    iForm.append(htmTb.startRow());
//    if (billedDate == null) {
        iForm.append(htmTb.headingCell("Select", "width=20"));
//    }
    iForm.append(htmTb.headingCell("Date", "width=50"));
    iForm.append(htmTb.headingCell("Patient", "width=150"));
    iForm.append(htmTb.headingCell("Description", "width=150"));
    iForm.append(htmTb.headingCell("Charge Amount", "width=50"));
    iForm.append(htmTb.headingCell("Paid Amount", "width=50"));
    iForm.append(htmTb.headingCell("Balance", "width=50"));
    iForm.append(htmTb.endRow());
    iForm.append(htmTb.endTable());

    String chargeId="0";
    iForm.append("<div style=\" height: 200; width: 668; overflow: auto;\">");
    iForm.append(htmTb.startTable());
    String rowColor="lightgrey";
    while (pRs.next()) {
        chargeId=pRs.getString("id");
        iForm.append(htmTb.startRow("bgcolor="+rowColor));
//        if (billedDate == null) {
            iForm.append(htmTb.addCell(pFrm.checkBox(false,"","cb"+pRs.getString("thischarge")), "width=25"));
//        }
        iForm.append(htmTb.addCell(pRs.getString("date"), "width=50"));
        iForm.append(htmTb.addCell(pRs.getString("patient"), "width=150"));
        iForm.append(htmTb.addCell(pRs.getString("description"), "width=150"));
        iForm.append(htmTb.addCell(Format.formatCurrency(pRs.getString("chargeamount")), 1, "width=50"));
        iForm.append(htmTb.addCell(Format.formatCurrency(pRs.getString("paidamount")), 1, "width=50"));
        iForm.append(htmTb.addCell(Format.formatCurrency(pRs.getString("balance")), 1, "width=50"));
        //iForm.append(frm.hidden("","chargeid"+chargeId));
        iForm.append(htmTb.endRow());
        if (rowColor.equals("lightgrey")) {
            rowColor="#cccccc";
        } else {
            rowColor="lightgrey";
        }
        // Hidden Date Field
        //iForm.append(frm.hidden(Format.formatDate(new java.util.Date(),"yyyy-MM-dd"), "date"+chargeId));

    }
    iForm.append(htmTb.endTable());
    iForm.append("</div>");

// Everything we need is inside the form.  Close it up.
    iForm.append(frm.endForm());
    iForm.append("</td></tr></table><br>");

    iForm.append(frm.button("Print Bills","class=button onclick=printBatchBills(\"printbatchbills.jsp?id=" + batchId + "\")","Filter"));
//    if (billedDate == null) {
        iForm.append(frm.button("Delete Selected Entries","class=button onclick=deleteBatchCharges(\"deletebatchcharges.jsp\")","Filter"));
    if (billedDate == null) {
        iForm.append(frm.button("Delete Entire Batch","class=button onclick=deleteBatch(\"deletebatch.jsp?id=" + batchId + "\")","Filter"));
    }

// Spit the results out to the browser
    out.print(htmTb.getFrame("white", iForm.toString()))    ;

// Save the session variables
    session.setAttribute("parentLocation", "batches.jsp");
    session.setAttribute("returnUrl", "");
%>
