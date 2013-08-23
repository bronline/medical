<%@include file="template/pagetop.jsp" %>

<%
try {
// Set up the SQL statement
    String myQuery     = "select * from apptstarttimes ";
    String url         = "apptstarttimes_d.jsp";
    String title       = "Times";

// Create an RWFiltered List object
    RWFilteredList lst = new RWFilteredList(io);
    RWHtmlTable htmTb  = new RWHtmlTable("200", "0");
    RWHtmlForm frm     = new RWHtmlForm();
    RWFieldSet fldSet  = new RWFieldSet();

// Set special attributes on the filtered list object
    String [] cw       = {"0", "100" };
    String [] ch       = {"", "Time"};

    lst.setTableWidth("100");
    lst.setTableBorder("0");
    lst.setCellPadding("3");
    lst.setAlternatingRowColors("#ffffff", "#cccccc");
    lst.setRoundedHeadings("#030089", "");
//    lst.setTableHeading(title);
    lst.setUrlField(0);
    lst.setNumberOfColumnsForUrl(2);
    lst.setRowUrl(url);
    lst.setShowRowUrl(true);
    lst.setOnClickAction("window.open");
    lst.setOnClickOption("\"" + title + "\",\"width=200,height=100,scrollbars=no,left=100,top=100,\"");
    lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    lst.setShowComboBoxes(false);
    lst.setUseCatalog(true);
    lst.setColumnWidth(cw);
//    lst.setUsePercentages(true);
    lst.setDivHeight(300);

// Show the filtered list
    //out.print(lst.getHtml(myQuery, ch) );

    htmTb.replaceNewLineChar(false);
    htmTb.setWidth("120");

//    out.print(htmTb.startTable());
//    out.print(htmTb.startRow());
//    out.print(htmTb.startCell(htmTb.LEFT));
//    out.print(lst.getHtml(myQuery, ch));
//    out.print(htmTb.endCell());
//    out.print(htmTb.endTable());
    
//    out.print(lst.getHtml(myQuery, ch));

    out.print(fldSet.getFieldSet(lst.getHtml(myQuery, ch) ,"style='width: " + lst.getTableWidth() + ";'", "Start Times", "style='font-size: 12; font-weight: bold;'" ));

    out.print(frm.startForm());
    out.print(frm.button("New " + title, "class=button onClick=window.open(\"" + url + "?id=0\",\"StartTimes\",\"width=200,height=100,scrollbars=no,left=100,top=100,\");" ));
    out.print(frm.endForm());

    session.setAttribute("parentLocation", self);

} catch (Exception e) {
    out.print(e);
}
%>
<%@ include file="template/pagebottom.jsp" %>