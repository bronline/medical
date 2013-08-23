<%-- 
    Document   : getunbilledcharges
    Created on : Jul 29, 2013, 1:12:52 PM
    Author     : Randy
--%>
<%@include file="sessioninfo.jsp" %>
<%
    StringBuffer details=new StringBuffer();
    ResultSet pmtRs=io.opnRS("select * from providers where id=" + request.getParameter("id"));
    if(pmtRs.next()) {
        String myQuery="Select " +
                "charges.id, " +
                "concat(patients.lastname,', ',patients.firstname) as patientname, " +
                "DATE_FORMAT(visits.`date`, '%m/%d/%y') as dos, " +
                "concat(items.code, ' - ', items.description) as itemname, " +
                "FORMAT(charges.quantity,0) as quantity, " +
                "charges.chargeamount, " +
                "(charges.quantity*charges.chargeamount-payments) as extendedamount, " +
//                "concat('<input type=\"button\" class=\"button\" id=\"btn',charges.id,'\" name=\"btn',charges.id,'\" onClick=\"batchFunctions(this,',charges.id,')\" value=\"add to batch\">') as batchbutton " +
                "concat('<div class=\"listButton\" style=\"width: 75px;\" id=\"btn',charges.id,'\" name=\"btn',charges.id,'\" onClick=\"batchFunctions(this,',charges.id,',',providers.id,')\">add to batch</div>') as batchbutton, " +
                "concat('<div class=\"listButton\" style=\"width: 75px;\" id=\"btn1',charges.id,'\" name=\"btn1',charges.id,'\" onClick=\"markChargeNonBillable(this,',charges.id,',',providers.id,')\">billable</div>') as billablebutton " +
                "from charges " +
                "left join items on charges.itemid=items.id " +
                "left join batchcharges on batchcharges.chargeid=charges.id " +
                "left join visits on charges.visitid=visits.id " +
                "left join patients on visits.patientid=patients.id " +
                "left join patientinsurance on patients.id=patientinsurance.patientid and patientinsurance.primaryprovider=1 and not ispip " +
                "left join providers on patientinsurance.providerid=providers.id " +
                "left join (select chargeid, sum(amount) as payments from payments group by chargeid) p on p.chargeid=charges.id " +
                "where " +
                "providers.id=" + request.getParameter("id") + " and " +
                "batchcharges.id is null and " +
                "((charges.billinsurance=0 and items.billinsurance=1) or (charges.billinsurance=2)) and " +
                "(charges.quantity*charges.chargeamount-payments)>0 " +
                "order by " +
                "patients.lastname, " +
                "patients.firstname, " +
                "visits.`date`, " +
                "charges.id";
        String [] cw       = {"0", "100", "75", "225", "50", "50", "50", "75", "75"};
        String [] ch       = {"Id", "Patient Name", "DOS", "Procedure", "Quantity", "Charge<br/>Amount", "UnBilled Amount", "", ""};

        RWFilteredList lst=new RWFilteredList(io);
        lst.setTableWidth("100%");
        lst.setTableBorder("0");

        lst.setColumnWidth(cw);
//        lst.setOnClickAction(1, "window.open('payments_d.jsp?id=##idColumn##','Payments','height=150,width=200') style='font-weight: bold; cursor: pointer;'");

        lst.setColumnAlignment(2, "CENTER");
        lst.setColumnAlignment(4, "RIGHT");
        lst.setColumnAlignment(5, "RIGHT");
        lst.setColumnAlignment(6, "RIGHT");
        lst.setColumnAlignment(7, "CENTER");

        lst.setColumnFormat(5, "MONEY");
        lst.setColumnFormat(6, "MONEY");

        details.append("<div align=\"center\" style=\"width: 100%;\">" + lst.getHtml(myQuery, ch) + "</div>");
    }
    pmtRs.close();

    out.print(details.toString());
%>
<%@include file="cleanup.jsp" %>
