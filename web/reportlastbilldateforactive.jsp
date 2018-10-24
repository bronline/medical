<%-- 
    Document   : reportlastbilldateforactive
    Created on : Dec 4, 2017, 8:43:03 AM
    Author     : Randy
--%>

<%@include file="template/pagetop.jsp" %>
<script>
    function printReport() {
      window.open('printreport.jsp','print','height=300,width=790,scrollbars=yes,resizable');
    }
    
    function changeReportDate() {
        frmInput.submit();
    }
</script>
<%
// Set up the SQL statement
    String startDate   = request.getParameter("startDate");
    String runReport   = request.getParameter("execute");
    if(startDate == null) { startDate=Format.formatDate(new java.util.Date(), "yyyy-MM-dd"); }
    
    String myQuery     = "CALL rwcatalog.prGetLastBilledForActive('" + io.getLibraryName() + "', '" + startDate + "')";

// Create an RWFiltered List object
    RWFilteredList lst = new RWFilteredList(io);
    RWHtmlTable htmTb = new RWHtmlTable("800", "0");
    RWHtmlForm frm = new RWHtmlForm("frmInput", self, "POST");
    
    String datePicker = "<image src=\"images/show-calendar.gif\" " +
                     "onClick='var X=event.x; var Y=event.y; " + 
                     "var action=\"datepicker.jsp?formName=frmInput&element=reportDate" + 
                     "&month=" + Format.formatDate(startDate, "MM") + 
                     "&year=" + Format.formatDate(startDate, "yyyy") + 
                     "&day=" + Format.formatDate(startDate, "dd") + "\"; " +
                     "var options=\"width=190,height=111,left=\" + X + \",top=\" + Y + \",\"; " +
                     "window.open(action, \"Date\", options);' " +
                     "style=\"cursor: pointer;\">";    

    frm.setShowDatePicker(true);
    htmTb.replaceNewLineChar(false);
    out.print(frm.startForm());
    out.print(frm.hidden("Y", "execute", ""));
    out.print(htmTb.startTable());
    out.print(htmTb.startRow());
    out.print(htmTb.addCell("<b>Last Bill Date</b>", "width=70"));
    out.print(htmTb.addCell(frm.date(startDate, "startDate", "class=tBoxText"), " width=200"));
    out.print(htmTb.addCell(frm.button("view", "class=button onClick=changeReportDate() "), htmTb.LEFT, "width=50"));
    out.print(htmTb.endRow());
    out.print(htmTb.endTable());
    out.print(frm.endForm());    

// Set special attributes on the filtered list object
    String [] cw       = {"0", "200", "100", "100", "100"};
    String [] ch       = { "", "Patient Name", "Charges", "Total Unbilled", "Last Billed" };

    lst.setColumnWidth(cw);
    lst.setTableWidth("500");
    lst.setTableBorder("0");
    lst.setCellPadding("3");
    lst.setColumnFormat(3, "MONEY");
    lst.setColumnFormat(4, "DATE");
    lst.setAlternatingRowColors("#ffffff", "#cccccc");
    lst.setColumnFilterState(1, false);
    lst.setColumnFilterState(2, false);
    lst.setColumnFilterState(3, false);
    lst.setColumnFilterState(4, false);
    lst.setUseCatalog(true);
    lst.setDivHeight(400);

// Show the filtered list
    if(runReport != null) {
        out.print(lst.getHtml(request, myQuery, ch));
        out.print("<input type=button class=button value=print onClick=printReport()>");
    }
    
    session.setAttribute("reportToPrint", lst);
%>
<%@ include file="template/pagebottom.jsp" %>
