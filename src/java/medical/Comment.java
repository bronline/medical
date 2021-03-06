/*
 * Comment.java
 *
 * Created on November 28, 2005, 11:46 AM
 *
 * To change this template, choose Tools | Options and locate the template under
 * the Source Creation and Management node. Right-click the template and choose
 * Open. You can then make changes to the template in the Source Editor.
 */

package medical;
import tools.*;
import tools.utils.*;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.Calendar;

/**
 *
 * @author rwandell
 */
public class Comment extends MedicalResultSet {
    private String id;
    private int patientId = 0;
    private int visitId = 0;
    private int appointmentId = 0;
    private Date date;
    private String comment;
    private int type = 0;
    private SimpleDateFormat isoFormat = new SimpleDateFormat("yyyy-MM-dd");

    /** Creates a new instance of Comment */
    public Comment() {
    }

    public Comment(RWConnMgr io, String ID) throws Exception {
        setConnMgr(io);
        id = ID;
        setResultSet(io.opnRS("select * from comments where id=" + id));
    }

    public String getInputForm(String patientId, String visitId) throws Exception {
    // Instantiate an RWInputForm and RWHtmlTable object
        if(this.date != null && this.type !=0 && !patientId.equals("0")) {
            setResultSet(io.opnRS("select * from comments where patientid=" + patientId + " and type=" + this.type + " and date='" + isoFormat.format(this.date) + "'"));
            if(rs.next()) { this.id=(rs.getString("id")); }
            rs.beforeFirst();
        } 
        RWInputForm frm = new RWInputForm(rs);
        RWHtmlTable htmTb = new RWHtmlTable ("100%", "0");
        StringBuffer cf = new StringBuffer();
  
    // Set display attributes for the input form
        frm.setTableBorder("0");
        frm.setDftTextBoxSize("20");
        frm.setDftTextAreaCols("80");
        frm.setDftTextAreaRows("10");
        frm.setShowDatePicker(true);
        frm.setDisplayDeleteButton(true);
        frm.setLabelBold(true);
        frm.setUpdateButtonText("  save  ");
        frm.setDeleteButtonText("remove");

    // If adding a comment, Put the familyId and memberId on the form as hidden fields
        if(id.equals("0")) {
            String [] var       = { "patientid", "visitid" };
            String [] val       = { patientId, visitId };
            frm.setPreLoadFields(var);
            frm.setPreLoadValues(val);
        }

    // Get an input item with the record ID to set the rcd and ID fields
        frm.getInputItem("id");
        cf.append(frm.startForm());
        cf.append(htmTb.startTable());
    // RKW 07-15-2008 Get the patient name to display on the form
        cf.append(htmTb.startRow());
        cf.append(htmTb.headingCell("Entering comments for: " + getPatientInfo(patientId, visitId), "colspan=2"));
        cf.append(htmTb.endRow());
        cf.append(htmTb.startRow());
        cf.append(htmTb.addCell("", "colspan=2"));
        cf.append(htmTb.endRow());
        cf.append(frm.getInputItem("date"));
        cf.append(frm.getInputItem("type"));
        cf.append(frm.getInputItem("comment"));
        cf.append(htmTb.endTable());
        cf.append(frm.updateButton());
        cf.append(frm.deleteButton());
        cf.append(frm.showHiddenFields());
        cf.append(frm.endForm());
        
        return cf.toString();
    }

    public String getAjaxInputForm(String patientId, String visitId) throws Exception {
    // Instantiate an RWInputForm and RWHtmlTable object
        if(this.date != null && this.type !=0 && !patientId.equals("0")) {
            setResultSet(io.opnRS("select * from comments where patientid=" + patientId + " and type=" + this.type + " and date='" + isoFormat.format(this.date) + "'"));
            if(rs.next()) { this.id=(rs.getString("id")); }
            rs.beforeFirst();
        } 
        RWInputForm frm = new RWInputForm(rs);
        RWHtmlTable htmTb = new RWHtmlTable ("100%", "0");
        StringBuffer cf = new StringBuffer();
  
    // Set display attributes for the input form
        frm.setTableBorder("0");
        frm.setDftTextBoxSize("20");
        frm.setDftTextAreaCols("80");
        frm.setDftTextAreaRows("10");
        frm.setShowDatePicker(true);
        frm.setDisplayDeleteButton(true);
        frm.setLabelBold(true);
        frm.setUpdateButtonText("  save  ");
        frm.setDeleteButtonText("remove");

    // If adding a comment, Put the familyId and memberId on the form as hidden fields
        if(id.equals("0")) {
            String [] var       = { "patientid", "visitid" };
            String [] val       = { patientId, visitId };
            frm.setPreLoadFields(var);
            frm.setPreLoadValues(val);
        }

    // Get an input item with the record ID to set the rcd and ID fields
//        frm.getInputItem("id", "id=ID");

        cf.append(htmTb.startTable());
        cf.append(htmTb.startRow());
        cf.append(htmTb.roundedTopCell(2,"transparent","#030089",""));
        cf.append(htmTb.endRow());
        
        cf.append(htmTb.startRow());
        cf.append(htmTb.headingCell("Entering comments for: " + getPatientInfo(patientId, visitId), "colspan=2"));
        cf.append(htmTb.endRow());
        cf.append(htmTb.startRow());
        cf.append(htmTb.addCell("", "colspan=2"));
        cf.append(htmTb.endRow());
        cf.append(frm.getInputItem("date"));
        cf.append(frm.getInputItem("type"));
        cf.append(frm.getInputItem("comment"));
        cf.append(htmTb.endTable());
        
        cf.append("<br>" + frm.button("  save  ", "class=button onclick=\"formObj=document.getElementById('txtHint'); processForm(this.parentNode,'SAVE');\""));
        if(!this.id.equals("0") ) { cf.append("&nbsp;&nbsp;&nbsp;" + frm.button("  delete  ", "class=button onclick=\"formObj=document.getElementById('txtHint'); processForm(this.parentNode,'DELETE');\"")); }
        cf.append("&nbsp;&nbsp;&nbsp;" + frm.button("  cancel  ", "class=button onclick='javascript:enableMouseOut=true;showHide(txtHint,\"HIDE\");'"));

//        cf.append(frm.showHiddenFields());
        
        return cf.toString();
    }

