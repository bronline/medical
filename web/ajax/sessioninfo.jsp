<%@ page import="medical.*, tools.*, tools.print.*, tools.utils.*, java.sql.*, java.util.*, java.math.* " %>
<%
    String databaseName =(String)session.getAttribute("databaseName");
//    RWConnMgr io        = (RWConnMgr)session.getAttribute("connMgr");
    Patient mainPatient     = (Patient)session.getAttribute("patient");
    Visit mainVisit         = (Visit)session.getAttribute("visit");
    Location mainLocation   = (Location)session.getAttribute("location");
    String currentPage  = request.getRequestURI();
    String blanks       = "                    ";
    RWConnMgr io        = new tools.RWConnMgr("localhost", databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);

    System.out.println(databaseName + blanks.substring(databaseName.length()) + " : " + new java.util.Date() + " - " + request.getRemoteAddr() + " - " + currentPage);

    if(io == null) {
        io = new tools.RWConnMgr("localhost", databaseName, "rwtools", "rwtools", io.MYSQL);
    }

    if(io.getConnection() == null) {
        io.setConnection(io.opnmySqlConn());
    } else {
        io.getConnection().close();
        io.setConnection(null);
        io.setConnection(io.opnmySqlConn());
    }

    Patient patient = new Patient(io, mainPatient.getId());
    Environment env = new Environment(io);
    Visit visit = new Visit(io, mainVisit.getId());
    Location location = new Location(io, mainLocation.getId());
    
%>