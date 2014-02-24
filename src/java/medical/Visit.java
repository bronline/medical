/*
 * Comment.java
 *
 * Created on November 28, 2005, 11:46 AM
 *
 * To change this template, choose Tools | Options and locate the template under
 * the Source Creation and Management node. Right-click the template and choose
 * Open. You can then make changes to the template in the Source Editor.
 */

package medical;
import java.math.BigDecimal;
import tools.*;
import tools.utils.*;
import java.sql.*;

/**
 *
 * @author BR Online Solutions
 */
public class Visit extends MedicalResultSet {
    private String id;
    private int appointmentId=0;
    private int patientId=0; 
    private int locationId=0;
    private int conditionId=0;
    private Date date;
    private RWHtmlTable htmTb   = new RWHtmlTable("100%","0");
    private Timestamp timeStamp;
    private java.util.Date date1;
    private Appointment appointment;
    private Charge charge;
    private DoctorNote doctorNote;
    private PatientConditions condition;
    private Symptoms symptoms;
    
    /** Creates a new instance of Visit */
    public Visit() {
        htmTb.replaceNLChar=false;
    }

    public Visit(RWConnMgr io, String ID) throws Exception {
        setConnMgr(io);
        setAppointment();
        setId(ID);
        htmTb.replaceNLChar=false;
    }

    public Visit(RWConnMgr io, int intId) throws Exception {
        setConnMgr(io);
        setAppointment();
        setId(intId);
        htmTb.replaceNLChar=false;
    }

    public void setId(int newId) throws Exception {
        setId("" + newId);
    }
    
    public void setId(String newId) throws Exception {
        id = newId;
//        if(io.getConnection() == null || io.getConnection().isClosed()) { io.opnmySqlConn(); }
//        PreparedStatement lPs=io.getConnection().prepareStatement("select * from visits where id=" + id);
//        setResultSet(lPs.executeQuery());
        setResultSet(io.opnRS("select * from visits where id=" + id));
        refresh();
    }

    public void setAppointment() throws Exception {
        if(appointment == null) {
            appointment = new Appointment(io, appointmentId);
        } else {
            appointment.setId(appointmentId);
        }
    }
    
    public int getPatientId() {
        return patientId;
    }
    
    public String getInputForm(String patientId, String visitId) throws Exception {
    // Instantiate an RWInputForm and RWHtmlTable object
        RWInputForm frm = new RWInputForm(rs);
        RWHtmlTable htmTb = new RWHtmlTable ("650", "0");
        StringBuffer vf = new StringBuffer();

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
            String [] var       = { "patientid", "visitid" };
            String [] val       = { patientId, visitId };
            frm.setPreLoadFields(var);
            frm.setPreLoadValues(val);
        }

    // Get an input item with the record ID to set the rcd and ID fields
        frm.getInputItem("id");
        vf.append(frm.startForm());
        vf.append(htmTb.startTable());
        vf.append(frm.getInputItem("date"));
        vf.append(frm.getInputItem("comment"));
        vf.append(htmTb.endTable());
        vf.append(frm.updateButton());
        vf.append(frm.deleteButton());
        vf.append(frm.showHiddenFields());
        vf.append(frm.endForm());
        
