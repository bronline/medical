<%-- 
    Document   : logout
    Created on : Nov 23, 2011, 8:15:23 AM
    Author     : rwandell
--%>

<%@page contentType="text/html" pageEncoding="windows-1252"%>
<%@ page import="medical.*, medical.utiils.InfoBubble, tools.*, tools.print.*, tools.utils.*, java.sql.*, java.util.*, java.math.*,java.util.Enumeration" %>
<link rel="stylesheet" type="text/css" href="css/stylesheet.css" title="stylesheet">
<script type="text/javascript" src="js/date-picker.js"></script>
<script type="text/javascript" src="js/CheckDate.js"></script>
<script type="text/javascript" src="js/CheckLength.js"></script>
<script type="text/javascript" src="js/colorpicker.js"></script>
<script type="text/javascript" src="js/datechecker.js"></script>
<script type="text/javascript" src="js/dFilter.js"></script>
<script type="text/javascript" src="js/currency.js"></script>
<script type="text/javascript" src="js/checkemailaddress.js"></script>
<script type="text/javascript" src="js/invertselection.js"></script>
<script type="text/javascript" src="js/setCheckBoxValue.js"></script>
<script type="text/javascript" src="js/autologout.js"></script>
<%

    String parmsPassed  = "";
    String appender = "";
    java.util.Enumeration parmEnum = null;
    String thisParm= "";
    String thisParmValue= "";
    parmEnum = request.getParameterNames();
    boolean injectionAttempt=false;
    int count=0;

    RWConnMgr sqlIo=new RWConnMgr("localhost", "rwcatalog", "rwtools", "rwtools", RWConnMgr.MYSQL);
    // check to see if the user is a known user of the software
    ResultSet usrRs=sqlIo.opnRS("select count(id) from useripaddresses where ipaddress='" + request.getRemoteAddr() + "'");
    if(!usrRs.next()) {
        // repeat offenders for sql injection
        ResultSet injRs=sqlIo.opnRS("select count(id) from sqlinjections where ipaddress='" + request.getRemoteAddr() + "'");
        if(injRs.next()) {
            if(injRs.getInt(1)>0) {
                System.out.println("*** BLOCKED ADDRESS ON " + new java.util.Date() + " DOMAIN: " + request.getServerName() + " FROM " + request.getRemoteAddr() + " : " + request.getQueryString());
                PreparedStatement lPs=sqlIo.getConnection().prepareStatement("insert into sqlinjections (ipaddress, sqlstatement) values(?,?)");
                lPs.setString(1, request.getRemoteAddr());
                lPs.setString(2, "BLOCKED " + request.getServerName()+request.getContextPath()+request.getServletPath());
                lPs.execute();

                response.sendRedirect("404.jsp");
                return;
            }
        }
        injRs.close();

        // The following was put here to prevent SQL injection
        java.util.ArrayList blackList=new java.util.ArrayList();
        ResultSet blRs=sqlIo.opnRS("select term from sqlblacklistitems");
        while(blRs.next()) {
            blackList.add(blRs.getString("term"));
        }
        blRs.close();
        blRs=null;



        java.util.ArrayList qsParm=new java.util.ArrayList();
        String queryString=request.getQueryString();
        String qsValue="";

        if(queryString != null) {
            while(queryString.contains("?") || queryString.contains("&") || queryString.length()>0 ) {
                if(queryString.indexOf("=")>-1) {
                    String qParm=queryString.substring(0,queryString.indexOf("="));
                    queryString=queryString.substring(queryString.indexOf("=")+1);
                    if(!queryString.contains("&")) {
                         qsValue=queryString.substring(0);
                         queryString="";
                    } else {
                        qsValue=queryString.substring(0,queryString.indexOf("&"));
                        queryString=queryString.substring(queryString.indexOf("&")+1);
                    }

                    count=0;
                    for(int xx=0;xx<blackList.size();xx++) {
                        if(qsValue.toUpperCase().contains(((String)blackList.get(xx)).toUpperCase())) { count++; }
                    }

                    if(count>0) {
                        thisParm=qParm;
                        thisParmValue=qsValue;
                        injectionAttempt=true;
                        break;
                    }
                } else {
                    queryString="";
                }
            }
        }

        if(!injectionAttempt) {
            while (parmEnum.hasMoreElements()) {
                thisParm = (String)parmEnum.nextElement();
                thisParmValue = request.getParameter(thisParm);

                parmsPassed += appender + thisParm + "=" + thisParmValue;
                appender = "&";
            }
        }

        if(injectionAttempt) {
            System.out.println("*** SQL INJECTION ATTEMPT ON " + new java.util.Date() + " DOMAIN: " + request.getServerName() + " FROM " + request.getRemoteAddr() + " : " + request.getQueryString());
            PreparedStatement lPs=sqlIo.getConnection().prepareStatement("insert into sqlinjections (ipaddress, sqlstatement) values(?,?)");
            lPs.setString(1, request.getRemoteAddr());
            lPs.setString(2, request.getServerName()+request.getContextPath()+request.getServletPath()+"?"+request.getQueryString()+" parameter: " +thisParm + " value: " + thisParmValue);
            lPs.execute();

            response.sendRedirect("404.jsp");
            return;
        }

      } else {
            while (parmEnum.hasMoreElements()) {
                thisParm = (String)parmEnum.nextElement();
                thisParmValue = request.getParameter(thisParm);

                parmsPassed += appender + thisParm + "=" + thisParmValue;
                appender = "&";
            }
      }

    sqlIo.getConnection().close();
    sqlIo=null;

    String databaseName = (String)session.getAttribute("databaseName");
    RWConnMgr io        = (RWConnMgr)session.getAttribute("connMgr");
    RWConnMgr altIo     = (RWConnMgr)session.getAttribute("altConnMgr");
    Patient patient     = (Patient)session.getAttribute("patient");
    Environment env     = (Environment)session.getAttribute("env");
    Visit visit         = (Visit)session.getAttribute("visit");
    Location location   = (Location)session.getAttribute("location");
    String currentPage  = request.getRequestURI();
    
    io=null;
    altIo=null;
    patient=null;
    visit=null;
    env=null;
    location=null;

    for(Enumeration e=session.getAttributeNames(); e.hasMoreElements();) {
        String paramName = (String)e.nextElement();
        session.removeAttribute(paramName);
    }

    if(databaseName == null) { databaseName="medical"; }

