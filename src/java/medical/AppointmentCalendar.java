//---------------------------------------------------------------------------------------------//
/*
 * AppointmentCalendar.java
 *
 * Created on November 17, 2005, 8:08 PM
 *
 * To change this template, choose Tools | Options and locate the template under
 * the Source Creation and Management node. Right-click the template and choose
 * Open. You can then make changes to the template in the Source Editor.
 */
//---------------------------------------------------------------------------------------------//

package medical;

import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import tools.*;


//---------------------------------------------------------------------------------------------//
import tools.utils.Format;
/**
 * Generates an appointment calendar based on the variable settings 
 * @author BR Online Solutions
 */
//---------------------------------------------------------------------------------------------//
public class AppointmentCalendar {
    boolean showArrivals=true;
    int showForResource=0;
    Date thisDate;
    ArrayList allAppointments = new ArrayList();
    int rowsToGenerate = 32;
    private int colsToGenerate = 1;
    StringBuffer grid = new StringBuffer();
    StringBuffer row = new StringBuffer();
    RWHtmlTable htmTb;
    String cellWidth = "60";
    Calendar myCalendar;
    int startHour = 0;
    int patientId = 0;
    int startMinute = 0;
    int incrementMinutes = 15;
    int startAM_PM = 0;
    int scrollTimeIncrements = 0;
    int selectedAppointment = 0;
    SimpleDateFormat timeFormat = new SimpleDateFormat("h:mm a");
    SimpleDateFormat linkTimeFormat = new SimpleDateFormat("HH:mm");
    SimpleDateFormat isoFormat = new SimpleDateFormat("yyyy-MM-dd");
    SimpleDateFormat dateFormat = new SimpleDateFormat("EEEEE MMMMMM d, yyyy" );
    SimpleDateFormat timeStampFormat = new SimpleDateFormat("yyyy-MM-dd-HH:mm:ss");

    String timeURL = "";
    String apptURL = "";
    String scrollURL = "";
    ResultSet apptRs;
    ResultSet apptTypesRs;
    String apptTypesArray[][];
    String[][] lastApptArray;
    
    // RKW - 09/22/08 - Added to show times outside of office hours as gray
    int morningStart=800;
    int morningEnd=1200;
    int afternoonStart=1300;
    int afternoonEnd=1800;
    
    // RKW - 09/30/2008 - Added to prevent auto expansion based on appointment count
    private boolean allowAutoExpand = false;
    private boolean allowSchedWhenOut = true;
    // RKW - 10/02/2008 - Added resource name
    String resourceName="";

