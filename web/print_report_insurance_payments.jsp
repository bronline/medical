<%--
    Document   : print_report_insurance_payments
    Created on : November 29, 2010
    Author     : Randy
--%>

<%@page contentType="text/html" pageEncoding="windows-1252"%>
<%@include file="globalvariables.jsp" %>
<%
   RWHtmlTable htmTb = new RWHtmlTable("600", "0");

   String reportDate=request.getParameter("reportDate");
   String reportToDate=request.getParameter("reportToDate");
   
   boolean showDetail=false;
   double chargeTotal=0.0;
   double gtPayments=0.0;
   double gtCharges=0.0;

   if(reportDate == null || reportDate.equals("")) { reportDate=Format.formatDate(new java.util.Date(), "yyyy-MM-dd"); }
   if(reportToDate == null || reportToDate.equals("")) { reportToDate=Format.formatDate(new java.util.Date(), "yyyy-MM-dd"); }
   if(request.getParameter("showDetail").equals("true")) { showDetail=true; }

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

   String myQuery = "select providers.id as providerid, DATE_FORMAT(`date`,'%m/%d/%y') as `checkdate`, checknumber, " +
                     "name, " +
                     "  sum(amount) as amount " +
                     "from payments " +
                     "left join providers on providers.id=payments.provider " +
                     "where not reserved and `date` between '" + Format.formatDate(reportDate, "yyyy-MM-dd") + "' and '" + Format.formatDate(reportToDate, "yyyy-MM-dd") + "' " +
                     "group by providers.id, `date`, checknumber " +
                     "order by `date`";
   String chargeQuery = "select DATE_FORMAT(v.`date`,'%m/%d/%y') as dos, concat(pt.firstname,' ',pt.lastname) as name, concat(i.code, ' - ', i.description) as item, c.chargeamount*c.quantity as charge, p.amount " +
                     "from payments p " +
                     "left join charges c on c.id=p.chargeid " +
                     "left join items i on i.id=c.itemid " +
                     "left join visits v on v.id=c.visitid " +
                     "left join patients pt on pt.id=p.patientid " +
                     "where p.provider=? and p.`date`=? and p.checknumber=?";

   ResultSet facilityRs=io.opnRS("select * from facilityaddress order by id");
   ResultSet pmtRs=io.opnRS(myQuery);
   PreparedStatement pmtPs=io.getConnection().prepareStatement(chargeQuery);

   if(facilityRs.next()) {
       out.print(htmTb.startTable("600"));
       out.print(htmTb.startRow());
       out.print(htmTb.addCell("","width=400"));
       out.print(htmTb.addCell(facilityRs.getString("facilityname"),"width=200 style=\"font-size: 12; font-weight: bold;\""));
       out.print(htmTb.endRow());
       out.print(htmTb.startRow());
       out.print(htmTb.addCell("","width=400"));
       out.print(htmTb.addCell(facilityRs.getString("facilityaddress"),"width=200 style=\"font-size: 12; font-weight: bold;\""));
       out.print(htmTb.endRow());
       out.print(htmTb.startRow());
       out.print(htmTb.addCell("","width=400"));
       out.print(htmTb.addCell(facilityRs.getString("facilitycsz"),"width=200 style=\"font-size: 12; font-weight: bold;\""));
       out.print(htmTb.endRow());
       out.print(htmTb.endTable());
       out.print("<br/><br/><br/>");
   }

   out.print(htmTb.startTable("600"));
   out.print(htmTb.startRow());
   out.print(htmTb.headingCell("Date",htmTb.CENTER,"width=100"));
   out.print(htmTb.headingCell("Check #",htmTb.CENTER,"width=100"));
   out.print(htmTb.headingCell("Payer",htmTb.CENTER,"width=300"));
   out.print(htmTb.headingCell("Amount",htmTb.RIGHT,"width=100"));
   out.print(htmTb.endRow());
   out.print(htmTb.endTable());

   out.print(htmTb.startTable("600"));
   while(pmtRs.next()) {
       out.print(htmTb.startRow("style=\"background-color: #cccccc;\""));
       out.print(htmTb.addCell(pmtRs.getString("checkdate"),htmTb.CENTER,"width=100"));
       out.print(htmTb.addCell(pmtRs.getString("checknumber"),htmTb.LEFT,"width=100"));
       out.print(htmTb.addCell(pmtRs.getString("name"),htmTb.LEFT,"width=300"));
       if(showDetail) {
           out.print(htmTb.addCell("","width=100"));
       } else {
           out.print(htmTb.addCell(Format.formatCurrency(pmtRs.getDouble("amount")),htmTb.RIGHT,"width=100"));
       }
       out.print(htmTb.endRow());
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
       gtPayments+=pmtRs.getDouble("amount");
   }
   out.print(htmTb.endTable());   

   out.print(htmTb.startTable("600"));
   out.print(htmTb.startRow("style=\"background-color: #cccccc;\""));
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

%>
