<%@ include file="template/pagetop.jsp" %>
<style>
th	        { font-size: 9px;
                  font-family: tahoma;
	          background-color: #cccccc;
	          color: #2c57a7;  }
.cBoxText	{ font-size: 14px; 
                  font-family: tahoma; }
</style>
<script language="javascript">
    function checkDateChange(what) {
        xx="appointments.jsp?month=" + month.options[month.selectedIndex].text + "&year=" + year.options[year.selectedIndex].text;
        location.href=xx;
    }
    function printReport() {
      window.open('patientappointmentreport.jsp','print','height=600,width=740,scrollbars=yes,resizable');
    }
</script>
<%
    String appointmentsView = (String)session.getAttribute("appointmentsView");
    String year     = request.getParameter("year");
    String month    = request.getParameter("month");
    String day      = request.getParameter("day");
    String date     = request.getParameter("date");
    String formName = request.getParameter("formName");
    String element  = request.getParameter("element");
    String bgColor  = "";
    if (appointmentsView==null) {
        appointmentsView="list";
    }
    if(patient.next()) {
//        if (appointmentsView.equals("list")) {
            out.print("<table><tr valign=top>");
            out.print("<td>" + patient.showDetailedAppointments() + "</td>");
//        } else {
            if(month == null) {
                month = Format.formatDate(new java.util.Date(), "MMMM");
            }

            if(day == null) {
                day = Format.formatDate(new java.util.Date(), "dd");
                bgColor="yellow";
            }

            if(year == null) {
                year = Format.formatDate(new java.util.Date(), "yyyy");
            }

            if(formName != null) { session.setAttribute("formName", formName); }
            if(element != null) { session.setAttribute("element", element); }
            RWCalendar cal = new RWCalendar(Integer.parseInt(year), month, day);
            cal.setLongDOW(true);
            cal.setLongMonth(true);
            cal.showMonthCombo(true);
            cal.showYearCombo(true);
            cal.setBgColorForToday("#cccccc");
            cal.setBgColorForSelected(bgColor);
            cal.showEvents(true);
            cal.setUseEventColor(true);
            out.print("<td>" + cal.getHtmlCalendar("400", "1", "0", "0", "50", getAppointments(io, patient.getId(), month, year), "") + patient.showMissedAppointments() + "</td>");
            out.print("<tr><td><input type=button class=button value=\"print patient appointments report\" onClick=printReport()></td>");

            out.print("</tr></table>");
//        }
    }
    session.setAttribute("returnUrl", "appointments.jsp");
    session.setAttribute("parentLocation", "appointments.jsp");

%>

<%! public RWEvent [] getAppointments(RWConnMgr io, int patientId, String month, String year) throws Exception {
    int yr           = Integer.parseInt(year);
    String [] months = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};
    int mo           = 0;

    for(mo=0; mo<months.length; mo ++) { if(months[mo].equals(month)) { break; } }
    String myQuery   = "select * from patientappointments where patientid=" + patientId + 
                       " and month(date)=" + (mo + 1) +
                       " and year(date)=" + yr +
                       " order by date, time";

    ResultSet aRs    = io.opnRS(myQuery);

    if(aRs.next()) {
        ArrayList evt = new ArrayList();
        evt.add(new RWEvent(Format.formatDate(aRs.getDate("DATE"), "yyyyMMdd"), aRs.getString("id"), aRs.getString("type"), aRs.getString("bgcolor"), aRs.getString("textcolor")));

        while(aRs.next()) {
            evt.add(new RWEvent(Format.formatDate(aRs.getDate("DATE"), "yyyyMMdd"), aRs.getString("id"), aRs.getString("type"), aRs.getString("bgcolor"), aRs.getString("textcolor")));
        }
        aRs.close();

        RWEvent [] events = new RWEvent[evt.size()];
        for(int x=0; x<evt.size(); x++) { events[x] = (RWEvent)evt.get(x); }
        return events;

    } else {
        RWEvent [] events = new RWEvent[1];
        events[0] = new RWEvent("", "", "");
        aRs.close();
        return events;
    }

}
%>

<%@include file="template/pagebottom.jsp" %>