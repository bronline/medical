<%@page import="tools.*"%>
<%@page import="java.sql.*"%>
<%@page import="java.util.*"%>
<%@page import="tools.utils.*"%>
<%@page import="java.io.*"%>
<%
    String schema = request.getParameter("schema");
    if (schema == null) {
        out.print("No Schema Specified");
    } else {
        RWConnMgr io = new RWConnMgr("localhost",schema,"rwtools","rwtools", RWConnMgr.MYSQL);
        ResultSet lRs = io.opnRS("show table  appointments");
        while (lRs.next()) {
            out.print(lRs.getString(1)+"<br>");
        }
    }
    
    
%>
