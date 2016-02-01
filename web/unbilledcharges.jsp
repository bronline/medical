<%-- 
    Document   : unbilledcharges
    Created on : Jul 29, 2013, 12:40:20 PM
    Author     : Randy
--%>
<%@include file="template/pagetop.jsp" %>

<script type="text/javascript">

    function showUnbilledCharges(what,providerId) {
        var rowId=what.id.substr(3);
        var obj=document.getElementById('rowId'+rowId);
        var url="ajax/getunbilledcharges.jsp?id="+providerId+"&sid="+Math.random();
        var visibleRow="#rowId" + rowId;

        if(what.innerHTML == "[-]") {
            $(visibleRow).css('visibility', 'hidden');
            $(visibleRow).css('display','none');
            what.innerHTML="[+]"
        } else {
            what.innerHTML="[-]";
            if(obj.innerHTML.trim() == '&nbsp;&nbsp;') {
                $.ajax({
                    type: "POST",
                    url: url,
                    success: function(data) {
                        $(visibleRow).html(data);
                    },
                    complete: function(data) {
                        $(visibleRow).css('visibility', 'visible');
                        $(visibleRow).css('display','');
                    }

                });
            }
        }

    }

    function batchFunctions(what,chargeId,providerId) {
        var url = "ajax/batchfunctions.jsp?chargeId=" + chargeId + "&providerId=" + providerId;
        $.ajax({
            type: "POST",
            url: url,
            success: function(data) {
                if(what.innerHTML == "remove") {
                    what.innerHTML = "add to batch";
                } else {
                    what.innerHTML = "remove";
                }
            },
            complete: function(data) {
            },
            error: function(data) {
                alert("There was a problem with your request");
            }
        });

    }

    function markChargeNonBillable(what,chargeId,providerId) {
        var url = "ajax/setbillablestateforcharge.jsp?chargeId=" + chargeId + "&providerId=" + providerId;
        $.ajax({
            type: "POST",
            url: url,
            success: function(data) {
                if(what.innerHTML == "billable") {
                    what.innerHTML = "not billable";
                } else {
                    what.innerHTML = "billable";
                }
            },
            complete: function(data) {
            },
            error: function(data) {
                alert("There was a problem with your request");
            }
        });
    }
</script>
<%
try {
// Set this as the parent location

    String myQuery     = "Select providers.id, max('[+]') as sel, providers.name, providers.address, count(charges.id) as chargecount, sum(quantity*chargeamount-payments) as totalcharges " +
            "from charges " +
            "left join items on charges.itemid=items.id " +
            "left join batchcharges on batchcharges.chargeid=charges.id " +
            "left join visits on charges.visitid=visits.id " +
            "left join patients on visits.patientid=patients.id " +
            "left join patientinsurance on patients.id=patientinsurance.patientid and patientinsurance.primaryprovider=1 and not ispip " +
            "left join providers on patientinsurance.providerid=providers.id " +
            "left join (select chargeid, sum(amount) as payments from payments group by chargeid) p on p.chargeid=charges.id " +
            "where " +
            "providers.name is not null and " +
            "providers.reserved=0 and " +
            "(batchcharges.id is null or not complete) and " +
            "((charges.billinsurance=0 and items.billinsurance=1) or (charges.billinsurance=2)) " +
            "group by " +
            "providers.id, " +
            "providers.name, " +
            "providers.address " +
            "having " +
            "sum(quantity*chargeamount-payments)>0 " +
            "order by " +
            "providers.name";

    String url         = "providers.jsp";
    String title       = "Unbilled Charges";

// Create an RWFiltered List object
    RWFilteredList lst = new RWFilteredList(io);
    RWHtmlTable htmTb  = new RWHtmlTable("960", "0");
    RWHtmlForm frm     = new RWHtmlForm();
    RWFieldSet fldSet  = new RWFieldSet();

    htmTb.replaceNewLineChar(false);

// Set special attributes on the filtered list object
    String [] cw       = {"0", "25", "100", "275", "50", "75"};
    String [] ch       = {"", "Sel", "Payer Name", "Payer Address", "Charges", "UnBilled Amount"};

    lst.setTableWidth("750");
    lst.setTableBorder("0");
    lst.setCellPadding("0");
    lst.setAlternatingRowColors("#ffffff", "#cccccc");
    lst.setRoundedHeadings("#030089", "");
        lst.setUrlField(0);

        lst.setColumnUrl(1, url, 0);
        lst.setRowUrl(url);

    lst.setShowRowUrl(false);
    lst.setShowComboBoxes(true);
    lst.setUseCatalog(false);
    lst.setDivHeight(300);
    lst.setColumnWidth(cw);
    for(int z=0;z<8;z++) { lst.setColumnFilterState(z, true); }
    lst.setColumnFilterState(0, false);
    lst.setColumnFilterState(1, false);
    lst.setColumnFilterState(2, true);
    lst.setColumnFilterState(3, false);
    lst.setColumnFilterState(4, false);
    lst.setColumnFilterState(5, false);
    lst.setColumnAlignment(1, "CENTER");
    lst.setColumnFormat(5, "MONEY");

    lst.setSummaryColunn(4);
    lst.setSummaryColunn(5);

        lst.setOnClickAction("window.open");
        lst.setOnClickOption("\"" + title + "\",\"width=400,height=250,scrollbars=no,left=100,top=100,\"");
        lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");

    lst.setShowColapsableRow(true);
    lst.setColumnForColapsingData(1);
    lst.setOnClickAction(1, "onClick=showUnbilledCharges(this,##idColumn##) style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    lst.setColapsableRowOptions("style=\"visibility: hidden; display: none;\"");

// Show the filtered list
    out.print("<title>" + title + "</title>");

    try {
        out.print(lst.getHtml(request, myQuery, ch));
    } catch (Exception e) {
    }

    out.print(frm.endForm());

    session.setAttribute("parentLocation", self+"?"+parmsPassed);

} catch (Exception e) {
    out.print(e);
}
%>
<%@ include file="template/pagebottom.jsp" %>
