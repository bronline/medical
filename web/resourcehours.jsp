<%-- 
    Document   : resourcehours
    Created on : Dec 10, 2008, 8:13:05 AM
    Author     : Randy Wandell
--%>
<%@ include file="globalvariables.jsp" %>
<%
    String date = "2008-12-01"; // Dec 1, 08 is a Monday
    String resourceId = request.getParameter("resourceId");
    String day = "";
    String morningStart = "";
    String morningEnd = "";
    String afternoonStart = "";
    String afternoonEnd = "";
    String update = request.getParameter("update");
    RWHtmlTable htmTb = new RWHtmlTable("375", "0");
    RWHtmlForm frm = new RWHtmlForm("frmInput", "POST", "resourcehours.jsp");

    if(update == null) {
        ResultSet resourceRs=io.opnRS("select * from resources where id=" + resourceId);
        PreparedStatement rPs=io.getConnection().prepareStatement("select * from dayhours where resourceid=? and `day`=?");
        PreparedStatement dPs=io.getConnection().prepareStatement("SELECT UCASE(DATE_FORMAT(?, '%a')) as `day`");

        out.print("<v:roundrect style='width: 375; height: 200; text-valign: middle; text-align: center;'>");
        if(resourceRs.next()) {
            out.print(frm.hidden(resourceId, "resourceId", "id=resourceId"));

            out.print(htmTb.startTable());

            out.print(htmTb.startRow());    
            out.print(htmTb.roundedTop(6, "transparent", "#030089", "divTop"));
            out.print(htmTb.endRow());

            out.print(htmTb.startRow());    
            out.print(htmTb.roundedTop(6, resourceRs.getString("name"), "#030089", "divTop"));
            out.print(htmTb.endRow());

            out.print(htmTb.startRow());
            out.print(htmTb.headingCell("", "style='background-color: #030089;'"));
            out.print(htmTb.headingCell("", "style='background-color: #030089;'"));
            out.print(htmTb.headingCell("Morning", "colspan=2 style='background-color: #030089;'"));
            out.print(htmTb.headingCell("Afternoon", "colspan=2 style='background-color: #030089;'"));
            out.print(htmTb.endRow());

            out.print(htmTb.startRow());
            out.print(htmTb.headingCell("", "style='background-color: #030089;'"));
            out.print(htmTb.headingCell("Day", "style='background-color: #030089;'"));
            out.print(htmTb.headingCell("Start", "style='background-color: #030089;'"));
            out.print(htmTb.headingCell("End", "style='background-color: #030089;'"));
            out.print(htmTb.headingCell("Start", "style='background-color: #030089;'"));
            out.print(htmTb.headingCell("End", "style='background-color: #030089;'"));
            out.print(htmTb.endRow());
            for(int d=0;d<7;d++) {
                dPs.setString(1, date);
                ResultSet lRs=dPs.executeQuery();

                if(lRs.next()) {
                    morningStart = "800";
                    morningEnd = "1200";
                    afternoonStart = "1300";
                    afternoonEnd = "1700";

                    rPs.setString(1, resourceId);
                    rPs.setString(2, lRs.getString("day"));
                    ResultSet rRs=rPs.executeQuery();
                    if(rRs.next()) {
                        morningStart = rRs.getString("morningStart");
                        morningEnd = rRs.getString("morningEnd");
                        afternoonStart = rRs.getString("afternoonStart");
                        afternoonEnd = rRs.getString("afternoonEnd");
                    }
                    rRs.close();

                    out.print(htmTb.startRow());
                    out.print(htmTb.addCell("", "width=25"));
                    out.print(htmTb.addCell("<b>" + lRs.getString("day") + "</b>" + frm.hidden(lRs.getString("day"), "day" + d, "id=day" + d), htmTb.CENTER,"width=50"));
                    out.print(htmTb.addCell(frm.textBox(morningStart, "morningstart" + d, "id=morningstart" + d + " size=4 maxlength=4 class=tBoxText style='text-align: right;'"), htmTb.CENTER, "width=75"));
                    out.print(htmTb.addCell(frm.textBox(morningEnd, "morningend" + d, "id=morningend" + d + " size=4 maxlength=4 class=tBoxText style='text-align: right;'"), htmTb.CENTER, "width=75"));
                    out.print(htmTb.addCell(frm.textBox(afternoonStart, "afternoonstart" + d, "id=afternoonstart" + d + " size=4 maxlength=4 class=tBoxText style='text-align: right;'"), htmTb.CENTER, "width=75"));
                    out.print(htmTb.addCell(frm.textBox(afternoonEnd, "afternoonend" + d, "id=afternoonend" + d + " size=4 maxlength=4 class=tBoxText style='text-align: right;'"), htmTb.CENTER, "width=75"));
                    out.print(htmTb.endRow());

                    ResultSet tempRs=io.opnRS("select INTERVAL 1 DAY + '" + date + "' as date");
                    if(tempRs.next()) { date=tempRs.getString("date"); }
                    tempRs.close();
                    lRs.close();
                }
            }
            out.print(htmTb.startRow("height=5"));
            out.print(htmTb.addCell("",htmTb.CENTER, "colspan=6"));
            out.print(htmTb.endRow());

            out.print(htmTb.startRow());
//            out.print(htmTb.addCell(frm.button("save", "class=button onclick=\"javascript:get(this.parentNode,'SAVE');\"") + " " + frm.button("cancel", "class=button onclick=\"javascript:showHide(txtHint,'HIDE');\""),htmTb.CENTER, "colspan=6"));
            out.print(htmTb.addCell(frm.button("save", "class=button onclick=\"javascript:processForm(this.parentNode,'SAVE',null);\"") + " " + frm.button("cancel", "class=button onclick=\"javascript:showHide(txtHint,'HIDE');\""),htmTb.CENTER, "colspan=6"));
            out.print(htmTb.endRow());

            out.print(htmTb.endTable());

            out.print("<input type=hidden name=parentLocation id=parentLocation value='null'>");
            out.print("<input type=hidden name=postLocation id=postLocation value='resourcehours.jsp'>");
            out.print("<input type=hidden name=fileName id=fileName value='dayhours'>");
            out.print("<input type=hidden name=update id=update value='Y'>");
            out.print("<input type=hidden name=patientid id=patientid value='0'>");
        } else {
            out.print("Resource not Found!");
        }
        out.print("</v:roundrect>");
    } else {
        PreparedStatement iPs=io.getConnection().prepareStatement("insert into dayhours (`day`, resourceid, morningstart, morningend, afternoonstart, afternoonend, apptdepth, incrementminutes) values (?,?,?,?,?,?,?,?)");
        PreparedStatement uPs=io.getConnection().prepareStatement("update dayhours set morningstart=?, morningend=?, afternoonstart=?, afternoonend=? where resourceid=? and `day`=?");
        PreparedStatement dPs=io.getConnection().prepareStatement("select * from dayhours where resourceid=? and `day`=?");

        for(int d=0;d<7;d++) {
            day=request.getParameter("day" + d);
            morningStart=request.getParameter("morningstart" + d);
            morningEnd=request.getParameter("morningend" + d);
            afternoonStart=request.getParameter("afternoonstart" + d);
            afternoonEnd=request.getParameter("afternoonend" + d);

            dPs.setString(1, resourceId);
            dPs.setString(2, day);
            ResultSet dRs=dPs.executeQuery();
            if(dRs.next()) {
			uPs.setString(1, morningStart);
			uPs.setString(2, morningEnd);
			uPs.setString(3, afternoonStart);
			uPs.setString(4, afternoonEnd);
			uPs.setString(5, resourceId);
			uPs.setString(6, day);
			uPs.execute();
            } else {
			iPs.setString(1, day);
			iPs.setString(2, resourceId);
			iPs.setString(3, morningStart);
			iPs.setString(4, morningEnd);
			iPs.setString(5, afternoonStart);
			iPs.setString(6, afternoonEnd);
			iPs.setInt(7, 1);
			iPs.setInt(8, 15);
			iPs.execute();

            }
            dRs.close(); 
        }
    }
  
%>


