<%-- 
    Document   : gethint.jsp
    Created on : Sep 10, 2008, 10:18:43 AM
    Author     : Randy Wandell
--%>
<%@page import="medical.*, tools.*, java.sql.ResultSet" %>
<%
String hint="";
try {
    String q=request.getParameter("q").toUpperCase();
    String databaseName=(String)session.getAttribute("databaseName");
    RWConnMgr io = new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);
    ResultSet lRs=io.opnRS("select concat(firstname,' ',lastname) as name, homephone, workphone, cellphone, email, ifnull(preferredcontact,0) as preferredcontact from patients where id=" + q);

    String spaces="&nbsp;&nbsp;&nbsp;";
    String [] boldStart = { "", "", "" };
    String [] boldEnd = { "", "", "" };

    hint += "<v:roundrect arcsize='.25' style=\"width: 225; height: 125l\">";

    if(lRs.next()) {
        boldStart[lRs.getInt("preferredcontact")]="<b>";
        boldEnd[lRs.getInt("preferredcontact")]="</b>";

        hint+=spaces+"<b>" + lRs.getString("name") + "</b></br><hr>";
        hint+=spaces+"Home Phone: " + boldStart[0] + tools.utils.Format.formatPhone(lRs.getString("homephone")) + boldEnd[0] + "</br>";
        hint+=spaces+"Work Phone: " + boldStart[1] + tools.utils.Format.formatPhone(lRs.getString("workphone")) + boldEnd[1] + "</br>";
        hint+=spaces+"Cell Phone: " + boldStart[2] + tools.utils.Format.formatPhone(lRs.getString("cellphone")) + boldEnd[2] + "</br>";
        hint+=spaces+"E-Mail: " + lRs.getString("email");

    }

    hint += "</v:roundrect>";
    lRs.close();
    io.getConnection().close();

    io=null;
    System.gc();
} catch (Exception e) {
}
out.print(hint);
%>