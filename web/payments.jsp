<%@include file="template/pagetop.jsp" %>
<script>
    function printReceipt(payment) {
        window.open('printreceipt.jsp?printOption=S&chk'+payment+'=Y','Receipt','address=no,toolbar=yes,scrollbars=yes');
    }
</script>
<script>
    var selectedItems = "";
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
                var url="ajax/getpaymentdetails.jsp?id="+paymentId+"&sid="+Math.random();
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

        String myQuery     = "SELECT a.id, concat('<input type=checkbox onClick=addItemToList(this) name=chk',a.id,'>') as chkbox, " +
                                "'+' as expand, " +
                                "a.date paymentdate, ifnull(b.name,'Cash') provider, checknumber, " +
                                "a.amount as paymentamount, case when chargeid=0 then a.originalamount else 0 end as originalamount, " +
                                "case when chargeid=0 then '**UNAPPLIED**' else e.description end as charge, d.date as chargedate, c.Quantity*c.chargeamount " +
//                                "concat('<input type=button class=button value=\"receipt\" onClick=printReceipt(',a.id,')>') as receipt " +
                                "FROM payments a " +
                                "left join providers b on a.provider=b.id " +
                                "left join charges c on a.chargeid=c.id " +
                                "left join visits d on c.visitid=d.id " +
                                "left join items e on c.itemid=e.id " +
                                "where a.patientId=" + patient.getId() + " order by a.patientid, a.date desc, a.chargeid";

        //RKW 01/13/10 - added colapsable section for charges
        myQuery="SELECT a.id, max(concat('<input type=checkbox onClick=addItemToList(this) name=chk',a.id,'>')) as chkbox, " +
                "max(case when chargeid=0 and refundid=0 then case when (select count(id) from payments where parentpayment=a.id)=0 then '' else '[+]' end else '[+]' end) as expand, " +
                "a.date paymentdate,ifnull(b.name,'Cash') provider,checknumber, " +
                "sum(case when a.chargeid=0 then case when amount=0 then 0 else amount end  else a.amount end) as paymentamount, " +
                "max(case when chargeid=0 and refundid=0 then case when amount<>0 then '**UNAPPLIED**' else '' end else '' end) as paymenttype " +
                "FROM payments a " +
                "left join providers b on a.provider=b.id " +
                "where a.patientId=" + patient.getId() +
                " group by ifnull(b.name,'Cash'), " +
                "case when chargeid=0 then concat(a.id,a.checknumber) else " +
                "case when parentpayment=0 then concat(checknumber) else concat(a.parentpayment,a.checknumber) end end " +
                "order by a.patientid, a.date desc";

        String url         = "paymentdetail.jsp?";
        String title       = "Payments";

    // Create an RWFiltered List object
        RWFilteredList lst = new RWFilteredList(io);
        RWHtmlTable htmTb  = new RWHtmlTable("960", "0");
        RWHtmlForm frm     = new RWHtmlForm();
        RWFieldSet fldSet  = new RWFieldSet();

        htmTb.replaceNewLineChar(false);

    // Set special attributes on the filtered list object
//        String [] cw       = {"0", "30", "10", "75", "125", "75", "80", "80", "150", "80", "80" };
        String [] cw       = {"0", "25", "25", "100", "275", "100", "75", "150"};
        String [] ch       = {"", "Sel", "&nbsp;&nbsp;", "Pay Date", "Provider", "Check", "Paid/Unapplied Amount", "Unapplied", "Charge", "Charge Date", "Charge Amount" };

        lst.setTableWidth("750");
        lst.setTableBorder("0");
        lst.setCellPadding("0");
        lst.setAlternatingRowColors("#ffffff", "#cccccc");
        lst.setRoundedHeadings("#030089", "");
    //    lst.setTableHeading(title);
        lst.setUrlField(0);
//        lst.setNumberOfColumnsForUrl(9);
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
        lst.setShowComboBoxes(true);
        lst.setUseCatalog(false);
        lst.setDivHeight(300);
        lst.setColumnWidth(cw);
        for(int z=0;z<8;z++) { lst.setColumnFilterState(z, true); }
        lst.setColumnFilterState(0, false);
        lst.setColumnFilterState(1, false);
        lst.setColumnFilterState(2, false);
        lst.setColumnFilterState(3, true);
        lst.setColumnFilterState(4, true);
        lst.setColumnFilterState(5, true);
        lst.setColumnFilterState(6, true);
        lst.setColumnFilterState(7, true);
        lst.setColumnFilterState(8, true);
        lst.setColumnFilterState(9, true);
        lst.setColumnFilterState(10, true);
        lst.setColumnAlignment(1, "CENTER");
        lst.setColumnAlignment(2, "CENTER");
        lst.setColumnAlignment(7, "CENTER");

        lst.setColumnFormat(6, "MONEY");
//        lst.setColumnFormat(7, "MONEY");
//        lst.setColumnFormat(10, "MONEY");

        lst.setSummaryColunn(6);
//        lst.setSummaryColunn(7);
//        lst.setSummaryColunn(9);

        lst.setShowColapsableRow(true);
        lst.setColumnForColapsingData(2);
        lst.setOnClickAction(2, "onClick=showPaymentDetails(this,##idColumn##) style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
        lst.setColapsableRowOptions("style=\"visibility: hidden; display: none;\"");

    // Show the filtered list
        out.print("<title>" + title + "</title>");

        try {
        out.print(fldSet.getFieldSet(lst.getHtml(request, myQuery, ch), "style='width: " + lst.getTableWidth() +"'",  title + " for " + patient.getPatientName(), "style='font-size: 12; font-weight: bold;' align=center"));
        } catch (Exception e) {
        }
        out.print("<B>Patient Unapplied Payment Total: " + Format.formatCurrency(patient.getUnappliedPaymentTotal()));
        out.print(frm.startForm());
        out.print(frm.button("New " + title, "class=button onClick=window.open(\"" + url + "?id=0\",\"Locations\",\"width=400,height=250,scrollbars=no,left=100,top=100,\");" ));
        out.print("<input type=button value='receipt with detail' onClick=showReceipt('S','Y') class=button>");
        out.print("<input type=button value='receipt only' onClick=showReceipt('S','N') class=button>");
        out.print("<input type=button value='invert selection' onClick=invertSelection() class=button>");
        out.print(frm.endForm());
    } else {
        out.print("Patient information not set");
    }


    session.setAttribute("parentLocation", self+"?"+parmsPassed);

} catch (Exception e) {
    out.print(e);
}
%>
<%@ include file="template/pagebottom.jsp" %>