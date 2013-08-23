<%@include file="template/pagetop.jsp" %>

<%@include file="template/FormSubmit.js" %>

<%
// If the user is authorized, show the filtered list
if(request.isUserInRole("codeList")) {
    // Try to generate a list of Groups
    try {
    // Create an RWFiltered List object to show the Groups
        RWFilteredList lst = new RWFilteredList(io);
        RWHtmlForm frm     = new RWHtmlForm();

    // Create an array with the column headings
        String [] columnHeadings = { "ID", "Group Name" };

    // Set special attributes on the filtered list object
        lst.setTableBorder("0");
        lst.setUrlField(0);
        lst.setNumberOfColumnsForUrl(2);
        lst.setRowUrl("groups_d.jsp");
    //  If the user is authorized to maintainance
        if(request.isUserInRole("codeMaint")) { lst.setShowRowUrl(true); }
        lst.setShowComboBoxes(false);
        lst.setShowColumnHeadings(false);

    // Show the list of groups
        out.print(lst.getHtml(request, "select id, groupname from groupnames", columnHeadings));

    // Show the add new group button
        out.print(frm.button("add new group", "onClick=submitForm('groups_d.jsp?id=0') class=button"));

    } catch (Exception e) {
        out.print(e);
    }
} else {
    out.print("<h1>You are not authorized to this function</h1>");
}
%>

<%@include file="template/pagebottom.jsp" %>