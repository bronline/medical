<%-- 
    Document   : holidayhours
    Created on : Dec 11, 2008, 6:45:05 PM
    Author     : Randy Wandell
--%>
<%@ include file="globalvariables.jsp" %>
<%
    String id = request.getParameter("ID");
    String resourceId = request.getParameter("resourceId");
    String day = "";
    String morningStart = "";
    String morningEnd = "";
    String afternoonStart = "";
    String afternoonEnd = "";
    String update = request.getParameter("update");
    RWHtmlTable htmTb = new RWHtmlTable("525", "0");
    RWInputForm frm;
    
    if(id == null) { id="0"; }
    if(update == null) {
        ResultSet resourceRs=io.opnRS("select * from resources order by calendarseq");
        ResultSet hoursRs=io.opnRS("select * from officehours where id=" + id);
        frm = new RWInputForm(hoursRs);
        
        out.print("<v:roundrect style='width: 530; height: 210; text-valign: middle; text-align: center;'>");
        if(resourceRs.next()) {
            out.print(frm.hidden(id, "ID"));
            
            out.print(htmTb.startTable());

            out.print(htmTb.startRow());    
            out.print(htmTb.roundedTop(6, "transparent", "#030089", "divTop"));
            out.print(htmTb.endRow());

            out.print(htmTb.startRow());
            out.print(htmTb.headingCell("", "style='background-color: #030089;'"));
            out.print(htmTb.headingCell("", "style='background-color: #030089;'"));
            out.print(htmTb.headingCell("Morning", "colspan=2 style='background-color: #030089;'"));
            out.print(htmTb.headingCell("Afternoon", "colspan=2 style='background-color: #030089;'"));
            out.print(htmTb.endRow());

            out.print(htmTb.startRow());
            out.print(htmTb.headingCell("Date", "style='background-color: #030089;'"));
            out.print(htmTb.headingCell("Provider", "style='background-color: #030089;'"));
            out.print(htmTb.headingCell("Start", "style='background-color: #030089;'"));
            out.print(htmTb.headingCell("End", "style='background-color: #030089;'"));
            out.print(htmTb.headingCell("Start", "style='background-color: #030089;'"));
            out.print(htmTb.headingCell("End", "style='background-color: #030089;'"));
            out.print(htmTb.endRow());

            out.print(htmTb.startRow());
            out.print(frm.getInputItemOnly("date", "id=date class=tBoxText"));
            out.print(frm.getInputItemOnly("resourceid", "id=resourceid class=cBoxText"));
            out.print(frm.getInputItemOnly("morningstart", "id=morningstart style='text-align: right;'"));
            out.print(frm.getInputItemOnly("morningend", "id=morningend style='text-align: right;'"));
            out.print(frm.getInputItemOnly("afternoonstart", "id=afternoonstart style='text-align: right;'"));
            out.print(frm.getInputItemOnly("afternoonend", "id=afternoonend style='text-align: right;'"));
            out.print(htmTb.endRow());

            out.print(htmTb.startRow("height=5"));
            out.print(htmTb.addCell("",htmTb.CENTER, "colspan=6"));
            out.print(htmTb.endRow());

            out.print(htmTb.startRow());
//            out.print(htmTb.addCell(frm.button("save", "class=button onclick=\"javascript:get(this.parentNode,'SAVE');\"") + " " + frm.button("cancel", "class=button onclick=\"javascript:showHide(txtHint,'HIDE');\""),htmTb.CENTER, "colspan=6"));
            out.print(htmTb.addCell(frm.button("save", "class=button onclick=\"javascript:processForm(this.parentNode,'SAVE',null);\"") + " " + frm.button("cancel", "class=button onclick=\"javascript:showHide(txtHint,'HIDE');\""),htmTb.CENTER, "colspan=6"));
            out.print(htmTb.endRow());

            out.print(htmTb.endTable());

            out.print("<input type=hidden name=parentLocation id=parentLocation value='null'>");
            out.print("<input type=hidden name=postLocation id=postLocation value='holidayhours.jsp'>");
            out.print("<input type=hidden name=fileName id=fileName value='officehours'>");
            out.print("<input type=hidden name=update id=update value='Y'>");
            out.print("<input type=hidden name=patientid id=patientid value='0'>");
        } else {
            out.print("Resource not Found!");
        }
        out.print("</v:roundrect>");
    } else {      
        PreparedStatement iPs=io.getConnection().prepareStatement("insert into officehours (`date`, resourceid, morningstart, morningend, afternoonstart, afternoonend) values (?,?,?,?,?,?)");
        PreparedStatement uPs=io.getConnection().prepareStatement("update officehours set date=?, resourceid=?, morningstart=?, morningend=?, afternoonstart=?, afternoonend=? where id=?");
        PreparedStatement dPs=io.getConnection().prepareStatement("select * from officehours where id=?");

        String date=request.getParameter("date");
        resourceId=request.getParameter("resourceid");
        morningStart=request.getParameter("morningstart");
        morningEnd=request.getParameter("morningend");
        afternoonStart=request.getParameter("afternoonstart");
        afternoonEnd=request.getParameter("afternoonend");

        dPs.setString(1, id);

        ResultSet dRs=dPs.executeQuery();
        if(dRs.next()) {
            uPs.setString(1, date);
            uPs.setString(2, resourceId);
            uPs.setString(3, morningStart);
            uPs.setString(4, morningEnd);
            uPs.setString(5, afternoonStart);
            uPs.setString(6, afternoonEnd);
            uPs.setString(7, id);
            uPs.execute();
        } else {
            iPs.setString(1, Format.formatDate(date, "yyyy-MM-dd"));
            iPs.setString(2, resourceId);
            iPs.setString(3, morningStart);
            iPs.setString(4, morningEnd);
            iPs.setString(5, afternoonStart);
            iPs.setString(6, afternoonEnd);
            try{
            iPs.execute();
            } catch (Exception e) {
                System.out.print(e.getMessage());
            }
        }
        dRs.close(); 
 
    }
  
%>


