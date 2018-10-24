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

   String [] cw = { "0", "130", "130", "130", "130", "130", "50", "50", "150" };
   String [] ch = { "", "Last Name", "First Name", "Address", "City", "State", "Zip", "DOB" };
   String myQuery = "select p.id, LastName, FirstName,address, city, state, zipcode, DATE_FORMAT(dob, '%m/%d/%y') as DOB, email " +
                    "from patients p " +
                    "order by lastname, firstname, dob";

   lst.setAlternatingRowColors("#e0e0e0", "#cccccc");
   lst.setColumnWidth(cw);
   lst.setFormMethod("POST");
   lst.setDivHeight(400);
   lst.setTableWidth("900");
   lst.setTableBorder("0");
   lst.setUseCatalog(true);
   out.print(lst.getHtml(request, myQuery));

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
