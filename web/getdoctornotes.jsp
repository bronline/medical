<%-- 
    Document   : getdoctornotes
    Created on : Sep 17, 2009, 6:11:13 PM
    Author     : Randy
--%>
<%@ include file="globalvariables.jsp" %>
<%
    String patientId=request.getParameter("patientid");
    ResultSet lRs=io.opnRS("select * from doctornotes where patientid=" + patientId + " order by notedate desc");
    RWHtmlTable htmTb=new RWHtmlTable("470","0");
    out.print("<v:roundrect style='width: 500; height: 215; text-valign: middle; text-align: center; arcsize='.25' fillcolor='#3399bb'>");
    out.print("<div style='height: 210; width: 490; overflow: auto;'>");
    out.print(htmTb.startTable());
    out.print(htmTb.startRow());
    out.print(htmTb.addCell("close", htmTb.RIGHT,"colspan=3 style=\"font-weight: bold; cursor: pointer; color: #000000;\" onClick=\"javascript:showHide(txtHint,'HIDE');\""));
    out.print(htmTb.endRow());
    while(lRs.next()) {
        out.print(htmTb.startRow());
        out.print(htmTb.addCell("<b>" + Format.formatDate(lRs.getString("notedate"),"MM/dd/yyyy"), "width=100"));
        out.print(htmTb.addCell(lRs.getString("note"),"width=300"));
        out.print(htmTb.addCell("","width=70"));
        out.print(htmTb.endRow());
        out.print(htmTb.startRow());
        out.print(htmTb.addCell("","colspan=2"));
        out.print(htmTb.endRow());
    }
    out.print(htmTb.endTable());
    out.print("</div>");
    out.print("</v:roundrect>");
    lRs.close();
%>