    public String scrollToTime;
    
//---------------------------------------------------------------------------------------------//
    /** Creates a new instance of AppointmentCalendar */
//---------------------------------------------------------------------------------------------//
    public AppointmentCalendar() {
        htmTb = new RWHtmlTable("", "2");
        htmTb.setCellPadding("1");
        myCalendar = Calendar.getInstance();
        myCalendar.set(myCalendar.SECOND,0);
        startHour=myCalendar.get(myCalendar.HOUR);
        startMinute=myCalendar.get(myCalendar.MINUTE);
        startAM_PM=myCalendar.get(myCalendar.AM_PM);
        thisDate=myCalendar.getTime();
        lastApptArray = new String[0][0];
    }

//---------------------------------------------------------------------------------------------//
    /**
     * Retrieves the HTML representation of the appointment calendar
     */
//---------------------------------------------------------------------------------------------//
    public String getHtmlGrid() throws Exception {
        fillApptArrayList();
        grid.setLength(0);
        int apptCount;
        int savedColsToGenerate=colsToGenerate;
        int apptCalendarWidth=0;
        setStartHour(startHour);
        setStartMinute(startMinute);
        setStartAM_PM(startAM_PM);
        Date startDate=myCalendar.getTime();
        
        // RKW 09/20/08 - show hours of operation as white and non-office hours as gray
        setHoursOfOperation();
        setCalendarAttributesForResource();
        
        // Calculate the most appointments in a given timeslot.  If colsToGenerate is exceeded, bump it.
        for (int i=1;i<=rowsToGenerate;i++) {
            apptCount = getApptCount();
            // RKW prevent autoexpansion if not allowAutoExpansion
            if (apptCount>colsToGenerate && !isAllowAutoExpand()) {
                colsToGenerate=apptCount;
            }
            myCalendar.add(Calendar.MINUTE, incrementMinutes);
        }
        
        // Reset
        myCalendar.setTime(startDate);
        setStartHour(startHour);
        setStartMinute(startMinute);
        setStartAM_PM(startAM_PM);
        startDate=myCalendar.getTime();
        
        // Make room to add a new appointment
        // RKW - 09/30/2008 prevent autoexpansion
        if(isAllowAutoExpand()) {
            colsToGenerate+=2; 
        }

        if (cellWidth.indexOf("%")<0) {
            apptCalendarWidth=colsToGenerate*Integer.parseInt(cellWidth);
            // RKW - 09/30/2008 if the width generated is less than the minimum width then set the minimum width
            if(colsToGenerate*Integer.parseInt(cellWidth)<200) {
                apptCalendarWidth=150;
            }
        }
        htmTb.setWidth(""+apptCalendarWidth);
        grid.append(htmTb.startTable());
        grid.append(htmTb.startRow());
        if(isAllowAutoExpand()) {
            grid.append(htmTb.headingCell(resourceName, "colspan=" + (colsToGenerate-2)));
        } else {            
            grid.append(htmTb.headingCell(resourceName, ""));            
        }
        grid.append(htmTb.endRow());
        
        // RKW - 09/30/2008 Seperate the heading from the body of the calendar
        grid.append(htmTb.endTable());

        grid.append("<div style='height: 400; width: " + (apptCalendarWidth+20) + "; overflow: auto;'>\n");
        grid.append(htmTb.startTable());
        
        for (int i=1;i<=rowsToGenerate;i++) {
            grid.append(getTimeRow(i-1));
            myCalendar.add(Calendar.MINUTE, incrementMinutes);
        }
        grid.append(htmTb.endTable());
        grid.append("</div>\n");

        // Clear out the last appointment array
        lastApptArray = new String[0][0];

        myCalendar.setTime(startDate);
        setStartHour(startHour);
        setStartMinute(startMinute);
        setStartAM_PM(startAM_PM);
        
        colsToGenerate = savedColsToGenerate;

        return grid.toString();
    }

