<%-- 
    Document   : postedipayment
    Created on : Jul 10, 2012, 2:10:41 PM
    Author     : Randy
--%>
<%@include file="sessioninfo.jsp" %>
<style type="text/css">
    .amountField { text-align: right; width: 75px; height: 18px; font-size: 10px; }
</style>
<script type="text/javascript">
<%
    int eobReasonCount=0;
    String eobArray="";
    ResultSet eRs1=io.opnRS("SELECT 0 as reasonid, ' ' as description, ' ' as type union select id as reasonid, description, type from eobreasons");
    while(eRs1.next()) {
        eobArray += "  eobArray[" + eRs1.getString("reasonid") + "]='" + eRs1.getString("type") + "';\n";
        eobReasonCount ++;
    }
    out.print("  var eobArray=new Array();\n");
    out.print(eobArray);
%>
  function calculateAdjustmentAmount(what) {
    var eobReasonIndex=what.selectedIndex;
    var names=document.getElementsByTagName('input');
    var suffix="";

    var deductableTotal=0.0;
    var adjustmentsTotal=0.0;
    var patientAmount=0.0;

    document.getElementById("eobReasonType").value=eobArray[eobReasonIndex];

    if(eobArray[eobReasonIndex] != ' ') {
        for(x=0;x<names.length;x++) {
            try {
                if(names[x].type != 'button') {
//                    if(names[x].name.substr(0,3)=='dos') {
//                        if(document.getElementById(names[x].name).value==currentDOS && suffix == "") {
//                            suffix=names[x].name.substr(3);
                            patientAmount=Number(document.getElementById('chargeamount').value.replace('$','').replace(',',''))-Number(document.getElementById('paymentamount').value.replace('$','').replace(',',''))-Number(document.getElementById('adjustmentamount').value.replace('$','').replace(',',''))
                            if(document.getElementById("eobReasonType" + suffix).value == 'A') { adjustmentsTotal=Number(document.getElementById('patientamount').value.replace('$','').replace(',','')); }
                            if(document.getElementById("eobReasonType" + suffix).value == 'D') { deductableTotal=Number(document.getElementById('patientamount').value.replace('$','').replace(',','')); }
                            document.getElementById("patientamount").value=formatCurrency(patientAmount);
//                        }
//                    }
                }
            } catch (err) {}
        }
    }

    document.getElementById("deductable").value=formatCurrency(deductableTotal);
    document.getElementById("adjustment").value=formatCurrency(adjustmentsTotal);

  }
