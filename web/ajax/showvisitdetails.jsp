<%-- 
    Document   : showvisitdetails
    Created on : Dec 1, 2010, 1:35:49 PM
    Author     : rwandell
--%>
<%@include file="sessioninfo.jsp" %>
<%
    String id=request.getParameter("id");
    String chargeId = "";
    String descWidth = "250";
    String tableWidth = "500";
    boolean showDetailsOnly=false;

    if(request.getParameter("detailsOnly") != null) {
        showDetailsOnly=true;
        descWidth="400";
        tableWidth="650";
    }

    String myQuery=
            "SELECT " +
            "0 AS sequence, " +
            "charges.id, " +
            "CASE WHEN items.code='' THEN items.description ELSE CONCAT(items.code,' - ', items.description) END AS item, " +
            "charges.quantity, " +
            "charges.chargeamount, " +
            "charges.chargeamount*charges.quantity AS charges, " +
            "CASE WHEN payments.id IS NULL THEN '' ELSE DATE_FORMAT(payments.`date`,'%m/%d/%y') END AS paymentdate, " +
            "CASE WHEN payments.id IS NULL THEN '' ELSE payments.checknumber END AS checknumber, " +
            "CASE WHEN payments.id IS NULL THEN '' ELSE payments.amount END AS paymentamount, " +
            "(charges.chargeamount*charges.quantity)-(SELECT IFNULL(SUM(amount),0) FROM payments WHERE chargeid=charges.id) AS itembalance, " +
            "providers.name " +
            "FROM charges " +
            "LEFT JOIN payments ON charges.id=payments.chargeid " +
            "LEFT JOIN items ON items.id=charges.itemid " +
            "LEFT JOIN providers ON providers.id=payments.provider " +
            "WHERE visitid=" + id + " AND providers.id IS NULL " +
            "UNION " +
            "SELECT " +
            "1 AS sequence, charges.id, " +
            "CASE WHEN items.code='' THEN items.description ELSE CONCAT(items.code,' - ', items.description) END AS item, " +
            "charges.quantity, " +
            "charges.chargeamount, " +
            "charges.chargeamount*charges.quantity AS charges, " +
            "CASE WHEN payments.id IS NULL THEN '' ELSE DATE_FORMAT(payments.`date`,'%m/%d/%y') END AS paymentdate, " +
            "CASE WHEN payments.id IS NULL THEN '' ELSE payments.checknumber END AS checknumber, " +
            "CASE WHEN payments.id IS NULL THEN '' ELSE payments.amount END AS paymentamount, " +
            "(charges.chargeamount*charges.quantity)-(SELECT IFNULL(SUM(amount),0) FROM payments WHERE chargeid=charges.id) AS itembalance, " +
            "providers.name " +
            "FROM charges " +
            "LEFT JOIN payments ON charges.id=payments.chargeid " +
            "LEFT JOIN items ON items.id=charges.itemid " +
            "LEFT JOIN providers ON providers.id=payments.provider " +
            "WHERE visitid=" + id + " AND NOT providers.reserved " +
            "UNION " +
            "SELECT " +
            "2 AS sequence, charges.id, " +
            "CASE WHEN items.code='' THEN items.description ELSE CONCAT(items.code,' - ', items.description) END AS item, " +
            "charges.quantity, " +
            "charges.chargeamount, " +
            "charges.chargeamount*charges.quantity AS charges, " +
            "CASE WHEN payments.id IS NULL THEN '' ELSE DATE_FORMAT(payments.`date`,'%m/%d/%y') END AS paymentdate, " +
            "CASE WHEN payments.id IS NULL THEN '' ELSE payments.checknumber END AS checknumber, " +
            "CASE WHEN payments.id IS NULL THEN '' ELSE payments.amount END AS paymentamount, " +
            "(charges.chargeamount*charges.quantity)-(SELECT IFNULL(SUM(amount),0) FROM payments WHERE chargeid=charges.id) AS itembalance, " +
            "providers.name " +
            "FROM charges " +
            "LEFT JOIN payments ON charges.id=payments.chargeid " +
            "LEFT JOIN items ON items.id=charges.itemid " +
            "LEFT JOIN providers ON providers.id=payments.provider " +
            "WHERE visitid=" + id + " AND providers.reserved " +
            "UNION " +
            "SELECT DISTINCT " +
            "3 AS sequence, charges.id, " +
            "CASE WHEN items.code='' THEN items.description ELSE CONCAT(items.code,' - ', items.description) END AS item, " +
            "charges.quantity, " +
            "charges.chargeamount, " +
            "charges.chargeamount*charges.quantity AS charges, " +
            "CASE WHEN eobexceptions.id IS NULL THEN '' ELSE DATE_FORMAT(eobexceptions.`date`,'%m/%d/%y') END AS paymentdate, " +
            "'' AS checknumber, " +
            "eobexceptions.amount AS paymentamount, " +
            "(charges.chargeamount*charges.quantity)-(SELECT IFNULL(SUM(amount),0) FROM payments WHERE chargeid=charges.id) AS itembalance, " +
            "eobreasons.description AS name " +
            "FROM charges " +
            "LEFT JOIN items ON items.id=charges.itemid " +
            "LEFT JOIN eobexceptions ON charges.id=eobexceptions.chargeid " +
            "LEFT JOIN eobreasons ON eobexceptions.reasonid=eobreasons.id " +
            "WHERE visitid=" + id + " " +
            "AND eobreasons.id IS NOT NULL AND eobreasons.`type`<>'A' " +
            "ORDER BY id, sequence, `paymentdate`, checknumber, name";

    ResultSet dRs=io.opnRS(myQuery);
    ResultSet vRs=io.opnRS("select * from visits where id=" + id);
    RWHtmlTable htmTb=new RWHtmlTable(tableWidth,"0");

    out.print("<div align=\"center\">\n");
    if(vRs.next()) {
        if(!showDetailsOnly) {
            out.print("<v:roundrect style=\"width: 520; height: 160; text-valign: middle; text-align: center;\" arcsize=\".05\">");
            out.print("<div align=\"right\"><b style=\"cursor: pointer;\" onClick=\"showHide(txtHint,'HIDE')\">close</b></div>");
        }
        out.print(htmTb.startTable());
        if(!showDetailsOnly) {
            out.print(htmTb.startRow("style=\"height: 15; font-weight: bold;\""));
            out.print(htmTb.addCell("Date of Service: " + Format.formatDate(vRs.getString("date"), "MM/dd/yy"), "colspan=4"));
            out.print(htmTb.endRow());
        }
        out.print(htmTb.startRow("style=\"font-weight: bold; color: #ffffff; \""));
        out.print(htmTb.addCell("Procedure", " width=" + descWidth));
        out.print(htmTb.addCell("Qty", htmTb.RIGHT, "width=50"));
        out.print(htmTb.addCell("Charges", htmTb.RIGHT, "width=50"));
        out.print(htmTb.addCell("Balance", htmTb.RIGHT, "width=50"));
        out.print(htmTb.endRow());
        out.print(htmTb.endTable());

        if(!showDetailsOnly) { out.print("<div align=\"left\" style=\"width: 520; height: 120; overflow: auto;\">"); }
        out.print(htmTb.startTable());
        while(dRs.next()) {
            if(!chargeId.equals(dRs.getString("id"))) {
                if(!chargeId.equals("") && dRs.getString("name") != null) {
                    out.print(htmTb.startRow("style=\"height: 5; background-color: #e0e0e0\""));
                    out.print(htmTb.addCell("", "colspan=4"));
                    out.print(htmTb.endRow());
                }
                out.print(htmTb.startRow("style=\"background-color: #cccccc;\""));
                out.print(htmTb.addCell(dRs.getString("item"), " width=" + descWidth));
                out.print(htmTb.addCell(""+dRs.getDouble("quantity"), htmTb.RIGHT, "width=50"));
                out.print(htmTb.addCell(Format.formatCurrency(dRs.getDouble("charges")), htmTb.RIGHT, "width=50"));
                out.print(htmTb.addCell(Format.formatCurrency(dRs.getDouble("itembalance")), htmTb.RIGHT, "width=50"));
                out.print(htmTb.endRow());
            }
            if(dRs.getString("name") != null) {
                if(!chargeId.equals(dRs.getString("id"))) {
                    out.print(htmTb.startRow("style=\"background-color: #e0e0e0;\""));
                    out.print(htmTb.startCell("colspan=\"4\""));
                    htmTb.setCellVAlign("bottom");
                    out.print(htmTb.startTable());
                    out.print(htmTb.startRow("style=\"height: 15; font-weight: bold;\""));
                    out.print(htmTb.addCell("", "width=25"));
                    out.print(htmTb.addCell("Date", "width=75"));
                    out.print(htmTb.addCell("Check #", "width=175"));
                    out.print(htmTb.addCell("Payer Name", "width=175"));
                    out.print(htmTb.addCell("Amount", "width=50"));
                    out.print(htmTb.endRow());
                    out.print(htmTb.endTable());
                    out.print(htmTb.endCell());
                    out.print(htmTb.endRow());
                    htmTb.setCellVAlign("top");
                }
                out.print(htmTb.startRow("style=\"background-color: #e0e0e0;\""));
                out.print(htmTb.startCell("colspan=\"4\""));
                out.print(htmTb.startTable());
                out.print(htmTb.startRow());
                out.print(htmTb.addCell("", "width=25"));
                out.print(htmTb.addCell(dRs.getString("paymentdate"), "width=75"));
                out.print(htmTb.addCell(dRs.getString("checknumber"), "width=175"));
                out.print(htmTb.addCell(dRs.getString("name"), "width=175"));
                out.print(htmTb.addCell(Format.formatCurrency(dRs.getDouble("paymentamount")), "width=50"));
                out.print(htmTb.endRow());
                out.print(htmTb.endTable());
                out.print(htmTb.endCell());
                out.print(htmTb.endRow());
            }
            chargeId=dRs.getString("id");
        }
        out.print(htmTb.endTable());
        if(!showDetailsOnly) {
            out.print("</div>\n");
            out.print("</v:roundrect>");
        }
        out.print("<br></div>\n");
    }
    dRs.close();
    vRs.close();
%>
<%@include file="cleanup.jsp" %>
