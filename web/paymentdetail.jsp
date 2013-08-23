<%@include file="globalvariables.jsp" %>

<title>Payment</title>
<script language="JavaScript" src="js/CheckDate.js"></script>
<script language="JavaScript" src="js/CheckLength.js"></script>

<script language="javascript">
  function submitForm(action) {
    var frmA=document.forms["frmInput"]
    frmA.method="POST"
    frmA.action=action
    frmA.submit()
  }

  function postBulkPayment() {
    var frmA=document.forms["frmInput"]
    frmA.method="POST"
    frmA.action="applybulkpayments.jsp";
    frmA.submit()
  }

  function removePayment(id) {
    var url="ajax/removepayment.jsp?id=" + id + "&sid="+Math.random();

    if(confirm("Removing this payment removes all children as well.  Are you sure you want to remove this payment")) {
        $.ajax({
            url: url,
            success: function(data){
                self.close();
            },
            error: function() {
                alert("There was a problem processing the request");
            }
        });
        window.opener.location.href="payments.jsp";
    }
  }
</script>

<%
    out.print("<script type=\"text/javascript\">window.opener.location.href=\"payments.jsp\";</script>");
// Initialize local variables
    String myQuery          = "select id, checknumber, amount, date from payments ";
    String id               = request.getParameter("id");
    String batchId          = request.getParameter("batchId");
    String today            = request.getParameter("today");
    String parentLocation   = (String)session.getAttribute("parentLocation");
    String pipPayment       = request.getParameter("pipPayment");
    String title="Maintain Payment";
    String fields[] = new String[4];
    String values[] = new String[4];

// If the id in the request is null or an empty string make it 0 to indicate an add
    if(id == null || id.equals("") || id.equals("0")) {
        id = "0";
        if(batchId == null) { myQuery = "select id, provider, checknumber, amount, date from payments "; }
        patient.beforeFirst();
        patient.next();
        title="Add Patient Payment for " + patient.getString("firstname") + " " + patient.getString("lastname");
    }

    myQuery += "where id=" + id;

    // Check to see if this is an unapplied payment with children
    boolean childItemsExist=checkForChildItems(io, id);

    // Create a result set of the data for the form
    ResultSet lRs = io.opnRS(myQuery);

// Instantiate an RWInputForm and RWHtmlTable object
    RWInputForm frm = new RWInputForm(lRs);
    if(batchId == null || batchId.equals("")) {
        frm.setFormUrl("updatepayment.jsp?a=1");
    } else if(batchId != null) {
//        frm.setFormUrl("applypayments.jsp?batchId=" + batchId + "&batchesOnly=Y" );
        if(pipPayment == null) {
            frm.setFormUrl("applyinsurancepayments.jsp?batchId=" + batchId + "&batchesOnly=Y" );
        } else {
            frm.setFormUrl("applypippayments.jsp?batchId=" + batchId + "&batchesOnly=Y" );
        }
        session.setAttribute("multiplePayments", "Y");
        session.setAttribute("myParent","bills.jsp");
        session.setAttribute("batchId", batchId);
    }

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

// Get an input item with the record id to set the rcd and id fields
    if (id.equals("0")) {
        fields[0]="patientid";
        fields[1]="provider";
        fields[2]="batchId";
        fields[3]="today";
        values[0]=""+patient.getId();
        if(batchId != null) {
            ResultSet providerRs=io.opnRS("select provider from batches where id=" + batchId);
            if(providerRs.next()) { values[1]=providerRs.getString("provider"); }
            providerRs.close();
        } else {
            values[1]="0";
        }
        if(batchId != null) { values[2]=batchId; } else { values[2]=""; }
        if(today != null) { values[3]=today; } else { values[3]=""; }
        frm.setPreLoadFields(fields);
        frm.setPreLoadValues(values);
    }

// don't show the remove button if this is an unapplied payment with child items
    if(childItemsExist) { frm.setDisplayDeleteButton(false); }

    out.print("<H1>"+title+"</H1>");
//out.print(pipPayment);
    out.print(frm.getInputForm());

    if(id.equals("0")) { out.print("" + frm.button("Apply as bulk payment", "class=button onClick=postBulkPayment()" )); }

// Show the apply to open charges button if this is an unapplied payment
    lRs = io.opnRS("select id, provider, amount, checknumber, chargeid from payments where id=" + id + " and chargeid=0");
    if (lRs.next()) {
        out.print("<br/><br/>");
        if(childItemsExist) { out.print(frm.button("remove", "class=\"button\" onClick=\"removePayment(" + id + ")\"") + "&nbsp;&nbsp;&nbsp;&nbsp;"); }
        out.print(frm.button("Apply to open charges", "class=button onClick=self.close();window.open(\"applypayments.jsp?checkNumber=" + lRs.getString("checknumber") + "&parentPayment=" + lRs.getString("id") + "&checkAmount=" + lRs.getString("amount") + "&providerId=" + lRs.getString("provider") + "\",\"Apply\",\"width=800,height=550,scrollbars=no,left=100,top=100,\");" ));
        session.setAttribute("closeWhenDone", session.getAttribute("parentLocation"));
    }

    if(batchId == null || batchId.equals("") || today == null || today.equals("")) { session.setAttribute("returnUrl", ""); }
%>
<%! public boolean checkForChildItems(RWConnMgr io, String id) throws Exception {
        boolean bool=false;
        if(!id.equals("0")) {
            ResultSet lRs=io.opnRS("select * from payments where parentpayment=" + id);
            if(lRs.next()) { bool=true; }
            lRs.close();
         }
        return bool;
    }
%>
