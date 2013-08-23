/*
 * VisitActivity.java
 *
 * Created on Feb 4, 2006, 12:03 PM
 *
 * To change this template, choose Tools | Options and locate the template under
 * the Source Creation and Management node. Right-click the template and choose
 * Open. You can then make changes to the template in the Source Editor.
 */

package medical;
import java.math.BigDecimal;
import tools.*;
import java.sql.*;
import java.util.Calendar;
import java.util.Enumeration;
import javax.servlet.http.HttpServletRequest;
import medical.utiils.InfoBubble;


/**
 *
 * @author adepoti
 */
public class VisitActivity extends RWResultSet
{
    private int visitId = 0;
    private int patientId = 0;
    private int noteId = 0;
    private int itemId = 0;
    private int _visitId = 0;
    private int resourceId = 0;
    private String _self = "";
    private RWConnMgr _newIo = null;
    private RWHtmlTable _htmTb = null;
    private Visit _visit = null;
    private Patient _patient = null;
    private String visitFontSize = "";


    //-----------------------------------------------------------------------------------
    /** Default Constructor */
    //-----------------------------------------------------------------------------------
    public VisitActivity()
    {
    }

    
    //-----------------------------------------------------------------------------------
    /** Overloaded Constructor */
    //-----------------------------------------------------------------------------------
    public VisitActivity(RWConnMgr io, Visit visit, Patient patient, int visitId, String self) throws Exception 
    {
        _newIo = io;
        _visit = visit;
        _patient = patient;
        if (visitId==0 && visit!=null) {
            visitId=visit.getId();
        }
        _visitId = visitId;        
        _self = self;
    }
    

    //-----------------------------------------------------------------------------------
    /** gets the HTML for the page */
    //-----------------------------------------------------------------------------------
    public String getHtml() throws Exception
    {
        _patient.setId(_visit.getInt("patientId"));
        
        RWHtmlTable htmTb = new RWHtmlTable("1000", "0");
        RWHtmlTable fHtmTb = new RWHtmlTable("220", "0");

        htmTb.setCellSpacing("3");
        StringBuffer thisPage = new StringBuffer();
       
        htmTb.replaceNewLineChar(false);
        fHtmTb.replaceNewLineChar(false);

        //table for heading
        RWHtmlTable tHtmlTb = new RWHtmlTable("100%", "0");

        thisPage.append("<div align=\"center\" style=\"width: 100%; height: 100%;\">\n");
        thisPage.append(InfoBubble.getBubble("roundrect", "visitHeaderBubble", "990", "20", "#cccccc", getVisitHeaderCell()));

//        thisPage.append(tHtmlTb.startTable());
//        tHtmlTb.setWidth("100%");
//        thisPage.append(tHtmlTb.startRow() );

        //display the visit date and type as a header
//        thisPage.append(htmTb.addCell(getVisitHeaderCell()));

//        tHtmlTb.setWidth("233");

//        thisPage.append(htmTb.endRow());
//        thisPage.append(tHtmlTb.endTable());

        thisPage.append(htmTb.startTable());
        thisPage.append(htmTb.startRow("height=650 style='text-valign: top;'"));
        thisPage.append(htmTb.addCell(getLeftPane()));
        thisPage.append(htmTb.addCell(getCenterPane()));
        thisPage.append(htmTb.endRow());
        thisPage.append(htmTb.endTable());

        return thisPage.toString();
    }
        
    private String getLeftPane() throws Exception {
        RWHtmlTable htmTb = new RWHtmlTable("220","0");
        RWHtmlTable fHtmTb = new RWHtmlTable("220", "0");
        StringBuffer thisPage = new StringBuffer();
        StringBuffer patientInfo = new StringBuffer();
        
        htmTb.replaceNewLineChar(false);
        fHtmTb.replaceNewLineChar(false);
        
        patientInfo.append(htmTb.startTable("220"));
        patientInfo.append(htmTb.startRow("height=135"));
        htmTb.setCellVAlign("middle");
        patientInfo.append(htmTb.addCell(_patient.getVisitBar(), htmTb.LEFT, "width=20"));
        htmTb.setCellVAlign("top");
        patientInfo.append(htmTb.addCell(_patient.getMiniContactInfo(htmTb, visitFontSize)));
        patientInfo.append(htmTb.endRow());
        patientInfo.append(htmTb.endTable());
              
        //added for the Visit Bar
        thisPage.append(htmTb.startTable("220"));
        thisPage.append(htmTb.startRow("height=145 style='text-valign: top;'"));
//        thisPage.append(htmTb.addCell(fHtmTb.getFrame(htmTb.BOTH, "", "silver", 1,patientInfo.toString())));
        thisPage.append(htmTb.addCell(InfoBubble.getBubble("roundrect", "patientinfobubble", "222", "137", "silver", patientInfo.toString())));
        thisPage.append(htmTb.endRow());

        //added for the Diagnosis
        fHtmTb.setWidth("220");
        thisPage.append(htmTb.startRow("height=85 style='text-valign: top;'"));
//        thisPage.append(htmTb.addCell(fHtmTb.getFrame(RWHtmlTable.BOTH, "", "silver", 1,_visit.getSymptoms())));
        thisPage.append(htmTb.addCell(InfoBubble.getBubble("roundrect", "patientsymptomsbubble", "222", "77", "silver",_visit.getSymptoms())));
        thisPage.append(htmTb.endRow());

//        //added for the Patient Condition
        fHtmTb.setWidth("220");
        thisPage.append(htmTb.startRow("height=155 style='text-valign: top;'"));
//        thisPage.append(htmTb.addCell(fHtmTb.getFrame(htmTb.BOTH, "", "silver", 1,_visit.getCondition())));
        thisPage.append(htmTb.addCell(InfoBubble.getBubble("roundrect", "patientconditionbubble", "222", "147", "silver",_visit.getCondition())));
        thisPage.append(htmTb.endRow());

        //added for the Patient Conditions
        fHtmTb.setWidth("220");
        thisPage.append(htmTb.startRow("height=100 style='text-valign: top;'"));
//        thisPage.append(htmTb.addCell(fHtmTb.getFrame(htmTb.BOTH, "", "silver", 1,_visit.getConditions())));
        thisPage.append(htmTb.addCell(InfoBubble.getBubble("roundrect", "patientconditionsbubble", "222", "92", "silver",_visit.getConditions())));
        thisPage.append(htmTb.endRow());

        //added for the X-Ray Findings
        fHtmTb.setWidth("220");
        thisPage.append(htmTb.startRow("height=87 style='text-valign: top;'"));
//        thisPage.append(htmTb.addCell(fHtmTb.getFrame(htmTb.BOTH, "", "silver", 1,_patient.getXrayFindings(visitFontSize))));
        thisPage.append(htmTb.addCell(InfoBubble.getBubble("roundrect", "patientfindingsbubble", "222", "79", "silver",_patient.getXrayFindings(visitFontSize))));
        thisPage.append(htmTb.endRow());

        //added for the Problems
        fHtmTb.setWidth("220");
        thisPage.append(htmTb.startRow("height=87 style='text-valign: top;'"));
//        thisPage.append(htmTb.addCell(fHtmTb.getFrame(htmTb.BOTH, "", "silver", 1,_patient.getPatientProblems(visitFontSize))));
        thisPage.append(htmTb.addCell(InfoBubble.getBubble("roundrect", "patientproblemsbubble", "222", "79", "silver",_patient.getPatientProblems(visitFontSize))));
        thisPage.append(htmTb.endRow());
        
        thisPage.append(htmTb.endTable());

        thisPage.append("</div>\n");
        
        return thisPage.toString();
    }

