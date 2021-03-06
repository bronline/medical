/*
 * Messages.java
 *
 * Created on January 3, 2006, 7:01 AM
 *
 * To change this template, choose Tools | Options and locate the template under
 * the Source Creation and Management node. Right-click the template and choose
 * Open. You can then make changes to the template in the Source Editor.
 */

package medical;
import tools.*;
import tools.utils.*;
import java.sql.*;
import java.util.Calendar;

/**
 *
 * @author BR Online Solutions
 */
public class Messages extends MedicalResultSet {
    private int id;
    private int patientId;
    private String date;
    private String message;
    private double amount;
    private int onVisit;
    private int startVisit;
    private int atVisit;
    private boolean display;
    private Timestamp displayed;
    private Timestamp complete;
    private int numVisits;
    private String frequency;
    private int numTimes;
    private boolean checkCount      = false;
    private StringBuffer msg        = new StringBuffer();
    private StringBuffer msgDetl    = new StringBuffer();
    private StringBuffer visitMsg   = new StringBuffer();
    private RWHtmlTable htmTb       = new RWHtmlTable("400", "0");
    private RWHtmlForm frm;
    private java.util.Date today    = new java.util.Date();
    private Messages patientMsg;
    private Messages updateMsg;
    private Patient patient;
    private ResultSet tmpRs;
    private Timestamp timeStamp     = new java.sql.Timestamp(today.getTime());
    private java.util.Date date1;
    private Calendar thisCalendar   = Calendar.getInstance();

    private int divHeight           = 25;

    /** Creates a new instance of Messages */
    public Messages() {
    }
    
    public Messages(RWConnMgr newIo) throws Exception {
        setConnMgr(newIo);
    }
    
    public void setPatientId(int newId) throws Exception {
        patientId = newId;
    }
    
    public void setPatientId(String newId) throws Exception {
        setPatientId(Integer.parseInt(newId));
    }

    public void setId(int newInt) throws Exception {
        id = newInt;
        setResultSet(io.opnUpdatableRS("select * from patientmessages where id=" + id));
        if(id !=0) {
            if(next()) {
                setPatientId(getInt("patientid"));
                setDate(getString("date"));
                setMessage(getString("message"));
                setAmount(getDouble("amount"));
                setOnVisit(getInt("onvisit"));
                setStartVisit(getInt("startvisit"));
                setAtVisit(getInt("atvisit"));
                setDisplayed(getTimestamp("displayed"));
                setComplete(getTimestamp("complete"));
                setDisplay(getBoolean("display"));
            }
        }
    }
    
    public void setMessage(String newMessage) {
        message = newMessage;
    }
    
    public void setDate(String newDate) {
        if(newDate == null) { newDate = "0001-01-01"; }
        try { date = Format.formatDate(newDate, "yyyy-MM-dd"); }
        catch (Exception dateException) { date = "0001-01-01"; }
    }
    
    public void setAmount(double newAmount) {
        amount = newAmount;
    }
    
    public void setAmount(String newAmount) {
        double amt = 0;
        if(newAmount == null || newAmount.equals("")) {
            setAmount(amt);
        } else {
            setAmount(Double.parseDouble(newAmount));
        }
    }
    
    public void setOnVisit(int newInt) {
        onVisit = newInt;
    }
    
    public void setOnVisit(String newString) {
        if(newString == null || newString.equals("")) {
            setOnVisit(0);
        } else {
            setOnVisit(Integer.parseInt(newString));
        }
    }
    
    public void setStartVisit(int newInt) {
        startVisit = newInt;
    }
    
    public void setStartVisit(String newString) {
        if(newString == null || newString.equals("")) {
            setStartVisit(0);
        } else {
            setStartVisit(Integer.parseInt(newString));
        }
    }
    
    public void setAtVisit(int newInt){
        atVisit = newInt;
    }
    
    public void setAtVisit(String newString) {
        if(newString == null || newString.equals("")) {
            setAtVisit(0);
        } else {
            setAtVisit(Integer.parseInt(newString));
        }
    }
    
    public void setFrequency(String newFrequency) {
        if(newFrequency == null || newFrequency.equals("")) { newFrequency = "Single"; }
        frequency = newFrequency;
    }
    
