 <%@include file="template/pagetop.jsp" %>
<script>
    function printReport() {
      window.open('printreport.jsp','print','height=300,width=640,scrollbars=yes,resizable');
    }
    
    function showReport(what) {
        var url = "report_patientbalance.jsp";
        if(what.checked) { url += "?creditOnly=Y"; }
        location.href=url;
    }
   
</script>
<%@ include file="ajax/ajaxstuff.jsp" %>
<%
    String creditOnly = request.getParameter("creditOnly");
    String checked = "";
    RWFilteredList lst = new RWFilteredList(io);
    String title = "Collections";

    String [] cw = { "0", "75", "75","150", "100", "100", "100", "100", "100" };
    String [] ch = { "", "Last Name", "First Name", "Payor Name", "Charges", "Payments", "Chg Bal", "Un-Applied", "Balance" };

    String myQuery = "select aa.id patientid, aa.Lastname, aa.Firstname, ifnull(ProviderName,'Cash') as PayerName, ifnull(a.charges,0) Charges, ifnull(b.payments,0) Payments,ifnull(a.charges,0)-ifnull(b.payments,0) ChgBal,  ifnull(c.payments,0) Unapplied, ifnull(a.charges,0)-ifnull(b.payments,0)-ifnull(c.payments,0) as Balance from " +
                     "patients aa join " +
                     "(select patientid, sum(quantity*chargeamount) charges from charges a join visits b on a.visitid=b.id group by patientid " +
                     ") a on aa.id=a.patientid " +
                     "left join " +
                     "(select patientid,name as providername from patientinsurance aaa join providers bbb on aaa.providerid=bbb.id where primaryprovider) bb on aa.id=bb.patientid left join " +
                     "(select patientid, sum(amount) payments from payments where chargeid<>0 group by patientid) b " +
                     "on a.patientid=b.patientid join " +
                     "(select patientid, sum(amount) payments from payments where chargeid=0 group by patientid) c " +
                     "on a.patientid=c.patientid ";
   
    if(creditOnly != null) { 
        myQuery += "where a.Charges-b.payments-c.payments<0 "; 
        checked="checked";
    }
    myQuery += "order by balance desc";
                        
    lst.setAlternatingRowColors("#e0e0e0", "#cccccc");
    lst.setColumnWidth(cw);
    lst.setFormMethod("POST");
    lst.setDivHeight(300);
    lst.setTableWidth("800");
    lst.setTableBorder("0");
    lst.setUseCatalog(true);
    lst.setColumnFormat(4, "MONEY");
    lst.setColumnFormat(5, "MONEY");
    lst.setColumnFormat(6, "MONEY");
    lst.setColumnFormat(7, "MONEY");
    lst.setColumnFormat(8, "MONEY");

    lst.setUrlField(0);
    
    lst.setOnClickAction(1, "javascript:enableMouseOut=false;ajaxComplete=false;showItem(event,'comments_d_new.jsp?type=6&date=" + Format.formatDate(new java.util.Date(),"yyyy-MM-dd") + "',0,##idColumn##,txtHint) style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    lst.setOnClickAction(2, "javascript:enableMouseOut=false;ajaxComplete=false;showItem(event,'comments_d_new.jsp?type=6&date=" + Format.formatDate(new java.util.Date(),"yyyy-MM-dd") + "',0,##idColumn##,txtHint) style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    
    lst.setOnMouseOverAction(1, "showPhoneNumber(event,##idColumn##,txtHint)");
    lst.setOnMouseOverAction(2, "showPhoneNumber(event,##idColumn##,txtHint)");
    lst.setOnMouseOutAction(1, "showHide(txtHint,'HIDE')");
    lst.setOnMouseOutAction(2, "showHide(txtHint,'HIDE')");
    
    lst.setSummaryColunn(4);
    lst.setSummaryColunn(5);
    lst.setSummaryColunn(6);
    lst.setSummaryColunn(7);
    lst.setSummaryColunn(8);

    out.print("Show Credit Balances Only <input type=\"checkbox\" name=\"creditOnly\" id=\"creditOnly\" onClick=\"showReport(this)\"" + checked + " />");
    out.print(lst.getHtml(request, myQuery, ch));

    out.print("<input type=button class=button value=print onClick=printReport()>");

    session.setAttribute("reportToPrint", lst);
    session.setAttribute("parentLocation", "None");
%>

<%@ include file="template/pagebottom.jsp" %>