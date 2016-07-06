<%@ include file="globalvariables.jsp" %>
<SCRIPT language=JavaScript>
<!-- 
function win(apptNum){
//window.opener.location.href=where;
    if(apptNum != null ) {
        var multiValue=window.opener.document.getElementById('appt'+apptNum);
        multiValue.innerHTML='Scheduled';
    }
    self.close();
//-->
}
</SCRIPT>

<body style='font-size: 12px;'>
<%

    RWHtmlTable htmTb=new RWHtmlTable("550","0","0","0");
//    patient.setId();
    String apptDate=request.getParameter("date");
    String resourceId=request.getParameter("resourceId");
    boolean onlineAppt=false;
    String appointmentNumber=request.getParameter("apptNum");
    
    int morningStart=6;
    int eveningEnd=18;
    int increment=15;
    int apptDepth=1;
    
    String schedule=request.getParameter("schedule");
    
    if(apptDate == null) {
        apptDate=Format.formatDate(new java.util.Date(), "yyyy-MM-dd");
    } else {
        apptDate=Format.formatDate(apptDate, "yyyy-MM-dd");
    }

    if(request.getParameter("online") != null || session.getAttribute("online") != null ) {
        onlineAppt=true;
        session.setAttribute("online","Y");
    }
    
    if(schedule==null) {
        ResultSet calendarRs=io.opnRS("select * from calendarsettings");
        if(calendarRs.next()) {
            morningStart=calendarRs.getInt("morningStart");
//            eveningEnd=calendarRs.getInt("eveningend");
            increment=calendarRs.getInt("increment");
            apptDepth=calendarRs.getInt("apptDepth");
        }
        calendarRs.close();
    
        String dayOfWeek=Format.formatDate(apptDate, "EEE").toUpperCase();
        String dayCheck="";
        if(dayOfWeek.equals("SUN")) {
            dayCheck="sunday";
        } else if(dayOfWeek.equals("MON")) {
            dayCheck="monday";
        } else if(dayOfWeek.equals("TUE")) {
            dayCheck="tuesday";
        } else if(dayOfWeek.equals("WED")) {
            dayCheck="wednesday";
        } else if(dayOfWeek.equals("THU")) {
            dayCheck="thursday";
        } else if(dayOfWeek.equals("FRI")) {
            dayCheck="friday";
        } else if(dayOfWeek.equals("SAT")) {
            dayCheck="saturday";
        }

        out.print("<div align=\"center\" style=\"width: 100%;\"><div align=\"left\" style=\"width: 550px; font-size: 10px;\">" + env.getString("schedulemessage") + "</div></div><br/>");
        out.print(htmTb.startTable());
        out.print(htmTb.startRow());
                              
        ResultSet resRs=io.opnRS("select * from resources where id <>0");
        while(resRs.next()) {
            out.print(htmTb.startCell(htmTb.LEFT));
            out.print("<fieldset>");
            out.print(htmTb.startTable("150"));
            out.print(htmTb.startRow());
            out.print(htmTb.addCell(resRs.getString("name"),"style='font-weight: bold; font-size: 12px;'"));
            out.print(htmTb.endRow());
            out.print(htmTb.startRow());
            ResultSet dowRs=io.opnRS("select * from dow where " + dayCheck);
            if(dowRs.next()) {
                ResultSet dayHoursRs=io.opnRS("select * from dayhours where day='" + dayOfWeek + "' and resourceid=" + resRs.getInt("id"));
                if(dayHoursRs.next()) {
                    increment = dayHoursRs.getInt("incrementminutes");
                    Hashtable apptTimes=new Hashtable();
                    ResultSet apptRs=io.opnRS("select distinct `time` from appointments where date='" + apptDate + "' and resourceid=" + resRs.getInt("id") + " order by time");
                    while(apptRs.next()) {
                        if(!apptTimes.containsKey(apptRs.getString("time"))) {
                            apptTimes.put(apptRs.getString("time"), "1");
                        } else {
                            String apptCount=(String)apptTimes.get(apptRs.getString("time"));
                            int currentCount=Integer.parseInt(apptCount);
                            apptTimes.remove(apptRs.getString("time"));
                            apptTimes.put(apptRs.getString("time"), ""+(currentCount++));
                        }
                    }

                    StringBuffer availableAppts = new StringBuffer();
                    int startTime=0;
                    int endTime=0;

                    Calendar cal=Calendar.getInstance();

                    apptDepth=dayHoursRs.getInt("apptdepth");

                    if(dayHoursRs.getInt("morningstart")!=0 && dayHoursRs.getInt("morningend") !=0) {
                        startTime=dayHoursRs.getInt("morningstart");
                        endTime=dayHoursRs.getInt("morningend");
                        availableAppts.append(getAvailableAppointments(cal, apptTimes, apptDate, startTime, endTime, increment, apptDepth, resRs.getInt("id"),appointmentNumber));
                    }

                    if(dayHoursRs.getInt("afternoonstart")!=0 && dayHoursRs.getInt("afternoonend") !=0) {
                        startTime=dayHoursRs.getInt("afternoonstart");
                        endTime=dayHoursRs.getInt("afternoonend");
                        availableAppts.append(getAvailableAppointments(cal, apptTimes, apptDate, startTime, endTime, increment, apptDepth, resRs.getInt("id"),appointmentNumber));
                    }

                    if(availableAppts.length() != 0) {
                        out.print(htmTb.startCell(htmTb.LEFT));
                        out.print("<p>Appointments available for " + Format.formatDate(apptDate, "EEEE, MMMM dd,yyyy") + "</p>\n");
                        out.print("<div style='height: 300; width: 171; overflow: auto;'>\n");
                        out.print(availableAppts);
                        out.print("</div>\n");
                        out.print(htmTb.endCell());
                    } else {
                        out.print("No appointments available");
                    }
                } else {
                    out.print("No hours for this day");
                }
            } else {
                out.print("Office is not open this day");
            }
            out.print(htmTb.endRow());
            out.print(htmTb.endTable());
            out.print("</fieldset>");
            out.print(htmTb.endCell());
        }
        out.print(htmTb.endRow());
        out.print(htmTb.endTable());
    } else {
        apptDate=request.getParameter("apptDate");
        String apptTime=request.getParameter("apptTime");
        String appointmentTime = apptTime;

        int resource = 0;
        if(resourceId != null) {
            try {
                resource=Integer.parseInt(resourceId);
            } catch (Exception e) {
            }
        }

        if(apptTime.contains("AM")) {
            apptTime=apptTime.substring(0,5) + ":00";
        } else {
            int hour=Integer.parseInt(apptTime.substring(0,2));
            hour +=12;
            apptTime= hour + ":" + apptTime.substring(3,5) + ":00";
        }
        
        Appointment appt=new Appointment(io, 0);

        appt.setPatientId(patient.getId());
        appt.setDate(java.sql.Date.valueOf(apptDate));
        appt.setTime(java.sql.Time.valueOf(apptTime));
        appt.setType(1);
        appt.setResourceId(resource);
        appt.update();

        sendReminder(io, resource, patient.getId(), apptDate, appointmentTime);

        if(onlineAppt) {
            out.print("<table width='100%' height='100%'><tr><td align=center valign=middle style='font-size: 12px; font-weight: bold;'>Thank you. Your appointment has been scheduled. Please check your email for your appointment confirmation.</td></tr></table>");
        } else {
            out.print("<body onLoad=win("+appointmentNumber+")>");
            out.print("<body>");
        }

    }

