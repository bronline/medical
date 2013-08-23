<%--
    Document   : getpaymentdetails
    Created on : Jan 20, 2010, 6:57:38 PM
    Author     : Randy
--%>

<%@include file="sessioninfo.jsp" %>
<%
    StringBuffer details=new StringBuffer();
    ResultSet conditionRs=io.opnRS("select * from patientconditions where id=" + request.getParameter("id"));
    if(conditionRs.next()) {
        String detlQry="select id, `date`, description, amount from " +
                       "(select v.id, v.`date`, i.description, c.chargeamount*quantity as amount " +
                       "from visits v " +
                       "left join charges c on c.visitid=v.id " +
                       "left join items i on i.id=c.itemid " +
                       "where v.conditionid=" + conditionRs.getString("id") + " " +
                       "union " +
                       "select v.id, p.`date`, py.name as description, sum(p.amount*-1) as amount " +
                       "from visits v " +
                       "left join charges c on c.visitid=v.id " +
                       "left join payments p on p.chargeid=c.id " +
                       "left join providers py on py.id=p.provider " +
                       "where v.conditionid=" + conditionRs.getString("id") + " and p.id is not null " +
                       "group by p.`date`, py.name) a " +
                       "order by a.`date`";

        String [] cw       = {"0", "100", "250", "100"};
        String [] ch       = {"Id", "Date", "Item Description", "Amount" };

        RWFilteredList lst=new RWFilteredList(io);
        lst.setTableWidth("775");
        lst.setTableBorder("0");

        lst.setColumnWidth(cw);

        lst.setColumnFormat(3, "MONEY");

        details.append("<div align=\"center\" style=\"width: 100%;\">" + lst.getHtml(detlQry, ch) + "</div>");

    }
    conditionRs.close();

    out.print(details.toString());

%>
<%@include file="cleanup.jsp" %>