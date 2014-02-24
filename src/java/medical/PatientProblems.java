/*
 * PatientProblems.java
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
public class PatientProblems extends MedicalResultSet {
    private StringBuffer sy   = new StringBuffer();
    private RWHtmlTable htmTb = new RWHtmlTable();
    private RWInputForm frm   = new RWInputForm();
    
    /** Creates a new instance of Symptoms */
    public PatientProblems() {
    }
    
    public PatientProblems(RWConnMgr newIo) throws Exception {
        setConnMgr(newIo);        
    }
    
    public String getPatientProblems(int patientId) throws Exception {
        return getPatientProblems(patientId,"");
    }
    
    public String getPatientProblems(int patientId, String fontSize) throws Exception {
        String style = "";
        
        if (!fontSize.equals("")) {
            style = " font-size: " + fontSize + ";";
        }

        rs = io.opnRS("select id, problem from patientproblems where patientid=" + patientId);
        sy.delete(0, sy.length());
        sy.append("<div id=patientProblemsBubble style='width: 100%;'>");
        sy.append(htmTb.startTable("100%", "0"));
        String onClickLocationA = "onClick=window.open(\"patientproblems_d.jsp?id=";
        String onClickLocationB = "\",\"Problems\",\"width=500,height=200,left=150,top=200,toolbar=0,status=0,\"); ";
        String linkClass = " style=\"cursor: pointer; color: #030089;" + style + "\"";

        sy.append(htmTb.roundedTop(1,"","#030089",""));

        // Display the heading
        sy.append(htmTb.startRow());
        sy.append(htmTb.headingCell("Problems", "style=\"cursor: pointer\" " + onClickLocationA + "0&patientid=" + patientId + onClickLocationB));
        sy.append(htmTb.endRow());
    //  End the table for the comments heading
        sy.append(htmTb.endTable());

    // Start a division for the symptoms section
        sy.append("<div style=\"width: 100%; height: 55;  overflow: auto; text-align: left;\">\n");

    // List the symptoms
        sy.append(htmTb.startTable("94%", "0"));

        while(next()) {
            String link = onClickLocationA + rs.getString("id") + onClickLocationB;
            sy.append(htmTb.startRow());
            sy.append(htmTb.addCell(getString("problem"), htmTb.LEFT, link + linkClass + " " + style, ""));
            sy.append(htmTb.endRow());
        }
        sy.append(htmTb.endTable());
    // End the division
        sy.append("</div></div>\n");
        
        return sy.toString();
    }
}
