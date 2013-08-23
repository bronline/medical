<%-- 
    Document   : newpayer
    Created on : Sep 15, 2010, 3:12:43 PM
    Author     : rwandell
--%>
<style type="text/css">
    label { vertical-align:top; }
</style>
<%  if(request.getParameter("update") ==  null) {
        out.print("<v:roundrect style='width: 450; height: 180; text-valign: middle; text-align: center;'>");
        out.print("<div align=\"right\" style=\"width: 100%;\"><b style=\"cursor: pointer;\" onClick=showHide(txtHint,'HIDE')>close</b></div>");
        out.print("<form name='payerForm'><div align=\"left\" style=\"width: 80%;\">\n");
        out.print("<label><b>New Payer</b></label> <input type='text' name='name' id='name' size='45' maxlength='100' /><br>");
        out.print("<label><b>Address&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</b></label> <textarea name='address' id='address' cols='34' rows='3'></textarea><br><br><br>");
        out.print("<label><b>Accept Assignment</b></label> <input type='checkbox' name='assignment' id='assignment' checked><br>");
        out.print("<input type='button' onclick=\"updateList(this);\" value=\"save\" class=\"button\" /><br>");
        out.print("<input type=hidden name=postLocation id=postLocation value='newpayer.jsp'>");
        out.print("<input type=hidden name=update id=update value='Y'>");
        out.print("<input type=hidden name=parentLocation id=parentLocation value='NONE'>");
        out.print("</div></form>");
        out.print("</v:roundrect>");
    } else if(request.getParameter("update") != null) {
        tools.RWConnMgr io = (tools.RWConnMgr)session.getAttribute("connMgr");
        StringBuffer s=new StringBuffer();
        String assignment=request.getParameter("assignment");

        if(assignment == null) {
            assignment="0";
        } else {
            assignment="1";
        }

        try {
            if(io.getConnection()==null) { io.setConnection(io.opnmySqlConn()); }
            java.sql.PreparedStatement lPs = io.getConnection().prepareStatement("insert into providers (name, address, practice, assignment) values (?,?,?,?)");
            if(request.getParameter("name")!=null && !request.getParameter("name").trim().equals("")) {
                lPs.setString(1, request.getParameter("name"));
                lPs.setString(2, request.getParameter("address"));
                lPs.setString(3, "");
                lPs.setString(4, assignment);
                lPs.execute();
            }

            String sqlStm="select 0 as providerid, '-- select --' as name, 'select' as name1 union " +
                    "select '-1' as providerid, '--- New Payer ---' as name, 'new' as name1 union " +
                    "select id as providerid, " +
                    "substr(concat(name,' - ',REPLACE(substr(address,1,locate(_latin1'\r',address)-1),'\r\n',''),' - ', " +
                    "case when substr(providers.address,length(providers.address)-4,1)='-' then " +
                    "replace(substr(address,(locate(_latin1'\r',address) + 1),length(address)-10-(locate(_latin1'\r',address) + 2)),'\r\n',' ') " +
                    "else replace(substr(address,(locate(_latin1'\r',address) + 1),length(address)-5-(locate(_latin1'\r',address) + 2)),'\r\n',' ')end),1,55) as name, " +
                    "name as name1 " +
                    "from providers order by name";

            java.sql.ResultSet lRs=io.opnRS(sqlStm);
            while(lRs.next()) {
                s.append("<option value=\"" + lRs.getString(1) + "\"");
                if(lRs.getString(3).equals(request.getParameter("name"))) { s.append(" selected "); }
                s.append(">" + lRs.getString("name"));
                s.append("</option>");
            }
            lRs.close();
        } catch (Exception e) {
            System.out.println(io.getLibraryName() + ": " + new java.util.Date() + " - " + request.getRemoteAddr() + " newpayer.jsp - problem adding payer (" + e.getMessage() + ")");
        }
        out.print(s.toString());

    }
%>