<%@include file="template/pagetop.jsp" %>
<%@include file="ajax/ajaxstuff.jsp" %>
<style>
    .cBoxText { font-size: 9px; }
</style>
<script>
    selectedItems='';
    function addItemToList(what) {
//      if(what.checked) { selectedItems += "&" + what.name + "=Y"; }
//      if(!what.checked) {
//        fieldName="&"+what.name+"=Y";
//        i=selectedItems.indexOf(fieldName);
//        j=i+fieldName.length;
//        k=selectedItems.length;
//        selectedItems=selectedItems.substring(0,i)+selectedItems.substring(j,k);
//      }
//      alert(selectedItems);
    }
    function showStatement(printOption) {
      getSelectedItems();
      windowUrl="patientstatement.jsp?printOption=" + printOption+selectedItems;
      window.open(windowUrl,"statement","address=no,toolbar=yes,scrollbars=yes");
    }

    function showPIPLedger() {
        getSelectedItems();
        windowUrl="pipledger.jsp?printOption=L" + selectedItems;
        window.open(windowUrl,"statement","address=no,toolbar=yes,scrollbars=yes");
    }

    function addNewCharge() {
      window.open("misccharge.jsp","MiscCharge","width=375,height=200");
    }

    function getSelectedItems() {
      selectedItems='';
      var checkedBoxes='';
      var inputItems = document.getElementsByTagName("input");
      for (var i=0;i<inputItems.length;i++) {
        var e = inputItems[i];
        if (e.type=='checkbox' && !e.disabled) {
          if(e.checked) {
            selectedItems += "&" + e.name + "=Y";
          }
        }
      }

    }
    function showNote(chargeId) {
        $('#txtHint').html('');
        var url="ajax/showchargecomment.jsp?id=" + chargeId; // + "&sid="+Math.random();
alert(url);
        $.ajax({
            url: url,
            success: function(data){
                $('#txtHint').html(data);
                ajaxComplete=true;
                showHide(txtHint,'SHOW');
                setDivPosition(e,txtHint);
                showHide(txtHint,'SHOW');
            },
            error: function() {
                alert("There was a problem processing the request");
            }
        });
    }
