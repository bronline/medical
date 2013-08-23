<%@include file="template/pagetop.jsp" %>
<%@ page import="java.text.*, tools.utils.Format" %>

<title>Payment Wizard</title>

<script language="javascript">
  function submitForm(action) {
    var frmA=document.forms["frmInput"]
    frmA.method="POST"
    frmA.action=action
    frmA.submit()
  }  
  function openwindow(url, a) {
    var inputItems = document.getElementsByTagName("input");
    var selectedOne='N'

    if (frmInput.checkNumber.value == "") {
      alert("Check Number Must Be Entered");
    } else {
      url = url+ "&checkNumber="+ frmInput.checkNumber.value + "&checkAmount="+ frmInput.checkAmount.value + "&startDate="+ frmInput.startDate.value + "&endDate="+ frmInput.endDate.value + "&paymentDate="+ frmInput.paymentDate.value
      for (var i=0;i<inputItems.length;i++) {
        var e = inputItems[i];
        if (e.type=='checkbox' && !e.disabled) {
          if(e.checked) {
            selectedOne='Y'
            url= url + '&' + e.name;
          }
        }
      }
      if (selectedOne != "Y") {
        alert("Select at least one patient to apply payments for.");
      } else {
//        alert(url);
        window.open(url ,"","width=930,height=530,scrollbars=no,left=100,top=100,");
      }
    }
  }  
</script>

