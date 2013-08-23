<%-- 
    Document   : print_report_payments_by_cpt
    Created on : Jun 8, 2012, 10:58:24 AM
    Author     : Randy
--%>


<%@include file="globalvariables.jsp" %>
<%
    RWHtmlTable htmTb = new RWHtmlTable("600", "0");

    String reportDate=request.getParameter("reportDate");
    String reportToDate=request.getParameter("reportToDate");

    boolean showDetail=false;
    double chargeTotal=0.0;
    double gtPayments=0.0;
    double gtCharges=0.0;
    String providerId="0";
    String cptCode = "";

    if(reportDate == null || reportDate.equals("")) { reportDate=Format.formatDate(new java.util.Date(), "yyyy-MM-dd"); }
    if(reportToDate == null || reportToDate.equals("")) { reportToDate=Format.formatDate(new java.util.Date(), "yyyy-MM-dd"); }
    if(request.getParameter("chkBox1_cb") != null) { showDetail=true; }
    if(request.getParameter("providerId") != null) { providerId=request.getParameter("providerId"); }
    if(request.getParameter("cptCode") != null) { cptCode=request.getParameter("cptCode"); }

    String myQuery = "select pr.name, concat(i.code, ' - ',i.description) as `procedure`, sum(c.chargeamount*c.quantity) as charges, sum(p.amount) as payments " +
           "from visits v " +
           "left join charges c on c.visitid=v.id " +
           "left join items i on i.id=c.itemid " +
           "left join payments p on p.chargeid=c.id " +
           "left join providers pr on p.provider=pr.id " +
           "where " +
           "not pr.reserved " +
           "and not pr.isadjustment " +
           "and p.provider<>0 " +
           "and v.`date` between '" + Format.formatDate(reportDate, "yyyy-MM-dd") + "' and '" + Format.formatDate(reportToDate, "yyyy-MM-dd") + "' ";


    String chargeQuery = "select DATE_FORMAT(v.`date`,'%m/%d/%y') as dos, concat(pt.firstname,' ',pt.lastname) as name, concat(i.code, ' - ', i.description) as item, c.chargeamount*c.quantity as charge, p.amount " +
                     "from payments p " +
                     "left join charges c on c.id=p.chargeid " +
                     "left join items i on i.id=c.itemid " +
                     "left join visits v on v.id=c.visitid " +
                     "left join patients pt on pt.id=p.patientid " +
                     "where p.provider=? and p.`date`=? and p.checknumber=?";

    if(providerId != null && !providerId.equals("0")) { myQuery += "and chargeid in (select id from charges where visitid in (select id from visits where resourceid=" + providerId + ")) "; }
    if(cptCode != null && !cptCode.equals("--None--")) { myQuery += "and i.code='" + cptCode + "' "; }
    myQuery += "group by i.code, pr.name order by pr.name, i.code";

    ResultSet facilityRs=io.opnRS("select * from facilityaddress order by id");

    if(facilityRs.next()) {
        out.print(htmTb.startTable("600"));
        out.print(htmTb.startRow());
        out.print(htmTb.addCell("","width=300"));
        out.print(htmTb.addCell(facilityRs.getString("facilityname"),"width=300 style=\"font-size: 12; font-weight: bold;\""));
        out.print(htmTb.endRow());
        out.print(htmTb.startRow());
        out.print(htmTb.addCell("","width=300"));
        out.print(htmTb.addCell(facilityRs.getString("facilityaddress"),"width=300 style=\"font-size: 12; font-weight: bold;\""));
        out.print(htmTb.endRow());
        out.print(htmTb.startRow());
        out.print(htmTb.addCell("","width=300"));
        out.print(htmTb.addCell(facilityRs.getString("facilitycsz"),"width=300 style=\"font-size: 12; font-weight: bold;\""));
        out.print(htmTb.endRow());
        out.print(htmTb.endTable());
        out.print("<br/><br/><br/>");
    }

    ResultSet pmtRs=io.opnRS(myQuery);
    PreparedStatement pmtPs=io.getConnection().prepareStatement(chargeQuery);

    out.print("<div align=\"center\" style=\"width: 620px; height: 310px;\">\n");
    out.print("<div align=\"left\">\n");
    out.print(htmTb.startTable("600"));
    out.print(htmTb.startRow());
    out.print(htmTb.headingCell("Payer",htmTb.CENTER,"width=200"));
    out.print(htmTb.headingCell("Procedure",htmTb.CENTER,"width=250"));
    out.print(htmTb.headingCell("Charges",htmTb.RIGHT,"width=75"));
    out.print(htmTb.headingCell("Payments",htmTb.RIGHT,"width=75"));
    out.print(htmTb.endRow());
    out.print(htmTb.endTable());
