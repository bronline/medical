<%@page import="tools.*" %>

<%
try {
// Receive the parameters 
    String providerId  = request.getParameter("providerId");
    String patientId   = request.getParameter("patientId");

// Setup local variables
    String me           = request.getRequestURI();
    String localQuery   = "select defaultpayments.id, ";
    String url          = "defaultpayments_d.jsp";
    String title        = "Defaults";
    String linkVariable = "";

    if(providerId == null) { providerId = (String)session.getAttribute("providerId"); }
    if(patientId == null) { patientId = (String)session.getAttribute("patientId"); }

// Limit the list based on what variables have been passed in
    if(providerId != null && patientId == null) {
        linkVariable = "&providerId=" + providerId;
        localQuery += "items.description, defaultpayments.amount from defaultpayments " +
                   "join items on defaultpayments.itemid=items.id " +
                   "where patientid=0 " +
                   "and providerid=" + providerId + 
                   " order by items.description";
    } else if(patientId != null && providerId == null) {
        linkVariable = "&patientId=" + patientId;
        localQuery += "providers.name, items.description, defaultpayments.amount from defaultpayments " +
                   "join items on defaultpayments.itemid=items.id  " +
                   "left outer join providers on defaultpayments.providerId=providers.id " +
                   "where defaultpayments.patientid=" + patientId +
                   " order by providers.name, items.description";
    } else {
        localQuery += "concat(patients.lastname, ', ', patients.firstname) as Patient, " +
                   "providers.name, items.description, defaultpayments.amount from defaultpayments " +
                   "join items on defaultpayments.itemid=items.id " +
                   "join providers on defaultpayments.providerid=providers.id " +
                   "join patients on defaultpayments.patientid=patients.id " +
                   "order by providers.name, patients.lastname, patients.firstname, items.description";
    }

// Create an RWFiltered List object
    RWConnMgr localIo  = new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);
    RWFilteredList lst = new RWFilteredList(localIo);
    RWHtmlForm frm     = new RWHtmlForm();
    RWHtmlTable htmTb  = new RWHtmlTable("370", "0");

// Set special attributes on the filtered list object
    lst.setTableWidth("350");
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
    lst.setOnClickOption("\"" + title + "\",\"width=450,height=150,scrollbars=no,left=100,top=100,\"");
    lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    lst.setShowComboBoxes(false);
    lst.setUseCatalog(true);
    lst.setDivHeight(200);

// Show the filtered list
    htmTb.replaceNewLineChar(false);

    out.print(htmTb.startTable());
    out.print(htmTb.startRow());
    out.print(htmTb.startCell(htmTb.LEFT));
    out.print(lst.getHtml(localQuery));
    out.print(htmTb.endCell());
    out.print(htmTb.endTable());

//    out.print(htmTb.getFrame("#030089", lst.getHtml(localQuery)));

    out.print(frm.startForm());
    out.print(frm.button("New " + title, "class=button onClick=window.open(\"" + url + "?id=0" + linkVariable + "\",\"Locations\",\"width=450,height=150,scrollbars=no,left=100,top=100,\");" ));
    out.print(frm.endForm());

    session.setAttribute("parentLocation", me);

} catch (Exception e) {
    out.print(e);
}
%>