    public void setNumberOfTimes(String newString) {
        if(newString == null) { newString = "0"; }
        numTimes = Integer.parseInt(newString);
    }
    
    public void setDisplay(boolean newBol) {
        display = newBol;
    }
    
    public void setDisplayed(Timestamp newDate) {
        displayed = newDate;
    }
    
    public void setComplete(Timestamp newDate) {
        complete = newDate;
    }
    
    public void setTimestamp() throws Exception {
        timeStamp = new java.sql.Timestamp(today.getTime());
    }

    public void refresh() throws Exception {
        String myQuery = "select m.*, concat(p.firstname, ' ', p.lastname) as name from patientmessages m " +
                         "join patients p on p.id=m.patientid where date<='" + Format.formatDate(today, "yyyy-MM-dd") + "' and ";
        String where   = "";

        if(patientId != 0) {
            myQuery += "patientId=" + patientId;
        } else {
            where +=  "displayed<>'0001-01-01 00:00:00.0' and complete='0001-01-01 00:00:00.0'";
        }

        myQuery += where + " order by patientid, date";
        setResultSet(io.opnRS(myQuery));
    }
    
    public void update() throws Exception {
        if(id != 0) {
            beforeFirst();
            next();
        } else {
            moveToInsertRow();
        }
        
        updateInt("patientId", patientId);
        updateString("date", date);
        updateString("message", message);
        updateDouble("amount", amount);
        updateInt("onvisit", onVisit);
        updateInt("startvisit", startVisit);
        updateInt("atvisit", atVisit);
        updateBoolean("display", display);
        updateTimestamp("displayed", displayed);
        updateTimestamp("complete", complete);
        
        if(id != 0) { updateRow(); } 
        if(id == 0) { insertRow(); }
    }
    
    public void updateDisplayed(int newId) throws Exception {
        refresh();
        if(updateMsg == null) { updateMsg = new Messages(io); }
        int visitCount=0;
        boolean displayMsg=false;
        
        ResultSet patRs=io.opnRS("select planid from patients where id=" + patientId);
        if(patRs.next()) {
            PatientPlan patientPlan=new PatientPlan(io, patRs.getInt("planid"));
            if(patientPlan.getPlanId() !=0 ) {
                String [] planDetails=patientPlan.getPlanInfo();
                ResultSet tmpRs=io.opnRS("select count(id) as visitcount from visits where patientid=" + patientId + " and date between '" + planDetails[2] + "' and '" + planDetails[3] + "'");
                if(tmpRs.next()) { visitCount=tmpRs.getInt("visitcount"); }
                tmpRs.close();
                tmpRs=null;
            }
            patientPlan=null;
        }
        
        int visitMultiple=0;
        float visits=0;

        while(next()) {
            displayMsg=false;
            if(getString("displayed").equals("0001-01-01 00:00:00.0")) {
                // onvisit = display at a certain visit
                // startvisit = start displaying no a certain visit
                // atvisit = display every x visits
                if(visitCount != 0) {
                    visitMultiple = (getInt("atvisit")/visitCount);
                    visits = Float.parseFloat(getString("atvisit"));
                    visits = visits/visitCount;
                }
                
                if(getInt("onvisit") != 0 && getInt("onvisit") == visitCount) { displayMsg = true; }
                if(getInt("startvisit") != 0 && getInt("startvisit") <= visitCount) { displayMsg = true; }
                if(getInt("atvisit") != 0 && visitMultiple == visits) { displayMsg = true; }

                if(displayMsg || !getString("date").equals("0001-01-01")) {
                    updateMsg.setId(getInt("id"));
                    updateMsg.setTimestamp();
                    updateMsg.setDisplayed(new java.sql.Timestamp(today.getTime()));
                    updateMsg.update();
                }

            }
        }
        
    }
    
    public void updateSnooze(int newId) throws Exception {
        if(updateMsg == null) { updateMsg = new Messages(io); }
        updateMsg.setId(newId);
        
        timeStamp = timeStamp.valueOf("0001-01-01 00:00:00");
        updateMsg.setDisplayed(timeStamp);
        updateMsg.update();
        
    }
    
