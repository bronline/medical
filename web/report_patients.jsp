<%@include file="template/pagetop.jsp" %>
<script>
    function printReport() {
      window.open('printreport.jsp','print','height=300,width=640,scrollbars=yes,resizable');
    }
</script>
<%@ include file="ajax/ajaxstuff.jsp" %>
<%
// Set up the SQL statement
    String myQuery     = "SELECT p.id as patientid, ifnull(r.name,'*Unassigned') as Provider, p.lastname, p.firstname, middlename, " +
                        "case when preferredcontact=0 then homephone when preferredcontact=1 then workphone when preferredcontact=2 then cellphone end as phonenumber, " +
                        "email, case when Active then 'Yes' else 'No' end as Active " +
                        "FROM patients p " +
                        "left join resources r on r.id=p.resourceid " +
                        "where (p.lastname <> ' ' or p.firstname <> ' ')  order by p.lastname, p.firstname, middlename";
    String title = "PatientsList";

// Create an RWFiltered List object
    RWFilteredList lst = new RWFilteredList(io);

// Set special attributes on the filtered list object
    String [] cw       = {"0", "150", "75", "75", "50", "100", "150", "50"};
    String [] ch       = {"", "Provider", "Last Name", "First Name", "MI", "Contact Phone", "E-mail Address", " Active" };
    lst.setColumnWidth(cw);
    lst.setTableWidth("750");
    lst.setTableBorder("0");
    lst.setCellPadding("3");
    lst.setColumnFormat(5,"(###)-###-####");
    lst.setAlternatingRowColors("#ffffff", "#cccccc");
    lst.setUseCatalog(true);
    lst.setDivHeight(400);

    lst.setUrlField(0);
//    lst.setOnClickAction("window.open");
//    lst.setOnClickOption("\"" + title + "\",\"width=500,height=200,scrollbars=no,left=100,top=100,\"");
//    lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
//    lst.setColumnUrl(2, "comments_d.jsp?type=1&date=" + Format.formatDate(new java.util.Date(),"yyyy-MM-dd"));
//   lst.setColumnUrl(3, "comments_d.jsp?type=1&date=" + Format.formatDate(new java.util.Date(),"yyyy-MM-dd"));
    lst.setOnClickAction(2, "javascript:enableMouseOut=false;ajaxComplete=false;showItem(event,'comments_d_new.jsp?type=1&date=" + Format.formatDate(new java.util.Date(),"yyyy-MM-dd") + "',0,##idColumn##,txtHint) style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    lst.setOnClickAction(3, "javascript:enableMouseOut=false;ajaxComplete=false;showItem(event,'comments_d_new.jsp?type=1&date=" + Format.formatDate(new java.util.Date(),"yyyy-MM-dd") + "',0,##idColumn##,txtHint) style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    lst.setOnMouseOverAction(2, "showPhoneNumber(event,##idColumn##,txtHint)");
    lst.setOnMouseOverAction(3, "showPhoneNumber(event,##idColumn##,txtHint)");
    lst.setOnMouseOutAction(2, "showHide(txtHint,'HIDE')");
    lst.setOnMouseOutAction(3, "showHide(txtHint,'HIDE')");

// Show the filtered list
    out.print(lst.getHtml(request, myQuery, ch));

    out.print("<input type=button class=button value=print onClick=printReport()>");

    session.setAttribute("reportToPrint", lst);
    session.setAttribute("parentLocation", "None");
%>
<%@ include file="template/pagebottom.jsp" %>