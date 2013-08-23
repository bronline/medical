/*
 * PatientProblem.java
 *
 * Created on December 27, 2005, 4:31 PM
 *
 * To change this template, choose Tools | Options and locate the template under
 * the Source Creation and Management node. Right-click the template and choose
 * Open. You can then make changes to the template in the Source Editor.
 */

package medical;
import tools.*;
import tools.utils.*;
import java.sql.*;
/**
 *
 * @author BR Online Solutions
 */
public class XrayFinding extends RWResultSet {
    private String id;
    private int patientId       = 0;
    private String findings;
    private Date date;
    private RWInputForm frm     = new RWInputForm();    
    private RWHtmlTable htmTb   = new RWHtmlTable("650", "0");
    
    /** Creates a new instance of Symptom */
    public XrayFinding() {
    }

    public XrayFinding(RWConnMgr io, String ID) throws Exception {
        setConnMgr(io);
        id = ID;
        setResultSet(io.opnRS("select * from xrayfindings where id=" + id));
    }

     public String getInputForm(String patientId) throws Exception {
        StringBuffer sy = new StringBuffer();
        frm.setResultSet(rs);
        
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
            String [] var       = { "patientid" };
            String [] val       = { patientId };
            frm.setPreLoadFields(var);
            frm.setPreLoadValues(val);
        }

    // Get an input item with the record ID to set the rcd and ID fields
        frm.getInputItem("id");
        sy.append(frm.startForm());
        sy.append(htmTb.startTable());
        sy.append(frm.getInputItem("date"));
        sy.append(frm.getInputItem("findings"));
        sy.append(htmTb.endTable());
        sy.append(frm.updateButton());
        sy.append(frm.deleteButton());
        sy.append(frm.showHiddenFields());
        sy.append(frm.endForm());
        
        return sy.toString();
    }

    public void setPatientId(int newPatientId) throws Exception {
        patientId = newPatientId;
    }

    public void setDate(Date newDate) {
        date = newDate;
    }
    
    public void setFindings(String newFindings) throws Exception {
        findings = newFindings;
    }
    
    public void update() throws Exception {
        setResultSet(io.opnUpdatableRS("select * from xrayfindings where id=" + id));
        rs.beforeFirst();
        if (rs.next()) {
            rs.updateInt("patientid", patientId);
            rs.updateDate("date", (java.sql.Date)date);
            rs.updateString("findings", findings);
            rs.updateRow();
        } else {
            rs.moveToInsertRow();
            rs.updateInt("patientid", patientId);
            rs.updateDate("date", (java.sql.Date)date);
            rs.updateString("findings", findings);
            rs.insertRow();
        }
    }
     
}
