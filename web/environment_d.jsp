<%@include file="template/pagetop.jsp" %>

<title>Environment</title>
<script language="JavaScript" src="js/CheckDate.js"></script>
<script language="JavaScript" src="js/CheckLength.js"></script>

<script language="javascript">
  function submitForm(action) {
    var frmA=document.forms["frmInput"]
    frmA.method="POST"
    frmA.action=action
    frmA.submit()
  }  
</script>

<%
// Initialize local variables
    String myQuery          = "select * from environment ";

// Create a result set of the data for the form
    ResultSet lRs = io.opnRS(myQuery);

// Instantiate an RWInputForm and RWHtmlTable object
    RWInputForm frm = new RWInputForm(lRs);
    RWHtmlTable htmTb = new RWHtmlTable ("650", "0");
    RWFieldSet fldSet = new RWFieldSet();

// Set display attributes for the input form
    frm.setTableWidth("650");
    frm.setTableBorder("0");
    frm.setDftTextBoxSize("35");
    frm.setDftTextAreaCols("35");
    frm.setDisplayDeleteButton(false);
    frm.setLabelBold(true);
    frm.setUpdateButtonText("  save  ");
    frm.setDeleteButtonText("remove");

// Get an input item with the record id to set the rcd and id fields
    out.print(fldSet.getFieldSet(frm.getInputForm(), "style='width: 650; height: 1;'", "Environment Settings", "style='font-size: 12; font-weight: bold;'"));

    session.setAttribute("returnUrl", "environment_d.jsp");
%>
<%@ include file="template/pagebottom.jsp" %>