    public String getMainHeader() {
        int scrollDownHour=startHour;
        int scrollUpHour=startHour;
        String scrollUpTime="";
        String scrollDownTime="";
        
        StringBuffer grid=new StringBuffer();
        grid.append(htmTb.startTable("630"));
        grid.append(htmTb.startRow("height=20"));

        if(startHour>3) { scrollUpHour = startHour-3; } else { scrollUpHour=0; }
        if(startHour<19) { scrollDownHour = startHour+3; } else { scrollDownHour = 18; }

        if(scrollUpHour<10) { scrollUpTime = "0"+scrollUpHour+":00"; } else { scrollUpTime = ""+scrollUpHour+":00"; }
        if(scrollDownHour<10) { scrollDownTime = "0"+scrollDownHour+":00"; } else { scrollDownTime = ""+scrollDownHour+":00"; }

// RKW 07/07/11        grid.append(htmTb.headingCell("<a href=" + scrollURL + "?scrollup=" + scrollTimeIncrements +
// RKW 07/07/11                ">&uarr;&uarr;</a>" + "&nbsp;&nbsp;&nbsp;&nbsp;" +
// RKW 07/07/11                "<a href=" + scrollURL + "?scrolldown=" + scrollTimeIncrements + ">&darr;&darr;</a>"));
        grid.append(htmTb.headingCell("<a href=" + scrollURL + "?scrollup=1&time=" + scrollUpTime +
                ">&uarr;&uarr;</a>" + "&nbsp;&nbsp;&nbsp;&nbsp;" +
                "<a href=" + scrollURL + "?scrolldown=1&time=" + scrollDownTime + ">&darr;&darr;</a>"));
        grid.append(htmTb.headingCell(dateFormat.format(thisDate), ""));            
        grid.append(htmTb.headingCell("<a href=" + scrollURL + "?adddays=-1" +
                "><<</a>" + "&nbsp;&nbsp;&nbsp;&nbsp;" + 
                "<a href=" + scrollURL + "?adddays=1>>></a>"));
        grid.append(htmTb.endRow());
        grid.append(htmTb.endTable());
        return grid.toString();
    }
//---------------------------------------------------------------------------------------------//
    /**
     * Private method to return the row for a given time interval
     */
//---------------------------------------------------------------------------------------------//
    private String getTimeRow(int scrollDown) throws Exception {

        String[][] apptArray = getApptArray(lastApptArray);
        String selectedStyle = "";
        String rowColor="";
        try {
            row.setLength(0);
            
            int currentHour=Integer.parseInt(Format.formatDate(myCalendar.getTime(), "kk"));
            int currentMinute=Integer.parseInt(Format.formatDate(myCalendar.getTime(), "mm"));
            int currentTime=(currentHour*100)+currentMinute;
            
            if(currentTime<morningStart) { rowColor="style='background-color: #e0e0e0;'";  }
            if(currentTime>=morningEnd && currentTime<afternoonStart) { rowColor="style='background-color: #e0e0e0;'";  }
            if(currentTime>=afternoonEnd) { rowColor="style='background-color: #e0e0e0;'";  }

            row.append(htmTb.startRow(rowColor));

            String onClick = "";

            for (int i=1;i<=colsToGenerate;i++) {
                String onClickOption="";
                if (i==1) {
                    if(linkTimeFormat.format(myCalendar.getTime()).substring(3).equals("00")) {  //RKW 07/07/11
                        onClickOption=" onClick=\"window.location.href='" + timeURL +"?scrolldown=" + scrollDown +
                                    "&time=" + linkTimeFormat.format(myCalendar.getTime()) + "'\"";
                        row.append(htmTb.addCell("<font size=1>" +  timeFormat.format(myCalendar.getTime()),"style='cursor: pointer; font-weight: bold;' width=" + cellWidth + onClickOption));
                    } else { // RKW 07/07/11
                        onClickOption=""; //RKW 07/07/11
                        row.append(htmTb.addCell("<font size=1>" + timeFormat.format(myCalendar.getTime()),"width=" + cellWidth + onClickOption));  // RKW 07/07/11
                    } // RKW 07/07/11
                } else {
                    onClick = " onClick=showAppointmentEditBubble(this,event,'ajax/appointment.jsp'," + apptArray[i-2][1] + "," + patientId + "); ";

                    if (apptArray[i-2][0] == null) {
                        if(isAllowSchedWhenOut() || !isTimeBlockedOut(currentTime)) {
                            onClickOption=" onClick=\"moveCurrentAppointment('" + isoFormat.format(myCalendar.getTime()) + "'," + showForResource + ",'" + linkTimeFormat.format(myCalendar.getTime()) + "')\"";
                        }
                        row.append(htmTb.addCell("", "style='cursor: pointer' width=" + 
                                cellWidth + onClickOption));
                    } else if (!apptArray[i-2][4].equals("N")) {
                        if (Integer.parseInt(apptArray[i-2][1])==selectedAppointment) {
                            selectedStyle="border: 3px solid #cc99ff; ";
                        } else {
                            selectedStyle="";
                        }
                        row.append(htmTb.addCell("<font size=1>" + apptArray[i-2][0], 
                                " rowspan=" + apptArray[i-2][5] + " width=" +
                                cellWidth + " style='" + selectedStyle +
                                " color: " + apptTypesArray[Integer.parseInt(apptArray[i-2][2])][3] + "; " +
                                " background-color: " + apptTypesArray[Integer.parseInt(apptArray[i-2][2])][2] + "; " +
                                " cursor: pointer;' " +
                                onClick +
                                " onDblClick=\"showVisit(" + apptArray[i-2][1] + ")\" " +
                                "\""));
                    }

                }

            }

            row.append(htmTb.endRow());
        } catch (Exception e) {
            String exp = e.getMessage();
        }      
        
        return row.toString();

    }
//---------------------------------------------------------------------------------------------//
    /**
     * Counts the appoitments for a timeslot
     */
//---------------------------------------------------------------------------------------------//
    private int getApptCount() throws Exception {
        int apptCount=0;
        int j=0;
        String[] appointment;
        for (int i=0;i<allAppointments.size();i++) {
            appointment = (String[])allAppointments.get(i);
            if (myCalendar.getTimeInMillis() >= Long.parseLong(appointment[0]) && 
                myCalendar.getTimeInMillis() <= Long.parseLong(appointment[1]) ) {
                apptCount++;
            }
        }
        return apptCount;
    }
//---------------------------------------------------------------------------------------------//
    /**
     * Returns all of the appointments for a given Date/Time in an array
     */
//---------------------------------------------------------------------------------------------//
    private String[][] getApptArray(String[][] lstApptArray) throws Exception {

        String[][] apptArray = new String[colsToGenerate][6];
        Calendar apptStart = Calendar.getInstance();;
        Calendar apptEnd = Calendar.getInstance();;
        String[] appointment;
        String myDateTime = timeStampFormat.format(myCalendar.getTime());
        String rowSpan;

        try {
            // First, move any appointments that have not expired from the last array into the new one 
            for (int i=0;i<lstApptArray.length;i++) {
                if (lstApptArray[i][3]!=null && myCalendar.getTimeInMillis() < Long.parseLong(lstApptArray[i][3])) {
                    apptArray[i]=lstApptArray[i];
                    apptArray[i][4]="N";
                    apptArray[i][5]="0";
                }
            }            

            apptRs.beforeFirst();

            int j=0;
            for (int i=0;i<allAppointments.size();i++) {
                appointment = (String[])allAppointments.get(i);
                if(appointment[3].equals("1349")) {
                    System.out.print(""+appointment[3]);
                }
                if (myCalendar.getTimeInMillis() >= Long.parseLong(appointment[0]) && 
                    myCalendar.getTimeInMillis() <= Long.parseLong(appointment[1]) ) {
                    // find open slot
                    while (apptArray[j][1]!=null) {
                        j++;
                        if (j>=apptArray.length) { break; }
                    }
                    if (j>=apptArray.length) { break; }
                    // calculate the rowspan
                    long minutes = (Long.parseLong(appointment[1]) - myCalendar.getTimeInMillis())/60000;
                    if (minutes%incrementMinutes==0) {
                        rowSpan = "" + ((minutes/incrementMinutes));
                    } else {
                        rowSpan = "" + ((minutes/incrementMinutes)+1);
                    }
                    apptArray[j][1]=appointment[3]; // Appointment Id
                    apptArray[j][2]=appointment[4]; // Appointment Type
                    apptArray[j][3]=appointment[1]; // Appointment End Time
                    apptArray[j][4]=appointment[5]; // Generate New Cell
                    apptArray[j][5]=rowSpan; // Rows to span
                    apptArray[j][0]="<input type=text value='" + appointment[2] + "' size=9 style='" +
                                    "color: " + apptTypesArray[Integer.parseInt(apptArray[j][2])][3] + 
                                    "; background: " + apptTypesArray[Integer.parseInt(apptArray[j][2])][2] +
                                    "; border: none; font-family: tahoma; font-size: 9px; cursor: pointer; height: 11px; ' READONLY>"; // Patient Name
                    allAppointments.remove(i);
                    i--;
                    j++;
                }
            }
            
        } catch (Exception e) {
            System.out.print(e.getMessage());
        }
        lastApptArray=apptArray;
        return apptArray;

    }

//---------------------------------------------------------------------------------------------//
    /**
     * Sets the value whether to show arrivals on the grid.
     */
//---------------------------------------------------------------------------------------------//
    public void setShowArrivals(boolean newShowArrivals) {

        showArrivals = newShowArrivals;
        
    }
//---------------------------------------------------------------------------------------------//
    /**
     * Sets the value for which resource to show appointments for
     */
//---------------------------------------------------------------------------------------------//
    public void setShowForResource(int showForResource) {

        this.showForResource = showForResource;
        
    }
//---------------------------------------------------------------------------------------------//
    /**
     * Sets the cell width for the appointment cells in the grid.
     */
//---------------------------------------------------------------------------------------------//
    public void setCellWidth(String newCellWidth) {

        cellWidth = newCellWidth;
        
    }
//---------------------------------------------------------------------------------------------//
    /**
     * Sets the appointment types result set
     */
//---------------------------------------------------------------------------------------------//
    public void setApptTypesRs(ResultSet newApptTypesRs) {
        try {
            apptTypesRs = newApptTypesRs;
            if (apptTypesRs.last() ) {
                apptTypesArray = new String[apptTypesRs.getInt(1)+1][4];
            }
            apptTypesRs.beforeFirst();
            while (apptTypesRs.next()) {
                apptTypesArray[apptTypesRs.getInt(1)][0]=apptTypesRs.getString(2);
                apptTypesArray[apptTypesRs.getInt(1)][1]=apptTypesRs.getString(3);
                apptTypesArray[apptTypesRs.getInt(1)][2]=apptTypesRs.getString(4);
                apptTypesArray[apptTypesRs.getInt(1)][3]=apptTypesRs.getString(5);
            }

        } catch (Exception e) {
            String exp = e.getMessage();
        }
    }
    
//---------------------------------------------------------------------------------------------//
    /**
     * Gets the value for showArrivals.
     */
//---------------------------------------------------------------------------------------------//
    public boolean getShowArrivals() {

        return showArrivals;
        
    }
    
//---------------------------------------------------------------------------------------------//
    /**
     * Gets the value for showForResource.
     */
//---------------------------------------------------------------------------------------------//
    public int getShowForResource() {

        return showForResource;
        
    }
    
//---------------------------------------------------------------------------------------------//
    /**
     * Sets the cell width for the appointment cells in the grid.
     */
//---------------------------------------------------------------------------------------------//
    public Calendar getCalendar() {

        return myCalendar;
        
    }
    
//---------------------------------------------------------------------------------------------//
    /**
     * Gets the date in *ISO format.
     */
//---------------------------------------------------------------------------------------------//
    public String getIsoDate() {

        return isoFormat.format(myCalendar.getTime());
        
    }
    
//---------------------------------------------------------------------------------------------//
    /**
     * Sets the number of rows to generate for the appointment cells in the grid.
     */
//---------------------------------------------------------------------------------------------//
    public void setRowsToGenerate(int newRowsToGenerate) {

        rowsToGenerate = newRowsToGenerate;
        
    }

//---------------------------------------------------------------------------------------------//
    /**
     * Sets the number of columns to generate for the appointment cells in the grid.
     */
//---------------------------------------------------------------------------------------------//
    public void setColsToGenerate(int newColsToGenerate) {
        
        colsToGenerate = newColsToGenerate;
        
    }
    
//---------------------------------------------------------------------------------------------//
    /**
     * Sets the starting hour for the grid.
     */
//---------------------------------------------------------------------------------------------//
    public void setStartHour(int newStartHour) {
        
        startHour = newStartHour;
        myCalendar.set(myCalendar.HOUR_OF_DAY,startHour);
        thisDate=myCalendar.getTime();

    }

//---------------------------------------------------------------------------------------------//
    /**
     * Sets the starting minute for the grid.
     */
//---------------------------------------------------------------------------------------------//
    public void setStartMinute(int newStartMinute) {
        
        startMinute = newStartMinute;
        
        myCalendar.set(myCalendar.MINUTE,startMinute);
        thisDate=myCalendar.getTime();
       
    }

//---------------------------------------------------------------------------------------------//
    /**
     * Sets the number of minutes each row is incremented by when displaying the grid
     */
//---------------------------------------------------------------------------------------------//
    public void setIncrementMinutes(int newIncrementMinutes) {

        incrementMinutes = newIncrementMinutes;

    }

//---------------------------------------------------------------------------------------------//
    /**
     * Sets the URL that the scrolling controls link to
     */
//---------------------------------------------------------------------------------------------//
    public void setScrollURL(String newScrollURL) {

        scrollURL = newScrollURL;

    }

//---------------------------------------------------------------------------------------------//
    /**
     * Sets the scroll time increments
     */
//---------------------------------------------------------------------------------------------//
    public void setScrollTimeIncrements(int newScrollTimeIncrements) {

        scrollTimeIncrements = newScrollTimeIncrements;

    }

//---------------------------------------------------------------------------------------------//
    /**
     * Sets the patientId
     */
//---------------------------------------------------------------------------------------------//
    public void setPatientId(int newPatientId) {

        patientId = newPatientId;

    }

//---------------------------------------------------------------------------------------------//
    /**
     * Sets the selected Appointment Id
     */
//---------------------------------------------------------------------------------------------//
    public void setSelectedAppointment(int newSelectedAppointment) {

        selectedAppointment = newSelectedAppointment;

    }

