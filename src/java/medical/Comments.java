/*
 * Comments.java
 *
 * Created on November 28, 2005, 12:38 PM
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
public class Comments extends MedicalResultSet {
    private RWHtmlTable htmTb = new RWHtmlTable("300", "0");
    
    /** Creates a new instance of Comments */
    public Comments() {
    }

    public Comments(RWConnMgr io) throws Exception {
        setConnMgr(io);
    }

    public String getPatientComments(String patientId) throws Exception {
        setResultSet(io.opnRS("select * from comments where patientid=" + patientId + " order by date desc"));
    // Initialize local variables
        StringBuffer cmt = new StringBuffer();
        String onClick = "onClick=showItem(event,'comments_d_new.jsp?date=" + Format.formatDate(new java.util.Date(),"yyyy-MM-dd") + "',0," + patientId + ",txtHint)";
//        String onClickLocationA = "onClick=window.open(\"comments_d.jsp?id=";
//        String onClickLocationB = "\",\"Comments\",\"width=500,height=200,left=150,top=200,toolbar=0,status=0,\"); ";
        String linkClass = " style=\"cursor: pointer; color: #030089;\"";

    // Start a new table to house the comments heading
        cmt.append(htmTb.startTable("300", "0"));

    // Display the heading
        cmt.append(htmTb.roundedTop(1,"","#030089","commentdivision"));
        cmt.append(htmTb.startRow());
//        cmt.append(htmTb.headingCell("Comments", "style=\"cursor: pointer\" " + onClickLocationA + "0&patientid=" + patientId + onClickLocationB));
        cmt.append(htmTb.headingCell("Comments", "style=\"cursor: pointer\" " + onClick));
        cmt.append(htmTb.endRow());

    //  End the table for the comments heading
        cmt.append(htmTb.endTable());

    // Start a division for the comments section
        htmTb.setWidth("281");

        cmt.append("<div style=\"width: 300; height: 79;  overflow: auto; text-align: left;\">\n");

    // List the comments
        htmTb.setWidth("281");
        cmt.append(htmTb.startTable());
        while(rs.next()) {
            String comment = rs.getString("comment");
            onClick = "onClick=showItem(event,'comments_d_new.jsp?'," + rs.getString("id") + "," + patientId + ",txtHint)";
            
//            String link = onClickLocationA + rs.getString("id") + onClickLocationB;
            cmt.append(htmTb.startRow());
//            cmt.append(htmTb.addCell(Format.formatDate(rs.getString("date"), "MM/dd/yyyy"), htmTb.LEFT, "width=25% " + link + linkClass, "" ));
            cmt.append(htmTb.addCell(Format.formatDate(rs.getString("date"), "MM/dd/yyyy"), htmTb.LEFT, "width=\"25%\" " + onClick + linkClass, "" ));
            cmt.append(htmTb.addCell(comment, "width=\"75%\""));
            cmt.append(htmTb.endRow());
        }
        cmt.append(htmTb.endTable());

    // End the division
        cmt.append("</div>\n");

    // Add a row at the end for separation
        htmTb.setWidth("300");
        cmt.append(htmTb.startTable());
        cmt.append(htmTb.startRow());
        cmt.append(htmTb.addCell(""));
        cmt.append(htmTb.endRow());
        cmt.append(htmTb.endTable());

        return cmt.toString();        
    }
}
