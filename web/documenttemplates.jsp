<%@ include file="template/pagetop.jsp" %>

<%
// Set up the SQL statement
    String myQuery     = "select * from documenttemplatelist order by type, identifier";
    String url         = "documenttemplates_d.jsp";
    String title       = "Document Templates";
    String [] cw       = { "0", "100", "150", "150", "200" } ;

    RWFilteredList lst = new RWFilteredList(io);
    RWHtmlTable htmTb  = new RWHtmlTable("620", "0");
    RWHtmlForm frm     = new RWHtmlForm();
    RWFieldSet fldSet  = new RWFieldSet();

    lst.setTableWidth("600");
    lst.setTableBorder("0");
    lst.setAlternatingRowColors("#ffffff", "#cccccc");
    lst.setRoundedHeadings("#030089", "");
//    lst.setTableHeading(title);
    lst.setUrlField(0);
    lst.setNumberOfColumnsForUrl(2);
    lst.setRowUrl(url);
    lst.setShowRowUrl(true);
    lst.setOnClickAction("window.open");
    lst.setOnClickOption("\"Templates\",\"width=450,height=150,scrollbars=no,left=100,top=100,\"");
    lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    lst.setShowComboBoxes(true);
    lst.setUseCatalog(true);
    lst.setDivHeight(300);
    lst.setColumnWidth(cw);

// Show the filtered list of available templates
    htmTb.replaceNewLineChar(false);
    out.print(fldSet.getFieldSet(lst.getHtml(request, myQuery), "style='width: " + lst.getTableWidth() +"'", title, "style='font-size: 12; font-weight: bold;' align=center"));
    out.print(frm.startForm());
    out.print(frm.button("New Template", "class=button onClick=window.open(\"documenttemplates_u.jsp?id=0\",\"Templates\",\"width=450,height=150,scrollbars=no,left=100,top=100,\");" ));
    out.print(frm.endForm());

    session.setAttribute("parentLocation", self);

%>

<%@ include file="template/pagebottom.jsp" %>