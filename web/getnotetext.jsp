<%@ page import="medical.*, tools.*, tools.print.*, tools.utils.*, java.sql.*, java.util.*, java.math.* " %>
<%
    String databaseName=(String)session.getAttribute("databaseName");
    RWConnMgr io=new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);

    String q=request.getParameter("q").toUpperCase();
    ResultSet lRs=io.opnRS("select notetext from notetemplates where id=" + q);

    String hint="";

    if(lRs.next()) {
        hint=lRs.getString("notetext");
    }
    lRs.close();
    io.getConnection().close();

    io=null;
    
    out.print(hint);
%>