    public void setId(String id) {
        this.id=id;
    }
    
    public void setPatientId(int newPatientId) throws Exception {
        patientId = newPatientId;
    }

    public void setPatientId(String patientId) throws Exception {
        setPatientId(Integer.parseInt(checkStringValueIsNumeric(patientId)));        
    }
    
    public void setVisitId(int newVisitId) throws Exception {
        visitId = newVisitId;
    }
    
    public void setVisitId(String visitId) throws Exception {
        setVisitId(Integer.parseInt(checkStringValueIsNumeric(visitId)));        
    }
    
    public void setDate(String newDate) throws Exception {
        this.date=java.sql.Date.valueOf(Format.formatDate(newDate, "yyyy-MM-dd"));
    }

    public void setDate(Date newDate) throws Exception {
        date = newDate;
    }

    public void setDate(Calendar newDate) throws Exception {
        date = java.sql.Date.valueOf(isoFormat.format(newDate.getTime()));
    }

    public void setComment(String newComment) throws Exception {
        comment = newComment;
    }

    public void setType(int newType) {
        this.type=newType;
    }
    
    public void setType(String type) throws Exception {
        setType(Integer.parseInt(checkStringValueIsNumeric(type)));        
    }
    
    public void update() throws Exception {
        setResultSet(io.opnUpdatableRS("select * from comments where id=" + id));
        rs.beforeFirst();
        if (rs.next()) {
            rs.updateInt("patientid", patientId);
            rs.updateInt("visitid", visitId);
            rs.updateInt("appointmentid", appointmentId);
            rs.updateDate("date", date);
            rs.updateString("comment", comment);
            rs.updateInt("type", this.type);
            rs.updateRow();
        } else {
            rs.moveToInsertRow();
            rs.updateInt("patientid", patientId);
            rs.updateInt("visitid", visitId);
            rs.updateDate("date", date);
            rs.updateString("comment", comment);
            rs.updateInt("type", this.type);
            rs.updateInt("appointmentid", appointmentId);
            rs.insertRow();
        }
    }

    // RKW 07-15-08 Retrieve the patient information to display on the form
    private String getPatientInfo(String patientId, String visitId) throws Exception {
        String info="";
        if(patientId != null && !patientId.equals("") && !patientId.equals("0")) {
            ResultSet lRs=io.opnRS("Select concat(firstname, ' ', lastname) as name from patients where id=" + patientId);
            if(lRs.next()) { info=lRs.getString("name"); }
            lRs.close();
        } else if(visitId != null && !visitId.equals("") && !visitId.equals("0")) {            
            ResultSet lRs=io.opnRS("select concat(firstname, ' ', lastname) as name  from visits left join patients on patients.id=visits.patientid where visits.id=" + visitId);
            if(lRs.next()) { info=lRs.getString("name"); }
            lRs.close();            
        } else if(id !=null && !id.equals("") && !id.equals("0")) {
            ResultSet lRs=io.opnRS("select concat(firstname, ' ', lastname) as name  from comments left join patients on patients.id=comments.patientid where comments.id=" + id);
            if(lRs.next()) { info=lRs.getString("name"); }
            lRs.close();                        
        }
        return info;
    }
    
    public boolean delete() {
        boolean rowDeleted = true;
        try {
            io.getConnection().prepareStatement("delete from comments where id=" + this.id).execute();
        } catch(Exception e) {
            rowDeleted = false;
        }
        
        return rowDeleted;
    }
    
    public boolean delete(int id) {
        setId(""+id);
        return delete();
    }
    
    public int getAppointmentId() {
        return appointmentId;
    }

    public void setAppointmentId(int appointmentId) {
        this.appointmentId = appointmentId;
    }

    public void setAppointmentId(String appointmentId) throws Exception {
        setAppointmentId(Integer.parseInt(checkStringValueIsNumeric(appointmentId)));        
    }
    
    
}
