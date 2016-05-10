<%-- 
    Document   : aging_body
    Created on : Jul 16, 2012, 12:07:05 PM
    Author     : Randy
--%>
<%
    String printReport = request.getParameter("printReport");
    int currentLine = 100;
    int pageCount = 0;
    int numberOfLinesPerPage = 92;

    if(printReport == null) { 
        out.print(printHeadings(ageItemHeading, htmTb));
        out.print("<div style=\"height: 400; width: 820; overflow: auto;\">");
        out.print(htmTb.startTable());
    }

    int row=0;
    while(insuranceRs.next()) {
        if(printReport != null && currentLine > numberOfLinesPerPage) {
            out.print(htmTb.endTable());
            if(pageCount != 0) { out.print("<p style=\"page-break-after:always;\"></p>"); }
            out.print(printHeadings(ageItemHeading, htmTb));
            out.print(htmTb.startTable("820"));
            currentLine = 8;
            pageCount ++;
        }
        rowColor="#e0e0e0";
        if(!patientKey.equals(insuranceRs.getString("patientname"))) {
            if(!patientKey.trim().equals("")) {
                double doubleRow=Double.parseDouble(""+row);
                if((row/2) == (doubleRow/2)) { rowColor="#cccccc"; }

                String infoLink="onClick=\"showBalanceInfo(event,"+patientId+","+providerKey+",txtHint)\" ";
                out.print(htmTb.startRow());
                out.print(htmTb.startCell(RWHtmlTable.CENTER));
                out.print(htmTb.startTable("80%"));
                out.print(htmTb.startRow());
                out.print(htmTb.addCell("", "width=25 style=\"background-color: " + rowColor + ";\""));
                out.print(htmTb.addCell(patientName, "width=\"125\" style=\"cursor: pointer; font-weight: bold; background-color: " + rowColor + ";\" " + infoLink));
                for(int a=0;a<patientTotals.length;a++) {
                    out.print(htmTb.addCell(Format.formatCurrency(patientTotals[a]),RWHtmlTable.RIGHT,"width=\"75\" style=\"background-color: " + rowColor + ";\" "));
                    patientTotals[a]=0;
                }
                out.print(htmTb.addCell("", "width=25 style=\"background-color: " + rowColor + ";\""));
                out.print(htmTb.endRow());
                out.print(htmTb.endTable());
                out.print(htmTb.endCell());
                out.print(htmTb.endRow());
                row ++;
                currentLine ++;
            }
        }

        for(int a=0;a<ageItemMaxDays.size();a++) {
            int minDays=Integer.parseInt((String)ageItemMinDays.get(a));
            int maxDays=Integer.parseInt((String)ageItemMaxDays.get(a));
            if(insuranceRs.getInt("daysold")>=minDays && insuranceRs.getInt("daysold")<=maxDays ) {
                patientTotals[a] += insuranceRs.getDouble("delinquent");
                payerTotals[a] += insuranceRs.getDouble("delinquent");
                grandTotals[a] += insuranceRs.getDouble("delinquent");
            }
        }

        patientTotals[patientTotals.length-1] += insuranceRs.getDouble("delinquent");
        payerTotals[payerTotals.length-1] += insuranceRs.getDouble("delinquent");
        grandTotals[grandTotals.length-1] += insuranceRs.getDouble("delinquent");

        providerName="";
        patientName=insuranceRs.getString("patientname");
        providerKey="";
        patientId=insuranceRs.getString("patientid");
        patientKey=insuranceRs.getString("patientname");
    }

    //Patient Totals
    if(patientTotals[patientTotals.length-1] != 0) {
        String infoLink="onClick=\"showBalanceInfo(event,"+patientId+","+providerKey+",txtHint)\" ";
        double doubleRow=Double.parseDouble(""+row);
        if((row/2) == (doubleRow/2)) { rowColor="#cccccc"; }

        out.print(htmTb.startRow());
        out.print(htmTb.startCell(RWHtmlTable.CENTER));
        out.print(htmTb.startTable("80%"));
        out.print(htmTb.startRow());
        out.print(htmTb.addCell("", "width=25 style=\"background-color: " + rowColor + ";\""));
        out.print(htmTb.addCell(patientName, "width=\"125\" style=\"cursor: pointer; font-weight: bold; background-color: " + rowColor + ";\" " + infoLink));
        for(int a=0;a<patientTotals.length;a++) {
            out.print(htmTb.addCell(Format.formatCurrency(patientTotals[a]),RWHtmlTable.RIGHT,"width=\"75\" style=\"border-bottom: 1px solid black; background-color: " + rowColor + ";\""));
            patientTotals[a]=0;
        }
        out.print(htmTb.addCell("", "width=25 style=\"background-color: " + rowColor + ";\""));
        out.print(htmTb.endRow());
        out.print(htmTb.endTable());
        out.print(htmTb.endCell());
        out.print(htmTb.endRow());
    }

    out.print(htmTb.endTable());

    if(printReport == null) { out.print("</div>"); }

    //Grand Totals
    if(grandTotals[grandTotals.length-1] != 0) {
        out.print(htmTb.startTable());
        out.print(htmTb.startRow("height=35"));
        out.print(htmTb.startCell(RWHtmlTable.CENTER));
        out.print(htmTb.startTable("80%"));
        out.print(htmTb.startRow());
        out.print(htmTb.addCell("", "width=25"));
        out.print(htmTb.addCell("<b>Grand Totals</b>", "width=\"125\" class=\"grandTotals\""));
        for(int a=0;a<grandTotals.length;a++) {
            out.print(htmTb.addCell("<b>" + Format.formatCurrency(grandTotals[a]) + "</b>",RWHtmlTable.RIGHT,"width=\"75\"  class=\"grandTotals\" style=\"border-top: 1px solid black; \""));
            grandTotals[a]=0;
        }
        out.print(htmTb.addCell("", "width=25"));
        out.print(htmTb.endRow());
        out.print(htmTb.endTable());
        out.print(htmTb.endCell());
        out.print(htmTb.endRow());
        out.print(htmTb.startRow("height=35"));
        out.print(htmTb.addCell(""));
        out.print(htmTb.endRow());
        out.print(htmTb.endTable());
    }

%>
<%! public String printHeadings(ArrayList ageItemHeading, RWHtmlTable htmTb) {
        StringBuffer s = new StringBuffer();
        s.append(htmTb.startTable());
        s.append(htmTb.startRow("height=30"));
        s.append(htmTb.addCell("Accounts Receivable Aging Report", htmTb.CENTER, "style='font-size: 16; font-weight: bold;'"));
        s.append(htmTb.endRow());

        htmTb.setCellVAlign("MIDDLE");
        s.append(htmTb.startRow("height=35"));
        s.append(htmTb.startCell(RWHtmlTable.CENTER));
        s.append(htmTb.startTable("80%"));
        s.append(htmTb.startRow("style=\"font-weight: bold;\""));
        s.append(htmTb.addCell("", "width=25"));
        s.append(htmTb.addCell("Patient Name","width=\"125\""));
        for(int a=0;a<ageItemHeading.size();a++) { s.append(htmTb.addCell((String)ageItemHeading.get(a),RWHtmlTable.RIGHT,"width=\"75\"")); }
        s.append(htmTb.addCell("", "width=25"));
        s.append(htmTb.endRow());
        s.append(htmTb.endTable());
        s.append(htmTb.endCell());
        s.append(htmTb.endRow());

        s.append(htmTb.endTable());

        htmTb.setCellVAlign("BOTTOM");

        return s.toString();
    }
%>