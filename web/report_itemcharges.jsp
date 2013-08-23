<%@include file="template/pagetop.jsp" %>
<script>
    function printReport(year,showByMonth,resourceId) {
      var url="report_itemcharges_print.jsp?print=Y&year=" + year + "&showByMonth=" + showByMonth + "&resourceId=" + resourceId;
      window.open(url,'print','height=300,width=640,scrollbars=yes,resizable');
    }
</script>
<%
// Set up the SQL statement
    String currentYear = Format.formatDate(new java.util.Date(), "yyyy");
    String showByMonth = request.getParameter("showByMonth");
    ArrayList month = new ArrayList();
    String resourceId = request.getParameter("resourceId");
    String resource = "";
    boolean showMonth = false;

// Check to see if a resource is selected
    if(resourceId != null && !resourceId.equals("0")) { resource += " and resourceid=" + resourceId; }

// Check to see if a year is selected
    if(request.getParameter("year") != null) { currentYear=request.getParameter("year"); }

    String monthQuery  = "select distinct month(date) as billmonth from patientchargesummary where year(date)=" + currentYear + " order by month(date)";

// Set special attributes on the filtered list object
    String [] cw       = {"250", "100", "100", "100"};
    String [] ch       = {"Description", "Charges", "Payments", "Balance"};

// Set up an RWHtmlTable
    RWHtmlTable htmTb = new RWHtmlTable("600", "0");

// Set up an RWHtmlForm
    RWHtmlForm frm = new RWHtmlForm("frmInput", "report_itemcharges.jsp", "POST");

// Get a list of months
    ResultSet mRs = io.opnRS(monthQuery);
    while(mRs.next()) { month.add(mRs.getString("billmonth")); }

// Get a list of resources
    ResultSet resourceRs=io.opnRS("select 0 as resourceid, '*all' as name union select id as resourceid, name from resources order by name");

// Get a list of years
   ResultSet yearsRs=io.opnRS("SELECT YEAR(`Date`) AS `year` FROM visits group by YEAR(`date`) order by YEAR(`date`)");

// Build an array of filtered list objects
    double gtCharges=0.0;
    double gtPayments=0.0;
    double gtBalance=0.0;
    
// Set the checkbox value for showByMonth
    if(showByMonth != null && showByMonth.equals("true")) { showMonth = true; }

