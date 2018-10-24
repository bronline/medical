<%@include file="/template/pagetop.jsp" %>
<script type="text/javascript" src="../js/jQuery.js"></script>
<script>
function printBills(patientId) {
//  billForm.submit();
    var url="ajax/selectpaperbill.jsp?patientId=" + patientId;
    var dataString = $('#billForm').serialize();

    $.ajax({
        type: "POST",
        url: url,
        data: dataString,
        success: function(data) {
            $('#secondaryInsuranceBubble').html(data);
        },
        complete: function(data) {
            $('#secondaryInsuranceBubble').css('visibility', 'visible');
            $('#secondaryInsuranceBubble').css('display','');
        }

    });
}

function billSecondary(batchId,patientId) {
//  window.open('billing.jsp?secondary=Y&batchId='+batchId+'&patientId='+patientId,'CreateBatch','width=800,height=550,scrollbars=no,left=100,top=100,');
    var url="ajax/billsecondary.jsp?batchId="+batchId+"&patientId="+patientId;

    $.ajax({
        type: "POST",
        url: url,
        success: function(data) {
            $('#secondaryInsuranceBubble').html(data);
        },
        complete: function(data) {
            $('#secondaryInsuranceBubble').css('visibility', 'visible');
            $('#secondaryInsuranceBubble').css('display','');
        }

    });
}
function closeSupplementalInsuranceBubble() {
    $('#secondaryInsuranceBubble').css('visibility', 'hidden');
}
function previewBill(batchId,patientId) {
  window.open('previewbill.jsp?batchId='+batchId+'&patientId='+patientId,'CreateBatch','address=no,scrollbars=yes');
}
function postPayment(batchId, providerId) {
  window.open('paymentdetail.jsp?id=0&batchId='+batchId+'&providerId='+providerId,'PostPayment','width=900,height=750,scrollbars=no,left=100,top=100');
}
function postPIPPayment(batchId, providerId) {
  window.open('paymentdetail.jsp?id=0&batchId='+batchId+'&providerId='+providerId+'&pipPayment=Y','PostPayment','width=900,height=750,scrollbars=no,left=100,top=100');
}
function removeFromBatch(batchId,patientId) {
    var action="ajax/removechargesfrombatch.jsp?batchId="+batchId+"&patientId="+patientId;

    $.ajax({
        type: "POST",
        url: action,
        success: function(data) {
            if(data.indexOf("removed")>=0) {
                alert("Open charges have been removed from the batch and are available to be re-billed");
                location.href="bills.jsp";
            }
            else if(data.indexOf("nothing")>=0) { alert("There were no charges available for removal")};
        },
        complete: function(data) {

        },
        error: function() {
        alert("There was a problem removing the charges from the batch");
        }

    });
}