    public String getCenterPane() throws Exception {
        RWHtmlTable htmTb = new RWHtmlTable("300", "0");
        RWHtmlTable fHtmTb = new RWHtmlTable("500", "0");
        StringBuffer thisPage = new StringBuffer();

        htmTb.replaceNewLineChar(false);
        fHtmTb.replaceNewLineChar(false);
        
//        thisPage.append(htmTb.startTable("500"));
        thisPage.append(htmTb.startTable("505"));
        thisPage.append(htmTb.startRow("height=55"));
//        thisPage.append(htmTb.addCell(fHtmTb.getFrame(htmTb.BOTH, "", "silver", 1, getIndicators())));
        thisPage.append(htmTb.addCell(InfoBubble.getBubble("roundrect", "patientindicatorsbubble", "504", "47", InfoBubble.CENTER, "silver", getIndicators())));
        fHtmTb.setWidth("125");
//        thisPage.append(htmTb.addCell("", "width=3"));
//        thisPage.append(htmTb.addCell(fHtmTb.getFrame(htmTb.BOTH, "", "silver", 1, getItems()),"rowspan=4 width=120"));
        thisPage.append(htmTb.addCell(InfoBubble.getBubble("roundrect", "itemssbubble", "116", "392", "silver", getItems()), htmTb.CENTER,"rowspan=4 width=125"));
//        thisPage.append(htmTb.addCell("", "width=3"));
//        thisPage.append(htmTb.addCell(fHtmTb.getFrame(htmTb.BOTH, "", "silver", 1, getNotes()),"rowspan=4 width=120"));
        thisPage.append(htmTb.addCell(InfoBubble.getBubble("roundrect", "notessbubble", "116", "392", "silver", getNotes()), htmTb.CENTER,"rowspan=4 width=125"));
        thisPage.append(htmTb.endRow());
        
        fHtmTb.setWidth("500");
        thisPage.append(htmTb.startRow("height=95"));
//        thisPage.append(htmTb.addCell(_visit.getProcedures(),"style=\"width: 500px; height: 90px;\" id=\"procedureList\""));
        thisPage.append(htmTb.addCell(InfoBubble.getBubble("roundrect", "proceduresbubble", "504", "87", "silver","<div id=\"procedureList\">" + _visit.getProcedures() + "</div>")));
        thisPage.append(htmTb.endRow());
        
        thisPage.append(htmTb.startRow("height=80"));
//        thisPage.append(htmTb.addCell(fHtmTb.getFrame(htmTb.BOTH, "", "silver", 1, _visit.getAttention(visitFontSize))));
        thisPage.append(htmTb.addCell(InfoBubble.getBubble("roundrect", "attentionbubble", "504", "72", "silver", _visit.getAttention(visitFontSize))));
        thisPage.append(htmTb.endRow());
        
        thisPage.append(htmTb.startRow("height=170"));
//        thisPage.append(htmTb.addCell(_visit.getSOAPNotes(),"stype=\"width: 500px;\" id=\"noteList\""));
        thisPage.append(htmTb.addCell(InfoBubble.getBubble("roundrect", "soapnotesbubble", "504", "162", "silver","<div id=\"noteList\">" + _visit.getSOAPNotes()) + "</div>"));
        thisPage.append(htmTb.endRow());

//        thisPage.append(htmTb.startRow("height=3"));
//        thisPage.append(htmTb.addCell("","colspan=5"));
//        thisPage.append(htmTb.endRow());

        fHtmTb.setWidth("755");
        thisPage.append(htmTb.startRow());
//        thisPage.append(htmTb.addCell(fHtmTb.getFrame(htmTb.BOTH, "", "silver", 1, getImages()),"colspan=5"));
        thisPage.append(htmTb.addCell(InfoBubble.getBubble("roundrect", "imagesbubble", "755", "250", "silver", getImages()),"colspan=3"));  // MAKE SURE TO CHANGE THE COLSPAN
        thisPage.append(htmTb.endRow());

        return thisPage.toString();
    }
    
