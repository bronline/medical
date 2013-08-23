/*
 * PatientIndicators.java
 *
 * Created on November 28, 2005, 1:01 PM
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
public class PatientIndicators extends RWResultSet{
    private String patientId;
    private ResultSet cRs;
    private RWHtmlTable htmTb = new RWHtmlTable("245"); 
    
    /** Creates a new instance of PatientIndicators */
    public PatientIndicators() {
    }

    public PatientIndicators(RWConnMgr newIo, int newId) throws Exception {
        setConnMgr(newIo);
        setPatientId("" + newId);
    }
    
    public PatientIndicators(RWConnMgr newIo, String newId) throws Exception {
        setConnMgr(newIo);
        setPatientId(newId);
    }

    public void setPatientId(String newId) {
        patientId = newId;
    }
    
    public void setPatientId(int newId) {
        setPatientId("" + newId);
    }
    
    public void setAvailableColors() throws Exception {
        cRs = io.opnRS("select * from statuscolors order by id"); 
    }
    
    public String getPatientIndicators() throws Exception {
        StringBuffer pi = new StringBuffer();
        String onClickLocationA = " onClick=window.open('updateindicators.jsp?patientid=" + patientId + "&colorid=";
        String onClickLocationB = "','Colors','width=1,height=1,scrollbars=no,left=5000,top=5000,') ";

        setAvailableColors();

        pi.append(htmTb.startTable());
        pi.append(htmTb.startRow());

        while(cRs.next()) {
            String link = onClickLocationA + cRs.getString("id") + onClickLocationB;
            link = " onClick=location.href='updateindicators.jsp?patientid=" + patientId + "&colorid=" + cRs.getString("id") + "'";
            setResultSet(io.opnRS("select * from patientindicators where patientid=" + patientId + " and colorid=" + cRs.getString("id")));
            if(rs.next()) {
                pi.append(htmTb.addCell("", "style=\"cursor: pointer; border: thin solid " + cRs.getString("color") + "; background: " + cRs.getString("color") + "\"" + link));
            } else {
                pi.append(htmTb.addCell("", "style=\"cursor: pointer; border: thin solid " + cRs.getString("color") + "\"" + link));
            }
            rs.close();
        }

        pi.append(htmTb.endRow());
        pi.append(htmTb.endTable());

        return pi.toString();        
    }
    
    public String getViewOnlyPatientIndicators() throws Exception 
    {
        StringBuffer pi = new StringBuffer();

        setAvailableColors();

        pi.append(htmTb.startTable());
        pi.append(htmTb.startRow());

        while( cRs.next() )
        {
            setResultSet(io.opnRS("select * from patientindicators where patientid=" + patientId + " and colorid=" + cRs.getString("id")));
            if(rs.next())
            {
                pi.append(htmTb.addCell("", "style=\"border: thin solid " + cRs.getString("color") + "; background: " + cRs.getString("color") + "\""));
            } 
            else 
            {
                pi.append(htmTb.addCell("", "style=\"border: thin solid " + cRs.getString("color") + "; background: white;\""));
            }
            rs.close();
        }

        pi.append( htmTb.endRow() );
        pi.append( htmTb.endTable() );

        return pi.toString();        
    }
    

    public void setPatientIndicator(String colorId) throws Exception {
        setResultSet(io.opnUpdatableRS("select * from patientindicators where patientid=" + patientId + " and colorid=" + colorId));
        if(rs.next()) {
            rs.deleteRow();
        } else {
            rs.moveToInsertRow();
            rs.updateInt("patientid", Integer.parseInt(patientId));
            rs.updateInt("colorid", Integer.parseInt(colorId));
            rs.insertRow();
        }        
    }
}
