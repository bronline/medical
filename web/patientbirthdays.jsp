<%@ include file="globalvariables.jsp" %>
<%
    String year     = request.getParameter("year");
    String month    = request.getParameter("month");
    String day      = request.getParameter("day");
    String date     = request.getParameter("date");
    String bgColor  = "";

    bgColor="yellow";

    Calendar calCalendar = Calendar.getInstance();
    calCalendar.setTime(new java.util.Date());
    calCalendar.set(Calendar.DAY_OF_MONTH,1);
//        out.print("<H1>" + patientRs.getString("firstname") + " " + patientRs.getString("lastname") + "</H1>");

    for (int i=0; i<3; i++) {
        String calendarMonth = Format.formatDate(calCalendar.getTime(), "MMMM");
        month = Format.formatDate(calCalendar.getTime(), "MM");
        day = Format.formatDate(calCalendar.getTime(), "dd");
        year = Format.formatDate(calCalendar.getTime(), "yyyy");

        RWCalendar cal = new RWCalendar(Integer.parseInt(year), calendarMonth, day);
        cal.setLongDOW(true);
        cal.setLongMonth(true);
        cal.showMonthCombo(false);
        cal.showYearCombo(false);
        cal.setBgColorForToday("#cccccc");
        cal.setBgColorForSelected(bgColor);
        cal.showEvents(true);
        cal.setUseEventColor(true);

        out.print(cal.getHtmlCalendar("600", "1", "0", "0", "40", getBirthdays(io, year, month), ""));
        out.print("<br>");

        calCalendar.add(Calendar.MONTH, 1);
    }


%>

<%! public RWEvent [] getBirthdays(RWConnMgr io, String year, String month) throws Exception {
    int yr           = Integer.parseInt(year);
    String [] months = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};
    int mo           = 0;

    for(mo=0; mo<months.length; mo ++) { if(months[mo].equals(month)) { break; } }
    String myQuery   = "select id, firstname, lastname, concat('" + year + "', DATE_FORMAT(dob, '-%m-%d')) as dob from patients where dob<>'0001-01-01' and month(dob)='" + month + "' order by concat('" + year + "', DATE_FORMAT(dob, '-%m-%d'))";

    ResultSet aRs    = io.opnRS(myQuery);

    if(aRs.next()) {
        ArrayList evt = new ArrayList();
        evt.add(new RWEvent(year+Format.formatDate(aRs.getDate("dob"), "MMdd"), aRs.getString("id"), aRs.getString("firstname") + " " + aRs.getString("lastname"), "white", "black"));

        while(aRs.next()) {
            evt.add(new RWEvent(year+Format.formatDate(aRs.getDate("dob"), "MMdd"), aRs.getString("id"), aRs.getString("firstname") + " " + aRs.getString("lastname"), "white", "black"));
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
