<%@ include file="../template/pagetop.jsp" %>
<%@page import="tools.*"%>
<%@page import="medical.*"%>
<%@page import="java.util.*"%>
<%@page import="java.sql.*"%>
<body OnLoad="document.Search.srchString.focus()";> 
<style>
th	    { font-size: 11px;
              font-family: Arial, Helvetica, sans-serif;
	      background-color: silver;
	      color: black;  }
</style>
<script language="javascript">
  function submitForm(action) {
    var frmA=document.forms["frmInput"]
    frmA.method="POST"
    frmA.action=action
    frmA.submit()
  }
    </script>
<%
//--------------------------------------------------------------------------------------------------------------//
//- Start Code                                   
//--------------------------------------------------------------------------------------------------------------//
// Get Parameters

    int scrollValue = 0;
    int addDays = 0;
    int apptId = 0;
    int patientId = 0;

// If button 2 was clicked, delete the appointment
    if (request.getParameter("btn2")!=null) {
        apptId=Integer.parseInt((String)session.getAttribute("apptId"));
        deleteAppointment(io, apptId);
        response.sendRedirect(self);

// If button 1 was clicked, update the appointment
    } else if (request.getParameter("btn1")!=null) {
        apptId=Integer.parseInt((String)session.getAttribute("apptId"));
        patientId=Integer.parseInt((String)session.getAttribute("patientId"));
        String apptTime = request.getParameter("time");
        String apptDate = request.getParameter("date");
        int type = Integer.parseInt(request.getParameter("type"));
        apptDate=apptDate.substring(6,10) + "-" + apptDate.substring(0,2) + "-" + apptDate.substring(3,5);
        updateAppointment(io, apptId, patientId, apptDate, apptTime, type);
        response.sendRedirect(self);

    } else {

        String month = (String)session.getAttribute("month");
        String year  = (String)session.getAttribute("year");
        String time  = (String)session.getAttribute("time");
        String date  = (String)session.getAttribute("date");
        String apptIdStr = (String)session.getAttribute("apptId");
        String patientIdStr = (String)session.getAttribute("patientId");
        String srchString = "*EMPTY";

        if (apptIdStr != null) {
            apptId = Integer.parseInt(apptIdStr);
        }
        if (patientIdStr != null) {
            patientId = Integer.parseInt(patientIdStr);
        }

        if (request.getParameter("month")!=null) {
            month=request.getParameter("month");
            session.setAttribute("month", month);
        }
        if (request.getParameter("year")!=null) {
            year=request.getParameter("year");
            session.setAttribute("year", year);
        }
        if (request.getParameter("time")!=null) {
            time=request.getParameter("time");
            session.setAttribute("time", time);
        }
        if (request.getParameter("date")!=null) {
            date=request.getParameter("date");
            session.setAttribute("date", date);
        }
        if (request.getParameter("scrollup")!=null) {
            scrollValue=-15*Integer.parseInt(request.getParameter("scrollup"));
        }
        if (request.getParameter("scrolldown")!=null) {
            scrollValue=15*Integer.parseInt(request.getParameter("scrolldown"));
        }
        if (request.getParameter("adddays")!=null) {
            addDays=Integer.parseInt(request.getParameter("adddays"));
        }
        if (request.getParameter("apptId")!=null) {
            if (apptId == Integer.parseInt(request.getParameter("apptId")) && request.getParameter("apptTime")==null) {
                apptId = 0;
            } else {
                apptId=Integer.parseInt(request.getParameter("apptId"));
            }
            session.setAttribute("apptId", ""+apptId);
        }
        if (request.getParameter("patientId")!=null) {
            patientId=Integer.parseInt(request.getParameter("patientId"));
            session.setAttribute("patientId", ""+patientId);
        }
        if (request.getParameter("srchString")!=null) {
            srchString=request.getParameter("srchString");
            apptId=0;
            patientId=0;
            session.setAttribute("patientId", ""+patientId);
            session.setAttribute("apptId", ""+apptId);
        }
        if (patientId==0 && apptId>0) {
            Appointment thisAppointment = new Appointment(io,""+apptId);
            if (thisAppointment.next()) { 
                patientId = thisAppointment.getInt("patientId");
                session.setAttribute("patientId", ""+patientId);
            }
        }

    // If the apptTime parameter was passed, the user is trying to schedule an appointment
        if (request.getParameter("apptTime")!=null) {
            String apptDate = request.getParameter("apptDate");
            String apptTime = request.getParameter("apptTime");
            updateAppointment(io, apptId, patientId, apptDate, apptTime+":00", 0);
            response.sendRedirect(self);
        } else if (scrollValue!=0) {
            AppointmentCalendar thisApptCal;
            thisApptCal = (AppointmentCalendar)session.getAttribute("thisApptCal");
            thisApptCal.add(Calendar.MINUTE,scrollValue);
            response.sendRedirect(self);
        } else {

    // Build the screen contents
            RWHtmlTable htmTb = new RWHtmlTable("","0");
            htmTb.replaceNLChar = false;
            htmTb.setCellPadding("1");

            out.print(htmTb.startTable());

            out.print(htmTb.startRow());

            out.print(htmTb.addCell(getLeftPane(session, htmTb, io, lCn, date, month, year, self,
                                                apptId, srchString, patientId, request)));

            patientIdStr = (String)session.getAttribute("patientId");
            if (patientIdStr != null) {
                patientId = Integer.parseInt(patientIdStr);
            }

            out.print(htmTb.addCell(getRightPane(session, htmTb, io, lCn, date, month, year, self, 
                                                scrollValue, addDays, apptId, patientId)));

            out.print(htmTb.endRow());

            out.print(htmTb.endTable());
        }
    }
