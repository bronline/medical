<%@include file="template/pagetop.jsp" %>

<%
try {
// Set up the SQL statement
    String myQuery     = "select * from subitemtypes " +
                         "order by type";
    String url         = "subitemtypes_d.jsp";
    String title       = "SubItem Types";

// Create an RWFiltered List object
    RWFilteredList lst = new RWFilteredList(io);
    RWHtmlTable htmTb  = new RWHtmlTable("620", "0");
    RWHtmlForm frm     = new RWHtmlForm();
    RWFieldSet fldSet  = new RWFieldSet();

// Set special attributes on the filtered list object
    String [] cw       = {"0", "200" };
    String [] ch       = {"", "Type" };

    lst.setTableWidth("300");
    lst.setTableBorder("0");
    lst.setCellPadding("3");
    lst.setAlternatingRowColors("#ffffff", "#cccccc");
    lst.setRoundedHeadings("#030089", "");
    lst.setTableHeading(title);
    lst.setUrlField(0);
    lst.setNumberOfColumnsForUrl(2);
    lst.setRowUrl(url);
    lst.setShowRowUrl(true);
    lst.setOnClickAction("window.open");
    lst.setOnClickOption("\"" + "SubItemTypes" + "\",\"width=500,height=250,scrollbars=no,left=100,top=100,\"");
    lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    lst.setShowComboBoxes(false);
    lst.setUseCatalog(false);
    lst.setColumnWidth(cw);
//    lst.setUsePercentages(true);
    lst.setDivHeight(300);

// Show the filtered list
    htmTb.replaceNewLineChar(false);

    out.print(fldSet.getFieldSet(lst.getHtml(myQuery, ch), "style='width: " + lst.getTableWidth() +"'", "SubItem Types", "style='font-size: 12; font-weight: bold;' align=center"));

    out.print(frm.startForm());
    out.print(frm.button("New " + title, "class=button onClick=window.open(\"" + url + "?id=0\",\"Locations\",\"width=500,height=250,scrollbars=no,left=100,top=100,\");" ));
    out.print(frm.endForm());

    session.setAttribute("parentLocation", self);

} catch (Exception e) {
    out.print(e);
}
%>
<%@ include file="template/pagebottom.jsp" %>