    public int getSelectedAppointment() {
        return this.selectedAppointment;
    }

//---------------------------------------------------------------------------------------------//
    /**
     * Sets the URL that the time cells on the grid link to
     */
//---------------------------------------------------------------------------------------------//
    public void setTimeURL(String newTimeURL) {

        timeURL = newTimeURL;

    }

//---------------------------------------------------------------------------------------------//
    /**
     * Sets the URL that each appointment grid cell links to
     */
//---------------------------------------------------------------------------------------------//
    public void setApptURL(String newApptURL) {

        apptURL = newApptURL;

    }

//---------------------------------------------------------------------------------------------//
    /**
     * Sets the starting AM_PM value for the time
     */
//---------------------------------------------------------------------------------------------//
    public void setStartAM_PM(int newStartAM_PM) {
    
        startAM_PM = newStartAM_PM;
        
        myCalendar.set(myCalendar.AM_PM,startAM_PM);
        thisDate=myCalendar.getTime();
        
    }

//---------------------------------------------------------------------------------------------//
    /**
     * Sets the day for this particular instance of the AppointmentCalendar.
     */
//---------------------------------------------------------------------------------------------//
    public void setDate(Date newDate) {
        
        thisDate = newDate;
        
        myCalendar.setTime(thisDate);
        setStartHour(startHour);
        setStartMinute(startMinute);
        setStartAM_PM(startAM_PM);
        
    }

//---------------------------------------------------------------------------------------------//
    /**
     * Sets the result set containing all of the appointments.
     */
//---------------------------------------------------------------------------------------------//
    public void setApptRs(ResultSet newRs) {
        
        apptRs = newRs;
    
    }

//---------------------------------------------------------------------------------------------//
    /**
     * invokes the add method to the calendar object
     */
//---------------------------------------------------------------------------------------------//
    public void add(int field, int amount) {
        
        myCalendar.add(field, amount);
        setStartHour(myCalendar.get(myCalendar.HOUR_OF_DAY));
        setStartMinute(myCalendar.get(myCalendar.MINUTE));
        setStartAM_PM(myCalendar.get(myCalendar.AM_PM));
        thisDate=myCalendar.getTime();
    
    }

//---------------------------------------------------------------------------------------------//
    /**
     * Fills the array list with the appointments from the resultset
     */
//---------------------------------------------------------------------------------------------//
    private void fillApptArrayList() throws Exception {
        
        apptRs.beforeFirst();
        allAppointments.clear();

        Calendar apptCal = Calendar.getInstance();;

        while (apptRs.next()) {
            if ((apptRs.getInt(7)==0) || showArrivals) {

                // Build an appointment 
                String[] appointment = new String[7];

                // Capture the start time 
                String apptTime = apptRs.getString(2);

                // Set the calendar according to the appointment's start date/time 
                apptCal.setTime(apptRs.getDate(1));
                apptCal.set(apptCal.HOUR_OF_DAY,Integer.parseInt(apptTime.substring(0,2)));
                apptCal.set(apptCal.MINUTE,Integer.parseInt(apptTime.substring(3,5)));
                apptCal.set(apptCal.SECOND,Integer.parseInt(apptTime.substring(6,8)));
                String sd = timeStampFormat.format(apptCal.getTime());
                String sMs = "" + apptCal.getTimeInMillis();

                // Increment to get the end time 
                apptCal.add(apptCal.MINUTE, incrementMinutes*apptRs.getInt("intervals"));
                String ed = timeStampFormat.format(apptCal.getTime());
                String eMs = "" + apptCal.getTimeInMillis();
                String prefix="";
                if (apptRs.getInt(7)!=0) {
                    prefix = "* ";
                }

                // Store the appointment in the array list 
                appointment[0]=sMs;                          // Start Date/Time
                appointment[1]=eMs;                          // End Date/Time
                appointment[2]=prefix + apptRs.getString(3); // Patient Name
                appointment[3]=apptRs.getString(4);          // Appointment Id
                appointment[4]=apptRs.getString(5);          // Appointment Type
                appointment[5]="Y";                          // Generate New Cell
                appointment[6]=apptRs.getString(6);          // Row Span (Intervals)

                allAppointments.add(appointment);
            }
        }
    }
    
