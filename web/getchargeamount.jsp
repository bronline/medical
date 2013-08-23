<%@ page import="medical.*, tools.*, tools.print.*, tools.utils.*, java.sql.*, java.util.*, java.math.* " %>
<%
    String databaseName = (String)session.getAttribute("databaseName");
    RWConnMgr io        = (RWConnMgr)session.getAttribute("connMgr");
    RWConnMgr altIo     = (RWConnMgr)session.getAttribute("altConnMgr");
    Patient patient     = (Patient)session.getAttribute("patient");
    Environment env     = (Environment)session.getAttribute("env");
    Visit visit         = (Visit)session.getAttribute("visit");
    Location location   = (Location)session.getAttribute("location");
    String currentPage  = request.getRequestURI();
    String parmsPassed  = "";
    
    if(databaseName == null) { databaseName=request.getParameter("databaseName"); }
    if(databaseName == null || databaseName.equals("")) { 
        out.print("<div style='width: 100%; color: white; font-size: 14px; text-align: center;'>YOU ARE NOT AUTHORIZED TO THE CHIROPRACTICE APPLICATION</div>");
    } else {
        session.setAttribute("databaseName", databaseName);

        System.out.println(databaseName + ": " +new java.util.Date() + " - " + request.getRemoteAddr() + " - " + currentPage);

        if(io == null) {
            io = new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", io.MYSQL);
            session.setAttribute("connMgr", io);
        }

        if(io.getConnection() == null) {
            io.setConnection(io.opnmySqlConn());
        } else {
            io.getConnection().close();
            io.setConnectString(null);
            io.setConnection(io.opnmySqlConn());
        }

        if(altIo == null) {
            altIo = new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", altIo.MYSQL);
            session.setAttribute("altConnMgr", altIo);
        }

        if(altIo.getConnection() == null) {
            altIo.setConnection(altIo.opnmySqlConn());
        }

        if(env == null) {
            env = new Environment(io);
            session.setAttribute("env", env);
        } else {
            env.setConnMgr(io);
            env.refresh();
        }

        ResultSet seRs = io.opnRS("select date from date where date < current_date");
        if(seRs.next()) {
            response.sendRedirect("softwareexpired.jsp");
        }
        seRs.close();

        if(currentPage.indexOf("elua.jsp")<0 && !env.getBoolean("eluadisplayed")) { 
            response.sendRedirect("elua.jsp");
        }

        if(patient == null) {
            patient = new Patient(io, "0");
            session.setAttribute("patient", patient);
        } else {
            patient.setConnMgr(io);
            patient.refresh();
        }

        if(visit == null) {
            visit = new Visit(io, "0");
            session.setAttribute("visit", visit);
        } else {
            visit.setConnMgr(io);
            visit.setId(visit.getId());
        }

        if(location == null) {
            location = new Location(io, 0);
            session.setAttribute("location", location);
        } else {
            location.setConnMgr(io);
            location.setId(location.getId());
        }
    }
    
    String id=request.getParameter("id").toUpperCase();
    ResultSet lRs=io.opnRS("select amount from items where id=" + id);

    String hint="";

    if(lRs.next()) {
        hint=lRs.getString("amount");
    }
    lRs.close();
    
    out.print(hint);
%>
