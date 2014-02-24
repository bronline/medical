<%-- 
    Document   : unappliedpayments
    Created on : Nov 18, 2013, 12:30:31 PM
    Author     : Randy
--%>
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

    function writeoffPayments() {
        var url="ajax/writeoffunapplied.jsp?sid="+Math.random()+selectedItems;
        $.ajax({
            url: url,
            success: function(data){
                alert("Unapplied payment(s) written off");
                location.href = "unappliedpayments.jsp";
            },
            error: function() {
                alert("There was a problem processing the request");
            }
        });

    }
</script>
<%
try {
        String myQuery="SELECT a.id, max(concat('<input type=checkbox onClick=addItemToList(this) name=chk',a.id,'>')) as chkbox, " +
                "max(case when chargeid=0 and refundid=0 then case when (select count(id) from payments where parentpayment=a.id)=0 then '' else '[+]' end else '[+]' end) as expand, " +
                "concat(pt.lastname,', ',pt.firstname) as name, " +
                "a.date paymentdate,ifnull(b.name,'Cash') provider,checknumber, " +
                "sum(case when a.chargeid=0 then case when amount=0 then 0 else amount end  else a.amount end) as paymentamount " +
                "FROM payments a " +
                "left join providers b on a.provider=b.id " +
                "left join patients pt on pt.id=a.patientid " +
                "where a.amount<>0 and a.originalamount<>a.amount and a.chargeid=0 and a.parentpayment=0 " +
                " group by ifnull(b.name,'Cash'), " +
                "case when chargeid=0 then concat(a.id,a.checknumber) else " +
                "case when parentpayment=0 then concat(checknumber) else concat(a.parentpayment,a.checknumber) end end " +
                "order by a.patientid, a.date desc";

        String url         = "paymentdetail.jsp?";
        String title       = "Un-Applied Payments";

    // Create an RWFiltered List object
        RWFilteredList lst = new RWFilteredList(io);
        RWHtmlTable htmTb  = new RWHtmlTable("960", "0");
        RWHtmlForm frm     = new RWHtmlForm();
        RWFieldSet fldSet  = new RWFieldSet();

        htmTb.replaceNewLineChar(false);

    // Set special attributes on the filtered list object
        String [] cw       = {"0", "25", "25", "175", "100", "100", "100", "75", "150"};
        String [] ch       = {"", "Sel", "&nbsp;&nbsp;", "Patient", "Pay Date", "Payment<br/>Method", "Check", "Unapplied Amount", "Charge", "Charge Date", "Charge Amount" };

        lst.setTableWidth("750");
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

        lst.setColumnFormat(7, "MONEY");

        lst.setSummaryColunn(7);

        lst.setShowColapsableRow(true);
        lst.setColumnForColapsingData(2);
        lst.setOnClickAction(2, "onClick=showPaymentDetails(this,##idColumn##) style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
        lst.setColapsableRowOptions("style=\"visibility: hidden; display: none;\"");

    // Show the filtered list
        out.print("<title>" + title + "</title>");

//        try {
        out.print(fldSet.getFieldSet(lst.getHtml(request, myQuery, ch), "style='width: " + lst.getTableWidth() +"'",  title + " - All Patients", "style='font-size: 12; font-weight: bold;' align=center"));
//        } catch (Exception e) {
//            out.print(myQuery);
//        }
        out.print(frm.startForm());
        out.print("<input type=button value='write-off payments' onClick=writeoffPayments() class=button>");
        out.print("<input type=button value='invert selection' onClick=invertSelection() class=button>");
        out.print(frm.endForm());

    session.setAttribute("parentLocation", self+"?"+parmsPassed);

} catch (Exception e) {
    out.print(e);
}
%>
<%@ include file="template/pagebottom.jsp" %>