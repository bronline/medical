<%@include file="template/pagetop.jsp" %>
<script>
    function printReceipt(payment) {
        window.open('printreceipt.jsp?printOption=S&chk'+payment+'=Y','Receipt','address=no,toolbar=yes,scrollbars=yes');
    }
</script>
<script>
    selectedItems='';
    function addItemToList(what) {
      if(what.checked) { selectedItems += "&" + what.name + "=Y"; }
      if(!what.checked) {
        fieldName="&"+what.name+"=Y";
        i=selectedItems.indexOf(fieldName);
        j=i+fieldName.length;
        k=selectedItems.length;
        selectedItems=selectedItems.substring(0,i)+selectedItems.substring(j,k);
      }
//      alert(selectedItems);
    }
    function showReceipt(printOption,detail) {
      windowUrl="printreceipt.jsp?printOption=" + printOption+"&detail="+detail+selectedItems;
      window.open(windowUrl,"statement","address=no,toolbar=yes,scrollbars=yes");
    }

    function showPaymentDetails(what,paymentId) {
        var rowId=what.id.substr(3);
        var obj=document.getElementById('rowId'+rowId);

        if(what.innerHTML == "[-]") {
            obj.style.visibility="hidden";
            obj.style.display="none";
            what.innerHTML="[+]"
        } else {
            obj.style.visibility="visible";
            obj.style.display="";
            what.innerHTML="[-]";
            if(obj.innerHTML.trim() == '&nbsp;&nbsp;') {
                var url="ajax/getconditiondetails.jsp?id="+paymentId+"&sid="+Math.random();
                var req = initRequest();
                req.onreadystatechange = function() {
                    if (req.readyState == 4) {
                        if (req.status == 200) {
                            obj.innerHTML=req.responseText;
                        }
                    }
                }
                req.open("GET", url, true);
                req.send(null);
            }
        }
    }
</script>
<%
try {
// Set this as the parent location
    if(patient.next()) {

        String myQuery="select p.id, '' as xx, '[+]' as expand, " +
                "case when p.description='' then p.`condition` else p.`description` end as description, " +
                "DATE_FORMAT(fromdate,'%m/%d/%y') as fromdate, DATE_FORMAT(todate,'%m/%d/%y') as todate, referringdoctor, " +
                "cast(ifnull(sum(c.chargeamount*quantity),0) AS decimal(10,2)) as charges, " +
                "cast(ifnull(sum(pm.amount),0) AS decimal(10,2)) as payments, " +
                "cast(ifnull(sum(c.chargeamount*quantity)-sum(pm.amount),0) AS decimal(10,2)) as balance " +
                "from patientconditions p " +
                "left join visits v on v.conditionid=p.id " +
                "left join charges c on c.visitid=v.id " +
                "left join payments pm on pm.chargeid=c.id " +
                "where p.patientid=" + patient.getId() + " " +
                "group by p.id, p.`condition`";

        String url         = "paymentdetail.jsp?";
        String title       = "Payments";

    // Create an RWFiltered List object
        RWFilteredList lst = new RWFilteredList(io);
        RWHtmlTable htmTb  = new RWHtmlTable("960", "0");
        RWHtmlForm frm     = new RWHtmlForm();
        RWFieldSet fldSet  = new RWFieldSet();

        htmTb.replaceNewLineChar(false);

    // Set special attributes on the filtered list object
        String [] cw       = {"0", "25", "25", "225", "100", "100", "100", "100", "100"};
        String [] ch       = {"", "&nbsp;&nbsp;", "&nbsp;&nbsp;", "Condition", "From Date", "To Date", "Referring Doctor", "Charges", "Payments", "Balance" };

        lst.setTableWidth("775");
        lst.setTableBorder("0");
        lst.setCellPadding("0");
        lst.setAlternatingRowColors("#ffffff", "#cccccc");
        lst.setRoundedHeadings("#030089", "");
        lst.setUrlField(0);
        lst.setColumnUrl(2, url, 0);
        lst.setColumnUrl(3, url, 0);
        lst.setColumnUrl(4, url, 0);
        lst.setColumnUrl(5, url, 0);
        lst.setColumnUrl(6, url, 0);
        lst.setColumnUrl(7, url, 0);
        lst.setColumnUrl(8, url, 0);
        lst.setColumnUrl(9, url, 0);
        lst.setRowUrl(url);
        lst.setShowRowUrl(true);
        lst.setOnClickAction("window.open");
        lst.setOnClickOption("\"" + title + "\",\"width=400,height=250,scrollbars=no,left=100,top=100,\"");
        lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
        lst.setShowComboBoxes(false);
        lst.setUseCatalog(false);
        lst.setDivHeight(300);
        lst.setColumnWidth(cw);

        lst.setColumnAlignment(1, "CENTER");
        lst.setColumnAlignment(2, "CENTER");
        lst.setColumnAlignment(4, "CENTER");
        lst.setColumnAlignment(5, "CENTER");

        lst.setColumnFormat(7, "MONEY");
        lst.setColumnFormat(8, "MONEY");
        lst.setColumnFormat(9, "MONEY");

        lst.setSummaryColunn(7);
        lst.setSummaryColunn(8);
        lst.setSummaryColunn(9);

        lst.setShowColapsableRow(true);
        lst.setColumnForColapsingData(2);
        lst.setOnClickAction(2, "onClick=showPaymentDetails(this,##idColumn##) style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
        lst.setColapsableRowOptions("style=\"visibility: hidden; display: none;\"");

    // Show the filtered list
        out.print("<title>" + title + "</title>");

//        try {
        out.print(fldSet.getFieldSet(lst.getHtml(request, myQuery, ch), "style='width: " + lst.getTableWidth() +"'",  title + " for " + patient.getPatientName(), "style='font-size: 12; font-weight: bold;' align=center"));
//        } catch (Exception e) {
//        }
        out.print("<B>Patient Unapplied Payment Total: " + Format.formatCurrency(patient.getUnappliedPaymentTotal()));

    } else {
        out.print("Patient information not set");
    }


    session.setAttribute("parentLocation", self+"?"+parmsPassed);

} catch (Exception e) {
    out.print(e);
}
%>
<%@ include file="template/pagebottom.jsp" %>