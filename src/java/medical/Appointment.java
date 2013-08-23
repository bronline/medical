/*
 * Appointment.java
 *
 * Created on November 19, 2005, 8:29 AM
 *
 * To change this template, choose Tools | Options and locate the template under
 * the Source Creation and Management node. Right-click the template and choose
 * Open. You can then make changes to the template in the Source Editor.
 */

package medical;
import tools.*;
import java.sql.*;

/**
 *
 * @author BR Online Solutions
 */
public class Appointment extends RWResultSet {

    private String id;
    private int patientId = 0;
    private int type = 0;
    private Date date;
    private Time time;
    private int intervals = 1;
    private String missedReason = "";
    private String notes = "";
    private int resourceId=0;
    private boolean emailNotification = true;
    
    /** Creates a new instance of Appointment */
    public Appointment() {
    }
    
    public Appointment(RWConnMgr io, String ID) throws Exception {
        setConnMgr(io);
        setId(ID);
    }
    
    public Appointment(RWConnMgr io, int ID) throws Exception {
        setConnMgr(io);
        setId(ID);
    }   

    public void setId(int newId) throws Exception {
        setId("" + newId);
    }
    
    public void setId(String newId) throws Exception {
        id = newId;
        try {
            ResultSet tmpRs = io.opnRS("select * from appointments where id=" + id);
            setResultSet(tmpRs);
            refresh();
        } catch (Exception e) {
            id="0";
        }
        
    }

    public int getId() {
        if(id != null) {
            return Integer.parseInt(id);
        } else {
            return 0;
        }
    }
    
    public String getMiniInputForm() throws Exception {
        RWHtmlTable htmTb = new RWHtmlTable("300", "0");
        RWInputForm frm = new RWInputForm(this);
        
        frm.setShowDatePicker(true);
        StringBuffer iForm = new StringBuffer();
        htmTb.replaceNewLineChar(false);
        frm.setDftTextBoxSize("25");
        frm.formItemOnOneRow = false;
        frm.setLabelBold(true);
        frm.setLabelPosition(frm.LABEL_ON_LEFT);
        htmTb.setWidth("200");
        frm.setUseExternalForm(true);
        frm.setDftTextAreaCols("30");
        iForm.append(frm.startForm());
        iForm.append(htmTb.startTable());

        iForm.append(htmTb.startRow());
        iForm.append(frm.getInputItem("date", "onChange=\"frmInput.btn1.click()\""));
        iForm.append(htmTb.endRow());
        iForm.append(htmTb.startRow());
        iForm.append(frm.getInputItem("time", "onChange=\"frmInput.btn1.click()\""));
        iForm.append(htmTb.endRow());
        iForm.append(htmTb.startRow());
        iForm.append(frm.getInputItem("type","onChange=\"frmInput.btn1.click()\""));
        iForm.append(htmTb.endRow());
        if(isInstanceEmailNotification()) {
            iForm.append(htmTb.startRow());
            iForm.append(frm.getInputItem("emailnotification","onChange=\"frmInput.btn1.click()\""));
            iForm.append(htmTb.endRow());
        }
        iForm.append(htmTb.startRow());
        iForm.append(frm.getInputItem("intervals","onChange=\"frmInput.btn1.click()\""));
        iForm.append(htmTb.endRow());
        iForm.append(htmTb.startRow());
        iForm.append(frm.getInputItem("notes",""));
        iForm.append(htmTb.endRow());
        iForm.append(htmTb.startRow());
        iForm.append(frm.getInputItem("missedreason",""));
        iForm.append(htmTb.endRow());
        iForm.append(htmTb.startRow());
        iForm.append(htmTb.addCell("&nbsp;"));
        iForm.append(htmTb.endRow());

        iForm.append(htmTb.startRow());
        iForm.append(htmTb.addCell(frm.submitButton("save", "class=button") + 
         "&nbsp;" + frm.submitButton("remove", "class=button") + 
         "&nbsp;" + frm.button("multi", "class=button onClick=window.open(\"multiappts.jsp\",\"Appointments\",\"width=310,height=400,left=150,top=200,toolbar=0,status=0,\");"), "colspan=2"));
        iForm.append(htmTb.endRow());

        iForm.append(htmTb.endTable());
        iForm.append(frm.endForm());

        htmTb.setWidth("375");

        return iForm.toString();
    }    

