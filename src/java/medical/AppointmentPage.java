/*
 * AppointmentPage.java
 *
 * Created on November 29, 2005, 8:36 PM
 *
 * To change this template, choose Tools | Options and locate the template under
 * the Source Creation and Management node. Right-click the template and choose
 * Open. You can then make changes to the template in the Source Editor.
 */

package medical;

import tools.*;
import tools.utils.*;
import java.sql.*;
import java.util.*;
import javax.servlet.http.HttpServletRequest;

/**
 *
 * @author BR Online Solutions
 */
public class AppointmentPage {

    private RWConnMgr io;
    private RWHtmlTable htmTb;
    private RWHtmlTable outerHtmTb;
    private RWCalendar cal;
    private RWHtmlForm frm;
    
    private String self = "";
    private String btn1 = "";
    private String btn2 = "";
    private String date = "";
    private String time = "";
    private String srchString = "";
    private String apptDate = "";
    private String apptTime = "";
    private String apptMissedReason = "";
    private String apptNotes = "";
    private String platterColor = "#ffffff";

    private int type = 0;
    private int intervals = 0;
    private int scrollUp = 0;
    private int scrollDown = 0;
    private int scrollValue = 0;
    private int addDays = 0;
    private int apptId = 0;
    private int patientId = 0;
    private int morningStart = 6;
    private int afternoonStart = 13;
    private int showAfternoonAfter = 11;
    private int incrementMinutes = 15;
    
    public Appointment thisAppointment;
    public AppointmentCalendar thisApptCal;
    public Patient thisPatient;
    private HttpServletRequest request;
    
    //RKW - 10/02/2008 - Added resource id for updating appointment
    private int resourceId=0;
    
    //RKW - 06/09/2009 - Added rowsToGenerate to control the rowsToGenerate in the appointment calendar
    private int rowsToGenerate=32;

    private int calendarResourceId = 0;