    //-----------------------------------------------------------------------------------
    /** inserts a charge */
    //-----------------------------------------------------------------------------------
    public void insertCharge(HttpServletRequest request, RWConnMgr io, int itemId, Visit visit, Patient patient) throws Exception 
    {
        StringBuffer noteText = new StringBuffer();
        ResultSet lRs = io.opnRS("select * from items where id = " + itemId);
        lRs.next();
        if (!lRs.getString("comment").equals("") && lRs.getBoolean("writecomment")) {
            Comment newComment = new Comment(io, "0");
            newComment.setDate(Calendar.getInstance());
            newComment.setPatientId(patient.getId());
            newComment.setVisitId(visit.getId());
            newComment.setComment(lRs.getString("comment"));
            newComment.update();
            insertNote(lRs.getString("comment"));
        }
        
        if(!lRs.getBoolean("itemgroup")) {
            try {
            Charge thisCharge = new Charge(io, "0");
            thisCharge.setVisitId(visit.getId());
            thisCharge.setItemId(itemId);
            thisCharge.setResourceId(this.resourceId);
            thisCharge.setChargeAmount(lRs.getBigDecimal("amount"));
            thisCharge.setQuantity(lRs.getBigDecimal("units"));
            thisCharge.update();
            } catch (Exception e) {
                System.out.println("VisitActivity-"+e.getMessage());
            }
        } else {
            ResultSet groupRs=io.opnRS("select * from itemgroup where groupid=" + itemId);
            while(groupRs.next()) {
                ResultSet giRs=io.opnRS("select * from items where id=" + groupRs.getInt("itemid"));
                if(giRs.next()) {
                    Charge thisCharge = new Charge(io, "0");
                    thisCharge.setVisitId(visit.getId());
                    thisCharge.setItemId(groupRs.getInt("itemid"));
                    thisCharge.setResourceId(this.resourceId);
                    thisCharge.setChargeAmount(giRs.getBigDecimal("amount"));
                    thisCharge.setQuantity(giRs.getBigDecimal("units"));
                    thisCharge.update();
                }
                giRs.close();
                giRs=null;
            }
            groupRs.close();
            groupRs=null;
        }

     // Roll through the checked items and append to the doctor note.
        Enumeration parms = request.getParameterNames();
        String name;
        String value;
        boolean oneWasAdded=false;

        if (!lRs.getString("comment").equals("") && !lRs.getBoolean("writecomment")) { noteText.append(lRs.getString("comment")); }

        while (parms.hasMoreElements()) {
            name=(String)parms.nextElement();
            value=request.getParameter(name);
            if (name.substring(0,3).equals("si_") && (value.toLowerCase().equals("true") || value.equals("1"))) {
                lRs = io.opnRS("select * from subitems where id = " + name.substring(3));
                if (lRs.next()) {
                    if (oneWasAdded) {
                        noteText.append(", ");
                    }
                    noteText.append(lRs.getString("subitem"));
                    oneWasAdded=true;
                }
            }
        }
        if (oneWasAdded) {
            noteText.append(".");
            insertNote(noteText.toString());
        }

//        while (parms.hasMoreElements()) {
//            name=(String)parms.nextElement();
//            if (name.substring(0,3).equals("si_") && name.endsWith("_cb")) {
//                lRs = io.opnRS("select * from subitems where id = " + name.substring(3, name.indexOf("_cb")));
//                if (lRs.next()) {
//                    if (oneWasAdded) {
//                        noteText.append(", ");
//                    }
//                    noteText.append(lRs.getString("subitem"));
//                    oneWasAdded=true;
//                }
//            }
//        }
//        if (oneWasAdded) {
//            noteText.append(".");
//            insertNote(noteText.toString());
//        }

    }


