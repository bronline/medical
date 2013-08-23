<%@include file="globalvariables.jsp" %>

<title>Item</title>
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
    String myQuery          = "select id, date from visits ";
    String id               = request.getParameter("visitId");

// If the id in the request is null or an empty string make it 0 to indicate an add
    if(id == null || id.equals("")) {
        id = "0";
    } else {
        myQuery += "where id=" + id;
    }

// Create a result set of the data for the form
    ResultSet lRs = io.opnRS(myQuery);

// Instantiate an RWInputForm and RWHtmlTable object
    RWInputForm frm = new RWInputForm(lRs);
    frm.setShowDatePicker(true);

    RWHtmlTable htmTb = new RWHtmlTable ("400", "0");

// Set display attributes for the input form
    frm.setTableWidth("400");
    frm.setTableBorder("0");
    frm.setDftTextBoxSize("35");
    frm.setDftTextAreaCols("35");
//    frm.setDisplayDeleteButton(true);
    frm.setLabelBold(true);
    frm.setUpdateButtonText("  save  ");
//    frm.setDeleteButtonText("remove");

// Get an input item with the record id to set the rcd and id fields
    out.print(frm.getInputForm());

    session.setAttribute("returnUrl", "");
    
%>
