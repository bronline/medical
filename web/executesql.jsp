<%-- 
    Document   : executesql
    Created on : Sep 25, 2012, 6:58:09 PM
    Author     : Randy
--%>

<%@ page import="tools.RWConnMgr, com.rwtools.tools.db.utils.DBCompare, java.util.ArrayList, medical.utiils.*, tools.utils.Format, java.sql.*" %>
<%
    RWConnMgr io=new RWConnMgr("localhost", "rwcatalog", "rwtools", "rwtools", RWConnMgr.MYSQL);
    ResultSet lRs = io.opnRS("select * from updatescripts where not processed");
    PreparedStatement lPs = io.getConnection().prepareStatement("update updatescripts set dateprocessed=? where id=?");

    UpdateChiroDatabases upd = new UpdateChiroDatabases();

    while(lRs.next()) {
        upd.executeSQLScript(lRs.getString("script"));
        lPs.setString(1, Format.formatDate(new java.util.Date(), "yyyy-MM-dd hh:mm:ss"));
        lPs.setInt(2, lRs.getInt("id"));
        lPs.execute();
    }

    io.getConnection().close();
%>
