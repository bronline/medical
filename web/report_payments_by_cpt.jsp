<%-- 
    Document   : report_payments_by_cpt
    Created on : Jun 8, 2012, 9:14:07 AM
    Author     : Randy
--%>

<%@include file="template/pagetop.jsp" %>
<script>
    function sendToExcel() {
      window.open('printreport.jsp?contentType=EXCEL','print','height=300,width=790,menubar=yes,scrollbars=yes,resizable');
    }

    function printReport(fromDate,toDate,cptCode,providerId) {
      window.open('print_report_payments_by_cpt.jsp?reportDate='+fromDate+'&reportToDate='+toDate+'&cptCode='+cptCode+'&providerId='+providerId,'print','height=300,width=790,menubar=yes,scrollbars=yes,resizable');
    }

    function changeReportDate() {
        frmInput.submit();
    }
</script>
<%
   RWHtmlTable htmTb = new RWHtmlTable("600", "0");
   RWHtmlForm frm = new RWHtmlForm("frmInput", self, "POST");

   String reportDate=request.getParameter("reportDate");
   String reportToDate=request.getParameter("reportToDate");

   boolean showDetail=false;
   double chargeTotal=0.0;
   double gtPayments=0.0;
   double gtCharges=0.0;
   String providerId="0";
   String cptCode = "";

   if(reportDate == null || reportDate.equals("")) { reportDate=Format.formatDate(new java.util.Date(), "yyyy-MM-dd"); }
   if(reportToDate == null || reportToDate.equals("")) { reportToDate=Format.formatDate(new java.util.Date(), "yyyy-MM-dd"); }
   if(request.getParameter("chkBox1_cb") != null) { showDetail=true; }
   if(request.getParameter("providerId") != null) { providerId=request.getParameter("providerId"); }
   if(request.getParameter("cptCode") != null) { cptCode=request.getParameter("cptCode"); }

   ResultSet cptRs = io.opnRS("select '--None--' as cptCode, '-- Select --' as `procedure` union select * from (select code as cptCode, concat(code, ' - ',description) as `procedure` from items where billinsurance order by code) f");

  ResultSet providerRs=io.opnRS("select 0 as providerid, '*ALL' as name union select id as providerid, name from resources order by name");

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
   out.print(htmTb.startTable("800"));
   out.print(htmTb.startRow());
   out.print(htmTb.addCell("<b>From Date</b>", "width=70"));
   out.print(htmTb.addCell(frm.date(Format.formatDate(reportDate, "MM/dd/yyyy"), "reportDate", "class=tBoxText") + datePicker, " width=150"));
   out.print(htmTb.addCell("<b>To Date</b>", "width=70"));
   out.print(htmTb.addCell(frm.date(Format.formatDate(reportToDate, "MM/dd/yyyy"), "reportToDate", "class=tBoxText") + dateToPicker, " width=150"));
   out.print(htmTb.addCell("<b>CPT Code</b>","width=75"));
   out.print(htmTb.addCell(frm.comboBox(cptRs, "cptCode", "cptCode", false, "1", null, cptCode, "class=cBoxText"), "width=100"));
   out.print(htmTb.addCell("<b>Provider</b>","width=75"));
   out.print(htmTb.addCell(frm.comboBox(providerRs, "providerId", "providerId", false, "1", null, providerId, "class=cBoxText"),"width=\"120\"" ));
   out.print(htmTb.addCell(frm.button("view", "class=button onClick=changeReportDate() "), htmTb.LEFT, "width=50"));
   out.print(htmTb.endRow());
   out.print(htmTb.endTable());
   out.print(frm.endForm());

   String myQuery = "select pr.name, concat(i.code, ' - ',i.description) as `procedure`, sum(c.chargeamount*c.quantity) as charges, sum(p.amount) as payments " +
           "from visits v " +
           "left join charges c on c.visitid=v.id " +
           "left join items i on i.id=c.itemid " +
           "left join payments p on p.chargeid=c.id " +
           "left join providers pr on p.provider=pr.id " +
           "where " +
           "not pr.reserved " +
           "and not pr.isadjustment " +
           "and p.provider<>0 " +
           "and v.`date` between '" + Format.formatDate(reportDate, "yyyy-MM-dd") + "' and '" + Format.formatDate(reportToDate, "yyyy-MM-dd") + "' ";


   String chargeQuery = "select DATE_FORMAT(v.`date`,'%m/%d/%y') as dos, concat(pt.firstname,' ',pt.lastname) as name, concat(i.code, ' - ', i.description) as item, c.chargeamount*c.quantity as charge, p.amount " +
                     "from payments p " +
                     "left join charges c on c.id=p.chargeid " +
                     "left join items i on i.id=c.itemid " +
                     "left join visits v on v.id=c.visitid " +
                     "left join patients pt on pt.id=p.patientid " +
                     "where p.provider=? and p.`date`=? and p.checknumber=?";

   if(providerId != null && !providerId.equals("0")) { myQuery += "and chargeid in (select id from charges where visitid in (select id from visits where resourceid=" + providerId + ")) "; }
   if(cptCode != null && !cptCode.equals("--None--")) { myQuery += "and i.code='" + cptCode + "' "; }
   myQuery += "group by i.code, pr.name order by pr.name, i.code";

   ResultSet pmtRs=io.opnRS(myQuery);
   PreparedStatement pmtPs=io.getConnection().prepareStatement(chargeQuery);

   out.print("<div align=\"center\" style=\"width: 620px; height: 310px;\">\n");
   out.print("<div align=\"left\">\n");
   out.print(htmTb.startTable("600"));
   out.print(htmTb.startRow());
   out.print(htmTb.headingCell("Payer",htmTb.CENTER,"width=200"));
   out.print(htmTb.headingCell("Procedure",htmTb.CENTER,"width=250"));
   out.print(htmTb.headingCell("Charges",htmTb.RIGHT,"width=75"));
   out.print(htmTb.headingCell("Payments",htmTb.RIGHT,"width=75"));
   out.print(htmTb.endRow());
   out.print(htmTb.endTable());
   out.print("</div>\n");

   out.print("<div align=\"left\" style=\"height: 300px; width: 620px; overflow: auto;\">\n");

   out.print(htmTb.startTable("600"));
   while(pmtRs.next()) {
       out.print(htmTb.startRow("style=\"background-color: #cccccc;\""));
       out.print(htmTb.addCell(pmtRs.getString("name"),htmTb.LEFT,"width=200"));
       out.print(htmTb.addCell(pmtRs.getString("procedure"),htmTb.LEFT,"width=250"));
       out.print(htmTb.addCell(Format.formatCurrency(pmtRs.getString("charges")),htmTb.RIGHT,"width=75"));
       if(showDetail) {
           out.print(htmTb.addCell("","width=75"));
       } else {
           out.print(htmTb.addCell(Format.formatCurrency(pmtRs.getDouble("payments")),htmTb.RIGHT,"width=75"));
       }
       out.print(htmTb.endRow());
/*
       if(showDetail) {
           pmtPs.setInt(1, pmtRs.getInt("providerid"));
           pmtPs.setString(2, Format.formatDate(pmtRs.getString("checkdate"), "yyyy-MM-dd"));
           pmtPs.setString(3, pmtRs.getString("checknumber"));

           chargeTotal=0.0;

           ResultSet chgRs=pmtPs.executeQuery();

           out.print(htmTb.startRow("style=\"background-color: #e0e0e0;\""));
           out.print(htmTb.startCell("colspan=4"));
           out.print(htmTb.startTable("600"));
           while(chgRs.next()) {
               out.print(htmTb.startRow());
               out.print(htmTb.addCell(chgRs.getString("dos"),htmTb.CENTER,"width=75"));
               out.print(htmTb.addCell(chgRs.getString("name"),"width=125"));
               out.print(htmTb.addCell(chgRs.getString("item"),"width=200"));
               out.print(htmTb.addCell(Format.formatCurrency(chgRs.getDouble("charge")),htmTb.RIGHT,"width=100"));
               out.print(htmTb.addCell(Format.formatCurrency(chgRs.getDouble("amount")),htmTb.RIGHT,"width=100"));
               out.print(htmTb.endCell());

               chargeTotal+=chgRs.getDouble("charge");
               gtCharges+=chgRs.getDouble("charge");
           }

           out.print(htmTb.startRow("style=\"background-color: #e0e0e0;\""));
           out.print(htmTb.addCell("","colspan=2"));
           out.print(htmTb.addCell("<b>Totals</b>",htmTb.RIGHT,"width=100"));
           out.print(htmTb.addCell("<b>"+Format.formatCurrency(chargeTotal)+"</b>",htmTb.RIGHT,"style=\"border-top: 1px solid black;\" width=100"));
           out.print(htmTb.addCell("<b>"+Format.formatCurrency(pmtRs.getDouble("amount"))+"</b>",htmTb.RIGHT,"style=\"border-top: 1px solid black;\" width=100"));
           out.print(htmTb.endRow());

           out.print(htmTb.endTable());
           out.print(htmTb.endCell());
           out.print(htmTb.endRow());
           chgRs.close();
           chgRs=null;

           out.print(htmTb.startRow("style=\"background-color: #e0e0e0; height: 15;\""));
           out.print(htmTb.addCell("", "colspan=4"));
           out.print(htmTb.endRow());
       }
*/
       gtPayments+=pmtRs.getDouble("payments");
       gtCharges+=pmtRs.getDouble("charges");
   }
   out.print(htmTb.endTable());

   out.print("</div>\n");

   out.print("<div align=\"left\">\n");
   out.print(htmTb.startTable("600"));
   out.print(htmTb.startRow("style=\"background-color: #ffffff;\""));
   if(showDetail) {
       out.print(htmTb.addCell("","width=75"));
       out.print(htmTb.addCell("","width=125"));
       out.print(htmTb.addCell("<b>Grand Totals</b>",htmTb.RIGHT,"width=200"));
       out.print(htmTb.addCell("<b>"+Format.formatCurrency(gtCharges)+"</b>",htmTb.RIGHT,"style=\"border-top: 1px solid black;\" width=100"));
   } else {
       out.print(htmTb.addCell("","width=100"));
       out.print(htmTb.addCell("","width=100"));
       out.print(htmTb.addCell("<b>Total Payments</b>",htmTb.RIGHT,"width=300"));
   }
   out.print(htmTb.addCell("<b>"+Format.formatCurrency(gtPayments)+"</b>",htmTb.RIGHT,"style=\"border-top: 1px solid black;\" width=100"));
   out.print(htmTb.endRow());
   out.print(htmTb.endTable());
   out.print("</div>\n");
   out.print("</div>\n");

   out.print("<br><br><input type=button class=button value='print' onClick=printReport('" + Format.formatDate(reportDate, "yyyy-MM-dd") + "','" + Format.formatDate(reportToDate, "yyyy-MM-dd") + "','" +cptCode + "'," + providerId + ")>&nbsp;&nbsp;&nbsp;<input type=button class=button value='send to Excel' onClick=sendToExcel()>");

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

