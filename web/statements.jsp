<%-- 
    Document   : statements
    Created on : Aug 15, 2011, 2:27:40 PM
    Author     : rwandell
--%>

<%@include file="template/pagetop.jsp" %>
<script>
    function submitRequest() {
        var printOption = $('select[name=print] option:selected').val();
        if(printOption == "P") {
//            var selected = $('#patList :input:not(:checked)').map(function(i,el){return el.name;}).get();
            var selected = $('#patList input:checked').map(function(i,el){return el.name;}).get();
            var url="report_statements.jsp?statements=S&printOption=O&minDays=" + minDays.value + "&maxDays=" + maxDays.value + "&complete=" + complete[complete.selectedIndex].value + "&patientType=" + patientType[patientType.selectedIndex].value;
            for(i=0;i<selected.length;i++) { url += "&"+selected[i]+"=1"; }
            window.open(url,"statements");
        } else {
            frmInput.submit();
        }
    }
</script>
<%
    String print = request.getParameter("print");
    String minDays = request.getParameter("minDays");
    String maxDays = request.getParameter("maxDays");
    String complete = request.getParameter("complete");
    String patientType = request.getParameter("patientType");
    String completedTransactions = "";
    String patientTransactions = "bc.id IS NOT NULL AND ";

    if(complete != null && complete.equals("C")) { completedTransactions = "bc.complete and "; }

    if(patientType != null && patientType.equals("C")) {
        completedTransactions = "";
        patientTransactions = "pi.patientid is null and ";
    }

    if(patientType != null && complete != null && complete.equals("C") && patientType.equals("A")) {
        completedTransactions = "1=case when pi.patientid IS NULL THEN 1 else case when bc.id is not null and bc.complete then 1 else 0 end end and ";
        patientTransactions = "";
    }

    if(patientType != null && complete != null && complete.equals("A") && patientType.equals("A")) {
        completedTransactions = "";
        patientTransactions = "";
    }

    RWHtmlTable htmTb=new RWHtmlTable("700", "0");

    htmTb.replaceNewLineChar(false);

    if(minDays == null) { minDays = "91"; }
    if(maxDays == null) { maxDays = "9999"; }

    ResultSet pRs = io.opnRS("select 'V' as print, 'View Details' as description UNION select 'P' as print, 'Print Statements' as description");
    ResultSet cRs = io.opnRS("select 'C' as complete, 'Completed Charges Only' as description UNION select 'A' as complete, 'All Charges' as description");
    ResultSet tRs = io.opnRS("select 'A' as patientType, 'All Patients' as description UNION select 'C' as patientType, 'Cash Patients Only' as description UNION select 'I' as patientType, 'Insurance Patients Only' as description");

    RWHtmlForm frm = new RWHtmlForm("frmInput", "statements.jsp", "post");
    out.print(frm.startForm());
    out.print(htmTb.startTable("400"));
    out.print(htmTb.startRow());
    out.print(htmTb.addCell("<b>Minimum Days</b>", "width=\"100\""));
    out.print(htmTb.addCell("<input type=\"text\" id=\"minDays\" name=\"minDays\" maxlength=\"4\" size=\"4\" class=\"tBoxText\" value=\"" + minDays + "\" style=\"text-align: right;\">", "width=\"300\""));
    out.print(htmTb.endRow());
    out.print(htmTb.startRow());
    out.print(htmTb.addCell("<b>Maximum Days</b>", "width=\"100\""));
    out.print(htmTb.addCell("<input type=\"text\" id=\"maxDays\" name=\"maxDays\" maxlength=\"4\" size=\"4\" class=\"tBoxText\" value=\"" + maxDays + "\" style=\"text-align: right;\">", "width=\"300\""));
    out.print(htmTb.endRow());
    out.print(htmTb.startRow());
    out.print(htmTb.addCell("<b>Patients to Include</b>", "width=\"100\""));
    out.print(htmTb.addCell(frm.comboBox(tRs, "patientType", "patientType", false, "1", null, patientType,  "class=\"cBoxText\""), "width=\"300\"" ));
    out.print(htmTb.endRow());
    out.print(htmTb.startRow());
    out.print(htmTb.startRow());
    out.print(htmTb.addCell("<b>Charges to Include</b>", "width=\"100\""));
    out.print(htmTb.addCell(frm.comboBox(cRs, "complete", "complete", false, "1", null, complete,  "class=\"cBoxText\""), "width=\"300\"" ));
    out.print(htmTb.endRow());
    out.print(htmTb.startRow());
    out.print(htmTb.addCell("<b>Print Option</b>", "width=\"100\""));
    out.print(htmTb.addCell(frm.comboBox(pRs, "print", "print", false, "1", null, print,  "class=\"cBoxText\"") + "&nbsp;" + frm.button("go", "onClick=submitRequest() class=button"), "width=\"300\"" ));
    out.print(htmTb.endRow());
    out.print(htmTb.endTable());
    out.print(frm.hidden("O", "printOption"));

    String statementQuery = "select p.id, concat('<input type=\"checkbox\" name=\"pat',p.id,'\" id=\"pat',p.id,'\" checked>') as chkbox, " +
            "p.lastname, p.firstname, sum(c.chargeamount*c.quantity) charges, sum(ifnull((select sum(amount) from payments where chargeid=c.id),0.00)) payments " +
            "from charges c " +
            "left join (SELECT id, chargeid, max(complete) as complete from batchcharges group by chargeid) bc on bc.chargeid=c.id " +
            "left join visits v on c.visitid=v.id " +
            "left join patients p on p.id=v.patientid " +
            "left join (SELECT patientid, COUNT(*) AS insCount from patientinsurance group by patientid) pi on p.id=pi.patientid " +
            "left join items i on i.id=c.itemid " +
            "WHERE (not i.billinsurance and v.`date` between DATE_SUB(CURRENT_DATE, INTERVAL " + maxDays + " DAY) and DATE_SUB(CURRENT_DATE, INTERVAL " + minDays + " DAY)) or (" +
            patientTransactions +
            completedTransactions +
            "v.`date` between DATE_SUB(CURRENT_DATE, INTERVAL " + maxDays + " DAY) and DATE_SUB(CURRENT_DATE, INTERVAL " + minDays + " DAY)) " +
            "group by p.id " +
            "having sum(c.chargeamount*c.quantity)-sum(ifnull((select sum(amount) from payments where chargeid=c.id),0.00))>0 " +
            "order by p.lastname, p.firstname";
    
    statementQuery = "call rwcatalog.prGetPatientStatementBalance('" + io.getLibraryName() + "','" + patientType + "','" + complete + "'," + maxDays + "," + minDays + ")";

    if(print != null) {
        RWFilteredList lst = new RWFilteredList(io);
        lst.setTableWidth("520");
        lst.setTableBorder("0");
        lst.setCellPadding("3");
        lst.setAlternatingRowColors("#ffffff", "#cccccc");
        lst.setRoundedHeadings("#030089", "");
        lst.setColumnFilterState(1, false);

        String [] ch = { "", "Include", "Last Name", "First Name", "Charges", "Payments<br>Adjustments", "Balance" };
        String [] cw       = {"0", "75", "125", "75", "75", "75", "75" };

        lst.setColumnWidth(cw);
        lst.setColumnAlignment(1, "center");
        lst.setColumnFormat(4, "MONEY");
        lst.setColumnFormat(5, "MONEY");
        lst.setColumnFormat(6, "MONEY");
        lst.setDivHeight(300);
        lst.setSummaryColunn(4);
        lst.setSummaryColunn(5);

        out.print("<div id=\"patList\" align=\"left\" style=\"width: 550;\">\n");
        out.print(lst.getHtml(request, statementQuery, ch));
//        out.print(statementQuery);
        out.print("</div>\n");

        out.print("<input type=button value='invert selection' onClick=invertSelection() class=button>");

        lst = null;
    }

    out.print(frm.endForm());

    pRs.close();
    cRs.close();
    tRs.close();

    pRs = null;
    cRs = null;
    tRs = null;

    htmTb = null;

    System.gc();
%>
<%@ include file="template/pagebottom.jsp" %>