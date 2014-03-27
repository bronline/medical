<%@ page import="medical.*, medical.utiils.InfoBubble, medical.utiils.PDF, tools.*, tools.print.*, tools.utils.*, java.sql.*, java.util.*, java.math.* " %>
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
<%@include file="ajax/autocomplete.jsp" %>
<!-- Declare the VML namespace -->
<xml:namespace ns="urn:schemas-microsoft-com:vml" prefix="v" />
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
//      if(usrRs.getInt(1)>0) {
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

//    }

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
    String blanks       = "                    ";
//    String parmsPassed  = "";

    if(databaseName == null) { databaseName=request.getParameter("databaseName"); }
    if(databaseName == null || databaseName.equals("")) {
        out.print("<div style='width: 100%; color: white; font-size: 14px; text-align: center;'>Your session has expired and you have been logged off of ChiroPractice</div>");
        return;
    } else {
        session.setAttribute("databaseName", databaseName);

        System.out.println(databaseName + blanks.substring(databaseName.length()) + " : " + new java.util.Date() + " - " + request.getRemoteAddr() + " - " + currentPage);

        if(io == null) {
            io = new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);
        }

        if(io.getConnection() == null) {
            io.setConnection(io.opnmySqlConn());
        } else {
            io.getConnection().close();
            io.setConnection(null);
            io.setConnection(io.opnmySqlConn());
        }

        ResultSet seRs = io.opnRS("select date from date where date < current_date");
        if(seRs.next()) {
            response.sendRedirect("softwareexpired.jsp");
            return;
        }
        seRs.close();

        session.setAttribute("connMgr", io);

        if(altIo == null) {
            altIo = new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);
            session.setAttribute("altConnMgr", altIo);
        }

        if(altIo.getConnection() == null) {
//            altIo.setConnection(altIo.opnmySqlConn());
            altIo = new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);
            session.setAttribute("altConnMgr", altIo);
        } else {
            altIo.getConnection().close();
            altIo = new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);
            session.setAttribute("altConnMgr", altIo);
        }

        if(env == null) {
            env = new Environment(io);
            session.setAttribute("env", env);
        } else {
            try {
                env.setConnMgr(io);
                env.refresh();
            } catch (Exception envException) {
                env = new Environment(io);
                session.setAttribute("env", env);
            }
        }

        if(currentPage.indexOf("elua.jsp")<0 && !env.getBoolean("eluadisplayed")) {
            response.sendRedirect("elua.jsp");
            return;
        }

        if(patient == null) {
            patient = new Patient(io, "0");
            session.setAttribute("patient", patient);
        } else {
            try {
                patient.setConnMgr(io);
                patient.refresh();
            } catch (Exception patException) {
                patient = new Patient(io, "0");
                session.setAttribute("patient", patient);
            }
        }

        if(visit == null) {
            visit = new Visit(io, "0");
            session.setAttribute("visit", visit);
        } else {
            try {
                visit.setConnMgr(io);
                visit.setId(visit.getId());
            } catch (Exception visException) {
                visit = new Visit(io, "0");
                session.setAttribute("visit", visit);
            }
        }

        if(location == null) {
            location = new Location(io, 0);
            session.setAttribute("location", location);
        } else {
            try {
                location.setConnMgr(io);
                location.setId(location.getId());
            } catch (Exception locException) {
                location = new Location(io, 0);
                session.setAttribute("location", location);
            }
        }
        System.gc();
    }

%>
