<%-- 
    Document   : showchargecomment
    Created on : May 17, 2012, 11:56:55 AM
    Author     : Randy
--%>

<%@include file="sessioninfo.jsp" %>
<%
    String id=request.getParameter("id");
    String chargeId = "";
    String descWidth = "250";
    String tableWidth = "400";
    boolean showDetailsOnly=false;

    ResultSet lRs=io.opnRS("SELECT comments FROM charges where id=" + id);
    RWHtmlTable htmTb=new RWHtmlTable(tableWidth,"0");

    out.print("<div align=\"center\">\n");
    if(lRs.next()) {
        out.print("<v:roundrect style=\"width: 420; height: 160; text-valign: middle; text-align: center;\" arcsize=\".05\">");
        out.print("<div align=\"right\"><b style=\"cursor: pointer;\" onClick=\"showHide(txtHint,'HIDE')\">close</b></div>");
        out.print("<div align=\"left\" style=\"margin-left: 5%; width: 90%;\">");
        out.print(lRs.getString("comments"));
        out.print("</div>\n");
        out.print("</v:roundrect>");

    }

    out.print("<br></div>\n");

    lRs.close();
%>
<%@include file="cleanup.jsp" %>