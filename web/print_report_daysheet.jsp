<%@include file="globalvariables.jsp" %>
<%@ page import="java.text.*" %>

<script>
    function printReport(target) {
      window.open(target,'print','height=300,width=640,scrollbars=yes,resizable');
    }
</script>
<%
    RWInputForm frm = new RWInputForm();
    frm.setShowDatePicker(true);

    String startDate = request.getParameter("startdate");
    String endDate = request.getParameter("enddate");
    SimpleDateFormat isoFormat = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat mdyFormat = new SimpleDateFormat("MM/dd/yyyy");
    NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance(Locale.US);

    if (startDate == null) {
       startDate = mdyFormat.format(new java.util.Date());
    }

    if (endDate == null) {
       endDate = startDate;
    }

// Some work variables
    String myQuery = "";
    double subtotal=0;
    double total=0;
    double grandTotal=0;

// Generate the date selection form
//    out.print(frm.startForm());
//    out.print("<table><tr>");
//    out.print("<td>Start</td><td>" + frm.date(tools.utils.Format.formatDate(startDate, "MM/dd/yyyy"), "startdate", "class=tBoxText") + "</td>");
//    out.print("<td>End</td><td>" + frm.date(tools.utils.Format.formatDate(endDate, "MM/dd/yyyy"), "enddate", "class=tBoxText") + "</td>");
//    out.print("<td>" + frm.submitButton("go", "class=button") + "</td>");
//    out.print("</tr></table>");
//    out.print(frm.endForm());
    out.print("<CENTER><H1>Day Sheet</H1>" + startDate + " - " + endDate + "<br><br>");
//    String target="print_report_daysheet.jsp?startdate=" + startDate + "&enddate=" + endDate;

    startDate=tools.utils.Format.formatDate(startDate, "yyyy-MM-dd");
    endDate=tools.utils.Format.formatDate(endDate, "yyyy-MM-dd");

// Begin printing the report
//    out.print("<div style=\" height: 300; width: 638; overflow: auto;\">");

//---------------------------------------------------------------------------------------------------------------------------//
//- PAYMENTS ----------------------------------------------------------------------------------------------------------------//
//---------------------------------------------------------------------------------------------------------------------------//
    myQuery = "select a.date, ifnull(name, 'Cash') as payment, concat(lastname,', ', firstname) as patient, " +
                "case when originalamount>0 then originalamount*-1 else amount*-1 end as amount from " +
                "payments a left outer join " +
                "providers b on a.provider=b.id left outer join " +
                "patients c on a.patientid=c.id " +
                "where (name is null or name <> 'Write Off') and date between '" + startDate + "' and '" + endDate + "' and parentpayment=0 " +
                "order by 2,1, 3";

    boolean firstPayment=true;
    String lastPayment = "";
    total=0;

    ResultSet pRs = io.opnRS(myQuery);

    if (pRs.next()) {
        do {
            if (!lastPayment.equals(pRs.getString("payment"))) {
                if (!firstPayment) {
                    out.print("<tr><td style=\"border-top:1px solid black;border-left:1px solid black;border-bottom:1px solid black;\" colspan=3>Sub Total: </td><td style=\"border-top:1px solid black;border-right:1px solid black;border-bottom:1px solid black;\" align=right>" + currencyFormatter.format(subtotal) +"</td></tr>");
                    out.print("</table></fieldset><br><br>");
                }
                subtotal=0.00;
                firstPayment=false;
                lastPayment=pRs.getString("payment");

            // Print the Payment name
                out.print("<fieldset style='width: 620'>");
                out.print("<legend style='font-size: 12; font-weight: bold;' align=center>Payment: " + lastPayment + "</legend>");

            // Print the table headings
                out.print("<table cellpadding=1 cellspacing=0>");
                out.print("<tr>");
                out.print("<th style=\"border-top:1px solid black;border-bottom:1px solid black;border-left:1px solid black;\" width=50>Date</td>");
                out.print("<th style=\"border-top:1px solid black;border-bottom:1px solid black;\" width=300>Description</td>");
                out.print("<th style=\"border-top:1px solid black;border-bottom:1px solid black;\" width=150>Patient</td>");
                out.print("<th width=100 style=\"border-top:1px solid black;border-bottom:1px solid black;border-right:1px solid black;\">Amount</td>");
                out.print("</tr>");
            }

        // Now the details
            out.print("<tr>");
            out.print("<td style=\"border-left:1px solid black;\" >" + pRs.getString(1) + "</td>");
            out.print("<td>Payment</td>");
            out.print("<td>" + pRs.getString(3) + "</td>");
            out.print("<td align=right style=\"border-right:1px solid black;\" >" + currencyFormatter.format(pRs.getDouble(4)) + "</td>");
            out.print("</tr>");

            subtotal+=pRs.getDouble("amount");
            total+=pRs.getDouble("amount");

        } while (pRs.next());

        if (!firstPayment) {
            out.print("<tr><td style=\"border-top:1px solid black;border-left:1px solid black;border-bottom:1px solid black;\" colspan=3>Sub Total: </td><td style=\"border-top:1px solid black;border-right:1px solid black;border-bottom:1px solid black;\" align=right>" + currencyFormatter.format(subtotal) +"</td></tr>");
            out.print("<tr><td colspan=4>&nbsp;</td></tr>");
            out.print("<tr><td style=\"border-top:1px solid black;border-left:1px solid black;border-bottom:1px solid black;\" colspan=3>Payment Total: </td><td style=\"border-top:1px solid black;border-right:1px solid black;border-bottom:1px solid black;\" align=right>" + currencyFormatter.format(total) +"</td></tr>");

            out.print("</table></fieldset><br><br>");

        }
        grandTotal+=total;
    }