//    out.print("</div>\n");

//    out.print("<div align=\"left\" style=\"height: 300px; width: 620px; overflow: auto;\">\n");

    out.print(htmTb.startTable("600"));
    while(pmtRs.next()) {
       out.print(htmTb.startRow());
       out.print(htmTb.addCell(pmtRs.getString("name"),htmTb.LEFT,"width=200"));
       out.print(htmTb.addCell(pmtRs.getString("procedure"),htmTb.LEFT,"width=250"));
       out.print(htmTb.addCell(Format.formatCurrency(pmtRs.getString("charges")),htmTb.RIGHT,"width=75"));
       if(showDetail) {
           out.print(htmTb.addCell("","width=75"));
       } else {
           out.print(htmTb.addCell(Format.formatCurrency(pmtRs.getDouble("payments")),htmTb.RIGHT,"width=75"));
       }
       out.print(htmTb.endRow());
    /*
       if(showDetail) {
           pmtPs.setInt(1, pmtRs.getInt("providerid"));
           pmtPs.setString(2, Format.formatDate(pmtRs.getString("checkdate"), "yyyy-MM-dd"));
           pmtPs.setString(3, pmtRs.getString("checknumber"));

           chargeTotal=0.0;

           ResultSet chgRs=pmtPs.executeQuery();

           out.print(htmTb.startRow("style=\"background-color: #e0e0e0;\""));
           out.print(htmTb.startCell("colspan=4"));
           out.print(htmTb.startTable("600"));
           while(chgRs.next()) {
               out.print(htmTb.startRow());
               out.print(htmTb.addCell(chgRs.getString("dos"),htmTb.CENTER,"width=75"));
               out.print(htmTb.addCell(chgRs.getString("name"),"width=125"));
               out.print(htmTb.addCell(chgRs.getString("item"),"width=200"));
               out.print(htmTb.addCell(Format.formatCurrency(chgRs.getDouble("charge")),htmTb.RIGHT,"width=100"));
               out.print(htmTb.addCell(Format.formatCurrency(chgRs.getDouble("amount")),htmTb.RIGHT,"width=100"));
               out.print(htmTb.endCell());

               chargeTotal+=chgRs.getDouble("charge");
               gtCharges+=chgRs.getDouble("charge");
           }

           out.print(htmTb.startRow("style=\"background-color: #e0e0e0;\""));
           out.print(htmTb.addCell("","colspan=2"));
           out.print(htmTb.addCell("<b>Totals</b>",htmTb.RIGHT,"width=100"));
           out.print(htmTb.addCell("<b>"+Format.formatCurrency(chargeTotal)+"</b>",htmTb.RIGHT,"style=\"border-top: 1px solid black;\" width=100"));
           out.print(htmTb.addCell("<b>"+Format.formatCurrency(pmtRs.getDouble("amount"))+"</b>",htmTb.RIGHT,"style=\"border-top: 1px solid black;\" width=100"));
           out.print(htmTb.endRow());

           out.print(htmTb.endTable());
           out.print(htmTb.endCell());
           out.print(htmTb.endRow());
           chgRs.close();
           chgRs=null;

           out.print(htmTb.startRow("style=\"background-color: #e0e0e0; height: 15;\""));
           out.print(htmTb.addCell("", "colspan=4"));
           out.print(htmTb.endRow());
       }
    */
       gtPayments+=pmtRs.getDouble("payments");
       gtCharges+=pmtRs.getDouble("charges");
    }
    out.print(htmTb.endTable());

    out.print("</div>\n");

    out.print("<div align=\"left\">\n");
    out.print(htmTb.startTable("600"));
    out.print(htmTb.startRow("style=\"background-color: #ffffff;\""));
    if(showDetail) {
       out.print(htmTb.addCell("","width=75"));
       out.print(htmTb.addCell("","width=125"));
       out.print(htmTb.addCell("<b>Grand Totals</b>",htmTb.RIGHT,"width=200"));
       out.print(htmTb.addCell("<b>"+Format.formatCurrency(gtCharges)+"</b>",htmTb.RIGHT,"style=\"border-top: 1px solid black;\" width=100"));
    } else {
       out.print(htmTb.addCell("","width=100"));
       out.print(htmTb.addCell("","width=100"));
       out.print(htmTb.addCell("<b>Total Payments</b>",htmTb.RIGHT,"width=300"));
    }
    out.print(htmTb.addCell("<b>"+Format.formatCurrency(gtPayments)+"</b>",htmTb.RIGHT,"style=\"border-top: 1px solid black;\" width=100"));
    out.print(htmTb.endRow());
    out.print(htmTb.endTable());
    out.print("</div>\n");
    out.print("</div>\n");

%>