%>
<body topmargin="0" leftmargin="0" style="background-color: #000066;  background-image: url('/medicaldocs/bg_page.gif'); ">
<table height="100%" width="100%" border=0 cellpadding=0 cellspacing=0>
  <tr>
    <td height=75 colspan=2>
        <table  width=100% border=0 cellpadding=0 cellspacing=0>
            <tr>
                <td width="45%" bgcolor=white align=left><img src="/medicaldocs/<% out.print(databaseName); %>/images/topleft.JPG" height=75 alt=""></td>
                <td width="10%" bgcolor=white align=left><img src="/medicaldocs/<% out.print(databaseName); %>/images/topcenter.JPG" height=75 alt=""></td>
                <td width="45%" bgcolor=white align=right><img src="/medicaldocs/<% out.print(databaseName); %>/images/topright.JPG" height=75 alt=""></td>
            </tr>
            <tr>
                <td width="100%" colspan=3 height=3 bgcolor=navy></td>
            </tr>
        </table>
    </td>
  </tr>
  <tr>
      <td>
        <div align="center">
        <v:roundrect id="logoutBubble" fillcolor="#ffffff" arcsize=".06" strokecolor="#cccccc" strokeweight="0px" style="border-color: transparent; background-color: #ffffff; height: 200; width: 800; ">
            <h1>You have been logged out. To log in again, click <a href="login.jsp">here</a></h1>
        </v:roundrect>
        </div>
      </td>
  </tr>
</table>

</body>
<% System.gc(); %>