    //-----------------------------------------------------------------------------------
    /** inserts a charge */
    //-----------------------------------------------------------------------------------
    public void insertCharge(HttpServletRequest request, RWConnMgr io, int itemId, Visit visit, Patient patient, String itemOrder) throws Exception
    {
        StringBuffer noteText = new StringBuffer();
        ResultSet lRs = io.opnRS("select * from items where id = " + itemId);
        lRs.next();
        if (!lRs.getString("comment").equals("") && lRs.getBoolean("writecomment")) {
            Comment newComment = new Comment(io, "0");
            newComment.setDate(Calendar.getInstance());
            newComment.setPatientId(patient.getId());
            newComment.setVisitId(visit.getId());
            newComment.setComment(lRs.getString("comment"));
            newComment.update();
            insertNote(lRs.getString("comment"));
        }

        if(!lRs.getBoolean("itemgroup")) {
            try {
            Charge thisCharge = new Charge(io, "0");
            thisCharge.setVisitId(visit.getId());
            thisCharge.setItemId(itemId);
            thisCharge.setResourceId(this.resourceId);
            thisCharge.setChargeAmount(lRs.getBigDecimal("amount"));
            thisCharge.setQuantity(lRs.getBigDecimal("units"));
            thisCharge.update();
            } catch (Exception e) {
                System.out.println("VisitActivity-"+e.getMessage());
            }
        } else {
            ResultSet groupRs=io.opnRS("select * from itemgroup where groupid=" + itemId);
            while(groupRs.next()) {
                ResultSet giRs=io.opnRS("select * from items where id=" + groupRs.getInt("itemid"));
                if(giRs.next()) {
                    Charge thisCharge = new Charge(io, "0");
                    thisCharge.setVisitId(visit.getId());
                    thisCharge.setItemId(groupRs.getInt("itemid"));
                    thisCharge.setResourceId(this.resourceId);
                    thisCharge.setChargeAmount(giRs.getBigDecimal("amount"));
                    thisCharge.setQuantity(giRs.getBigDecimal("units"));
                    thisCharge.update();
                }
                giRs.close();
                giRs=null;
            }
            groupRs.close();
            groupRs=null;
        }

     // Roll through the checked items and append to the doctor note.
        String name;
        String value;
        boolean oneWasAdded=false;

        if (!lRs.getString("comment").equals("") && !lRs.getBoolean("writecomment")) { noteText.append(lRs.getString("comment")); }

        if(itemOrder != null && !itemOrder.trim().equals("")) {
            itemOrder=itemOrder.substring(1);
            while (itemOrder.length()>0) {
                if(itemOrder.contains(",")) {
                    name=itemOrder.substring(0,itemOrder.indexOf(","));
                } else {
                    name=itemOrder;
                }
                value=request.getParameter(name);
                lRs = io.opnRS("select * from subitems where id = " + name.substring(3));
                if (lRs.next()) {
                    if (oneWasAdded) {
                        noteText.append(", ");
                    }
                    noteText.append(lRs.getString("subitem"));
                    oneWasAdded=true;
                }
                if(itemOrder.contains(",")) {
                    itemOrder=itemOrder.substring(itemOrder.indexOf(",")+1);
                } else {
                    itemOrder="";
                }
            }
        }
        if (oneWasAdded) {
            noteText.append(".");
            insertNote(noteText.toString());
        }

//        while (parms.hasMoreElements()) {
//            name=(String)parms.nextElement();
//            if (name.substring(0,3).equals("si_") && name.endsWith("_cb")) {
//                lRs = io.opnRS("select * from subitems where id = " + name.substring(3, name.indexOf("_cb")));
//                if (lRs.next()) {
//                    if (oneWasAdded) {
//                        noteText.append(", ");
//                    }
//                    noteText.append(lRs.getString("subitem"));
//                    oneWasAdded=true;
//                }
//            }
//        }
//        if (oneWasAdded) {
//            noteText.append(".");
//            insertNote(noteText.toString());
//        }

    }

    //-----------------------------------------------------------------------------------
    /** inserts a note */
    //-----------------------------------------------------------------------------------
    public void insertNote(HttpServletRequest request, RWConnMgr io, int noteId, Visit visit, Patient patient) throws Exception 
    {
        ResultSet lRs = io.opnRS("select * from doctornotes where visitid = " + visit.getId());
            String commentId = "0";
        if (lRs.next()) {
            commentId = lRs.getString("id");
        } 

        DoctorNote thisDoctorNote = new DoctorNote(io, commentId);
        String commentText = "";
        if (thisDoctorNote.next()) {
            commentText=thisDoctorNote.getString("note");
        }
        lRs = io.opnRS("select * from notetemplates where id = " + noteId);
        String noteText = "";
        if (lRs.next()) {
            noteText = lRs.getString("notetext");
        } else {
            noteText = "NOTE TEXT NOT DEFINED";
        }
// 2007-07-14       thisDoctorNote.setNoteDate(Calendar.getInstance());
        thisDoctorNote.setNoteDate(visit.getVisitDate());
        thisDoctorNote.setPatientId(patient.getId());
        thisDoctorNote.setVisitId(visit.getId());

        StringBuffer finalNoteText = new StringBuffer();
        if (commentText.equals("")) {
            finalNoteText.append(noteText);
        } else {
            finalNoteText.append(commentText + " " + noteText);
        }

        // Roll through the checked items and append to the doctor note.
        Enumeration parms = request.getParameterNames();
        String name;
        String value;
        boolean oneWasAdded=false;
        while (parms.hasMoreElements()) {
            name=(String)parms.nextElement();
            value=request.getParameter(name);
            if (name.substring(0,3).equals("si_") && value.toLowerCase().equals("true")) {
                lRs = io.opnRS("select * from subitems where id = " + name.substring(3));
                if (lRs.next()) {
                    if (oneWasAdded) {
                        finalNoteText.append(", ");
                    }
                    finalNoteText.append(lRs.getString("subitem"));
                    oneWasAdded=true;
                }
            }
        }
        if (oneWasAdded) {
            finalNoteText.append(".");
        }

//        Enumeration parms = request.getParameterNames();
//        String name;
//        boolean oneWasAdded=false;
//        while (parms.hasMoreElements()) {
//            name=(String)parms.nextElement();
//            if (name.substring(0,3).equals("si_") && name.endsWith("_cb")) {
//                lRs = io.opnRS("select * from subitems where id = " + name.substring(3, name.indexOf("_cb")));
//                if (lRs.next()) {
//                    if (oneWasAdded) {
//                        finalNoteText.append(", ");
//                    }
//                    finalNoteText.append(lRs.getString("subitem"));
//                    oneWasAdded=true;
//                }
//            }
//        }
//        if (oneWasAdded) {
//            finalNoteText.append(".");
//        }

        thisDoctorNote.setNote(finalNoteText.toString());
        thisDoctorNote.update();
    }

