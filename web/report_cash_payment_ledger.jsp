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
   RWFilteredList lst = new RWFilteredList(io);
   RWHtmlTable htmTb = new RWHtmlTable("800", "0");
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
                     "style=\"cursor: pointer;\">";

  String dateToPicker = "<image src=\"images/show-calendar.gif\" " +
                     "onClick='var X=event.x; var Y=event.y; " +
                     "var action=\"datepicker.jsp?formName=frmInput&element=reportToDate" +
                     "&month=" + Format.formatDate(reportToDate, "MM") +
                     "&year=" + Format.formatDate(reportToDate, "yyyy") +
                     "&day=" + Format.formatDate(reportToDate, "dd") + "\"; " +
                     "var options=\"width=190,height=111,left=\" + X + \",top=\" + Y + \",\"; " +
                     "window.open(action, \"Date\", options);' " +
                     "style=\"cursor: pointer;\">";

   frm.setShowDatePicker(true);
   htmTb.replaceNewLineChar(false);
   out.print(frm.startForm());
   out.print(htmTb.startTable());
   out.print(htmTb.startRow());
   out.print(htmTb.addCell("<b>From Date</b>", "width=70"));
   out.print(htmTb.addCell(frm.date(Format.formatDate(reportDate, "MM/dd/yyyy"), "reportDate", "class=tBoxText") + datePicker, " width=200"));
   out.print(htmTb.addCell("<b>To Date</b>", "width=70"));
   out.print(htmTb.addCell(frm.date(Format.formatDate(reportToDate, "MM/dd/yyyy"), "reportToDate", "class=tBoxText") + dateToPicker, " width=200"));
   out.print(htmTb.addCell(frm.button("view", "class=button onClick=changeReportDate() "), htmTb.LEFT, "width=50"));
   out.print(htmTb.endRow());
   out.print(htmTb.endTable());
   out.print(frm.endForm());

// Set up the SQL statement
    String myQuery     = "SELECT pm.id, pm.`date`, IfNull(py.name,'Cash') as name, concat(pt.lastname,', ',pt.firstname) as patientname, " +
                         "pm.checknumber, pm.originalamount " +
                         "FROM payments pm " +
                         "LEFT JOIN patients pt ON pm.patientid=pt.id " +
                         "LEFT JOIN providers py ON pm.provider=py.id " +
                         "WHERE pm.`date` BETWEEN '" + Format.formatDate(reportDate,"yyyy-MM-dd") + "' AND '" + Format.formatDate(reportToDate,"yyyy-MM-dd") + "' " +
                         "AND py.Name<>'Write Off' " +
                         "AND py.reserved " +
                         "AND pm.parentpayment=0 " +
                         "AND NOT py.isadjustment " +
                         "OR (pm.provider=0 AND pm.`date` BETWEEN '" + Format.formatDate(reportDate,"yyyy-MM-dd") + "' AND '" + Format.formatDate(reportToDate,"yyyy-MM-dd") + "' AND pm.parentpayment=0) " +
                         "ORDER BY py.name, pt.lastname, pt.firstname";

    String title = "CashPaymentLedger";

// Set special attributes on the filtered list object
    String [] cw       = {"0", "100", "100", "250", "100", "100", "100", "50"};
    String [] ch       = {"", "Date", "Source", "Patient Name", "Check #", "Amount", " Active" };
    lst.setColumnWidth(cw);
    lst.setTableWidth("750");
    lst.setTableBorder("0");
    lst.setCellPadding("3");
    lst.setAlternatingRowColors("#ffffff", "#cccccc");
    lst.setUseCatalog(true);
    lst.setDivHeight(400);
    lst.setColumnFormat(5, "MONEY");
    lst.setSummaryColunn(5);

// Show the filtered list
    out.print(lst.getHtml(request, myQuery, ch));

    out.print("<input type=button class=button value=print onClick=printReport()>");

    session.setAttribute("reportToPrint", lst);
    session.setAttribute("parentLocation", "None");
%>
<%@ include file="template/pagebottom.jsp" %>