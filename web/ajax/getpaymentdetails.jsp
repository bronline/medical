<%-- 
    Document   : getpaymentdetails
    Created on : Jan 20, 2010, 6:57:38 PM
    Author     : Randy
--%>

<%@include file="sessioninfo.jsp" %>
<%
    StringBuffer details=new StringBuffer();
    ResultSet pmtRs=io.opnRS("select * from payments where id=" + request.getParameter("id"));
    if(pmtRs.next()) {
        String detlQry="select p.id, v.`date`, i.description, FORMAT(c.quantity,2) AS quantity, (c.quantity*c.chargeamount) chargeamount, " +
                "p.amount, ifnull((select sum(amount) from payments where chargeid=p.chargeid and provider<>p.provider),0) AS otherpayments, " +
                "(c.quantity*c.chargeamount)-p.amount-ifnull((select sum(amount) from payments where chargeid=p.chargeid and provider<>p.provider),0) balance " +
                "from payments p " +
                "left join charges c on c.id=p.chargeid " +
                "left join visits v on c.visitid=v.id " +
                "left join items i on i.id=c.itemid " +
                "where p.provider=" + pmtRs.getInt("provider") +
                " and v.`date` is not null " +
                " and p.checknumber='" + pmtRs.getString("checknumber") + "' " +
                "and p.date='" + pmtRs.getString("date") + "' " +
                "and p.patientid=" + pmtRs.getInt("patientId");
        if(pmtRs.getInt("chargeid") == 0) {
            detlQry="select p.id, v.`date`, i.description, c.quantity, (c.quantity*c.chargeamount) chargeamount, " +
                "p.amount, 0.00 AS otherpayments, (c.quantity*c.chargeamount)-p.amount balance " +
                "from payments p " +
                "left join charges c on c.id=p.chargeid " +
                "left join visits v on c.visitid=v.id " +
                "left join items i on i.id=c.itemid " +
                "where p.parentpayment=" + pmtRs.getInt("id");
        }

        String [] cw       = {"0", "75", "250", "75", "75", "75", "75", "75"};
        String [] ch       = {"Id", "Date", "Charge Description", "Quantity", "Charge<br/>Amount", "This<br/>Trans", "Other<br/>Trans", "Charge</br>Balance" };

        RWFilteredList lst=new RWFilteredList(io);
        lst.setTableWidth("700");
        lst.setTableBorder("0");

        lst.setColumnWidth(cw);
        lst.setOnClickAction(1, "window.open('payments_d.jsp?id=##idColumn##','Payments','height=150,width=200') style='font-weight: bold; cursor: pointer;'");

        lst.setColumnAlignment(3, "RIGHT");
        lst.setColumnAlignment(4, "RIGHT");
        lst.setColumnAlignment(5, "RIGHT");
        lst.setColumnAlignment(6, "RIGHT");
        lst.setColumnAlignment(7, "RIGHT");

        lst.setColumnFormat(4, "MONEY");
        lst.setColumnFormat(5, "MONEY");
        lst.setColumnFormat(6, "MONEY");
        lst.setColumnFormat(7, "MONEY");

        details.append("<div align=\"center\" style=\"width: 100%;\">" + lst.getHtml(detlQry, ch) + "</div>");
    }
    pmtRs.close();

    out.print(details.toString());
%>
<%@include file="cleanup.jsp" %>