<%@include file="template/pagetop.jsp" %>
<script>
    function printReport() {
      window.open('printreport.jsp','print','height=300,width=640,scrollbars=yes,resizable');
    }
</script>
<%@ include file="ajax/ajaxstuff.jsp" %>
<%
// Set up the SQL statement
    String myQuery     = "SELECT a.id as patientid, LastName, FirstName, DATE_FORMAT(LastAppt,'%c/%m/%Y') as lastappt, DATE_FORMAT(lastvisit,'%c/%m/%Y') aslastvisit, " +
                        "case when preferredcontact=0 then homephone when preferredcontact=1 then workphone when preferredcontact=2 then cellphone end as phonenumber, " +
                        "a.email AS Email, " +
                        "case when Active then 'Yes' else 'No' end as Active FROM " +
                        "patients a " +
                        "left join (select patientid, max(date) lastappt from appointments group by patientid) b on a.id=b.patientid " +
                        "left join (select patientid, max(date) lastvisit from visits group by patientid) c on a.id=c.patientid " +
                        "join environment " +
                        "where (lastappt <= current_date and lastvisit >= Date_Add(current_date, interval (recallvisitdays*-1) day)) " +
                        "and (lastname <> ' ' or firstname <> ' ')  order by lastname, firstname, middlename";

// Create an RWFiltered List object
    RWFilteredList lst = new RWFilteredList(io);
    String title="RecallList";

// Set special attributes on the filtered list object
    String [] cw       = {"0", "100", "100", "75", "75", "100", "200", "75"};
    String [] ch       = {"", "Last Name", "First Name", "Last Appt", "Last Visit", "Contact Phone", "Email", "Active" };

    lst.setColumnWidth(cw);
    lst.setTableWidth("800");
    lst.setTableBorder("0");
    lst.setCellPadding("3");
    lst.setColumnFormat(5,"(###)-###-####");
    lst.setAlternatingRowColors("#ffffff", "#cccccc");
    lst.setUseCatalog(true);
    lst.setDivHeight(400);

    lst.setUrlField(0);

    
    lst.setOnClickAction(1, "javascript:enableMouseOut=false;ajaxComplete=false;showItem(event,'comments_d_new.jsp?type=4&date=" + Format.formatDate(new java.util.Date(),"yyyy-MM-dd") + "',0,##idColumn##,txtHint) style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    lst.setOnClickAction(2, "javascript:enableMouseOut=false;ajaxComplete=false;showItem(event,'comments_d_new.jsp?type=4&date=" + Format.formatDate(new java.util.Date(),"yyyy-MM-dd") + "',0,##idColumn##,txtHint) style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    
    lst.setOnMouseOverAction(1, "showPhoneNumber(event,##idColumn##,txtHint)");
    lst.setOnMouseOverAction(2, "showPhoneNumber(event,##idColumn##,txtHint)");
    lst.setOnMouseOutAction(1, "showHide(txtHint,'HIDE')");
    lst.setOnMouseOutAction(2, "showHide(txtHint,'HIDE')");
       
// Show the filtered list
    out.print(lst.getHtml(request, myQuery, ch));

   out.print("<input type=button class=button value=print onClick=printReport()>");
    
    session.setAttribute("reportToPrint", lst);
    session.setAttribute("parentLocation", "None");
%>
<%@ include file="template/pagebottom.jsp" %>