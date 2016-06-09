<%@include file="globalvariables.jsp" %>

<title>Create New Batch</title>

<script language="javascript">
  function submitForm(action) {
//    var isSure = confirm('This Action will reset all changes in the list.  Do you want to continue?');
//    if (isSure==true) {
        var frmA=document.forms["frmInput"]
        frmA.method="POST"
        frmA.action=action
        frmA.submit()
//    }
  }
  function generateBatch(action) {
    var frmA=document.forms["frmInput"]
    frmA.method="POST"
    frmA.action=action
    frmA.submit()
  }
</script>

<%
// Initialize local variables

    int patientId = patient.getId();
    String myQuery          = "";
    String whereClause      = "";
    String id               = request.getParameter("id");
    String batchId          = request.getParameter("batchId");
    String secondaryIns     = request.getParameter("secondary");
    String[] preload={"*UNASSIGNED"};
    String[] preload2={};
    StringBuffer iForm = new StringBuffer();

    String startDate = "";
    String endDate = "";
    String providerId = "2";
    String checkNumber = "00000";
    String checkAmount = "0.00";
    String patientName = "";
    String batchField = "";

    String readOnly = "";

    String baseSQL = "";
    String providerAttributes="";

    if(secondaryIns != null && secondaryIns.equals("Y")) { providerAttributes=" style=\"visibility: hidden;\""; }

// Check to see if the batch id was passed in.  If so, populate the other parameters from the batch
    if(batchId != null && !batchId.equals("0")) {
        String batchQuery="select provider,visits.patientid," +
                          "DATE_FORMAT(min(visits.`date`), '%m/%d/%Y') as startdate, " +
                          "DATE_FORMAT(max(visits.`date`), '%m/%d/%Y') as enddate " +
                          "from batches " +
                          "join batchcharges on batches.id=batchcharges.batchid " +
                          "join charges on charges.id=batchcharges.chargeid " +
                          "join visits on charges.visitid=visits.id " +
                          "where patientid=" + patientId +
                          " group by provider, patientid";

        ResultSet bRs=io.opnRS(batchQuery);
        if(bRs.next()) {
            startDate=bRs.getString("startDate");
            endDate=bRs.getString("endDate");
            batchField="<input type=hidden name=batchId value=" + batchId + ">";
        }
    }

// If parameters were passed, use them
    if (request.getParameter("providerId")!=null) {
        providerId=request.getParameter("providerId");
    }
    if (request.getParameter("patientId")!=null) {
        patientId=Integer.parseInt(request.getParameter("patientId"));
    }
    if (request.getParameter("startDate")!=null) {
        startDate=request.getParameter("startDate");
    }
    if (request.getParameter("endDate")!=null) {
        endDate=request.getParameter("endDate");
    }

    if(startDate.equals("")) {
//        ResultSet lRs=io.opnRS("select DATE_FORMAT(DATE_ADD(current_date, INTERVAL -8 DAY), '%m/%d/%Y') as startDate");
        ResultSet lRs=io.opnRS("select DATE_FORMAT(MIN(v.`date`),'%m/%d/%Y') as startdate from charges c left join visits v on v.id=c.visitid where c.id not in (select chargeid from batchcharges)");
        if(lRs.next()) { startDate=lRs.getString("startdate"); }
        lRs.close();
    }

    if(endDate.equals("")) {
        ResultSet lRs=io.opnRS("select DATE_FORMAT(current_date-1, '%m/%d/%Y') as endDate");
        if(lRs.next()) { endDate=lRs.getString("enddate"); }
        lRs.close();
    }

// Instantiate a table and a form
    RWHtmlTable htmTb = new RWHtmlTable("300", "0");
    htmTb.replaceNewLineChar(false);
    htmTb.setWidth("210");

    RWInputForm frm = new RWInputForm();
    frm.setShowDatePicker(true);
    frm.setDftTextBoxSize("25");
    frm.formItemOnOneRow = false;
    frm.setLabelBold(true);
    frm.setLabelPosition(frm.LABEL_ON_LEFT);
    frm.setUseExternalForm(true);

    frm.setDftTextBoxSize("25");
    frm.formItemOnOneRow = false;
    frm.setLabelBold(true);
    frm.setLabelPosition(frm.LABEL_ON_LEFT);
    frm.setUseExternalForm(true);
    frm.setShowDatePicker(true);

    htmTb.setWidth("600");

