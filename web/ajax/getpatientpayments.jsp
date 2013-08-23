<%-- 
    Document   : getpatientpayments
    Created on : Apr 4, 2012, 10:52:28 AM
    Author     : rwandell
--%>
<%@include file="sessioninfo.jsp" %>
<%
    String patientId = request.getParameter("patientId");
    String startDate = request.getParameter("startDate");
    String endDate = request.getParameter("endDate");
    RWHtmlTable htmTb = new RWHtmlTable("60%","0");

    if(startDate != null) { startDate = Format.formatDate(startDate,"yyyy-MM-dd"); }
    if(endDate != null) { endDate = Format.formatDate(endDate,"yyyy-MM-dd"); }

    if(patientId != null) {
        out.print(htmTb.startTable());
        out.print(htmTb.startRow("style=\"background-color: #e0e0e0;\""));
        out.print(htmTb.addCell("<b>Date</b>", RWHtmlTable.CENTER, "width=\"15%\""));
        out.print(htmTb.addCell("<b>Source</b>", RWHtmlTable.LEFT, "width=\"50%\""));
        out.print(htmTb.addCell("<b>Check #</b>", RWHtmlTable.LEFT, "width=\"20%\""));
        out.print(htmTb.addCell("<b>Amount</b>", RWHtmlTable.RIGHT,"width=\"15%\""));
        out.print(htmTb.endRow());

        ResultSet pmtRs = io.opnRS("select `date`, ifnull(name,'Cash') as name, checknumber, amount from payments pm left join providers p on p.id=pm.provider where `date` between '" + startDate + "' and '" + endDate + "' and patientid=" + patientId + " order by `date`");
        while(pmtRs.next()) {
            out.print(htmTb.startRow("style=\"background-color: #e0e0e0;\""));
            out.print(htmTb.addCell(pmtRs.getString("date"), RWHtmlTable.CENTER, "width=\"15%\""));
            out.print(htmTb.addCell(pmtRs.getString("name"), RWHtmlTable.LEFT, "width=\"50%\""));
            out.print(htmTb.addCell(pmtRs.getString("checknumber"), RWHtmlTable.LEFT, "width=\"20%\""));
            out.print(htmTb.addCell(Format.formatCurrency(pmtRs.getDouble("amount")), RWHtmlTable.RIGHT,"width=\"15%\""));
            out.print(htmTb.endRow());
        }
        out.print(htmTb.endTable());
        pmtRs.close();
    }
%>
<%@include file="cleanup.jsp" %>