    /** Creates a new instance of AppointmentPage */
    public AppointmentPage(RWConnMgr newIo, String url) {
        try {
            io=newIo;
            
            htmTb = new RWHtmlTable("","0");
            frm= new RWHtmlForm();
            htmTb.replaceNLChar = false;
            outerHtmTb = new RWHtmlTable("","0");
            outerHtmTb.setCellPadding("1");
            outerHtmTb.replaceNLChar = false;

            self=url;

            cal = new RWCalendar(Integer.parseInt(Format.formatDate(new java.util.Date(), "yyyy")), 
                                            Format.formatDate(new java.util.Date(), "MMMM"));
            cal.setCalendar();
            cal.showMonthCombo(true);
            cal.showYearCombo(true);
            cal.setLongMonth(true);
            cal.setDayUrl(self);
            cal.setBgColorForToday("yellow");
            cal.setBgColorForSelected("orange");
            cal.showSelectedDate(true);
            int hourOfDay = Calendar.getInstance().get(Calendar.HOUR_OF_DAY);        
            thisApptCal = new AppointmentCalendar();

            thisApptCal.setApptTypesRs(io.opnRS("select * from appointmenttypes order by id"));

            thisApptCal.setColsToGenerate(9);

//RKW 06/09/09
//          thisApptCal.setRowsToGenerate(23);
            thisApptCal.setRowsToGenerate(this.rowsToGenerate);
            thisApptCal.setStartMinute(00);
// 10/24/07 changed to use incrementMinutes variable
//          thisApptCal.setIncrementMinutes(15);
            thisApptCal.setIncrementMinutes(this.incrementMinutes);
            thisApptCal.setCellWidth("58");
            thisApptCal.setTimeURL(url);
            thisApptCal.setScrollURL(url);
            thisApptCal.setScrollTimeIncrements(28);
            if (hourOfDay>showAfternoonAfter) {
                thisApptCal.setStartHour(afternoonStart);
            } else {
                thisApptCal.setStartHour(morningStart);
            }

            thisAppointment = new Appointment(io, "0");
            thisPatient = new Patient(io, "0");          
            
        } catch (Exception e) {
        }

    }

//---------------------------------------------------------------------------------------------//
    /**
     * Process a request's parameters.
     */
//---------------------------------------------------------------------------------------------//
    public void processRequestParameters(HttpServletRequest request) throws Exception {

        // If the "show arrivals" checkbox is sent, then set the boolean
        if (request.getParameter("showarrivals")!=null) {
            thisApptCal.setShowArrivals(Boolean.parseBoolean(request.getParameter("showarrivals")));
        }        
        
        // If the "show for resource" combobox is sent, then set the resource
        if (request.getParameter("showforresource")!=null) {
            thisApptCal.setShowForResource(Integer.parseInt(request.getParameter("showforresource")));
        }        
        
        // If a new patient was selected, reset the appointment ID to zero
        if (request.getParameter("srchPatientId")!=null) {
            apptId=0;
            thisApptCal.setSelectedAppointment(0);
            patientId=Integer.parseInt(request.getParameter("srchPatientId"));
        }
        
        // Process Delete Request
        if (request.getParameter("btn2")!=null) {
            deleteAppointment();
        }
        
        if (request.getParameter("calendarResourceId")!=null) {
            resourceId=Integer.parseInt(request.getParameter("calendarResourceId"));
            this.calendarResourceId=resourceId;
        }

        // Process Update Request
        if (request.getParameter("btn1")!=null) {
            apptMissedReason = request.getParameter("missedreason");
            apptNotes = request.getParameter("notes");
            apptTime = request.getParameter("time");
            apptDate = request.getParameter("date");
            intervals = Integer.parseInt(request.getParameter("intervals"));
            type = Integer.parseInt(request.getParameter("type"));
            apptDate=apptDate.substring(6,10) + "-" + apptDate.substring(0,2) + "-" + apptDate.substring(3,5);
            if(request.getParameter("resourceId") != null) { resourceId=Integer.parseInt(request.getParameter("resourceId")); }
            updateAppointment();
        }

        // Schedule an appointment
        if (request.getParameter("apptTime")!=null && patientId>0 && (this.thisApptCal.selectedAppointment!=0 || this.apptId==0)) {
            apptDate = request.getParameter("apptDate");
            apptTime = request.getParameter("apptTime") + ":00";
            type = 0;
            intervals=0;
            apptMissedReason="";
            apptNotes = "";
            resourceId=Integer.parseInt(request.getParameter("resourceId"));
            updateAppointment();
            this.thisApptCal.setSelectedAppointment(0);
            this.apptId=0;
        }
        
        srchString = "*EMPTY";

        if (request.getParameter("year")!=null) {
            cal.setYear(Integer.parseInt(request.getParameter("year")));
        }
        if (request.getParameter("month")!=null) {
            cal.setMonth(request.getParameter("month"));
        }
        cal.setCalendar();

        if (request.getParameter("date")!=null && request.getParameter("btn2")==null
                && request.getParameter("btn1")==null) {
            date=request.getParameter("date");
            int yr = Integer.parseInt(date.substring(0,4))-1900;
            int mt = Integer.parseInt(date.substring(4,6))-1;
            int dy = Integer.parseInt(date.substring(6,8));
            thisApptCal.setDate(new java.util.Date(yr,mt,dy));
        }

        if (request.getParameter("adddays")!=null) {
            addDays=Integer.parseInt(request.getParameter("adddays"));
            thisApptCal.add(Calendar.DATE,addDays);
        }

        scrollValue = 0;
        if (request.getParameter("scrollup")!=null) {
// RKW - 07/07/11            scrollValue=-this.incrementMinutes*Integer.parseInt(request.getParameter("scrollup"));
            thisApptCal.scrollToTime=request.getParameter("time");
        }
        if (request.getParameter("scrolldown")!=null) {
// RKW - 07/07/11            scrollValue=this.incrementMinutes*Integer.parseInt(request.getParameter("scrolldown"));
            thisApptCal.scrollToTime=request.getParameter("time");

        }
        if (scrollValue != 0) {
// RKW - 07/07/11            thisApptCal.add(Calendar.MINUTE,scrollValue);
        }
        
        if (request.getParameter("patientId")!=null && request.getParameter("apptTime")==null) {
            patientId=Integer.parseInt(request.getParameter("patientId"));
        }

        if (request.getParameter("apptId")!=null) {
            if (apptId == Integer.parseInt(request.getParameter("apptId")) && request.getParameter("apptTime")==null) {
                apptId = 0;
            } else {
                apptId=Integer.parseInt(request.getParameter("apptId"));
                if (request.getParameter("apptTime")==null &&  (request.getHeader("referer")!=null && request.getHeader("referer").indexOf(self)<0)) {
//                if (request.getParameter("apptTime")==null &&  ((request.getHeader("referer")!=null && request.getHeader("referer").indexOf(self)<0)) ) {
                    if(io.getConnection().isClosed()) { io.setConnection(io.opnmySqlConn()); }
                    ResultSet apptRs=io.opnRS("select * from appointments where id =" + apptId);
                    thisAppointment.setResultSet(apptRs);
                    if (thisAppointment.next()) { 
                        String time = thisAppointment.getString("time");
                        int hour = Integer.parseInt(time.substring(0, 2));
                        if (hour>12) {
                            thisApptCal.setStartAM_PM(1);
                        } else {
                            thisApptCal.setStartAM_PM(0);
                        }
                        thisApptCal.setStartHour(hour);
                        thisApptCal.setStartMinute(00);
                        patientId = thisAppointment.getInt("patientId");
                        thisAppointment.beforeFirst();
                    }
                    apptRs.close();
                }
            }
// RKW 08/25/10            thisApptCal.setSelectedAppointment(apptId);
        }

//        if (request.getParameter("srchString")!=null) {
//            thisApptCal.setSelectedAppointment(0);
//            srchString=request.getParameter("srchString");
//            apptId=0;
//            patientId=0;
//        }
        
        ResultSet tmpAppt=io.opnRS("select * from appointments where id =" + apptId);
        thisAppointment.setResultSet(tmpAppt);
        if (thisAppointment.next()) { 
            patientId = thisAppointment.getInt("patientId");
            thisAppointment.beforeFirst();
        }
        tmpAppt.close();
        thisPatient.setId(patientId);

    }
    
