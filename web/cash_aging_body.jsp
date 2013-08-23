<%-- 
    Document   : cash_aging_body
    Created on : Sep 25, 2012, 11:16:47 AM
    Author     : Randy
--%>

<%

    RWConnMgr localIo = new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", io.MYSQL);

    RWHtmlTable htmTb=new RWHtmlTable("800","0");
    htmTb.replaceNewLineChar(false);

    ArrayList ageItemHeading=new ArrayList();
    ResultSet agingItemRs=io.opnRS("select * from agingitems order by seq");
    while(agingItemRs.next()) {
        ageItemHeading.add(agingItemRs.getString("description"));
    }
    ageItemHeading.add("Total");

    out.print(htmTb.startTable());
    out.print(htmTb.startRow("height=30"));
    out.print(htmTb.addCell("Cash Patients Aging Report", htmTb.CENTER, "style='font-size: 16; font-weight: bold;'"));
    out.print(htmTb.endRow());
    out.print(htmTb.endTable());

    out.print(htmTb.startTable());

    double [] providerTotals=new double[ageItemHeading.size()];
    out.print(htmTb.startRow());
    out.print(htmTb.headingCell("Cash Patients", 0, "style='font-size: 14px;'"));
    out.print(htmTb.endRow());
    out.print(htmTb.startRow());
    out.print(htmTb.addCell(getPatientsForInsurance(zeroBalances, localIo, io, htmTb, 0, agingItemRs, providerTotals, ageItemHeading)));
    out.print(htmTb.endRow());
    out.print(htmTb.startRow("height=35"));
    out.print(htmTb.addCell(""));
    out.print(htmTb.endRow());

    out.print(htmTb.endTable());

    agingItemRs.close();
    localIo.getConnection().close();
    localIo=null;

    System.gc();

%>
<%! public String getPatientsForInsurance(boolean zeroBalances, RWConnMgr localIo, RWConnMgr io, RWHtmlTable htmTb, int providerId, ResultSet agingItemRs, double[] providerTotals, ArrayList ageItemHeading) throws Exception {
        StringBuffer pi=new StringBuffer();

        ResultSet patientRs=io.opnRS("SELECT * from patients p where id not in (select patientid from patientinsurance) order by lastname, firstname");
        pi.append(htmTb.startTable());
        pi.append(htmTb.startRow());
        pi.append(htmTb.addCell("Patient Name", "style='font-size: 12px; border-bottom: 1px solid black;'"));
        for(int t=0;t<ageItemHeading.size();t++) {
            pi.append(htmTb.addCell((String)ageItemHeading.get(t), htmTb.RIGHT, "width=75 style='font-size: 12px; border-bottom: 1px solid black;'"));
        }
        pi.append(htmTb.endRow());

        int row=0;
        while(patientRs.next()) {
            String rowColor="#e0e0e0";
//            int row=patientRs.getRow();
            double doubleRow=Double.parseDouble(""+row);
            if((row/2) == (doubleRow/2)) { rowColor="#f0f0f0"; }
            String agingString = getPatientAging(zeroBalances, localIo, htmTb, providerId, agingItemRs, patientRs, providerTotals, rowColor);
            if (agingString.length()>0) {
                row++;
                pi.append(htmTb.startRow());
                pi.append(htmTb.addCell(patientRs.getString("lastname") + ", " + patientRs.getString("firstname"), "width=150 style='background: " + rowColor + ";'"));
                pi.append(agingString);
                pi.append(htmTb.endRow());
            }
        }
        pi.append(htmTb.startRow());
        pi.append(htmTb.addCell("Cash Totals", "style='font-size: 12px; border-top: 1px solid black;'"));
        for(int t=0;t<providerTotals.length;t++) { pi.append(htmTb.addCell(Format.formatCurrency(providerTotals[t]), htmTb.RIGHT, "width=75 style='font-size: 12px; border-top: 1px solid black;'")); }
        pi.append(htmTb.endRow());
        pi.append(htmTb.endTable());

        patientRs.close();

        return pi.toString();
    }

    public String getPatientAging(boolean zeroBalances, RWConnMgr io, RWHtmlTable htmTb, int providerId, ResultSet ageItemRs, ResultSet patientRs, double[] providerTotals, String rowColor) throws Exception {
        io.getConnection().close();
        io.setConnection(io.opnmySqlConn());

        String baseQuery="select p.id, sum(c.quantity*c.chargeamount) charges, " +
            "sum(ifnull((select sum(amount) from payments where chargeid=c.id),0.00)) payments " +
            "from charges c " +
            "left join visits v on c.visitid=v.id " +
            "left join patients p on p.id=v.patientid ";
        String grouping=" group by p.id";
        StringBuffer pa=new StringBuffer();

        int i=0;
        double patientTotal=0.0;
        ageItemRs.beforeFirst();
        while(ageItemRs.next()) {
            String thisQuery=baseQuery;
            String where=" where p.id=" + patientRs.getString("id");
            if(ageItemRs.getInt("mindays")==0 && ageItemRs.getInt("maxdays") != 0) {
                where += " and v.date>DATE_SUB(CURRENT_DATE, INTERVAL '" + ageItemRs.getInt("maxdays") + "' DAY) ";
            } else if(ageItemRs.getInt("mindays") != 0 && ageItemRs.getInt("maxdays") != 0) {
                where += " and v.date between DATE_SUB(CURRENT_DATE, INTERVAL '" + ageItemRs.getInt("maxdays") + "' DAY) and DATE_SUB(CURRENT_DATE, INTERVAL '" + ageItemRs.getInt("mindays") + "' DAY) ";
            } else if(ageItemRs.getInt("mindays") == 0 && ageItemRs.getInt("maxdays") == 0) {
            }
            thisQuery=thisQuery+where+grouping;

            ResultSet agingRs=io.opnRS(thisQuery);
            if(agingRs.next()) {
                double balance=agingRs.getDouble("charges");
                balance-=agingRs.getDouble("payments");
                pa.append(htmTb.addCell(Format.formatCurrency(balance), htmTb.RIGHT,"width=75 style='background: " + rowColor + "; '"));
                providerTotals[i]+=balance;
                providerTotals[providerTotals.length-1] += balance;
                patientTotal += balance;
            } else {
                pa.append(htmTb.addCell(Format.formatCurrency(0.0), htmTb.RIGHT,"width=75 style='background: " + rowColor + "; '"));
            }
            agingRs.close();
            i++;
        }
        pa.append(htmTb.addCell(Format.formatCurrency(patientTotal), htmTb.RIGHT, "width=75 style='background: " + rowColor + "; '"));
        if (!zeroBalances && patientTotal==0) pa.setLength(0);
        return pa.toString();
    }
%>
