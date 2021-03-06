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
public class XrayFindings extends MedicalResultSet {
    private StringBuffer sy   = new StringBuffer();
    private RWHtmlTable htmTb = new RWHtmlTable();
    private RWInputForm frm   = new RWInputForm();
    
    /** Creates a new instance of Symptoms */
    public XrayFindings() {
    }
    
    public XrayFindings(RWConnMgr newIo) throws Exception {
        setConnMgr(newIo);        
    }
    
    public String getXrayFindings(int patientId) throws Exception {
        return getXrayFindings(patientId, "");
    }
    
    public String getXrayFindings(int patientId, String fontSize) throws Exception {
        String style = "";
        
        if (!fontSize.equals("")) {
            style = " font-size: " + fontSize + ";'";
        }
        rs = io.opnRS("select id, date, findings from xrayfindings where patientid=" + patientId);
        sy.delete(0, sy.length());
        sy.append("<div id=xrayFindingsBubble style='width: 100%;'>");
        sy.append(htmTb.startTable("100%", "0"));
        String onClickLocationA = "onClick=window.open(\"xrayfindings_d.jsp?id=";
        String onClickLocationB = "\",\"Findings\",\"width=500,height=200,left=150,top=200,toolbar=0,status=0,\"); ";
        String linkClass = " style=\"cursor: pointer; color: #030089;" + style + "\"";

        sy.append(htmTb.roundedTop(1,"","#030089",""));

        // Display the heading
        sy.append(htmTb.startRow());
        sy.append(htmTb.headingCell("Findings", "style=\"cursor: pointer\" " + onClickLocationA + "0&patientid=" + patientId + onClickLocationB));
        sy.append(htmTb.endRow());
    //  End the table for the comments heading
        sy.append(htmTb.endTable());

    // Start a division for the symptoms section
        sy.append("<div style=\"width: 225; height: 55;  overflow: auto; text-align: left;\">\n");

    // List the symptoms
        sy.append(htmTb.startTable("94%", "0"));

        while(next()) {
            String link = onClickLocationA + rs.getString("id") + onClickLocationB;
            sy.append(htmTb.startRow());
            //sy.append(htmTb.addCell(getString("date"), htmTb.CENTER, link + linkClass, ""));
            sy.append(htmTb.addCell(getString("findings"), htmTb.LEFT, link + linkClass + " " + style, ""));
            sy.append(htmTb.endRow());
        }
        sy.append(htmTb.endTable());
    // End the division
        sy.append("</div></div>\n");
        
        return sy.toString();
    }
}