%>
</body>
<%! public String getAvailableAppointments(Calendar cal, Hashtable apptTimes, String apptDate, int start, int stop, int increment, int apptDepth, int resourceId, String appointmentNumber) {
        StringBuffer appointments = new StringBuffer();

        int year=Integer.parseInt(Format.formatDate(apptDate, "yyyy"));
        int month=Integer.parseInt(Format.formatDate(apptDate, "MM"));
        int day=Integer.parseInt(Format.formatDate(apptDate, "dd"));

        String startMins = "" + start;
        String stopMins = "" + stop;

        if(startMins.length() == 3) { startMins = startMins.substring(1); } else { startMins = startMins.substring(2); }
        if(stopMins.length() == 3) { stopMins = stopMins.substring(1); } else { stopMins = stopMins.substring(2); }

        start = start/100;
        stop = stop/100;

        int startIncrement = Integer.parseInt(startMins);
        int stopIncrement = Integer.parseInt(stopMins);

        cal.set(year,month,day,stop,stopIncrement,0);
        long endingTime=cal.getTimeInMillis();
        cal.set(year,month,day,start,0,0);
        long startingTime=cal.getTimeInMillis();
        cal.set(year,month,day,start,increment,0);
        long incrementMills=cal.getTimeInMillis()-startingTime;
        cal.set(year,month,day,start,startIncrement,0);

        for(long currentTime=cal.getTimeInMillis()+incrementMills; currentTime<=endingTime; currentTime+=incrementMills) {
            String apptCount=(String)apptTimes.get(Format.formatDate(cal.getTime(),"HH:mm:ss"));
            int scheduledAppts=1;
            if(apptCount != null) { scheduledAppts=Integer.parseInt(apptCount); }

            String key=Format.formatDate(cal.getTime(),"HH:mm:ss");
            if(!apptTimes.containsKey(key) || (apptTimes.containsKey(key) && scheduledAppts<apptDepth)) {
                appointments.append("<a href='scheduleappt.jsp?schedule=Y&resourceId=" + resourceId + "&apptDate=" + apptDate + "&apptTime=" + Format.formatDate(cal.getTime(),"hh:mm a") + "&apptNum=" + appointmentNumber + "' style='font-size: 12px; font-weight: bold;'>" + Format.formatDate(cal.getTime(),"hh:mm a") + "</a><br>\n");
            }
            cal.setTimeInMillis(currentTime);
        }
        return appointments.toString();
    }

    public boolean sendReminder(RWConnMgr io, int resourceId, int patientId, String appointmentDate, String appointmentTime) throws Exception {
        boolean messageSent=true;

        String myQuery = "Select resources.id, " +
                "IfNULL(resources.providerEmailAddress,environment.officeEmailAddress) AS emailAddress, " +
                "IfNull(resources.name,environment.suppliername) as emailName, " +
                "IfNull(resources.apptEmailSubject,environment.apptEmailSubject) AS apptEmailSubject," +
                "IfNull(resources.apptEmailMessage, environment.apptEmailMessage) AS apptEmailMessage " +
                "from resources join environment where resources.id=" + resourceId;

//        try {
            ResultSet lRs = io.opnRS(myQuery);
            if(lRs.next()) {
                String fromName="";
                String fromAddress="";

                if(lRs.getString("emailAddress") != null) { fromAddress=lRs.getString("emailAddress"); }
                if(lRs.getString("emailName") != null) { fromName=lRs.getString("emailName"); } else { fromName=fromAddress; }

                RWEmail email = new tools.RWEmail(fromAddress, fromName);

                ResultSet pRs = io.opnRS("select firstname, lastname, concat(firstname, ' ',lastname) as name, email from patients where id=" + patientId);
                if(pRs.next()) {
                    String content = "text/html";

                    ResultSet emlRs = io.opnRS("select * from chiro_site.emailsettings where id=1");
                    if(emlRs.next()) {
                        String messageText=lRs.getString("apptEmailMessage");
                        String subject = lRs.getString("apptemailsubject");

                        ResultSet aRs = io.opnRS("select * from appointmentreminders where `day`='" + Format.formatDate(appointmentDate, "EEE") + "'");
                        if(aRs.next()) {
                            messageText = aRs.getString("emailmessage");
                            subject = aRs.getString("emailsubject");
                        }
                        aRs.close();
                        
                        messageText = messageText.replaceAll("##PATIENT##", pRs.getString("name"));
                        messageText = messageText.replaceAll("##FIRSTNAME##", pRs.getString("firstname"));
                        messageText = messageText.replaceAll("##LASTNAME##", pRs.getString("lastname"));
                        messageText = messageText.replaceAll("##DOCTOR##", lRs.getString("emailname"));
                        messageText = messageText.replaceAll("##TIME##", appointmentTime);
                        messageText = messageText.replaceAll("##DATE##", Format.formatDate(appointmentDate, "MM/dd/yyyy"));
                        messageText = messageText.replaceAll("##DAY##", Format.formatDate(appointmentDate, "EEE"));

                        email.setContentType(content);
                        if(emlRs.getString("smtphost") != null && !emlRs.getString("smtphost").equals("")) {
                            email.setSMTPHost(emlRs.getString("smtphost"));
                            email.setSMTPUser(emlRs.getString("smtpuser"));
                            email.setSMTPPassword(emlRs.getString("smtppass"));
                        }

                        email.setToName(pRs.getString("name"));
                        email.setToAddress(pRs.getString("email"));
                        email.setSubject(subject);
                        email.setMessage(messageText);
                        email.setAttachmentName("test.xls");
                        email.send();
                    }
                }
                pRs.close();
            }
            lRs.close();
//        } catch (Exception e) {
//        }
        return messageSent;
    }
%>