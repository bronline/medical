<%-- 
    Document   : vendors
    Created on : July 29, 2009, 7:39:37 PM
    Author     : Randy
--%>
<%@include file="template/pagetop.jsp" %>

<%
try {
// Set up the SQL statement
    String asofDate    = request.getParameter("asofDate");
    if(asofDate == null) { asofDate=Format.formatDate(new java.util.Date(),"yyyy-MM-dd"); }
    
    String myQuery     = "select id, name, phone1, phone2, phone3, email from vendors ";
    
    String url         = "vendors_d.jsp";
    String title       = "Supplier";
    String [] cw       = { "0", "200", "75", "75", "75", "200" };
    String [] ch       = { "", "Name", "Phone-1", "Phone-2", "Phone-3", "Email" };

// Create an RWFiltered List object
    RWFilteredList lst = new RWFilteredList(io);
    RWHtmlTable htmTb  = new RWHtmlTable("625", "0");
    RWHtmlForm frm     = new RWHtmlForm();
    RWFieldSet fldSet  = new RWFieldSet();

// Set special attributes on the filtered list object
    lst.setTableWidth("625");
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
    lst.setOnClickOption("\"" + title + "\",\"width=450,height=275,scrollbars=no,left=100,top=100,\"");
    lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    lst.setShowComboBoxes(false);
    lst.setUseCatalog(true);
    lst.setDivHeight(300);
    lst.setColumnWidth(cw);

// Show the filtered list
    htmTb.replaceNewLineChar(false);

    out.print(fldSet.getFieldSet(lst.getHtml(myQuery, ch), "style='width: " + lst.getTableWidth() +"'", "Supplier List", "style='font-size: 12; font-weight: bold;' align=center"));

    out.print(frm.startForm());
    out.print(frm.button("New " + title, "class=button onClick=window.open(\"" + url + "?id=0\",\"Locations\",\"width=450,height=275,scrollbars=no,left=100,top=100,\");" ));
    out.print(frm.endForm());

    session.setAttribute("parentLocation", self);

} catch (Exception e) {
    out.print(e);
}
%>
<%@ include file="template/pagebottom.jsp" %>