    public void updateComplete(int newId) throws Exception {
        if(updateMsg == null) { updateMsg = new Messages(io); }
        updateMsg.setId(newId);
        
        updateMsg.setTimestamp();
        updateMsg.setComplete(new java.sql.Timestamp(today.getTime()));
        updateMsg.update();
        
    }
    
    public int getId() {
        return id;
    }
    
    public String getMessageText() {
        return message;
    }
    
    public String getDate() {
        return date;
    }
    
    public double getAmount() {
        return amount;
    }
    
    public String getMessage() throws Exception {
        msg.delete(0, msg.length());
        if(patient == null) { patient = new Patient(io, 0); }
        if(frm == null) { frm = new RWHtmlForm(); }
        
        patient.setId(patientId);
        
        htmTb.replaceNewLineChar(false);
        htmTb.setWidth("175");
        htmTb.setBorder("0");
        
        msg.append(htmTb.startTable("100%", "0"));
        msg.append(htmTb.startRow());
        msg.append(htmTb.addCell("<b>Date</b>"));
        msg.append(htmTb.addCell(Format.formatDate(date, "MM/dd/yyyy")));
        msg.append(htmTb.endRow());
        msg.append(htmTb.startRow());
        msg.append(htmTb.addCell("<b>Name</b>"));
        msg.append(htmTb.addCell(patient.getPatientName()));
        msg.append(htmTb.endRow());
        msg.append(htmTb.startRow());
        msg.append(htmTb.addCell("<b>Message</b>"));
        msg.append(htmTb.addCell(message));
        msg.append(htmTb.endRow());
        msg.append(htmTb.startRow());
        msg.append(htmTb.addCell("<b>Amount</b>"));
        msg.append(htmTb.addCell(Format.formatNumber(amount, "######0.00; (######0.00)")));
        msg.append(htmTb.endRow());
        
        msg.append(htmTb.endTable());
        msg.append("<br>");
        msg.append(frm.button("snooze", "class=button onClick=submitForm('S')", "btnSnooze"));
        msg.append(" ");
        msg.append(frm.button("    ok    ", "class=button onClick=submitForm('O')", "btnOk"));
        
        return msg.toString();
    }
    
    public String getMessages(int newPatient) throws Exception {
        setPatientId(newPatient);
        refresh();
        
        String rowColor     = "#ffffff";
        msg.delete(0, msg.length());
        msgDetl.delete(0, msgDetl.length());
        htmTb.replaceNewLineChar(false);
        
        msg.append(htmTb.startTable("800", "0"));
        //msg.append(htmTb.roundedTopCell(5, "", "#030089", ""));
        msg.append(htmTb.startRow());
        msg.append(htmTb.headingCell("Name", "width='15%'"));
        msg.append(htmTb.headingCell("Date", "width='10%'"));
        msg.append(htmTb.headingCell("Message", ""));
        msg.append(htmTb.headingCell("On Visit", "width='10%'"));
        msg.append(htmTb.headingCell("Start Visit", "width='10%'"));
        msg.append(htmTb.headingCell("Evry X Visits", "width='10%'"));
        msg.append(htmTb.headingCell("Amount", "width='10%'"));
        msg.append(htmTb.headingCell("Displayed", "width='10%'"));
        msg.append(htmTb.endRow());
        msg.append(htmTb.endTable());

        msgDetl.append(htmTb.startTable("800", "0"));
        
        while(next()) {
            msgDetl.append(htmTb.startRow("bgcolor=" + rowColor));
            msgDetl.append(htmTb.addCell(getString("name"), htmTb.LEFT, "width='15%' " + rowUrl()));
            msgDetl.append(htmTb.addCell(Format.formatDate(getString("date"), "MM/dd/yyyy"), htmTb.CENTER, "width='10%'"));
            msgDetl.append(htmTb.addCell(getString("message"), htmTb.LEFT, ""));
            msgDetl.append(htmTb.addCell(getString("onvisit"), htmTb.RIGHT, "width='10%'"));
            msgDetl.append(htmTb.addCell(getString("startvisit"), htmTb.RIGHT, "width='10%'"));
            msgDetl.append(htmTb.addCell(getString("atvisit"), htmTb.RIGHT, "width='10%'"));
            msgDetl.append(htmTb.addCell(Format.formatNumber(getDouble("amount"), "######0.00; (######0.00)"), htmTb.RIGHT, "width='10%'"));
            msgDetl.append(htmTb.addCell(Format.formatDate(getString("displayed"), "MM/dd/yyyy"), htmTb.CENTER, "width='10%'"));
            msgDetl.append(htmTb.endRow());
            if(rowColor.equals("#ffffff")) {
                rowColor = "#e0e0e0";
            } else {
                rowColor = "#ffffff";
            }
        }

//        msgDetl.append(checkForPatientMessages(getInt("patientId"), getString("date")));

        msgDetl.append(htmTb.endTable());
        
        msg.append(htmTb.getTableDiv(divHeight, 819 , "valign=top", msgDetl.toString()));
        
        return msg.toString();
    }