        return vf.toString();
    }

    public int getId() {
        return Integer.parseInt(id);
    }

    public void setLastInsertedRow() throws Exception {
        ResultSet tmpRs  = io.opnRS("select LAST_INSERT_ID()");
        if(tmpRs.next()) {
            setId(tmpRs.getInt(1));
        }
        tmpRs.close();
    }
    
    public String getCharges() throws Exception {
        StringBuffer charges = new StringBuffer();
        charges.append(htmTb.startTable());
        charges.append(htmTb.startRow());
        charges.append(htmTb.addCell("Charges", "class=pageHeading"));
        charges.append(htmTb.endRow());
        charges.append(htmTb.endTable());
        
    // Create an RWFiltered List object to show the occupations
        RWFilteredList lst = new RWFilteredList(io);

    // Create an array with the column headings
        String [] columnHeadings = { "id",  "Procedure"};
        String myQuery = "select a.id, b.description, a.chargeamount from charges a join items b on a.itemid=b.id where visitid = " + id;

    // Set special attributes on the filtered list object
        lst.setTableBorder("0");
        lst.setCellPadding("1");
        lst.setCellSpacing("0");
        lst.setTableWidth("100%");
        lst.setAlternatingRowColors("white","lightgrey");
        lst.setUrlField(0);
        lst.setNumberOfColumnsForUrl(3);
        lst.setRowUrl("charges_d.jsp");
        lst.setOnClickAction("window.open");
        lst.setOnClickOption("\"" + "Charges" + "\",\"width=500,height=200,scrollbars=no,left=100,top=100,\"");
        lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
        lst.setShowRowUrl(true);
        lst.setShowComboBoxes(false);
        lst.setShowColumnHeadings(false);

    // Set specific column widths
        String [] cellWidths = {"0", "100", "100"};
        lst.setColumnWidth(cellWidths);

    // Show the list of charges
        charges.append("<div style=\"width: 400; height: 119; overflow: auto;\">" + lst.getHtml(myQuery, columnHeadings) + "</div>");
        
        return htmTb.getFrame(htmTb.BOTH, "","silver",0,charges.toString());
    }

    public String getAttention(String fontSize) throws Exception {
        String attnMsg="";
        StringBuffer attention = new StringBuffer();
        attention.append(htmTb.startTable("500"));
        attention.append(htmTb.startRow());
        attention.append(htmTb.addCell("Attention", "class=pageHeading"));
        attention.append(htmTb.endRow());
        attention.append(htmTb.endTable());
        
    // Show the attention message
        ResultSet lRs=io.opnRS("SELECT attentionMsg FROM patients where id=" + patientId);
        if (lRs.next()) {
            attnMsg=lRs.getString("attentionmsg");
            if (attnMsg==null) {
                attnMsg="";
            }
        } else {
            attnMsg="";
        }
        attention.append("<div style=\"font-size: " + fontSize + "; width: 400; height: 35; overflow: auto;\">" + attnMsg + "</div>");
        
        return htmTb.getFrame(htmTb.BOTH, "","silver",0,attention.toString());
    }

    public String getProcedures() throws Exception {
        StringBuffer charges = new StringBuffer();
        // Added 10-14-07 add a field to determine if the visit has charges
        int numCharges=0;

        charges.append(htmTb.startTable("500"));
        charges.append(htmTb.startRow());
        charges.append(htmTb.addCell("Procedures", "class=pageHeading"));
        charges.append(htmTb.endRow());
        charges.append(htmTb.endTable());
        
    // Create an RWFiltered List object to show the occupations
        RWFilteredList lst = new RWFilteredList(io);

    // Create an array with the column headings
        String [] columnHeadings = { "id",  "Item", "Charge"};
        String myQuery = "select a.id, b.description " +
                "from charges a " +
                "join items b on a.itemid=b.id " +
                "join environment e " +
                "where visitid = " + id + " and " +
                "1=case when e.displaycopay then" +
                "    1" +
                "  else" +
                "    case when not b.copayitem then 1 else 0 end" +
                "  end " +
                "order by a.id";
        
        // Added 10-14-07 to determine if the visit has charges
        ResultSet tmpRs=io.opnRS(myQuery);
        if(tmpRs.next()) { numCharges=1; }
        charges.append("<input type=\"hidden\" name=\"enableSpaceBar\" id=\"enableSpaceBar\" value=" + numCharges + ">");
        tmpRs.close();
        tmpRs=null;
            
    // Set special attributes on the filtered list object
        lst.setTableBorder("0");
        lst.setCellPadding("1");
        lst.setCellSpacing("0");
        lst.setTableWidth("475");
        lst.setAlternatingRowColors("white","lightgrey");
        lst.setUrlField(0);
        lst.setNumberOfColumnsForUrl(2);
//        lst.setRowUrl("charges_d.jsp");
//        lst.setOnClickAction("window.open");
//        lst.setOnClickOption("\"" + "Charges" + "\",\"width=500,height=200,scrollbars=no,left=100,top=100,\"");
//        lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
//        lst.setShowRowUrl(true);

        lst.setOnClickAction(1, "updateProcedure(##idColumn##,"+id+") style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");

        lst.setShowComboBoxes(false);
        lst.setShowColumnHeadings(false);

    // Set specific column widths
        String [] cellWidths = {"0", "200"};
        lst.setColumnWidth(cellWidths);

    // Show the list of charges
        charges.append("<div style=\"width: 500; height: 60; overflow-y: auto;\">" + lst.getHtml(myQuery, columnHeadings) + "</div>");

//        return htmTb.getFrame(htmTb.BOTH, "","silver",0,charges.toString());
        return charges.toString();
    }
    public String getComments() throws Exception {
        StringBuffer comments = new StringBuffer();
        comments.append(htmTb.startTable());
        comments.append(htmTb.startRow());
        comments.append(htmTb.addCell("Notes", "class=pageHeading"));
        comments.append(htmTb.endRow());
        comments.append(htmTb.endTable());
        
    // Create an RWFiltered List object to show the occupations
        RWFilteredList lst = new RWFilteredList(io);

    // Create an array with the column headings
        String [] columnHeadings = { "id",  "Comment"};
        String myQuery = "select id, comment from comments where visitid = " + id;

    // Set special attributes on the filtered list object
        lst.setTableBorder("0");
        lst.setCellPadding("1");
        lst.setCellSpacing("0");
        lst.setTableWidth("100%");
        lst.setAlternatingRowColors("white","lightgrey");
        lst.setUrlField(0);
        lst.setNumberOfColumnsForUrl(3);
        lst.setRowUrl("comments_d.jsp");
        lst.setShowRowUrl(true);
        lst.setOnClickAction("window.open");
        lst.setOnClickOption("\"" + "Comments" + "\",\"width=500,height=200,scrollbars=no,left=100,top=100,\"");
        lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
        lst.setShowComboBoxes(false);
        lst.setShowColumnHeadings(false);

    // Set specific column widths
        String [] cellWidths = {"0", "200"};
        lst.setColumnWidth(cellWidths);

    // Show the list of charges
        comments.append("<div style=\"width: 400; height: 90; overflow: auto;\">" + lst.getHtml(myQuery, columnHeadings) + "</div>");
        
        return htmTb.getFrame(htmTb.BOTH, "","silver",0,comments.toString());
    }

    public String getSOAPNotes() throws Exception {
        StringBuffer notes = new StringBuffer();

        notes.append(htmTb.startTable("500"));
        notes.append(htmTb.startRow());
        notes.append(htmTb.addCell("SOAP Notes", "class=pageHeading"));
        notes.append(htmTb.addCell("view previous",htmTb.RIGHT,"class=\"pageHeading\" style=\"cursor: pointer; font-size: 10px; text-decoration: underline;\" onClick=\"showItemInFixedPos(event,'getdoctornotes.jsp',0," + patientId + ",txtHint,100,100)\""));
        notes.append(htmTb.endRow());
        notes.append(htmTb.endTable());
        
    // Create an RWFiltered List object to show the occupations
        RWFilteredList lst = new RWFilteredList(io);

    // Create an array with the column headings
        String [] columnHeadings = { "id",  "Note"};
        String myQuery = "select id, note from doctornotes where visitid = " + id;

    // Set special attributes on the filtered list object
        lst.setTableBorder("0");
        lst.setCellPadding("1");
        lst.setCellSpacing("0");
        lst.setTableWidth("480");
        lst.setAlternatingRowColors("white","lightgrey");
        lst.setUrlField(0);
        lst.setNumberOfColumnsForUrl(3);
//        lst.setRowUrl("doctornotes_d.jsp");
//        lst.setShowRowUrl(true);

//        lst.setOnClickAction("window.open");
//        lst.setOnClickOption("\"" + "Comments" + "\",\"width=800,height=400,scrollbars=no,left=100,top=100,\"");
//        lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");

        lst.setOnClickAction(1, "editSOAPNote(##idColumn##,"+id+") style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");

        lst.setShowComboBoxes(false);
        lst.setShowColumnHeadings(false);

    // Set specific column widths
        String [] cellWidths = {"0", "200"};
        lst.setColumnWidth(cellWidths);

    // Show the list of charges
        notes.append("<div style=\"width: 500; height: 135; overflow-y: auto;\">" + lst.getHtml(myQuery, columnHeadings) + "</div>");
        
//        return htmTb.getFrame(htmTb.BOTH, "","silver",0,notes.toString());
        return notes.toString();
    }

    public String getSymptoms() {
        try {
            if(symptoms == null) { symptoms = new Symptoms(io); }
            return symptoms.getConditionSymptoms(getCurrentCondition());
        } catch (Exception e) {
            return "";
        }
    }
    
    public String getCondition() throws Exception {
        StringBuffer pc=new StringBuffer();
        
        pc.append("<div id=patientConditionBubble style='width: 220; height: 140;'>");
        pc.append(htmTb.startTable("100%"));
        pc.append(htmTb.roundedTop(2,"","#030089",""));

    // Display the heading
        pc.append(htmTb.startRow());
        pc.append(htmTb.headingCell("Current Condition", "onMouseOver=this.style.cursor='pointer' onMouseOut=this.style.cursor='normal' onClick=showInputForm(event,'patientcondition.jsp',0," + this.patientId + ",txtHint)"));
        pc.append(htmTb.endRow());
        
        pc.append(htmTb.startCell(htmTb.LEFT));
        pc.append("<div id=patientCondition>" + getVisitCondition()+ "</div>");
        pc.append(htmTb.endCell());
        
        pc.append(htmTb.endTable());
        pc.append("</div>");
        return pc.toString();
    }
    
    public String getVisitCondition() throws Exception {
//        if(condition == null) { condition = new PatientConditions(this.io,this.conditionId); }
//        if(this.conditionId == 0) {
//            this.conditionId=condition.getCurrentCondition(""+this.patientId);
//        } else {
//            this.conditionId=checkConditionId();
//        }

        getCurrentCondition();

        condition.setEditMode(true);
        
        return condition.getCondition(this.getConditionId());

    }

    public int getCurrentCondition() throws Exception {
        if(condition == null) { condition = new PatientConditions(this.io,this.conditionId); }
        if(this.conditionId == 0) {
            this.conditionId=condition.getCurrentCondition(""+this.patientId);
        } else {
            this.conditionId=checkConditionId();
        }
        return this.conditionId;
    }

    public String getConditions() throws Exception {
        beforeFirst();
        if(condition == null) { condition=new PatientConditions(io,"0"); }
        if (!next() || id.equals("0")) {return "";}
        StringBuffer pc = new StringBuffer();
        condition.setEditMode(true);
        
        pc.append("<div id=previousConditions style='width: 220;'>");
        pc.append(htmTb.startTable("100%"));
        pc.append(htmTb.roundedTop(2,"","#030089","previosuconditions"));

    // Display the heading
        pc.append(htmTb.startRow());
        pc.append(htmTb.headingCell("Conditions"));
        pc.append(htmTb.endRow());
        
        pc.append(htmTb.startRow());
        pc.append(htmTb.addCell(condition.getConditionList(this.patientId)));
        pc.append(htmTb.endRow());
 
        pc.append(htmTb.endTable());
        pc.append("</div>");

        return pc.toString();       
    }

    public void setPatientId(int newPatientId) throws Exception {
        patientId = newPatientId;
    }
    
    public void setAppointmentId(int newAppointmentId) throws Exception {
        appointmentId = newAppointmentId;
    }
    
    public void setLocationId(int newLocationId) throws Exception {
        locationId = newLocationId;
    }
    
    public void setDate(Date newDate) throws Exception {
        date = newDate;
    }

    public void setTimestamp() throws Exception {
//        String currentDateString = new java.util.Date().toString(); 
//
//        long time1 = date1.parse(currentDateString);
//        timeStamp = new java.sql.Timestamp(time1);  
        timeStamp = new java.sql.Timestamp(System.currentTimeMillis());  
    }

    public void setResultSet(ResultSet newRs) throws Exception {
        super.setResultSet(newRs);
    }

    public void refresh() throws Exception {
        rs.beforeFirst();
        if (rs.next()) {
            id = rs.getString("id");
            appointmentId = rs.getInt("appointmentId");
            patientId = rs.getInt("patientId");
            date = rs.getDate("date");
            locationId = rs.getInt("locationId");
            conditionId = rs.getInt("conditionId");
            rs.beforeFirst();
        } else {
            id="0";
            appointmentId=0;
            patientId=0;
            locationId=0;
            conditionId=0;
        }
    }

    public void delete() throws Exception {
        rs.beforeFirst();
        if (rs.next()) {
            rs.deleteRow();
        }
    }

    public void update() throws Exception {
        setResultSet(io.opnUpdatableRS("select * from visits where id=" + id));
        rs.beforeFirst();
        setTimestamp();
        if (rs.next()) {
            rs.updateInt("appointmentid", appointmentId);
            rs.updateInt("patientid", patientId);
            rs.updateInt("locationid", locationId);
            rs.updateDate("date", date);
            rs.updateTimestamp("timein", timeStamp);
            rs.updateInt("conditionId", conditionId);
            rs.updateRow();
         } else {
            setDate(java.sql.Date.valueOf(Format.formatDate(new java.util.Date(), "yyyy-MM-dd")));
            moveToInsertRow();
            rs.updateInt("appointmentid", appointmentId);
            rs.updateInt("patientid", patientId);
            rs.updateInt("locationid", locationId);
            rs.updateDate("date", date);
            rs.updateTimestamp("timein", timeStamp);
            rs.updateInt("conditionId", conditionId);
            rs.insertRow();
            setLastInsertedRow();
        }
        checkForPatientCopay();
    }
    
    public void duplicateLastVisit(int visitId) throws Exception {
        ResultSet lRs=io.opnRS("SELECT * FROM visits where patientid=" + patientId + " and `date`<(select `date` from visits where id=" + visitId + ") order by `date` desc, timein desc");
        if(lRs.next()) {
//            if(lRs.next()) {
                duplicateVisitCharges(lRs.getInt("id"));
                duplicateVisitNotes(lRs.getInt("id"));
//            }
        }
        lRs.close();
    }
    
    public void duplicateVisitCharges(int visitId) throws Exception {
        if(charge == null) { charge=new Charge(io, "0"); }
        
        ResultSet cRs=io.opnRS("select * from charges where chargeamount>0 and visitid=" + visitId + " order by id");
        while(cRs.next()) {
            charge.setId(0);
            charge.setVisitId(Integer.parseInt(id));
            charge.setItemId(cRs.getInt("itemid"));
            charge.setResourceId(cRs.getInt("resourceId"));
            charge.setChargeAmount(cRs.getBigDecimal("chargeamount"));
            charge.setCopayAmount(cRs.getBigDecimal("copayamount"));
            charge.setQuantity(cRs.getBigDecimal("quantity"));
            charge.update();
        }
        cRs.close();
    }
    
    public void duplicateVisitNotes(int visitId) throws Exception {
        if(doctorNote == null) { doctorNote=new DoctorNote(io, "0"); }
        
        ResultSet nRs=io.opnRS("select * from doctornotes where visitid=" + visitId);
        while(nRs.next()) {
            doctorNote.setId(0);
            doctorNote.setVisitId(Integer.parseInt(id));
            doctorNote.setPatientId(nRs.getInt("patientid"));
            doctorNote.setNoteDate(this.date);
            doctorNote.setNote(nRs.getString("note"));
            doctorNote.update();
        }
        nRs.close();
    }
        
    public void undoVisit(int visitId) throws Exception {
        undoVisitCharges(visitId);
        undoVisitNotes(visitId);
    }
    
    public void undoVisitCharges(int visitId) throws Exception {
        PreparedStatement lPs=io.getConnection().prepareStatement("delete from charges where visitid=" + visitId);
        PreparedStatement pPs=io.getConnection().prepareStatement("delete from payments where chargeid in (select id from charges where visitId=" + visitId + ")");
        PreparedStatement uPs=io.getConnection().prepareStatement("update payments set amount=amount + ? where id=?");
        
        String myQuery="select parentpayment, sum(amount) as amount from payments where chargeid in (select id from charges where visitid=" + this.id + ") and parentpayment<>0 group by parentpayment";
        ResultSet tempRs=io.opnRS(myQuery);
        while(tempRs.next()) {
            uPs.setDouble(1, tempRs.getDouble("amount"));
            uPs.setInt(2, tempRs.getInt("parentpayment"));
            uPs.executeUpdate();
        }
        tempRs.close();
        tempRs=null;

        pPs.execute();
        lPs.execute();
    }
    
    public void undoVisitNotes(int visitId) throws Exception {
        PreparedStatement lPs=io.getConnection().prepareStatement("delete from doctornotes where visitid=" + visitId);
        lPs.executeUpdate();        
    }

    public int getConditionId() {
        return conditionId;
    }

    public void setConditionId(int conditionId) {
        this.conditionId = conditionId;
    }

    private int checkConditionId() {
        int currentConditionId=0;
        try {
            ResultSet lRs=io.opnRS("select * from patientconditions where id=" + this.conditionId);
            if(lRs.next()) { currentConditionId=lRs.getInt("id"); }
            lRs.close();
            lRs=null;
        } catch (Exception e) {
        }
        
        return currentConditionId;
    }
    
    public String deleteVisit() throws Exception {
        StringBuffer errorMessages=new StringBuffer();
// RKW 08/24/2010 - Changed to delete payments associated with the visit
//        if(paymentsExist()) {
//           errorMessages.append("This visit can not be deleted.  Payments exist for charges associated with this visit.");
//        } else {
            deleteVisitCharges();
            deleteVisitNotes();
            PreparedStatement lPs=io.getConnection().prepareStatement("delete from visits where id=" + this.id);
            lPs.execute();
//        }
        
        return errorMessages.toString();
    }
    
    private boolean paymentsExist() {
        boolean exists=true;
        try {
            ResultSet tmpRs=io.opnRS("select * from payments where chargeid in (SELECT id FROM charges where visitid=" + this.id + ")");
            exists=tmpRs.next();
            tmpRs.close();
            tmpRs=null;
        } catch (Exception e) {
        }
        
        return exists;
    }
    
    private void deleteVisitCharges() {
        try {
            undoVisitCharges(Integer.parseInt(this.id));
        } catch (Exception deleteChargesException) {
            System.out.println(deleteChargesException.getMessage());
        }
    }
    
    private void deleteVisitNotes() {
        try {
            PreparedStatement lPs=io.getConnection().prepareStatement("delete from doctornotes where visitid=" + this.id);
            lPs.execute();
        } catch (Exception deleteNotesException) {
            System.out.println(deleteNotesException.getMessage());
        }        
    }
    
    public void checkForPatientCopay() {
        try {
            ResultSet itmRs=io.opnRS("select * from items where copayitem");
            if(itmRs.next()) {
                ResultSet visitRs=io.opnRS("select * from charges where itemId=" + itmRs.getInt("id") + " and visitId=" + Integer.parseInt(id));
                if(!visitRs.next()) {
                    String insuranceQuery="select * from patientinsurance as pi " +
                            "left join visits v on v.id=" + id + " " +
                            "left join patientconditions pc on pc.id=v.conditionid " +
                            "where" +
                            "  pi.providerid=case when pc.providerid<>0 THEN pc.providerid else case when pi.primaryprovider then pi.providerid else 0 end end" +
                            "  and copayamount<>0" +
                            "  and active" +
                            "  and not copayaspercent" +
                            "  and pi.patientId=" + this.getPatientId();
                    ResultSet insRs=io.opnRS(insuranceQuery);
//                    ResultSet insRs=io.opnRS("select * from patientinsurance where primaryprovider and copayamount<>0 and not copayaspercent and patientId=" + this.patientId);
                    if(insRs.next()) {
                        if(charge == null) { charge=new Charge(io, "0"); }
                        charge.setId(0);
                        charge.setVisitId(Integer.parseInt(id));
                        charge.setItemId(itmRs.getInt("id"));
                        charge.setResourceId(0);
                        charge.setChargeAmount(insRs.getBigDecimal("copayamount"));
                        charge.setCopayAmount(insRs.getBigDecimal("copayamount"));
                        charge.setQuantity(new BigDecimal("1"));
                        charge.update();
                    }
                    insRs.close();
                    insRs=null;
                }
                visitRs.close();
                visitRs=null;
            }
            itmRs.close();
            itmRs=null;
        } catch (Exception e) {
        }
    }

    public Date getVisitDate() {
        return this.date;
    }
}