// Set the SQL statements for the insurance providers and patients
    String insQuery="select 0 as prid, '*ALL' as name union " +
            "select id as providerid, " +
            "substr(concat(name,' - ',REPLACE(substr(address,1,locate(_latin1'\r',address)-1),'\r\n',''),' - ', " +
            "case when substr(providers.address,length(providers.address)-4,1)='-' then " +
            "replace(substr(address,(locate(_latin1'\r',address) + 1),length(address)-10-(locate(_latin1'\r',address) + 2)),'\r\n',' ') " +
            "else " +
            "replace(substr(address,(locate(_latin1'\r',address) + 1),length(address)-5-(locate(_latin1'\r',address) + 2)),'\r\n',' ') " +
            "end),1,55) as name " +
            "from providers " +
            "where not reserved ";

    String patQuery="select 0 as paid, '*ALL' as name union " +
            "select patients.id as paid, concat(lastname, ' ', firstname) name from patients " +
            "left join patientinsurance on patientinsurance.patientid=patients.id " +
            "where lastname<>'' and insuranceactive and patientinsurance.active order by name";

// Check to see if patient or insurance provider is selected
    if((request.getParameter("patientId") != null && !request.getParameter("patientId").equals("0")) || secondaryIns != null) {
        insQuery += " and id in(select providerid from patientinsurance where patientid=" + patientId + " and active";
        if(secondaryIns != null) {
            int unionPosition=insQuery.indexOf("union");
            insQuery = insQuery.substring(unionPosition + 6);
            insQuery += " and not primaryprovider";
        }
        insQuery += ")";
        patQuery="select id as paid, concat(lastname, ' ', firstname) name from patients where lastname<>'' and id=" + patientId + " order by name";

        readOnly = " READONLY";
    } else if(request.getParameter("providerId") != null && !request.getParameter("providerId").equals("0")) {
        insQuery+=" and id=" + providerId;
        patQuery="select 0 as paid, '*ALL' as name union select id as paid, concat(lastname, ' ', firstname) name from patients where lastname<>'' and id in (select patientid from patientinsurance where providerid=" + providerId + ") order by name";
    }

    // Instantiate result sets for use in the comboboxes
    insQuery += " order by name";


    ResultSet lRs = io.opnRS(insQuery);
    ResultSet patRs = io.opnRS(patQuery);

// Print The Title
    patient.setId(patientId);
    patient.beforeFirst();
    if (patient.next()) {
        patientName = patient.getString("firstname") + " " + patient.getString("lastname") ;
    }

    out.print("<H1>Create New Billing Batch</H1>");

// Build the form now
    iForm.append(frm.startForm());

// If the batch id was passed in, we are submitting suplemental insurance so we need to retain the batch id
    iForm.append(batchField);

// Now, the groupbox with the Service Dates
    iForm.append("<fieldset style=\"width: 650 ; border: 1px solid #666; padding: 10px;\"><legend><b>Include Charges</b></legend>");
    iForm.append(htmTb.startTable());

    iForm.append(htmTb.startRow());
    iForm.append(htmTb.addCell("<b>Payer</b>"));
    lRs.beforeFirst();
    iForm.append(htmTb.addCell(frm.comboBox(lRs,"providerId","prid",false,"1",preload2,providerId,"class=cBoxText onchange=submitForm(\"billing.jsp\")")));
    iForm.append(htmTb.addCell("<b>Patient"));
    patRs.beforeFirst();
    iForm.append(htmTb.addCell(frm.comboBox(patRs,"patientId","paid",false,"1",preload2,""+patientId,"class=cBoxText onchange=submitForm(\"billing.jsp\")")));
    iForm.append(htmTb.endRow());

    iForm.append(htmTb.startRow());
    iForm.append(htmTb.addCell("<b>Start Date"));
    iForm.append(htmTb.addCell(frm.date(startDate,"startDate","class=tBoxText" + readOnly)));
    iForm.append(htmTb.addCell("<b>End Date"));
    iForm.append(htmTb.addCell(frm.date(endDate,"endDate","class=tBoxText" + readOnly)));
    iForm.append(htmTb.endRow());

    iForm.append(htmTb.endTable());
    iForm.append("</fieldset>");

    if(secondaryIns == null) {
        iForm.append("<br><br>" + frm.button("Get Charges","class=button onclick=submitForm(\"billing.jsp\")","Filter") + "<br><br>");
    } else {
        iForm.append("<br><br>" + frm.button("Get Charges","class=button onclick=submitForm(\"billing.jsp?secondary=Y\")","Filter") + "<br><br>");
    }

// Now, the hidden stuff
    if(!providerId.equals("0")) { iForm.append(frm.hidden(providerId,"providerId")); }
    iForm.append(frm.hidden(checkNumber,"checkNumber"));
    iForm.append(frm.hidden(checkAmount,"checkAmount"));

