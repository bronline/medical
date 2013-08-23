<%-- 
    Document   : patientbalanceinfo
    Created on : Jan 10, 2010, 10:46:10 AM
    Author     : Randy
--%>
<%@include file="sessioninfo.jsp" %>
<%
    String patientId=request.getParameter("patientId");
    String providerId=request.getParameter("providerId");

//    out.print("<v:roundrect id=\"txtHint\" arcsize='.25'>");
    out.print("<div align=\"right\" style=\"font-weight: bold; cursor: pointer;\" onClick=\"showHide(txtHint,'HIDE')\">close</div>");
    ResultSet patRs=io.opnRS("select * from patients p left join patientinsurance pi on pi.patientid=p.id where p.id=" + patientId + " and pi.providerId=" + providerId );
    if(patRs.next()) {
        RWHtmlTable htmTb=new RWHtmlTable("600","0");
        out.print(htmTb.startTable());
        out.print(htmTb.startRow());
        out.print(htmTb.addCell(patRs.getString("firstname") + " " +patRs.getString("lastname") + "&nbsp;&nbsp;&nbsp;" + "DOB: " + Format.formatDate(patRs.getString("dob"), "MM/dd/yyyy"),"class=patientHeading"));
        out.print(htmTb.endRow());
        out.print(htmTb.startRow());
        out.print(htmTb.addCell(patRs.getString("address"),"class=patientHeading"));
        out.print(htmTb.endRow());
        out.print(htmTb.startRow());
        out.print(htmTb.addCell(patRs.getString("city") + ", " + patRs.getString("state") + "  " + patRs.getString("zipcode"),"class=patientHeading"));
        out.print(htmTb.endRow());
        out.print(htmTb.startRow());
        out.print(htmTb.addCell(""));
        out.print(htmTb.endRow());

        ResultSet insRs=io.opnRS("select * from providers where id=" + providerId);
        if(insRs.next()) {
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("<b>" + insRs.getString("name") + "</b>"));
            out.print(htmTb.endRow());
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("<b>ID #: " + patRs.getString("pi.providernumber") + " Group Id: " + patRs.getString("pi.providergroup") + "</b>"));
            out.print(htmTb.endRow());
            if(insRs.getDouble("phonenumber") != 0) {
                String phoneNumber="Phone:&nbsp;&nbsp;&nbsp;" + Format.formatPhone(insRs.getString("phonenumber"));
                if(insRs.getInt("extension") != 0) {
                    phoneNumber += " ext: " + insRs.getString("extension");
                }
                out.print(htmTb.startRow());
                out.print(htmTb.addCell("<b>" + phoneNumber + "</b>"));
                out.print(htmTb.endRow());
            }
            if(!insRs.getString("contactname").trim().equals("")) {
                out.print(htmTb.startRow());
                out.print(htmTb.addCell("<b>Contact :" + insRs.getString("contactname") + "</b>"));
                out.print(htmTb.endRow());
            }
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("<hr>"));
            out.print(htmTb.endRow());
            htmTb.replaceNewLineChar(false);
            out.print(htmTb.startRow());
            out.print(htmTb.addCell(getOpenItems(io,patientId,providerId)));
            out.print(htmTb.endRow());
            insRs.close();
        }

        out.print(htmTb.endTable());
//        out.print("</v:roundrect>");
    }
    patRs.close();
