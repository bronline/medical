<%@include file="globalvariables.jsp" %>

<title>Preview Batch Bills</title>

<script language="javascript">
function previewBill(batchId,patientId) {
  window.open('previewbill.jsp?batchId='+batchId+'&patientId='+patientId,'CreateBatch','address=no,scrollbars=yes');
}
</script>

<%
// Initialize local variables

// If parameters were passed, use them
    String batchId = request.getParameter("batchId");
    int batchIdInt = Integer.parseInt(batchId);

// Instantiate the Batch
    Batch thisBatch = new Batch(io, batchIdInt);
    thisBatch.next();
    java.util.Date billedDate = thisBatch.getBilled();

// Print The Title
    out.print("<H1>Preview Batch Bills for Batch: " + batchId + "</H1>");
    out.print("<H1>Created: " + thisBatch.getCreated() + "</H1>");
    if (billedDate != null) {
        out.print("<H1>Originally Billed: " + billedDate + "</H1>");
    }
    
    String myQuery     = "select a.id, a.id as Batch, b.lastname, b.firstname, e.items, " +
                         "concat('<input type=button name=preView', a.id, ' onClick=previewBill(', a.id,',', e.patientid,') class=button value=\"preview\" style=\"font-size: 8px; font-weight: normal;\">') as preview " +
                         " from batches a join " +
                         "(select batchid, patientid, count(*) as items from batchcharges " + 
                         " join charges on batchcharges.chargeid=charges.id " +
                         " join visits on charges.visitid=visits.id " +
                         "group by batchid, patientid) e " + 
                         " on a.id = e.batchid join " + 
                         " patients b on e.patientid=b.id where a.id=" + batchId + " order by lastname, firstname";
    String title = "Patients in Batch " + batchId;

// Create an RWFiltered List object
    RWFilteredList lst = new RWFilteredList(io);
    RWHtmlTable htmTb  = new RWHtmlTable("620", "0");
//    RWHtmlForm frm     = new RWHtmlForm();
    RWFieldSet fldSet  = new RWFieldSet();

// Set special attributes on the filtered list object
    String [] cw       = {"0", "30", "100","80", "80", "80" };
    String [] ch       = {"", "Batch", "Last Name", "First Name", "Charges", "Preview"};

    lst.setTableWidth("600");
    lst.setTableBorder("0");
    lst.setCellPadding("3");
    lst.setAlternatingRowColors("#ffffff", "#cccccc");
    lst.setRoundedHeadings("#030089", "");
    lst.setShowRowUrl(false);
    lst.setShowComboBoxes(false);
    lst.setUseCatalog(true);
    lst.setColumnWidth(cw);
    lst.setDivHeight(300);

// Show the filtered list
    htmTb.replaceNewLineChar(false);
    out.print(fldSet.getFieldSet(lst.getHtml(myQuery, ch), "style='width: " + lst.getTableWidth() +"'", title, "style='font-size: 12; font-weight: bold;' align=center"));

    lst=null;

    io.getConnection().close();
    io=null;

    System.gc();
%>