// Set up the base SQL
    baseSQL = "select" +
            "    c.id as patientid," +
            "    substr(concat(name,' - ',REPLACE(substr(e.address,1,locate(_latin1'\r',e.address)-1),'\r\n',''),' - ', case when substr(e.address,length(e.address)-4,1)='-' then replace(substr(e.address,(locate(_latin1'\r',e.address) + 1),length(e.address)-10-(locate(_latin1'\r',e.address) + 2)),'\r\n',' ') else replace(substr(e.address,(locate(_latin1'\r',e.address) + 1),length(e.address)-5-(locate(_latin1'\r',e.address) + 2)),'\r\n',' ') end),1,55) as name," +
            "    CASE WHEN pi.hicfaassignment<>0 THEN CASE WHEN pi.hicfaassignment=2 THEN 0 ELSE 1 END ELSE CASE WHEN e.assignment=0 THEN 2 ELSE 1 END  END as assignment, " +
            "    a.itemid," +
            "    a.id," +
            "    b.date," +
            "    d.description," +
            "    a.chargeamount*a.quantity as chargeamount," +
            "    concat(lastname,', ',firstname) patient," +
            "    ifnull(sum(p.amount),0) paidamount," +
            "    cast((a.chargeamount*a.quantity)-ifnull(sum(p.amount),0) as decimal(6, 2)) balance," +
            "    CASE WHEN pc.providerid IS NULL OR pc.providerid=0 THEN e.id ELSE pc.providerid END as providerid," +
            "    e.name as provider " +
            "from charges a " +
            "left join items d on a.itemid=d.id " +
            "left join visits b on a.visitid=b.id " +
            "left join patientconditions pc on b.conditionid=pc.id " +
            "left join patients c on b.patientid=c.id " +
            "left join payments p on a.id=p.chargeid " +
//            "join (select * from patientinsurance where primaryprovider=1 and active) d on c.id=d.patientid " +
            "join patientinsurance pi on c.id=pi.patientid and pi.primaryprovider=1 and pi.active and pi.verified " +
            "left join providers e on e.id=(CASE WHEN pc.providerid=0 THEN pi.providerid ELSE pc.providerid END) " +
            "where " +
            "  not exists (select id from batchcharges where chargeid=a.id)" +
            "  and c.insuranceactive" +
            "  and d.billinsurance" +
            "  and b.date between (CASE WHEN pi.insuranceeffective='0001-01-01' THEN e.effectivedate ELSE pi.insuranceeffective END) and '" + Format.formatDate(endDate, "yyyy-MM-dd") + "' " +
            "group by a.itemid, a.id, b.date, d.description, a.chargeamount, concat(lastname,', ',firstname) ";

