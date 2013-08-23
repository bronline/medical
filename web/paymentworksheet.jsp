<%@include file="template/pagetop.jsp" %>
<script language="javascript">
  function submitForm(action) {
    var frmA=document.forms["frm1"]
    frmA.method="POST"
    frmA.action=action
    frmA.submit()
  }  
</script>

<%
try {
// Set up the SQL statement
    String myQuery     = "select id, year, startdate, plannedvisits, visitscovered-visitsused as visitscovered, " +
                         "insurancepervisit, patientportionwhilecovered, patientportionafterexpires " +
                         "from paymentschedule ";

    String url         = "paymentworksheet_d.jsp";
    String title       = "Payment Worksheets";

// Check to see if the patient is set.  If so, display the list
    if(patient.getId() != 0) {
        myQuery += "where patientid=" + patient.getId() + " order by year desc";

        // Create an RWFiltered List object
        RWFilteredList lst = new RWFilteredList(io);
        RWHtmlTable htmTb  = new RWHtmlTable("500", "0");
        RWHtmlForm frm     = new RWHtmlForm();
        RWFieldSet fldSet  = new RWFieldSet();

    // Set special attributes on the filtered list object
        lst.setTableBorder("0");
        lst.setTableWidth("500");
        lst.setCellPadding("3");
        lst.setAlternatingRowColors("#ffffff", "#cccccc");
        lst.setRoundedHeadings("#030089", "");
        String [] cellWidths = {"0", "50", "75", "75", "100", "70", "70", "70"};
        String [] cellHeadings = { "", "Year", "Start Date", "Planned Visits", "Visits Covered", "IPV", "PPPV", "PPAE" };
        lst.setColumnWidth(cellWidths);
        lst.setUrlField(0);
        lst.setNumberOfColumnsForUrl(2);
        lst.setRowUrl(url);
        lst.setShowRowUrl(true);
        lst.setOnClickAction("window.open");
        lst.setOnClickOption("\"" + "PaymentWorksheets" + "\",\"width=650,height=550,scrollbars=no,left=140,top=40,\"");
        lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
        lst.setShowComboBoxes(false);
        lst.setDivHeight(300);
        lst.setColumnAlignment(1,"CENTER");
        lst.setColumnAlignment(2,"CENTER");
        lst.setColumnAlignment(3,"CENTER");
        lst.setColumnAlignment(4,"CENTER");
        
    // Show the filtered list
        htmTb.replaceNewLineChar(false);

        out.print(fldSet.getFieldSet(lst.getHtml(myQuery, cellHeadings), "style='width: " + lst.getTableWidth() +"'", title + " for " + patient.getPatientName(), "style='font-size: 12; font-weight: bold;' align=center"));

        out.print(frm.startForm());
//        out.print(frm.button("New Payment Worksheet", "class=button onClick=window.open(\"" + "duplatestpaymentschedule.jsp" + "?id=0\",\"Locations\",\"width=650,height=550,scrollbars=no,left=140,top=40,\");" ));
        out.print(frm.button("New Payment Worksheet", "class=button onClick=submitForm('duplatestpaymentschedule.jsp')"));
        out.print(frm.endForm());
    }

    session.setAttribute("parentLocation", request.getRequestURI());
    session.setAttribute("returnUrl", request.getRequestURI());

} catch (Exception e) {
    out.print(e);
}
%>

<%@ include file="template/pagebottom.jsp" %>