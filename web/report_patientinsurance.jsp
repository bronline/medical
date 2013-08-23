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

    String [] cw = { "0", "100", "100", "100", "200","80" };
    String [] ch = { "", "Last Name", "First Name", "Provider Number", "Payer Name", "Active" };
    String myQuery = "SELECT patients.id as patientid, lastname, firstname, insuranceinformation.providernumber, ifnull(ProviderName,'Cash') as PayerName, (case when active then 'Yes' else 'No' end) as ActivePatient " +
                    "FROM patients " +
                    "left join insuranceinformation on patients.id=patientid " +
                    "where lastname<>'' " +
                    "order by lastname, firstname";

    lst.setAlternatingRowColors("#e0e0e0", "#cccccc");
    lst.setColumnWidth(cw);
    lst.setFormMethod("POST");
    lst.setDivHeight(300);
    lst.setTableWidth("600");
    lst.setTableBorder("0");
    lst.setUseCatalog(true);

    lst.setUrlField(0);
    lst.setColumnAlignment(5, "CENTER");
//    lst.setOnClickAction("window.open");
//    lst.setOnClickOption("\"Insurance\",\"width=500,height=200,scrollbars=no,left=100,top=100,\"");
//    lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
//    lst.setColumnUrl(1, "comments_d.jsp?type=2&date=" + Format.formatDate(new java.util.Date(),"yyyy-MM-dd"));
//    lst.setColumnUrl(2, "comments_d.jsp?type=2&date=" + Format.formatDate(new java.util.Date(),"yyyy-MM-dd"));

    lst.setOnMouseOverAction(1, "showPhoneNumber(event,##idColumn##,txtHint)");
    lst.setOnMouseOverAction(2, "showPhoneNumber(event,##idColumn##,txtHint)");

    lst.setOnClickAction(1, "javascript:enableMouseOut=false;ajaxComplete=false;showItem(event,'comments_d_new.jsp?type=2&date=" + Format.formatDate(new java.util.Date(),"yyyy-MM-dd") + "',0,##idColumn##,txtHint) style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    lst.setOnClickAction(2, "javascript:enableMouseOut=false;ajaxComplete=false;showItem(event,'comments_d_new.jsp?type=2&date=" + Format.formatDate(new java.util.Date(),"yyyy-MM-dd") + "',0,##idColumn##,txtHint) style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");

    lst.setOnMouseOutAction(1, "showHide(txtHint,'HIDE')");
    lst.setOnMouseOutAction(2, "showHide(txtHint,'HIDE')");
    out.print(lst.getHtml(request, myQuery, ch));

    out.print("<input type=button class=button value=print onClick=printReport()>");

    session.setAttribute("reportToPrint", lst);
    session.setAttribute("parentLocation", "None");
%>

<%@ include file="template/pagebottom.jsp" %>