<%@include file="template/pagetop.jsp" %>
<script src="js/clienthint.js"></script>
<script>
    function printReport() {
      window.open('printreport.jsp','print','height=300,width=640,scrollbars=yes,resizable');
    }
</script>
<%@ include file="ajax/ajaxstuff.jsp" %>
<%
// Set up the SQL statement
    String myQuery     = "select a.id as patientid, Lastname, Firstname, " +
                            "ifnull(totalvisits,0) Total, " +
                            "ifnull(yearvisits,0) Year, " +
                            "ifnull(quartervisits,0) Quarter, " +
                            "ifnull(monthvisits,0) Month, " +
                            "ifnull(weekvisits,0) Week, " +
                            "ifnull(planvisits,'NA') Plan " +
                            "from patients a left join " +
                            "(select patientid, count(*) totalvisits from visits group by patientid) b " +
                            "on a.id=b.patientid left join " +
                            "(select patientid, count(*) yearvisits from visits where date > current_date - INTERVAL 1 year " +
                            "group by patientid) c " +
                            "on a.id=c.patientid left join " +
                            "(select patientid, count(*) quartervisits from visits where date > current_date - INTERVAL 3 month " +
                            "group by patientid) d " +
                            "on a.id=d.patientid left join " +
                            "(select patientid, count(*) monthvisits from visits where date > current_date - INTERVAL 1 month " +
                            "group by patientid) e " +
                            "on a.id=e.patientid left join " +
                            "(select patientid, count(*) weekvisits from visits where date > current_date - INTERVAL 1 week " +
                            "group by patientid) f " +
                            "on a.id=f.patientid left join " +
                            "(select a.patientid, count(*) planvisits from patientplan a join visits b on a.patientid=b.patientid " +
                            "where b.date between a.startdate and a.enddate group by a.patientid) g " +
                            "on a.id=g.patientid " +
                            "order by 4 desc, 2,3";

// Create an RWFiltered List object
    RWFilteredList lst = new RWFilteredList(io);

// Set special attributes on the filtered list object
    String [] cw       = {"0", "150", "150", "50", "50", "50", "50", "50", "50"};

    lst.setColumnWidth(cw);
    lst.setTableWidth("650");
    lst.setTableBorder("0");
    lst.setCellPadding("3");
    lst.setColumnAlignment(8, "right");
    lst.setAlternatingRowColors("#ffffff", "#cccccc");
    lst.setUseCatalog(true);
    lst.setDivHeight(400);

    lst.setUrlField(0);
//    lst.setOnClickAction("window.open");
//    lst.setOnClickOption("\"Insurance\",\"width=500,height=200,scrollbars=no,left=100,top=100,\"");
//    lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
//    lst.setColumnUrl(1, "comments_d.jsp?type=7&date=" + Format.formatDate(new java.util.Date(),"yyyy-MM-dd"));
//    lst.setColumnUrl(2, "comments_d.jsp?type=7&date=" + Format.formatDate(new java.util.Date(),"yyyy-MM-dd"));

    lst.setOnClickAction(1, "javascript:enableMouseOut=false;ajaxComplete=false;showItem(event,'comments_d_new.jsp?type=7&date=" + Format.formatDate(new java.util.Date(),"yyyy-MM-dd") + "',0,##idColumn##,txtHint) style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    lst.setOnClickAction(2, "javascript:enableMouseOut=false;ajaxComplete=false;showItem(event,'comments_d_new.jsp?type=7&date=" + Format.formatDate(new java.util.Date(),"yyyy-MM-dd") + "',0,##idColumn##,txtHint) style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
       
    lst.setOnMouseOverAction(1, "showPhoneNumber(event,##idColumn##,txtHint)");
    lst.setOnMouseOverAction(2, "showPhoneNumber(event,##idColumn##,txtHint)");
    lst.setOnMouseOutAction(1, "showHide(txtHint,'HIDE')");
    lst.setOnMouseOutAction(2, "showHide(txtHint,'HIDE')");   

// Show the filtered list
    out.print(lst.getHtml(request, myQuery));

   out.print("<input type=button class=button value=print onClick=printReport()>");
    
    session.setAttribute("reportToPrint", lst);
    session.setAttribute("parentLocation", "None");
%>
<%@ include file="template/pagebottom.jsp" %>