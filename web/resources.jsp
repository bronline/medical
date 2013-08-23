<%@include file="template/pagetop.jsp" %>
<%@include file="ajax/ajaxstuff.jsp" %>
<%
try {
// Set up the SQL statement
    String myQuery     = "select id, name, credentials, officename, concat('<input type=button value=\"office hours\" class=button onClick=showItem(event,\"resourcehours.jsp?resourceId=',id,'\",0,0,txtHint)>') as Hours from resources order by name";
    String url         = "resources_d.jsp";
    String title       = "Resources";

// Create an RWFiltered List object
    RWFilteredList lst = new RWFilteredList(io);
    RWHtmlTable htmTb  = new RWHtmlTable("650", "0");
    RWHtmlForm frm     = new RWHtmlForm();
    RWFieldSet fldSet  = new RWFieldSet();

// Set special attributes on the filtered list object
    lst.setTableWidth("650");
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
    lst.setOnClickOption("\"" + title + "\",\"width=450,height=350,scrollbars=no,left=100,top=100,\"");
    lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    lst.setShowComboBoxes(false);
    lst.setUseCatalog(true);
    lst.setDivHeight(300);

// Show the filtered list
    htmTb.replaceNewLineChar(false);

    out.print(fldSet.getFieldSet(lst.getHtml(myQuery), "style='width: " + lst.getTableWidth() +"'", "Resources", "style='font-size: 12; font-weight: bold;' align=center"));

    out.print(frm.startForm());
    out.print(frm.button("New " + title, "class=button onClick=window.open(\"" + url + "?id=0\",\"Locations\",\"width=450,height=150,scrollbars=no,left=100,top=100,\");" ));
    out.print(frm.endForm());

    session.setAttribute("parentLocation", self);

} catch (Exception e) {
    out.print(e);
}
%>
<%@ include file="template/pagebottom.jsp" %>