// Show the resource combobox
    out.print(frm.startForm());
    out.print("<b>Resouce: </b>" + frm.comboBox(resourceRs, "resourceId", "resourceId", false, "1", null, resourceId, "class=cBoxText"));
    out.print("&nbsp;&nbsp;&nbsp;");
    out.print("<b>Year </b>" + frm.comboBox(yearsRs, "year", "year", false, "1", null, currentYear, "class=cBoxText"));
    out.print("&nbsp;&nbsp;&nbsp;");
    out.print("<b>Show by Month </b>" + frm.checkBox(showMonth, "", "showByMonth"));
    out.print(frm.submitButton("go", "class=button"));
    out.print(frm.endForm());

    if(month.size()>0 && resourceId != null) {
        for(int i=0;i<month.size();i++) {
            double charges=0.0;
            double payments=0.0;
            double balance=0.0;

        // Set the current month
            String currentMonth=(String)month.get(i);
            String monthDescription=getMonthDescription(Integer.parseInt(currentMonth))+ "-";

         // Set the starting background color
            String bgColor="#e0e0e0";

         // Set up for separation by month
            String chargesMonthSelection = "";
            String paymentsMonthSelection = "";
            if(showByMonth.equals("true")) {
                chargesMonthSelection = " and month(visits.date)=" + currentMonth;
                paymentsMonthSelection = " and month(payments.date)=" + currentMonth;
            } else {
                monthDescription = "";
                i=month.size();
            }

         // Now print the details
            String myQuery     = "SELECT description, " +
                                 "ifnull((select sum(quantity*chargeamount) from charges " +
                                 "join (select * from visits where year(visits.date)=" + currentYear + chargesMonthSelection + " ) visits " +
                                 "on visits.id=charges.visitid " +
                                 "where itemid=items.id " + resource + "), 0) as charges, " +
                                 "ifnull((select sum(amount) from " +
                                 "(select * from payments where  year(payments.date)=" + currentYear + paymentsMonthSelection +") payments " +
                                 "left join charges on payments.chargeid=charges.id " +
                                 "where itemid=items.id " + resource + "), 0) as payments, " +
                                 "0.0 as unpaid " +
                                 "from items order by description";

        // Show headings for this month
            out.print(htmTb.startTable());
            out.print(htmTb.startRow());
            out.print(htmTb.headingCell(monthDescription + currentYear, "colspan=" + ch.length));
            out.print(htmTb.endRow());
            out.print(htmTb.startRow());
            for(int x=0;x<ch.length;x++) { out.print(htmTb.headingCell(ch[x], "width=" + cw[x])); }
            out.print(htmTb.endRow());

            ResultSet dtlRs=io.opnRS(myQuery);
            while(dtlRs.next()) {
                out.print(htmTb.startRow());
                out.print(htmTb.addCell(dtlRs.getString("description"), "style='background: " + bgColor + ";'"));
                out.print(htmTb.addCell(tools.utils.Format.formatCurrency(dtlRs.getDouble("charges")), htmTb.RIGHT, "style='background: " + bgColor + ";'"));
                out.print(htmTb.addCell(tools.utils.Format.formatCurrency(dtlRs.getDouble("payments")), htmTb.RIGHT, "style='background: " + bgColor + ";'"));
                out.print(htmTb.addCell(tools.utils.Format.formatCurrency((dtlRs.getDouble("charges") - dtlRs.getDouble("payments"))), htmTb.RIGHT, "style='background: " + bgColor + ";'"));
                out.print(htmTb.endRow());
                if(bgColor.equals("#e0e0e0")) { bgColor="#cccccc"; } else { bgColor="#e0e0e0"; }
                charges += dtlRs.getDouble("charges");
                payments += dtlRs.getDouble("payments");
                balance += (dtlRs.getDouble("charges") - dtlRs.getDouble("payments"));

                gtCharges += dtlRs.getDouble("charges");
                gtPayments += dtlRs.getDouble("payments");
                gtBalance += (dtlRs.getDouble("charges") - dtlRs.getDouble("payments"));

            }

         // Show the totals for the current month
            out.print(htmTb.startRow());
            out.print(htmTb.headingCell("Totals for " + monthDescription, htmTb.LEFT));
            out.print(htmTb.headingCell(tools.utils.Format.formatCurrency(charges), htmTb.RIGHT));
            out.print(htmTb.headingCell(tools.utils.Format.formatCurrency(payments), htmTb.RIGHT));
            out.print(htmTb.headingCell(tools.utils.Format.formatCurrency(balance), htmTb.RIGHT));
            out.print(htmTb.endRow());

         // Put out a blank line between months
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("", "colspan=" + ch.length));
            out.print(htmTb.endRow());

//           out.print("<input type=button class=button value=print onClick=printReport()>");

//           session.setAttribute("reportToPrint", lst);
        }

// Show the grand totals for the current month
        out.print(htmTb.startRow());
        out.print(htmTb.headingCell("Grand Totals", htmTb.LEFT));
        out.print(htmTb.headingCell(tools.utils.Format.formatCurrency(gtCharges), htmTb.RIGHT));
        out.print(htmTb.headingCell(tools.utils.Format.formatCurrency(gtPayments), htmTb.RIGHT));
        out.print(htmTb.headingCell(tools.utils.Format.formatCurrency(gtBalance), htmTb.RIGHT));
        out.print(htmTb.endRow());

// End the table
       out.print(htmTb.endTable());

       out.print("<div align=\"center\" style=\"width: 100%;\"><input type=\"button\" class=\"button\" value=\"print\" onClick=\"printReport("+currentYear+","+showByMonth+","+resourceId+")\"></div>");

    }
%>
<%@ include file="template/pagebottom.jsp" %>
<%! public String getMonthDescription(int currentMonth) {
        if(currentMonth == 1) { return "January"; }
        else if(currentMonth == 2) { return "February"; }
        else if(currentMonth == 3) { return "March"; }
        else if(currentMonth == 4) { return "April"; }
        else if(currentMonth == 5) { return "May"; }
        else if(currentMonth == 6) { return "June"; }
        else if(currentMonth == 7) { return "July"; }
        else if(currentMonth == 8) { return "August"; }
        else if(currentMonth == 9) { return "September"; }
        else if(currentMonth == 10) { return "October"; }
        else if(currentMonth == 11) { return "November"; }
        else if(currentMonth == 12) { return "December"; }
        else { return "Unknown"; }
   }
%>