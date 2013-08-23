<%@include file="globalvariables.jsp" %>
<%@include file="simpletabs.jsp" %>

<title>Providers</title>

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

    String myQuery          = "";
    String id               = request.getParameter("id");

// Set up the SQL based on the current tab
    if(curTab == 1) {
        myQuery = "select id, name, address, phonenumber, extension, contactname, contactemail, billingaddress, payer, setof, reserved from providers";
    } else if(curTab == 2) {
        myQuery = "select id, grouptaxid, grouppractice, payerid, tds, pos from providers";
    } else if(curTab == 3) {
        myQuery = "select id, ediid, claimoffice, necid from providers";
    } else if(curTab == 4) {
        myQuery = "select id, assignment, category, showqualifier, showinbox11, box19, practice, billprinttype, billingmap, billmaprptoffset from providers";
    }

// If the id in the request is null or an empty string make it 0 to indicate an add
    if(id == null || id.equals("")) {
        id = (String)session.getAttribute("id");
        if(id == null) { id = "0"; }
    }
    myQuery += " where id=" + id;

if(curTab < 5) {
// Create the outer table
    out.print(tabTbl.startRow());
    out.print(tabTbl.startCell(tabTbl.CENTER, "height=300 colspan=" + tabDesc.length + " style=\"border-bottom: black solid 1px; border-left: black solid 1px; border-right: black solid 1px;\""));

// Create a result set of the data for the form
    ResultSet lRs = io.opnRS(myQuery);

// Instantiate an RWInputForm and RWHtmlTable object
    RWInputForm frm = new RWInputForm(lRs);

// Set display attributes for the input form
    frm.setTableWidth("400");
    frm.setTableBorder("0");
    frm.setDftTextBoxSize("35");
    frm.setDftTextAreaCols("35");
    frm.setDisplayDeleteButton(false);
    frm.setLabelBold(true);
    frm.setUpdateButtonText("  save  ");
    frm.setDeleteButtonText("remove");

// Get an input item with the record id to set the rcd and id fields
    out.print(frm.getInputForm());

// Set the session variable to return to editing
    session.setAttribute("returnUrl", "providers_d.jsp?id=" + id);

} else { 
    session.setAttribute("providerId", id);
    session.setAttribute("patientId", null);

// Set the session variable to refresh the list
    session.setAttribute("returnUrl", "");
    out.print(tabTbl.startCell(tabTbl.CENTER, "height=300 colspan=" + tabDesc.length + " style=\"border-bottom: black solid 1px; border-left: black solid 1px; border-right: black solid 1px;\""));
%>
<%@ include file="defaultpayments_x.jsp" %>      
<%
}
// Close up the simple tabs
    out.print(tabTbl.endCell());
    out.print(tabTbl.endRow());

    out.print(tabTbl.endTable());

// Save the session variables
    session.setAttribute("id", id);
%>
