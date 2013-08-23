<%@include file="globalvariables.jsp" %>
<SCRIPT language=JavaScript>
<!-- 
function win(where){
window.opener.location.href=where;
self.close();
//-->
}
</SCRIPT>
<script>
    function checkSchedule(resourceId,date,time,apptNum) {
        window.open('scheduleappt.jsp?date='+date+'&resourceId='+resourceId+'&apptNum='+apptNum,'scheduleappt','width=600,height=500');
    }
</script>
<%
    
    String parentLocation = (String)session.getAttribute("parentLocation");
    String returnUrl = (String)session.getAttribute("returnUrl");
    boolean allScheduled = true;
    RWHtmlTable htmTb=new RWHtmlTable("200","0");
    StringBuffer s=new StringBuffer();

    int weeks;
    String startDate;
    int apptType;
    int resourceId;
    String sunday = request.getParameter("sunday_cb");
    String monday = request.getParameter("monday_cb");
    String tuesday = request.getParameter("tuesday_cb");
    String wednesday = request.getParameter("wednesday_cb");
    String thursday = request.getParameter("thursday_cb");
    String friday = request.getParameter("friday_cb");
    String saturday = request.getParameter("saturday_cb");
    String suntime=request.getParameter("suntime");
    String montime=request.getParameter("montime");
    String tuetime=request.getParameter("tuetime");
    String wedtime=request.getParameter("wedtime");
    String thutime=request.getParameter("thutime");
    String fritime=request.getParameter("fritime");
    String sattime=request.getParameter("sattime");
    String time="";
    int calendarDayOfWeek;
    int apptId=0;

    if (request.getParameter("delete")!=null) {
        String query = "delete from appointments where date > current_date and patientid = " + patient.getId();
        PreparedStatement lPs = io.getConnection().prepareStatement(query);
        lPs.executeUpdate();

    } else if (request.getParameter("weeks")!=null) {
               
        weeks = Integer.parseInt(request.getParameter("weeks"));
        startDate = request.getParameter("startdate");
        apptType = Integer.parseInt(request.getParameter("appttype"));
        resourceId= Integer.parseInt(request.getParameter("resourceId"));
        
        if (sunday!=null) {
            suntime = request.getParameter("suntime");
        }
        Appointment appointmentWriter = new Appointment(io, 0);
        Calendar thisCalendar = Calendar.getInstance();
        thisCalendar.setTime(java.sql.Date.valueOf(Format.formatDate(startDate,"yyyy-MM-dd")));
        appointmentWriter.setPatientId(patient.getId());
        appointmentWriter.setType(apptType);
        for (int i=1;i<=(weeks*7);i++) {
            calendarDayOfWeek = thisCalendar.get(thisCalendar.DAY_OF_WEEK);
            if ( 
                (calendarDayOfWeek == thisCalendar.SUNDAY && sunday != null) ||
                (calendarDayOfWeek == thisCalendar.MONDAY && monday != null) ||
                (calendarDayOfWeek == thisCalendar.TUESDAY && tuesday != null) ||
                (calendarDayOfWeek == thisCalendar.WEDNESDAY && wednesday != null) ||
                (calendarDayOfWeek == thisCalendar.THURSDAY && thursday != null) ||
                (calendarDayOfWeek == thisCalendar.FRIDAY && friday != null) ||
                (calendarDayOfWeek == thisCalendar.SATURDAY && saturday != null)) {

                if (calendarDayOfWeek == thisCalendar.SUNDAY) {time = suntime; }        
                if (calendarDayOfWeek == thisCalendar.MONDAY) {time = montime; }        
                if (calendarDayOfWeek == thisCalendar.TUESDAY) {time = tuetime; }        
                if (calendarDayOfWeek == thisCalendar.WEDNESDAY) {time = wedtime; }        
                if (calendarDayOfWeek == thisCalendar.THURSDAY) {time = thutime; }        
                if (calendarDayOfWeek == thisCalendar.FRIDAY) {time = fritime; }        
                if (calendarDayOfWeek == thisCalendar.SATURDAY) {time = sattime; }        

                if(!appointmentExists(io,Format.formatDate(thisCalendar.getTime(),"yyyy-MM-dd"),1,time,resourceId)) {
                    appointmentWriter.setDate((java.sql.Date.valueOf(Format.formatDate(thisCalendar.getTime(),"yyyy-MM-dd"))));
                    appointmentWriter.setId(0);
                    appointmentWriter.setIntervals(getIntervalsForType(io,apptType));
                    appointmentWriter.setTime(Time.valueOf(time+":00"));
                    appointmentWriter.setResourceId(resourceId);
                    appointmentWriter.update();
                } else {
                    allScheduled=false;
                    s.append(htmTb.startRow());
                    s.append(htmTb.addCell(Format.formatDate(thisCalendar.getTime(),"yyyy-MM-dd")));
                    s.append(htmTb.addCell(time));
                    s.append(htmTb.addCell("check schedule", "id=appt" + apptId + " style='cursor: pointer;' onClick=checkSchedule(" + resourceId + ",'" + Format.formatDate(thisCalendar.getTime(),"yyyy-MM-dd") + "','" + time + "'," + apptId + ")"));
                    s.append(htmTb.endRow());
                    apptId ++;
                }
            }
        thisCalendar.add(Calendar.DATE,1);
        }
    }

    if(allScheduled) { 
        out.print("<body onLoad=win('" + parentLocation + "')>");
        out.print("<body>");
    } else {
        out.print(htmTb.startTable());
        out.print(htmTb.startRow());
        out.print(htmTb.headingCell("Scnedule Conflicts","colspan=3"));
        out.print(htmTb.endRow());
        out.print(s.toString());
        out.print(htmTb.endTable());
        out.print("<br><br><input type=button value='finished' class=button onClick=win('" + parentLocation + "')>");
    }
%>
<%! public boolean appointmentExists(RWConnMgr io, String appointmentDate, int intervals, String appointmentTime, int resourceId) {
        boolean appointmentExists=true;
        
        try {
            String myQuery="select count(*) from appointments where date='" + appointmentDate + "' and resourceid=" + resourceId + " and time='" + appointmentTime + ":00'";
            ResultSet resourceRs=io.opnRS("select * from dayhours where resourceid=" + resourceId);
            ResultSet lRs=io.opnRS(myQuery);
            if(appointmentExists=lRs.next()) {
                if(resourceId==0) {
                    appointmentExists=false;
                } else {
                    if(resourceRs.next()) {
                        if(lRs.getInt(1)<resourceRs.getInt("apptdepth")) {
                            appointmentExists=false;
                        }
                    }
                }
                resourceRs.close();
            }
            lRs.close();
            
        } catch (Exception e) {
            
        }
        
        return appointmentExists;
    }


    public int getIntervalsForType(RWConnMgr io, int appointmentType) {
        int intervals=1;
        try {
            ResultSet atRs = io.opnRS("select * from appointmenttypes where id=" + appointmentType);
            if(atRs.next()) { 
                intervals=atRs.getInt("defaultincrements");
            }
            atRs.close();
            atRs = null;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return intervals;
    }
%>
