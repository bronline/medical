<%@ include file="template/pagetop.jsp" %>
<script language="javascript">
  function submitForm(action) {
    var isSure = confirm('This Action will reset all changes in the list.  Do you want to continue?');
    if (isSure==true) {
        var frmA=document.forms["frmInput"]
        frmA.method="POST"
        frmA.action=action
        frmA.submit()
    }
  }  
  function updateDefaults(action) {
    var frmA=document.forms["frmInput"]
    frmA.method="POST"
    frmA.action=action
    frmA.submit()
  }
  function refreshParentPage(where) {
    if(where != null) {
      window.opener.location.href=where;
    }
  }
</script>
<body onUnLoad="refreshParentPage('<%= (String)session.getAttribute("myParent") %>')">

<%
//// Set the patient id
//    if(patient.getId() != 0) {
//        session.setAttribute("providerId", null);
//        session.setAttribute("patientId", "" + patient.getId());
//%>
<%//@ include file="defaultpayments.jsp" %>
<%
//    } else {
//        out.print("Patient not set");
//    }
%>
<%
// Instantiate a table and a form
    RWHtmlTable htmTb = new RWHtmlTable("700", "0");
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
    String myQuery =    "SELECT a.patientid, b.id as providerid, c.id as itemid, ifnull(d.id,0) as dftid, " +
                        "b.name, c.description, c.code, c.amount, ifnull(d.amount,ifnull(e.amount,0)) as defaultpayment, " +
                        "ifnull(d.copay,ifnull(e.copay,0)) as copay, ifnull(d.modifier,ifnull(e.modifier,''))as modifier,  " +
                        "ifnull(d.billinsurance,ifnull(e.billinsurance,'1')) as billinsurance " +
                        "FROM patientinsurance a " +
                        "join providers b on a.providerid=b.id join items c on 1=1 " + 
                        "left outer join defaultpayments d on a.providerid=d.providerid and a.patientid=d.patientid and c.id=d.itemid " +
                        "left outer join defaultpayments e on a.providerid=e.providerid and e.patientid=0 and c.id=e.itemid " +
                        "where a.patientid=" + patient.getId() + " order by name, description";
    
    htmTb.setWidth("700");
    htmTb.setBorder("0");  

// Build the form now
    iForm.append("<table><tr><td align=left>");
    iForm.append(frm.startForm());

    ResultSet pRs = io.opnRS(myQuery);
    iForm.append(htmTb.startTable());
    iForm.append(htmTb.startRow());
    iForm.append(htmTb.headingCell("Insurance", "width=100"));
    iForm.append(htmTb.headingCell("Procedure", "width=250"));
    iForm.append(htmTb.headingCell("Code", "width=50"));
    iForm.append(htmTb.headingCell("Charge Amount", "width=50"));
    iForm.append(htmTb.headingCell("Default Payment", "width=50"));
    iForm.append(htmTb.headingCell("Patient Portion", "width=50"));
    iForm.append(htmTb.headingCell("Mod", "width=30"));
    iForm.append(htmTb.headingCell("Bill", "width=20"));
    iForm.append(htmTb.endRow());
    iForm.append(htmTb.endTable());

    String itemId="0";
    String providerId="0";
    String dftId="0";
    iForm.append("<div style=\" height: 300; width: 718; overflow: auto;\">");
    iForm.append(htmTb.startTable());
    String rowColor="#ffffff";
    while (pRs.next()) {
        providerId=pRs.getString("providerId");
        itemId=pRs.getString("itemId");
        dftId=pRs.getString("dftId");
        iForm.append(htmTb.startRow("bgcolor="+rowColor));
        iForm.append(htmTb.addCell(pRs.getString("name"), "width=100"));
        iForm.append(htmTb.addCell(pRs.getString("description"), "width=250"));
        iForm.append(htmTb.addCell(pRs.getString("code"), "width=50"));
        iForm.append(htmTb.addCell(pRs.getString("amount"), 1, "width=50"));
        iForm.append(htmTb.addCell(frm.textBox(pRs.getString("defaultpayment"),"defaultpayment_"+dftId+"_"+itemId+"_"+providerId, "8","8","class=tBoxText style=\"text-align: right;\""), 2, "width=50"));
        iForm.append(htmTb.addCell(frm.textBox(pRs.getString("copay"),"copay_"+dftId+"_"+itemId+"_"+providerId, "8","8","class=tBoxText style=\"text-align: right;\""), 2, "width=50"));
        iForm.append(htmTb.addCell(frm.textBox(pRs.getString("modifier"),"modifier_"+dftId+"_"+itemId+"_"+providerId, "4","4","class=tBoxText style=\"text-align: right;\""), 2, "width=30"));
        iForm.append(htmTb.addCell(frm.checkBox(pRs.getBoolean("billinsurance"),"","billinsurance_"+dftId+"_"+itemId+"_"+providerId),2,"width=20"));
        iForm.append(htmTb.endRow());
        if (rowColor.equals("#ffffff")) {
            rowColor="#cccccc";
        } else {
            rowColor="#ffffff";
        }

    }
    iForm.append(htmTb.endTable());
    iForm.append("</div>");

// Everything we need is inside the form.  Close it up.
    iForm.append(frm.endForm());
    iForm.append("</td></tr></table>");

    iForm.append("<br>" + frm.button("Update Defaults","class=button onclick=updateDefaults(\"updatepatientallowances.jsp\")","Filter"));

// Spit the results out to the browser
    out.print(iForm.toString());
    
// Save the session variables
    session.setAttribute("returnUrl", "patientallowances.jsp");

%>
<%@ include file="template/pagebottom.jsp" %>