//---------------------------------------------------------------------------------------------------------------------------//
//- WRITEOFFS ----------------------------------------------------------------------------------------------------------------//
//---------------------------------------------------------------------------------------------------------------------------//
    myQuery = "select a.date, ifnull(name, 'Cash') as payment, concat(lastname,', ', firstname) as patient, " +
                "case when originalamount>0 then originalamount*-1 else amount*-1 end as amount from " +
                "payments a left outer join " +
                "providers b on a.provider=b.id left outer join " +
                "patients c on a.patientid=c.id " +
                "where name = 'Write Off' and date between '" + startDate + "' and '" + endDate + "' and parentpayment=0 " +
                "order by 2,1, 3";

    boolean firstWriteOff=true;
    String lastWriteOff = "";
    total=0;

    ResultSet wRs = io.opnRS(myQuery);

    if (wRs.next()) {
        do {
            if (!lastWriteOff.equals(wRs.getString("payment"))) {
                if (!firstWriteOff) {
                    out.print("<tr><td style=\"border-top:1px solid black;border-left:1px solid black;border-bottom:1px solid black;\" colspan=3>Sub Total: </td><td style=\"border-top:1px solid black;border-right:1px solid black;border-bottom:1px solid black;\" align=right>" + currencyFormatter.format(subtotal) +"</td></tr>");
                    out.print("</table></fieldset><br><br>");
                }
                subtotal=0.00;
                firstWriteOff=false;
                lastWriteOff=wRs.getString("payment");

            // Print the Payment name
                out.print("<fieldset style='width: 620'>");
                out.print("<legend style='font-size: 12; font-weight: bold;' align=center>Write Offs</legend>");

            // Print the table headings
                out.print("<table cellpadding=1 cellspacing=0>");
                out.print("<tr>");
                out.print("<th style=\"border-top:1px solid black;border-bottom:1px solid black;border-left:1px solid black;\" width=50>Date</td>");
                out.print("<th style=\"border-top:1px solid black;border-bottom:1px solid black;\" width=300>Description</td>");
                out.print("<th style=\"border-top:1px solid black;border-bottom:1px solid black;\" width=150>Patient</td>");
                out.print("<th width=100 style=\"border-top:1px solid black;border-bottom:1px solid black;border-right:1px solid black;\">Amount</td>");
                out.print("</tr>");
            }

        // Now the details
            out.print("<tr>");
            out.print("<td style=\"border-left:1px solid black;\" >" + wRs.getString(1) + "</td>");
            out.print("<td>Write Off</td>");
            out.print("<td>" + wRs.getString(3) + "</td>");
            out.print("<td align=right style=\"border-right:1px solid black;\" >" + currencyFormatter.format(wRs.getDouble(4)) + "</td>");
            out.print("</tr>");

            subtotal+=wRs.getDouble("amount");
            total+=wRs.getDouble("amount");

        } while (wRs.next());

        if (!firstWriteOff) {
            out.print("<tr><td style=\"border-top:1px solid black;border-left:1px solid black;border-bottom:1px solid black;\" colspan=3>Sub Total: </td><td style=\"border-top:1px solid black;border-right:1px solid black;border-bottom:1px solid black;\" align=right>" + currencyFormatter.format(subtotal) +"</td></tr>");
            out.print("<tr><td colspan=4>&nbsp;</td></tr>");
            out.print("<tr><td style=\"border-top:1px solid black;border-left:1px solid black;border-bottom:1px solid black;\" colspan=3>Write Off Total: </td><td style=\"border-top:1px solid black;border-right:1px solid black;border-bottom:1px solid black;\" align=right>" + currencyFormatter.format(total) +"</td></tr>");

            out.print("</table></fieldset><br><br>");

        }
        grandTotal+=total;
    }

