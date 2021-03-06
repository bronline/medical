/*
 * PatientPlan.java
 *
 * Created on November 28, 2005, 1:56 PM
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
public class PatientPlan extends MedicalResultSet {
    private RWHtmlTable htmTb           = new RWHtmlTable("400", "0");
    private int planId                  = 0;
    private int patientId               = 0;
    private String [] planInfo;
    private StringBuffer pln            = new StringBuffer();
    private StringBuffer ins            = new StringBuffer();
    private StringBuffer inpFrm         = new StringBuffer();
    private RWHtmlTable tbl             = new RWHtmlTable("275", "0");
    private RWInputForm frm             = new RWInputForm();

    private String visitDate;
    
    /** Creates a new instance of PatientPlan */
    public PatientPlan() {
    }
    
    public PatientPlan(RWConnMgr io, String newId) throws Exception {
        setConnMgr(io);
        setPlanId(newId);
    }
    
    public PatientPlan(RWConnMgr io, int newId) throws Exception {
        setConnMgr(io);
        setPlanId(newId);
    }
    
    public void setPlanId(int newId) throws Exception {
        planId = newId;
        ResultSet tmpRs=io.opnUpdatableRS("select * from patientplan where id=" + planId);
        setResultSet(tmpRs);
        if(planId != 0) { refresh(); }
        if(planId == 0) { clearValues(); }
    }

    public void setPlanId(String newId) throws Exception {
        setPlanId(Integer.parseInt(newId));
    }
    
    public void setPatientId(int newPatient) {
        patientId = newPatient;
    }
    
    public void refresh() throws Exception {
        beforeFirst();
        next();
        setPatientId(getInt("patientId"));
    }
    
    public void clearValues() {
        patientId = 0;
    }
    
    public int getPlanId() {
        return planId;
    }
    
    public String getInputForm(String patientId) throws Exception {
        inpFrm.delete(0, inpFrm.length());
        pln.delete(0, pln.length() );
        ins.delete(0, ins.length());
        
        beforeFirst();
       
        // Instantiate an RWInputForm and RWHtmlTable object
        RWInputForm frm = new RWInputForm(rs);

    // Set display attributes for the input form
        frm.setDftTextBoxSize("20");
        frm.setDftTextAreaCols("35");
        frm.setDisplayDeleteButton(true);
        frm.setShowDatePicker(true);
        frm.setLabelBold(true);
        frm.setUpdateButtonText("  save  ");
        frm.setDeleteButtonText("remove");

    // Set display attributes for the table
        tbl.replaceNewLineChar(false);

    // If adding a comment, Put the familyId and memberId on the form as hidden fields
        if(planId == 0) {
            String [] var       = { "patientid" };
            String [] val       = { patientId };
            frm.setPreLoadFields(var);
            frm.setPreLoadValues(val);
        }
        
        frm.getInputItem("id");
        
        inpFrm.append(frm.startForm());

    // Show the dates and number of visits associated with the plan
        planInfo = getPlanInfo();
        pln.append(tbl.startTable("325"));
        pln.append(frm.getInputItem("planid"));
        pln.append(frm.getInputItem("startdate"));
        pln.append(frm.getInputItem("enddate"));
        pln.append(frm.getInputItem("prepaidplan"));
        pln.append(frm.getInputItem("autowriteoff"));
        pln.append(frm.getInputItem("usevisits"));
        pln.append(frm.getInputItem("frequency"));
        pln.append(frm.getInputItem("visits", "onBlur=totalVisits()"));
        pln.append(frm.getInputItem("previousvisits", "onBlur=totalVisits()"));
        pln.append(htmTb.startRow());
        pln.append(htmTb.addCell("<b>Visits to date</b"));
        pln.append(htmTb.addCell(frm.textBox(planInfo[5], "visitsToDate", "10", "10", "class=tBoxText READONLY")));
        pln.append(htmTb.endRow());
        pln.append(htmTb.startRow());
        pln.append(htmTb.addCell("<b>Visits Remaining</b"));
        pln.append(htmTb.addCell(frm.textBox(planInfo[4], "visitsRemaining", "10", "10", "class=tBoxText READONLY")));
        pln.append(htmTb.endRow());
        pln.append(tbl.endTable());
        
    // Show the insurance information
        String totalAmount = "0.00";
        String remainingCovered = "0";
        String chargesToDate = "0.00";
        if(planId !=0) {
            totalAmount = Format.formatNumber(getFloat("patientportion") + getFloat("insuranceportion"), "#####0.00; (#####0.00)");
            remainingCovered = Format.formatNumber(getInt("visitsallowed") - Integer.parseInt(planInfo[5]), "#####0; (#####0)");
            chargesToDate = Format.formatNumber(getPlanChargesToDate(), "######0.00");
        }
        ins.append(tbl.startTable("325"));
        ins.append(frm.getInputItem("patientportion", "onBlur=totalCharges()"));
        ins.append(frm.getInputItem("insuranceportion", "onBlur=totalCharges()"));
        ins.append(htmTb.startRow());
        ins.append(htmTb.addCell("<b>Total Amount</b>"));
        ins.append(htmTb.addCell(frm.textBox(totalAmount, "totalAmount", "12", "12", "class=tBoxText READONLY")));
        ins.append(htmTb.endRow());
        ins.append(htmTb.addCell("<b>Charges-To-Date</b>"));
        ins.append(htmTb.addCell(frm.textBox(chargesToDate, "chargesToDate", "12", "12", "class=tBoxText READONLY")));
        ins.append(htmTb.endRow());
        ins.append(frm.getInputItem("visitsallowed", "onBlur=totalVisits()"));
        ins.append(htmTb.startRow());
        ins.append(htmTb.addCell("<b>Remaining Visits Covered</b>"));
        ins.append(htmTb.addCell(frm.textBox(remainingCovered, "remainingCovered", "10", "10", "class=tBoxText READONLY")));
        ins.append(htmTb.endRow());
        ins.append(frm.getInputItem("planoptions"));
        ins.append(tbl.endTable());
        
    // Add the plan and insurance information to the input form
        inpFrm.append(htmTb.startTable());
        inpFrm.append(htmTb.startRow());
        inpFrm.append(htmTb.startCell(htmTb.LEFT, "class=infoHeader"));
        inpFrm.append("Treatment Plan Details");
        inpFrm.append(tbl.getFrame("#cccccc", pln.toString()));
        inpFrm.append(htmTb.endCell());
        inpFrm.append(htmTb.startRow());
        inpFrm.append(htmTb.startCell(htmTb.LEFT, "class=infoHeader"));        
        inpFrm.append("Insurance Information");
        inpFrm.append(tbl.getFrame("#cccccc", ins.toString()));
        inpFrm.append(htmTb.endCell());
        inpFrm.append(htmTb.endRow());
        inpFrm.append(htmTb.endTable());
        
    // Add the buttons to the bottom of the form
        inpFrm.append(frm.updateButton());
        inpFrm.append(frm.deleteButton());
        inpFrm.append(frm.showHiddenFields());
        inpFrm.append(frm.endForm());
        
        return inpFrm.toString();
    }
    
    public String getBubbleInfo(int patient) throws Exception {
        StringBuffer sp=new StringBuffer();
        setVisitDate(Format.formatDate(new java.util.Date(), "yyyy-MM-dd"));
        
        ResultSet tmpRs=io.opnRS("select planid from patients where id=" + patient);
        if(tmpRs.next()) { 
            if(tmpRs.getInt("planid")!=0) {
                setPlanId(tmpRs.getInt("planid"));
                planInfo=getPlanInfo();

                planInfo[0]=getLastVisitDate();

                if(planInfo != null && planInfo[0] != null && !planInfo[0].equals("N/A")) {
                    sp.append(htmTb.startTable("100%"));
                    sp.append(htmTb.startRow());
                    sp.append(htmTb.addCell("<b>Treatment Plan Details</b>",htmTb.CENTER,"colspan=2"));
                    sp.append(htmTb.endRow());
                    sp.append(htmTb.startRow());
                    sp.append(htmTb.addCell("<b>Plan:</b>", "class=smallPlan width=60%"));
                    sp.append(htmTb.addCell(planInfo[1], "class=smallPlan width=40%"));
                    sp.append(htmTb.endRow());
                    sp.append(htmTb.startRow());
                    sp.append(htmTb.addCell("<b>Last visit: </b>", "class=smallPlan"));
                    sp.append(htmTb.addCell(Format.formatDate(planInfo[0], "MM/dd/yy"), "class=smallPlan"));
                    sp.append(htmTb.endRow());
                    sp.append(htmTb.startRow());
                    sp.append(htmTb.addCell("<b>Next Appt: </b>", "class=smallPlan"));
                    sp.append(htmTb.addCell(getNextAppointment(), "class=smallPlan"));
                    sp.append(htmTb.endRow());
                    sp.append(htmTb.startRow());
                    sp.append(htmTb.addCell("<b># Remaining: </b>", "class=smallPlan"));
                    sp.append(htmTb.addCell(planInfo[4], "class=smallPlan"));
                    sp.append(htmTb.endRow());
                    sp.append(htmTb.endTable());
                }

            }
        }
        tmpRs.close();

        return sp.toString();
        
    }
    
    public String getSingleLineDetails(int newPatient, String visitDate) throws Exception {
        StringBuffer sp=new StringBuffer();
        setVisitDate(visitDate);
        
//        if(planInfo == null) {
            ResultSet tmpRs=io.opnRS("select planid from patients where id=" + newPatient);
            if(tmpRs.next()) { 
                if(tmpRs.getInt("planid")!=0) {
                    setPlanId(tmpRs.getInt("planid"));
                    planInfo=getPlanInfo();

                    planInfo[0]=getLastVisitDate();
                    
                    if(planInfo != null && planInfo[0] != null && !planInfo[0].equals("N/A")) {
                        sp.append(htmTb.startTable("100%"));
                        sp.append(htmTb.startRow());
                        sp.append(htmTb.addCell("Plan:", "class=smallPlan width=10%"));
                        sp.append(htmTb.addCell(planInfo[1], "class=smallPlan width=30%"));
                        sp.append(htmTb.addCell("Last visit: " + Format.formatDate(planInfo[0], "MM/dd/yy"), "class=smallPlan width=30%"));
                        sp.append(htmTb.addCell("Remaining: " +planInfo[4], "class=smallPlan width=25%"));
                        sp.append(htmTb.endRow());
                        sp.append(htmTb.endTable());
                    }

                }
            }
            tmpRs.close();
//        }

        return sp.toString();
    }
    
    public String getSingleLineDetails() throws Exception {
        return getSingleLineDetails(patientId, Format.formatDate(new java.util.Date(), "yyyy-MM-dd"));
    }

    public String getMiniPlanDetails(int newPatient) throws Exception {
        setPatientId(newPatient);
        StringBuffer rp = new StringBuffer();
        String onClickLocation = "onClick=window.open(\"plan_d.jsp?patientid=" + patientId + "&planid=" + planId +
                              "\",\"Plan\",\"width=345,height=410,left=150,top=200,toolbar=0,status=0,\"); " +
                              " colspan=3 style=\"cursor: pointer\"";
        
        rp.append(htmTb.startTable("100%"));
        rp.append(htmTb.startRow());
        rp.append(htmTb.headingCell("Treatment Plan", onClickLocation));
        rp.append(htmTb.endRow());
        rp.append(htmTb.endTable());

    // Start a division for the symptoms section
        rp.append("<div style=\"width: 100%; height: 110;  overflow: auto; text-align: left;\">\n");
        beforeFirst();
        if(next()) {
        
            rp.append(htmTb.startTable("100%"));

            if(patientId !=0 && planId != 0) {
                String dedQuery="SELECT ifnull(case when (patientportion-sum(c.chargeamount))<0 then 0 else (patientportion-sum(c.chargeamount)) end,0) as remainingdeductable, " +
                        "ifnull(case when (insuranceportion-patientportion)-sum(c.chargeamount)<0 then 0 else (insuranceportion-patientportion)-sum(c.chargeamount) end,0) as remainingauth " +
                        "FROM patientplan p " +
                        "LEFT JOIN visits v on v.patientid=p.patientid " +
                        "LEFT JOIN charges c on c.visitid=v.id " +
                        "where p.patientid=" + patientId + " and (v.date>=p.startDate and v.date<p.enddate)";
                ResultSet dedRs=io.opnRS(dedQuery);
                
                
                String [] planInfo = getPlanInfo();
                rp.append(htmTb.startRow());
                rp.append(htmTb.addCell("<b>Last Visit</b>", "style=\"color: white\""));
                rp.append(htmTb.addCell(planInfo[0], "style=\"color: white\""));
                rp.append(htmTb.addCell("Remaining Visits: " + planInfo[4], "style=\"color: white\""));
                rp.append(htmTb.endRow());
                rp.append(htmTb.startRow());
                rp.append(htmTb.addCell("<b>Frequency:</b>", "style=\"color: white\""));
                rp.append(htmTb.addCell(frm.textBox(planInfo[1], "frequency", "25", "25","class=tBoxText READONLY"), "colspan=2"));
                rp.append(htmTb.endRow());
                rp.append(htmTb.startRow());
                rp.append(htmTb.addCell("<b>Start:</b>", "style=\"color: white\""));
                rp.append(htmTb.addCell(frm.textBox(Format.formatDate(planInfo[2], "MM/dd/yyyy"), "planstartdate", "10", "10","class=tBoxText READONLY"), "colspan=2"));
                rp.append(htmTb.endRow());
                rp.append(htmTb.startRow());
                rp.append(htmTb.addCell("<b>End:</b>", "style=\"color: white\""));
                rp.append(htmTb.addCell(frm.textBox(Format.formatDate(planInfo[3], "MM/dd/yyyy"), "planenddate", "10", "10","class=tBoxText READONLY"), "colspan=2"));
                rp.append(htmTb.endRow());
                
                if(dedRs.next()) {
                    rp.append(htmTb.startRow());
                    rp.append(htmTb.addCell("<b>Remaining Ded</b>", "style=\"color: white\""));
                    rp.append(htmTb.addCell(frm.textBox(Format.formatCurrency(dedRs.getDouble("remainingdeductable")), "deductable", "10", "10","class=tBoxText READONLY style='text-align: right;'"), "colspan=2"));
                    rp.append(htmTb.endRow());
                    
                    rp.append(htmTb.startRow());
                    rp.append(htmTb.addCell("<b>Remaining Auth</b>", "style=\"color: white\""));
                    rp.append(htmTb.addCell(frm.textBox(Format.formatCurrency(dedRs.getDouble("remainingauth")), "deductable", "10", "10","class=tBoxText READONLY style='text-align: right;'"), "colspan=2"));
                    rp.append(htmTb.endRow());
                    
                }
            }
            rp.append(htmTb.endTable());
        }
        rp.append("</div>");
        
        return rp.toString();
    }
    
    public void updatePlanDetails() throws Exception {
        boolean rowUpdated = false;
        if(rs.next()) {
            ResultSet pRs = io.opnRS("select * from plantypes where id=" + rs.getString("planid"));
            if(pRs.next()) {
                if(rs.getString("frequency").equals("")) { 
                    rs.updateString("frequency", pRs.getString("frequency"));
                    rowUpdated = true;
                }
                if(rs.getInt("visits") == 0) {
                    rs.updateInt("visits", pRs.getInt("visits"));
                    rowUpdated = true;
                }
            }
            pRs.close();
            if(rowUpdated) { rs.updateRow(); }
        }
    }
    
    public String [] getPlanInfo() throws Exception {
        String [] planInfo = { "N/A", "N/A", "N/A", "N/A", "N/A", "0" };

        int numVisits      = 0;
        if(planId !=0) {
            planInfo[1] = rs.getString("frequency");
            planInfo[2] = rs.getString("startdate");
            planInfo[3] = rs.getString("enddate");
            planInfo[4] = rs.getString("visits");
            
            ResultSet vRs = io.opnRS("select max(date) from visits where patientid=" + getInt("patientId"));
            if(vRs.next()) {
                planInfo[0] = Format.formatDate(vRs.getString(1), "MM/dd/yyyy");
            }
            
//            vRs = io.opnRS("select * from patientplanvisits where patientid=" + getInt("patientId"));
            ResultSet v1Rs = io.opnRS("select count(id) as visits from visits where patientid=" + getInt("patientId") + " and `date` between '" + rs.getString("startDate") + "' and '" + rs.getString("enddate") + "'");
            if(v1Rs.next()) {
                planInfo[5] = v1Rs.getString("visits");
                numVisits = getInt("visits") - v1Rs.getInt("visits") - getInt("previousvisits");
                planInfo[4] = "" + numVisits;
            }
            
            v1Rs.close();
            vRs.close();
        }
        return planInfo;
    }
    
    public double getPlanChargesToDate() throws Exception {
        double chargesToDate=0.0;
        if(planId != 0) {
            if(planInfo == null) { planInfo = getPlanInfo(); }
            ResultSet chgRs=io.opnRS("select ifnull(sum(chargeamount),0) from charges a join visits b on a.visitid=b.id where patientid=" + patientId + " and `date` between '" + planInfo[2] + "' and '" + planInfo[3] + "'");
            if(chgRs.next()) { chargesToDate=chgRs.getDouble(1); }
        }        
        return chargesToDate;
    }

    public String getVisitDate() {
        return visitDate;
    }

    public void setVisitDate(String visitDate) {
        this.visitDate = visitDate;
    }
    
    public String getNextAppointment() throws Exception {
        String apptDate="*None*";
        ResultSet lRs=io.opnRS("select `date` from appointments where patientid=" + this.patientId + " and `date`>=current_date order by `date` limit 1");
        if(lRs.next()) { apptDate=Format.formatDate(lRs.getString("date"),"MM/dd/yyyy"); }
        lRs.close();
        return apptDate;
    }
    
    public String getLastVisitDate() throws Exception {
        String lastVisitDate=Format.formatDate(new java.util.Date(), "yyyy-MM-dd");
        
        ResultSet vsRs=io.opnRS("select max(date) from visits where patientid=" + patientId + " and date<'" + getVisitDate() + "'");
        if(vsRs.next()) { if(vsRs.getString(1) != null) { lastVisitDate=vsRs.getString(1); } }
        vsRs.close();
        vsRs=null;

        return lastVisitDate;
    }
    
    public int getVisitsToDate() throws Exception {
        int visitsToDate=0;
        
        ResultSet vsRs=io.opnRS("select count(date) from visits where patientid=" + patientId + " and date<'" + getVisitDate() + "'");
        if(vsRs.next()) { visitsToDate=vsRs.getInt(1); }
        vsRs.close();
        vsRs=null;

        return visitsToDate;
    }
    
    public boolean isAutoWriteOff() throws Exception {
        return this.getBoolean("autowriteoff");
    }
    
    public boolean isVisitBased() throws Exception {
        return this.getBoolean("usevisits");
    }

    public boolean isPrepaidPlan() throws Exception {
        return this.getBoolean("prepaidplan");
    }

}
