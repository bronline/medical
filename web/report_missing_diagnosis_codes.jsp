<%-- 
    Document   : report_missing_diagnosis_codes
    Created on : Jul 23, 2010, 7:21:58 AM
    Author     : rwandell
--%>

<%@include file="template/pagetop.jsp" %>
<script src="js/clienthint.js"></script>
<script>
    function printReport() {
      window.open('printreport.jsp','print','height=300,width=640,scrollbars=yes,resizable');
    }
</script>
<%@ include file="ajax/ajaxstuff.jsp" %>
<%
    RWFilteredList lst = new RWFilteredList(io);

    String [] cw = { "0", "100", "100", "100", "100","100" };
    String [] ch = { "", "Last Name", "First Name", "Condition", "Start Date", "End Date" };
    String myQuery = "select c.id, p.lastname, p.firstname, c.description, " +
                     "case when fromdate='0000-00-00' then '' else c.fromdate end as fromdate, " +
                     "case when todate='0000-00-00' then '' else c.todate end as todate " +
                     "from patientconditions c " +
                     "left join patients p on p.id=c.patientid " +
                     "left join patientsymptoms s on s.conditionid=c.id " +
                     "left join patientinsurance i on i.patientid=c.patientid and i.primaryprovider=1 " +
                     "WHERE s.id IS NULL AND i.id IS NOT NULL " +
                     "order by p.lastname, p.firstname";

    lst.setAlternatingRowColors("#e0e0e0", "#cccccc");
    lst.setColumnWidth(cw);
    lst.setFormMethod("POST");
    lst.setDivHeight(300);
    lst.setTableWidth("600");
    lst.setTableBorder("0");
    lst.setUseCatalog(true);

//    lst.setUrlField(0);
    lst.setColumnAlignment(4, "CENTER");
    lst.setColumnAlignment(5, "CENTER");

//    lst.setOnMouseOverAction(1, "showPhoneNumber(event,##idColumn##,txtHint)");
//    lst.setOnMouseOverAction(2, "showPhoneNumber(event,##idColumn##,txtHint)");

//    lst.setOnClickAction(1, "javascript:enableMouseOut=false;ajaxComplete=false;showItem(event,'comments_d_new.jsp?type=2&date=" + Format.formatDate(new java.util.Date(),"yyyy-MM-dd") + "',0,##idColumn##,txtHint) style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
//    lst.setOnClickAction(2, "javascript:enableMouseOut=false;ajaxComplete=false;showItem(event,'comments_d_new.jsp?type=2&date=" + Format.formatDate(new java.util.Date(),"yyyy-MM-dd") + "',0,##idColumn##,txtHint) style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");

//    lst.setOnMouseOutAction(1, "showHide(txtHint,'HIDE')");
//    lst.setOnMouseOutAction(2, "showHide(txtHint,'HIDE')");
    out.print(lst.getHtml(request, myQuery, ch));

    out.print("<input type=button class=button value=print onClick=printReport()>");

    session.setAttribute("reportToPrint", lst);
    session.setAttribute("parentLocation", "None");
%>

<%@ include file="template/pagebottom.jsp" %>
