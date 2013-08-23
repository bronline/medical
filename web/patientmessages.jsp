<%@include file="template/pagetop.jsp" %>

<%
try {
// Set up the SQL statement
    String myQuery     = "select id, message, date, amount, onvisit, startvisit, atvisit, DATE_FORMAT(displayed, '%m/%d/%y') AS displayed, DATE_FORMAT(complete, '%m/%d/%y') AS complete " +
                         "from patientmessages ";

    String url         = "patientmessages_d.jsp";
    String title       = "Messages";

// Check to see if the patient is set.  If so, display the list
    if(patient.getId() != 0) {
//        myQuery += "where patientid=" + patient.getId() + " and displayed='0001-01-01 00:00:00' and complete='0001-01-01 00:00:00' order by date";
        myQuery += "where patientid=" + patient.getId() + " order by date";

        String [] cw       = {"0", "250", "75", "75", "75", "75", "75", "75", "75"};
        String [] ch       = {"", "Message", "Date", "Amount", "On Visit #", "Start on Visit #", "Show On Visit #", "Date Displayed", "Date Completed" };

        // Create an RWFiltered List object
        RWFilteredList lst = new RWFilteredList(io);
        RWHtmlTable htmTb  = new RWHtmlTable("470", "0");
        RWHtmlForm frm     = new RWHtmlForm();
        RWFieldSet fldSet  = new RWFieldSet();

    // Set special attributes on the filtered list object
        lst.setTableBorder("0");
        lst.setCellPadding("2");
        lst.setAlternatingRowColors("#ffffff", "#cccccc");
        lst.setRoundedHeadings("#030089", "");
        lst.setColumnWidth(cw);
        lst.setUrlField(0);
        lst.setNumberOfColumnsForUrl(2);
        lst.setRowUrl(url);
        lst.setColumnAlignment(7, "CENTER");
        lst.setColumnAlignment(8, "CENTER");
        lst.setShowRowUrl(true);
        lst.setOnClickAction("window.open");
        lst.setOnClickOption("\"" + title + "\",\"width=450,height=150,scrollbars=no,left=100,top=100,\"");
        lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
        lst.setShowComboBoxes(false);
        lst.setUseCatalog(true);
        lst.setDivHeight(300);

    // Show the filtered list
        htmTb.replaceNewLineChar(false);

        out.print(fldSet.getFieldSet(lst.getHtml(request,myQuery,ch), "style='width: " + lst.getTableWidth() +"'", title + " for " + patient.getPatientName(), "style='font-size: 12; font-weight: bold;' align=center"));

        out.print(frm.startForm());
        out.print(frm.button("New " + title, "class=button onClick=window.open(\"" + url + "?id=0\",\"Locations\",\"width=450,height=150,scrollbars=no,left=100,top=100,\");" ));
        out.print(frm.endForm());
    }

    session.setAttribute("parentLocation", request.getRequestURI());

} catch (Exception e) {
    out.print(e);
}
%>

<%@ include file="template/pagebottom.jsp" %>