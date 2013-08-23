<%-- 
    Document   : patientcheckout
    Created on : Mar 6, 2012, 9:32:59 AM
    Author     : rwandell
--%>
<script type="text/javascript" src="../js/jQuery.js"></script>
<script type="text/javascript">
    function processCheckout() {
        var url="ajax/patientcheckout.jsp?update=Y";

        var dataString = $("#checkoutForm").serialize();

        $.ajax({
            type: "POST",
            url: url,
            data: dataString,
            success: function(data) {

            },
            complete: function(data) {
                $('#txtHint').css('visibility','hidden');
                $('#txtHint').css('display','none');
                $('#txtHint').css('-moz-box-shadow','');
                $('#txtHint').css('-webkit-box-shadow','');
                $('#txtHint').css('box-shadow','');
                alert("payment has been posted");
            }

        });
    }
</script>
<%@include file="sessioninfo.jsp" %>
<%
    String update = request.getParameter("update");

    if(update == null) {
        String copayAsPercent = "false";
        String chargeQuery = "SELECT * FROM charges WHERE visitid in (select id from visits where patientid=" + patient.getId() + " and `date` = current_date) and itemId IN (SELECT min(id) from items where copayitem)";

        ResultSet piRs = io.opnRS("SELECT * FROM patientinsurance WHERE active AND primaryprovider AND patientid=" + patient.getId());
        if(piRs.next()) {
            if(piRs.getBoolean("copayaspercent")) {
                chargeQuery = "SELECT 0 as id, SUM(copayamount) as chargeamount FROM charges WHERE visitid in (select id from visits where patientid=" + patient.getId() + " and `date` = current_date)";
                copayAsPercent = "true";
            }
        }

        ResultSet chgRs = io.opnRS(chargeQuery);
        if(chgRs.next()) {
            ResultSet pmtRs = io.opnRS("SELECT * FROM payments where chargeid in (select Id from charges where visitid in (select id from visits where patientid=" + patient.getId() + " and `date` = current_date))");
            if(!pmtRs.next()) {
                ResultSet frmRs = io.opnRS("select id, provider, checknumber, amount from payments WHERE id=0");
                RWInputForm frm = new RWInputForm(frmRs);
                frm.setTableBorder("0");
                frm.setTableWidth("250");
                frm.setDftTextBoxSize("35");
                frm.setDftTextAreaCols("35");
                frm.setDisplayDeleteButton(false);
                frm.setLabelBold(true);
                frm.setOnSubmit("return processCheckout();");
                frm.setUpdateButtonText("  save  ");
                frm.setFormUrl("processCheckout()");

                out.print("<div id=\"checkoutDiv\">\n");
                out.print("<div style=\"position: relative; top: -5px; cursor: pointer; width: 100%; text-align: right; font-weight: bold;\" onClick=\"closeCheckoutBubble()\">close</div>\n");
                out.print("<form id=\"checkoutForm\" name=\"checkoutForm\">\n");
                out.print("<table width=\"400px\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\">");
                out.print(frm.getInputItem("provider", ""));
                out.print(frm.getInputItem("checknumber", ""));
                out.print(frm.getInputItem("amount", ""));
                out.print("</table>\n");
                out.print("<input type=\"hidden\" id=\"patientId\" name=\"patientId\" value=\"" + patient.getId() + "\">\n");
                out.print("<input type=\"hidden\" id=\"chargeId\" name=\"chargeId\" value=\"" + chgRs.getString("id") + "\">\n");
                out.print("<input type=\"hidden\" id=\"chargeamount\" name=\"chargeamount\" value=\"" + chgRs.getDouble("chargeamount") + "\">\n");
                out.print("<input type=\"hidden\" id=\"copayaspercent\" name=\"copayaspercent\" value=\"" + copayAsPercent + "\">\n");
                out.print("<br/>");
                out.print("<input type=\"button\" class=\"button\" value=\"apply\" onClick=\"processCheckout()\">");
                out.print("</form>\n");
                out.print("</div>\n");

                out.print("<script type=\"text/javascript\">$('#amount').val('" + Format.formatCurrency(chgRs.getDouble("chargeamount")) + "'); $('#amount').css('text-align','right');</script>\n");
                frmRs.close();
            }
            pmtRs.close();
        }
        chgRs.close();

        piRs.close();
        piRs = null;
    } else if(update.equals("Y")) {
        String copayAsPercent = request.getParameter("copayaspercent");
        String providerId = request.getParameter("provider");
        String checkNumber = request.getParameter("checknumber");
        String patientId = request.getParameter("patientId");
        String chargeId = request.getParameter("chargeId");
        String paymentAmount = request.getParameter("amount");
        double chargeAmount = Double.parseDouble(request.getParameter("chargeamount"));
        double amount = Double.parseDouble(paymentAmount.replaceAll("\\$","").replaceAll(",",""));
        String date = Format.formatDate(new java.util.Date(), "yyyy-MM-dd");
        int parentPayment = 0;

        PreparedStatement pmtPs = io.getConnection().prepareStatement("insert into payments (provider, patientid, chargeid, `date`, checknumber, amount, originalamount, parentpayment) VALUES (?,?,?,?,?,?,?,?)");

        if(amount>chargeAmount || copayAsPercent.equals("true")) {
            pmtPs.setString(1, providerId);
            pmtPs.setString(2, patientId);
            pmtPs.setInt(3, 0);
            pmtPs.setString(4, date);
            pmtPs.setString(5, checkNumber);
            pmtPs.setDouble(6, amount-chargeAmount);
            pmtPs.setDouble(7, amount);
            pmtPs.setInt(8, 0);

            pmtPs.execute();

            ResultSet rs  = io.opnRS("select LAST_INSERT_ID()");
            if(rs.next()) {
                parentPayment = rs.getInt(1);
            }
            rs.close();
        }

        String chargeQuery = "SELECT * FROM charges WHERE id=" + chargeId;
        if(copayAsPercent.equals("true")) { chargeQuery = "SELECT * FROM charges WHERE visitid in (select id from visits where patientid=" + patient.getId() + " and `date` = current_date)"; }

        ResultSet chgRs = io.opnRS(chargeQuery);
        while(chgRs.next() && amount>0) {
            if(copayAsPercent.equals("true")) {
                chargeAmount = chgRs.getDouble("copayamount");
            } else {
                chargeAmount = chgRs.getDouble("chargeamount");
            }
            pmtPs.setString(1, providerId);
            pmtPs.setString(2, patientId);
            pmtPs.setInt(3, chgRs.getInt("id"));
            pmtPs.setString(4, date);
            pmtPs.setString(5, checkNumber);
            pmtPs.setDouble(6, chargeAmount);
            pmtPs.setDouble(7, chargeAmount);
            pmtPs.setInt(8, parentPayment);

            pmtPs.execute();
            
            amount = amount-chargeAmount;
        }
    }
%>
<%@include file="cleanup.jsp" %>
