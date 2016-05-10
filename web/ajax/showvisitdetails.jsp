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
    int currentSequence = 0;

    if(request.getParameter("detailsOnly") != null) {
        showDetailsOnly=true;
        descWidth="400";
        tableWidth="650";
    }

    String myQuery = "call rwcatalog.prGetVisitDetails('" + io.getLibraryName() + "'," + id + ")";

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
                out.print(htmTb.startRow("style=\"background-color: #cccccc; font-weight: bold;\""));
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
                    out.print(htmTb.addCell("Amount", htmTb.RIGHT, "width=50"));
                    out.print(htmTb.endRow());
                    out.print(htmTb.endTable());
                    out.print(htmTb.endCell());
                    out.print(htmTb.endRow());
                    htmTb.setCellVAlign("top");
                }
                if(dRs.getInt("sequence") == 3) {
                    if(currentSequence != 3) {
                        out.print(htmTb.startRow("style=\"background-color: #606060;\""));
                        out.print(htmTb.addCell("Adjustment Reasons", htmTb.CENTER, "style=\" color: #ffffff;\" colspan=\"4\""));
                        out.print(htmTb.endRow());
                    }
                    out.print(htmTb.startRow("style=\"background-color: #e0e0e0;\""));
                } else {
                    out.print(htmTb.startRow("style=\"background-color: #e0e0e0;\""));
                }
                out.print(htmTb.startCell("colspan=\"4\""));
                out.print(htmTb.startTable());
                out.print(htmTb.startRow());
                out.print(htmTb.addCell("", "width=25"));
                out.print(htmTb.addCell(dRs.getString("paymentdate"), "width=75"));
                out.print(htmTb.addCell(dRs.getString("checknumber"), "width=175"));
                out.print(htmTb.addCell(dRs.getString("name"), "width=175"));
                out.print(htmTb.addCell(Format.formatCurrency(dRs.getDouble("paymentamount")), htmTb.RIGHT, "width=50"));
                out.print(htmTb.endRow());
                out.print(htmTb.endTable());
                out.print(htmTb.endCell());
                out.print(htmTb.endRow());
            }
            chargeId=dRs.getString("id");
            currentSequence = dRs.getInt("sequence");
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
