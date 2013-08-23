<%@include file="globalvariables.jsp" %>

<title>Item Types</title>
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
    String myQuery          = "select ";
    String id               = request.getParameter("id");
    String providerId       = request.getParameter("providerId");
    String patientId        = request.getParameter("patientId");

// Check to see if either a patientId or providerId has been passed in
// If not, set the respective value to zero.
    if(providerId == null) {
        providerId = "0";
        myQuery += "id, providerid, itemid, amount from defaultpayments ";
    }else if(patientId == null) {
        patientId = "0";
        myQuery += "id, itemId, amount from defaultpayments ";
    } else {
        providerId = "0";
        patientId = "0";
        myQuery += "* from defaultpayments ";
    }

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
    RWHtmlTable htmTb = new RWHtmlTable ("450", "0");

// Set display attributes for the input form
    frm.setTableWidth("450");
    frm.setTableBorder("0");
    frm.setDftTextBoxSize("35");
    frm.setDftTextAreaCols("35");
    frm.setDisplayDeleteButton(true);
    frm.setLabelBold(true);
    frm.setUpdateButtonText("  save  ");
    frm.setDeleteButtonText("remove");

// Setup the hidden variables based on what has been passed in
    if(id.equals("0")) {
        String [] var = { "" };
        String [] val = { "" };
        if(!providerId.equals("0")) {
            var[0] = "providerid";
            val[0] = providerId;
        } else if(!patientId.equals("0")) {
            var[0] = "patientid";
            val[0] = patientId;
        }
        frm.setPreLoadFields(var);
        frm.setPreLoadValues(val);
    }

// Get an input item with the record id to set the rcd and id fields
    out.print(frm.getInputForm());

    session.setAttribute("returnUrl", "");
%>
