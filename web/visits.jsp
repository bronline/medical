<%@include file="template/pagetop.jsp"%>
<%@include file="/ajax/ajaxstuff.jsp" %>
<script type="text/javascript">
    function addVisit(patientId) {
	location.href="writevisit.jsp?patientId="+patientId;
    }

    function showVisitDetails(what,visitId) {
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
                var url="ajax/showvisitdetails.jsp?detailsOnly=Y&id="+visitId+"&sid="+Math.random();
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

    function openCharges(what, visitId) {
        var url = "ajax/opencharges.jsp?visitId=" + visitId;
        $.ajax({
            url: url,
            success: function (data) {
                alert("Charges have been re-opened.");
                $(what).css('visibility', 'hidden');
                $(what).css('display', 'none');
            },
            complete: function(data){

            },
            error: function() {
                alert("There was a problem processing the request");
            }
        });
    }

    function printReceipt(visitId) {
        window.open("visitreceipt.jsp?visitId="+visitId,"VisitReceipt");
    }
    
    function updateAttentionMessage() {
        var url = "ajax/updateattnmessage.jsp?update=y&attentionmsg=" + $("#attentionmsg").val();
        $.ajax({
            url: url,
            success: function (data) {
                $("#btn1").css("visibility","hidden");
                alert("Attention message has been updated");
            },
            complete: function(data){

            },
            error: function() {
                alert("There was a problem processing the request");
            }
        });        
    }
    
    function checkUpdateButtonVisibility() {
        $("#btn1").css("visibility","visible");
    }
</script>
<%
    try {
        session.setAttribute("returnUrl", "visits.jsp");

// Set up the SQL statement
        if(patient.next()) {
//            String myQuery     = "select id as visitId, date, type from visitsummary where patientId=" + patient.getId() + " order by date desc";
//            String myQuery     = "select id as visitId, Date, Type, ItemCount, Charges, InsPayments, PatPayments, WriteOffs, Balance from patientvisitlist where patientId=" + patient.getId() + " order by date desc";
            String myQuery     =    "select aa.id as visitId, " +
                                                "case when (SELECT COUNT(*) FROM charges WHERE visitid=aa.id)>0 THEN '[+]' ELSE '' END as plussign, " +
                                                "aa.Date, cc.Type, ItemCount, Charges, InsPayments, PatPayments, WriteOffs, " +
						"(charges-inspayments-patpayments-writeoffs) as Balance " +
						"from visits aa " + 
						"left join appointments bb on aa.appointmentid=bb.id left join appointmenttypes cc on bb.type=cc.id " +
						"join (select a.visitid, itemcount,sum(a.chargeamount) as charges, ifnull(sum(b.amount),0) as inspayments, " +
						"ifnull(sum(c.amount),0) as patpayments, ifnull(sum(d.amount),0) as writeoffs " +
						"from chargesbyvisit a " +
						"left join visitpaymentsbyinsurance b on a.visitid=b.visitid " +
						"left join visitpaymentsbypatient c on a.visitid=c.visitid " +
						"left join visitwriteoffs d on a.visitid=d.visitid " +
						"where a.visitid in (select id from visits where patientid=" + patient.getId() + ") " +
						"group by visitid) dd on aa.id=dd.visitid order by aa.Date desc";

            myQuery="select aa.id as visitId, case when ItemCount>0 THEN '[+]' ELSE '' END as plussign, aa.`Date`, IFNULL(cc.`Type`,'Office Visit') AS `Type`, " +
                    "IFNULL(ItemCount,0) AS ItemCount, IFNULL(ItemCharges,0) AS ItemCharges, IFNULL(InsPayments,0) AS InsPayments, IFNULL(PatPayments,0) AS PatPayments, " +
                    "IFNULL(Adjustments,0) AS Adjustments, IFNULL(WriteOffs,0) AS WriteOffs, (IFNULL(ItemCharges,0)-IFNULL(inspayments,0)-IFNULL(patpayments,0)-IFNULL(adjustments,0)-IFNULL(writeoffs,0)) as Balance, " +
                    "concat('<input type=button value=receipt class=button onclick=printReceipt(',aa.id,') style=\"font-size: 8px;\">') as receipt, " +
                    "CASE WHEN completedcharges<>0 THEN concat('<input type=button value=open class=button onClick=openCharges(this,',aa.id,')>') ELSE '' END as reopen " +
                    "from visits aa " +
                    "left join appointments bb on aa.appointmentid=bb.id " +
                    "left join appointmenttypes cc on bb.type=cc.id " +
                    "LEFT JOIN (SELECT visitid, COUNT(*) AS ItemCount, SUM(chargeamount*quantity) AS ItemCharges FROM charges GROUP BY visitid) AS c ON c.visitid=aa.id " +
                    "LEFT JOIN (SELECT v.id AS visitid, SUM(amount) AS Inspayments FROM payments p LEFT JOIN providers pp ON p.provider=pp.id LEFT JOIN charges c ON c.id=p.chargeid LEFT JOIN visits v ON v.id=c.visitid WHERE NOT pp.reserved GROUP BY v.id) AS i ON i.visitid=aa.id " +
                    "LEFT JOIN (SELECT v.id AS visitid, SUM(amount) AS PatPayments FROM payments p LEFT JOIN providers pp ON p.provider=pp.id LEFT JOIN charges c ON c.id=p.chargeid LEFT JOIN visits v ON v.id=c.visitid WHERE (pp.reserved AND pp.id<>10 AND NOT pp.isadjustment) OR pp.id IS NULL GROUP BY v.id) AS pat ON pat.visitid=aa.id " +
                    "LEFT JOIN (SELECT v.id AS visitid, SUM(amount) AS Adjustments FROM payments p LEFT JOIN providers pp ON p.provider=pp.id LEFT JOIN charges c ON c.id=p.chargeid LEFT JOIN visits v ON v.id=c.visitid WHERE pp.reserved AND pp.id<>10 AND pp.isadjustment GROUP BY v.id) AS adj ON adj.visitid=aa.id " +
                    "LEFT JOIN (SELECT v.id AS visitid, SUM(amount) AS WriteOffs FROM payments p LEFT JOIN providers pp ON p.provider=pp.id LEFT JOIN charges c ON c.id=p.chargeid LEFT JOIN visits v ON v.id=c.visitid WHERE pp.reserved AND pp.id=10 GROUP BY v.id) AS wo ON wo.visitid=aa.id " +
                    "LEFT JOIN (select visitid, count(*) as completedcharges from batchcharges left join charges on charges.id=batchcharges.chargeid where complete group by visitid) cc ON cc.visitId=aa.id " +
                    "WHERE aa.patientid=" + patient.getId() + " " +
                    "ORDER BY aa.`date` DESC";

            String url         = "visitactivity.jsp?";
            String title       = "Visits";
            String [] columnWidths = {"25", "0", "80", "120", "50", "80", "80", "80", "80", "80", "80", "50", "50" };
            String [] ch       = {"","", "Date", "Type", "Item Count", "Charges", "Ins. Payments", "Pat. Payments", "Adjustments", "Writeoffs", "Balance","", "" };

        // Create an RWFiltered List object
            RWFilteredList lst = new RWFilteredList(io);
            RWHtmlTable htmTb  = new RWHtmlTable("805", "0");
            RWFieldSet fldSet  = new RWFieldSet();
            RWHtmlForm frm     = new RWHtmlForm();
            RWInputForm attnMsgForm=new RWInputForm(io.opnRS("select id, attentionmsg from patients where id=" + patient.getId()));

        // Set special attributes on the filtered list object
            lst.setTableWidth("805");
            lst.setTableBorder("0");
            lst.setCellPadding("3");
            lst.setRoundedHeadings("#030089", "");
            lst.setAlternatingRowColors("#ffffff", "#cccccc");
    //        lst.setTableHeading(title + " for " + patient.getPatientName());
            lst.setUrlField(0);
            lst.setNumberOfColumnsForUrl(3);
            lst.setRowUrl(url);
            lst.setShowRowUrl(true);
//            lst.setUrlTarget("blank");
            lst.setOnClickAction("window.open");
            lst.setOnClickOption("'VisitActivity','width=1000,height=725,resizable=yes,scrollbars=no,status=no,left=50,top=20,'");
            lst.setOnClickStyle("style='cursor: pointer; color: #2c57a7; font-weight: bold;'");
            lst.setShowComboBoxes(false);
            lst.setUseCatalog(true);
            lst.setDivHeight(200);
            lst.setColumnWidth(columnWidths);

            lst.setColumnFormat(5, "MONEY");
            lst.setColumnFormat(6, "MONEY");
            lst.setColumnFormat(7, "MONEY");
            lst.setColumnFormat(8, "MONEY");
            lst.setColumnFormat(9, "MONEY");
            lst.setColumnFormat(10, "MONEY");

            lst.setSummaryColunn(4);
            lst.setSummaryColunn(5);
            lst.setSummaryColunn(6);
            lst.setSummaryColunn(7);
            lst.setSummaryColunn(8);
            lst.setSummaryColunn(9);
            lst.setSummaryColunn(10);

            lst.setShowColapsableRow(true);
            lst.setColumnForColapsingData(1);
            lst.setOnClickAction(1, "onClick=showVisitDetails(this,##idColumn##) style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
            lst.setColapsableRowOptions("style=\"visibility: hidden; display: none;\"");

            htmTb.replaceNewLineChar(false);
            int patientId=patient.getId();
//            out.print(htmTb.getFrame("#cccccc", getPatientVisitSummary(io, patientId))+"<br>");
            out.print(InfoBubble.getBubble("roundrect", "visitSummaryBubble", "825", "32", "#cccccc", getPatientVisitSummary(io, patientId))+"<br>");
        // Show bubble for patient note type
//            out.print(htmTb.getFrame("#cccccc", getAttnMsgForm(attnMsgForm, htmTb))+"<br>");
            out.print(InfoBubble.getBubble("roundrect", "attentionMessageBubble", "825", "60", "#cccccc", getAttnMsgForm(attnMsgForm, htmTb))+"<br>");

        // Show the filtered list
            htmTb.replaceNewLineChar(false);

        // Show the visit history
            try {
                out.print(fldSet.getFieldSet(lst.getHtml(myQuery, ch), "style='width: " + lst.getTableWidth() +"'", title + " for " + patient.getPatientName(), "style='font-size: 12; font-weight: bold;' align=center")+"<br>");
            } catch (Exception e) {
            }

//            out.print(frm.startForm("action=writevisit.jsp"));
            out.print(frm.button("Add Visit","class=button onClick=addVisit(" + patient.getId() + ")"));
//            out.print(frm.endForm());
        } else {
            out.print("Patient information not set");
 
        }

    } catch (Exception e) {
        out.print(e);
    }
%>
<%! public String getAttnMsgForm(RWInputForm attnForm, RWHtmlTable htmTb) throws Exception {
    /*
        StringBuffer form=new StringBuffer();
        attnForm.setTableWidth("660");
        attnForm.setTableBorder("0");
        attnForm.setAction("updaterecord.jsp?fileName=patients");
        attnForm.setMethod("POST");
        attnForm.lRcd.beforeFirst();
        attnForm.setDftTextAreaCols("110");

        htmTb.setCellVAlign("TOP");
        htmTb.setWidth("700");
        if(attnForm.lRs.next()) {
            form.append("<div align=\"center\">\n");
            form.append(attnForm.startForm());
            form.append(attnForm.hidden(attnForm.lRs.getString("id"), "rcd"));
            form.append(htmTb.startTable());
            form.append(htmTb.startRow());
            form.append(htmTb.addCell("Attention Message: "));
            form.append(htmTb.addCell(attnForm.getInputItemOnly("attentionmsg", "class=tBoxText")));
            form.append(htmTb.addCell(attnForm.submitButton("update", "class=button")));
            form.append(htmTb.endTable());
            form.append(attnForm.endForm());
            form.append("</div>\n");
        }
        return form.toString();
    */
        StringBuffer form=new StringBuffer();
        htmTb.setCellVAlign("TOP");
        htmTb.setWidth("700");
        form.append(htmTb.startTable());
        form.append(htmTb.startRow());
        form.append(htmTb.addCell("Attention Message: "));
        form.append(htmTb.addCell(attnForm.getInputItemOnly("attentionmsg", "style=\"width: 500px; height: 50px;\" class=tBoxText onKeyPress=\"checkUpdateButtonVisibility()\" onBlur=\"updateAttentionMessage()\"")));
        form.append(htmTb.addCell(attnForm.button("update", "class=\"button\" onClick=\"$('#btn1').css('visibility','hidden');\" style=\"visibility: hidden;\"")));
        form.append(htmTb.endTable());
        return form.toString();
    }
%>
<%! public String getPatientVisitSummary(RWConnMgr io, int patientId) throws Exception {
    String myQuery     = "select a.id, " +
                            "ifnull(totalvisits,0) Total, " +
                            "ifnull(yearvisits,0) Year, " +
                            "ifnull(quartervisits,0) Quarter, " +
                            "ifnull(monthvisits,0) Month, " +
                            "ifnull(weekvisits,0) Week, " +
                            "ifnull(planvisits,'NA') Plan " +
                            "from patients a left join " +
                            "(select patientid, count(*) totalvisits from visits group by patientid) b " +
                            "on a.id=b.patientid left join " +
                            "(select patientid, count(*) yearvisits from visits where date > current_date - INTERVAL 1 year " +
                            "group by patientid) c " +
                            "on a.id=c.patientid left join " +
                            "(select patientid, count(*) quartervisits from visits where date > current_date - INTERVAL 3 month " +
                            "group by patientid) d " +
                            "on a.id=d.patientid left join " +
                            "(select patientid, count(*) monthvisits from visits where date > current_date - INTERVAL 1 month " +
                            "group by patientid) e " +
                            "on a.id=e.patientid left join " +
                            "(select patientid, count(*) weekvisits from visits where date > current_date - INTERVAL 1 week " +
                            "group by patientid) f " +
                            "on a.id=f.patientid left join " +
                            "(select a.patientid, count(*) planvisits from patientplan a join visits b on a.patientid=b.patientid " +
                            "where b.date between a.startdate and a.enddate group by a.patientid) g " +
                            "on a.id=g.patientid where a.id=" + patientId;

// Create an RWFiltered List object
    RWFilteredList lst = new RWFilteredList(io);

// Set special attributes on the filtered list object
    String [] cw       = {"0", "50", "50", "50", "50", "50", "50"};

    lst.setColumnWidth(cw);
    lst.setTableWidth("660");
    lst.setTableBorder("0");
    lst.setCellPadding("3");
    lst.setColumnAlignment(1, "center");
    lst.setColumnAlignment(2, "center");
    lst.setColumnAlignment(3, "center");
    lst.setColumnAlignment(4, "center");
    lst.setColumnAlignment(5, "center");
    lst.setColumnAlignment(6, "center");
    lst.setAlternatingRowColors("#ffffff", "#cccccc");
    lst.setUseCatalog(true);
    lst.setShowComboBoxes(false);
// Show the filtered list
    return "<div align=\"center\">\n" + lst.getHtml(myQuery) + "</div>\n";
  }
%>

<%@ include file="template/pagebottom.jsp" %>