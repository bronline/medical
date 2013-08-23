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

   String fromMonth=request.getParameter("fromMonth");
   String toMonth=request.getParameter("toMonth");

   if(fromMonth == null || fromMonth.equals("")) { fromMonth="01"; }
   if(toMonth == null || toMonth.equals("")) { toMonth="01"; }

   String [] months = {"01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12" };

   frm.setShowDatePicker(true);
   htmTb.replaceNewLineChar(false);
   out.print(frm.startForm());
   out.print(htmTb.startTable());
   out.print(htmTb.startRow());
   out.print(htmTb.addCell("<b>From Month</b>", "width=70"));
   out.print(htmTb.addCell(frm.comboBox("fromMonth", months, fromMonth), " width=200"));   out.print(htmTb.addCell("<b>To Month</b>", "width=70"));
   out.print(htmTb.addCell(frm.comboBox("toMonth", months, toMonth), " width=200"));   out.print(htmTb.addCell("<b>To Month</b>", "width=70"));
   out.print(htmTb.addCell(frm.button("view", "class=button onClick=changeReportDate() "), htmTb.LEFT, "width=50"));
//   out.print(htmTb.addCell("", "width=280"));
   out.print(htmTb.endRow());
   out.print(htmTb.endTable());
   out.print(frm.endForm());

   String [] cw = { "0", "130", "130", "130", "130", "130", "50", "50", "100" };
   String [] ch = { "", "Last Name", "First Name", "Address", "City", "State", "Zip", "DOB", "Phone" };
   String myQuery = "select p.id, LastName, FirstName,address, city, state, zipcode, DATE_FORMAT(dob, '%m/%d') as DOB, " +
                    "case when preferredcontact=0 then homephone when preferredcontact=1 then workphone when preferredcontact=2 then cellphone end as phonenumber " +
                    "from patients p " +
                    "where month(dob) between " + request.getParameter("fromMonth") + " and " + request.getParameter("toMonth") + " " +
                    "order by concat(YEAR(CURRENT_DATE), DATE_FORMAT(dob, '-%m-%d'))";

   lst.setAlternatingRowColors("#e0e0e0", "#cccccc");
   lst.setColumnWidth(cw);
   lst.setFormMethod("POST");
   lst.setDivHeight(400);
   lst.setTableWidth("850");
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