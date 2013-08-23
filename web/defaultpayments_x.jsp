<%@page import="tools.*" %>
<script language="javascript">
  function updateDefaults(action) {
    var frmA=document.forms["frmInput"]
    frmA.method="POST"
    frmA.action=action
    frmA.submit()
  }
</script>
<%
try {
// Receive the parameters 
    String providerId  = request.getParameter("providerId");
    String patientId   = request.getParameter("patientId");

// Setup local variables
    String me           = request.getRequestURI();
    String url          = "defaultpayments_d.jsp";
    String title        = "Defaults";
    String linkVariable = "";

    if(providerId == null) { providerId = (String)session.getAttribute("providerId"); }
    if(patientId == null) { patientId = (String)session.getAttribute("patientId"); }

// Instantiate a table and a form
    RWHtmlTable htmTb = new RWHtmlTable("370", "0");
    htmTb.replaceNewLineChar(false);
 
    RWInputForm frm = new RWInputForm();
    frm.setShowDatePicker(true);
    frm.setDftTextBoxSize("25");
    frm.formItemOnOneRow = false;
    frm.setLabelBold(true);
    frm.setLabelPosition(frm.LABEL_ON_LEFT);
    frm.setUseExternalForm(true);

    frm.setDftTextBoxSize("25");
    frm.formItemOnOneRow = false;
    frm.setLabelBold(true);
    frm.setLabelPosition(frm.LABEL_ON_LEFT);
    frm.setUseExternalForm(true);
    frm.setShowDatePicker(true);

    StringBuffer iForm = new StringBuffer();

// Create a new paymentform
    String localQuery =    "SELECT ifnull(a.patientid,0), " + providerId +  " as providerId, b.id as itemId, ifnull(a.id,0) as dftid, " +
                        "b.description, b.code, b.amount, ifnull(a.amount,0) as defaultpayment, " +
                        "ifnull(a.copay,0) as copay , modifier " +
                        "FROM items b " +
                        "left outer join " +
                        "(select * from defaultpayments " +
                        "where patientid=0 and providerid=" + providerId + ") a on b.id=a.itemid  " +
                        "order by description, code";
    
    htmTb.setWidth("370");

// Put this in a left justified table so the stuff lines up
    iForm.append("<table><tr><td align=left>");
// Build the form now
    iForm.append(frm.startForm());

    ResultSet pRs = io.opnRS(localQuery);
    iForm.append(htmTb.startTable());
    iForm.append(htmTb.startRow());
    iForm.append(htmTb.headingCell("Procedure", "width=150"));
    iForm.append(htmTb.headingCell("Code", "width=50"));
    iForm.append(htmTb.headingCell("Charge Amount", "width=50"));
    iForm.append(htmTb.headingCell("Default Payment", "width=60"));
    iForm.append(htmTb.headingCell("CoPay", "width=60"));
    iForm.append(htmTb.headingCell("Modifier", "width=60"));
    iForm.append(htmTb.endRow());
    iForm.append(htmTb.endTable());

    String itemId="0";
    providerId="0";
    String dftId="0";
    iForm.append("<div style=\" height: 200; width: 388; overflow: auto;\">");
    iForm.append(htmTb.startTable());
    String rowColor="lightgrey";
    while (pRs.next()) {
        providerId=pRs.getString("providerId");
        itemId=pRs.getString("itemId");
        dftId=pRs.getString("dftId");
        iForm.append(htmTb.startRow("bgcolor="+rowColor));
        iForm.append(htmTb.addCell(pRs.getString("description"), "width=200"));
        iForm.append(htmTb.addCell(pRs.getString("code"), "width=50"));
        iForm.append(htmTb.addCell(pRs.getString("amount"), 1, "width=50"));
        iForm.append(htmTb.addCell(frm.textBox(pRs.getString("defaultpayment"),"defaultpayment_"+dftId+"_"+itemId+"_"+providerId, "8","8","class=tBoxText style=\"text-align: right;\""), 2, "width=60"));
        iForm.append(htmTb.addCell(frm.textBox(pRs.getString("copay"),"copay_"+dftId+"_"+itemId+"_"+providerId, "8","8","class=tBoxText style=\"text-align: right;\""), 2, "width=60"));
        iForm.append(htmTb.addCell(frm.textBox(pRs.getString("modifier"),"modifier_"+dftId+"_"+itemId+"_"+providerId, "8","8","class=tBoxText style=\"text-align: right;\""), 2, "width=60"));
        iForm.append(htmTb.endRow());
        if (rowColor.equals("lightgrey")) {
            rowColor="#cccccc";
        } else {
            rowColor="lightgrey";
        }

    }
    iForm.append(htmTb.endTable());
    iForm.append("</div>");

// Everything we need is inside the form.  Close it up.
    iForm.append(frm.endForm());

    iForm.append("<br>" + frm.button("Update Defaults","class=button onclick=updateDefaults(\"updatedefaultpayments.jsp\")","Filter"));
    iForm.append("</td></tr></table>");

// Spit the results out to the browser
    out.print(iForm.toString());
    
// Save the session variables
    session.setAttribute("returnUrl", "providers_d.jsp?tab=5");

} catch (Exception e) {
    out.print(e);
}
%>