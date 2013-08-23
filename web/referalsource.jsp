<%  if(request.getParameter("update") ==  null) {
        out.print("<v:roundrect style='width: 450; height: 75; text-valign: middle; text-align: center;'>");       
        out.print("<div align=\"right\" style=\"width: 100%;\"><b style=\"cursor: pointer;\" onClick=showHide(txtHint,'HIDE')>close</b></div>");
        out.print("<form name='referalForm'>");
        out.print("<label><b>Referal Source</b></label> <input type='text' name='referrer' id='referrer' size='45' maxlength='100' />");
        out.print("<input type='button' onclick=\"updateList(this);\" value=\"save\" class=\"button\" /><br>");
        out.print("<input type=hidden name=postLocation id=postLocation value='referalsource.jsp'>");
        out.print("<input type=hidden name=update id=update value='Y'>");
        out.print("<input type=hidden name=parentLocation id=parentLocation value='NONE'>");
        out.print("</form>");
        out.print("</v:roundrect>");
    } else if(request.getParameter("update") != null) {
        tools.RWConnMgr io = (tools.RWConnMgr)session.getAttribute("connMgr");
        StringBuffer s=new StringBuffer();
        try {
            if(io.getConnection()==null) { io.setConnection(io.opnmySqlConn()); }
            java.sql.PreparedStatement lPs = io.getConnection().prepareStatement("insert into referredby (referrer) values (?)");
            if(request.getParameter("referrer")!=null && !request.getParameter("referrer").trim().equals("")) {
                lPs.setString(1, request.getParameter("referrer"));
                lPs.execute();
            }


            java.sql.ResultSet lRs=io.opnRS("select 0 as referral, '-- select --' as referrer union select '-1' as referral, '--- New Referal Source ---' as referrer union select id as referral, referrer from referredby order by referrer");
            while(lRs.next()) {
                s.append("<option value=\"" + lRs.getString(1) + "\"");
                if(lRs.getString(2).equals(request.getParameter("referrer"))) { s.append(" selected "); }
                s.append(">" + lRs.getString("referrer"));
                s.append("</option>");
            }
            lRs.close();
        } catch (Exception e) {
            s.append(e.getMessage());
        }
        out.print(s.toString());

    }
%>