    public String checkForNewMessages() throws Exception {
        String currentTimeStamp = Format.formatDate(new java.util.Date(), "yyyy-MM-dd HH:mm:ss");
        PreparedStatement lPs=io.getConnection().prepareStatement("update patientmessages set displayed=? where displayed<>'0001-01-01 00:00:00.0' and complete='0001-01-01 00:00:00.0'");
        lPs.setString(1, currentTimeStamp);
        lPs.execute();

        return currentTimeStamp;
    }

    public String getMessagesForPopup(String currentTimeStamp) throws Exception {
        String myQuery = "select m.*, concat(p.firstname, ' ', p.lastname) as name from patientmessages m " +
                "join patients p on p.id=m.patientid where date<=current_date and " +
                "displayed>'" + currentTimeStamp + "' and complete='0001-01-01 00:00:00.0' " +
                "order by patientid, date";

        setResultSet(io.opnRS(myQuery));

        String rowColor     = "#ffffff";
        msg.delete(0, msg.length());
        msgDetl.delete(0, msgDetl.length());
        htmTb.replaceNewLineChar(false);

        msg.append(htmTb.startTable("800", "0"));
        //msg.append(htmTb.roundedTopCell(5, "", "#030089", ""));
        msg.append(htmTb.startRow());
        msg.append(htmTb.headingCell("Name", "width='15%'"));
        msg.append(htmTb.headingCell("Date", "width='10%'"));
        msg.append(htmTb.headingCell("Message", ""));
        msg.append(htmTb.headingCell("On Visit", "width='10%'"));
        msg.append(htmTb.headingCell("Start Visit", "width='10%'"));
        msg.append(htmTb.headingCell("Evry X Visits", "width='10%'"));
        msg.append(htmTb.headingCell("Amount", "width='10%'"));
        msg.append(htmTb.headingCell("Displayed", "width='10%'"));
        msg.append(htmTb.endRow());
        msg.append(htmTb.endTable());

        msgDetl.append(htmTb.startTable("800", "0"));

        while(next()) {
            msgDetl.append(htmTb.startRow("bgcolor=" + rowColor));
            msgDetl.append(htmTb.addCell(getString("name"), htmTb.LEFT, "width='15%' " + monitorRowUrl()));
            msgDetl.append(htmTb.addCell(Format.formatDate(getString("date"), "MM/dd/yyyy"), htmTb.CENTER, "width='10%'"));
            msgDetl.append(htmTb.addCell(getString("message"), htmTb.LEFT, ""));
            msgDetl.append(htmTb.addCell(getString("onvisit"), htmTb.RIGHT, "width='10%'"));
            msgDetl.append(htmTb.addCell(getString("startvisit"), htmTb.RIGHT, "width='10%'"));
            msgDetl.append(htmTb.addCell(getString("atvisit"), htmTb.RIGHT, "width='10%'"));
            msgDetl.append(htmTb.addCell(Format.formatNumber(getDouble("amount"), "######0.00; (######0.00)"), htmTb.RIGHT, "width='10%'"));
            msgDetl.append(htmTb.addCell(Format.formatDate(getString("displayed"), "MM/dd/yyyy"), htmTb.CENTER, "width='10%'"));
            msgDetl.append(htmTb.endRow());
            if(rowColor.equals("#ffffff")) {
                rowColor = "#e0e0e0";
            } else {
                rowColor = "#ffffff";
            }
        }

        msgDetl.append(htmTb.endTable());

        msg.append(htmTb.getTableDiv(divHeight, 819 , "valign=top", msgDetl.toString()));

        return msg.toString();
    }