 //---------------------------------------------------------------------------------------------//
    /**
     * Update the appointment with the values currnetly set
     */
//---------------------------------------------------------------------------------------------//
   public void updateAppointment() throws Exception { 
        thisAppointment.setId(apptId);
        thisAppointment.setPatientId(patientId);
        thisAppointment.setDate(java.sql.Date.valueOf(apptDate));
        thisAppointment.setTime (java.sql.Time.valueOf(apptTime));
        thisAppointment.setMissedReason (apptMissedReason);
        thisAppointment.setResourceId(resourceId);
        thisAppointment.setNotes(apptNotes);
        if (apptId==0) { 
            thisAppointment.setType(0);
            intervals=1;
        }
        if (intervals > 0) {
            thisAppointment.setIntervals(intervals);
        }
        if (type > 0) {
            thisAppointment.setType(type);
        }
        thisAppointment.update();
        if (apptId==0) {
            apptId = thisAppointment.getInt("id");
        }
    }    

//---------------------------------------------------------------------------------------------//
    /**
     * Delete the current Appointment.
     */
//---------------------------------------------------------------------------------------------//
    public void deleteAppointment() throws Exception {
        thisAppointment.setResultSet(io.opnUpdatableRS("select * from appointments where id =" + apptId));
        thisAppointment.delete();
        apptId=0;
        thisApptCal.setSelectedAppointment(apptId);
    }
    
//---------------------------------------------------------------------------------------------//
    /**
     * Get the Left Pane of the Page.
     */
//---------------------------------------------------------------------------------------------//
    public String getLeftPane() throws Exception {
        StringBuffer lP = new StringBuffer();

        lP.append(outerHtmTb.startTable());
        lP.append(outerHtmTb.startRow());
        lP.append(outerHtmTb.addCell(getDatePicker()));
        lP.append(outerHtmTb.endRow());
        
        lP.append(outerHtmTb.startRow());
        lP.append(outerHtmTb.addCell("<hr>" + frm.checkBox(thisApptCal.getShowArrivals(),"onClick=\"window.location.href='?showarrivals=' + this.checked \"","showarrivals") + " Show arrivals"));
        lP.append(outerHtmTb.endRow());

        ResultSet rscRs = io.opnRS("select 0 as id, '*ALL' as name union select id, name from resources");
        String[] preload={};

        lP.append(outerHtmTb.startRow());
        lP.append(outerHtmTb.addCell("Appts for: " + frm.comboBox(rscRs,"calendarResourceId","id",false,"1",null,""+calendarResourceId,"onChange=showForResource(this) class=cBoxText") + "<hr>"));
        lP.append(outerHtmTb.endRow());

        lP.append(outerHtmTb.startRow());
// pre-ajax        lP.append(outerHtmTb.addCell(getApptInfo(io, apptId), "id=\"appointmentEditForm\""));
        lP.append(outerHtmTb.addCell(""));
        lP.append(outerHtmTb.endRow());
        lP.append(outerHtmTb.endTable());
        
        return lP.toString();
    }

//---------------------------------------------------------------------------------------------//
    /**
     * Get the rigjht pane of the page
     */
//---------------------------------------------------------------------------------------------//
    public String getRightPane() throws Exception {
        StringBuffer rP = new StringBuffer();

        thisApptCal.setRowsToGenerate(this.rowsToGenerate);
        rP.append(getApptCalendar());

        return rP.toString();
    }
    
//---------------------------------------------------------------------------------------------//
    /**
     * Get the date picker.
     */
//---------------------------------------------------------------------------------------------//
    public String getDatePicker() throws Exception {
        cal.setSelectedDate(thisApptCal.getIsoDate());
        return htmTb.getFrame(htmTb.BOTH,"",platterColor,3,cal.getHtmlCalendar(""));
    }
    
//---------------------------------------------------------------------------------------------//
    /**
     * Get the patient.
     */
//---------------------------------------------------------------------------------------------//
    public Patient getPatient() throws Exception {

        return thisPatient;
    }
    
//---------------------------------------------------------------------------------------------//
    /**
     * Get the search bubble.
     */
//---------------------------------------------------------------------------------------------//
    public String getSearchBubble() throws Exception {

       return thisPatient.getSearchBubble(self);

    }
    
//---------------------------------------------------------------------------------------------//
    /**
     * Get the patient information.
     */
//---------------------------------------------------------------------------------------------//
    public String getPatientInfo() throws Exception {
        String returnValue = thisPatient.getSearchResults(srchString, self, "patientId");
        if (thisPatient.getId() > 0) {
            patientId = thisPatient.getId();
            thisPatient.beforeFirst();
            if (!thisPatient.next()) { return ""; } 
            thisPatient.beforeFirst();
        } 
        return returnValue;
    }
    
//---------------------------------------------------------------------------------------------//
    /**
     * Get the appointment information.
     */
//---------------------------------------------------------------------------------------------//
    public String getApptInfo(RWConnMgr io, int apptId) throws Exception {

        if (apptId==0) { return ""; }

        thisAppointment.beforeFirst();
        if (!thisAppointment.next()) { return ""; }

        thisAppointment.beforeFirst();

        return htmTb.getFrame(htmTb.BOTH,"",platterColor,3,thisAppointment.getMiniInputForm());

    }

//---------------------------------------------------------------------------------------------//
    /**
     * Get the HTML that represents the Appointment Calendar
     */
//---------------------------------------------------------------------------------------------//
    public String getApptCalendar() throws Exception {
        int startHour=0;  // RKW 07/07/11
        int startMinute=0;  // RKW 07/07/11

        StringBuffer ac=new StringBuffer();
        StringBuffer hd=new StringBuffer();
        
        // RKW 10/02/08 - wrap the sql with the list of resources
// RKW 07/07/11        ac.append(thisApptCal.getMainHeader());
        hd.append(thisApptCal.getMainHeader());  // RKW 07/07/11
        ac.append("<table><tr>");
        date = "'" + thisApptCal.getIsoDate() +"'";

// RKW 07/07/11
        if(thisApptCal.scrollToTime != null){
            startHour=Integer.parseInt(thisApptCal.scrollToTime.substring(0,2));
            if(startHour<12) { thisApptCal.setStartAM_PM(thisApptCal.myCalendar.AM); } else { thisApptCal.setStartAM_PM(thisApptCal.myCalendar.PM); startHour -= 12; }
            startMinute=Integer.parseInt(thisApptCal.scrollToTime.substring(3));
        } else {
            startHour=thisApptCal.startHour;
            startMinute=thisApptCal.startMinute;
        }

        try {
            String myLocalQuery="select id from resources where id in " + 
                    "(select distinct resourceid from dayhours where `day` LIKE(SUBSTRING(UCASE(DATE_FORMAT(" + date + ",'%W')),1,3)) ) " +
                    "order by calendarseq";
            
            ResultSet resourceRs=io.opnRS(myLocalQuery);
            while(resourceRs.next()) {
                if(calendarResourceId==0 || calendarResourceId==resourceRs.getInt("id")) {
                    thisApptCal.setShowForResource(resourceRs.getInt("id"));
                    String appointmentQuery = "select a.date, time, concat(substr(firstname,1,1), ' ', lastname), " +
                            "a.id, a.type, intervals, ifnull(v.id, 0) as visitid, b.resourceid " +
                            "from appointments a join patients b on a.patientid=b.id " +
                            "join appointmenttypes c on a.type =c.id " +
                            "left join visits v on a.id=v.appointmentid " +
                            "where a.date between " +
                            "date_sub(" + date + ", interval 1 day) and date_add(" + date + ", interval 1 day) ";
        //            if (thisApptCal.getShowForResource()>0) {
                        appointmentQuery += " and a.resourceid=" + thisApptCal.getShowForResource() + " ";
        //            }
                    appointmentQuery += " order by date, time, sequence,id";
                    ResultSet hoursRs=io.opnRS("select * from dayhours where `day` LIKE(SUBSTRING(UCASE(DATE_FORMAT(" + date + ",'%W')),1,3)) AND resourceid="+thisApptCal.getShowForResource());
                    if(hoursRs.next()) { thisApptCal.setIncrementMinutes(hoursRs.getInt("incrementminutes")); }
                    hoursRs.close();
                    hoursRs=null;

                    ResultSet lRs = io.opnRS(appointmentQuery);
                    thisApptCal.setApptRs(lRs);

                    thisApptCal.startHour=startHour;        // RKW 07/07/11
                    thisApptCal.startMinute=startMinute;    // RKW 07/07/11
                    ac.append("<td>" + thisApptCal.getHtmlGrid() + "</td>");
                }
            }
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }

        thisApptCal.scrollToTime=null;
        
        // RKW 10/05/2008 - Now do the general office
        String appointmentQuery = "select a.date, time, concat(substr(firstname,1,1), ' ', lastname), " + 
                "a.id, a.type, intervals, ifnull(v.id, 0) as visitid, b.resourceid " +
                "from appointments a join patients b on a.patientid=b.id " + 
                "join appointmenttypes c on a.type =c.id " +
                "left join visits v on a.id=v.appointmentid " +
                "where a.date between " + 
                "date_sub(" + date + ", interval 1 day) and date_add(" + date + ", interval 1 day) ";
        appointmentQuery += " and a.resourceid=0 ";
        appointmentQuery += " order by date, time, sequence,id";

        ResultSet lRs = io.opnRS(appointmentQuery);
        thisApptCal.setApptRs(lRs);

        thisApptCal.setShowForResource(0);
        ac.append("<td>" + thisApptCal.getHtmlGrid() + "</td>");
        
        ac.append("</tr></table>");

// RKW 07/07/11        return htmTb.getFrame(htmTb.BOTH,"",platterColor,3,htmTb.getTableDiv(480,650,"",ac.toString()));
        return htmTb.getFrame(htmTb.BOTH,"",platterColor,3,hd.toString() + htmTb.getTableDiv(480,630,"",ac.toString()));
//        return htmTb.getFrame(htmTb.BOTH,"",platterColor,3,ac.toString());
        
    }

//---------------------------------------------------------------------------------------------//
    /**
     * Get the HTML that represents the Appointment Page.
     */
//---------------------------------------------------------------------------------------------//
    public String getHtml(HttpServletRequest newRequest) throws Exception {

        request=newRequest;

        thisAppointment.setResultSet(io.opnRS("select * from appointments where id =" + apptId));
        if (thisAppointment.next()) { 
            patientId = thisAppointment.getInt("patientId");
            thisAppointment.beforeFirst();
        }
        if (patientId!=0) {
            thisPatient.setResultSet(io.opnRS("select * from patients where id =" + patientId));
        }
        StringBuffer html = new StringBuffer();
        String query = "select * from calmsgs where date ='" + thisApptCal.getIsoDate() + "'";
        ResultSet lRs = io.opnRS(query);
        html.append(outerHtmTb.startTable());

        if (lRs.next()) {
            html.append(outerHtmTb.startRow());
            html.append(outerHtmTb.addCell(lRs.getString("message"), "style=\"text-align=center; color=black; background=yellow; font-weight: bold;\" colspan=2"));
            html.append(outerHtmTb.addCell("&nbsp;", "colspan=2"));
            html.append(outerHtmTb.endRow());
        }

        html.append(outerHtmTb.startRow());

        html.append(outerHtmTb.addCell(getLeftPane()));
        html.append(outerHtmTb.addCell(getRightPane()));

        html.append(outerHtmTb.endRow());

        html.append(outerHtmTb.endTable());
        
        return html.toString();
    }

//---------------------------------------------------------------------------------------------//
    /**
     * Set the connection manager.
     */
//---------------------------------------------------------------------------------------------//
    public void setConnMgr(RWConnMgr newIo) throws Exception {
        io=newIo;
    }

//---------------------------------------------------------------------------------------------//
    /**
     * Set the patient.
     */
//---------------------------------------------------------------------------------------------//
    public void setPatient(Patient newPatient) throws Exception {
        if (newPatient.getId()!=patientId) {
//            apptId=0;
//            thisApptCal.setSelectedAppointment(0);
        }
        thisPatient=newPatient;
        patientId=thisPatient.getId();
    }