</script>
<%
try {
// Set this as the parent location
    if(patient.next()) {

/*
         String myQuery     = "select patientbalance.id,concat('<input type=checkbox onClick=addItemToList(this) name=chk',patientbalance.id,'>') as chkbox, " +
                             "DATE_FORMAT(date, '%m/%d/%Y')as chargedate, " +
                             "description,chargeamount,paidamount,balance,ifnull(batchid,'N/A') as batchid " +
                             "from patientbalance " +
                             "left join batchcharges on batchcharges.chargeid=patientbalance.id " +
                             "where patientId=" + patient.getId() + " order by date desc";
*/

        String myQuery     = "select b.id, concat('<input type=checkbox onClick=addItemToList(this) name=chk',b.id,'>') as chkbox, " +
                                "DATE_FORMAT(a.date, '%m/%d/%Y')as chargedate, description, " +
                                "case when comments is null or trim(comments)='' then '' else concat('<img src=\"/medicaldocs/notepad.png\" height=\"15\" onClick=\"showNote(',b.id,')\" style=\"cursor: pointer;\">') end as notepad," +
                                "FORMAT(quantity,2) AS quantity, " +
                                "quantity*ifnull(chargeamount,0) chargeamount, ifnull(paidamount,0) paidamount, ifnull(writeoffamount,0) writeoffamount, " +
                                "ifnull(deductables,0) as deductables, " +
                                "(quantity*chargeamount)-ifnull(paidamount,0)-ifnull(writeoffamount,0) as balance, ifnull(batchid,'N/A') as batchid  " +
                                " from visits a join charges b on a.id=b.visitid " +
                                "left join " +
                                "(select chargeid, count(*) as payments, sum(amount) as paidamount from payments where provider<>10 group by chargeid)  pmts on b.id=pmts.chargeid " +
                                "left join " +
                                "(select chargeid, count(*) as payments, sum(amount) as writeoffamount from payments where provider=10 group by chargeid)  writeoffs on b.id=writeoffs.chargeid " +
                                "left join items on b.itemid=items.id " +
                                "left join " +
                                "(SELECT max(batches.id) batchid, batchcharges.chargeid FROM " +
                                "batches join batchcharges on batches.id=batchcharges.batchid join charges on batchcharges.chargeid=charges.id " +
                                "join visits on charges.visitid=visits.id join patientinsurance on visits.patientid=patientinsurance.patientid where " +
                                "primaryprovider=1 group by batchcharges.chargeid) " +
                                "ZZ " +
                                "on ZZ.chargeid=b.id " +
                                "left join " +
                                "(select chargeid, SUM(amount) as deductables from eobexceptions left join eobreasons on reasonid=eobreasons.id where `type`='D' group by chargeid) eob on b.id=eob.chargeid " +
                                "where patientId=" + patient.getId() + " order by date desc, b.id";

        String url         = "chargedetail.jsp?";
        String title       = "Charges";

        out.print("<title>" + title + "</title>");

    // Create an RWFiltered List object
        RWFilteredList lst = new RWFilteredList(io);
        RWHtmlTable htmTb  = new RWHtmlTable("650", "0");
        RWFieldSet fldSet  = new RWFieldSet();

        htmTb.replaceNewLineChar(false);

    // Set special attributes on the filtered list object
        String [] cw       = {"0", "50", "75", "225", "50", "50", "50", "50", "50", "50", "50", "100" };
        String [] ch       = {"", "Sel", "Date", "Description", "Note", "Qty", "Charge Amount", "Payments", "Writeoff", "Deductable", "Balance", "Billing<br>Batch" };

        lst.setTableWidth("800");
        lst.setTableBorder("0");
        lst.setCellPadding("3");
        lst.setAlternatingRowColors("#ffffff", "#cccccc");
        lst.setRoundedHeadings("#030089", "");
    //    lst.setTableHeading(title);
        lst.setUrlField(0);
//        lst.setNumberOfColumnsForUrl(6);
        lst.setColumnUrl(2, url, 0);
        lst.setColumnUrl(3, url, 0);
        lst.setColumnUrl(5, url, 0);
        lst.setColumnUrl(6, url, 0);
        lst.setColumnUrl(7, url, 0);
        lst.setColumnUrl(8, url, 0);
        lst.setColumnUrl(9, url, 0);
        lst.setRowUrl(url);
        lst.setShowRowUrl(true);
        lst.setOnClickAction("window.open");
        lst.setOnClickOption("\"" + title + "\",\"width=750,height=550,scrollbars=no,left=100,top=100,\"");
        lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
        lst.setShowComboBoxes(true);
        lst.setUseCatalog(false);
        lst.setDivHeight(245);
        lst.setColumnWidth(cw);
        lst.setColumnFilterState(1, false);
        lst.setColumnFilterState(2, true);
        lst.setColumnFilterState(3, true);
        lst.setColumnFilterState(11, true);

        lst.setColumnAlignment(1, "CENTER");
        lst.setColumnAlignment(4, "CENTER");
        lst.setColumnAlignment(5, "RIGHT");
        lst.setColumnAlignment(11, "RIGHT");

        lst.setColumnFormat(6, "MONEY");
        lst.setColumnFormat(7, "MONEY");
        lst.setColumnFormat(8, "MONEY");
        lst.setColumnFormat(9, "MONEY");
        lst.setColumnFormat(10, "MONEY");

        lst.setSummaryColunn(6);
        lst.setSummaryColunn(7);
        lst.setSummaryColunn(8);
        lst.setSummaryColunn(9);
        lst.setSummaryColunn(10);

        // Show the filtered list
        // RKW 09-04-08 fieldset not displaying correctly in Firefox
        int fieldsetWidth=Integer.parseInt(lst.getTableWidth());
        try {
            out.print(fldSet.getFieldSet(lst.getHtml(request, myQuery, ch), "style='width: " + fieldsetWidth +"'",  title + " for " + patient.getPatientName(), "style='font-size: 12; font-weight: bold;' align=center"));
        } catch (Exception e) {
        }

        // Show aging information - 12/20/07
        out.print(patient.getPatientAging(htmTb, "#e0e0e0", 20));
        out.print("<b><a style=\"color: red\">Available Patient Unapplied Payments: " + Format.formatCurrency(patient.getUnappliedPaymentTotal()) + "</a><br>");

        out.print("<br>\n");
        out.print("<input type=button value='add new charge' onClick=addNewCharge() class=button>");
        out.print("<input type=button value='print open items only' onClick=showStatement('O') class=button>");
        out.print("<input type=button value='print all charge history' onClick=showStatement('A') class=button>");
        out.print("<input type=button value='print charge ledger' onClick=showStatement('L') class=button>");
        out.print("<input type=button value='print PIP ledger' onClick=showPIPLedger() class=button>");
        out.print("<input type=button value='print selected charges' onClick=showStatement('S') class=button>");
        out.print("<input type=button value='invert selection' onClick=invertSelection() class=button>");

    } else {
        out.print("Patient information not set");
    }

    session.setAttribute("parentLocation", self+"?"+parmsPassed);
    session.setAttribute("returnUrl", "");

} catch (Exception e) {
    out.print(e);
}
%>

<%@ include file="template/pagebottom.jsp" %>