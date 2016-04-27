<%-- 
    Document   : testmysql
    Created on : Apr 7, 2016, 9:05:15 AM
    Author     : Randy
--%>

<%@page import="java.sql.DriverManager"%>
<%@ page import="com.mysql.jdbc.*, java.sql.DriverManager, medical.*, tools.*, tools.print.*, tools.utils.*, java.util.*, java.math.* " %>

<%
    String parmsPassed  = "";
    String appender = "";
    java.util.Enumeration parmEnum = null;
    String thisParm= "";
    String thisParmValue= "";
    parmEnum = request.getParameterNames();
    boolean injectionAttempt=false;
    int count=0;

    RWConnMgr sqlIo=new RWConnMgr("127.9.154.2", "rwcatalog", "rwtools", "rwtools", RWConnMgr.MYSQL);
    ResultSet lRs = sqlIo.opnRS("select * from catalog");

%>
