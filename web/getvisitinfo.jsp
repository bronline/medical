<%-- 
    Document   : getvisitinfo
    Created on : Mar 22, 2009, 7:41:25 PM
    Author     : Randy
--%>
<%@ page import="medical.*, tools.*, tools.print.*, tools.utils.*, java.sql.*, java.util.*, java.math.* " %>
<%
    String databaseName = (String)session.getAttribute("databaseName");
    RWConnMgr io=new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);
    RWHtmlTable htmTb = new RWHtmlTable("400","0");

    String visitId = request.getParameter("visitId");
    StringBuffer visitInfo=new StringBuffer();
    
    if(visitId != null) {
        visitInfo.append(htmTb.startTable());
        
        String chargeSql = "select  c.id, i.description, c.chargeamount from charges c left join items i on i.id=c.itemid where c.visitId=" + visitId;
        ResultSet chgRs = io.opnRS(chargeSql);
        while(chgRs.next()) {
            
        }
        chgRs.close();
        visitInfo.append(htmTb.endTable());
    }

    io.getConnection().close();
    response.setHeader("Cache-Control", "no-cache"); 
    out.print(visitInfo.toString());       
%>