    //-----------------------------------------------------------------------------------
    /** inserts a note */
    //-----------------------------------------------------------------------------------
    public void insertNote(HttpServletRequest request, RWConnMgr io, int noteId, Visit visit, Patient patient, String itemOrder) throws Exception
    {
        ResultSet lRs = io.opnRS("select * from doctornotes where visitid = " + visit.getId());
            String commentId = "0";
        if (lRs.next()) {
            commentId = lRs.getString("id");
        }

        DoctorNote thisDoctorNote = new DoctorNote(io, commentId);
        String commentText = "";
        if (thisDoctorNote.next()) {
            commentText=thisDoctorNote.getString("note");
        }
        lRs = io.opnRS("select * from notetemplates where id = " + noteId);
        String noteText = "";
        if (lRs.next()) {
            noteText = lRs.getString("notetext");
        } else {
            noteText = "NOTE TEXT NOT DEFINED";
        }
// 2007-07-14       thisDoctorNote.setNoteDate(Calendar.getInstance());
        thisDoctorNote.setNoteDate(visit.getVisitDate());
        thisDoctorNote.setPatientId(patient.getId());
        thisDoctorNote.setVisitId(visit.getId());

        StringBuffer finalNoteText = new StringBuffer();
        if (commentText.equals("")) {
            finalNoteText.append(noteText);
        } else {
            finalNoteText.append(commentText + " " + noteText);
        }

     // Roll through the checked items and append to the doctor note.
        String name;
        String value;
        boolean oneWasAdded=false;

        if(itemOrder != null && !itemOrder.trim().equals("")) {
            itemOrder=itemOrder.substring(1);
            while (itemOrder.length()>0) {
                if(itemOrder.contains(",")) {
                    name=itemOrder.substring(0,itemOrder.indexOf(","));
                } else {
                    name=itemOrder;
                }
                value=request.getParameter(name);
                lRs = io.opnRS("select * from subitems where id = " + name.substring(3));
                if (lRs.next()) {
                    if (oneWasAdded) {
                        finalNoteText.append(", ");
                    }
                    finalNoteText.append(lRs.getString("subitem"));
                    oneWasAdded=true;
                }
                if(itemOrder.contains(",")) {
                    itemOrder=itemOrder.substring(itemOrder.indexOf(",")+1);
                } else {
                    itemOrder="";
                }
            }
        }
        if (oneWasAdded) {
            finalNoteText.append(".");
//            insertNote(finalNoteText.toString());
        }

        thisDoctorNote.setNote(finalNoteText.toString());
        thisDoctorNote.update();
    }

