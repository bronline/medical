<%-- 
    Document   : report_openbalances
    Created on : Jan 16, 2008, 9:24:18 AM
    Author     : Randy
--%>

<%@include file="template/pagetop.jsp" %>
<script>
    function printReport() {
      window.open('printreport.jsp','print','height=300,width=640,scrollbars=yes,resizable');
    }
</script>
<%
// Set up the SQL statement
    String myQuery     = "select patientid, concat(lastname,', ',firstname) as name, " +
                         "sum(balance) as balance " +
                         "from patientbalance " +
                         "join patients on patients.id=patientbalance.patientid " +
                         "group by patientid, concat(lastname,', ',firstname) " +
                         "order by sum(balance) desc";

// Create an RWFiltered List object
    RWFilteredList lst = new RWFilteredList(io);

// Set special attributes on the filtered list object
    String [] cw       = {"0", "250", "150"};
    String [] ch       = { "", "Patient Name", "Balance" };

    lst.setColumnWidth(cw);
    lst.setTableWidth("600");
    lst.setTableBorder("0");
    lst.setCellPadding("3");
    lst.setColumnFormat(2, "MONEY");
    lst.setAlternatingRowColors("#ffffff", "#cccccc");
    lst.setColumnFilterState(1, false);
    lst.setColumnFilterState(2, false);
    lst.setUseCatalog(true);
    lst.setDivHeight(400);

// Show the filtered list
    out.print(lst.getHtml(request, myQuery, ch));

   out.print("<input type=button class=button value=print onClick=printReport()>");
    
    session.setAttribute("reportToPrint", lst);
%>
<%@ include file="template/pagebottom.jsp" %>