//---------------------------------------------------------------------------------------------------------------------------//
//- CHARGES -----------------------------------------------------------------------------------------------------------------//
//---------------------------------------------------------------------------------------------------------------------------//
    myQuery = "SELECT b.date, c.description, concat(lastname,', ', firstname) as patient " +
                ", a.chargeamount as amount, 'charge' as chargetype " +
                "from charges a join " +
                "visits b on a.visitid=b.id join " +
                "items c on a.itemid=c.id join " +
                "patients d on b.patientid=d.id " +
                "where b.date between '" + startDate + "' and '" + endDate + "' " +
                "order by chargetype, date, patient";

    boolean firstCharge=true;
    String lastCharge = "";
    total=0;

    ResultSet cRs = io.opnRS(myQuery);

    if (cRs.next()) {
        do {
            if (!lastCharge.equals(cRs.getString("chargetype"))) {
                if (!firstCharge) {
                    out.print("<tr><td style=\"border-top:1px solid black;border-left:1px solid black;border-bottom:1px solid black;\" colspan=3>Sub Total: </td><td style=\"border-top:1px solid black;border-right:1px solid black;border-bottom:1px solid black;\" align=right>" + currencyFormatter.format(subtotal) +"</td></tr>");
                    out.print("</table></fieldset><br><br>");
                }
                subtotal=0.00;
                firstCharge=false;
                lastCharge=cRs.getString("chargetype");

            // Print the Charge name
                out.print("<fieldset style='width: 620'>");
                out.print("<legend style='font-size: 12; font-weight: bold;' align=center>Billable Charges</legend>");

            // Print the table headings
                out.print("<table cellpadding=1 cellspacing=0>");
                out.print("<tr>");
                out.print("<th style=\"border-top:1px solid black;border-bottom:1px solid black;border-left:1px solid black;\" width=50>Date</td>");
                out.print("<th style=\"border-top:1px solid black;border-bottom:1px solid black;\" width=300>Description</td>");
                out.print("<th style=\"border-top:1px solid black;border-bottom:1px solid black;\" width=150>Patient</td>");
                out.print("<th width=100 style=\"border-top:1px solid black;border-bottom:1px solid black;border-right:1px solid black;\">Amount</td>");
                out.print("</tr>");
            }

        // Now the details
            out.print("<tr>");
            out.print("<td style=\"border-left:1px solid black;\" >" + cRs.getString("date") + "</td>");
            out.print("<td>" + cRs.getString("description") + "</td>");
            out.print("<td>" + cRs.getString("patient") + "</td>");
            out.print("<td align=right style=\"border-right:1px solid black;\" >" + currencyFormatter.format(cRs.getDouble("amount")) + "</td>");
            out.print("</tr>");

            subtotal+=cRs.getDouble("amount");
            total+=cRs.getDouble("amount");

        } while (cRs.next());

        if (!firstCharge) {
            out.print("<tr><td style=\"border-top:1px solid black;border-left:1px solid black;border-bottom:1px solid black;\" colspan=3>Sub Total: </td><td style=\"border-top:1px solid black;border-right:1px solid black;border-bottom:1px solid black;\" align=right>" + currencyFormatter.format(subtotal) +"</td></tr>");
            out.print("<tr><td colspan=4>&nbsp;</td></tr>");
            out.print("<tr><td style=\"border-top:1px solid black;border-left:1px solid black;border-bottom:1px solid black;\" colspan=3>Billable Charges Total: </td><td style=\"border-top:1px solid black;border-right:1px solid black;border-bottom:1px solid black;\" align=right>" + currencyFormatter.format(total) +"</td></tr>");

            out.print("</table></fieldset><br><br>");

        }
        grandTotal+=total;
    }
    out.print("<table cellpadding=1 cellspacing=0>");
    out.print("<tr><td style=\"border-top:1px solid black;border-left:1px solid black;border-bottom:1px solid black;\" width=500>Grand Total: </td><td width=100 style=\"border-top:1px solid black;border-right:1px solid black;border-bottom:1px solid black;\" align=right>" + currencyFormatter.format(grandTotal) +"</td></tr>");
    out.print("</table>");

//---------------------------------------------------------------------------------------------------------------------------//

//    out.print("</div>");

// Add the print button
//    out.print("<input type=button class=button value=print onClick=printReport('"+ target + "')>");

   %>