%>
<%@include file="cleanup.jsp" %>
<%! public String getOpenItems(RWConnMgr io, String patientId, String providerId) {
        StringBuffer oi=new StringBuffer();
        String myQuery="select p.id, c.id as chargeid, v.`date`, ci.code, ci.description, c.chargeamount*c.quantity charges, " +
                "ifnull((select sum(amount) from payments where chargeid=c.id),0.00) payments " +
                "from charges c " +
                "left join visits v on c.visitid=v.id " +
                "left join patients p on p.id=v.patientid " +
                "left join items ci on ci.id=c.itemid " +
                "left join (select distinct patientid, providerid from patientinsurance) pi on pi.patientid=p.id " +
                "left join providers i on i.id=pi.providerid " +
                "where v.patientid=" + patientId + " and pi.providerid=" + providerId +
                " and c.id in (select chargeid from batchcharges bc join batches b on b.id=bc.batchid where b.provider=" + providerId + ") " +
                "and (c.chargeamount*c.quantity)-(ifnull((select sum(amount) from payments where chargeid=c.id),0.00))>0 " +
                "order by v.`date`";

        try {
            RWHtmlTable htmTb=new RWHtmlTable("580","0");
            oi.append(htmTb.startTable());
            oi.append(htmTb.startRow());
            oi.append(htmTb.headingCell("Date", "width=50"));
            oi.append(htmTb.headingCell("CPT", "width=50"));
            oi.append(htmTb.headingCell("Description","width=300"));
            oi.append(htmTb.headingCell("Charge", RWHtmlTable.RIGHT, "width=60"));
            oi.append(htmTb.headingCell("Payments", RWHtmlTable.RIGHT, "width=60"));
            oi.append(htmTb.headingCell("balance", RWHtmlTable.RIGHT, "width=60"));
            oi.append(htmTb.endRow());
            oi.append(htmTb.endTable());
            oi.append("<div style=\"width: 600; height: 200; overflow: auto;\">");
            ResultSet chgRs=io.opnRS(myQuery);

            oi.append(htmTb.startTable());
            double balance=0.0;
            while(chgRs.next()) {
                oi.append(htmTb.startRow());
                oi.append(htmTb.addCell(Format.formatDate(chgRs.getString("date"),"MM/dd/yy"), "width=50"));
                oi.append(htmTb.addCell(chgRs.getString("code"), "width=50"));
                oi.append(htmTb.addCell(chgRs.getString("description"),"width=300"));
                oi.append(htmTb.addCell(Format.formatCurrency(chgRs.getDouble("charges")), RWHtmlTable.RIGHT,"width=60"));
                oi.append(htmTb.addCell(Format.formatCurrency(chgRs.getDouble("payments")), RWHtmlTable.RIGHT, "width=60"));
                oi.append(htmTb.addCell(Format.formatCurrency(chgRs.getDouble("charges")-chgRs.getDouble("payments")), RWHtmlTable.RIGHT, "width=60"));
                oi.append(htmTb.endRow());
                oi.append(getPaymentsForCharge(io, htmTb, providerId, chgRs.getInt("chargeid")));
                balance += chgRs.getDouble("charges")-chgRs.getDouble("payments");
            }
            oi.append(htmTb.endTable());
            oi.append("</div>");

            oi.append(htmTb.startTable());
            oi.append(htmTb.startRow());
            oi.append(htmTb.addCell("<hr>"));
            oi.append(htmTb.endRow());
            oi.append(htmTb.startRow());
            oi.append(htmTb.addCell(Format.formatCurrency(balance), RWHtmlTable.RIGHT, ""));
            oi.append(htmTb.endRow());
            oi.append(htmTb.endTable());

            chgRs.close();
        } catch (Exception e) {
            oi.append(e.getMessage());
        }
        return oi.toString();
    }

    public String getPaymentsForCharge(RWConnMgr io, RWHtmlTable htmTb, String providerId, int chargeId) {
        StringBuffer ci=new StringBuffer();
        try {
            ResultSet pmtRs=io.opnRS("select * from payments p left join providers pi on pi.id=p.provider where chargeid=" + chargeId + " order by `date` ");
            while(pmtRs.next()) {
                ci.append(htmTb.startRow());
                ci.append(htmTb.addCell(""));
                ci.append(htmTb.startCell("colspan=2 style=\"background-image: url('css/opaque_processing.png')\""));
                ci.append(htmTb.startTable("350"));
                ci.append(htmTb.startRow());
                ci.append(htmTb.addCell(Format.formatDate(pmtRs.getString("date"),"MM/dd/yy"), RWHtmlTable.CENTER,"width=50"));
                ci.append(htmTb.addCell(pmtRs.getString("checknumber"), "width=50"));
                ci.append(htmTb.addCell(pmtRs.getString("name"), "width=150"));
                ci.append(htmTb.addCell(Format.formatCurrency(pmtRs.getDouble("amount")), RWHtmlTable.RIGHT, "width=100"));
                ci.append(htmTb.endRow());
                ci.append(htmTb.endTable());
                ci.append(htmTb.endCell());
                ci.append(htmTb.addCell("","colspan=3"));
                ci.append(htmTb.endRow());

            }
            pmtRs.close();
            if(ci.length() != 0) {
                ci.append(htmTb.startRow());
                ci.append(htmTb.addCell("<hr>", "colspan=6"));
                ci.append(htmTb.endRow());
            }
        } catch (Exception e) {

        }

        return ci.toString();
    }
%>