<%@include file="globalvariables.jsp" %>

<title>Charge</title>
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
    String myQuery          = "select id, itemid, resourceid, quantity, chargeamount, comments from charges ";
    String id               = request.getParameter("id");

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

// Set display attributes for the input form
    frm.setTableBorder("0");
    frm.setTableWidth("250");
    frm.setDftTextBoxSize("35");
    frm.setDftTextAreaCols("35");
    frm.setDisplayDeleteButton(true);
    frm.setLabelBold(true);
    frm.setUpdateButtonText("  save  ");
    frm.setDeleteButtonText("remove");
    
// If payments exist for this charge, do not show the remove button
    if(checkForPayments(io, id)) { frm.setDisplayDeleteButton(false); }

// Get an input item with the record id to set the rcd and id fields
    out.print(frm.getInputForm());

    session.setAttribute("returnUrl", "");
%>
<%!
    public boolean checkForPayments(RWConnMgr io, String chargeId) throws Exception {
        ResultSet lRs=io.opnRS("select id from payments where provider<>10 and parentpayment=0 and chargeId=" + chargeId);
        boolean paymentsExist=lRs.next();
        lRs.close();

        return paymentsExist;
    }
%>