</script>
<%
    String id=request.getParameter("id");
    String post=request.getParameter("post");
    String exceptionRecord=request.getParameter("exceptionRecord");
    RWHtmlTable htmTb = new RWHtmlTable("350", "0");
    String[] preload2={};
    RWInputForm frm = new RWInputForm();

    if(post == null) {
        String myQuery="SELECT" +
                    "  patients.id as patientid," +
                    "  patients.firstname," +
                    "  patients.lastname," +
                    "  edipayments.dos," +
                    "  items.code," +
                    "  case when items.id is null then 'Item Not Found' else items.description end as description," +
                    "  charges.chargeamount," +
                    "  charges.quantity," +
                    "  edipayments.paymentamount," +
                    "  edipayments.adjustmentamount," +
                    "  edipayments.ptientamount," +
                    "  case when edipayments.providerid=0 then 'Payer Not Found' else providers.name end as payername, " +
                    "  edipayments.checknumber, " +
                    "  edipayments.paymentdate, " +
                    "  edipayments.chargeid, " +
                    "  0 as exceptionrecord, " +
                    "  edipayments.eobbatchid " +
                    "from edipayments " +
                    "left join patients on patients.id=edipayments.patientid " +
                    "left join charges on charges.id=edipayments.chargeid " +
                    "left join providers on providers.id=edipayments.providerid " +
                    "left join items on items.id=charges.itemid " +
                    "where edipayments.id=" + id;
        if(exceptionRecord.equals("1")) {
            myQuery="SELECT" +
                    "  case when patients.id is null then 0 else patients.id end as patientid," +
                    "  case when patients.id is null then concat(ediexceptions.accountnumber,' -') else firstname end as firstname," +
                    "  case when patients.id is null then 'Patient Not Found' else lastname end as lastname," +
                    "  case when ediexceptions.dos is null or ediexceptions.dos='' then '0001-01-01' else ediexceptions.dos end as dos," +
                    "  ediexceptions.cptcode as code," +
                    "  case when ediexceptions.cptcode is null or ediexceptions.cptcode='' then 'Procedure Not Found' else items.description end as description," +
                    "  0 as chargeamount," +
                    "  0 as quantity," +
                    "  ediexceptions.paymentamount," +
                    "  ediexceptions.adjustmentamount," +
                    "  ediexceptions.patientamount as ptientamount," +
                    "  case when ediexceptions.providerid=0 then 'Payer Not Found' else providers.name end as payername, " +
                    "  ediexceptions.checknumber, " +
                    "  ediexceptions.paymentdate, " +
                    "  0 as chargeid, " +
                    "  1 as exceptionrecord, " +
                    "  ediexceptions.eobbatchid " +
                    "from ediexceptions " +
                    "left join patients on patients.accountnumber=ediexceptions.accountnumber " +
                    "left join providers on providers.id=ediexceptions.providerid " +
                    "left join items on items.code=ediexceptions.cptcode " +
                    "where ediexceptions.id="+id;
        }

        ResultSet eRs=io.opnRS("SELECT 0 as reasonid, ' ' as description union select id as reasonid, description from eobreasons");

        out.print("<div align=\"right\"><b style=\"cursor: pointer; margin-right: 5px; margin-top: 3px;\" onClick=\"closeBubble(paymentpannel,'HIDE')\">close</b></div>");

        out.print("<div align=\"left\" style=\"margin-left: 10px;\">");
        ResultSet lRs = io.opnRS(myQuery);
        if(lRs.next()) {
            out.print("Posting payment for : <b>" + lRs.getString("firstname") + " " + lRs.getString("lastname") + "</b>");
            out.print("<br/>");
            out.print("<br/>");
            out.print("<form id=\"paymentForm\" name=\"paymentForm\">");
            out.print(htmTb.startTable());
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("DOS","width=\"100\""));
            if(exceptionRecord != null && exceptionRecord.equals("0")) {
            out.print(htmTb.addCell(Format.formatDate(lRs.getString("dos"),"MM/dd/yy"),"width=\"200\""));
            } else {
                String dosQuery = "select c.id as chargeid, v.date " +
                        "from visits v " +
                        "left join charges c on c.visitid=v.id " +
                        "left join items i on i.id=c.itemid " +
                        "where patientid=" + lRs.getString("patientid") + " and i.code='" + lRs.getString("code") + "' " +
                        "and c.id in (select chargeid from batchcharges where not complete)";
                StringBuffer selectHtml = new StringBuffer();
                selectHtml.append("<select id=\"chargeid\" name=\"chargeid\" class=\"cBoxText\">");
                selectHtml.append("<option value=\"0\">-- Select --</option>");
                ResultSet dtRs=io.opnRS(dosQuery);
                while(dtRs.next()) {
                    if(lRs.getString("dos").equals(dtRs.getString("date"))) {
                        selectHtml.append("<option value=\"" + dtRs.getString("chargeid") + "\" selected>" + Format.formatDate(dtRs.getString("date"), "MM/dd/yy") + "</option>");
                    } else {
                        selectHtml.append("<option value=\"" + dtRs.getString("chargeid") + "\">" + Format.formatDate(dtRs.getString("date"), "MM/dd/yy") + "</option>");
                    }
                }
                selectHtml.append("</select>");
                dtRs.close();
                dtRs = null;
                out.print(htmTb.addCell(selectHtml.toString(), "width=\"200\""));
            }
            out.print(htmTb.endRow());
            if(exceptionRecord != null && exceptionRecord.equals("0")) {
                out.print(htmTb.startRow());
                out.print(htmTb.addCell("Charge Amount","width=\"100\""));
                out.print(htmTb.addCell(Format.formatCurrency((lRs.getDouble("chargeamount")*lRs.getDouble("quantity"))),"width=\"200\""));
                out.print(htmTb.endRow());
            } else {
                out.print(htmTb.startRow());
                out.print(htmTb.addCell("Procedure","width=\"100\""));
                out.print(htmTb.addCell(lRs.getString("code") + " - " + lRs.getString("description"),"width=\"200\""));
                out.print(htmTb.endRow());
            }
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("Payer","width=\"100\""));
            out.print(htmTb.addCell(getPayerListForPatient(io, lRs.getInt("patientid")),"width=\"200\""));
            out.print(htmTb.endRow());
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("Check Number","width=\"100\""));
            out.print(htmTb.addCell("<input type=\"text\" name=\"checknumber\" id=\"checknumber\" class=\"tBoxText\" size=\"35\" value=\"" + lRs.getString("checknumber") + "\">","width=\"200\""));
            out.print(htmTb.endRow());
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("Payment Date","width=\"100\""));
            out.print(htmTb.addCell("<input type=\"text\" name=\"paymentdate\" id=\"paymentdate\" class=\"tBoxText\" size=\"10\" style=\"text-align: right;\" readonly value=\"" + Format.formatDate(lRs.getString("paymentdate"), "MM/dd/yy") + "\">","width=\"200\""));
            out.print(htmTb.endRow());
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("Payment Amount","width=\"100\""));
            out.print(htmTb.addCell("<input type=\"text\" class=\"amountField\" id=\"paymentamount\" name=\"paymentamount\" value=\"" + lRs.getDouble("paymentamount") + "\">"));
            out.print(htmTb.endRow());
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("Adjustment Amount","width=\"100\""));
            out.print(htmTb.addCell("<input type=\"text\" class=\"amountField\" id=\"adjustmentamount\" name=\"adjustmentamount\" value=\"" + lRs.getDouble("adjustmentamount") + "\">"));
            out.print(htmTb.endRow());
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("Patient Responsible","width=\"100\""));
            out.print(htmTb.addCell("<input type=\"text\" class=\"amountField\" id=\"patientamount\" name=\"patientamount\" value=\"" + lRs.getDouble("ptientamount") + "\">"));
            out.print(htmTb.endRow());
            out.print(htmTb.endRow());
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("Patient Responsible","width=\"100\""));
            out.print(htmTb.addCell(frm.comboBox(eRs,"eobReasonId","reasonid",false,"1",null,"","class=cBoxText style='width: 90px' onChange=calculateAdjustmentAmount(this)") + frm.hidden("", "eobReasonType")));
            out.print(htmTb.endRow());
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("Attention Box","width=\"100\""));
            out.print(htmTb.addCell("<input type=\"text\" class=\"tBoxText\" id=\"attentionbox\" name=\"attentionbox\" size=\"35\" value=\"\">"));
            out.print(htmTb.endRow());
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("Notes to Batch","width=\"100\""));
            out.print(htmTb.addCell("<input type=\"text\" class=\"tBoxText\" id=\"notestobatch\" name=\"notestobatch\" size=\"35\" value=\"\">"));
            out.print(htmTb.endRow());
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("Notes to Benefits/Payer","width=\"100\""));
            out.print(htmTb.addCell("<input type=\"text\" class=\"tBoxText\" id=\"notestobenefits\" name=\"notestobenefits\" size=\"35\" value=\"\">"));
            out.print(htmTb.endRow());
            out.print(htmTb.endTable());
            out.print("<input type=\"hidden\" id=\"id\" name=\"id\" value=\"" + id + "\"> ");
            out.print("<input type=\"hidden\" id=\"eobbatchid\" name=\"eobbatchid\" value=\"" + lRs.getString("eobbatchid") + "\"> ");
            out.print("<input type=\"hidden\" id=\"patientid\" name=\"patientid\" value=\"" + lRs.getString("patientid") + "\"> ");
            out.print("<input type=\"hidden\" id=\"exceptionrecord\" name=\"exceptionrecord\" value=\"" + exceptionRecord + "\"> ");
            out.print("<input type=\"hidden\" id=\"chargeamount\" name=\"chargeamount\"    value=\"" + lRs.getDouble("chargeamount")*lRs.getDouble("quantity") + "\"");
            out.print("<input type=\"hidden\" id=\"patientbalance\" name=\"patientbalance\" value=\"" + (lRs.getDouble("paymentamount")-lRs.getDouble("adjustmentamount")) + "\"> ");
            out.print(frm.textBox("$0.00","deductable","7","7","style='text-align: right; display: none;' class=tBoxText READONLY " ));
            out.print(frm.textBox("$0.00","adjustment","7","7","style='text-align: right; display: none;' class=tBoxText READONLY" ));
            if(exceptionRecord.equals("0")) {
                out.print("<input type=\"hidden\" id=\"chargeid\" name=\"chargeid\" value=\"" + lRs.getString("chargeid") + "\"> ");
            }
            out.print("</from>");
            out.print("<br/>");
            out.print("<br/>");
            out.print("<input type=\"button\" class=\"button\" value=\"post\" onClick=\"postThisPayment()\">");
        }
        out.print("</div>");
        lRs.close();
        lRs = null;
    } else {
        boolean processed = true;
        String providerId = request.getParameter("providerid");
        String patientId = request.getParameter("patientid");
        String chargeId = request.getParameter("chargeid");
        String checkNumber = request.getParameter("checknumber");
        String paymentAmount = request.getParameter("paymentamount");
        String adjustmentAmount = request.getParameter("adjustmentamount");
        String patientAmount = request.getParameter("patientamount");
        String deductable = request.getParameter("deductable");
        String adjustment = request.getParameter("adjustment");
        String paymentDate = request.getParameter("paymentdate");
        String eobReasonType = request.getParameter("eobReasonType");
        String eobReasonId = request.getParameter("eobReasonId");
        String attentionMsg = request.getParameter("attentionbox");
        String notesToBatch = request.getParameter("notestobatch");
        String notesToBenefits = request.getParameter("notestobenefits");
        String batchId = request.getParameter("eobbatchid");

        double dblPaymentAmount = 0.0;
        double dblAdjustmentAmount = 0.0;
        double dblPatientResponsible = 0.0;
        int paymentId = 0;

        try {
            dblPaymentAmount = Double.parseDouble(paymentAmount.replaceAll("\\$", "").replaceAll(",",""));
        } catch (Exception pmtExecp) {
        }

        try {
            dblAdjustmentAmount = Double.parseDouble(adjustmentAmount.replaceAll("\\$", "").replaceAll(",",""));
        } catch (Exception adjExecp) {
        }

        try {
            dblPatientResponsible = Double.parseDouble(patientAmount.replaceAll("\\$", "").replaceAll(",",""));
        } catch (Exception adjExecp) {
        }

        PreparedStatement batchChargePs = io.getConnection().prepareStatement("UPDATE batchcharges bc left join batches b on bc.batchid=b.id set bc.complete=1 where bc.chargeid=? and provider=?");
        PreparedStatement eobReasonPs = io.getConnection().prepareStatement("select * from eobreasons where id=?");
        PreparedStatement eobExceptionPs = io.getConnection().prepareStatement("insert into eobexceptions (chargeid, paymentid, reasonid, amount, `date`) values (?, ?, ?, ?, ?)");
        PreparedStatement lPs = io.getConnection().prepareStatement("insert into payments (provider, checknumber, amount, chargeid, patientid, date, parentpayment, originalamount) values(?, ?, ?, ?, ?, ?, ?, ?)");
        PreparedStatement bcPs = io.getConnection().prepareStatement("insert into billbatchcomments (batchid, patientid, comments) values(?,?,?) ON DUPLICATE KEY UPDATE comments=concat(comments,'\n',?)");
        PreparedStatement piPs = io.getConnection().prepareStatement("update patientinsurance set notes=case when notes = '' then ? else concat(notes,'\n',?) end where patientid=? and providerid=?");
        PreparedStatement ptPs = io.getConnection().prepareStatement("update patients set attentionmsg=case when attentionmsg='' then ? else concat(attentionmsg,'\n',?) end where id=?");

        lPs.setString(2, checkNumber);
        lPs.setString(4, chargeId);
        lPs.setString(5, patientId);
        lPs.setString(6, Format.formatDate(paymentDate, "yyyy-MM-dd"));
        lPs.setInt(7, 0);

        try {
            if(dblPaymentAmount != 0.0) {
                lPs.setString(1, providerId);
                lPs.setDouble(3, dblPaymentAmount);
                lPs.setDouble(8, dblPaymentAmount);
                lPs.execute();

                io.setMySqlLastInsertId();
                paymentId=io.getLastInsertedRecord();
            }
        } catch (Exception payerException) {
            processed = false;
        }

        try {
            if(processed && dblAdjustmentAmount != 0.0 && eobReasonId.equals("0") && Double.parseDouble(adjustment.replaceAll("\\$", "").replaceAll(",","")) == 0.0) {
                ResultSet lRs = io.opnRS("select * from providers where isadjustment");
                if(lRs.next()) {
                    lPs.setString(1, lRs.getString("id"));
                    lPs.setDouble(3, dblAdjustmentAmount);
                    lPs.setDouble(8, dblAdjustmentAmount);
                    lPs.execute();

                    lRs.close();
                    lRs = null;
                }
            }
            
            try{
                if(processed) {
                    eobReasonPs.setString(1, eobReasonId);
                    ResultSet eobReasonRs=eobReasonPs.executeQuery();
                    if(eobReasonRs.next()) {
                        if(eobReasonRs.getString("type").toUpperCase().equals("D")) {
                            PreparedStatement dedPs=io.getConnection().prepareStatement("INSERT INTO deductables (batchid, patientid, `date`, amount) VALUES(?,?,?,?) ON DUPLICATE KEY UPDATE amount=amount+?");
                            dedPs.setString(1, "0");
                            dedPs.setString(2, patientId);
                            dedPs.setString(3, Format.formatDate(paymentDate, "yyyy-MM-dd"));
                            dedPs.setDouble(4, dblPatientResponsible);
                            dedPs.setDouble(5, dblPatientResponsible);
                            dedPs.execute();
                        }

                        if(eobReasonRs.getString("type").toUpperCase().equals("A")) {
                            lPs.setString(1, "10");
                            lPs.setString(2, "WO_" + checkNumber);
                            lPs.setDouble(3, dblPatientResponsible);
                            lPs.setDouble(8, dblPatientResponsible);
                            lPs.execute();
                        }

                        if(eobReasonId != null && !eobReasonId.equals("0") && !eobReasonRs.getString("type").equals("A")){
                            eobExceptionPs.setString(1, chargeId);
                            eobExceptionPs.setInt(2, paymentId);
                            eobExceptionPs.setString(3, eobReasonId);
                            eobExceptionPs.setDouble(4, dblPatientResponsible);
                            eobExceptionPs.setString(5, Format.formatDate(paymentDate, "yyyy-MM-dd"));
                            eobExceptionPs.execute();
                        }
                    }
                }
            } catch (Exception eobException) {
            }
        } catch (Exception adjustmentException) {
            processed=false;
        }

        if(processed) {
            PreparedStatement ediPs;
            if(request.getParameter("exceptionrecord") == null || request.getParameter("exceptionrecord").equals("0")) {
                ediPs = io.getConnection().prepareStatement("update edipayments set processed=1 where id=" + id);
            } else {
                ediPs = io.getConnection().prepareStatement("update ediexceptions set processed=1 where id=" + id);
            }
            ediPs.execute();

            batchChargePs.setString(1, chargeId);
            batchChargePs.setString(2, providerId);
            batchChargePs.execute();
        }
        
        if(attentionMsg != null && !attentionMsg.trim().equals("")) {
            ptPs.setString(1, attentionMsg);
            ptPs.setString(2, attentionMsg);
            ptPs.setString(3, patientId);
            ptPs.execute();
        }
        
        if(notesToBatch != null && !notesToBatch.trim().equals("")) {
            ResultSet bcRs = io.opnRS("select b.id from batchcharges bc left join batches b on bc.batchid=b.id where bc.chargeid=" + chargeId + " and b.provider=" + providerId);
            if(bcRs.next()) {
                bcPs.setString(1, bcRs.getString("id"));
                bcPs.setString(2, patientId);
                bcPs.setString(3, notesToBatch);
                bcPs.setString(4, notesToBatch);
                bcPs.execute();
            }
        }
        
        if(notesToBenefits != null && !notesToBenefits.trim().equals("")) {
            piPs.setString(1, notesToBenefits);
            piPs.setString(2, notesToBenefits);
            piPs.setString(3, patientId);
            piPs.setString(4, providerId);
            piPs.execute();
        }
    }
%>
<%! public String getPayerListForPatient(RWConnMgr io, int patientId) {
        StringBuffer s = new StringBuffer();
        try {
            ResultSet pRs = io.opnRS("Select * from patientinsurance left join providers on providers.id=providerid where patientid=" + patientId + " order by primaryprovider desc, active desc, name, providernumber");
            while(pRs.next()) {
                if(pRs.getRow() == 1) { s.append("<select name=\"providerid\" id=\"providerid\" class=\"cBoxText\">"); }
                s.append("<option value=\"" + pRs.getString("providerid") + "\">" + pRs.getString("name") + "</option>");
            }
            if(s.length()>0) { s.append("</select>"); }
            pRs.close();
            pRs=null;
        } catch (Exception e) {
            s.append("error...");
        }
        return s.toString();
    }
%>
<%@include file="cleanup.jsp" %>