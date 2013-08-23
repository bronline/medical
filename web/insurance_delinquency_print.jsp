<%-- 
    Document   : insurance_delinquency_print
    Created on : Jul 23, 2010, 7:30:29 AM
    Author     : rwandell
--%>

<%@page contentType="text/html" pageEncoding="windows-1252"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
   "http://www.w3.org/TR/html4/loose.dtd">
<%@include file="globalvariables.jsp" %>
<style media="print" rel="stylesheet" type="text/css">
    .navStuff { DISPLAY: none }
    a:after { content:' [' attr(href) '] ' }
</style>

<input type="submit" name="print_btn" value="print" onclick="window.print();" class="btn navStuff" >
<%@include file="insurance_delinquency_body.jsp" %>