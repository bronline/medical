<%@include file="template/pagetop.jsp" %>
<%@ page import="java.text.*" %>
<script>
function previewBills(batchId) {
  window.open('previewbills.jsp?batchId='+batchId,'PreviewBatchBills','address=no,scrollbars=yes');
}
function printSelectedBills() {

    var postStr="";
    var elem="";
    var names=document.getElementsByTagName('input');
    for(x=0;x<names.length;x++) { 
        try {
//            alert(names[x].name + " " + names[x].type);
            if(names[x].type == "checkbox") {
                if(names[x].checked) { postStr += "&" + names[x].name + "=Y" }
            }
        } catch (err) {}
    }

    if(postStr != "") {
        window.open("printbatchbills.jsp?selectedBills=Y" + postStr,"batches","width=200,height=200,resizable");
        location.href="batches.jsp";
    } else {
        alert("You did not select any batches");
    }
}
</script>
<%
try {
    RWInputForm form = new RWInputForm();
    form.setFormName("inputForm");
    SimpleDateFormat mdyFormat = new SimpleDateFormat("MM/dd/yyyy");
    form.setShowDatePicker(true);

    String startDate = request.getParameter("startdate");

    if (startDate == null) {
       Calendar startCal = Calendar.getInstance();
       startCal.add(Calendar.MONTH, -1);
       startDate = mdyFormat.format(startCal.getTime());
    }

    // Date selector
    out.print(form.startForm());
    out.print("<table><tr>");
    out.print("<td>Since</td><td>" + form.date(tools.utils.Format.formatDate(startDate, "MM/dd/yyyy"), "startdate", "class=tBoxText") + "</td>");
    out.print("<td>" + form.submitButton("go", "class=button") + "</td>");
    out.print("</tr></table>");
    out.print(form.endForm());

    // Set up the SQL statement
    startDate=tools.utils.Format.formatDate(startDate, "yyyy-MM-dd");

// Set up the SQL statement
    String myQuery     = "select a.id, concat('<input type=checkbox name=chk', a.id, '>') as fld, a.id as Batch, b.name provider, created, billed, lastbilldate, patients, items, batchamount, " +
                         "concat('<input type=button name=preView', a.id, ' onClick=previewBills(', a.id,') class=button value=\"preview\" style=\"font-size: 8px; font-weight: normal;\">') as preview " +
                         " from batches a join " +
                         "(select batchid, count(distinct patientid) as patients from batchcharges a join charges b on a.chargeid = b.id join visits c on b.visitid = c.id group by batchid) d " + 
                         " on a.id = d.batchid join " + 
                         "(select batchid, count(*) as items, " +
                         "sum(quantity*chargeamount) as batchamount from batchcharges f join charges g on f.chargeid=g.id group by batchid) e " + 
                         " on a.id = e.batchid left outer join " + 
                         " providers b on provider = b.id " +
                         " where created >= '" + startDate + "' " +
                         "order by created desc, batch desc";
    String url         = "batches_d.jsp";
    String title       = "Billing Batches";

// Create an RWFiltered List object
    RWFilteredList lst = new RWFilteredList(io);
    RWHtmlTable htmTb  = new RWHtmlTable("750", "0");
    RWHtmlForm frm     = new RWHtmlForm();
    RWFieldSet fldSet  = new RWFieldSet();

// Set special attributes on the filtered list object
    String [] cw       = {"0","30", "30", "100","80", "80", "80", "50", "50", "80", "20" };
    String [] ch       = {"", "Sel", "Batch", "Provider", "Created", "Billed", "Last<br>Billed", "Patients", "Items", "Amount", "Preview"};

    lst.setTableWidth("700");
    lst.setTableBorder("0");
    lst.setCellPadding("3");
    lst.setAlternatingRowColors("#ffffff", "#cccccc");
    lst.setRoundedHeadings("#030089", "");
//    lst.setTableHeading(title);
    lst.setUrlField(0);
//    lst.setNumberOfColumnsForUrl(5);
//    lst.setRowUrl(url);
//    lst.setShowRowUrl(true);
    
    lst.setOnClickAction(2, "javascript:window.open(\"batches_d.jsp?id=##idColumn##\",\"batches\",\"width=800,height=550,scrollbars=yes,left=100,top=100,\") style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    lst.setOnClickAction(3, "javascript:window.open(\"batches_d.jsp?id=##idColumn##\",\"batches\",\"width=800,height=550,scrollbars=yes,left=100,top=100,\") style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    lst.setOnClickAction(4, "javascript:window.open(\"batches_d.jsp?id=##idColumn##\",\"batches\",\"width=800,height=550,scrollbars=yes,left=100,top=100,\") style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    lst.setOnClickAction(5, "javascript:window.open(\"batches_d.jsp?id=##idColumn##\",\"batches\",\"width=800,height=550,scrollbars=yes,left=100,top=100,\") style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    lst.setOnClickAction(6, "javascript:window.open(\"batches_d.jsp?id=##idColumn##\",\"batches\",\"width=800,height=550,scrollbars=yes,left=100,top=100,\") style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");

//    lst.setOnClickAction("window.open");
//    lst.setOnClickOption("\"batches\",\"width=800,height=550,scrollbars=yes,left=100,top=100,\"");
    lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    lst.setShowComboBoxes(true);
    lst.setColumnFilterState(3, true);
    lst.setUseCatalog(true);
    lst.setColumnFormat(9, "MONEY");
    lst.setColumnWidth(cw);
//    lst.setUsePercentages(true);
    lst.setDivHeight(300);

// Show the filtered list
    htmTb.replaceNewLineChar(false);
//    out.print(frm.startForm());    
    out.print(fldSet.getFieldSet(lst.getHtml(request, myQuery, ch), "style='width: " + lst.getTableWidth() +"'", title, "style='font-size: 12; font-weight: bold;' align=center"));

    out.print(frm.button("New " + title, "class=button onClick=window.open(\"billing.jsp?id=0\",\"StartTimes\",\"width=800,height=550,scrollbars=no,left=100,top=100,\");" ));
//    out.print(frm.button("Print Selected " + title, "class=button onClick=window.open(\"printbatchbills.jsp?selectedBills=Y\",\"BillBatchPrint\",\"width=800,height=550,scrollbars=no,left=100,top=100,\");" ));
    out.print(frm.button("Print Selected " + title, "class=button onClick=printSelectedBills()" ));
//    out.print(frm.endForm());

//    session.setAttribute("parentLocation", self);

    // 03-02-08 added filter for provider column (Randy)
    session.setAttribute("parentLocation", self+"?"+parmsPassed);
    session.setAttribute("returnUrl", "");

} catch (Exception e) {
    out.print(e);
}
%>

<script language="javascript">
  function formSubmit() {
    var frmA=document.forms["formFilter"]
    var startDate = document.createElement('input');
    startDate.name='startdate'
    startDate.value=frmInput.startdate.value
    frmA.appendChild(startDate)
    frmA.action=""
    frmA.method="POST"
    frmA.submit()
  }
</script>

<%@ include file="template/pagebottom.jsp" %>