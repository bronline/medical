/*
 * LocationOccupancy.java
 *
 * Created on December 10, 2005, 11:11 PM
 * adepoti
 *
 * To change this template, choose Tools | Options and locate the template under
 * the Source Creation and Management node. Right-click the template and choose
 * Open. You can then make changes to the template in the Source Editor.
 */

package medical;

import tools.*;
import tools.utils.*;
import java.sql.*;
import java.util.*;
import javax.servlet.http.HttpServletRequest;
import medical.utiils.InfoBubble;

/**
 *
 * @author BR Online Solutions
 *  
 */
public class LocationOccupancy 
{
    private RWConnMgr _newIo;
    private RWHtmlTable _htmTb;
    
    private String _self = "";
    private String _locationId = "";
    
    
    //-----------------------------------------------------------------------------------
    /** Creates a new instance of LocationOccupancy */
    //-----------------------------------------------------------------------------------
    public LocationOccupancy(RWConnMgr io, String url, String id) 
    {
        _htmTb = new RWHtmlTable( "", "0" );
        _htmTb.replaceNewLineChar(false);
        
        _self = url;
        _newIo = io;
        _locationId = id;
    }

    
    //-----------------------------------------------------------------------------------
    /** gets the HTML to output to the screen */
    //-----------------------------------------------------------------------------------
    public String getHtml() throws Exception
    {
        //create a new table three columns wide
        RWHtmlTable pageTable = new RWHtmlTable("100%", "0");
       
        pageTable.replaceNewLineChar(false);
        
        StringBuffer sb = new StringBuffer();

        sb.append(pageTable.startTable());
        
        sb.append(pageTable.startRow());
        
        //add the location list filtered list
//        sb.append(pageTable.addCell(pageTable.getFrame( _htmTb.BOTH, "", "silver", 3,
//                pageTable.getTableDiv( 400, 200,
//                "", getLocationResults()))));
        sb.append(pageTable.addCell(InfoBubble.getBubble("roundrect", "locationResultsBubble","200","400","#cccccc", getLocationResults())));

        //add a blank cell to separate the two lists
        sb.append(pageTable.addCell("&nbsp;&nbsp;"));
        
        //add all the patients in the specified location
//        sb.append(pageTable.addCell(pageTable.getFrame( _htmTb.BOTH, "", "silver", 3,
//                pageTable.getTableDiv( 400, 500,
//                "", getLocationOccupancyIFrame()))));
        sb.append(pageTable.addCell(InfoBubble.getBubble("roundrect", "locationResultsBubble","500","400","#cccccc",getLocationOccupancyIFrame())));

        sb.append(pageTable.endRow());
        
        sb.append(pageTable.endTable());
        
        return _htmTb.getFrame( _htmTb.BOTH, "", "white", 3, sb.toString());
    }
    
    
    //-----------------------------------------------------------------------------------
    /** Sets the default values for the FilteredList and displays either the list of locations
     or the patients at the selected location*/
    //-----------------------------------------------------------------------------------
    private void prepTableDefaults( RWFilteredList _lst ) throws Exception 
    {
        String output = "";
        String sql = "";

        // Set special attributes on the filtered list object
        _lst.setTableBorder("0");
        _lst.setCellPadding("1");
        _lst.setCellSpacing("0");
        _lst.setTableWidth("100%");
        _lst.setAlternatingRowColors("white","lightgrey");
        _lst.setUrlField(0);
        _lst.setShowRowUrl(true);
        _lst.setShowComboBoxes(false);
        _lst.setShowColumnHeadings(true);
    }


    //-----------------------------------------------------------------------------------
    /** Lists the locations */
    //-----------------------------------------------------------------------------------
    private String getLocationResults() throws Exception 
    {
        // Create an RWFiltered List object to show the occupations
        RWFilteredList locationlist = new RWFilteredList(_newIo);

        //set the common FilteredList properties that are shared by both lists
        prepTableDefaults( locationlist );
        
        String myQuery = "SELECT id, description FROM locations ORDER BY description";

        // Create an array with the column headings
        String [] columnHeadings = { "location_id",  "Locations" };

        
        // Set special attributes on the filtered list object
        locationlist.setNumberOfColumnsForUrl(2);
        locationlist.setColumnAlignment( 1, "center" );
        locationlist.setRowUrl(_self);

        // Set specific column widths
        String [] cellWidths = {"0%", "100%"};
        locationlist.setColumnWidth(cellWidths);

        StringBuffer sb = new StringBuffer();
        
//        sb.append("<div style=\"width: 150; overflow: auto;\">");

        sb.append(locationlist.getHtml( myQuery, columnHeadings ));

//        sb.append("</div>");

        return sb.toString();
    }



