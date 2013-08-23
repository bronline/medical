<%-- 
    Document   : report_average_payer_charges
    Created on : May 19, 2009, 7:07:52 PM
    Author     : Randy
--%>

<%@include file="template/pagetop.jsp" %>
<script>
    function printReport() {
      window.open('printreport.jsp','print','height=300,width=640,scrollbars=yes,resizable');
    }
    function changeReportDate() {
        frmInput.submit();
    }
</script>
<%@ include file="ajax/ajaxstuff.jsp" %>
<%
   RWHtmlTable htmTb = new RWHtmlTable("600", "0");
   RWHtmlForm frm = new RWHtmlForm("frmInput", self, "POST");

   String reportDate=request.getParameter("reportDate");
   String reportToDate=request.getParameter("reportToDate");

   if(reportDate == null || reportDate.equals("")) { reportDate=Format.formatDate(new java.util.Date(), "yyyy-MM-dd"); }
   if(reportToDate == null || reportToDate.equals("")) { reportToDate=Format.formatDate(new java.util.Date(), "yyyy-MM-dd"); }

  String datePicker = "<image src=\"images/show-calendar.gif\" " +
                     "onClick='var X=event.x; var Y=event.y; " +
                     "var action=\"datepicker.jsp?formName=frmInput&element=reportDate" +
                     "&month=" + Format.formatDate(reportDate, "MM") +
                     "&year=" + Format.formatDate(reportDate, "yyyy") +
                     "&day=" + Format.formatDate(reportDate, "dd") + "\"; " +
                     "var options=\"width=190,height=111,left=\" + X + \",top=\" + Y + \",\"; " +
                     "window.open(action, \"Date\", options);' " +
                     "style=\"cursor: hand;\">";

  String dateToPicker = "<image src=\"images/show-calendar.gif\" " +
                     "onClick='var X=event.x; var Y=event.y; " +
                     "var action=\"datepicker.jsp?formName=frmInput&element=reportToDate" +
                     "&month=" + Format.formatDate(reportToDate, "MM") +
                     "&year=" + Format.formatDate(reportToDate, "yyyy") +
                     "&day=" + Format.formatDate(reportToDate, "dd") + "\"; " +
                     "var options=\"width=190,height=111,left=\" + X + \",top=\" + Y + \",\"; " +
                     "window.open(action, \"Date\", options);' " +
                     "style=\"cursor: hand;\">";

   frm.setShowDatePicker(true);
   htmTb.replaceNewLineChar(false);
   out.print(frm.startForm());
   out.print(htmTb.startTable());
   out.print(htmTb.startRow());
   out.print(htmTb.addCell("<b>From Date</b>", "width=70"));
   out.print(htmTb.addCell(frm.date(Format.formatDate(reportDate, "MM/dd/yyyy"), "reportDate", "class=tBoxText") + datePicker, " width=200"));
//   out.print(htmTb.addCell(frm.button("view", "class=button onClick=changeReportDate() "), htmTb.LEFT, "width=50"));
   out.print(htmTb.addCell("<b>To Date</b>", "width=70"));
   out.print(htmTb.addCell(frm.date(Format.formatDate(reportToDate, "MM/dd/yyyy"), "reportToDate", "class=tBoxText") + dateToPicker, " width=200"));
   out.print(htmTb.addCell(frm.button("view", "class=button onClick=changeReportDate() "), htmTb.LEFT, "width=50"));
//   out.print(htmTb.addCell("", "width=280"));
   out.print(htmTb.endRow());
   out.print(htmTb.endTable());
   out.print(frm.endForm());
    
    String myQuery     = "select providerid, ifnull(p.name,'Cash') name, SUM(charges)/sum(visits) charges, " +
                         "SUM(insurance)/SUM(visits) insurance, SUM(patient)/SUM(visits) cash, SUM(writeoff)/SUM(visits) writeoff " +
                         "from chargesbypayer c " +
                         "left join providers p on p.id=c.providerid " +
                         "where date between '" +  Format.formatDate(reportDate, "yyyy/MM/dd") + "' and '" + Format.formatDate(reportToDate, "yyyy/MM/dd") + "' " +
                         " group by providerid, ifnull(p.name,'Cash') " +
                         "order by p.name";
    
    String title = "ProviderCharges";

// Create an RWFiltered List object
    RWFilteredList lst = new RWFilteredList(io);

// Set special attributes on the filtered list object
    String [] cw       = {"0", "300", "100", "100", "100", "100"};
    String [] ch       = {"", "Payer", "Average<br/>Charges<br/>Per Visit", "Average<br/>Payment<br/>Per Visit", "Average<br/>Cash<br/>Per Visit", "Average<br/>Write-Off<br/>Per Visit" };

    lst.setColumnWidth(cw);
    lst.setColumnFilterState(0, false);
    lst.setTableWidth("600");
    lst.setTableBorder("0");
    lst.setCellPadding("3");
    lst.setColumnFormat(2, "MONEY");
    lst.setColumnFormat(3, "MONEY");
    lst.setColumnFormat(4, "MONEY");
    lst.setColumnFormat(5, "MONEY");
    lst.setAlternatingRowColors("#ffffff", "#cccccc");
    lst.setUseCatalog(true);
    lst.setDivHeight(400);
    
// Show the filtered list
    out.print(lst.getHtml(request, myQuery, ch));

    session.setAttribute("reportToPrint", lst);
    session.setAttribute("parentLocation", "None");
%>
<%@ include file="template/pagebottom.jsp" %>