//--------------------------------------------------------------------------------------------------------------//

%>
<%
//--------------------------------------------------------------------------------------------------------------//
//- Delete the Appointment  ------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------//
%>
<%! public void deleteAppointment(RWConnMgr io, int apptId) throws Exception {
        Appointment thisAppointment = new Appointment(io,""+apptId);
        thisAppointment.delete();
}
%>
<%
//--------------------------------------------------------------------------------------------------------------//
//- Update the Appointment  ------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------//
%>
<%! public void updateAppointment(RWConnMgr io, int apptId, int patientId, String apptDate, 
                                    String apptTime, int type) throws Exception {
        Appointment thisAppointment = new Appointment(io,""+apptId);
        thisAppointment.setPatientId(patientId);
        thisAppointment.setDate(java.sql.Date.valueOf(apptDate));
        thisAppointment.setTime (java.sql.Time.valueOf(apptTime));
        if (type > 0) {
            thisAppointment.setType(type);
        }
        thisAppointment.update();
}
%>
<%
//--------------------------------------------------------------------------------------------------------------//
//- Get the left Pane    ---------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------//
%>
<%! public String getLeftPane(HttpSession session, RWHtmlTable htmTb, RWConnMgr io, Connection lCn, 
                                String date, String month, String year, String self,
                                int apptId, String srchString, int patientId,
                                HttpServletRequest request) throws Exception {
    StringBuffer lP = new StringBuffer();
    
    lP.append(htmTb.startTable());
    lP.append(htmTb.startRow());
    lP.append(htmTb.addCell(getDatePicker(month, year, self)));
    lP.append(htmTb.endRow());
    lP.append(htmTb.startRow());
    lP.append(htmTb.addCell(getSearchBubble(io)));
    lP.append(htmTb.endRow());
    lP.append(htmTb.startRow());
    lP.append(htmTb.addCell(getPatientInfo(session, io, apptId, srchString, patientId, request)));
    lP.append(htmTb.endRow());
    lP.append(htmTb.startRow());
    lP.append(htmTb.addCell(getApptInfo(io, apptId)));
    lP.append(htmTb.endRow());
    lP.append(htmTb.endTable());
    
    return lP.toString();
}
%>
<%
//--------------------------------------------------------------------------------------------------------------//
//- Get the right Pane    ---------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------//
%>
<%! public String getRightPane(HttpSession session, RWHtmlTable htmTb, RWConnMgr io, Connection lCn, String date, 
                    String month, String year, String self, int scrollValue, int addDays,
                    int apptId, int patientId) throws Exception {
    StringBuffer rP = new StringBuffer();
    
    rP.append(getApptCalendar(session, io, lCn, self, date, scrollValue, addDays, apptId, patientId));
    
    return rP.toString();
}
%>
<%
//--------------------------------------------------------------------------------------------------------------//
//- Get the Date Picker  ---------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------//
%>
<%! public String getDatePicker(String month, String year, String self) throws Exception {
    RWHtmlTable htmTb = new RWHtmlTable("","0");
    htmTb.replaceNLChar = false;

    if(month == null || month=="") {
        month = Format.formatDate(new java.util.Date(), "MMMM");
    }
    if(year == null || year=="") {
        year = Format.formatDate(new java.util.Date(), "yyyy");
    }
    
    RWCalendar cal = new RWCalendar(Integer.parseInt(year), month);
    cal.setCalendar();
    cal.setDayUrl(self);
    cal.setBgColorForToday("yellow");

    return htmTb.getFrame(htmTb.BOTH,"","white",3,cal.getHtmlCalendar(""));
    //return cal.getHtmlCalendar("");
}
%>
<%
//--------------------------------------------------------------------------------------------------------------//
//- Get the Patient Info ---------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------//
%>
<%! public String getPatientInfo(HttpSession session, RWConnMgr io, int apptId, String srchString, 
                                int patientId, HttpServletRequest request) throws Exception {
    String cardCondition = "";
    ResultSet lRs;
    try {
        cardCondition = "or cardnumber = " + Integer.parseInt(srchString) + " ";
    } catch (Exception e) {
        
    }
    if (!srchString.equals("*EMPTY")) {
        if(srchString.equals("")) { return ""; }
        String searchSql = "select id as patientId, lastname, firstname from patients where  " +
                "lastname like '%" + srchString + "%' or " +
                "firstname like '%" + srchString + "%' " +
                cardCondition +
                " order by lastname, firstname";
        lRs = io.opnRS(searchSql);
        if (lRs.next()) {
            patientId=lRs.getInt("patientId");
            if(lRs.next()) {
                return getSearchResults(io, searchSql, request);
            }
        }
    }

    if (apptId!=0) { 
        Appointment thisAppointment = new Appointment(io,""+apptId);
        if (!thisAppointment.next()) { return ""; }
        patientId = thisAppointment.getInt("patientid");
    }

    if (patientId==0) { return ""; } 
    
    Patient thisPatient = new Patient(io, ""+patientId);
    if (!thisPatient.next()) { return ""; } 
    thisPatient.beforeFirst();
    RWHtmlTable htmTb = new RWHtmlTable("","0");
    htmTb.replaceNLChar = false;
    
    session.setAttribute("patientId", ""+patientId); 
    
    return htmTb.getFrame(htmTb.BOTH,"","white",3,thisPatient.getMiniContactInfo(htmTb));
}
%>
<%
//--------------------------------------------------------------------------------------------------------------//
//- Get the Patient Search Results -----------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------//
%>
<%! public String getSearchResults(RWConnMgr io, String myQuery, HttpServletRequest request) throws Exception {

    RWHtmlTable htmTb = new RWHtmlTable("","0");
    htmTb.replaceNewLineChar(false);    
    
// Create an RWFiltered List object to show the occupations
    RWFilteredList lst = new RWFilteredList(io);

// Create an array with the column headings
    String [] columnHeadings = { "id",  "Last Name", "First Name"};

// Set special attributes on the filtered list object
    lst.setTableBorder("0");
    lst.setCellPadding("1");
    lst.setCellSpacing("0");
    lst.setTableWidth("100%");
    lst.setAlternatingRowColors("white","lightgrey");
    lst.setUrlField(0);
    lst.setNumberOfColumnsForUrl(3);
    lst.setRowUrl("apptcalendar.jsp");
    lst.setShowRowUrl(true);
    lst.setShowComboBoxes(false);
    lst.setShowColumnHeadings(false);

// Set specific column widths
    String [] cellWidths = {"0%", "100", "100"};
    lst.setColumnWidth(cellWidths);

// Show the list of occupations
    return htmTb.getFrame(htmTb.BOTH, "","white",0,"<div style=\"width: 200; height: 178; overflow: auto;\">" + lst.getHtml(request, myQuery, columnHeadings) + "</div>");

}
%>
<%
//--------------------------------------------------------------------------------------------------------------//
//- Get the Patient Info ---------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------//
%>
<%! public String getSearchBubble(RWConnMgr io) throws Exception {

    RWHtmlTable htmTb = new RWHtmlTable("200","0");
    RWHtmlForm frm = new RWHtmlForm("Search","apptcalendar.jsp");
    frm.setMethod("GET");
    htmTb.replaceNLChar = false;
    StringBuffer sB = new StringBuffer();

    sB.append(htmTb.startTable());
    sB.append(frm.startForm());
    sB.append(htmTb.startRow());
    sB.append(htmTb.addCell(frm.textBox("","srchString", "class=tBoxText width=100 size=37")));
    sB.append(htmTb.addCell(frm.submitButton("go", "class=button", "gobutton")));
    sB.append(htmTb.endRow());
    sB.append(frm.endForm());
    sB.append(htmTb.endTable());

    return htmTb.getFrame(htmTb.BOTH,"","white",3,sB.toString());

}
%>
<%
//--------------------------------------------------------------------------------------------------------------//
//- Get the Appointment Info ---------------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------//
%>
<%! public String getApptInfo(RWConnMgr io, int apptId) throws Exception {

    if (apptId==0) { return ""; }

    RWHtmlTable htmTb = new RWHtmlTable("","0");
    htmTb.replaceNLChar = false;

    Appointment thisAppointment = new Appointment(io,""+apptId);

    if (!thisAppointment.next()) { return ""; }
    thisAppointment.beforeFirst();
    return htmTb.getFrame(htmTb.BOTH,"","white",3,thisAppointment.getMiniInputForm());
}
%>
<%
//--------------------------------------------------------------------------------------------------------------//
//- Get the Appointment Calendar -------------------------------------------------------------------------------//
//--------------------------------------------------------------------------------------------------------------//
%>
<%! public String getApptCalendar(HttpSession session, RWConnMgr io, Connection lCn, String self, 
                        String date, int scrollValue, int addDays, int apptId, 
                        int patientId) throws Exception {

    RWHtmlTable htmTb = new RWHtmlTable("","0");
    htmTb.replaceNLChar = false;

    AppointmentCalendar thisApptCal;
    thisApptCal = (AppointmentCalendar)session.getAttribute("thisApptCal");
    // If we couldn't find the stored calendar, instantiate one
    if (thisApptCal == null) {
        thisApptCal = new AppointmentCalendar();
        thisApptCal.setColsToGenerate(12);
        thisApptCal.setRowsToGenerate(21);
        thisApptCal.setStartMinute(00);
        //thisApptCal.setStartAM_PM(0);
        thisApptCal.setIncrementMinutes(15);
        thisApptCal.setCellWidth("60");
        thisApptCal.setTimeURL(self);
        thisApptCal.setScrollURL(self);
        thisApptCal.setScrollTimeIncrements(12);
    }
    
    if (date==null ||date.equals("")) {
        date = "current_date";
    } else {
        int yr = Integer.parseInt(date.substring(0,4))-1900;
        int mt = Integer.parseInt(date.substring(4,6))-1;
        int dy = Integer.parseInt(date.substring(6,8));
        date = "'" + date.substring(0,4) + "-" + date.substring(4,6)+"-" + date.substring(6,8) + "'";
        thisApptCal.setDate(new java.util.Date(yr,mt,dy));
    }
    thisApptCal.setSelectedAppointment(apptId);
    thisApptCal.setPatientId(patientId);
    if (scrollValue!=0) {
        thisApptCal.add(Calendar.MINUTE,scrollValue);
    }
    if (addDays!=0) {
        thisApptCal.add(Calendar.DATE,addDays);
    }

    date = "'" + thisApptCal.getIsoDate() +"'";

    ResultSet lRs = io.opnRS("select date, time, concat(substr(firstname,1,1), ' ', lastname), a.id, type from appointments a join patients b on a.patientid=b.id where date = " + date);
    thisApptCal.setApptRs(lRs);
    lRs = io.opnRS("select * from appointmenttypes");
    thisApptCal.setApptTypesRs(lRs);

    // store the calendar for later use
    session.setAttribute("thisApptCal", thisApptCal);
    date = date.substring(1,5) + date.substring(6,8) + date.substring(9,11);
    session.setAttribute("date", date);

    return htmTb.getFrame(htmTb.BOTH,"","white",3,thisApptCal.getHtmlGrid());
}
%>
    <%@ include file="../template/pagebottom.jsp" %>
