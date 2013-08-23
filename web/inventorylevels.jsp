<%-- 
    Document   : inventorylevels
    Created on : May 6, 2009, 7:39:37 PM
    Author     : Randy
--%>
<%@include file="template/pagetop.jsp" %>

<%
try {
// Set up the SQL statement
    String asofDate    = request.getParameter("asofDate");
    if(asofDate == null) { asofDate=Format.formatDate(new java.util.Date(),"yyyy-MM-dd"); }
    
    String myQuery     = "SELECT i.id, i.description, " +
                         "ifnull(r.receipts,0)-ifnull(s.sales,0) as currentlevel, " +
                         "ifnull(l.minimum,0) minimum, " +
                         "ifnull(l.maximum,0) as maximum, " +
                         "ifnull(l.reorder,0) as reorder " +
                         "FROM items i " +
                         "LEFT JOIN inventorylevels l on l.itemid=i.id " +
                         "LEFT JOIN itemsales s on s.itemid=i.id and s.date<='" + asofDate + "' " +
                         "LEFT JOIN itemreceipts r on r.itemid=i.id and r.date<='" + asofDate + "' " +
                         "WHERE i.inventoryitem";
    
    String url         = "inventorylevels_d.jsp";
    String title       = "Level";
    String [] cw       = { "0", "300", "75", "75", "75", "75" };
    String [] ch       = { "", "Inventory Item", "Level", "Minimum", "Maximum", "Reorder" };

// Create an RWFiltered List object
    RWFilteredList lst = new RWFilteredList(io);
    RWHtmlTable htmTb  = new RWHtmlTable("500", "0");
    RWHtmlForm frm     = new RWHtmlForm();
    RWFieldSet fldSet  = new RWFieldSet();

// Set special attributes on the filtered list object
    lst.setTableWidth("500");
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
    lst.setOnClickOption("\"" + title + "\",\"width=450,height=150,scrollbars=no,left=100,top=100,\"");
    lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    lst.setShowComboBoxes(false);
    lst.setUseCatalog(true);
    lst.setDivHeight(300);
    lst.setColumnWidth(cw);

// Show the filtered list
    htmTb.replaceNewLineChar(false);

    out.print(fldSet.getFieldSet(lst.getHtml(myQuery, ch), "style='width: " + lst.getTableWidth() +"'", "Inventory Levels", "style='font-size: 12; font-weight: bold;' align=center"));

    out.print(frm.startForm());
//    out.print(frm.button("New " + title, "class=button onClick=window.open(\"" + url + "?id=0\",\"Locations\",\"width=450,height=150,scrollbars=no,left=100,top=100,\");" ));
//    out.print(frm.endForm());

    session.setAttribute("parentLocation", self);

} catch (Exception e) {
    out.print(e);
}
%>
<%@ include file="template/pagebottom.jsp" %>
