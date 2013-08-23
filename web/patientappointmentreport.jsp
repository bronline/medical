<%@ include file="globalvariables.jsp" %>
<%
    String year     = request.getParameter("year");
    String month    = request.getParameter("month");
    String day      = request.getParameter("day");
    String date     = request.getParameter("date");
    String bgColor  = "";
    
    if(patient.next()) {
        bgColor="yellow";

        Calendar calCalendar = Calendar.getInstance();
        calCalendar.setTime(new java.util.Date());
        calCalendar.set(Calendar.DAY_OF_MONTH,1);
        out.print("<H1>" + patient.getString("firstname") + " " + patient.getString("lastname") + "</H1>");
        for (int i=0; i<3; i++) {
            month = Format.formatDate(calCalendar.getTime(), "MMMM");
            day = Format.formatDate(calCalendar.getTime(), "dd");
            year = Format.formatDate(calCalendar.getTime(), "yyyy");

            RWCalendar cal = new RWCalendar(Integer.parseInt(year), month, day);
            cal.setLongDOW(true);
            cal.setLongMonth(true);
            cal.showMonthCombo(false);
            cal.showYearCombo(false);
            cal.setBgColorForToday("#cccccc");
            cal.setBgColorForSelected(bgColor);
            cal.showEvents(true);
            cal.setUseEventColor(true);
            
            out.print(cal.getHtmlCalendar("600", "1", "0", "0", "40", getAppointments(io, patient.getId(), month, year), ""));
            out.print("<br>");
            
            calCalendar.add(Calendar.MONTH, 1);
        }
            
    }

%>

<%! public RWEvent [] getAppointments(RWConnMgr io, int patientId, String month, String year) throws Exception {
    int yr           = Integer.parseInt(year);
    String [] months = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};
    int mo           = 0;

    for(mo=0; mo<months.length; mo ++) { if(months[mo].equals(month)) { break; } }
    String myQuery   = "select TIME_FORMAT(time,'%h:%i %p') ftime, a.* from patientappointments a where patientid=" + patientId + 
                       " and month(date)=" + (mo + 1) +
                       " and year(date)=" + yr +
                       " order by date, time";

    ResultSet aRs    = io.opnRS(myQuery);

    if(aRs.next()) {
        ArrayList evt = new ArrayList();
        evt.add(new RWEvent(Format.formatDate(aRs.getDate("DATE"), "yyyyMMdd"), aRs.getString("id"), aRs.getString("ftime") + " - " + aRs.getString("type"), aRs.getString("bgcolor"), aRs.getString("textcolor")));

        while(aRs.next()) {
            evt.add(new RWEvent(Format.formatDate(aRs.getDate("DATE"), "yyyyMMdd"), aRs.getString("id"), aRs.getString("ftime") + " - " + aRs.getString("type"), aRs.getString("bgcolor"), aRs.getString("textcolor")));
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