    public void setPlatterColor(String newColor) {
        platterColor = newColor;
    }

    public void setMorningStart(int morningStart) {
        this.morningStart = morningStart;
        int hourOfDay = Calendar.getInstance().get(Calendar.HOUR_OF_DAY);

        if (hourOfDay>=showAfternoonAfter) {
            thisApptCal.setStartHour(afternoonStart);
        } else {
            thisApptCal.setStartHour(morningStart);
        }
    }
    
    public void setAfternoonStart(int afternoonStart) {
        this.afternoonStart = afternoonStart;
        int hourOfDay = Calendar.getInstance().get(Calendar.HOUR_OF_DAY);

        if (hourOfDay>=showAfternoonAfter) {
            thisApptCal.setStartHour(afternoonStart);
        } else {
            thisApptCal.setStartHour(morningStart);
        }
    }
    
    public void setShowAfternoonAfter (int showAfternoonAfter) {
        this.showAfternoonAfter = showAfternoonAfter;
        int hourOfDay = Calendar.getInstance().get(Calendar.HOUR_OF_DAY);

        if (hourOfDay>=showAfternoonAfter) {
            thisApptCal.setStartHour(afternoonStart);
        } else {
            thisApptCal.setStartHour(morningStart);
        }
    }

    public int getIncrementMinutes() {
        return incrementMinutes;
    }

