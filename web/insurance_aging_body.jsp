<%--
    Document   : insurance_aging_body
    Created on : Jul 16, 2012, 12:07:05 PM
    Author     : Randy
--%>
<%
    String printReport = request.getParameter("printReport");

    out.print(htmTb.startTable());
    out.print(htmTb.startRow("height=30"));
    out.print(htmTb.addCell("Insurance Provider Aging Report", htmTb.CENTER, "style='font-size: 16; font-weight: bold;'"));
    out.print(htmTb.endRow());
    out.print(htmTb.endTable());

    if(printReport == null) { out.print("<div style=\"height: 400; width: 820; overflow: auto;\">"); }
    out.print(htmTb.startTable());

    int row=0;
    while(insuranceRs.next()) {
        rowColor="#e0e0e0";
        if(!providerKey.equals(insuranceRs.getString("providerid"))) {
            String phoneNumber="";
            if(insuranceRs.getDouble("phonenumber") != 0) { phoneNumber=" - " + tools.utils.Format.formatPhone(insuranceRs.getString("phonenumber")); }
            if(insuranceRs.getInt("extension") !=0) { phoneNumber += " ext: " + insuranceRs.getString("extension"); }
            if(!providerKey.trim().equals("")) {
                //Patient Totals
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
                    out.print(htmTb.addCell(Format.formatCurrency(patientTotals[a]),RWHtmlTable.RIGHT,"width=\"75\" style=\"border-bottom: 1px solid black; background-color: " + rowColor + ";\""));
                    patientTotals[a]=0;
                }
                out.print(htmTb.addCell("", "width=25 style=\"background-color: " + rowColor + ";\""));
                out.print(htmTb.endRow());
                out.print(htmTb.endTable());
                out.print(htmTb.endCell());
                out.print(htmTb.endRow());

                //Payer Totals
                htmTb.setCellVAlign("MIDDLE");
                out.print(htmTb.startRow("height=25"));
                out.print(htmTb.startCell(RWHtmlTable.CENTER));
                out.print(htmTb.startTable("80%"));
                out.print(htmTb.startRow());
                out.print(htmTb.addCell("", "width=25"));
                out.print(htmTb.addCell(providerName + " Total", "width=\"125\" class=\"providerTotals\""));
//                out.print(htmTb.addCell("", "width=\"50\""));
                for(int a=0;a<patientTotals.length;a++) {
                    out.print(htmTb.addCell(Format.formatCurrency(payerTotals[a]),RWHtmlTable.RIGHT,"width=\"75\" class=\"providerTotals\""));
                    payerTotals[a]=0;
                }
                out.print(htmTb.addCell("", "width=25"));
                out.print(htmTb.endRow());
                out.print(htmTb.endTable());
                out.print(htmTb.endCell());
                out.print(htmTb.endRow());
                htmTb.setCellVAlign("BOTTOM");

                out.print(htmTb.startRow("height=35"));
                out.print(htmTb.addCell(""));
                out.print(htmTb.endRow());
            }
            out.print(htmTb.startRow());
            out.print(htmTb.headingCell(insuranceRs.getString("headingname") + phoneNumber, 0, "style='font-size: 14px;umber'"));
            out.print(htmTb.endRow());
            out.print(htmTb.startRow());

            row=0;

            htmTb.setCellVAlign("MIDDLE");
            out.print(htmTb.startRow("height=35"));
            out.print(htmTb.startCell(RWHtmlTable.CENTER));
            out.print(htmTb.startTable("80%"));
            out.print(htmTb.startRow("style=\"font-weight: bold;\""));
            out.print(htmTb.addCell("", "width=25"));
            out.print(htmTb.addCell("Patient Name","width=\"125\""));
            for(int a=0;a<ageItemHeading.size();a++) { out.print(htmTb.addCell((String)ageItemHeading.get(a),RWHtmlTable.RIGHT,"width=\"75\"")); }
            out.print(htmTb.addCell("", "width=25"));
            out.print(htmTb.endRow());
            out.print(htmTb.endTable());
            out.print(htmTb.endCell());
            out.print(htmTb.endRow());
            htmTb.setCellVAlign("BOTTOM");
        }

        if(!patientKey.equals(insuranceRs.getString("providerid")+insuranceRs.getString("patientname"))) {
            if(!patientKey.trim().equals("")) {
                double doubleRow=Double.parseDouble(""+row);
                if((row/2) == (doubleRow/2)) { rowColor="#cccccc"; }

                String infoLink="onClick=\"showBalanceInfo(event,"+patientId+","+providerKey+",txtHint)\" ";
                if(providerKey.equals(insuranceRs.getString("providerid"))) {
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
                }
                row ++;
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

        providerName=insuranceRs.getString("name");
        patientName=insuranceRs.getString("patientname");
        providerKey=insuranceRs.getString("providerid");
        patientId=insuranceRs.getString("patientid");
        patientKey=insuranceRs.getString("providerid")+insuranceRs.getString("patientname");
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

    //Payer Totals
    if(payerTotals[payerTotals.length-1] != 0) {
        htmTb.setCellVAlign("MIDDLE");
        out.print(htmTb.startRow("height=25"));
        out.print(htmTb.startCell(RWHtmlTable.CENTER));
        out.print(htmTb.startTable("80%"));
        out.print(htmTb.startRow());
        out.print(htmTb.addCell("", "width=25"));
        out.print(htmTb.addCell(providerName + " Total", "width=\"125\""));
        for(int a=0;a<patientTotals.length;a++) {
            out.print(htmTb.addCell(Format.formatCurrency(payerTotals[a]),RWHtmlTable.RIGHT,"width=\"75\""));
            payerTotals[a]=0;
        }
        out.print(htmTb.addCell("", "width=25"));
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
