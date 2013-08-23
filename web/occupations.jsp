<%  if(request.getParameter("update") ==  null) {
        out.print("<v:roundrect style='width: 450; height: 75; text-valign: middle; text-align: center;'>");       
        out.print("<div align=\"right\" style=\"width: 100%;\"><b style=\"cursor: pointer;\" onClick=showHide(txtHint,'HIDE')>close</b></div>");
        out.print("<form name='occupationForm'>");
        out.print("<label><b>Occupation</b></label> <input type='text' name='occupation' id='occupation' size='45' maxlength='100' />");
        out.print("<input type='button' onclick=\"updateList(this);\" value=\"save\" class=\"button\" /><br>");
        out.print("<input type=hidden name=postLocation id=postLocation value='occupations.jsp'>");
        out.print("<input type=hidden name=update id=update value='Y'>");
        out.print("<input type=hidden name=parentLocation id=parentLocation value='NONE'>");
        out.print("</form>");
        out.print("</v:roundrect>");
    } else if(request.getParameter("update") != null) {
        tools.RWConnMgr io = (tools.RWConnMgr)session.getAttribute("connMgr");
        StringBuffer s=new StringBuffer();
        try {
            if(io.getConnection()==null) { io.setConnection(io.opnmySqlConn()); }
            java.sql.PreparedStatement lPs = io.getConnection().prepareStatement("insert into occupation (occupation) values (?)");
            if(request.getParameter("occupation")!=null && !request.getParameter("occupation").trim().equals("")) {
                lPs.setString(1, request.getParameter("occupation"));
                lPs.execute();
            }


            java.sql.ResultSet lRs=io.opnRS("select 0 as occupationid, '-- select --' as occupation union select '-1' as occupationid, '--- New Occupation ---' as occupation union select id as occupationid, occupation from occupation order by occupation");
            while(lRs.next()) {
                s.append("<option value=\"" + lRs.getString(1) + "\"");
                if(lRs.getString(2).equals(request.getParameter("occupation"))) { s.append(" selected "); }
                s.append(">" + lRs.getString("occupation"));
                s.append("</option>");
            }
            lRs.close();
        } catch (Exception e) {
            s.append(e.getMessage());
        }
        out.print(s.toString());

    }
%>