     private String monitorRowUrl() throws Exception {
        return "onClick=window.open(\"instantmessages_d.jsp?returnLocation=instantmessages_monitor.jsp&id=" + getInt("id") + "\",\"Instant\",\"height=65,width=188,scrollbars=no,left=100,top=500,\"); style=\"cursor:pointer; font-weight: bold;\"";
    }

   private String rowUrl() throws Exception {
        return "onClick=window.open(\"instantmessages_d.jsp?id=" + getInt("id") + "\",\"Instant\",\"height=65,width=188,scrollbars=no,left=100,top=500,\"); style=\"cursor:pointer; font-weight: bold;\"";
    }
    
    private String checkForPatientMessages(int patientId, String date) throws Exception {
        visitMsg.delete(0, visitMsg.length());
        numVisits       = 0;
        if(patientMsg == null) {
            patientMsg = new Messages(io);
        }
        
        patientMsg.setPatientId(patientId);
        patientMsg.refresh();
        
        checkCount = true;
        while(patientMsg.next()) {
            if(!patientMsg.getString("date").equals("0001-01-01")) {
                tmpRs = io.opnRS("select count(id) from visits where patientid=" + patientId + " and date>='" + patientMsg.getString("date") + "'");
                if(tmpRs.next()) {
                    numVisits = tmpRs.getInt(1);
                    checkCount = false;
                    break;
                }
            }
        }
        
        patientMsg.beforeFirst();
        int visitMultiple = 0;
        float visits = 0;
        while(patientMsg.next() && patientMsg.getString("displayed").equals("0001-01-01 00:00:00.0")) {
            boolean displayMsg = false;
            if(numVisits != 0) {
                visitMultiple = (patientMsg.getInt("atvisit")/numVisits);
                visits = Float.parseFloat(patientMsg.getString("atvisit"));
                visits = visits/numVisits;
            }
            if(patientMsg.getInt("onvisit") != 0 && patientMsg.getInt("onvisit") == numVisits) { displayMsg = true; }
            if(patientMsg.getInt("startvisit") != 0 && patientMsg.getInt("startvisit") <= numVisits) { displayMsg = true; }
            if(patientMsg.getInt("atvisit") != 0 && visitMultiple == visits) { displayMsg = true; }
            if(displayMsg) {
                visitMsg.append(htmTb.startRow());
                visitMsg.append(htmTb.addCell(patientMsg.getString("name"), "style='color: white;'"));
                visitMsg.append(htmTb.addCell(""));
                visitMsg.append(htmTb.addCell(patientMsg.getString("message"), "style='color: white;'"));
                visitMsg.append(htmTb.addCell(""));
                visitMsg.append(htmTb.addCell(""));
                visitMsg.append(htmTb.endRow());
            }
        }
        
        tmpRs.close();
        
        return visitMsg.toString();
    }
    
    public void generateMessages() throws Exception {
        thisCalendar.setTime(java.sql.Date.valueOf(Format.formatDate(date,"yyyy-MM-dd")));
        timeStamp = timeStamp.valueOf("0001-01-01 00:00:00");
        setDisplay(true);
        setDisplayed(timeStamp);
        setComplete(timeStamp);
        for(int x=0; x<numTimes; x++) {
            setId(0);
            update();
            if(frequency.equals("Weeks")) { thisCalendar.add(thisCalendar.DATE, 7); }
            if(frequency.equals("Months")){ thisCalendar.add(thisCalendar.MONTH, 1); }
            setDate(Format.formatDate(thisCalendar.getTime(), "yyyy-MM-dd"));
        }
    }

    /**
     * @return the divHeight
     */
    public int getDivHeight() {
        return divHeight;
    }

    /**
     * @param divHeight the divHeight to set
     */
    public void setDivHeight(int divHeight) {
        this.divHeight = divHeight;
    }
}
