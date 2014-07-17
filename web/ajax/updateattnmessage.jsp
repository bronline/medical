<%-- 
    Document   : updateattnmessage
    Created on : Jul 17, 2014, 9:41:36 AM
    Author     : Randy
--%>
<%@include file="sessioninfo.jsp" %>
<%
    int id = patient.getId();
    String update = request.getParameter("update");
    
    if(id == 0) {
        out.print("Patient not set");
    } else if(update == null) {
        RWHtmlTable htmTb  = new RWHtmlTable("805", "0");
        ResultSet lRs = io.opnRS("select id, attentionmsg from patients where id=" + id);
        
        RWInputForm attnForm=new RWInputForm(lRs);

        attnForm.setTableWidth("660");
        attnForm.setTableBorder("0");
        attnForm.setAction("javascript;updateAttentionMessage();");
        attnForm.setMethod("POST");
        attnForm.lRcd.beforeFirst();
        attnForm.setDftTextAreaCols("110");

        htmTb.setCellVAlign("TOP");
        htmTb.setWidth("700");
        
        out.print("<v:roundrect style=\"width: 700; height: 100; text-valign: middle; text-align: center;\" arcsize=\".05\">");
        out.print("<div align=\"right\"><b style=\"cursor: pointer;\" onClick=\"showHide(txtHint,'HIDE')\">close</b></div>");
        
        if(attnForm.lRs.next()) {
            out.print("<div align=\"center\">\n");
            out.print("<form method=\"POST\">");
            out.print(attnForm.hidden(attnForm.lRs.getString("id"), "rcd"));
            out.print(htmTb.startTable());
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("Attention Message: "));
            out.print(htmTb.addCell(attnForm.getInputItemOnly("attentionmsg", "class=tBoxText")));
            out.print(htmTb.addCell(attnForm.button("update", "class=button onClick=\"updateAttentionMessage('y')\"")));
            out.print(htmTb.endTable());
            out.print("</form>");
            out.print("</div>\n");
        }
        
        out.print("</v:roundrect>");
        lRs.close();
        lRs=null;

    } else if(update != null && update.equals("y")) {
        String attnMessage = request.getParameter("attentionmsg");
        
        if(attnMessage != null) {
            PreparedStatement lPs = io.getConnection().prepareStatement("UPDATE patients set attentionmsg=? where id=?");
            lPs.setString(1, attnMessage);
            lPs.setInt(2, id);
            
            lPs.execute();
        }
        
        out.print(attnMessage);
    }
%>