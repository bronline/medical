<%--
    Document   : report_visits_without_charges
    Created on : Mar 9, 2010, 5:21:12 PM
    Author     : Randy
--%>
<%@page contentType="text/html" pageEncoding="windows-1252"%>
<%@include file="template/pagetop.jsp" %>
<script>
    function printReport() {
      window.open('printreport.jsp?contentType=EXCEL','print','height=300,width=790,menubar=yes,scrollbars=yes,resizable');
    }

    function changeReportDate() {
        frmInput.submit();
    }
</script>
<%
   RWFilteredList lst = new RWFilteredList(io);
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

   String [] cw = { "0", "100", "130", "130", "130", "130", "50", "50", "75", "75", "75", "150" };
   String [] ch = { "", "Visit Date", "Last Name", "First Name", "Address", "City", "State", "Zip", "Home Phone", "Cell Phone", "Work Phone", "E-Mail" };

   String myQuery = "SELECT patients.id, b.date, lastname, firstname " +
           "FROM patients " +
           "left join visits b on patients.id=b.patientid " +
           "left join charges c on c.visitid=b.id " +
           "where b.date between '" +  Format.formatDate(reportDate, "yyyy/MM/dd") + "' and '" + Format.formatDate(reportToDate, "yyyy/MM/dd") + "' " +
           "group by patients.id, b.date, lastname, firstname " +
           "having IfNull(sum(chargeamount),0)=0";

   lst.setAlternatingRowColors("#e0e0e0", "#cccccc");
   lst.setColumnWidth(cw);
   lst.setFormMethod("POST");
   lst.setDivHeight(400);
   lst.setTableWidth("600");
   lst.setTableBorder("0");
   lst.setUseCatalog(true);
   out.print(lst.getHtml(request, myQuery, ch));

   out.print("<input type=button class=button value='send to Excel' onClick=printReport()>");

   session.setAttribute("reportToPrint", lst);
%>
<script language="javascript">
  function formSubmit() {
    var frmA=document.forms["formFilter"]
    var reportDate = document.createElement('input');
    reportDate.name='reportDate'
    reportDate.value=frmInput.reportDate.value
    frmA.appendChild(reportDate)
    var reportToDate = document.createElement('input');
    reportToDate.name='reportToDate'
    reportToDate.value=frmInput.reportToDate.value
    frmA.appendChild(reportToDate)
    frmA.action=""
    frmA.method="POST"
    frmA.submit()
  }
</script>
<%@ include file="template/pagebottom.jsp" %>