    //-----------------------------------------------------------------------------------
    /** inserts a note for a patient */
    //-----------------------------------------------------------------------------------
    private void insertNote(int noteId) throws Exception 
    {
        ResultSet lRs = io.opnRS("select * from doctornotes where visitid = " + _visit.getId());
        String commentId = "0";
    
        if (lRs.next()) 
        {
            commentId = lRs.getString("id");
        } 

        DoctorNote thisDoctorNote = new DoctorNote(_newIo, commentId);
        String commentText = "";
        if (thisDoctorNote.next()) 
        {
            commentText = thisDoctorNote.getString("note");
        }

        lRs = _newIo.opnRS("select * from notetemplates where id = " + noteId);
        String noteText = "";

        if (lRs.next()) 
        {
            noteText = lRs.getString("notetext");
        } 
        else 
        {
            noteText = "NOTE TEXT NOT DEFINED";
        }
// 2007-10-23       thisDoctorNote.setNoteDate(Calendar.getInstance());
        thisDoctorNote.setNoteDate(_visit.getDate("date"));
        thisDoctorNote.setPatientId(_patient.getId());
        thisDoctorNote.setVisitId(_visit.getId());
        if (commentText.equals("")) {
            thisDoctorNote.setNote(noteText);
        } 
        else 
        {
            thisDoctorNote.setNote(commentText + " " + noteText);
        }
        thisDoctorNote.update();
    }

    
    //-----------------------------------------------------------------------------------
    /** inserts a note for a patient */
    //-----------------------------------------------------------------------------------
    private void insertNote(String noteText) throws Exception 
    {
        ResultSet lRs = _newIo.opnRS("select * from doctornotes where visitid = " + _visit.getId());
        String commentId = "0";
        String commentText = "";
    
        if (lRs.next()) {
            commentId = lRs.getString("id");
        } 

        DoctorNote thisDoctorNote = new DoctorNote(_newIo, commentId);
        if (thisDoctorNote.next()) {
            commentText = thisDoctorNote.getString("note");
        }

// 2007-10-24       thisDoctorNote.setNoteDate(Calendar.getInstance());
        try {
//            thisDoctorNote.setNoteDate(_visit.getDate("date"));
            thisDoctorNote.setNoteDate(_visit.getVisitDate());
            thisDoctorNote.setPatientId(_patient.getId());
            thisDoctorNote.setVisitId(_visit.getId());
            if (commentText.equals("")) {
                thisDoctorNote.setNote(noteText);
            } else {
                thisDoctorNote.setNote(commentText + " " + noteText);
            }
            thisDoctorNote.update();
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
    }

    
    //-----------------------------------------------------------------------------------
    /** insert a charge */
    //-----------------------------------------------------------------------------------
    private void insertCharge(int itemId) throws Exception 
    {
        ResultSet lRs = _newIo.opnRS("select * from items where id = " + itemId);
        lRs.next();
        //RKW 12/10/08 - Added writecomment field to indicate weather the item comments are to be written to the comments table
        if (!lRs.getString("comment").equals("") && lRs.getBoolean("writecomment")) {
            Comment newComment = new Comment(io, "0");
            newComment.setDate(Calendar.getInstance());
            newComment.setPatientId(_visit.getInt("patientid"));
            newComment.setVisitId(_visit.getId());
            newComment.setComment(lRs.getString("comment"));
            newComment.update();
            insertNote(lRs.getString("comment"));
        }
        Charge thisCharge = new Charge(_newIo, "0");
        thisCharge.setVisitId(_visit.getId());
        thisCharge.setItemId(itemId);
        thisCharge.setResourceId(this.resourceId);
        thisCharge.setChargeAmount(lRs.getBigDecimal("amount"));
        thisCharge.setQuantity(lRs.getBigDecimal("units"));
        thisCharge.update();
    }


    //-----------------------------------------------------------------------------------
    /** constructs the row for the images for a patient */
    //-----------------------------------------------------------------------------------
    private String getImages() throws Exception 
    {
        StringBuffer xr   = new StringBuffer();
        int id            = _patient.getId();
        RWHtmlTable htmTb = new RWHtmlTable("640", "0");
        htmTb.replaceNewLineChar(false);

        _patient.refresh();

        htmTb.setWidth("740");

        xr.append("<div id=\"imagesBubble\" style=\" height: 245; width:760; overflow: auto;\">");
        xr.append(htmTb.startTable());
        xr.append(htmTb.startRow());

        ResultSet lRs = _newIo.opnRS("Select * from patientdocuments where patientId=" + id + " and documentType=1 and identifierid=1 order by seq");
        while (lRs.next()) {
            xr.append(htmTb.addCell(getImage(htmTb, lRs.getString("documentpath"), lRs.getString("description"), lRs.getInt("id")), htmTb.CENTER, "width=200"));
        }
        lRs.close();

//        xr.append(htmTb.addCell(getImage(htmTb, id, 1, 1), htmTb.CENTER, "width=200"));
//        xr.append(htmTb.addCell(getImage(htmTb, id, 1, 2), htmTb.CENTER, "width=200"));
//        xr.append(htmTb.addCell(getImage(htmTb, id, 1, 3), htmTb.CENTER, "width=200"));
//        xr.append(htmTb.addCell(getImage(htmTb, id, 1, 4), htmTb.CENTER, "width=200"));

        xr.append(htmTb.endRow());
        xr.append(htmTb.endTable());
        xr.append("</div>");


        return xr.toString();
    }

    
    //-----------------------------------------------------------------------------------
    /** gets specific image for a patient */
    //-----------------------------------------------------------------------------------
    public String getImage(RWHtmlTable htmTb, String documentPath, String description, int id) throws Exception {
        String imagePath = "images/no_photo.jpg";
        String imageDescription = "No Photo";
        String onClickOption = "";
        StringBuffer img = new StringBuffer();

// RKW Images not displaying on the visit activity screen
//        if(!documentPath.equals("")) {
//            imagePath        = documentPath.replaceAll("\\\\", "/");
//            imagePath        = "/medicaldocs" + imagePath.substring(imagePath.lastIndexOf("/medical/") + "/medical".length());
//            imageDescription = description;
//            onClickOption    = "onClick=displayImage('" + id + "') style='cursor: pointer;'";
//        }
        if(!documentPath.equals("")) {
            imagePath        = documentPath.replaceAll("\\\\", "/");
            if(imagePath.substring(0,2).equals("//") || imagePath.substring(0,2).toUpperCase().equals("C:")) { 
                imagePath=imagePath.substring(imagePath.indexOf("/medical"));
            }
            if(imagePath.indexOf("/medical/") > -1  && imagePath.indexOf("/medicaldocs/") == -1) { imagePath = "/medicaldocs" + imagePath.substring(imagePath.lastIndexOf("/medical/") + "/medical".length()); }
            imageDescription = description;
            onClickOption    = "onClick=displayImage('" + id + "') style='cursor: pointer;'";
        }

        htmTb.setWidth("100%");
        img.append(htmTb.startTable());
        img.append(htmTb.startRow());
        img.append(htmTb.addCell("<image src=\"" + imagePath + "\" height=225 " + onClickOption + ">", htmTb.CENTER));
        img.append(htmTb.endRow());
        img.append(htmTb.endTable());

        return img.toString();
    }   

    private String getImage(RWHtmlTable htmTb, int patientId, int documentType, int identifierId) throws Exception 
    {
        String imagePath = "images/no_photo.jpg";
        String imageDescription = "No Photo";
        String onClickOption = "";
        StringBuffer img = new StringBuffer();

        ResultSet lRs = _newIo.opnRS("Select * from patientdocuments where patientId=" + _patient.getId() + " and documentType=" + documentType + " and identifierid=" + identifierId);

        if(lRs.next()) {
            imagePath        = lRs.getString("documentpath");
            imageDescription = lRs.getString("description");
            onClickOption    = "onClick=displayImage('" + lRs.getString("id") + "') style='cursor: pointer;'";
        }

        lRs.close();

        img.append(htmTb.startTable());
        img.append(htmTb.startRow());
        img.append(htmTb.addCell("<image src=" + imagePath + " height=280 " + onClickOption + ">", htmTb.CENTER));
        img.append(htmTb.endRow());
        img.append(htmTb.endTable());

        return img.toString();
    }
    
    
    //-----------------------------------------------------------------------------------
    /** gets items */
    //-----------------------------------------------------------------------------------
    private String getItems() throws Exception 
    {

        StringBuffer items   = new StringBuffer();
        String onClick       = "";
        RWHtmlTable htmTb = new RWHtmlTable("100%", "0");
        htmTb.replaceNewLineChar(false);
        ResultSet lRs = _newIo.opnRS("select id, buttontext, buttoncolor, buttontextcolor, subitemtype, comment, keypad from items where showitem order by sequence desc");
        RWHtmlForm frm = new RWHtmlForm();

        htmTb.setWidth("100%");

        items.append(htmTb.startTable());

        items.append(htmTb.startRow());
        items.append(htmTb.addCell("Procedures", "class=pageHeading"));
        items.append(htmTb.endRow());
        items.append(htmTb.endTable());

//        items.append("<div style=\"width: 125; height: 365; overflow: auto;\">");
        items.append("<div style=\"width: 116; height: 365; overflow-y: auto; overflow-x: none;\">");
        items.append(htmTb.startTable("94%"));
        while (lRs.next()) {
            if (lRs.getInt("subitemtype")>0) {
//                onClick = "\"window.open('showsubitems.jsp?&itemId=" + lRs.getString("id") + "&subitemtypeid=" + lRs.getString("subitemtype") + "&visitId=" + _visit.getId() + "&pageHeader=" + lRs.getString("comment").replaceAll("'","\\\\u0027") + "','SubItems','width=600,height=500,scrollbars=no,left=50,top=20,')\"";
                onClick = "\"showSubItemsForProcedure(" + lRs.getString("id") + "," + lRs.getString("subitemtype") + "," + _visit.getId() + ",'" + lRs.getString("comment").replaceAll("'","\\\\u0027") + "')\"";
            } else {
//                onClick = "\"disableAllButtons(); window.location.href='" + _self + "?itemId=" + lRs.getString("id") + "'\"";
                onClick = "\"disableAllButtons(); addProcedure(" + lRs.getString("id") + "," + _visitId + ")\"";
            }
            items.append(htmTb.startRow());
            items.append(htmTb.addCell(frm.button(lRs.getString("buttontext").trim(), "id='" + lRs.getString("keypad") + "' style=\"font-size: 10; background: " 
                     + lRs.getString("buttoncolor").trim() + "; color:" + lRs.getString("buttontextcolor").trim()
                     + "; width: 94; \" onClick=" + onClick)));
            items.append(htmTb.endRow());
        }
//        items.append("</div>"); 
        items.append(htmTb.endTable());

        return items.toString();
    }

    
    //-----------------------------------------------------------------------------------
    /** gets Notes */
    //-----------------------------------------------------------------------------------
    private String getNotes() throws Exception 
    {
        String onClick="";
        StringBuffer items   = new StringBuffer();
        RWHtmlTable htmTb = new RWHtmlTable("100%", "0");
        htmTb.replaceNewLineChar(false);
        ResultSet lRs = _newIo.opnRS("select id, notetext, buttontext, buttoncolor, buttontextcolor, subitemtype, keypad from notetemplates where showitem order by sequence desc");
        RWHtmlForm frm = new RWHtmlForm();

        htmTb.setWidth("125");

        items.append(htmTb.startTable());

        items.append(htmTb.startRow());
        items.append(htmTb.addCell("SOAP", "align=center class=pageHeading"));
        items.append(htmTb.endRow());
        items.append(htmTb.endTable());

//        items.append("<div style=\"width: 125; height: 365; overflow: auto;\">");
        items.append("<div style=\"width: 116; height: 365; overflow-y: auto; overflow-x: none;\">");
        items.append(htmTb.startTable("94%"));
        while (lRs.next()) {
            if (lRs.getInt("subitemtype")>0) {
//                onClick = "\"window.open('showsubitems.jsp?&noteId=" + lRs.getString("id") + "&subitemtypeid=" + lRs.getString("subitemtype") + "&visitId=" + _visit.getId() + "&pageHeader=" + lRs.getString("notetext").replaceAll("'","\\\\u0027") + "','SubItems','width=600,height=500,scrollbars=no,left=50,top=20,')\"";
                onClick = "\"showSubItemsForNote(" + lRs.getString("id") + "," + lRs.getString("subitemtype") + "," + _visit.getId() + ",'" + lRs.getString("notetext").replaceAll("'","\\\\u0027") + "')\"";
            } else {
//                onClick = "\"disableAllButtons(); window.location.href='"+ _self + "?noteId=" + lRs.getString("id") + "'\"";
                onClick = "\"disableAllButtons(); addNote(" + lRs.getString("id") + ","+ _visitId + ")\"";
            }
            items.append(htmTb.startRow());
            items.append(htmTb.addCell(frm.button(lRs.getString("buttontext"), "id='" + lRs.getString("keypad") + "' style=\"font-size: 10; background: " 
                     + lRs.getString("buttoncolor").trim() + "; color: " + lRs.getString("buttontextcolor").trim() 
                     + "; width: 94; \" onClick=" + onClick)));
            items.append(htmTb.endRow());
        }
        items.append("</div>"); 
        items.append(htmTb.endTable());

        return items.toString();
    }

    
    //-----------------------------------------------------------------------------------
    /** gets the visit info */
    //-----------------------------------------------------------------------------------
    private String getVisitInfo() throws Exception
    {
        final String WALK_IN = "Walk In";
        final String spacer = "  on  ";
        String apptType = "";
        String apptDate = "";

        ResultSet lRs = _newIo.opnRS("SELECT * FROM visitsummary  WHERE id=" + _visitId);

        //walk in if there is appointment

        if(lRs.next()) 
        {
            apptType        = lRs.getString("type");
            apptDate        = lRs.getString("date");
        }

        lRs.close();

        if ((apptType == null) || (apptType.length() <= 0))
        {
            apptType = WALK_IN;
        }

        return "<b style='font-weight: normal; font-size: 14px'>" + apptType + spacer + apptDate + "</b> <img src=images/show-calendar.gif onClick=changeVisitDate(" + _visitId + ")>";
    }
    
    
    //-----------------------------------------------------------------------------------
    /** gets the patient indicators in read only mode */
    //-----------------------------------------------------------------------------------
    private String getIndicators() throws Exception
    {
        StringBuffer indicators=new StringBuffer();
        
        PatientIndicators pi = new PatientIndicators( _newIo, _patient.getId() );
        
        indicators.append("<div style='width: 245; height: 40'>");
        indicators.append(pi.getViewOnlyPatientIndicators());
        indicators.append(getNoteType());
        indicators.append(getTreatmentPlanInfo());
        indicators.append("</div>");

        return indicators.toString();
    }
    
    //-----------------------------------------------------------------------------------
    /** 08/29/07 - gets the patient note type in read only mode */
    //-----------------------------------------------------------------------------------
    private String getNoteType() throws Exception {
        String noteTypeInfo="";

        if(io == null) {
            io=_visit.io;
        }
        
        ResultSet noteRs=io.opnRS("select notetype from patients where id=" + _visit.getPatientId());
        if(noteRs.next()) {
            if(noteRs.getString("noteType") != null && !noteRs.getString("noteType").trim().equals("")) { noteTypeInfo="<b class=noteType>Note Type: " + noteRs.getString("noteType") + "</b>"; }
        }

        noteRs.close();

        return noteTypeInfo;
    }

    //-----------------------------------------------------------------------------------
    /** 08/29/07 - gets the patient treatment plan info */
    //-----------------------------------------------------------------------------------
    private String getTreatmentPlanInfo() throws Exception {
        PatientPlan patientPlan=new PatientPlan();
        patientPlan.setConnMgr(_visit.io);
//        patientPlan.setPatientId(_visit.getPatientId());
        
        return patientPlan.getSingleLineDetails(_visit.getPatientId(), _visit.getString("date"));
    }

    //-----------------------------------------------------------------------------------
    /** gets the DoctorNotes */
    //-----------------------------------------------------------------------------------
    private String getDoctorNotes() throws Exception
    {
        StringBuffer sy   = new StringBuffer();
        RWHtmlTable htmTb = new RWHtmlTable();
        RWInputForm frm   = new RWInputForm();

        ResultSet rs = _newIo.opnRS("select * from doctornotes where visitid=" + _visitId);

        sy.delete(0, sy.length());
        sy.append(htmTb.startTable("100%", "0"));
        String onClickLocationA = "onClick=window.open(\"doctornotes_d.jsp?id=";
        String onClickLocationB = "\",\"DoctorNotes\",\"width=500,height=225,left=150,top=200,toolbar=0,status=0\"); ";
        String linkClass = " style=\"cursor: pointer; color: #030089;\"";

        sy.append(htmTb.roundedTop(1,"","#030089","doctornotedivision"));

        // Display the heading
        sy.append(htmTb.startRow());
        sy.append(htmTb.headingCell("DoctorNotes", "style=\"cursor: pointer\" " + onClickLocationA + "0&patientid=" + _patient.getId() + onClickLocationB));
        sy.append(htmTb.endRow());
        
        //  End the table for the comments heading
        sy.append(htmTb.endTable());

        // Start a division for the doctor notes section
        sy.append("<div style=\"width: 100%; height: 75;  overflow: auto; text-align: left;\">\n");

        // List the doctor notes
        sy.append(htmTb.startTable("94%", "0"));

        while(rs.next()) 
        {
            String link = onClickLocationA + rs.getString("id") + onClickLocationB;
            sy.append(htmTb.startRow());
            sy.append(htmTb.addCell(rs.getString("note"), htmTb.LEFT, link + linkClass, ""));
            sy.append(htmTb.endRow());
        }
        sy.append(htmTb.endTable());
        
        // End the division
        sy.append("</div>\n");

        return sy.toString();
    }

    //-----------------------------------------------------------------------------------
    /** Sets the visit font size */
    //-----------------------------------------------------------------------------------
    public void setVisitFontSize(String newFontSize) throws Exception
    {
        visitFontSize = newFontSize;
    }
    
    //-----------------------------------------------------------------------------------
    /** Sets the visit resource id */
    //-----------------------------------------------------------------------------------
    public void setResourceId(int resourceId) throws Exception
    {
        this.resourceId = resourceId;
    }
    
    //-----------------------------------------------------------------------------------------
    /** Creates the table at the top of the page with appointment type and duplicate buttons */
    //-----------------------------------------------------------------------------------------
    public String getVisitHeaderCell() throws Exception  {
        StringBuffer headerCell=new StringBuffer();
        RWHtmlTable htmTb=new RWHtmlTable("100%", "0");
        RWHtmlForm frm= new RWHtmlForm();
        ResultSet rscRs = _newIo.opnRS("select id, name from resources");
        String[] preload={};
        
        headerCell.append(htmTb.startTable());
//        headerCell.append(htmTb.roundedTop(6, "", "silver", ""));
        headerCell.append(htmTb.startRow());
//        headerCell.append(htmTb.addCell("&nbsp;&nbsp;&nbsp;Doctor: " + frm.comboBox(rscRs,"currentresource","id",false,"1",null,""+resourceId,"onChange=\"window.location.href='?currentresource=' + this.value \" class=cBoxText")," width=233"));
        headerCell.append(htmTb.addCell("&nbsp;&nbsp;&nbsp;Doctor: " + frm.comboBox(rscRs,"currentresource","id",false,"1",null,""+resourceId,"onChange=\"changeResource(this.value," + _visit.getId() + ")\" class=cBoxText")," width=233"));
        headerCell.append(htmTb.addCell(getVisitInfo(), htmTb.CENTER, "width=300"));
        headerCell.append(htmTb.addCell("<input type=button value='payment' class=button onClick=getPayment(" + _visit.getId() + ")>", "width=100"));
        headerCell.append(htmTb.addCell("<input type=button value='duplicate' class=button onClick=duplicateVisit(" + _visit.getId() + ")>", "width=100"));
        headerCell.append(htmTb.addCell("<input type=button value='clear visit' class=button onClick=undoVisit(" + _visit.getId() + ")>", "width=100"));
        headerCell.append(htmTb.addCell("<input type=button value='  delete  ' class=button onClick=deleteVisit(" + _visit.getId() + ")>", "width=100"));
        headerCell.append(htmTb.addCell("<input type=button value='   done   ' class=button onClick=closeVisit()>", "width=100"));
        headerCell.append(htmTb.endRow());
//        headerCell.append(htmTb.roundedBottom(6, "", "silver", ""));
        headerCell.append(htmTb.endTable());
        
        return headerCell.toString();
    }

}
