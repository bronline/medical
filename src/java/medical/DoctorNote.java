/*
 * DoctorNote.java
 *
 * Created on January 28, 2006, 2:19 PM
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
 * @author ajdepoti
 */
public class DoctorNote extends MedicalResultSet 
{
    private String id;
    private int patientId       = 0;
    private String note;
    private int visitId = 0;
    private Date noteDate;
    private RWInputForm frm     = new RWInputForm();    
    private RWHtmlTable htmTb   = new RWHtmlTable("650", "0");
    private SimpleDateFormat isoFormat = new SimpleDateFormat("yyyy-MM-dd");

    
    /** Creates a new instance of DoctorNote */
    public DoctorNote() 
    {
    }
    
    
    public DoctorNote(RWConnMgr io, String ID) throws Exception 
    {
        setConnMgr(io);
        id = ID;
        setId(id);
// 2007-10-16. Replaced with line above.   setResultSet(io.opnRS("select * from doctornotes where id=" + id));
    }

    
     public String getInputForm(String patientId) throws Exception 
     {
        StringBuffer sy = new StringBuffer();
        frm.setResultSet(rs);
        String today = Format.formatDate(new java.util.Date(), "yyyy-MM-dd");
        
        // Set display attributes for the input form
        frm.setTableBorder("0");
        frm.setDftTextBoxSize("20");
        frm.setDftTextAreaCols("90");
        frm.setDftTextAreaRows("20");
        frm.setShowDatePicker(true);
        frm.setDisplayDeleteButton(true);
        frm.setLabelBold(true);
        frm.setUpdateButtonText("  save  ");
        frm.setDeleteButtonText("remove");
        frm.setFormUrl("doctornotes_d.jsp?update=Y");
        // If adding a comment, Put the familyId and memberId on the form as hidden fields
        if(id.equals("0")) 
        {
            String [] var       = { "patientid" };
            String [] val       = { patientId };
            frm.setPreLoadFields(var);
            frm.setPreLoadValues(val);
        }

        // Get an input item with the record ID to set the rcd and ID fields
        frm.getInputItem("id");
        sy.append(frm.startForm());
        sy.append(htmTb.startTable());
        sy.append(frm.getInputItem("notedate"));
        sy.append(frm.getInputItem("Note","style=\"font-size: 13px\" onKeyUp=\"setNoteText()\""));
        if (visitId!=0) {
            sy.append(frm.hidden(""+ visitId, "visitId"));
        }
        if(id.equals("0")) {
            sy.append(frm.hidden(today, "notedate"));
        }
        sy.append(htmTb.endTable());
        sy.append(frm.updateButton());
        sy.append(frm.deleteButton());
        sy.append(frm.showHiddenFields());
        sy.append(frm.endForm());
        
        return sy.toString();
    }
     
     public String getAjaxInputForm(String patientId, boolean fromVisit) throws Exception
     {
        StringBuffer sy = new StringBuffer();
        frm.setResultSet(rs);
        String today = Format.formatDate(new java.util.Date(), "yyyy-MM-dd");

        // Set display attributes for the input form
        frm.setTableBorder("0");
        frm.setDftTextBoxSize("20");
        frm.setDftTextAreaCols("90");
        frm.setDftTextAreaRows("20");
        frm.setShowDatePicker(true);
        frm.setDisplayDeleteButton(true);
        frm.setLabelBold(true);
        frm.setUpdateButtonText("  save  ");
        frm.setDeleteButtonText("remove");
        frm.setFormUrl("doctornotes_d.jsp?update=Y");
        // If adding a comment, Put the familyId and memberId on the form as hidden fields
        if(id.equals("0"))
        {
            String [] var       = { "patientid" };
            String [] val       = { patientId };
            frm.setPreLoadFields(var);
            frm.setPreLoadValues(val);
        }

        // Get an input item with the record ID to set the rcd and ID fields
        frm.getInputItem("id");
        sy.append(frm.startForm());
        sy.append(htmTb.startTable());
        if(!fromVisit) { sy.append(frm.getInputItem("notedate")); } 
        sy.append(frm.getInputItem("Note","style=\"font-size: 13px\""));
        if (visitId!=0) {
            sy.append(frm.hidden(""+ visitId, "visitId"));
        }
        if(id.equals("0")) {
            sy.append(frm.hidden(today, "notedate"));
        }
        sy.append(htmTb.endTable());
//        sy.append(frm.button("save", "class=\"button\" onClick=\"get(this.parentNode,'SAVE')\""));
//        if(!id.equals("0")) { sy.append("&nbsp;&nbsp;"+frm.button("delete", "class=\"button\" onClick=\"get(this.parentNode,'DELETE')\"")); }
        sy.append(frm.button("save", "class=\"button\" onClick=\"processForm(this.parentNode,'SAVE',null)\""));
        if(!id.equals("0")) { sy.append("&nbsp;&nbsp;"+frm.button("delete", "class=\"button\" onClick=\"processForm(this.parentNode,'DELETE',null)\"")); }
//        sy.append(frm.updateButton());
//        sy.append(frm.deleteButton());
        sy.append(frm.showHiddenFields());
        if(fromVisit) { sy.append(frm.hidden(Format.formatDate(noteDate.toString(),"MM/dd/yyyy"), "notedate")); }
        sy.append(frm.endForm());

        return sy.toString();
    }

    public void setId(int newId) throws Exception {
        setId("" + newId);
    }
    
    public void setId(String newId) throws Exception {
        id = newId;
        this.rs=io.opnRS("select * from doctornotes where id=" + id);
//        setResultSet(io.opnRS("select * from doctornotes where id=" + id));
        refresh();
    }

    public void setPatientId(int newPatientId) throws Exception 
    {
        patientId = newPatientId;
    }

    public void setVisitId(int newVisitId) throws Exception 
    {
        visitId = newVisitId;
    }

    public void setNote(String newNote) throws Exception 
    {
        note = newNote;
    }

    public void setNoteDate(Date newDate) throws Exception {
        noteDate = newDate;
    }

    public void setNoteDate(Calendar newDate) throws Exception {
        noteDate = java.sql.Date.valueOf(isoFormat.format(newDate.getTime()));
    }

    public void refresh() throws Exception {
        this.beforeFirst();
        if (this.next()) {
            id = this.getString("id");
            visitId = this.getInt("visitid");
            patientId = this.getInt("patientId");
            noteDate = this.getDate("notedate");
            note = this.getString("note");
            this.beforeFirst();
        }

    }

    public void update() throws Exception 
    {
        setResultSet(io.opnUpdatableRS("select * from doctornotes where id=" + id));
        rs.beforeFirst();
        if (rs.next()) 
        {
            rs.updateInt("patientid", patientId);
            rs.updateInt("visitid", visitId);
            rs.updateDate("notedate", noteDate);
            rs.updateString("note", note);
            rs.updateRow();
        } 
        else 
        {
            rs.moveToInsertRow();
            rs.updateInt("patientid", patientId);
            rs.updateInt("visitid", visitId);
            rs.updateDate("notedate", noteDate);
            rs.updateString("note", note);
            rs.insertRow();
        }
    }
    public void delete() throws Exception 
    {
        setResultSet(io.opnUpdatableRS("select * from doctornotes where id=" + id));
        if (next()) {
            deleteRow();
        }
    }
}