// Now, tack on the filtered list containing all patients that may qualify to have their charges paid by this check
    whereClause = "where not exists (select id from batchcharges where chargeid=a.id) and c.insuranceactive ";
    whereClause = "where (balance<>0 or (balance=0 and assignment=0)) ";

    if (patientId>0) {
        whereClause += " and patientid=" + patientId;
    }
    if ((batchId == null || batchId.equals("0")) && !providerId.equals("0")) {
        whereClause += " and patientId in (select patientid from patientinsurance where primaryprovider=1 and providerid=" + providerId + " and active) ";
    }

    whereClause += " and date between '" + Format.formatDate(startDate, "yyyy-MM-dd") + "' and '" + Format.formatDate(endDate, "yyyy-MM-dd") + "' ";

    myQuery = "select * from (" +
            baseSQL +
            ") f " + whereClause +
            " order by date, description";

    if(batchId != null && !batchId.equals("0")) {
        myQuery = "select * from " +
                  "(select a.itemid,a.id,visits.date,d.description,a.chargeamount,concat(lastname,', ',firstname) patient,ifnull(sum(p.amount),0) paidamount,cast(a.chargeamount-ifnull(sum(p.amount),0) as decimal(6, 2)) balance " +
                  "from batchcharges " +
                  "join charges a on batchcharges.chargeid=a.id " +
                  "join items d on a.itemid=d.id " +
                  "join visits on a.visitid=visits.id " +
                  "join patients c on visits.patientid=c.id " +
                  "left outer join payments p on a.id=p.chargeid " +
                  "where c.insuranceactive and visits.patientId=" + patientId +
                  " group by a.itemid, a.id, visits.date, d.description, a.chargeamount, concat(lastname,', ',firstname) ) e " +
//                  "where balance <> 0 " +
			"where date between '" + Format.formatDate(startDate, "yyyy-MM-dd") + "' and '" + Format.formatDate(endDate, "yyyy-MM-dd") + "' " +
                  " order by `date`, description";
    }

    String url         = "billing.jsp?checkNumber="+checkNumber+"&checkAmount="+checkAmount+"&startDate="+startDate+"&endDate="+endDate;
    String title       = "";

    if ((patientId==0 && providerId.equals("0"))) {

        myQuery = "CALL rwcatalog.prGetBillingByPayer('" + databaseName + "', " + patientId + ", " + providerId + ", '" + Format.formatDate(startDate, "yyyy-MM-dd") + "','" + Format.formatDate(endDate, "yyyy-MM-dd") + "')";
    // out.print(myQuery);
    // Create an RWFiltered List object
        RWFilteredList lst = new RWFilteredList(io);

    // Set special attributes on the filtered list object
        lst.setTableWidth("700");
        lst.setTableBorder("0");
        lst.setCellPadding("3");
        lst.setAlternatingRowColors("#ffffff", "#cccccc");
        lst.setRoundedHeadings("#030089", "");
        // Set specific column widths
        String [] cellWidths = {"0", "50", "420", "100", "100"};
        String [] cellHeadings = { "", "Select", "Payer", "Charges", "Amount" };
        lst.setColumnWidth(cellWidths);
        lst.setShowComboBoxes(false);
        lst.setUseCatalog(true);
        lst.setDivHeight(250);

        htmTb.replaceNewLineChar(false);
        iForm.append(lst.getHtml(myQuery, cellHeadings));
        iForm.append(frm.button("Generate Batches","class=button onclick=generateBatch(\"generatebatches.jsp\")","Filter"));
        iForm.append("<input type=button value='invert selection' onClick=invertSelection() class=button>");

    } else {

        myQuery = "CALL rwcatalog.prGetChargesForBillingBatch('" + databaseName + "', " + patientId + ", " + providerId + ", '" + Format.formatDate(startDate, "yyyy-MM-dd") + "','" + Format.formatDate(endDate, "yyyy-MM-dd") + "')";

        htmTb.setWidth("650");
        RWInputForm pFrm = new RWInputForm();
        pFrm.setFormName("billing");

        ResultSet pRs = io.opnRS(myQuery);
        iForm.append("<table><tr><td align=left>");
        iForm.append(htmTb.startTable());
        iForm.append(htmTb.startRow());
        iForm.append(htmTb.headingCell("Date", "width=50"));
        iForm.append(htmTb.headingCell("Patient", "width=150"));
        iForm.append(htmTb.headingCell("Description", "width=150"));
        iForm.append(htmTb.headingCell("Charge Amount", "width=50"));
        iForm.append(htmTb.headingCell("Paid Amount", "width=50"));
        iForm.append(htmTb.headingCell("Balance", "width=50"));
        iForm.append(htmTb.endRow());
        iForm.append(htmTb.endTable());

        String chargeId="0";
        iForm.append("<div style=\" height: 200; width: 668; overflow: auto;\">");
        iForm.append(htmTb.startTable());
        String rowColor="lightgrey";
        //BigDecimal bDDefaultPayment;
        //String defaultPayment;
        long balance;
        while (pRs.next()) {
            chargeId=pRs.getString("id");
            iForm.append(htmTb.startRow("bgcolor="+rowColor));
            iForm.append(htmTb.addCell(pRs.getString("date"), "width=50"));
            iForm.append(htmTb.addCell(pRs.getString("patient"), "width=150"));
            iForm.append(htmTb.addCell(pRs.getString("description"), "width=150"));
            iForm.append(htmTb.addCell(pRs.getString("chargeamount"), 1, "width=50"));
            iForm.append(htmTb.addCell(pRs.getString("paidamount"), 1, "width=50"));
            iForm.append(htmTb.addCell(pRs.getString("balance"), 1, "width=50"));
            iForm.append(frm.hidden("","chargeid"+chargeId));
            iForm.append(htmTb.endRow());
            if (rowColor.equals("lightgrey")) {
                rowColor="#cccccc";
            } else {
                rowColor="lightgrey";
            }
            // Hidden Date Field
            iForm.append(frm.hidden(Format.formatDate(new java.util.Date(),"yyyy-MM-dd"), "date"+chargeId));

        }
        iForm.append(htmTb.endTable());
        iForm.append("</div>");

        String providerSQL = "";
        if(request.getParameter("secondary") != null) {
            providerSQL = "SELECT providerid FROM patientinsurance WHERE not primaryprovider and patientid=" + patientId + " limit 1";
        } else {
            providerSQL = "SELECT providerid FROM patientinsurance WHERE primaryprovider and verified and active and patientid=" + patientId + " limit 1";
        }
        ResultSet patInsRs=io.opnRS(providerSQL);
        if(patInsRs.next()) { providerId=patInsRs.getString("providerid"); }
        patInsRs.close();
        patInsRs = null;

        String isSecondary="";
        if(request.getParameter("secondary") != null) { isSecondary="&secondary=Y"; }

        iForm.append("</td></tr></table><br>");

    // Everything we need is inside the form.  Close it up.
        iForm.append(frm.endForm());
        iForm.append(frm.button("Generate Batch","class=button onclick=generateBatch(\"generatebatch.jsp?providerId=" + providerId + isSecondary + "\")","Filter"));

    }

// Spit the results out to the browser
    out.print(htmTb.getFrame("white", iForm.toString()))    ;

// Save the session variables
    session.setAttribute("returnUrl", "");
%>