function closeCharges(batchId,patientId) {
    var action="ajax/closechargesinbatch.jsp?batchId="+batchId+"&patientId="+patientId;

    $.ajax({
        type: "POST",
        url: action,
        success: function(data) {
            if(data.indexOf("closed")>=0) {
                alert("Charges have been closed");
                location.href="bills.jsp";
            }
            else if(data.indexOf("nothing")>=0) { alert("There were no charges to close")};
        },
        complete: function(data) {

        },
        error: function() {
        alert("There was a problem removing the charges from the batch");
        }

    });
}
</script>
<div id="secondaryInsuranceBubble"></div>
<div align="left" id="batchPrintBubble"></div>
<%
try {
// Set up the SQL statement
    if(patient.next()) {
        visit.setId(0);

        String myQuery="SELECT id, batchid, name, fld, sup, preview, rmvBtn, postpmt, startdate, enddate, billed, lastbilled, charges from (" +
        "SELECT " +
        "  e.id, " +
        "  a.batchid, " +
        "  providers.name, " +
        "  concat('<input type=checkbox name=chk', e.id, '>') as fld, " +
        "  case when (select count(*) from patientinsurance where c.patientid=d.id)>1 then concat('<input type=button name=btn', e.id, ' onClick=billSecondary(', e.id,',',d.id,') class=button value=\"bill 2nd\" style=\"font-size: 8px; font-weight: normal;\">') else '' end as sup, " +
        "  concat('<input type=button name=preView', e.id, ' onClick=previewBill(', e.id,',',d.id,') class=button value=\"preview\" style=\"font-size: 8px; font-weight: normal;\">') as preview, " +
        "  concat('<input type=button name=rmvBtn onClick=removeFromBatch(',a.batchid,',',c.patientid,') class=button value=\"remove\" style=\"font-size: 8px; font-weight: normal;\">') as rmvBtn, " +
        "  concat('<input type=button name=postPmt onClick=', (case when pi.ispip then 'postPIPPayment' else 'postPayment' end),'(', a.batchid, ',',providers.id,') class=button value=\"post payment\" style=\"font-size: 8px; font-weight: normal;\">') as postpmt, " +
        "  DATE_FORMAT(min(c.`date`), '%m/%d/%Y') as startdate, " +
        "  DATE_FORMAT(max(c.`date`), '%m/%d/%Y') as enddate, " +
        "  DATE_FORMAT(e.billed, '%m/%d/%Y') as billed, " +
        "  DATE_FORMAT(e.lastbilldate, '%m/%d/%Y') as lastbilled, " +
        "  concat('Open | <a href=\"javascript:closeCharges(',a.batchid,',',d.id,')\">Close</a>') as charges " +
        " FROM batches e " +
        " left join batchcharges a on a.batchid=e.id and NOT a.complete " +
        " join charges b on a.chargeid=b.id " +
        " join visits c on b.visitid=c.id " +
        " join patients d on c.patientid=d.id " +
        " join providers on e.provider=providers.id " +
        " left join patientinsurance pi on pi.patientid=d.id and pi.providerid=e.provider " +
        " left join payments pm on pm.patientid=" + patient.getString("id") + " and pm.chargeid=b.id " +
        " where " +
        "  c.patientid=" + patient.getString("id") + " " +
        " group by " +
        "  e.id " +
        "UNION " +
        "SELECT " +
        "  e.id, " +
        "  a.batchid, " +
        "  providers.name, " +
        "  concat('<input type=checkbox name=chk', e.id, '>') as fld, " +
        "  case when (select count(*) from patientinsurance where c.patientid=d.id)>1 then concat('<input type=button name=btn', e.id, ' onClick=billSecondary(', e.id,',',d.id,') class=button value=\"bill 2nd\" style=\"font-size: 8px; font-weight: normal;\">') else '' end as sup, " +
        "  concat('<input type=button name=preView', e.id, ' onClick=previewBill(', e.id,',',d.id,') class=button value=\"preview\" style=\"font-size: 8px; font-weight: normal;\">') as preview, " +
        "  concat('<input type=button name=rmvBtn onClick=removeFromBatch(',a.batchid,',',c.patientid,') class=button value=\"remove\" style=\"font-size: 8px; font-weight: normal;\">') as rmvBtn, " +
        "  concat('<input type=button name=postPmt onClick=', (case when pi.ispip then 'postPIPPayment' else 'postPayment' end),'(', a.batchid, ',',providers.id,') class=button value=\"post payment\" style=\"font-size: 8px; font-weight: normal;\">') as postpmt, " +
        "  DATE_FORMAT(min(c.`date`), '%m/%d/%Y') as startdate, " +
        "  DATE_FORMAT(max(c.`date`), '%m/%d/%Y') as enddate, " +
        "  DATE_FORMAT(e.billed, '%m/%d/%Y') as billed, " +
        "  DATE_FORMAT(e.lastbilldate, '%m/%d/%Y') as lastbilled, " +
        "  'Complete' as charges " +
        " FROM batches e " +
        " left join batchcharges a on a.batchid=e.id and a.complete " +
        " join charges b on a.chargeid=b.id " +
        " join visits c on b.visitid=c.id " +
        " join patients d on c.patientid=d.id " +
        " join providers on e.provider=providers.id " +
        " left join patientinsurance pi on pi.patientid=d.id and pi.providerid=e.provider " +
        " left join payments pm on pm.patientid=" + patient.getString("id") + " and pm.chargeid=b.id " +
        " where " +
        "  c.patientid=" + patient.getString("id") + " " +
        " group by " +
        "  e.id) tmp " +
        "order by " +
        "  startdate desc";       

        String url         = "bills_d.jsp";
        String title       = "Bills";

        ResultSet iMsgRs = io.opnRS("SELECT p.name, ifnull(i.notes,'') as notes FROM patientinsurance i left join providers p on i.providerid=p.id where active and i.patientid=" + patient.getId());

    // Create an RWFiltered List object
        RWFilteredList lst = new RWFilteredList(io);
        RWHtmlTable htmTb  = new RWHtmlTable("750", "0");
        RWHtmlForm frm     = new RWHtmlForm();
        RWFieldSet fldSet  = new RWFieldSet();

        while(iMsgRs.next()) {
            out.print("<fieldset style=\"width: 850px; border: 1px solid #666; padding: 10px;\"><legend><b>Notes for " + iMsgRs.getString("name") + "</b></legend>");
            out.print("<textarea rows=\"3\" cols=\"175\" class=\"tAreaText\" READONLY>" + iMsgRs.getString("notes") + "</textarea>");
            out.print("</fieldset>");
        }

        iMsgRs.close();

    // Set special attributes on the filtered list object
        lst.setTableWidth("850");
        lst.setTableBorder("0");
        lst.setCellPadding("3");
        lst.setAlternatingRowColors("#ffffff", "#cccccc");
        lst.setRoundedHeadings("#030089", "");
    //    lst.setTableHeading(title);
        // Set specific column widths
        String [] cellWidths = {"0", "40", "120", "50", "80", "80", "80", "80", "80", "80", "80", "80", "80"};
        String [] cellHeadings = { "", "Batch", "Payer", "Print", getSecondaryHeading(io, patient.getInt("id")),"Preview", "Remove<br>From Batch", "Post", "From", "To", "Billed Date", "Last<br>Billed", "Status" };
        lst.setColumnWidth(cellWidths);
        lst.setUrlField(0);
        lst.setNumberOfColumnsForUrl(0);
        lst.setRowUrl(url);
        lst.setShowRowUrl(true);
        lst.setOnClickAction("window.open");
        lst.setOnClickOption("\"Bills\",\"width=850,height=470,scrollbars=no,left=100,top=100,\"");
        lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
        lst.setShowComboBoxes(false);
        lst.setUseCatalog(true);
        lst.setDivHeight(200);

        lst.setColumnAlignment(3, "CENTER");
        lst.setColumnAlignment(4, "CENTER");
        lst.setColumnAlignment(5, "CENTER");
        lst.setColumnAlignment(6, "CENTER");
        lst.setColumnAlignment(7, "CENTER");
        lst.setColumnAlignment(8, "CENTER");
        lst.setColumnAlignment(9, "RIGHT");

// out.print(myQuery);

    // Show the filtered list
        htmTb.replaceNewLineChar(false);

        out.print("<form name=\"billForm\" id=\"billForm\" action=printpatientbills.jsp?patientId=" + patient.getString("id") + " method=post>\n");
        out.print(fldSet.getFieldSet(lst.getHtml(myQuery, cellHeadings), "style='width: " + lst.getTableWidth() +"'",  title + " for " + patient.getPatientName(), "style='font-size: 12; font-weight: bold;' align=center"));
        out.print("</form>");

        out.print(frm.startForm());
        out.print(frm.button("Print selected bills ", "class=button onClick=printBills(" + patient.getString("id") + ")" ));
        out.print(frm.endForm());
    } else {
        out.print("Patient information not set");
    }

    session.setAttribute("parentLocation", self);
    session.removeAttribute("returnUrl");

} catch (Exception e) {
    out.print(e);
}
%>
<%! public String getSecondaryHeading(RWConnMgr io, int patientId) throws Exception {
        String heading="";

        ResultSet lRs=io.opnRS("select patientid, count(*) as inscount from patientinsurance where active and not primaryprovider and patientid=" + patientId + " group by patientid");
        if(lRs.next()) {
            if(lRs.getInt("inscount") > 1) { heading="Bill<br>Secondary"; }
        }
        lRs.close();

        return heading;
    }
%>
<%@ include file="template/pagebottom.jsp" %>