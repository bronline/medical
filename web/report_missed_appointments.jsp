<%@include file="template/pagetop.jsp" %>
<%@ page import="java.text.*" %>
<script>
    function printReport() {
      window.open('printreport.jsp','print','height=300,width=640,scrollbars=yes,resizable');
    }
</script>
<%@ include file="ajax/ajaxstuff.jsp" %>
<%
   RWInputForm frm = new RWInputForm();
   SimpleDateFormat mdyFormat = new SimpleDateFormat("MM/dd/yyyy");
   frm.setShowDatePicker(true);
   String title = "MissedAppointments";

   String startDate = request.getParameter("startdate");
   
   if (startDate == null) {
       Calendar startCal = Calendar.getInstance();
       startCal.add(Calendar.MONTH, -1);
       startDate = mdyFormat.format(startCal.getTime());
   }

// Date selector
   out.print(frm.startForm());
   out.print("<table><tr>");
   out.print("<td>Since</td><td>" + frm.date(tools.utils.Format.formatDate(startDate, "MM/dd/yyyy"), "startdate", "class=tBoxText") + "</td>");
   out.print("<td>" + frm.submitButton("go", "class=button") + "</td>");
   out.print("</tr></table>");
   out.print(frm.endForm());

// Set up the SQL statement
    startDate=tools.utils.Format.formatDate(startDate, "yyyy-MM-dd");
    String myQuery     = "select a.id as patientid, ifnull(r.name,'*Unassigned') as Provider, a.LastName, a.FirstName, b.date as Date, c.type as Type from patients a left join resources r on r.id=a.resourceid join appointmentsmissed b on a.id=b.patientid join appointmenttypes c on b.type=c.id where date >= '" + startDate + "' order by 2,3,4,5";

// Create an RWFiltered List object
    RWFilteredList lst = new RWFilteredList(io);

// Set special attributes on the filtered list object
    String [] cw       = {"0", "100", "100", "100", "100", "100"};

    lst.setColumnWidth(cw);
    lst.setTableWidth("600");
    lst.setTableBorder("0");
    lst.setCellPadding("3");
    lst.setAlternatingRowColors("#ffffff", "#cccccc");
    lst.setUseCatalog(true);
    lst.setDivHeight(400);
    lst.setUrlField(0);
//    lst.setOnClickAction("window.open");
//    lst.setOnClickOption("\"" + title + "\",\"width=500,height=200,scrollbars=no,left=100,top=100,\"");
//    lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
//    lst.setColumnUrl(2, "comments_d.jsp?type=5&date=" + tools.utils.Format.formatDate(new java.util.Date(),"yyyy-MM-dd"));
//    lst.setColumnUrl(3, "comments_d.jsp?type=5&date=" + tools.utils.Format.formatDate(new java.util.Date(),"yyyy-MM-dd"));
    
    lst.setOnClickAction(2, "javascript:enableMouseOut=false;ajaxComplete=false;showItem(event,'comments_d_new.jsp?type=5&date=" + tools.utils.Format.formatDate(new java.util.Date(),"yyyy-MM-dd") + "',0,##idColumn##,txtHint) style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    lst.setOnClickAction(3, "javascript:enableMouseOut=false;ajaxComplete=false;showItem(event,'comments_d_new.jsp?type=5&date=" + tools.utils.Format.formatDate(new java.util.Date(),"yyyy-MM-dd") + "',0,##idColumn##,txtHint) style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    
    lst.setOnMouseOverAction(2, "showPhoneNumber(event,##idColumn##,txtHint)");
    lst.setOnMouseOverAction(3, "showPhoneNumber(event,##idColumn##,txtHint)");
    lst.setOnMouseOutAction(2, "showHide(txtHint,'HIDE')");
    lst.setOnMouseOutAction(3, "showHide(txtHint,'HIDE')");

// Show the filtered list
    out.print(lst.getHtml(request, myQuery));

   out.print("<input type=button class=button value=print onClick=printReport()>");
    
    session.setAttribute("reportToPrint", lst);
    session.setAttribute("parentLocation", "None");
%>
<%@ include file="template/pagebottom.jsp" %>