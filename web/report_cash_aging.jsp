<%@include file="template/pagetop.jsp" %>
<script type=""text/javascript">
    function printReport(zeroBalances) {
        window.open("print_cash_aging.jsp?showZeroBalances="+zeroBalances,"CashAging");
    }
</script>
<%
    String showZeroBalances = request.getParameter("showZeroBalances");
    if (showZeroBalances==null) showZeroBalances="false";
    boolean zeroBalances = (showZeroBalances.equals("false")) ? false:true;

    // Set up an RWHtmlForm
    RWHtmlForm frm = new RWHtmlForm("frmInput", "", "POST");

    // Show the resource combobox
    out.print(frm.startForm());
    if (showZeroBalances.equals("false")) {
        out.print("<input type=CHECKBOX name=showZeroBalances>" + "<b>Show Zero Balances</b>&nbsp;&nbsp;");
    } else {
        out.print("<input type=CHECKBOX name=showZeroBalances CHECKED>" + "<b>Show Zero Balances</b>&nbsp;&nbsp;");
    }
    out.print(frm.submitButton("go", "class=button"));
    out.print(frm.endForm());

    // Only generate the report if this is a post
    if (request.getMethod().equals("POST")) {
%>
<%@include file="cash_aging_body.jsp" %>
<%
    }

    out.print(frm.button("print", "class=\"button\" onClick=\"printReport('" + showZeroBalances + "')\""));

    System.gc();

%>

<%@ include file="template/pagebottom.jsp" %>