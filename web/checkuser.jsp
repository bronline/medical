<%-- 
    Document   : checkuser
    Created on : Nov 23, 2011, 9:27:15 AM
    Author     : rwandell
--%>

<%@page contentType="text/html" pageEncoding="windows-1252"%>
<%@ page import="medical.*, medical.utiils.InfoBubble, tools.*, tools.print.*, tools.utils.*, java.sql.*, java.util.*, java.math.* " %>
<%
    String userName=request.getParameter("userName");
    String password=request.getParameter("password");
    String returnLocation="login.jsp";

    RWConnMgr cm = new RWConnMgr("localhost", "chiro_site", "rwtools", "rwtools", RWConnMgr.MYSQL);
    if(request.getParameter("userName") != null) {
        String userQry = "SELECT * FROM userinfo ui " +
                "LEFT JOIN userroles ur ON ur.rolprf=ui.id " +
                "LEFT JOIN roles r ON r.id=ur.role " +
                "WHERE secprf='" + request.getParameter("userName") + "' AND r.applicationid=6";
        ResultSet uRs = cm.opnRS(userQry);
        if(uRs.next()) {
            if(uRs.getString("secpass").equals(request.getParameter("password"))) {
                session.setAttribute("databaseName", userName);
                returnLocation="patientmaint.jsp";
            } else {
                session.setAttribute("errorMessage", "User name or password is not valid");
            }
        } else {
            session.setAttribute("errorMessage", "User name or password is not valid");
        }
        uRs.close();
    } else {
        session.setAttribute("errorMessage", "User name must be entered");
    }

    cm.getConnection().close();
    cm=null;

    System.gc();

    response.sendRedirect(returnLocation);
%>
