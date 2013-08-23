<%@ page import="tools.*" %>

<%
    RWCalendar cal = new RWCalendar(2005, "December");
    
    cal.setSelectedDate("2005-12-15");
    cal.setBgColorForSelected("yellow");
    cal.showSelectedDate(true);

    out.print(cal.getHtmlCalendar(""));
%>