    // RKW 09/20/2008 - Get the global settings for the calendar 
    private void setHoursOfOperation() {
        String currentDay=Format.formatDate(myCalendar.getTime(), "EEE");
        String currentDate=Format.formatDate(myCalendar.getTime(), "yyyy-MM-dd");
        try {
            String localQuery = "SELECT day, " +
                "case when c.morningstart is not null then c.morningstart else IfNull(b.morningstart,a.morningstart) end as morningstart, " +
                "case when c.morningend is not null then c.morningend else IfNull(b.morningend,a.morningend) end as morningend, " +
                "case when c.afternoonstart is not null then c.afternoonstart else IfNull(b.afternoonstart,a.afternoonstart) end as afternoonstart, " +
                "case when c.afternoonend is not null then c.afternoonend else IfNull(b.afternoonend,a.afternoonend) end as afternoonend, " +
                "a.apptdepth, a.incrementminutes, case when r.allowsched is null then 0 else r.allowsched end as allowsched, " + 
                "case when r.allowexpand is null then 0 else r.allowexpand end as allowexpand " +
                "from dayhours a " +
                "left join officehours b on b.date='" + currentDate + "' and b.resourceid=0 " +
                "left join officehours c on a.resourceid=c.resourceid and c.date='" + currentDate + "' " +
                "where a.resourceid=0 and a.day='" + currentDay.toUpperCase() + "'";
            
            ResultSet lRs=apptRs.getStatement().getConnection().prepareStatement(localQuery).executeQuery();
            if(lRs.next()) {
                morningStart=lRs.getInt("morningStart");
                morningEnd=lRs.getInt("morningend");
                afternoonStart=lRs.getInt("afternoonstart");
                afternoonEnd=lRs.getInt("afternoonEnd");
                this.colsToGenerate=lRs.getInt("apptDepth");
                this.incrementMinutes=lRs.getInt("incrementMinutes");
                this.allowSchedWhenOut=lRs.getBoolean("allowsched");
                this.allowAutoExpand=lRs.getBoolean("allowexpand");
            }
            lRs.close();
        } catch (Exception e) {
            
        }
    }