    //-----------------------------------------------------------------------------------
    /**  gets the all the patients in the selected location */
    //-----------------------------------------------------------------------------------
    private String getLocationOccupancyIFrame() throws Exception 
    {
            
        return "<iframe src='whoshere.jsp' width=100% height=100% style=\"background: silver\" frameborder=0></iframe>";
    }
    //-----------------------------------------------------------------------------------
    /**  gets the all the patients in the selected location */
    //-----------------------------------------------------------------------------------
    public String getLocationOccupancy() throws Exception 
    {
        //if it is the initial entry show the first location in the DB
        if ( ( _locationId == null ) || ( _locationId == "" ) ) 
        {
            _locationId = "1";
        }

        //we only want to show anyone waiting less than 24 hours
        //String myQuery = "SELECT pat.id, pat.lastname, pat.firstname, pat.middlename, " +
        String myQuery = "SELECT v.id as rcd, 'remove' as remove, pat.lastname, pat.firstname, pat.middlename, " +
                "DATE(v.timein) AS date_in, TIME(v.timein) AS time_in, " +
                "TIMEDIFF(NOW(), timein) AS wait_time " +
                "FROM visits AS v " +
                "INNER JOIN patients AS pat ON v.patientid=pat.id " +
                "WHERE v.locationid=" + _locationId + 
                " AND (HOUR(TIMEDIFF(NOW(), v.timein)) < 24) ORDER BY wait_time DESC";

        // Create an array with the column headings
        String [] columnHeadings = { "id", "Remove", "Last Name", "First Name",
            "Middle Initial", "Arrival Date",
            "Arrival Time", "Time Waiting" };

        // Create an RWFiltered List object to show the occupations
        RWFilteredList patientlist = new RWFilteredList(_newIo);

        //set the common FilteredList properties that are shared by both lists
        prepTableDefaults( patientlist );
        
       // Set special attributes on the filtered list object
        patientlist.setColumnAlignment( 1, "center" );
        patientlist.setColumnAlignment( 2, "center" );
        patientlist.setColumnAlignment( 3, "center" );
        patientlist.setColumnAlignment( 4, "center" );
        patientlist.setColumnAlignment( 5, "center" );
        patientlist.setColumnAlignment( 6, "center" );
        patientlist.setColumnAlignment( 7, "center" );

        patientlist.setNumberOfColumnsForUrl(2);
        //patientlist.setRowUrl("patientmaint.jsp");
        patientlist.setRowUrl("updaterecord.jsp?fileName=visits&locationid=0");
        // Set specific column widths
        String [] cellWidths = {"0", "100", "100", "100", "100", "100", "100", "100"};
        patientlist.setColumnWidth( cellWidths );

        patientlist.setTableHeading( addTableHeading() );
        patientlist.setTableHeadingOptions("style=\"font-size:10pt\"");
        
        return patientlist.getHtml( myQuery, columnHeadings );
    }


    //-----------------------------------------------------------------------------------
    /** Adds a heading to the table */
    //-----------------------------------------------------------------------------------
    private String addTableHeading() throws Exception
    {
        String tableHeading="";
        ResultSet lRs = _newIo.opnRS( "SELECT description FROM locations WHERE id=" + _locationId );

        if(lRs.next()) { tableHeading="Patients in " +  lRs.getString("description"); }
        lRs.close();
        
        return tableHeading;

    }
    //-----------------------------------------------------------------------------------
    /** Set the location Id */
    //-----------------------------------------------------------------------------------
    public void setLocationId(String newLocationId) throws Exception
    {
        _locationId = newLocationId;
    }
}