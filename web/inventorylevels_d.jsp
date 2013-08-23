<%-- 
    Document   : inventorylevels_d
    Created on : Jul 23, 2009, 11:24:58 AM
    Author     : Randy
--%>
<%@ include file="globalvariables.jsp" %>
<title>Comments</title>

<script language="JavaScript" src="js/date-picker.js"></script>

<script language="javascript">
  function submitForm(action) {
    var frmA=document.forms["frmInput"]
    frmA.method="POST"
    frmA.action=action
    frmA.submit()
  }  
</script>
<script>
  function setFocus() {
    document.frmInput.comment.focus();
  }
</script>
<%
// Initialize local variables
    String ID = request.getParameter("id");

// If the id in the request is null or an empty string make it 0 to indicate an add
    if(ID == null || ID.equals("")) {
        ID = "0";
    }

    ResultSet lRs=io.opnRS("select id, minimum, maximum, reorder from inventorylevels where itemid=" + ID);
    ResultSet itemRs=io.opnRS("select description from items where id=" + ID);
    if(itemRs.next()) {
        RWInputForm frm = new RWInputForm(lRs);

    // Set display attributes for the input form
        frm.setTableBorder("0");
        frm.setDftTextBoxSize("35");
        frm.setDftTextAreaCols("35");
        frm.setDisplayDeleteButton(true);
        frm.setLabelBold(true);
        frm.setUpdateButtonText("  save  ");
        frm.setDeleteButtonText("remove");
        frm.setFormHeight("110");
        frm.setTableWidth("410");

        out.print("<div align='center' width='100%'><b>" + itemRs.getString("description") + "</b></div>");
        out.print(frm.getInputForm());
    } else {
        out.print("<div align='center' width='100%'>Inventory item not found</div>");        
    }
    
    session.setAttribute("returnUrl", "");
%>
