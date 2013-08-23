<%-- 
    Document   : deductables
    Created on : Nov 17, 2010, 1:05:09 PM
    Author     : rwandell
--%>
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

    }
    function showReceipt(printOption,detail) {
      windowUrl="printreceipt.jsp?printOption=" + printOption+"&detail="+detail+selectedItems;
      window.open(windowUrl,"statement","address=no,toolbar=yes,scrollbars=yes");
    }

    function showDeductableDetails(what,visitId) {
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
                var url="ajax/getdeductabledetails.jsp?id="+visitId+"&sid="+Math.random();
                $.ajax({
                    url: url,
                    success: function(data){
                        $(obj).html(data);
                    },
                    error: function() {
                        alert("There was a problem processing the request");
                    }
                });
            }
        }
    }
</script>
<%
try {
// Set this as the parent location
    if(patient.next()) {

        String myQuery="SELECT v.id, '' AS blank, '[+]' AS plus, d.batchid, p.name, b.created, IfNULL(b.billed,'') AS billed, v.`date`, YEAR(v.`date`) AS `year`, d.amount " +
                "FROM deductables d " +
                "LEFT JOIN visits v ON v.patientid=d.patientid AND v.`date`=d.`date` " +
                "LEFT JOIN batches b ON b.id=d.batchid " +
                "LEFT JOIN providers p on p.id=b.provider " +
                "WHERE d.patientid=" + patient.getId() + " " +
                "ORDER BY v.`date`";

        myQuery="select aa.id as id,'' as blank, case when ItemCount>0 THEN '[+]' ELSE '' END as plus, DATE_FORMAT(aa.`Date`,'%m/%d/%y') as `date`, " +
                "IFNULL(ItemCount,0) AS ItemCount, IFNULL(ItemCharges,0) AS ItemCharges, IFNULL(InsPayments,0) AS InsPayments, " +
                "IFNULL(PatPayments,0) AS PatPayments, IFNULL(Adjustments,0) AS Adjustments, IFNULL(WriteOffs,0) AS WriteOffs, " +
                "IFNULL(Deductable,0) AS Deductable, (IFNULL(ItemCharges,0)-IFNULL(inspayments,0)-IFNULL(patpayments,0)-IFNULL(adjustments,0)-IFNULL(writeoffs,0)) as Balance " +
                "from visits aa " +
                "LEFT JOIN (SELECT visitid, COUNT(*) AS ItemCount, SUM(chargeamount*quantity) AS ItemCharges FROM charges GROUP BY visitid) AS c ON c.visitid=aa.id " +
                "LEFT JOIN (SELECT v.id AS visitid, SUM(amount) AS Inspayments FROM payments p LEFT JOIN providers pp ON p.provider=pp.id LEFT JOIN charges c ON c.id=p.chargeid LEFT JOIN visits v ON v.id=c.visitid WHERE NOT pp.reserved GROUP BY v.id) AS i ON i.visitid=aa.id " +
                "LEFT JOIN (SELECT v.id AS visitid, SUM(amount) AS PatPayments FROM payments p LEFT JOIN providers pp ON p.provider=pp.id LEFT JOIN charges c ON c.id=p.chargeid LEFT JOIN visits v ON v.id=c.visitid WHERE pp.reserved AND pp.id<>10 AND NOT pp.isadjustment GROUP BY v.id) AS pat ON pat.visitid=aa.id " +
                "LEFT JOIN (SELECT v.id AS visitid, SUM(amount) AS Adjustments FROM payments p LEFT JOIN providers pp ON p.provider=pp.id LEFT JOIN charges c ON c.id=p.chargeid LEFT JOIN visits v ON v.id=c.visitid WHERE pp.reserved AND pp.id<>10 AND pp.isadjustment GROUP BY v.id) AS adj ON adj.visitid=aa.id " +
                "LEFT JOIN (SELECT v.id AS visitid, SUM(amount) AS WriteOffs FROM payments p LEFT JOIN providers pp ON p.provider=pp.id LEFT JOIN charges c ON c.id=p.chargeid LEFT JOIN visits v ON v.id=c.visitid WHERE pp.reserved AND pp.id=10 GROUP BY v.id) AS wo ON wo.visitid=aa.id " +
                "LEFT JOIN (SELECT v.id AS visitid, SUM(amount) AS Deductable FROM visits v LEFT JOIN charges c ON c.visitid=v.id LEFT JOIN eobexceptions ex ON ex.chargeid=c.id LEFT JOIN eobreasons er ON ex.reasonid=er.id WHERE er.`type`='D' GROUP BY v.id) AS dd ON dd.visitid=aa.id " +
                "WHERE aa.patientid=" + patient.getId() + " AND IFNULL(Deductable,0)>0 " +
                "ORDER BY aa.`date` DESC";

        String title = "Deductables";
        String url = "deductable_d.jsp";

    // Create an RWFiltered List object
        RWFilteredList lst = new RWFilteredList(io);
        RWHtmlTable htmTb  = new RWHtmlTable("700", "0");
        RWHtmlForm frm     = new RWHtmlForm();
        RWFieldSet fldSet  = new RWFieldSet();

        htmTb.replaceNewLineChar(false);

    // Set special attributes on the filtered list object
        String [] cw       = {"0", "0", "75", "50", "75", "75", "75", "75", "75", "75", "75", "75"};
        String [] ch       = {"", "", "", "Date<br/>of<br/>Service", "Items", "Charges", "Ins<br/>Payments", "Pat<br/>Payments", "Adjustments", "Write-Off", "Deductable", "Balance" };

        lst.setTableWidth("725");
        lst.setTableBorder("0");
        lst.setCellPadding("0");
        lst.setAlternatingRowColors("#ffffff", "#cccccc");
        lst.setRoundedHeadings("#030089", "");

        lst.setUrlField(0);

        lst.setColumnUrl(2, url, 0);
//        lst.setColumnUrl(3, url, 0);
//        lst.setColumnUrl(4, url, 0);
//        lst.setColumnUrl(5, url, 0);
//        lst.setColumnUrl(6, url, 0);
//        lst.setColumnUrl(7, url, 0);
//        lst.setColumnUrl(8, url, 0);

        lst.setRowUrl(url);
        lst.setShowRowUrl(false);
        lst.setOnClickAction("window.open");
        lst.setOnClickOption("\"" + title + "\",\"width=400,height=250,scrollbars=no,left=100,top=100,\"");
        lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
        lst.setShowComboBoxes(false);
        lst.setUseCatalog(false);
        lst.setDivHeight(250);
        lst.setColumnWidth(cw);
//        for(int z=0;z<9;z++) { lst.setColumnFilterState(z, true); }
//        lst.setColumnFilterState(0, false);
//        lst.setColumnFilterState(1, false);
//        lst.setColumnFilterState(2, false);
//        lst.setColumnFilterState(5, false);
//        lst.setColumnFilterState(6, false);
/*
        lst.setColumnAlignment(3, "CENTER");
        lst.setColumnAlignment(5, "CENTER");
        lst.setColumnAlignment(6, "CENTER");
        lst.setColumnAlignment(7, "CENTER");
        lst.setColumnAlignment(8, "CENTER");
        lst.setColumnAlignment(9, "RIGHT");
*/
        lst.setColumnFormat(5, "MONEY");
        lst.setColumnFormat(6, "MONEY");
        lst.setColumnFormat(7, "MONEY");
        lst.setColumnFormat(8, "MONEY");
        lst.setColumnFormat(9, "MONEY");
        lst.setColumnFormat(10, "MONEY");
        lst.setColumnFormat(11, "MONEY");

        lst.setShowColapsableRow(true);
        lst.setColumnForColapsingData(2);
        lst.setOnClickAction(2, "onClick=showDeductableDetails(this,##idColumn##) style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
        lst.setColapsableRowOptions("style=\"visibility: hidden; display: none;\"");

    // Show the filtered list
        out.print("<title>" + title + "</title>");

//        try {
            out.print("<fieldset style=\"width: 750px; height: 320px;\">\n");
            out.print("<legend style='font-size: 12px; font-weight: bold;' align=center>" + title + " for " + patient.getPatientName() + "</legend>\n");
            out.print(lst.getHtml(request, myQuery, ch));
            out.print("</fieldset>\n");
//        } catch (Exception e) {
//        }
    } else {
        out.print("Patient information not set");
    }


    session.setAttribute("parentLocation", self+"?"+parmsPassed);

} catch (Exception e) {
    out.print(e);
}
%>
<%@ include file="template/pagebottom.jsp" %>