    public void setIncrementMinutes(int incrementMinutes) {
        this.incrementMinutes = incrementMinutes;
        thisApptCal.setIncrementMinutes(this.incrementMinutes);
    }

    public int getResourceId() {
        return resourceId;
    }

    public void setResourceId(int resourceId) {
        this.resourceId = resourceId;
    }
    
    public int getApptId() {
        return this.apptId;
    }

    public int getRowsToGenerate() {
        return rowsToGenerate;
    }

    public void setRowsToGenerate(int rowsToGenerate) {
        this.rowsToGenerate = rowsToGenerate;
    }

    public void setAppointmentId(int appointmentId) {
            apptId = appointmentId;
            //                if (request.getParameter("apptTime")==null &&  (request.getHeader("referer")!=null && request.getHeader("referer").indexOf(self)<0)) {
        try {
            if (io.getConnection() == null || io.getConnection().isClosed()) {
                try {
                    io.opnmySqlConn();
                } catch (Exception ee) {

                }
            }
            try {
                ResultSet apptRs = io.opnRS("select * from appointments where id =" + apptId);
                thisAppointment.setResultSet(apptRs);
                if (thisAppointment.next()) {
                    String appointmentTime = thisAppointment.getString("time");
                    int hour = Integer.parseInt(appointmentTime.substring(0, 2));
                    if (hour > 12) {
// RKW - 10/15/10                        thisApptCal.setStartAM_PM(1);
                    } else {
// RKW - 10/15/10                        thisApptCal.setStartAM_PM(0);
                    }
//                    thisApptCal.setStartHour(hour);
//                    thisApptCal.setStartMinute(00);
                    patientId = thisAppointment.getInt("patientId");
                    thisAppointment.beforeFirst();
                }
                apptRs.close();
                thisApptCal.setSelectedAppointment(apptId);
            } catch (Exception ee) {

            }
        } catch (SQLException e) {
            
        }
    }
}
