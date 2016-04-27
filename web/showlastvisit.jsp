<%@ page import="medical.*, medical.utiils.InfoBubble, tools.*, tools.print.*, tools.utils.*, java.sql.*, java.util.*, java.math.* " %>

<%   
    RWConnMgr io=new RWConnMgr("localhost", "rwcatalog", "rwandell", "bmw525", RWConnMgr.MYSQL);

    ResultSet lRs = io.opnRS("SHOW DATABASES");
    while(lRs.next()) {
        try {
            ResultSet cRs = io.opnRS("SELECT MAX(`date`) AS " + lRs.getString("database") + " from " + lRs.getString("database") + ".visits where `date`>=DATE_ADD(CURRENT_DATE, INTERVAL -18 MONTH) having max(`date`) is not null");
            if(cRs.next()) {
                 out.print("<div style=\"width: 100px; float: left;\">" + lRs.getString("database") + ": </div><div style=\"width: 100px; float: left;\">" + cRs.getString(1) + "</div><br/>");
            }
        } catch (Exception e) {
        }
    }

    lRs.close();
%>
