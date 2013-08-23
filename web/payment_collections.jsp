<%-- 
    Document   : payment_collections
    Created on : Apr 3, 2012, 2:50:49 PM
    Author     : rwandell
--%>
<%
    String startDate = request.getParameter("startDate");
    String endDate = request.getParameter("endDate");
    boolean printReport=false;

    if(startDate == null) {
        ResultSet dayRs = io.opnRS("select DATE_ADD(DATE_ADD(current_date, interval -1 MONTH), INTERVAL (-DAY(current_date)+1) DAY) as startDate, DATE_ADD(DATE_ADD(DATE_ADD(DATE_ADD(current_date, interval -1 MONTH), INTERVAL (-DAY(current_date)+1) DAY), INTERVAL 1 MONTH), INTERVAL -1 DAY) as endDate");
        if(dayRs.next()) {
            startDate=dayRs.getString("startDate");
            endDate=dayRs.getString("endDate");
        }
        dayRs.close();
    } else {
        startDate=Format.formatDate(startDate,"yyyy-MM-dd");
        endDate=Format.formatDate(endDate,"yyyy-MM-dd");
    }

    if(request.getParameter("printReport") != null) { printReport=true; }

    String cashPtQuery = "SELECT " +
            "  p.id, " +
            "  CONCAT(lastname,', ',firstname) AS name, " +
            "  COUNT(pm.id) AS payments " +
            "FROM patients p " +
            "LEFT JOIN payments pm ON pm.patientid=p.id AND pm.chargeid<>0 AND pm.`date` BETWEEN '" + startDate + "' AND '" + endDate + "' " +
            "LEFT JOIN patientinsurance pi ON pi.patientid=p.id and primaryprovider and pi.active " +
            "WHERE " +
            "  pi.id IS NULL " +
            "GROUP BY " +
            "  p.id " +
            "HAVING " +
            "  COUNT(pm.id)>0 " +
            "ORDER BY " +
            "  p.lastname, " +
            "  p.firstname";

    String insPtQuery = "SELECT " +
            "  p.id, " +
            "  CONCAT(lastname,', ',firstname) AS name, " +
            "  COUNT(pm.id) AS payments " +
            "FROM patients p " +
            "LEFT JOIN payments pm ON pm.patientid=p.id AND pm.chargeid<>0 AND pm.`date` BETWEEN '" + startDate + "' AND '" + endDate + "' " +
            "LEFT JOIN patientinsurance pi ON pi.patientid=p.id and primaryprovider and pi.active " +
            "WHERE " +
            "  pi.id IS NOT NULL " +
            "GROUP BY " +
            "  p.id " +
            "HAVING " +
            "  COUNT(pm.id)>0 " +
            "ORDER BY " +
            "  p.lastname, " +
            "  p.firstname";

    String ptPmtQuery = "SELECT " +
            " ifnull(SUM(amount),0) AS ptamount " +
            "FROM payments pm " +
            "LEFT JOIN providers pr ON pm.provider=pr.id AND pr.reserved " +
            "WHERE " +
            " pm.`date` BETWEEN ? AND ? " +
            " AND pm.patientid=? " +
            " AND pm.chargeid<>0 " +
            " AND ((pr.id<>10 " +
            " AND NOT pr.isadjustment) or pr.id is null)";

    String ptAdjQuery = "SELECT " +
            " ifnull(SUM(amount),0) AS ptamount " +
            "FROM payments pm " +
            "LEFT JOIN providers pr ON pm.provider=pr.id AND pr.reserved " +
            "WHERE " +
            " pm.`date` BETWEEN ? AND ? " +
            " AND pm.patientid=? " +
            " AND pm.chargeid<>0 " +
            " AND (pr.id=10 OR pr.isadjustment) " +
            " AND pr.provider<>0";

    String ptInsQuery = "SELECT " +
            " ifnull(SUM(amount),0) AS amount " +
            "FROM payments pm " +
            "LEFT JOIN providers pr ON pm.provider=pr.id AND NOT pr.reserved " +
            "WHERE " +
            " pm.`date` BETWEEN ? AND ? " +
            " AND pm.patientid=? " +
            " AND pm.chargeid<>0 " +
            " and pm.provider<>10 " +
            " AND NOT pr.isadjustment";

    double patientPayments = 0.0;
    double paymentAdjustments = 0.0;
    double insurancePayments = 0.0;

    double totalCashPayments = 0.0;
    double totalCashAdjustments = 0.0;
    double totalInsPtPayments = 0.0;
    double totalInsAdjustments = 0.0;
    double totalInsPayments = 0.0;
    double totalPtPayments = 0.0;
    double totalAdjustments = 0.0;
    double totalInsurance = 0.0;

    int currentLine = 0;
    int linesPerPage = 75;
    int pageNumber = 1;

    String plusSign = "[+]";
    String rowStyle = "style=\"height: 15px;\"";
    String bgColor = "";

    java.util.Date reportDate = new java.util.Date();

    PreparedStatement ptPmtPs = io.getConnection().prepareStatement(ptPmtQuery);
    PreparedStatement ptAdjPs = io.getConnection().prepareStatement(ptAdjQuery);
    PreparedStatement ptInsPs = io.getConnection().prepareStatement(ptInsQuery);

    ptPmtPs.setString(1, startDate);
    ptPmtPs.setString(2, endDate);

    ptAdjPs.setString(1, startDate);
    ptAdjPs.setString(2, endDate);

    ptInsPs.setString(1, startDate);
    ptInsPs.setString(2, endDate);

    RWHtmlTable htmTb = new RWHtmlTable("800", "0", "0", "0");
    RWInputForm frm = new RWInputForm();

    if(!printReport) {
        out.print("<div align=\"center\" style=\"width: 100%;\">");
        out.print(frm.startForm());
        out.print("<table><tr>");
//        out.print("<td>Provider</td><td>" + frm.comboBox(rRs, "resourceId", "id", false, "1", null, resourceId, "class='cBoxText'") + "</td>");
        out.print("<td>Start</td><td>" + frm.date(tools.utils.Format.formatDate(startDate, "MM/dd/yyyy"), "startDate", "class=tBoxText") + "</td>");
        out.print("<td>End</td><td>" + frm.date(tools.utils.Format.formatDate(endDate, "MM/dd/yyyy"), "endDate", "class=tBoxText") + "</td>");
        out.print("<td>" + frm.submitButton("go", "class=button") + "</td>");
        out.print("</tr></table>");
        out.print(frm.endForm());
        out.print("</div><div align=\"left\" style=\"margin-left: 30px; float: left;\">\n");
    } else {
        plusSign="";
        rowStyle="";
        bgColor="#e0e0e0";
    }

    out.print(htmTb.startTable());

    ResultSet ptRs = io.opnRS(cashPtQuery);
    while(ptRs.next()) {
        if((currentLine>=linesPerPage && printReport) || ptRs.getRow()==1 ) {
            if(printReport) {
                htmTb.setCellVAlign("bottom");
                out.print(htmTb.startRow("style=\"height: 50px;\""));
                out.print(htmTb.addCell("Date: " + Format.formatDate(reportDate, "MM/dd/yy"), RWHtmlTable.LEFT, "style=\"font-size: 12px; bold;page-break-before: always; \""));
                out.print(htmTb.addCell("", "colspan=\"3\""));
                out.print(htmTb.addCell("Page: " + pageNumber, RWHtmlTable.RIGHT, "style=\"font-size: 12px; \""));
                out.print(htmTb.endRow());
                out.print(htmTb.startRow());
                out.print(htmTb.addCell("Payment Collection Report", RWHtmlTable.CENTER, "colspan=\"5\" style=\"font-size: 16px; font-weight: bold;\""));
                out.print(htmTb.endRow());
            }
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("Cash Patients", RWHtmlTable.CENTER, "colspan=\"5\" style=\"font-size: 16px; font-weight: bold;\""));
            out.print(htmTb.endRow());
            out.print(htmTb.startRow("style=\"background-color: #030098;\""));
            out.print(htmTb.headingCell("", "width=\"5%\""));
            out.print(htmTb.headingCell("Patient Name", RWHtmlTable.LEFT, "width=\"35%\""));
            out.print(htmTb.headingCell("Payments", RWHtmlTable.CENTER, "width=\"15%\""));
            out.print(htmTb.headingCell("Pt Payments", RWHtmlTable.RIGHT, "width=\"15%\""));
            out.print(htmTb.headingCell("Adjustments", RWHtmlTable.RIGHT,"width=\"15%\""));
            out.print(htmTb.headingCell("", "width=\"15%\""));
            out.print(htmTb.endRow());
            htmTb.setCellVAlign("top");

            currentLine = 20;
            pageNumber ++;

            if(!printReport) {
                out.print(htmTb.endTable());
                out.print("<div style=\"width: 820px; height: 200px; overflow: auto;\">");
                out.print(htmTb.startTable());
            } else {
                bgColor="#e0e0e0";
            }
        }

        if(printReport) { rowStyle = "style=\"background-color: " + bgColor + ";\""; }

        ptPmtPs.setInt(3, ptRs.getInt("id"));
        ResultSet ptPmtRs = ptPmtPs.executeQuery();
        if(ptPmtRs.next()) { patientPayments=ptPmtRs.getDouble("ptamount"); } else { patientPayments=0.0; }

        ptAdjPs.setInt(3, ptRs.getInt("id"));
        ResultSet ptAdjRs = ptAdjPs.executeQuery();
        if(ptAdjRs.next()) { paymentAdjustments=ptAdjRs.getDouble("ptamount"); } else { paymentAdjustments=0.0; }

        out.print(htmTb.startRow(rowStyle));
        out.print(htmTb.addCell(plusSign, RWHtmlTable.CENTER, "width=\"5%\" id=\"plus"+ptRs.getString("id")+"\" onClick=\"showPaymentDetails(this,"+ptRs.getString("id")+")\" style=\"cursor: pointer;\""));
        out.print(htmTb.addCell(ptRs.getString("name"), "width=\"35%\""));
        out.print(htmTb.addCell(ptRs.getString("payments"), RWHtmlTable.CENTER, "width=\"15%\""));
        out.print(htmTb.addCell(Format.formatCurrency(patientPayments), RWHtmlTable.RIGHT, "width=\"15%\""));
        out.print(htmTb.addCell(Format.formatCurrency(paymentAdjustments), RWHtmlTable.RIGHT,"width=\"15%\""));
        out.print(htmTb.addCell("", "width=\"15%\""));
        out.print(htmTb.endRow());

        if(!printReport) {
            out.print(htmTb.startRow("style=\"background-color: #e0e0e0;\""));
            out.print(htmTb.addCell("", RWHtmlTable.CENTER, "id=\"rowId"+ptRs.getString("id")+"\" style=\"display: none;\" colspan=\"6\""));
            out.print(htmTb.endRow());
        }

        totalCashPayments += patientPayments;
        totalCashAdjustments += paymentAdjustments;

        currentLine ++;

        if(bgColor.equals("#e0e0e0")) { bgColor="#ffffff"; } else { bgColor="#e0e0e0"; }

        ptPmtRs.close();
        ptPmtRs = null;

        ptAdjRs.close();
        ptAdjRs = null;
    }

    if(!printReport) {
        out.print(htmTb.endTable());
        out.print("</div>");
        out.print(htmTb.startTable());
    }

    out.print(htmTb.startRow());
    out.print(htmTb.addCell("","width=\"5%\" style=\"border-top: 1px solid black; font-size: 12px; font-weight: bold;\""));
    out.print(htmTb.addCell("Totals", "width=\"35%\" style=\"border-top: 1px solid black; font-size: 12px; font-weight: bold;\""));
    out.print(htmTb.addCell("", RWHtmlTable.CENTER, "width=\"15%\" style=\"border-top: 1px solid black; font-size: 12px; font-weight: bold;\""));
    out.print(htmTb.addCell(Format.formatCurrency(totalCashPayments), RWHtmlTable.RIGHT, "width=\"15%\" style=\"border-top: 1px solid black; font-size: 12px; font-weight: bold;\""));
    out.print(htmTb.addCell(Format.formatCurrency(totalCashAdjustments), RWHtmlTable.RIGHT,"width=\"15%\" style=\"border-top: 1px solid black; font-size: 12px; font-weight: bold;\""));
    out.print(htmTb.addCell("", "width=\"15%\" style=\"border-top: 1px solid black; font-size: 12px; font-weight: bold;\""));
    out.print(htmTb.endRow());

    ResultSet insRs = io.opnRS(insPtQuery);
    while(insRs.next()) {
        if((currentLine>=linesPerPage && printReport) || insRs.getRow() == 1) {
            if(printReport) {
                htmTb.setCellVAlign("bottom");
                out.print(htmTb.startRow("style=\"height: 50px;\""));
                out.print(htmTb.addCell("Date: " + Format.formatDate(reportDate, "MM/dd/yy"), RWHtmlTable.LEFT, "style=\"font-size: 12px; page-break-before: always; \""));
                out.print(htmTb.addCell("", "colspan=\"3\""));
                out.print(htmTb.addCell("Page: " + pageNumber, RWHtmlTable.RIGHT, "style=\"font-size: 12px; \""));
                out.print(htmTb.endRow());
                out.print(htmTb.startRow());
                out.print(htmTb.addCell("Payment Collection Report", RWHtmlTable.CENTER, "colspan=\"5\" style=\"font-size: 16px; font-weight: bold;\""));
                out.print(htmTb.endRow());
            }
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("Insurance Patients", RWHtmlTable.CENTER, "colspan=\"5\" style=\"font-size: 16px; font-weight: bold;\""));
            out.print(htmTb.endRow());
            out.print(htmTb.startRow());
            out.print(htmTb.headingCell("", "width=\"5%\""));
            out.print(htmTb.headingCell("Patient Name", RWHtmlTable.LEFT, "width=\"35%\""));
            out.print(htmTb.headingCell("Payments", RWHtmlTable.CENTER, "width=\"15%\""));
            out.print(htmTb.headingCell("Pt Payments", RWHtmlTable.RIGHT, "width=\"15%\""));
            out.print(htmTb.headingCell("Adjustments", RWHtmlTable.RIGHT,"width=\"15%\""));
            out.print(htmTb.headingCell("Insurance", RWHtmlTable.RIGHT, "width=\"15%\""));
            out.print(htmTb.endRow());
            htmTb.setCellVAlign("top");

            currentLine=20;
            pageNumber ++;

            if(!printReport) {
                out.print(htmTb.endTable());
                out.print("<div style=\"width: 820px; height: 200px; overflow: auto;\">");
                out.print(htmTb.startTable());
            } else {
                bgColor="#e0e0e0";
            }
        }

        if(printReport) { rowStyle = "style=\"background-color: " + bgColor + ";\""; }

        ptPmtPs.setInt(3, insRs.getInt("id"));
        ResultSet ptPmtRs = ptPmtPs.executeQuery();
        if(ptPmtRs.next()) { patientPayments=ptPmtRs.getDouble("ptamount"); } else { patientPayments=0.0; }

        ptAdjPs.setInt(3, insRs.getInt("id"));
        ResultSet ptAdjRs = ptAdjPs.executeQuery();
        if(ptAdjRs.next()) { paymentAdjustments=ptAdjRs.getDouble("ptamount"); } else { paymentAdjustments=0.0; }

        ptInsPs.setInt(3, insRs.getInt("id"));
        ResultSet ptInsRs = ptInsPs.executeQuery();
        if(ptInsRs.next()) { insurancePayments=ptInsRs.getDouble("amount"); } else { insurancePayments=0.0; }

        out.print(htmTb.startRow(rowStyle));
        out.print(htmTb.addCell(plusSign, RWHtmlTable.CENTER, "width=\"5%\" id=\"plus"+insRs.getString("id")+"\" onClick=\"showPaymentDetails(this,"+insRs.getString("id")+")\" style=\"cursor: pointer;\""));
        out.print(htmTb.addCell(insRs.getString("name"), "width=\"35%\""));
        out.print(htmTb.addCell(insRs.getString("payments"), RWHtmlTable.CENTER, "width=\"15%\""));
        out.print(htmTb.addCell(Format.formatCurrency(patientPayments), RWHtmlTable.RIGHT, "width=\"15%\""));
        out.print(htmTb.addCell(Format.formatCurrency(paymentAdjustments), RWHtmlTable.RIGHT,"width=\"15%\""));
        out.print(htmTb.addCell(Format.formatCurrency(insurancePayments), RWHtmlTable.RIGHT, "width=\"15%\""));
        out.print(htmTb.endRow());

        if(!printReport) {
            out.print(htmTb.startRow("style=\"background-color: #e0e0e0;\""));
            out.print("<td align=\"center\" id=\"rowId"+insRs.getString("id")+"\" style=\"display: none;\" colspan=\"6\"></td>");
//            out.print(htmTb.addCell("", RWHtmlTable.CENTER, "id=\"rowId"+insRs.getString("id")+"\" style=\"display: none;\" colspan=\"6\""));
            out.print(htmTb.endRow());
        }

        totalInsPtPayments += patientPayments;
        totalInsAdjustments += paymentAdjustments;
        totalInsPayments += insurancePayments;

        currentLine ++;

        if(bgColor.equals("#e0e0e0")) { bgColor="#ffffff"; } else { bgColor="#e0e0e0"; }

        ptPmtRs.close();
        ptPmtRs = null;

        ptAdjRs.close();
        ptAdjRs = null;

        ptInsRs.close();
        ptInsRs = null;
    }

    if(!printReport) {
        out.print(htmTb.endTable());
        out.print("</div>");
        out.print(htmTb.startTable());
    }

    out.print(htmTb.startRow());
    out.print(htmTb.addCell("","width=\"5%\" style=\"border-top: 1px solid black; font-size: 12px; font-weight: bold;\""));
    out.print(htmTb.addCell("Totals", "width=\"35%\" style=\"border-top: 1px solid black; font-size: 12px; font-weight: bold;\""));
    out.print(htmTb.addCell("", RWHtmlTable.CENTER, "width=\"15%\" style=\"border-top: 1px solid black; font-size: 12px; font-weight: bold;\""));
    out.print(htmTb.addCell(Format.formatCurrency(totalInsPtPayments), RWHtmlTable.RIGHT, "width=\"15%\" style=\"border-top: 1px solid black; font-size: 12px; font-weight: bold;\""));
    out.print(htmTb.addCell(Format.formatCurrency(totalInsAdjustments), RWHtmlTable.RIGHT,"width=\"15%\" style=\"border-top: 1px solid black; font-size: 12px; font-weight: bold;\""));
    out.print(htmTb.addCell(Format.formatCurrency(totalInsPayments), RWHtmlTable.RIGHT, "width=\"15%\" style=\"border-top: 1px solid black; font-size: 12px; font-weight: bold;\""));
    out.print(htmTb.endRow());

    out.print(htmTb.endTable());
    ptRs.close();

    if(!printReport) { out.print("</div>\n"); }


%>