    public void setPatientId(int newPatientId) throws Exception {
        patientId = newPatientId;
    }
    
    public void setType(int newType) throws Exception {
        type = newType;
    }

    public void setDate(Date newDate) throws Exception {
        date = newDate;
    }

    public void setTime(Time newTime) throws Exception {
        time = newTime;
    }

    public void setIntervals(int newIntervals) throws Exception {
        intervals = newIntervals;
    }
    
    public void setMissedReason(String newMissedReason) throws Exception {
        missedReason = newMissedReason;
    }
    
    public void setResultSet(ResultSet newRs) throws Exception {
        super.setResultSet(newRs);
    }
    
    public void update() throws Exception {
        setResultSet(io.opnUpdatableRS("select * from appointments where id=" + id));
        if (type==0) {type=1;}
        if (rs.next()) {
            rs.updateInt("patientid", patientId);
            rs.updateInt("type", type);
            rs.updateDate("date", date);
            rs.updateTime("time", time);
            rs.updateInt("intervals", intervals);
            rs.updateString("missedreason", missedReason);
            rs.updateInt("resourceid", resourceId);
            rs.updateString("notes", notes);
            rs.updateBoolean("emailNotification", emailNotification);
            rs.updateRow();
        } else {
            rs.moveToInsertRow();
            rs.updateInt("patientid", patientId);
            rs.updateInt("type", type);
            rs.updateDate("date", date);
            rs.updateTime("time", time);
            rs.updateInt("intervals", intervals);
            rs.updateString("missedreason", missedReason);
            rs.updateInt("resourceid", resourceId);
            rs.updateString("notes", notes);
            rs.updateBoolean("emailNotification", emailNotification);
            rs.insertRow();
        }
    }
    
    public void delete() throws Exception {
        rs.beforeFirst();
        if (rs.next()) {
            rs.deleteRow();
        }
    }

    public void refresh() throws Exception {
        rs.beforeFirst();
        if (rs.next()) {
            patientId = rs.getInt("patientid");
            id = rs.getString("id");
            type = rs.getInt("type");
            date = rs.getDate("date");
            time = rs.getTime("time");
            intervals = rs.getInt("intervals");
            missedReason = rs.getString("missedreason");
            resourceId = rs.getInt("resourceid");
            notes = rs.getString("notes");
            emailNotification = rs.getBoolean("emailnotification");
            rs.beforeFirst();
        } else {
            id="0";
        }
    }

    public int getIntervalsForType(int appointmentType) {
        try {
            ResultSet atRs = io.opnRS("select * from appointmenttypes where id=" + appointmentType);
            if(atRs.next()) { intervals=atRs.getInt("defaultincrements"); }
            atRs.close();
            atRs = null;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return intervals;
    }

    public int getResourceId() {
        return resourceId;
    }

    public void setResourceId(int resourceId) {
        this.resourceId = resourceId;
    }

    /**
     * @return the notes
     */
    public String getNotes() {
        return notes;
    }

    /**
     * @param notes the notes to set
     */
    public void setNotes(String notes) {
        this.notes = notes;
    }

    /**
     * @return the emailNotification
     */
    public boolean isEmailNotification() {
        return emailNotification;
    }

    /**
     * @param emailNotification the emailNotification to set
     */
    public void setEmailNotification(boolean emailNotification) {
        this.emailNotification = emailNotification;
    }

    public boolean isInstanceEmailNotification() {
        boolean notification = false;

        try {
            ResultSet instanceRs = io.opnRS("select * from chiro_site.userinfo where secprf='" + io.getLibraryName() + "'");
            if (instanceRs.next()) {
                notification = instanceRs.getBoolean("sendnotificationemail");
            }
            instanceRs.close();
            instanceRs = null;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return notification;
    }

}
