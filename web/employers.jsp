<%  if(request.getParameter("update") ==  null) {
        out.print("<v:roundrect style='width: 450; height: 75; text-valign: middle; text-align: center;'>");
        out.print("<div align=\"right\" style=\"width: 100%;\"><b style=\"cursor: pointer;\" onClick=showHide(txtHint,'HIDE')>close</b></div>");
        out.print("<form name='employerForm'>");
        out.print("<label><b>Employer Name</b></label> <input type='text' name='employer' id='employer' size='45' maxlength='100' />");
        out.print("<input type='button' onclick=\"updateList(this);\" value=\"save\" class=\"button\" /><br>");
        out.print("<input type=hidden name=postLocation id=postLocation value='employers.jsp'>");
        out.print("<input type=hidden name=update id=update value='Y'>");
        out.print("<input type=hidden name=parentLocation id=parentLocation value='NONE'>");
        out.print("</form>");
        out.print("</v:roundrect>");
    } else if(request.getParameter("update") != null) {
        tools.RWConnMgr io = (tools.RWConnMgr)session.getAttribute("connMgr");
        StringBuffer s=new StringBuffer();
        try {
            if(io.getConnection()==null) { io.setConnection(io.opnmySqlConn()); }
            java.sql.PreparedStatement lPs = io.getConnection().prepareStatement("insert into employers (employer) values (?)");
            if(request.getParameter("employer")!=null && !request.getParameter("employer").trim().equals("")) {
                lPs.setString(1, request.getParameter("employer"));
                lPs.execute();
            }

            java.sql.ResultSet lRs=io.opnRS("select 0 as employerid, '-- select --' as employer union select '-1' as employerid, '--- New Employer ---' as employer union select id as employerid, employer from employers order by employer");
            while(lRs.next()) {
                s.append("<option value=\"" + lRs.getString(1) + "\"");
                if(lRs.getString(2).equals(request.getParameter("employer"))) { s.append(" selected "); }
                s.append(">" + lRs.getString("employer"));
                s.append("</option>");
            }
            lRs.close();
        } catch (Exception e) {
            s.append(e.getMessage());
        }
        out.print(s.toString());

    }
%>