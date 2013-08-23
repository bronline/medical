<%@include file="template/pagetop.jsp" %>

<%@include file="template/CheckDate.js" %>
<%@include file="template/CheckLength.js" %>

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
    String myQuery          = "select * from groupnames ";
    String ID               = request.getParameter("id");

// If the id in the request is null or an empty string make it 0 to indicate an add
    if(ID == null || ID.equals("")) {
        ID = "0";
    } else {
        myQuery += "where id=" + ID;
    }

// Create a result set of the data for the form
    ResultSet lRs = io.opnRS(myQuery);

// Instantiate an RWInputForm and RWHtmlTable object
    RWInputForm frm = new RWInputForm(lRs);
    RWHtmlTable htmTb = new RWHtmlTable ("650", "0");

// Set display attributes for the input form
    frm.setTableBorder("0");
    frm.setDftTextBoxSize("35");
    frm.setDftTextAreaCols("35");
    frm.setDisplayDeleteButton(true);
    frm.setLabelBold(true);
    frm.setUpdateButtonText("  save  ");
    frm.setDeleteButtonText("remove");

// Sow the update and delete buttons
    if(!request.isUserInRole("codeMaint")) {
        frm.setDisplayDeleteButton(false);
        frm.setDisplayUpdateButton(false);
        frm.setFormItemsDisabled();
    }

// Get an input item with the record ID to set the rcd and ID fields
    out.print(frm.getInputForm());

// Set the return point
    session.setAttribute("returnUrl", "groups.jsp");
%>

<%@include file="template/pagebottom.jsp" %>