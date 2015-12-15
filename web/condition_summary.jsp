<%-- 
    Document   : condition_summary
    Created on : Apr 23, 2012, 2:22:23 PM
    Author     : rwandell
--%>
<%@include file="template/pagetop.jsp"%>
<script type="text/javascript">
    function showConditionDetails(what,conditionId) {
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
                var url="ajax/patientcondition.jsp?id="+conditionId+"&report=Y&sid="+Math.random();
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
    RWFilteredList lst = new RWFilteredList(io);
    RWHtmlTable htmTb  = new RWHtmlTable("805", "0");
    RWFieldSet fldSet  = new RWFieldSet();

    String myQuery = "SELECT " +
            "id, '[+]' as expand, description, DATE_FORMAT(fromdate,'%m/%d/%y') as fromdate, DATE_FORMAT(todate,'%m/%d/%y') as todate, DATE_FORMAT(similardate,'%m/%d/%y') as similardate, " +
            "ifnull((SELECT SUM(chargeamount*quantity) FROM charges WHERE visitid IN (SELECT id FROM visits WHERE conditionid=pc.id)),0) as Charges, " +
            "ifnull((SELECT SUM(amount) FROM payments pm left join providers pr on pm.provider=pr.id WHERE pr.reserved and pr.id<>10 and not pr.isadjustment and chargeid in (SELECT id FROM charges WHERE visitid IN (SELECT id FROM visits WHERE conditionid=pc.id))),0) as PatPayments, " +
            "ifnull((SELECT SUM(amount) FROM payments pm left join providers pr on pm.provider=pr.id WHERE pm.provider<>10 and not pr.isadjustment and chargeid in (SELECT id FROM charges WHERE visitid IN (SELECT id FROM visits WHERE conditionid=pc.id))),0) as PayerPayments, " +
            "ifnull((SELECT SUM(amount) FROM payments pm WHERE pm.provider=10 and chargeid in (SELECT id FROM charges WHERE visitid IN (SELECT id FROM visits WHERE conditionid=pc.id))),0) as Writeoff, " +
            "ifnull((SELECT SUM(amount) FROM payments pm left join providers pr on pm.provider=pr.id WHERE pr.isadjustment and chargeid in (SELECT id FROM charges WHERE visitid IN (SELECT id FROM visits WHERE conditionid=pc.id))),0) as Adjustments, " +
            "ifnull((SELECT SUM(chargeamount*quantity) FROM charges WHERE visitid IN (SELECT id FROM visits WHERE conditionid=pc.id)),0)-ifnull((SELECT SUM(amount) FROM payments WHERE chargeid in (SELECT id FROM charges WHERE visitid IN (SELECT id FROM visits WHERE conditionid=pc.id))),0) as balance " +
            "FROM patientconditions pc " +
            "WHERE " +
            "patientid=" + patient.getId() + " " +
            "ORDER BY " +
            "fromdate desc, todate";

    String [] columnWidths = { "0", "50", "150", "75", "75", "75", "75", "75", "75", "75", "75", "75" };
    String [] ch       = {"", "", "Description", "From", "To", "Similar", "Charges", "Patient<br>Payments", "Payer<br>Payments", "Write-Off", "Payer<br>Adjustment", "Balance" };
    
    String url = "conditiondetail.jsp?";

    lst.setTableWidth("750");
    lst.setTableBorder("0");
    lst.setCellPadding("3");
    lst.setRoundedHeadings("#030089", "");
    lst.setAlternatingRowColors("#ffffff", "#cccccc");
    lst.setUrlField(0);
    lst.setNumberOfColumnsForUrl(2);
    lst.setRowUrl(url);
    lst.setShowRowUrl(true);
    lst.setOnClickAction("window.open");
    lst.setOnClickOption("'ConditionSummary','width=1000,height=725,resizable=yes,scrollbars=no,status=no,left=50,top=20,'");
    lst.setOnClickStyle("style='cursor: pointer; color: #2c57a7; font-weight: bold;'");

    lst.setShowColapsableRow(true);
    lst.setColumnForColapsingData(1);
    lst.setOnClickAction(1, "onClick=showConditionDetails(this,##idColumn##) style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    lst.setColapsableRowOptions("style=\"visibility: hidden; display: none;\"");
    
    lst.setShowComboBoxes(false);
    lst.setUseCatalog(true);
    lst.setDivHeight(200);
    lst.setColumnWidth(columnWidths);

    lst.setColumnAlignment(3, "center");
    lst.setColumnAlignment(4, "center");
    lst.setColumnAlignment(5, "center");

    lst.setColumnFormat(6, "MONEY");
    lst.setColumnFormat(7, "MONEY");
    lst.setColumnFormat(8, "MONEY");
    lst.setColumnFormat(9, "MONEY");
    lst.setColumnFormat(10, "MONEY");
    lst.setColumnFormat(11, "MONEY");
    
    lst.setSummaryColunn(6);
    lst.setSummaryColunn(7);
    lst.setSummaryColunn(8);
    lst.setSummaryColunn(9);
    lst.setSummaryColunn(10);
    lst.setSummaryColunn(11);

//    lst.setShowColapsableRow(true);
//    lst.setColumnForColapsingData(1);
//    lst.setOnClickAction(1, "onClick=showVisitDetails(this,##idColumn##) style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
//    lst.setColapsableRowOptions("style=\"visibility: hidden; display: none;\"");

    htmTb.replaceNewLineChar(false);
    int patientId=patient.getId();

    // Show the filtered list
    htmTb.replaceNewLineChar(false);

// Show the visit history
    try {
        out.print(fldSet.getFieldSet(lst.getHtml(myQuery, ch), "style='width: " + lst.getTableWidth() +"'", "Condition Summary" + " for " + patient.getPatientName(), "style='font-size: 12; font-weight: bold;' align=center")+"<br>");
    } catch (Exception e) {
    }

%>
<%@ include file="template/pagebottom.jsp" %>