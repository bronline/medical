<%-- 
    Document   : print_cash_aging
    Created on : Sep 25, 2012, 11:32:56 AM
    Author     : Randy
--%>
<style media="print" rel="stylesheet" type="text/css">
    .navStuff { DISPLAY: none }
    a:after { content:' [' attr(href) '] ' }
</style>

<input type="submit" name="print_btn" value="print" onclick="window.print();" class="btn navStuff" >
<%@include file="globalvariables.jsp" %>
<%
    String showZeroBalances = request.getParameter("showZeroBalances");
//    if (showZeroBalances==null) showZeroBalances="false";
    boolean zeroBalances = (showZeroBalances.equals("false")) ? false:true;
%>
<%@include file="cash_aging_body.jsp" %>