    public int getColsToGenerate() {
        return colsToGenerate;
    }

    public

    // RKW - 09/30/2008 - Added to prevent auto expansion based on appointment count
    boolean isAllowAutoExpand() {
        return allowAutoExpand;
    }

    public void setAllowAutoExpand(boolean allowAutoExpand) {
        this.allowAutoExpand = allowAutoExpand;
    }

    // RKW 10/01/2008 - Get the calendar attributes for the specific resource if they exist
    private void setCalendarAttributesForResource() throws Exception {
        String currentDay=Format.formatDate(myCalendar.getTime(), "EEE");
        String currentDate=Format.formatDate(myCalendar.getTime(), "yyyy-MM-dd");
        
        String myQuery="SELECT resources.id as resourceId, resources.name, dayhours.* " +
                "FROM resources " +
                "left join dayhours on resources.id=dayHours.resourceid " +
                "where day='" + currentDay.toUpperCase() + "' and resources.id=" + this.showForResource + " order by resources.id";

        String localQuery = "SELECT r.id as resourceId, IfNull(r.name,'General Office') as name, day, " +
            "case when c.morningstart is not null then c.morningstart else IfNull(b.morningstart,a.morningstart) end as morningstart, " +
            "case when c.morningend is not null then c.morningend else IfNull(b.morningend,a.morningend) end as morningend, " +
            "case when c.afternoonstart is not null then c.afternoonstart else IfNull(b.afternoonstart,a.afternoonstart) end as afternoonstart, " +
            "case when c.afternoonend is not null then c.afternoonend else IfNull(b.afternoonend,a.afternoonend) end as afternoonend, " +
            "a.apptdepth, a.incrementminutes, case when r.allowsched is null then 0 else r.allowsched end as allowsched, " + 
            "case when r.allowexpand is null then 0 else r.allowexpand end as allowexpand " +
            "from dayhours a " +
            "left join officehours b on b.date='" + currentDate + "' and b.resourceid=0 " +
            "left join officehours c on a.resourceid=c.resourceid and c.date='" + currentDate + "' " +
            "left join resources r on r.id=a.resourceid " +
            "where a.resourceid=" + this.showForResource + " and a.day='" + currentDay.toUpperCase() + "'";
            
        
        this.resourceName="General Office";
        ResultSet lRs=this.apptRs.getStatement().getConnection().prepareStatement(localQuery).executeQuery();
        if(lRs.next()) {
            this.resourceName=lRs.getString("name");
            this.colsToGenerate=lRs.getInt("apptDepth")+1;
            this.incrementMinutes=lRs.getInt("incrementMinutes");
            this.morningStart=lRs.getInt("morningStart");
            this.morningEnd=lRs.getInt("morningEnd");
            this.afternoonStart=lRs.getInt("afternoonStart");
            this.afternoonEnd=lRs.getInt("afternoonEnd");
            this.allowSchedWhenOut=lRs.getBoolean("allowsched");
            this.allowAutoExpand=lRs.getBoolean("allowexpand");
        }
        lRs.close();
    }

    public boolean isAllowSchedWhenOut() {
        return allowSchedWhenOut;
    }

    public void setAllowSchedWhenOut(boolean allowSchedWhenOut) {
        this.allowSchedWhenOut = allowSchedWhenOut;
    }
    
    private boolean isTimeBlockedOut(int currentTime) {
        boolean timeIsBlockedOut=false;
        if(currentTime<morningStart) { timeIsBlockedOut=true;  }
        if(currentTime>=morningEnd && currentTime<afternoonStart) { timeIsBlockedOut=true;  }
        if(currentTime>=afternoonEnd) { timeIsBlockedOut=true;  }
        return timeIsBlockedOut;
    }
}
