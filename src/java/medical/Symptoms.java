/*
 * Symptoms.java
 *
 * Created on December 27, 2005, 1:27 PM
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
 * @author rwandell
 */
public class Symptoms extends MedicalResultSet {
    private StringBuffer sy   = new StringBuffer();
    private RWHtmlTable htmTb = new RWHtmlTable();
    private RWInputForm frm   = new RWInputForm();
    
    /** Creates a new instance of Symptoms */
    public Symptoms() {
    }
    
    public Symptoms(RWConnMgr newIo) throws Exception {
        setConnMgr(newIo);        
    }
    
    public String getPatientSymptoms(int patientId) throws Exception {
        rs = io.opnRS("select a.id, sequence, concat(code, ' - ', description) as description, symptom from patientsymptoms a join diagnosiscodes b on a.diagnosisid=b.id where patientid=" + patientId + " order by sequence");
        sy.delete(0, sy.length());
        sy.append("<div id=patientSymptomsBubble style='width: 225;'>");
        sy.append(htmTb.startTable("100%", "0"));
//        String onClickLocationA = "onClick=window.open(\"symptoms_d.jsp?id=";
//        String onClickLocationB = "\",\"Symptoms\",\"width=500,height=125,left=150,top=200,toolbar=0,status=0,\"); ";
        String onClickLocationA = "onClick=showInputForm(event,'symptoms_d.jsp',0," + patientId + ",txtHint)";
        String linkClass = " style=\"cursor: pointer; color: #030089;\"";

        sy.append(htmTb.roundedTop(1,"","#030089",""));

        // Display the heading
        sy.append(htmTb.startRow());
//        sy.append(htmTb.headingCell("Diagnosis", "style=\"cursor: pointer\" " + onClickLocationA + "0&patientid=" + patientId + onClickLocationB));
        sy.append(htmTb.headingCell("Diagnosis", "style=\"cursor: pointer\" " + onClickLocationA ));
        sy.append(htmTb.endRow());
    //  End the table for the comments heading
        sy.append(htmTb.endTable());

    // Start a division for the symptoms section
        sy.append("<div style=\"width: 100%; height: 55;  overflow: auto; text-align: left;\">\n");

    // List the symptoms
        sy.append(htmTb.startTable("94%", "0"));

        while(next()) {
//            String link = onClickLocationA + rs.getString("id") + onClickLocationB;
            String link = onClickLocationA;
            sy.append(htmTb.startRow());
            sy.append(htmTb.addCell(getString("description").trim(), htmTb.LEFT, link + linkClass, ""));
//            sy.append(htmTb.addCell(getString("symptom"), htmTb.LEFT, link + linkClass, ""));
            sy.append(htmTb.endRow());
        }
        sy.append(htmTb.endTable());
    // End the division
        sy.append("</div></div>\n");
        
        return sy.toString();
    }

    public String getConditionSymptoms(int conditionId) throws Exception {
        int patientId=0;
        ResultSet condRs=io.opnRS("select patientid from patientconditions where id=" + conditionId);
        if(condRs.next()) { patientId=condRs.getInt("patientid"); }
        condRs.close();

        rs = io.opnRS("select a.id, sequence, concat(code, ' - ', description) as description, symptom from patientsymptoms a join diagnosiscodes b on a.diagnosisid=b.id where conditionid=" + conditionId + " order by sequence");
        sy.delete(0, sy.length());
        sy.append("<div id=\"patient_symptoms_container\" style='width: 100%;'>");
        sy.append(htmTb.startTable("100%", "0"));

        String onClickLocationA ="";
        if(patientId != 0) { onClickLocationA="onClick=showInputForm(event,'symptoms_d.jsp?condition=Y'," + conditionId + "," + patientId + ",txtHint)"; }
        String linkClass = " style=\"cursor: pointer; color: #030089;\"";

        sy.append(htmTb.roundedTop(1,"","#030089",""));

        // Display the heading
        sy.append(htmTb.startRow());
//        sy.append(htmTb.headingCell("Diagnosis", "style=\"cursor: pointer\" " + onClickLocationA + "0&patientid=" + patientId + onClickLocationB));
        sy.append(htmTb.headingCell("Diagnosis", "style=\"cursor: pointer\" " + onClickLocationA ));
        sy.append(htmTb.endRow());
    //  End the table for the comments heading
        sy.append(htmTb.endTable());

    // Start a division for the symptoms section
        sy.append("<div style=\"width: 100%; height: 55;  overflow: auto; text-align: left;\">\n");

    // List the symptoms
        sy.append(htmTb.startTable("94%", "0"));

        while(next()) {
//            String link = onClickLocationA + rs.getString("id") + onClickLocationB;
            String link = onClickLocationA;
            sy.append(htmTb.startRow());
            sy.append(htmTb.addCell(getString("description").trim(), htmTb.LEFT, link + linkClass, ""));
//            sy.append(htmTb.addCell(getString("symptom"), htmTb.LEFT, link + linkClass, ""));
            sy.append(htmTb.endRow());
        }
        sy.append(htmTb.endTable());
    // End the division
        sy.append("</div></div>\n");

        return sy.toString();
    }

    public String getConditionSymptoms(String conditionId) {
        try {
            return getConditionSymptoms(Integer.parseInt(conditionId));
        } catch (Exception e) {
            return "";
        }
    }
}