<%
// Initialize local variables
    SimpleDateFormat mdyFormat = new SimpleDateFormat("MM/dd/yyyy");

    String myQuery          = "";
    String whereClause      = "";
    String id               = request.getParameter("id");
    String[] preload={"*UNASSIGNED"};
    String[] preload2={};
    StringBuffer iForm = new StringBuffer();
    
    String startDate = "01/01/1901";
    String endDate = "12/31/2100";
    String paymentDate = Format.formatDate(new java.util.Date(), "MM/dd/yyyy");
    String providerId = "2";
    String checkNumber = "";
    String checkAmount = "0.00";
    String lowDate = "01/01/1901";
    String highDate = "12/31/2100";
    String params="";
    
    Calendar startCal = Calendar.getInstance();
    endDate = mdyFormat.format(startCal.getTime());
    startCal.add(Calendar.DAY_OF_MONTH, -7);
    startDate = mdyFormat.format(startCal.getTime());

    // If parameters were passed, use them
    if (request.getParameter("providerId")!=null) {
        providerId=request.getParameter("providerId");
        params+="&providerId="+providerId;
    }
    if (request.getParameter("checkNumber")!=null) {
        checkNumber=request.getParameter("checkNumber");
        params+="&checkNumber="+checkNumber;
    }
    if (request.getParameter("checkAmount")!=null) {
        checkAmount=request.getParameter("checkAmount");
        params+="&checkAmount="+checkAmount;
    }
    if (request.getParameter("startDate")!=null) {
        startDate=request.getParameter("startDate");
        params+="&startDate="+startDate;
    }
    if (request.getParameter("endDate")!=null) {
        endDate=request.getParameter("endDate");
        params+="&endDate="+endDate;
    }
    if (request.getParameter("paymentDate")!=null) {
        paymentDate=request.getParameter("paymentDate");
        params+="&paymentDate="+paymentDate;
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

String providerQuery="SELECT 0 as providerid, '*All' as name union select id as providerid, substr(concat(name,' - ',REPLACE(substr(address,1,locate(_latin1'\r',address)-1),'\r\n',''),' - '," +
        "    case when substr(providers.address,length(providers.address)-4,1)='-' then" +
        "      replace(substr(address,(locate(_latin1'\r',address) + 2),length(address)-10-(locate(_latin1'\r',address) + 2)),'\r\n',' ')" +
        "    else" +
        "      replace(substr(address,(locate(_latin1'\r',address) + 2),length(address)-5-(locate(_latin1'\r',address) + 2)),'\r\n',' ')" +
        "    end),1,55) as name from providers where not reserved order by name";

// Instantiate result sets for use in the comboboxes
    ResultSet lRs = io.opnRS(providerQuery);

    frm.setDftTextBoxSize("25");
    frm.formItemOnOneRow = false;
    frm.setLabelBold(true);
    frm.setLabelPosition(frm.LABEL_ON_LEFT);
    frm.setUseExternalForm(true);
    frm.setShowDatePicker(true);

    htmTb.setWidth("210");
// Print The Title
    out.print("<H1>Apply Payments Wizard</H1>");
    
// Build the form now
    iForm.append(frm.startForm());
    
// First is the group box containing the insurance provider
    iForm.append("<fieldset style=\"width: 500; border: 1px solid #666; padding: 10px;\"><legend><b>Insurance</b></legend>");
    iForm.append(htmTb.startTable());
    iForm.append(htmTb.startRow());
    iForm.append(htmTb.addCell("<b>Provider"));
    lRs.beforeFirst();
    iForm.append(htmTb.addCell(frm.comboBox(lRs,"providerId","id",false,"1",preload2,providerId,"class=cBoxText onchange=submitForm(\"paymentwizard.jsp\")")));
    iForm.append(htmTb.endRow());
    iForm.append(htmTb.endTable());
    iForm.append("</fieldset>");

// Now, the groupbox with the Payment Info
    iForm.append("<br><fieldset style=\"width: 247; border: 1px solid #666; padding: 10px;\"><legend><b>Payment</b></legend>");
    iForm.append(htmTb.startTable());
    iForm.append(htmTb.startRow());
    iForm.append(htmTb.addCell("<b>Check Number"));
    lRs.beforeFirst();
    iForm.append(htmTb.addCell(frm.textBox(checkNumber, "checkNumber", "15","15","class=tBoxText")));
    iForm.append(htmTb.endRow());

    iForm.append(htmTb.startRow());
    iForm.append(htmTb.addCell("<b>Check Amount"));
    lRs.beforeFirst();
    iForm.append(htmTb.addCell(frm.textBox(checkAmount, "checkAmount", "10","10","class=tBoxText onBlur=\"this.value=formatCurrency(this.value);\"")));
    iForm.append(htmTb.endRow());

    iForm.append(htmTb.startRow());
    iForm.append(htmTb.addCell("<b>Payment Date"));
    lRs.beforeFirst();
    iForm.append(htmTb.addCell(frm.date(paymentDate, "paymentDate", "class=tBoxText")));
    iForm.append(htmTb.endRow());

    iForm.append(htmTb.endTable());
    iForm.append("</fieldset>");

// Now, the groupbox with the Service Dates
    iForm.append("&nbsp;&nbsp;<fieldset style=\"width: 247 ; border: 1px solid #666; padding: 10px;\"><legend><b>Services Performed</b></legend>");
    iForm.append(htmTb.startTable());
    iForm.append(htmTb.startRow());
    iForm.append(htmTb.addCell("<b>Start Date"));
    iForm.append(htmTb.addCell(frm.date(startDate,"startDate","class=tBoxText")));
    iForm.append(htmTb.endRow());

    iForm.append(htmTb.startRow());
    iForm.append(htmTb.addCell("<b>End Date"));
    iForm.append(htmTb.addCell(frm.date(endDate,"endDate","class=tBoxText")));
    iForm.append(htmTb.endRow());

    iForm.append(htmTb.startRow());
    iForm.append(htmTb.addCell(""));
    iForm.append(htmTb.addCell(""));
    iForm.append(htmTb.endRow());

    iForm.append(htmTb.endTable());
    iForm.append("</fieldset>");

    iForm.append("<br>" + frm.button("Get Charges","class=button onclick=submitForm(\"paymentwizard.jsp\")","Filter"));

// Everything we need is inside the form.  Close it up.
    iForm.append(frm.endForm());

// Now, tack on the filtered list containing all patients that may qualify to have their charges paid by this check
//    whereClause = "where a.patientid in (select patientid from patientinsurance where providerid = " + providerId + ") " + 
//                  " and date >= '" + tools.utils.Format.formatDate(startDate, "yyyy-MM-dd") + "' " +
//                  " and date <= '" + tools.utils.Format.formatDate(endDate, "yyyy-MM-dd") + "' ";

//    myQuery     = "select patientId,  cast(sum(visitcharges) as decimal (7, 2)) as Charges, sum(charges) as Items, " +
//                  "lastname as Last, firstname as First, b.name as Provider from visitcharges " + 
//                  "a join providers b on a.providerid=b.id " + whereClause +
//                  " group by patientid, lastname, firstname order by lastname, firstname";

    whereClause = "where providerid = " + providerId + 
                  " and date >= '" + tools.utils.Format.formatDate(startDate, "yyyy-MM-dd") + "' " +
                  " and date <= '" + tools.utils.Format.formatDate(endDate, "yyyy-MM-dd") + "' ";

    myQuery     = "select patientId,  sum(Charges) as Charges, sum(Items) as Items, " +
                  "Last, First, Provider from providerchargesummary " + whereClause + 
                  "group by patientid";

    String url         = "applymultpatpayments.jsp?providerId="+providerId;
    String title       = "";

    lowDate = tools.utils.Format.formatDate(startDate, "yyyy-MM-dd");
    highDate = tools.utils.Format.formatDate(endDate, "yyyy-MM-dd");
    
//    myQuery =   "select zz.*, lastname as Last, firstname as First, name as Provider " +
//                "from (select patientId, sum(chargeamount) as Charges, count(*) as Items from (select a.patientid, a.chargeid, " +
//                "a.chargeamount, ifnull(b.paidamount,0), a.chargeamount-ifnull(b.paidamount,0) as balance from " +
//                "(select bb.patientid, aa.id as chargeid, chargeamount from charges aa join visits bb on aa.visitid=bb.id " +
//                "where date between '" + lowDate + "' and '" + highDate + "' and " +
//                "patientid in (select patientid from patientinsurance where providerid=" + providerId + ")) a " +
//                "left outer join " +
//                "(SELECT chargeid, sum(paidamount) as paidamount FROM paidamounts where patientid in " +
//                "(select patientid from patientinsurance where providerid=" + providerId + ") group by chargeid) b " +
//                "on a.chargeid=b.chargeid ) z where balance > 0 group by patientid) zz " + 
//                "join patients zzz on zz.patientid=zzz.id join patientinsurance zzzz on zzz.id=zzzz.patientid join " +
//                "providers zzzzz on zzzz.providerid=zzzzz.id " + 
//                "where zzzzz.id = " + providerId;
//    myQuery =   "select patientswithbalances.patientId, Charges, Items, lastname as Last, firstname as First , pv.name as Provider from " +
//                "(select patientId, count(chargeid) as items, sum(balance) as charges " +
//                " from " +
//                "(select patientid, chargeid, chargeamount - paidamount as balance from " +
//                "(select a.patientid, c.id as chargeid, c.chargeamount, ifnull(sum(p.amount), 0) paidamount from " +
//                "(select patientid from patientinsurance where providerid=" + providerId + ") a join " +
//                "visits v on a.patientid = v.patientid join " +
//                "charges c on v.id=c.visitid left outer join " +
//                "payments p on " +
//                "c.id = p.chargeid " +
//                "where v.date between '" + lowDate + "' and '" + highDate + "' " +
//                "group by patientid, c.id, chargeamount " +
//                ") allpayments where chargeamount - paidamount > 0) " +
//                "as chargeswithbalances " +
//                "group by patientid) " +
//                "as patientswithbalances " +
//                "join patients p on patientswithbalances.patientid=p.id " +
//                "join patientinsurance pi on p.id=pi.patientid " +
//               "join providers pv on pi.providerid = pv.id " +
//                "where pv.id=" + providerId;
    myQuery =   "select id, concat('<input type=checkbox name=chk', id, ' checked >') as Apply, CONCAT('$',FORMAT(Charges,2)) AS Charges, Items, Last, First, Provider from " +
                "(select e.id, provider as pvid, sum((chargeamount*quantity)-ifnull(paidamount,0)) Charges, count(*) Items, lastname Last, firstname First, f.name Provider, complete " +
                "from batches a join batchcharges b on a.id=b.batchid " +
                "join charges c on b.chargeid = c.id " +
                "join visits d on c.visitid=d.id " +
                "join patients e on d.patientid=e.id " +
                "join providers f on provider=f.id " +
                "left outer join (SELECT patientid, chargeid, sum(amount) paidamount FROM payments p " +
                "group by patientid, chargeid) g on c.id=g.chargeid " +
                "where date between '" + lowDate + "' and '" + highDate + "' " +
                "and provider=" + providerId + " and not complete " +
                "group by e.id, provider, lastname, firstname, f.name) z " +
                "where Charges > 0 " +
                "order by last, first";

    //out.print(myQuery);
// Create an RWFiltered List object
    RWFilteredList lst = new RWFilteredList(io);

// Set special attributes on the filtered list object
    String [] cellWidths = {"0", "40", "60", "50", "150", "150", "150"};
    String [] cellHeadings = { "", "Select", "Charges", "Items", "Last Name", "First Name", "Insurance Provider" };

    lst.setColumnWidth(cellWidths);
    
    lst.setTableWidth("500");
    lst.setTableBorder("0");
    lst.setCellPadding("3");
    lst.setAlternatingRowColors("#ffffff", "#cccccc");
    lst.setRoundedHeadings("#030089", "");
    lst.setTableHeading(title);
    lst.setUrlField(0);
//    lst.setNumberOfColumnsForUrl(2);
//    lst.setRowUrl(url);
    lst.setShowRowUrl(true);
    lst.setOnClickAction("openwindow");
    lst.setOnClickOption("\"a\"");
    lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    lst.setShowComboBoxes(false);
    lst.setUseCatalog(true);
    lst.setDivHeight(140);
    //lst.setShowComboBoxes(true);

// Show the filtered list
    iForm.append(lst.getHtml(myQuery, cellHeadings) );
    
    iForm.append(frm.button("apply payments for selected patients", "class=button onClick=openwindow(\"" + url + "\")" ));
    iForm.append("<input type=button value='invert selection' onClick=invertSelection() class=button>");

// Spit the results out to the browser
    out.print(iForm.toString());
    
// Save the session variables
    if (params.trim().equals("")) {
        session.setAttribute("returnUrl", "paymentwizard.jsp");
        session.setAttribute("myParent", "paymentwizard.jsp");
    } else {
        session.setAttribute("returnUrl", "paymentwizard.jsp?params=true"+params);
        session.setAttribute("myParent", "paymentwizard.jsp?params=true"+params);
    }           
%>
<%@ include file="template/pagebottom.jsp" %>