/*
 * Symptom.java
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
public class Symptom extends MedicalResultSet {
    private String id;
    private int patientId       = 0;
    private String symptom;
    private int diagnosisId     = 0;
    private int sequence        = 0;
    private int conditionId     = 0;
    private RWInputForm frm     = new RWInputForm();    
    private RWHtmlTable htmTb   = new RWHtmlTable("650", "0");
    
    /** Creates a new instance of Symptom */
    public Symptom() {
    }

    public Symptom(RWConnMgr io, String ID) throws Exception {
        setConnMgr(io);
        id = ID;
        setResultSet(io.opnRS("select * from patientsymptoms where id=" + id));
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
        if(getId().equals("0")) {
            String [] var       = { "patientid" };
            String [] val       = { patientId };
            frm.setPreLoadFields(var);
            frm.setPreLoadValues(val);
        }

    // Get an input item with the record ID to set the rcd and ID fields
        frm.getInputItem("id");
        sy.append(frm.startForm());
        sy.append(htmTb.startTable());
        sy.append(frm.getInputItem("diagnosisid"));
        sy.append(frm.getInputItem("symptom"));
        sy.append(frm.getInputItem("sequence"));
        sy.append(htmTb.endTable());
        sy.append(frm.updateButton());
        sy.append(frm.deleteButton());
//        sy.append(frm.button("  save  ", "class=button onclick=\"javascript:get(this.parentNode,'SAVE');\""));
//        if(Integer.parseInt(this.id) !=0 ) { sy.append("&nbsp;&nbsp;&nbsp;" + frm.button("  delete  ", "class=button onclick=\"javascript:get(this.parentNode,'DELETE',symptoms);\"")); }
//        sy.append("&nbsp;&nbsp;&nbsp;" + frm.button("  cancel  ", "class=button onclick='javascript:showHide(txtHint,\"HIDE\");'"));
        
        sy.append(frm.showHiddenFields());
        sy.append(frm.endForm());
        
        return sy.toString();
    }

    public void setPatientId(int newPatientId) throws Exception {
        patientId = newPatientId;
    }
    
    public void setPatientId(String patientId) throws Exception {
        setPatientId(Integer.parseInt(checkStringValueIsNumeric(patientId)));        
    }

    public void setSymptom(String newSymptom) throws Exception {
        symptom = newSymptom;
    }
    
    public void setDiagnosisId(int newDiagnosisId) throws Exception {
        diagnosisId = newDiagnosisId;
    }
    
    public void setDiagnosisId(String diagnosisId) throws Exception {
        setDiagnosisId(Integer.parseInt(checkStringValueIsNumeric(diagnosisId)));                
    }

    public void update() throws Exception {
        setResultSet(io.opnUpdatableRS("select * from patientsymptoms where id=" + getId()));
        rs.beforeFirst();
        if (rs.next()) {
            rs.updateInt("patientid", patientId);
            rs.updateString("symptom", symptom);
            rs.updateInt("diagnosisid", diagnosisId);
            rs.updateInt("sequence",getSequence());
            rs.updateRow();
        } else {
            rs.moveToInsertRow();
            rs.updateInt("patientid", patientId);
            rs.updateString("symptom", symptom);
            rs.updateInt("diagnosisid", diagnosisId);
            rs.updateInt("sequence",getSequence());
            rs.updateInt("conditionid", conditionId);
            rs.updateString("date", Format.formatDate(new java.util.Date(), "yyyy-MM-dd"));
            rs.insertRow();
        }
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public int getSequence() {
        return sequence;
    }

    public void setSequence(int sequence) {
        this.sequence = sequence;
    }
    public void setSequence(String sequence) throws Exception {
        setSequence(Integer.parseInt(checkStringValueIsNumeric(sequence)));                
    }

    /**
     * @return the conditionId
     */
    public int getConditionId() {
        return conditionId;
    }

    /**
     * @param conditionId the conditionId to set
     */
    public void setConditionId(int conditionId) {
        this.conditionId = conditionId;
    }
     
}
