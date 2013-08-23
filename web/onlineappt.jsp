<%@ include file="globalvariables.jsp" %>
<%@page import="java.util.Date"%>
<script language="javascript">
    function checkDateChange(what) {
        xx="onlineappt.jsp?" + what.name + "=" + what.options[what.selectedIndex].text;
        location.href=xx;
    }
    function filterChange(what) {
        xx="onlineappt.jsp?" + what.name + "=" + what.options[what.selectedIndex].value;
        location.href=xx;
    }
    function checkAppts() {
        frmInput.submit();
    }
</script>

<%
    if(patient.getId() !=0) {
        String month = (String)session.getAttribute("month");
        String group = (String)session.getAttribute("group");
        String yr    = (String)session.getAttribute("yr");
        String width = request.getParameter("width");
        String height= request.getParameter("height");
        String border= request.getParameter("border");
        String bodyColor=request.getParameter("bodyColor");
        String mn    = "";
        int cellHeight = 60;
    //    String groupEventsSQL = "(select calendar.id AS id,calendar.groupid AS groupid,calendar.date AS date,calendar.time AS time,calendar.event AS event,calendar.description AS description,groups.name AS name,groups.code AS code from (calendar left join groups on((calendar.groupid = groups.id)))) groupevents";

        String[] preload2={};

        if(width == null) { width=(String)session.getAttribute("calendarWidth"); }
        if(height == null) { height=(String)session.getAttribute("calendarHeight"); }
        if(border == null) { border=(String)session.getAttribute("calendarBorder"); }
        if(bodyColor == null) { bodyColor=(String)session.getAttribute("calendarBodyColor"); }

        if (month==null) { month = tools.utils.Format.formatDate(new Date(), "MMMM"); }

        int year     = 0;
        if (yr != null) {
            year = Integer.parseInt(yr);
        } else {
            year = Integer.parseInt(tools.utils.Format.formatDate(new Date(), "yyyy"));
        }

        if(request.getParameter("month") != null) {
            month=request.getParameter("month");
        }
        if(request.getParameter("year") != null) {
            year=Integer.parseInt(request.getParameter("year"));
        }

        if(request.getParameter("group") != null) {
            group=request.getParameter("group");
        }

        yr = ""+year;

        RWCalendar cal = new RWCalendar(year, month);

        mn = tools.utils.Format.formatDate(cal.getTime(), "MM");

        cal.showDayLink(true);
        cal.showEventLink(true);

        cal.showDayLink(true);
        cal.setBgColorForToday("silver");
        cal.setDayUrl("scheduleappt.jsp");
        cal.setLongDOW(false);
        cal.showEvents(false);
        cal.setChangeCellColorForEvents(true);
        cal.showMonthCombo(true);
        cal.showYearCombo(true);
        cal.setYearsBack(5);
    //    cal.setEventUrl("scheduleappt.jsp?");
        cal.setOnClickAction("window.open");
        cal.setOnClickOption("\"Event\",\"width=600,height=500,scrollbars=no,left=0,top=0,\"");
        cal.setOnClickStyle("style=\"cursor: pointer; color: #333333; font-weight: bold;\"");
        cal.showExtendedDescription(false);

        RWEvent [] events = new RWEvent[0];

    //    if(pageContentHeight != null && !pageContentHeight.equals("")) { cellHeight=((Integer.parseInt(pageContentHeight)/5)); }

        if(width == null || width.equals("")) { width="600"; }
        if(border == null || border.equals("")) { border="0"; }
        if(height != null && !height.equals("")) { cellHeight=((Integer.parseInt(height)/6)); }

        out.print("<body style='align=center; margin-top: 0; margin-left: 0; background: #" + bodyColor + ";'>");
        out.print("<p style='font-size: 12px;'>Click on the date to see the available appointments</p>\n");
        out.print(cal.getHtmlCalendar(width, "1", "0", "0", ""+cellHeight, events, "calendar.jsp"));
        out.print("</body>");

        session.setAttribute("month", month);
        session.setAttribute("yr", yr);
        session.setAttribute("group", group);
        session.setAttribute("calendarWidth", width);
        session.setAttribute("calendarHeight", height);
        session.setAttribute("calendarBorder", border);
        session.setAttribute("calendarBodyColor", bodyColor);
    } else if(request.getParameter("cellphone") == null || request.getParameter("cellphone").equals("")) {
        String errorMessage=(String)session.getAttribute("errorMessage");
        if(errorMessage == null) { errorMessage=""; }
        ResultSet lRs=io.opnRS("select id, cellphone, dob from patients where id=0");
        RWInputForm frm=new RWInputForm(lRs);
        RWHtmlTable htmTb=new RWHtmlTable("600","0");
        frm.setAction("onlineappt.jsp");
        frm.setMethod("POST");
        frm.setName("frmInput");

        out.print(frm.startForm());
        out.print(htmTb.startTable());
        out.print(htmTb.startRow("height=30"));
        out.print(htmTb.addCell("<b>Please enter the following to schedule an appointment:<b>", "colspan=2 style='font-size: 12px;'"));
        out.print(htmTb.endRow());
        out.print(htmTb.startRow("height=30"));
        out.print(htmTb.addCell("<b style='color: red;'>" + errorMessage + "<b>", "colspan=2 style='font-size: 12px;'"));
        out.print(htmTb.endRow());
        out.print(frm.getInputItem("cellphone"));
        out.print(frm.getInputItem("dob"));
//        out.print(frm.getInputItem("accountnumber"));
        out.print(htmTb.endTable());
        out.print(frm.endForm());
        out.print(frm.button("check available appointments", "class=button onClick=checkAppts()"));
    } else if(request.getParameter("cellphone") != null && !request.getParameter("cellphone").equals("")) {
//        String accountNumber=request.getParameter("accountnumber");
        String dob=request.getParameter("dob");
        String cellPhone=request.getParameter("cellphone");

        ResultSet lRs=io.opnRS("select id from patients where cellphone='" + cellPhone+ "' and dob='" + tools.utils.Format.formatDate(dob, "yyyy-MM-dd") + "'");
        if(lRs.next()) {
            patient.setId(lRs.getString("id"));
            lRs.close();
            out.print("<script>location.href='onlineappt.jsp';</script>");
        } else {
            session.setAttribute("errorMessage", "Information not found");
            lRs.close();
            out.print("<script>location.href='onlineappt.jsp';</script>");
        }
    }
%>

