<%@ include file="../globalvariables.jsp" %>
<META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">
<META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">
<META HTTP-EQUIV="EXPIRES" CONTENT="0">
<%
//    response.setHeader("Cache-Control", "no-cache");
//    response.setHeader("Pragma", "no-cache");
//    response.setHeader("Pragma", "no-store");

    String absoluteRoot = System.getProperty("catalina.home") + "\\webapps\\medical";

    String self = request.getRequestURI();
    String wordSelf = "";
    String excelSelf = "";
    String printSelf = "";
    String content = request.getParameter("content");
    String parm = "";
    StringBuffer parms = new StringBuffer("");
    boolean redirect=false;
    
    String libraryName="";
    if(databaseName != null) { libraryName=databaseName; }

    if (content == null) {
        content = "HTML";
    }
    for( Enumeration en = request.getParameterNames(); en.hasMoreElements(); ) {
        if (parms.toString()!=""){
            parms.append("&");
        }
        parm = ( String) en.nextElement();
        parms.append(parm + "=" + request.getParameter(parm)); 
    }
    if (parms.toString().length()>0){
        excelSelf = self + "?" + parms.toString() + "&content=EXCEL";
        printSelf = self + "?" + parms.toString() + "&content=PRINT";
        wordSelf = self + "?" + parms.toString() + "&content=WORD";
    } else {
        excelSelf = self + "?content=EXCEL";
        printSelf = self + "?content=PRINT";
        wordSelf = self + "?content=WORD";
    }
    
    if (content.equals("EXCEL")) {
        response.setContentType("application/vnd.ms-excel");
    }
    if (content.equals("WORD")) {
        response.setContentType("application/msword");
    }

    if (!content.equals("WORD") && !content.equals("EXCEL")) {
%>
<html>
<head>
<link rel="stylesheet" type="text/css" href="css/stylesheet.css" title="csstylesheet">
<title>Chiropractic Office Management System</title>

</head>

<body topmargin="0" leftmargin="0" style="background-color: #000066;  background-image: url('/medicaldocs/bg_page.gif'); " onLoad="loadMask(); set_interval()" onmousemove="reset_interval()" onclick="reset_interval()" onkeypress="reset_interval()" onscroll="reset_interval()">
<%
    }
    
    if (content.equals("HTML")) {
%>
<%@ include file="../sliders/leftslider.jsp" %>
<div id="instantMessages" style="text-align: left; background-color: transparent; position: absolute; visibility: hidden; display: none; z-index: 99;"></div>

<%@ include file="../sliders/topslider.jsp" %>
<div align="center" style="position: absolute; top: 0; left: 0; z-index: 100; height: 78px; z-index: 100; background-color: #ffffff; width: 100%">
        <div align="left" style="float: left; width: 15%; z-index: 100;"><img src="/medicaldocs/<% out.print(libraryName); %>/images/topleft.JPG" height=75 alt=""></div>
        <div align="center" style="float: left; width: 70%; z-index: 100;"><img src="/medicaldocs/<% out.print(libraryName); %>/images/topcenter.JPG" height=75 alt=""></div>
        <div align="right" style="float: left; width: 15%; z-index: 100;"><img src="/medicaldocs/<% out.print(libraryName); %>/images/topright.JPG" height=75 alt=""></div>
        <div style="float: left; width: 100%; background-color: navy; height: 3px; z-index: 100;"></div>
</div>

<div align="left" style="position: absolute; top: 100px; width: 100%;">
<table height="100%" width="100%" border=0 cellpadding=0 cellspacing=0>
    <tr>
        <td align="right"><a href="logout.jsp" style="padding-right: 15px; text-decoration: none; color: #ffffff;">logout</a></td>
    </tr>
    <tr>
        <td align=left valign=top>
            <TABLE cellSpacing=5 border=0>
                <TR>
                    <TD valign=top>

<!-- start of body -->              
<% }

//    try {
%>   
<%@ include file="/tabtop.jsp" %>
