<style type="text/css">
    .patientHeading { font-size: 11px; font-weight: bold; }
    .pageHeading { font-size: 16px; font-weight: bold; page-break-before: always; }
    .payerHeading { font-size: 14px; font-weight: bold; page-break-before: always; }
    .facilityAddress { font-size: 12px; font-weight: bold; }
    .supplierInfo { font-size: 12px; font-weight: bold; }
</style>
<%
    String providerId = request.getParameter("providerId");
    String showZeroBalances = request.getParameter("showZeroBalances");
    String patientKey = "";
    String providerKey = "";
    String providerName = "";
    String dateKey = "";
    String delinquentDays = request.getParameter("delinquentDays");
    String patientType = request.getParameter("patientType");

    if (showZeroBalances==null) showZeroBalances="false";
    if (providerId==null) providerId="0";
    if (delinquentDays==null) delinquentDays="30";
    boolean zeroBalances = (showZeroBalances.equals("false")) ? false:true;

    // Get a list of providers
    String myQuery="select ifnull(providers.id,'') as providerid, patients.id as patientid, batches.id as batchid, patients.accountnumber, providers.name, concat(patients.firstname, ' ', patients.lastname) as patientname, DATEDIFF(current_date,billed) as daysold, " +
            "  substr(concat(providers.name,' - ',REPLACE(substr(providers.address,1,locate(_latin1'\r',providers.address)-1),'\r\n',''),' - ', " +
            "   case when substr(providers.address,length(providers.address)-4,1)='-' then " +
            "     replace(substr(providers.address,(locate(_latin1'\r',providers.address) + 2),length(providers.address)-10-(locate(_latin1'\r',providers.address) + 2)),'\r\n',' ') " +
            "   else " +
            "     replace(substr(providers.address,(locate(_latin1'\r',providers.address) + 2),length(providers.address)-5-(locate(_latin1'\r',providers.address) + 2)),'\r\n',' ') " +
            "   end),1,55) as headingname, " +
            "patientinsurance.providernumber, patientinsurance.providergroup, batches.billed, batches.lastbilldate, visits.`date` as dateofservice, items.code, case when patients.ssn=0 then '' else patients.ssn end as ssn, patients.dob, providers.phonenumber, providers.extension, " +
            "(charges.chargeamount*charges.quantity)-ifnull((select sum(amount) from payments where chargeid=charges.id),0) AS delinquent " +
            "from batches " +
            "left join batchcharges on batches.id=batchcharges.batchid " +
            "left join charges on charges.id=batchcharges.chargeid " +
            "left join visits on visits.id=charges.visitid " +
            "left join items on items.id=charges.itemid " +
            "left join providers on providers.id=batches.provider " +
            "left join patients on patients.id=visits.patientid " +
            "left join patientinsurance on patientinsurance.patientid=patients.id and patientinsurance.providerid=batches.provider " +
            "where (charges.chargeamount*charges.quantity)-ifnull((select sum(amount) from payments where chargeid=charges.id),0)>0 " +
    //        "and ifnull((select sum(amount) from payments where chargeid=charges.id),0)=0 " +
            "and not complete ";

    if(delinquentDays != null && !delinquentDays.equals("All")) { myQuery += "and DATEDIFF(current_date,billed)>=" + delinquentDays; }
    if(patientType != null && patientType .equals("P")) { myQuery += " and patientinsurance.ispip"; }
    if(patientType != null && patientType .equals("I")) { myQuery += " and !patientinsurance.ispip"; }

    RWConnMgr localIo = new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);

    RWHtmlTable htmTb=new RWHtmlTable("800","0");
    htmTb.replaceNewLineChar(false);

    ArrayList ageItemHeading=new ArrayList();
    ArrayList ageItemMaxDays=new ArrayList();
    ArrayList ageItemMinDays=new ArrayList();
    String providerSQL;
    if (!providerId.equals("0")) {
        myQuery += " and batches.provider = " + providerId;
    }
    myQuery += " order by providers.name, patients.lastname, patients.firstname, batches.id, visits.date, charges.id";
    ResultSet insuranceRs=io.opnRS(myQuery);

    ResultSet agingItemRs=io.opnRS("select * from agingitems order by seq");
    while(agingItemRs.next()) {
        ageItemHeading.add(agingItemRs.getString("description"));
        ageItemMaxDays.add(agingItemRs.getString("maxdays"));
        ageItemMinDays.add(agingItemRs.getString("mindays"));
    }
    ageItemHeading.add("Total");

    double [] patientTotals = new double[ageItemHeading.size()];
    double [] payerTotals = new double[ageItemHeading.size()];
    double [] grandTotals = new double[ageItemHeading.size()];

    Hashtable providers=new Hashtable();

    ResultSet facRs=io.opnRS("SELECT * FROM supplieraddress join facilityaddress on id=0 where providerid=0 ");

    out.print(htmTb.startTable());
    out.print(htmTb.startRow("height=30"));
    out.print(htmTb.addCell("Primary Insurance Aging Report " + Format.formatDate(new java.util.Date(), "MM/dd/yyyy"), htmTb.CENTER, "class='pageHeading' style='font-size: 16; font-weight: bold;'"));
    out.print(htmTb.endRow());

    if(facRs.next()) {
        out.print(htmTb.startRow());
        out.print(htmTb.addCell("<div class=\"facilityAddress\" style=\"float: left;\">" + facRs.getString("facilityname") + "</div><div class=\"supplierInfo\" style=\"float: right;\">TID: " + facRs.getString("taxid") + "&nbsp;&nbsp;</div>" , htmTb.LEFT));
        out.print(htmTb.endRow());
        out.print(htmTb.startRow());
        out.print(htmTb.addCell("<div class=\"facilityAddress\" style=\"float: left;\">" + facRs.getString("supplieraddress") + "</div><div class=\"supplierInfo\" style=\"float: right;\">NPI: " + facRs.getString("providernpi") + "</div>", htmTb.LEFT));
        out.print(htmTb.endRow());
        out.print(htmTb.startRow());
        out.print(htmTb.addCell("<div class=\"facilityAddress\" style=\"float: left;\">" + facRs.getString("suppliercsz") + "</div><div class=\"supplierInfo\" style=\"float: right;\">GRP: " + facRs.getString("practicenpi") + "</div>", htmTb.LEFT));
        out.print(htmTb.endRow());
        out.print(htmTb.startRow("height=20"));
        out.print(htmTb.addCell(""));
        out.print(htmTb.endRow());
    }
    out.print(htmTb.endTable());

    out.print(htmTb.startTable());

    while(insuranceRs.next()) {

        if(!providerKey.equals(insuranceRs.getString("providerid"))) {
            String phoneNumber="";
            if(insuranceRs.getDouble("phonenumber") != 0) { phoneNumber=" - " + tools.utils.Format.formatPhone(insuranceRs.getString("phonenumber")); }
            if(insuranceRs.getInt("extension") !=0) { phoneNumber += " ext: " + insuranceRs.getString("extension"); }
            if(!providerKey.trim().equals("")) {
                //Patient Totals
                htmTb.setCellVAlign("TOP");
                out.print(htmTb.startRow("height=35"));
                out.print(htmTb.startCell(""));
                out.print(htmTb.startTable("80%"));
                out.print(htmTb.startRow());
                out.print(htmTb.addCell("Total", "width=\"75\""));
                out.print(htmTb.addCell("", "width=\"50\""));
                for(int a=0;a<patientTotals.length;a++) {
                    out.print(htmTb.addCell(Format.formatCurrency(patientTotals[a]),RWHtmlTable.RIGHT,"width=\"75\" style=\"border-top: 1px solid black; \""));
                    patientTotals[a]=0;
                }
                out.print(htmTb.endRow());
                out.print(htmTb.endTable());
                out.print(htmTb.endCell());
                out.print(htmTb.endRow());
                htmTb.setCellVAlign("BOTTOM");

                //Payer Totals
                out.print(htmTb.startRow());
                out.print(htmTb.startCell(""));
                out.print(htmTb.startTable("80%"));
                out.print(htmTb.startRow());
                out.print(htmTb.addCell(providerName + " Total", "width=\"125\""));
//                out.print(htmTb.addCell("", "width=\"50\""));
                for(int a=0;a<patientTotals.length;a++) {
                    out.print(htmTb.addCell(Format.formatCurrency(payerTotals[a]),RWHtmlTable.RIGHT,"width=\"75\" style=\"border-top: 1px solid black; \""));
                    payerTotals[a]=0;
                }
                out.print(htmTb.endRow());
                out.print(htmTb.endTable());
                out.print(htmTb.endCell());
                out.print(htmTb.endRow());

                out.print(htmTb.startRow("height=35"));
                out.print(htmTb.addCell(""));
                out.print(htmTb.endRow());
            }

            out.print(htmTb.startRow());
            out.print(htmTb.headingCell(insuranceRs.getString("headingname") + phoneNumber, 0, "class='payerHeading'"));
            out.print(htmTb.endRow());
            out.print(htmTb.startRow());
        }

        if(!patientKey.equals(insuranceRs.getString("batchid")+insuranceRs.getString("patientid")+insuranceRs.getString("dateofservice"))) {
            if(!patientKey.trim().equals("")) {
                if(providerKey.equals(insuranceRs.getString("providerid"))) {
                    out.print(htmTb.startRow());
                    out.print(htmTb.startCell(""));
                    out.print(htmTb.startTable("80%"));
                    out.print(htmTb.startRow());
                    out.print(htmTb.addCell("Total", "width=\"75\""));
                    out.print(htmTb.addCell("", "width=\"50\""));
                    for(int a=0;a<patientTotals.length;a++) {
                        out.print(htmTb.addCell(Format.formatCurrency(patientTotals[a]),RWHtmlTable.RIGHT,"width=\"75\" style=\"border-top: 1px solid black; \""));
                        patientTotals[a]=0;
                    }
                    out.print(htmTb.endRow());
                    out.print(htmTb.endTable());
                    out.print(htmTb.endCell());
                    out.print(htmTb.endRow());

                    out.print(htmTb.startRow("height=15"));
                    out.print(htmTb.addCell(""));
                    out.print(htmTb.endRow());
                }
            }

            out.print(htmTb.startRow());
            out.print(htmTb.startCell(""));
            out.print(htmTb.startTable("70%"));
            out.print(htmTb.startRow());
            out.print(htmTb.addCell(insuranceRs.getString("accountnumber") + " " + insuranceRs.getString("patientname"),"style=\"font-weight: bold;\""));
            out.print(htmTb.addCell("SS: " + insuranceRs.getString("ssn"), "colspan=2 style=\"font-weight: bold;\""));
            out.print(htmTb.endRow());
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("Birth date: " + Format.formatDate(insuranceRs.getString("dob"),"MM/dd/yy"),"width=\"30%\" style=\"font-weight: bold;\""));
            out.print(htmTb.addCell("Policy: " + insuranceRs.getString("providernumber"), " width=\"30%\" style=\"font-weight: bold;\""));
            out.print(htmTb.addCell("Group: " + insuranceRs.getString("providergroup"), " width=\"40%\" style=\"font-weight: bold;\""));
            out.print(htmTb.endRow());
            out.print(htmTb.endTable());
            out.print(htmTb.endCell());
            out.print(htmTb.endRow());

            out.print(htmTb.startRow("height=5"));
            out.print(htmTb.addCell(""));
            out.print(htmTb.endRow());

            out.print(htmTb.startRow());
            out.print(htmTb.startCell(""));
            out.print(htmTb.startTable("100%"));
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("Batch Number: " + insuranceRs.getString("batchid"),"width=\"25%\""));
            out.print(htmTb.addCell("Initial billing Date: " + Format.formatDate(insuranceRs.getString("billed"),"MM/dd/yy"),"width=\"30%\""));
            out.print(htmTb.addCell("Last billing Date: " + Format.formatDate(insuranceRs.getString("lastbilldate"),"MM/dd/yy"),"width=\"45%\""));
            out.print(htmTb.endRow());

            ResultSet batchNotesRs = io.opnRS("select * from billbatchcomments where trim(comments)<>'' and batchid=" + insuranceRs.getString("batchid") + " and patientid=" + insuranceRs.getString("patientid"));
            if(batchNotesRs.next()) {
                out.print(htmTb.startRow());
                out.print(htmTb.addCell("Batch Notes: " + batchNotesRs.getString("comments"),"colspan=\"3\""));
                out.print(htmTb.endRow());
            }
            batchNotesRs.close();
            batchNotesRs = null;

            out.print(htmTb.endTable());
            out.print(htmTb.endCell());
            out.print(htmTb.endRow());

            out.print(htmTb.startRow("height=5"));
            out.print(htmTb.addCell(""));
            out.print(htmTb.endRow());

            htmTb.setCellVAlign("TOP");
            out.print(htmTb.startRow("height=15"));
            out.print(htmTb.startCell(""));
            out.print(htmTb.startTable("80%"));
            out.print(htmTb.startRow("style=\"font-weight: bold;\""));
            out.print(htmTb.addCell("Date","width=\"75\""));
            out.print(htmTb.addCell("Code","width=\"50\""));
            for(int a=0;a<ageItemHeading.size();a++) { out.print(htmTb.addCell((String)ageItemHeading.get(a),RWHtmlTable.RIGHT,"width=\"75\"")); }
            out.print(htmTb.endRow());
            out.print(htmTb.endTable());
            out.print(htmTb.endCell());
            out.print(htmTb.endRow());
            htmTb.setCellVAlign("BOTTOM");
        }

        out.print(htmTb.startRow());
        out.print(htmTb.startCell(""));
        out.print(htmTb.startTable("80%"));
        out.print(htmTb.startRow());
        out.print(htmTb.addCell(Format.formatDate(insuranceRs.getString("dateofservice"),"MM/dd/yy"), "width=\"75\""));
        out.print(htmTb.addCell(insuranceRs.getString("code"), "width=\"50\""));

        for(int a=0;a<ageItemMaxDays.size();a++) {
            int minDays=Integer.parseInt((String)ageItemMinDays.get(a));
            int maxDays=Integer.parseInt((String)ageItemMaxDays.get(a));
            if(insuranceRs.getInt("daysold")>=minDays && insuranceRs.getInt("daysold")<=maxDays ) {
                out.print(htmTb.addCell(Format.formatCurrency(insuranceRs.getString("delinquent")), RWHtmlTable.RIGHT, "width=\"75\""));
                patientTotals[a] += insuranceRs.getDouble("delinquent");
                payerTotals[a] += insuranceRs.getDouble("delinquent");
                grandTotals[a] += insuranceRs.getDouble("delinquent");
            } else {
                out.print(htmTb.addCell("$0.00", RWHtmlTable.RIGHT, "width=\"75\""));
            }
        }
        out.print(htmTb.addCell(Format.formatCurrency(insuranceRs.getString("delinquent")), RWHtmlTable.RIGHT, "width=\"75\""));
        patientTotals[patientTotals.length-1] += insuranceRs.getDouble("delinquent");
        payerTotals[payerTotals.length-1] += insuranceRs.getDouble("delinquent");
        grandTotals[grandTotals.length-1] += insuranceRs.getDouble("delinquent");

        out.print(htmTb.endRow());
        out.print(htmTb.endTable());
        out.print(htmTb.endCell());
        out.print(htmTb.endRow());

        providerName=insuranceRs.getString("name");
        providerKey=insuranceRs.getString("providerid");
        patientKey=insuranceRs.getString("batchid")+insuranceRs.getString("patientid")+insuranceRs.getString("dateofservice");
    }

    //Patient Totals
    if(patientTotals[patientTotals.length-1] != 0) {
        out.print(htmTb.startRow("height=35"));
        out.print(htmTb.startCell(""));
        out.print(htmTb.startTable("80%"));
        out.print(htmTb.startRow());
        out.print(htmTb.addCell("Total", "width=\"75\""));
        out.print(htmTb.addCell("", "width=\"50\""));
        for(int a=0;a<patientTotals.length;a++) {
            out.print(htmTb.addCell(Format.formatCurrency(patientTotals[a]),RWHtmlTable.RIGHT,"width=\"75\" style=\"border-top: 1px solid black; \""));
            patientTotals[a]=0;
        }
        out.print(htmTb.endRow());
        out.print(htmTb.endTable());
        out.print(htmTb.endCell());
        out.print(htmTb.endRow());
    }

    //Payer Totals
    if(payerTotals[payerTotals.length-1] != 0) {
        out.print(htmTb.startRow("height=25"));
        out.print(htmTb.startCell(""));
        out.print(htmTb.startTable("80%"));
        out.print(htmTb.startRow());
        out.print(htmTb.addCell(providerName + " Total", "width=\"125\""));
    //    out.print(htmTb.addCell("", "width=\"50\""));
        for(int a=0;a<patientTotals.length;a++) {
            out.print(htmTb.addCell(Format.formatCurrency(payerTotals[a]),RWHtmlTable.RIGHT,"width=\"75\" style=\"border-top: 1px solid black; \""));
            payerTotals[a]=0;
        }
        out.print(htmTb.endRow());
        out.print(htmTb.endTable());
        out.print(htmTb.endCell());
        out.print(htmTb.endRow());
    }

    out.print(htmTb.endTable());

//    out.print("</div>");

    //Grand Totals
    if(grandTotals[grandTotals.length-1] != 0) {
        out.print(htmTb.startTable());
        out.print(htmTb.startRow("height=35"));
        out.print(htmTb.startCell(""));
        out.print(htmTb.startTable("80%"));
        out.print(htmTb.startRow());
        out.print(htmTb.addCell("<b>Grand Totals</b>", "width=\"75\""));
        out.print(htmTb.addCell("", "width=\"50\""));
        for(int a=0;a<grandTotals.length;a++) {
            out.print(htmTb.addCell("<b>" + Format.formatCurrency(grandTotals[a]) + "</b>",RWHtmlTable.RIGHT,"width=\"75\" style=\"border-top: 1px solid black; \""));
            grandTotals[a]=0;
        }
        out.print(htmTb.endRow());
        out.print(htmTb.endTable());
        out.print(htmTb.endCell());
        out.print(htmTb.endRow());
        out.print(htmTb.startRow("height=35"));
        out.print(htmTb.addCell(""));
        out.print(htmTb.endRow());
        out.print(htmTb.endTable());
    }

    agingItemRs.close();
    insuranceRs.close();

    localIo.getConnection().close();
    localIo=null;
    System.gc();
%>
