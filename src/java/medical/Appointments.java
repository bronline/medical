/*
 * Appointments.java
 *
 * Created on November 28, 2005, 12:48 PM
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
public class Appointments extends MedicalResultSet {
    private RWHtmlTable htmTb = new RWHtmlTable("300", "0");
     
    /** Creates a new instance of Appointments */
    public Appointments() {
    }

    public Appointments(RWConnMgr io) throws Exception {
        setConnMgr(io);
    }
    
    public String getPatientAppointments(String patientId) throws Exception {
    // Initialize local variables
        StringBuffer apt = new StringBuffer();

    // Create a resultset for the comments
        setResultSet(io.opnRS("select * from showappointments where patientid=" + patientId + " and date>='" + Format.formatDate(new java.util.Date(), "yyyy-MM-dd") + "' order by date"));

    // Start a new table to house the comments heading
        apt.append(htmTb.startTable("300", "0"));

    // Display the heading
        String onClick = "onClick=showItem(event,'ajax/appointment.jsp?date=" + Format.formatDate(new java.util.Date(),"yyyy-MM-dd") + "',0," + patientId + ",txtHint)";

        apt.append(htmTb.roundedTop(1,"","#030089","appointmentdivision"));
        apt.append(htmTb.startRow());
//        apt.append(htmTb.headingCell("Appointments", htmTb.CENTER, "style=\"cursor: pointer; text-decoration: none;\" onClick=submitForm('apptcalendar.jsp?id=0&patientId=" + ID + "')"));
        apt.append(htmTb.headingCell("Appointments", htmTb.CENTER, "style=\"cursor: pointer; text-decoration: none;\" " + onClick));
        apt.append(htmTb.endRow());

    //  End the table for the comments heading
        apt.append(htmTb.endTable());

    // Start a division for the comments section
        apt.append("<div style=\"width: 300; height: 55;  overflow: auto; text-align: left;\">\n");

    // List the comments
        htmTb.setWidth("281");
        apt.append(htmTb.startTable());
        while(rs.next()) {
            onClick = "onClick=showItem(event,'ajax/appointment.jsp?date=" + Format.formatDate(rs.getString("date"),"yyyy-MM-dd") + "'," + rs.getString("id") + "," + rs.getString("patientid") + ",txtHint)";
            apt.append(htmTb.startRow());
//            apt.append(htmTb.addCell(Format.formatDate(rs.getString("date"), "MM/dd/yyyy"), htmTb.LEFT, "width=20%", "apptcalendar.jsp?apptId=" + rs.getString("id") + "&date=" + Format.formatDate(rs.getString("date"), "yyyyMMdd")  ));
            apt.append(htmTb.addCell(Format.formatDate(rs.getString("date"), "MM/dd/yyyy"), htmTb.LEFT, "width=75 " + onClick  + " style=\"cursor: pointer; color: " + rs.getString("textcolor") + "; background: " + rs.getString("bgcolor") + "\""));
            apt.append(htmTb.addCell(rs.getString("time"), htmTb.LEFT, "width=75 style=\"color: " + rs.getString("textcolor") + "; background: " + rs.getString("bgcolor") + "\"" ));
            apt.append(htmTb.addCell(rs.getString("type"), htmTb.LEFT, "width=130 style=\"color: " + rs.getString("textcolor") + "; background: " + rs.getString("bgcolor") + "\"") );
            apt.append(htmTb.endRow());
        }
        apt.append(htmTb.endTable());

    // End the division
        apt.append("</div>\n");

    // Add a row at the end for separation
        htmTb.setWidth("300");
        apt.append(htmTb.startTable());
        apt.append(htmTb.startRow());
        apt.append(htmTb.addCell(""));
        apt.append(htmTb.endRow());
        apt.append(htmTb.endTable());

        return apt.toString();        
    }

    public String getDetailedPatientAppointments(String patientId) throws Exception {
    // Initialize local variables
        StringBuffer apt = new StringBuffer();

    // Create a resultset for the comments
        setResultSet(io.opnRS("select * from showappointments where patientid=" + patientId + " and date>='" + Format.formatDate(new java.util.Date(), "yyyy-MM-dd") + "' order by date"));

    // Start a new table to house the appointments heading
        apt.append(htmTb.startTable("369", "0"));

    // Display the heading
        apt.append(htmTb.roundedTop(1,"","#cccccc","appointmentdivision"));
        apt.append(htmTb.startRow());
        apt.append(htmTb.headingCell("Appointments", htmTb.CENTER, "style=\"cursor: pointer; text-decoration: none;\" onClick=window.open(\"multiappts.jsp\",\"Appointments\",\"width=240,height=450,left=150,top=150,toolbar=0,status=0,\");"));
        apt.append(htmTb.endRow());

    //  End the table for the comments heading
        apt.append(htmTb.endTable());

    // Start a division for the comments section
        apt.append("<div style=\"width: 369; height: 360;  overflow: auto; text-align: left;\">\n");

    // List the comments
        htmTb.setWidth("350");
        apt.append(htmTb.startTable());
        int i=0;
        while(rs.next()) {
            i++;
            apt.append(htmTb.startRow());
            apt.append(htmTb.addCell(i+"", htmTb.CENTER, "style=\"cursor: pointer; color: " + rs.getString("textcolor") + "; background: " + rs.getString("bgcolor") + "\" onClick=window.open(\"appointments_d.jsp?id=" + rs.getString("id") + "\",\"Appointments\",\"width=500,height=200,left=150,top=200,toolbar=0,status=0,\");  " ));
            apt.append(htmTb.addCell(Format.formatDate(rs.getString("date"), "MM/dd/yyyy"), htmTb.LEFT, "width=20% style=\"cursor: pointer; color: " + rs.getString("textcolor") + "; background: " + rs.getString("bgcolor") + "\" onClick=window.open(\"appointments_d.jsp?id=" + rs.getString("id") + "\",\"Appointments\",\"width=500,height=200,left=150,top=200,toolbar=0,status=0,\");  " ));
            apt.append(htmTb.addCell(rs.getString("time"), htmTb.LEFT, "width=20% style=\"cursor: pointer; color: " + rs.getString("textcolor") + "; background: " + rs.getString("bgcolor") + "\" onClick=window.open(\"appointments_d.jsp?id=" + rs.getString("id") + "\",\"Appointments\",\"width=500,height=200,left=150,top=200,toolbar=0,status=0,\");  " ));
            apt.append(htmTb.addCell(rs.getString("type"), htmTb.LEFT, "style=\"cursor: pointer; color: " + rs.getString("textcolor") + "; background: " + rs.getString("bgcolor") + "\" onClick=window.open(\"appointments_d.jsp?id=" + rs.getString("id") + "\",\"Appointments\",\"width=500,height=200,left=150,top=200,toolbar=0,status=0,\");  " ));
            apt.append(htmTb.endRow());
            apt.append(htmTb.startRow("style=\"height: 2px\""));
            //apt.append(htmTb.addCell("","COLSPAN=3 style=\"height: 2px\""));
            apt.append(htmTb.endRow());

        }
        apt.append(htmTb.endTable());

    // End the division
        apt.append("</div>\n");

    // Add a row at the end for separation
        htmTb.setWidth("350");
        apt.append(htmTb.startTable());
        apt.append(htmTb.startRow());
        apt.append(htmTb.addCell(""));
        apt.append(htmTb.endRow());
        apt.append(htmTb.endTable());

        return apt.toString();        
    }

    public String getDetailedPatientMissedAppointments(String patientId) throws Exception {
    // Initialize local variables
        StringBuffer apt = new StringBuffer();

    // Create a resultset for the comments
        setResultSet(io.opnRS("select a.* from showappointments a join (select * from appointmentsmissed) b on a.id=b.id where a.patientid=" + patientId + " order by a.date"));

    // Start a new table to house the appointments heading
        apt.append(htmTb.startTable("399", "0"));

    // Display the heading
        apt.append(htmTb.roundedTop(1,"","#cccccc","appointmentdivision"));
        apt.append(htmTb.startRow());
        apt.append(htmTb.headingCell("Missed Appointments", htmTb.CENTER, ""));
        apt.append(htmTb.endRow());

    //  End the table for the comments heading
        apt.append(htmTb.endTable());

    // Start a division for the comments section
        apt.append("<div style=\"width: 399; height: 80;  overflow: auto; text-align: left;\">\n");

    // List the comments
        htmTb.setWidth("380");
        apt.append(htmTb.startTable());
        while(rs.next()) {
            apt.append(htmTb.startRow());
            apt.append(htmTb.addCell(Format.formatDate(rs.getString("date"), "MM/dd/yyyy"), htmTb.LEFT, "width=20% style=\"cursor: pointer; color: " + rs.getString("textcolor") + "; background: " + rs.getString("bgcolor") + "\" onClick=window.open(\"appointments_d.jsp?id=" + rs.getString("id") + "\",\"Appointments\",\"width=500,height=200,left=150,top=200,toolbar=0,status=0,\");  " ));
            apt.append(htmTb.addCell(rs.getString("time"), htmTb.LEFT, "width=20% style=\"cursor: pointer; color: " + rs.getString("textcolor") + "; background: " + rs.getString("bgcolor") + "\" onClick=window.open(\"appointments_d.jsp?id=" + rs.getString("id") + "\",\"Appointments\",\"width=500,height=200,left=150,top=200,toolbar=0,status=0,\");  " ));
            apt.append(htmTb.addCell(rs.getString("type"), htmTb.LEFT, "style=\"cursor: pointer; color: " + rs.getString("textcolor") + "; background: " + rs.getString("bgcolor") + "\" onClick=window.open(\"appointments_d.jsp?id=" + rs.getString("id") + "\",\"Appointments\",\"width=500,height=200,left=150,top=200,toolbar=0,status=0,\");  " ));
            apt.append(htmTb.endRow());
            apt.append(htmTb.startRow("style=\"height: 2px\""));
            //apt.append(htmTb.addCell("","COLSPAN=3 style=\"height: 2px\""));
            apt.append(htmTb.endRow());

        }
        apt.append(htmTb.endTable());

    // End the division
        apt.append("</div>\n");

    // Add a row at the end for separation
        htmTb.setWidth("350");
        apt.append(htmTb.startTable());
        apt.append(htmTb.startRow());
        apt.append(htmTb.addCell(""));
        apt.append(htmTb.endRow());
        apt.append(htmTb.endTable());

        return apt.toString();        
    }

}
