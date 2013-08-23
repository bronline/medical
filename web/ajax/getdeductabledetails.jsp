<%-- 
    Document   : getdeductabledetails
    Created on : Nov 17, 2010, 1:52:06 PM
    Author     : rwandell
--%>

<%--
    Document   : getpaymentdetails
    Created on : Jan 20, 2010, 6:57:38 PM
    Author     : Randy
--%>

<%@include file="sessioninfo.jsp" %>
<%
    StringBuffer details=new StringBuffer();
    String visitId = request.getParameter("id");
    try {
        if(visitId != null) {
            String detlQry="select v.id, v.`date`, i.description, FORMAT(c.quantity,2) AS quantity, (c.quantity*c.chargeamount) chargeamount, " +
                    "IFNULL((select sum(amount) from payments where chargeid=c.id),0) AS payments, " +
                    "IFNULL((select sum(amount) from eobexceptions left join eobreasons on reasonid=eobreasons.id where chargeid=c.id and `type`='D'),0) AS deductables, "+
                    "IfNull((c.quantity*c.chargeamount),0)-IFNULL((select sum(amount) from payments where chargeid=c.id),0) balance " +
                    "from visits v " +
                    "left join charges c on c.visitid=v.id " +
                    "left join items i on i.id=c.itemid " +
                    "where v.id=" + visitId + " " +
                    "ORDER BY c.id";

            String [] cw       = {"0", "75", "250", "75", "75", "75", "75", "75"};
            String [] ch       = {"Id", "Date", "Charge Description", "Quantity", "Charge<br/>Amount", "Payments/<br>Adjustments", "Deductables", "Charge</br>Balance" };

            RWFilteredList lst=new RWFilteredList(io);
            lst.setTableWidth("700");
            lst.setTableBorder("0");

            lst.setColumnWidth(cw);

            lst.setColumnAlignment(3, "RIGHT");
            lst.setColumnAlignment(4, "RIGHT");
            lst.setColumnAlignment(5, "RIGHT");
            lst.setColumnAlignment(6, "RIGHT");
            lst.setColumnAlignment(7, "RIGHT");

            lst.setColumnFormat(4, "MONEY");
            lst.setColumnFormat(5, "MONEY");
            lst.setColumnFormat(6, "MONEY");
            lst.setColumnFormat(7, "MONEY");

            lst.setSummaryColunn(7);

            details.append("<div align=\"center\" style=\"width: 100%;\">" + lst.getHtml(detlQry, ch) + "<br/></div>");
        }
    } catch (Exception e) {
    }
    out.print(details.toString());
%>
<%@include file="cleanup.jsp" %>