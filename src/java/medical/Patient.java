/*
 * Patient.java
 *
 * Created on November 19, 2005, 8:29 AM
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
import java.util.Calendar;
import java.util.ArrayList;
import medical.utiils.InfoBubble;

/**
 *
 * @author BR Online Solutions
 */
public class Patient extends MedicalResultSet {

    private String id;
    private boolean updatable   = false;
    private RWHtmlTable htmTb   = new RWHtmlTable();
    private RWInputForm frm     = new RWInputForm();
    private PatientIndicators ind;
    private Comments comments;
    private Appointments appointments;
    private PatientPlan plan;
    private Document document;
    private Symptoms symptoms;
    private PatientProblems problems;
    public PatientConditions condition;
    private XrayFindings findings;
    private PatientInsurance patientInsurance;
    private java.util.Date today    = new java.util.Date();
    private Timestamp timeStamp     = new java.sql.Timestamp(today.getTime());
    private ResultSet workRs;
    private BigDecimal returnAmount;
    private Environment env;

    private boolean editForm = false;
    
    /** Creates a new instance of Patient */
    public Patient() {
    }
    
    public Patient(RWConnMgr newIo, String ID) throws Exception {
        setConnMgr(newIo);
        if(frm == null)   { frm   = new RWInputForm(); }
        if(htmTb == null) { htmTb = new RWHtmlTable(); }
        if(ind == null)   { ind   = new PatientIndicators(io, 0); }
        setId(ID);
    }

    public Patient(RWConnMgr newIo, int ID) throws Exception {
        setConnMgr(newIo);
        if(frm == null)   { frm   = new RWInputForm(); }
        if(htmTb == null) { htmTb = new RWHtmlTable(); }
        if(ind == null)   { ind   = new PatientIndicators(io, 0); }
        setId("" +ID);
    }

    public Patient(RWConnMgr io, String ID, boolean newBol) throws Exception {
        setConnMgr(io);
        setUpdatable(newBol);
        if(frm == null)   { frm   = new RWInputForm(); }
        if(htmTb == null) { htmTb = new RWHtmlTable(); }
        if(ind == null)   { ind   = new PatientIndicators(io, 0); }
        setId(ID);
    }
    
    public Patient(RWConnMgr io, int ID, boolean newBol) throws Exception {
        setConnMgr(io);
        setUpdatable(newBol);
        setId("" + ID);
    }
    
    public void setId(String newId) throws Exception {
        id = newId;
        refresh();
        beforeFirst();
        if(!next()) {
            id = "0";
            refresh();
        }
        beforeFirst();
    }

    public void setId(int newId) throws Exception {
        setId("" + newId);
    }
    
    public void setEditPatient(boolean newBol) {
        editForm = newBol;
    }

    public void findCardNumber(String newCard) throws Exception {
        setResultSet(io.opnRS("select * from patients where cardnumber=" + newCard));
        if(rs.next()) {
            setId(getInt("id"));
        } else {
            setId(0);
        }
    }

    public void setUpdatable(boolean newBol) {
        updatable = newBol;
    }

    public void setTimestamp() throws Exception {
        timeStamp = new java.sql.Timestamp(today.getTime());
    }

    public void refresh() throws Exception {
        if(updatable) {
            setResultSet(io.opnUpdatableRS("select * from patients where id=" + id));        
        } else {
            setResultSet(io.opnRS("select * from patients where id=" + id));
        }       
        frm.setResultSet(rs);
        beforeFirst();
    }

    public int getId() {
        return Integer.parseInt(id);
    }
    
    public PatientPlan getPatientPlan() throws Exception {
        if(plan == null && !id.equals("0")) { plan=new PatientPlan(io, 0); }
        beforeFirst();
        if(next()) {
            plan.setPlanId(getInt("planId"));
        }
        return plan;
    }

    public String getPatientName() throws Exception {
        beforeFirst();
        if (!next() && !id.equals("0")) {return "";}
        return getString("firstName") + " " + getString("lastname");
    }
    
    public String getInputForm() throws Exception {
        frm.setResultSet(rs);
        beforeFirst();
        if (!next() && !id.equals("0")) {return "";}
        
        htmTb.setWidth("100%");
        htmTb.setBorder("0");
        frm.setFormItemsDisabled();
        if(editForm) { frm.setFormItemsEnabled(); }
        frm.setUseExternalForm(true);
        frm.setShowDatePicker(true);
        frm.setUpdateButtonText("  save  ");
        frm.setDisplayDeleteButton(false);
        frm.setDisplayUpdateButton(false);
        frm.setName("frmInput");
        frm.setMethod("POST");
        frm.setAction("updaterecord.jsp?rcd=" + id + "&fileName=patients");
        frm.setOnSubmit("return checkRequiredFields()");
        frm.setUseHelpText(true);
        frm.clearFieldDatasources();  // RKW - 10/16/2010
        htmTb.replaceNewLineChar(false);
        StringBuffer md = new StringBuffer();
        StringBuffer pp = new StringBuffer();

        md.append(frm.startForm());
        frm.getInputItem("id");

//        md.append("<table width=\"100%\"><tr><td align=\"center\">");
//        if(id.equals("0")) { htmTb.setWidth("550"); }
//        md.append(htmTb.startTable());
        if(id.equals("0")) {
            md.append(htmTb.startTable("550"));
        } else {
            md.append(htmTb.startTable("860"));
        }
        md.append(htmTb.startRow());

        if(!id.equals("0")) {
//            md.append(htmTb.startRow());
            frm.setUseExternalForm(false);
            frm.formItemOnOneRow = false;
            md.append(htmTb.addCell("<table><tr><td colspan=4>" + getIndicators() + "</td></tr><tr>" +  frm.getInputItem("active") +  frm.getInputItem("resourceid") + "</tr></table>", "width=270"));
            frm.setUseExternalForm(true);
//            md.append(htmTb.addCell(htmTb.getFrame(htmTb.BOTH, "", "#cccccc", 3, getAccountInfo()), "width=560 colspan=2"));
            md.append(htmTb.addCell(InfoBubble.getBubble("roundrect", "accountInfoBubble", "580", "30", "#cccccc", getAccountInfo()),htmTb.RIGHT, "width=590 colspan=2"));
//            md.append(htmTb.endRow());
        } else {
            frm.setUseExternalForm(false);
            frm.formItemOnOneRow = false;
            md.append(htmTb.startRow());
            md.append(htmTb.addCell("<table><tr>" +  frm.getInputItem("active") +  frm.getInputItem("resourceid") + "</tr></table>"));
            frm.setUseExternalForm(true);
//            md.append(htmTb.endRow());
        }

        md.append(htmTb.endRow());
        
        md.append(htmTb.startRow());
        md.append(htmTb.startCell(htmTb.LEFT, "class=infoHeader width=270"));
        md.append("Patient Information\n");
//        md.append(htmTb.getFrame(htmTb.BOTH, "", "#cccccc", 3, getNameAndAddress()));
        md.append(InfoBubble.getBubble("roundrect", "nameAndAddressBubble", "260", "125", "#cccccc", getNameAndAddress()));
        md.append("Contact Information\n");
//        md.append(htmTb.getFrame(htmTb.BOTH, "", "#cccccc", 3, getContactInfo()));
        md.append(InfoBubble.getBubble("roundrect", "contactInfoBubble", "260", "150", "#cccccc", getContactInfo()));
//        md.append(getInsuranceActiveInfo());
        md.append(htmTb.endCell());

        md.append(htmTb.startCell(htmTb.CENTER, "class=infoHeader width=290"));
        md.append("Demographic Information\n");
//        md.append(htmTb.getFrame(htmTb.BOTH, "", "#cccccc", 3, getDemographics()));
        md.append(InfoBubble.getBubble("roundrect", "demographicsBubble", "270", "125", InfoBubble.CENTER, "#cccccc", getDemographics()));
//        md.append(htmTb.getFrame(htmTb.BOTH, "", "#cccccc", 3, getDiagnosis()));
    // If this is a new patient, do not show the symptoms or treatment plan
        if(!id.equals("0")) {
//            md.append("Symptoms\n");
//            md.append(htmTb.getFrame(htmTb.BOTH, "", "#cccccc", 3, getSymptoms()));
            md.append("Treatment\n");
//            md.append(htmTb.getFrame(htmTb.BOTH, "", "#cccccc", 3, getTreatmentPlan()));
//            md.append(InfoBubble.getBubble("roundrect", "treatmentPlanBubble", "270", "150", "#cccccc", getTreatmentPlan()));
            md.append(InfoBubble.getBubble("roundrect", "treatmentPlan", "270", "150", InfoBubble.CENTER, "#030089", getTreatmentPlan()));
        }
        md.append(htmTb.endCell());


    // If this is a new patient, don't show the dashboard
        if(!id.equals("0")) {
            md.append(htmTb.startCell(htmTb.RIGHT, "class=infoHeader width=300 rowspan=2"));

            htmTb.setWidth("300");
            md.append("<br>\n");
            StringBuffer cmt = new StringBuffer();
            cmt.append(htmTb.startTable());
            cmt.append(htmTb.startRow());
            cmt.append(htmTb.addCell(showComments(), htmTb.LEFT, "id=\"patient_comments\""));
            cmt.append(htmTb.endRow());
            cmt.append(htmTb.startRow());
            cmt.append(htmTb.addCell(showAppointments(), htmTb.LEFT, "id=\"patient_appointments\""));
            cmt.append(htmTb.endRow());
            cmt.append(htmTb.startRow());
            cmt.append(htmTb.addCell(showCharges(), htmTb.LEFT, "id=\"patient_charges\""));
            cmt.append(htmTb.endRow());
            cmt.append(htmTb.endTable());

//            md.append(htmTb.getFrame(htmTb.BOTH, "", "#cccccc", 3, cmt.toString()));
            md.append(InfoBubble.getBubble("roundrect", "rightPaneBubble", "300", "390", "#cccccc", cmt.toString()));
            md.append(htmTb.endCell());
        }

        md.append(htmTb.endRow());
   
// Don't show the insurance information and appointments if it's a new patient
        if(!id.equals("0")) {
//            md.append(htmTb.startRow());
//            md.append(htmTb.startCell(htmTb.CENTER, "colspan=2 height=3px"));
//            md.append(htmTb.endCell());
//            md.append(htmTb.endRow());
            
            md.append(htmTb.startRow());
            md.append(htmTb.startCell(htmTb.LEFT, "width=560 colspan=2"));
//            md.append(htmTb.getFrame(htmTb.BOTH, "", "#cccccc", 3, getInsuranceInfo()));
            md.append(getInsuranceInfo());
            md.append(htmTb.endCell());
            md.append(htmTb.endRow());
       }
                
        md.append(htmTb.endTable());

        md.append("<br>");

        md.append(htmTb.startTable("280"));
        md.append(htmTb.startRow("height=30"));

        if(editForm) {
            md.append(htmTb.startTable("210"));
            md.append(htmTb.startRow());
            md.append(htmTb.addCell(frm.submitButton("  save  ", "class=button"), "width=70 style='align: center;'"));
            if(!id.equals("0")) { md.append(htmTb.addCell(frm.button(" delete ", "class=button onClick=deletePatient()"), "width=70 style='align: center;'")); }
            md.append(htmTb.addCell(frm.resetButton("  reset  ", "class=button"), "width=70 style='align: center;'"));
            md.append(htmTb.addCell(frm.button("  cancel  ", "class=button onClick=cancelEditMode()"), "width=70 style='align: center;'"));
            if(!id.equals("0")) { md.append(htmTb.addCell(frm.button("payment", "class='button' onClick=makePayment()"))); }
        } else {
// Add New Patient button
            if(!id.equals("0")) {
                md.append(htmTb.addCell(frm.button("  edit  ", "class=button onClick=setEditMode()"), "width=70 style='align: center;'"));
                md.append(htmTb.addCell("", "width=70 style='align: center;'"));
                md.append(htmTb.addCell(frm.button("  temp card  ", "class=button onClick=tempCard()"), "width=70 style='align: center;'"));
                md.append(htmTb.addCell(frm.button("  payment  ", "class='button' onClick=makePayment()"), "width=70 style='align: center;'"));
                md.append(htmTb.addCell(getCheckinCheckout()));
            } 
            md.append(htmTb.addCell(frm.button("  new  ", "class=button onClick=submitForm('newpatient.jsp')"), "width=70 style='align: center;'"));
        }

        md.append(htmTb.endRow());
        md.append(htmTb.endTable());
        
//        md.append("</td></tr></table>");
        
        md.append(frm.showHiddenFields());

        md.append(frm.endForm());

        md.append("<script type=\"text/javascript\">\n  document.forms[\"frmInput\"].elements[\"firstname\"].focus();\n</script>");

        pp.append("<div align=\"center\" id=\"patientInfoBody\">\n" + md.toString() + "\n</div>\n");
//        pp.append(htmTb.getFrame(htmTb.BOTH, "", "white", 15, md.toString()));

        return pp.toString();
        
    }
    
    public String getMenuItems() throws Exception {
        StringBuffer pp = new StringBuffer();
        ResultSet mi = io.opnRS("select * from menuitems where type='P' order by sequence");
        
        htmTb.setWidth("100%");
        pp.append(htmTb.startTable());
        while(mi.next()) {
            pp.append(htmTb.startRow());
            pp.append(htmTb.roundedTop(1, "", "#ffffff", ""));
            pp.append(htmTb.addCell("<b>" + mi.getString("menuitem") + "</b>", htmTb.CENTER, "width=100 bgcolor=white onClick=submitForm('" + mi.getString("url") + "') style=\"cursor: pointer;\""));
            pp.append(htmTb.roundedBottom(1, "", "#ffffff", ""));
            pp.append(htmTb.endRow());
            pp.append(htmTb.startRow("height=3"));
            pp.append("<td></td>");
            pp.append(htmTb.endRow());
        }
        
        pp.append(htmTb.endTable());

        return pp.toString();
    }
    
    public String getAccountInfo() throws Exception {
        beforeFirst();
        if (!next() && !id.equals("0")) {return "";}
        StringBuffer ai = new StringBuffer();
        htmTb.replaceNewLineChar(false);
        frm.formItemOnOneRow = false;
        frm.setLabelBold(true);
        htmTb.setWidth("100%");

        ai.append(htmTb.startTable());
        ai.append(htmTb.startRow());
        frm.setFormItemsDisabled();
        if(editForm) { frm.setFormItemsEnabled(); }
        ai.append(frm.getInputItem("accountnumber"));
        ai.append(frm.getInputItem("billingaccount"));
        ai.append(htmTb.endRow());
        ai.append(htmTb.endTable());

        return ai.toString();
    }

    public String getNameAndAddress() throws Exception {
        beforeFirst();
        if (!next() && !id.equals("0")) {return "";}
        StringBuffer na = new StringBuffer();
        htmTb.replaceNewLineChar(false);
        frm.setDftTextBoxSize("12");
        frm.setDftTextAreaCols("41");
        frm.setDftTextAreaRows("3");
        frm.formItemOnOneRow = false;
        frm.setLabelBold(true);
        frm.setLabelPosition(frm.LABEL_ON_BOTTOM);
        htmTb.setWidth("260");

        // added 10-14-07 attentionmsg is text and cannot be null for add
//        na.append("<div style='height: 115; width: 100%'>");
        if(id.equals("0")) { na.append("<input type=hidden name=attentionmsg value=''>"); }
        
        na.append(htmTb.startTable());
        na.append(htmTb.addCell(frm.getInputItem("firstname")));
        na.append(htmTb.addCell(" " +frm.getInputItem("middlename")));
        na.append(htmTb.addCell(frm.getInputItem("lastname")));
        na.append(htmTb.endRow());

        na.append(htmTb.startRow());
        na.append(htmTb.addCell(frm.getInputItem("address"), "colspan=3"));
        na.append(htmTb.endRow());

        na.append(htmTb.startRow());
        na.append(htmTb.addCell(frm.getInputItem("city")));
        na.append(htmTb.addCell(" " + frm.getInputItem("state")));
        na.append(htmTb.addCell(frm.getInputItem("zipcode")));
        na.append(htmTb.endRow());

        na.append(htmTb.endTable());
//        na.append("</div>");
//        htmTb.setWidth("245");

        return na.toString();
    }

    public String getInsuranceInfo() throws Exception {
        beforeFirst();
        if (!next() && !id.equals("0")) {return "";}
        StringBuffer ii = new StringBuffer();
        if(patientInsurance == null) { patientInsurance = new PatientInsurance(io); }
//        htmTb.replaceNewLineChar(false);
//        frm.setDftTextBoxSize("25");
//        frm.formItemOnOneRow = true;
//        frm.setLabelBold(true);
//        frm.setLabelPosition(frm.LABEL_ON_LEFT);
        htmTb.setWidth("550");

        ii.append(htmTb.startTable());
        ii.append(htmTb.startRow());
        ii.append(htmTb.addCell(getInsuranceActiveInfo()));
        ii.append(htmTb.endRow());
        ii.append(htmTb.startRow());
        ii.append(htmTb.startCell(htmTb.LEFT));
//        ii.append(htmTb.getFrame(htmTb.BOTH, "", "#cccccc", 3, patientInsurance.getPatientInsuranceList(Integer.parseInt(id))));
        ii.append(InfoBubble.getBubble("roundrect", "rightPaneBubble", "545", "70", "#cccccc", patientInsurance.getPatientInsuranceList(Integer.parseInt(id))));
        ii.append(htmTb.endCell());
        ii.append(htmTb.endRow());
//        ii.append(frm.getInputItem("providerid"));
//        ii.append(frm.getInputItem("providernumber"));
//        ii.append(frm.getInputItem("providergroup"));

        ii.append(htmTb.endTable());
//        htmTb.setWidth("245");

//        return ii.toString();
        return ii.toString();       
        
    }

    public String getSymptoms() throws Exception {
        beforeFirst();
        if (!next() || id.equals("0")) {return "";}
        if(condition == null || condition.getPatientId()!=Integer.parseInt(id)) { condition=new PatientConditions(io,"0"); }
        if(symptoms == null) { symptoms = new Symptoms(io); }
//        return symptoms.getPatientSymptoms(Integer.parseInt(id));
        return symptoms.getConditionSymptoms(condition.getCurrentCondition(this.id));
    }

    public String getPatientCondition() throws Exception {
        beforeFirst();
        if(condition == null || condition.getPatientId()!=Integer.parseInt(id)) { condition=new PatientConditions(io,"0"); symptoms=new Symptoms(io); }
        if (!next() || id.equals("0")) {return "";}
        StringBuffer pc = new StringBuffer();
        condition.setEditMode(true);
        
        pc.append("<div id=patientConditionBubble style='width: 100%; height: 140;'>");
        pc.append(frm.startForm());
        pc.append(htmTb.startTable("100%"));
        pc.append(htmTb.roundedTop(2,"","#030089","conditiondivision"));

    // Display the heading
        pc.append(htmTb.startRow());
        pc.append(htmTb.headingCell("Current Condition", "onMouseOver=this.style.cursor='pointer' onMouseOut=this.style.cursor='normal' onClick=showInputForm(event,'patientcondition.jsp',0," + this.id + ",txtHint)"));
        pc.append(htmTb.endRow());
        
        pc.append(htmTb.startRow());
        pc.append(htmTb.addCell("<div id=patientCondition style='height: 100;'>" + condition.getCondition(condition.getCurrentCondition(this.id)) + "</div>"));
        pc.append(htmTb.endRow());
 
        pc.append(htmTb.endTable());
        pc.append("</div></div>");

        return pc.toString();       
    }
    
    public String getConditions() throws Exception {
        beforeFirst();
        if(condition == null) { condition=new PatientConditions(io,"0"); }
        if (!next() || id.equals("0")) {return "";}
        StringBuffer pc = new StringBuffer();
        condition.setEditMode(false);
        
        pc.append("<div id=previousConditions style='width: 100%; height: 80;'>");
        pc.append(htmTb.startTable("100%"));
        pc.append(htmTb.roundedTop(2,"","#030089","previosuconditions"));

    // Display the heading
        pc.append(htmTb.startRow());
        pc.append(htmTb.headingCell("Conditions"));
        pc.append(htmTb.endRow());
        
        pc.append(htmTb.startRow());
        pc.append(htmTb.addCell("<div style='height: 80;'>" + condition.getConditionList(id) + "</div>"));
        pc.append(htmTb.endRow());
 
        pc.append(htmTb.endTable());
        pc.append(frm.endForm());
        pc.append("</div>");

        return pc.toString();       
    }
    
    private String getInsuranceActiveInfo() throws Exception {
        StringBuffer ia=new StringBuffer();
        
        beforeFirst();
        if (!next() || id.equals("0")) {return "";}

        ia.append(htmTb.startTable("100%", "0"));
        ia.append(htmTb.startRow());
        ia.append(frm.getInputItem("insuranceactive"));
        ia.append(htmTb.endRow());
        ia.append(htmTb.endTable());
        
        return ia.toString();
    }

    public String getPatientProblems() throws Exception {
        return getPatientProblems("");
    }

    public String getPatientProblems(String fontSize) throws Exception {
        beforeFirst();
        if (!next() || id.equals("0")) {return "";}
        
        if(problems == null) { problems = new PatientProblems(io); }
        return problems.getPatientProblems(Integer.parseInt(id), fontSize);       
    }

    public String getXrayFindings() throws Exception {
        return getXrayFindings("");
    }

    public String getXrayFindings(String fontSize) throws Exception {
        beforeFirst();
        if (!next() || id.equals("0")) {return "";}
        
        if(findings == null) { findings = new XrayFindings(io); }
        return findings.getXrayFindings(Integer.parseInt(id), fontSize);       
    }

    public String getTreatmentPlan() throws Exception {
        beforeFirst();
        if (!next() || id.equals("0")) {return "";}

        if(plan == null) { plan = new PatientPlan(io, 0); }
        plan.setPlanId(getInt("planid"));
        
//        htmTb.setWidth("100%");
        
//        return htmTb.getFrame(htmTb.BOTH, "", "#030089", 3, plan.getMiniPlanDetails(Integer.parseInt(id)));
        return plan.getMiniPlanDetails(Integer.parseInt(id));
    }
    
    public String getDiagnosis() throws Exception {
        beforeFirst();
        if (!next() && !id.equals("0")) {return "";}
        htmTb.setBorder("0");
        String ID = id;
        StringBuffer di = new StringBuffer();

        htmTb.replaceNewLineChar(false);
        frm.setDftTextBoxSize("25");
        frm.setDftTextAreaCols("35");
        frm.setDftTextAreaRows("14");

        frm.formItemOnOneRow = true;
        frm.setLabelBold(true);
        frm.setLabelPosition(frm.LABEL_ON_LEFT);
        htmTb.setWidth("100%");
        di.append(htmTb.startTable());

        di.append(frm.getInputItem("diagnosis"));

//        if(!ID.equals("0")) {

//            di.append(htmTb.startRow());
//            di.append(htmTb.addCell(htmTb.getFrame(htmTb.BOTH, "", "#030089", 3, rp.toString()), "colspan=2"));
//            di.append(htmTb.endRow());
//        }

        di.append(htmTb.endTable());
               
        htmTb.setWidth("245");
        frm.setDftTextAreaRows("3");

        return di.toString();
    }   

    public String getContactInfo() throws Exception {
        beforeFirst();
        if (!next() && !id.equals("0")) {return "";}
        StringBuffer ci = new StringBuffer();
        htmTb.replaceNewLineChar(false);
        frm.setDftTextBoxSize("25");
        frm.formItemOnOneRow = true;
        frm.setLabelBold(true);
        frm.setLabelPosition(frm.LABEL_ON_LEFT);
        htmTb.setWidth("260");
        
//        ci.append("<div style='height: 130; width: 100%'>");
        ci.append(htmTb.startTable());
        ci.append(frm.getInputItem("nickname"));

        try {
            if(getString("billingaccount") != null && !getString("billingaccount").equals("")) { ci.append(getBillingAccountContact()); }
        } catch (Exception e) {
        }

        ci.append(frm.getInputItem("homephone"));
        ci.append(htmTb.startRow());
        ci.append(htmTb.addCell("<b>Work Phone</b>"));
        ci.append(htmTb.startCell(htmTb.LEFT));
        ci.append("<table cellspacing='0' cellpadding='0' border='0'><tr>");
        ci.append(htmTb.addCell(frm.getInputItemOnly("workphone")));
        ci.append(htmTb.addCell("&nbsp;&nbsp;<b>ext.</b> "+frm.getInputItemOnly("workext","style='width: 40px;'") + "</tr></table>"));
        ci.append(htmTb.endCell());
        ci.append(htmTb.endRow());
        //ci.append(frm.getInputItem("workphone"));
        ci.append(frm.getInputItem("cellphone"));
        ci.append(frm.getInputItem("email"));
        ci.append(frm.getInputItem("cardnumber"));
        ci.append(frm.getInputItem("preferredcontact"));
        ci.append(frm.getInputItem("useemail"));

        ci.append(htmTb.endTable());
//        ci.append("</div>");
//        htmTb.setWidth("245");

        return ci.toString();
    }
    
    public String getDemographics() throws Exception {
        if(env == null) { env=new Environment(io); }
        env.refresh();
        beforeFirst();
        if (!rs.next() && !id.equals("0")) {return "";}
        StringBuffer ci = new StringBuffer();
        htmTb.replaceNewLineChar(false);
        frm.setDftTextBoxSize("15");
        frm.formItemOnOneRow = false;
        frm.setRBItemOnOneRow(true);
        frm.setLabelBold(true);
        frm.setLabelPosition(frm.LABEL_ON_LEFT);
        frm.setRbPosLeft();
        htmTb.setWidth("100%");

        ci.append("<div style='height: 115; width: 100%;'>");
        ci.append(htmTb.startTable());
        ci.append(htmTb.startRow());
        ci.append(htmTb.startCell("colspan=3"));
        ci.append(htmTb.startTable());
        ci.append(htmTb.startRow());
        ci.append(frm.getInputItem("gender"));
//        ci.append(htmTb.addCell("", "width=25%"));
        ci.append(htmTb.endRow());
        ci.append(htmTb.endTable());
        ci.append(htmTb.endCell());
        ci.append(htmTb.endRow());
        ci.append(htmTb.startRow());
        ci.append(htmTb.startCell("colspan=3"));
        ci.append(htmTb.startTable("100%"));
        ci.append(htmTb.startRow());
        ci.append(htmTb.addCell("<b>Marital Status</b>","width=84"));
        ci.append(htmTb.addCell(frm.getInputItemOnly("maritalstatus"),"colspan=2"));
//        ci.append(frm.getInputItem("maritalstatus"));
//        ci.append(htmTb.addCell(""));
        ci.append(htmTb.endRow());
//        ci.append(htmTb.startRow());
//        ci.append(frm.getInputItem("relationshipid"));
//        ci.append(htmTb.addCell(""));
//        ci.append(htmTb.endRow());
        ci.append(htmTb.endTable());
        ci.append(htmTb.endCell());
        ci.append(htmTb.endRow());
        ci.append(htmTb.startRow());


//        ci.append(frm.getInputItem("dob"));
        ci.append(htmTb.addCell("<b>DOB</b>", "width=84"));
        ci.append(htmTb.addCell(frm.getInputItemOnly("dob","")));
        if(rs.getRow() !=0) { 
            ci.append(htmTb.addCell("Age: " + getAge(rs.getDate("dob")), "width=50"));
        } else {
            ci.append(htmTb.addCell(""));
        }
        ci.append(htmTb.endRow());
        ci.append(htmTb.endTable());
        frm.setDftTextBoxSize("30");
        ci.append(htmTb.startTable());
        if(env.getBoolean("showssn")) {
            ci.append(htmTb.startRow());
            ci.append(frm.getInputItem("ssn"));
            ci.append(htmTb.endRow());
        }
        ci.append(htmTb.startRow());
        ci.append(frm.getInputItem("referredby", "onChange=checkForNew(this,'referalsource.jsp')"));
        ci.append(htmTb.endRow());
        ci.append(htmTb.startRow());
        ci.append(frm.getInputItem("occupationid", "onChange=checkForNew(this,'occupations.jsp')"));
        ci.append(htmTb.endRow());
        ci.append(htmTb.startRow());
        ci.append(frm.getInputItem("employer", "onChange=checkForNew(this,'employers.jsp')"));
        ci.append(htmTb.endRow());
        ci.append(htmTb.startRow());
        ci.append(htmTb.startCell(htmTb.LEFT, "height=3px colspan=2"));
        ci.append(htmTb.endCell());
        ci.append(htmTb.endRow());

        ci.append(htmTb.endTable());
        ci.append("</div>");
//        htmTb.setWidth("245");

        return ci.toString();
    }

    public String showComments() throws Exception {
        if(comments == null) { comments = new Comments(io); }
        return comments.getPatientComments(id);
    }

    public String showAppointments() throws Exception {
        if(appointments == null) { appointments = new Appointments(io); }
        return appointments.getPatientAppointments(id);
    }    
  
    public String showDetailedAppointments() throws Exception {
        if(appointments == null) { appointments = new Appointments(io); }
        return appointments.getDetailedPatientAppointments(id);
    }    

    public String showMissedAppointments() throws Exception {
        if(appointments == null) { appointments = new Appointments(io); }
        return appointments.getDetailedPatientMissedAppointments(id);
    }    

    public String showCharges() throws Exception {

    // Initialize local variables
        StringBuffer cmt = new StringBuffer();
        double totalCharges = 0.00;
        double dueToday = 0.00;
        int divHeight = 155;
        String dueTodayLink = "";
        String maintLink = "";
        
//        if (1==1) {return "";}

    // Create a resultset for the comments
//        ResultSet lRs = io.opnRS("select * from patientchargesummary where patientid=" + id);
//        ResultSet lRs = io.opnRS("select * from patientbalance where balance <> 0 and patientid=" + id);
        String balanceQuery = "select a.id , a.date , a.description , a.chargeamount , " +
                              "ifnull(e.paidamount,0) AS paidamount, cast((a.chargeamount - ifnull(e.paidamount,0)) as decimal) AS balance, " +
                              "a.patientid AS patientid from " +
                              "(SELECT * FROM patientchargesummary p where patientid=" + id + ") a " +
                              "left join paidamounts e on a.id = e.chargeid";
/*
        balanceQuery="select aa.id as visitId, aa.Date, cc.Type, ItemCount, Charges, InsPayments, PatPayments, WriteOffs, " +
                        "(charges-inspayments-patpayments-writeoffs) as Balance " +
                        "from visits aa " +
			"left join appointments bb on aa.appointmentid=bb.id left join appointmenttypes cc on bb.type=cc.id  " +
			"join (select a.visitid, itemcount,sum(a.chargeamount) as charges, ifnull(sum(b.amount),0) as inspayments,  " +
			"ifnull(sum(c.amount),0) as patpayments, ifnull(sum(d.amount),0) as writeoffs " +
			"from chargesbyvisit a " +
			"left join visitpaymentsbyinsurance b on a.visitid=b.visitid " +
			"left join visitpaymentsbypatient c on a.visitid=c.visitid " +
			"left join visitwriteoffs d on a.visitid=d.visitid " +
			"where a.visitid in (select id from visits where patientid=" + id +") " +
			"group by visitid having (charges-inspayments-patpayments-writeoffs)<>0) dd on aa.id=dd.visitid order by aa.Date";
*/
        balanceQuery="select aa.id as visitId, case when ItemCount>0 THEN '[+]' ELSE '' END as plussign, aa.`Date`, IFNULL(cc.`Type`,'Office Visit') AS `Type`, " +
                    "IFNULL(ItemCount,0) AS ItemCount, IFNULL(ItemCharges,0) AS ItemCharges, IFNULL(InsPayments,0) AS InsPayments, IFNULL(PatPayments,0) AS PatPayments, " +
                    "IFNULL(Adjustments,0) AS Adjustments, IFNULL(WriteOffs,0) AS WriteOffs, (IFNULL(ItemCharges,0)-IFNULL(inspayments,0)-IFNULL(patpayments,0)-IFNULL(adjustments,0)-IFNULL(writeoffs,0)) as Balance " +
                    "from visits aa " +
                    "left join appointments bb on aa.appointmentid=bb.id " +
                    "left join appointmenttypes cc on bb.type=cc.id " +
                    "LEFT JOIN (SELECT visitid, COUNT(*) AS ItemCount, SUM(chargeamount*quantity) AS ItemCharges FROM charges GROUP BY visitid) AS c ON c.visitid=aa.id " +
                    "LEFT JOIN (SELECT v.id AS visitid, SUM(amount) AS Inspayments FROM payments p LEFT JOIN providers pp ON p.provider=pp.id LEFT JOIN charges c ON c.id=p.chargeid LEFT JOIN visits v ON v.id=c.visitid WHERE NOT pp.reserved GROUP BY v.id) AS i ON i.visitid=aa.id " +
                    "LEFT JOIN (SELECT v.id AS visitid, SUM(amount) AS PatPayments FROM payments p LEFT JOIN providers pp ON p.provider=pp.id LEFT JOIN charges c ON c.id=p.chargeid LEFT JOIN visits v ON v.id=c.visitid WHERE (pp.reserved AND pp.id<>10 AND NOT pp.isadjustment) OR pp.id IS NULL GROUP BY v.id) AS pat ON pat.visitid=aa.id " +
                    "LEFT JOIN (SELECT v.id AS visitid, SUM(amount) AS Adjustments FROM payments p LEFT JOIN providers pp ON p.provider=pp.id LEFT JOIN charges c ON c.id=p.chargeid LEFT JOIN visits v ON v.id=c.visitid WHERE pp.reserved AND pp.id<>10 AND pp.isadjustment GROUP BY v.id) AS adj ON adj.visitid=aa.id " +
                    "LEFT JOIN (SELECT v.id AS visitid, SUM(amount) AS WriteOffs FROM payments p LEFT JOIN providers pp ON p.provider=pp.id LEFT JOIN charges c ON c.id=p.chargeid LEFT JOIN visits v ON v.id=c.visitid WHERE pp.reserved AND pp.id=10 GROUP BY v.id) AS wo ON wo.visitid=aa.id " +
                    "WHERE aa.patientid=" + id + " AND (IFNULL(ItemCharges,0)-IFNULL(inspayments,0)-IFNULL(patpayments,0)-IFNULL(adjustments,0)-IFNULL(writeoffs,0))>0 " +
                    "ORDER BY aa.`date` DESC";

        String dueTodayQuery = "select min(visitdate) as startdate, max(visitdate) as enddate, sum(copayamount)-sum(amount) as due from duetoday where patientid=" + id;
        
        ResultSet lRs = io.opnRS(balanceQuery);
        ResultSet dRs = io.opnRS(dueTodayQuery);
        
        if(dRs.next()) {
            dueToday = dRs.getDouble("due");
            divHeight = divHeight-20;
            dueTodayLink = "onClick=window.open('applypayments.jsp?&id=" + id + "&startDate=" + 
                                dRs.getString("startdate") + "&endDate=" + dRs.getString("enddate") + 
                                "&checkAmount=" + dRs.getString("due") + "&coPay=Y','Payments'," +
                                "'width=850,height=550,scrollbars=no,left=100,top=100,'); ";
        }
        
        dRs.close();
        
    // Start a new table to house the comments heading
        htmTb.setWidth("300");
        cmt.append("<div style='width: 300; height: 180;'>");
        cmt.append(htmTb.startTable("300"));

    // Display the heading
        cmt.append(htmTb.roundedTop(8,"","#030089","chargedivision"));
//        cmt.append(htmTb.startRow());
//        cmt.append(htmTb.headingCell("Open Items"));
//        cmt.append(htmTb.endRow());
        cmt.append(htmTb.startRow());
        cmt.append(htmTb.headingCell("Open Items", "colspan=8"));
        cmt.append(htmTb.endRow());
        cmt.append(htmTb.startRow());
        cmt.append(htmTb.headingCell("DOS", "width=14%"));
        cmt.append(htmTb.headingCell("Chgs", "width=14%"));
        cmt.append(htmTb.headingCell("Ins Pmt", "width=14%"));
        cmt.append(htmTb.headingCell("Pt Pmt", "width=14%"));
        cmt.append(htmTb.headingCell("Adj Amt", "width=14%"));
        cmt.append(htmTb.headingCell("Wrt Off", "width=14%"));
        cmt.append(htmTb.headingCell("Balance", "width=14%"));
        cmt.append(htmTb.headingCell("", ""));
        cmt.append(htmTb.endCell());

    //  End the table for the comments heading
        cmt.append(htmTb.endTable());

    // Start a division for the comments section
        cmt.append("<div style=\"width: 300; height: " + divHeight + ";  overflow: auto; text-align: left;\">\n");

    // List the comments
        htmTb.setWidth("281");
        cmt.append(htmTb.startTable());
        while(lRs.next()) {
            if (lRs.getDouble("balance")!=0) {
//                maintLink = "onClick=window.open('chargedetail.jsp?&id=" + lRs.getString("id") + "','Charges'," +
//                            "'width=750,height=550,scrollbars=no,left=100,top=100,'); ";
                maintLink = "onClick=showItem(event,'ajax/showvisitdetails.jsp'," + lRs.getString("visitid") + "," + this.id + ",txtHint) ";

                cmt.append(htmTb.startRow(maintLink + "style='cursor: pointer;'"));
                cmt.append(htmTb.addCell(Format.formatDate(lRs.getString("date"), "MM/dd/yy"), htmTb.LEFT, "width=14% style='cursor: pointer; color: #030089;'"));
                cmt.append(htmTb.addCell(Format.formatCurrency(lRs.getDouble("itemcharges")), htmTb.RIGHT, "width=14% style='cursor: pointer; color: #030089;'"));
                cmt.append(htmTb.addCell(Format.formatCurrency(lRs.getDouble("inspayments")), htmTb.RIGHT, "width=14% style='cursor: pointer; color: #030089;'"));
                cmt.append(htmTb.addCell(Format.formatCurrency(lRs.getDouble("patpayments")), htmTb.RIGHT, "width=14% style='cursor: pointer; color: #030089;'"));
                cmt.append(htmTb.addCell(Format.formatCurrency(lRs.getDouble("adjustments")), htmTb.RIGHT, "width=14% style='cursor: pointer; color: #030089;'"));
                cmt.append(htmTb.addCell(Format.formatCurrency(lRs.getDouble("writeoffs")), htmTb.RIGHT, "width=14% style='cursor: pointer; color: #030089;'"));
                cmt.append(htmTb.addCell(Format.formatCurrency(lRs.getDouble("balance")), htmTb.RIGHT, "width=14% style='cursor: pointer; color: #030089;'"));
                cmt.append(htmTb.endRow());
                totalCharges += lRs.getDouble("balance");
            }
        }
        cmt.append(htmTb.endTable());

    // End the division
        cmt.append("</div>\n");

    // Add a row at the end for total charges
        cmt.append(htmTb.startTable());
        cmt.append(htmTb.startRow());
        cmt.append(htmTb.addCell("<b>Total Open Charges</b>", htmTb.RIGHT));
        cmt.append(htmTb.addCell(Format.formatCurrency(totalCharges), htmTb.RIGHT));
        cmt.append(htmTb.endRow());
        cmt.append(htmTb.startRow());
        cmt.append(htmTb.addCell("<b>Unapplied Patient Payments</b>", htmTb.RIGHT));
        cmt.append(htmTb.addCell(Format.formatCurrency(getUnappliedPaymentTotal()), htmTb.RIGHT));
        cmt.append(htmTb.endRow());
        cmt.append(htmTb.startRow());
        cmt.append(htmTb.addCell("<b>Balance</b>", htmTb.RIGHT));
        cmt.append(htmTb.addCell(Format.formatCurrency(totalCharges - Double.parseDouble(""+getUnappliedPaymentTotal())), htmTb.RIGHT));
        cmt.append(htmTb.endRow());
        if(dueToday != 0.0) {
            cmt.append(htmTb.startRow());
            cmt.append(htmTb.addCell("<b>Due Today</b>", htmTb.RIGHT, "style='cursor: pointer; color: red; font-weight: bold;' " + dueTodayLink));
            cmt.append(htmTb.addCell(Format.formatCurrency(dueToday), htmTb.RIGHT, "style='cursor: pointer; color: red; font-weight: bold;' " + dueTodayLink));
            cmt.append(htmTb.endRow());
        }
        cmt.append(htmTb.endTable());
        cmt.append("</div>");
        htmTb.setWidth("300");

        return cmt.toString();
    }    

    public String getIndicators() throws Exception {
        ind.setPatientId(id);
        return ind.getPatientIndicators();
    }
    
    public int getAge(java.sql.Date date1) {
        int age = 0;
        if(!date1.toString().trim().equals("") && !date1.toString().trim().equals("1900-01-01")) {
            Calendar birthdate = Calendar.getInstance();
            birthdate.setTime(date1);
            Calendar now = Calendar.getInstance();
            age = now.get(Calendar.YEAR) - birthdate.get(Calendar.YEAR);
            birthdate.add(Calendar.YEAR, age);
            if (now.before(birthdate))
            age--;
        }
        return age;
    }
    
    public String getMiniContactInfo(RWHtmlTable htmTb) throws Exception {
        return getMiniContactInfo(htmTb, "");
    }       
    
    public String getMiniContactInfo(RWHtmlTable htmTb, String fontSize) throws Exception {
        String style = "";
        
        if (!fontSize.equals("")) {
            style = "style=font-size:" + fontSize;
        } else {
            fontSize="10px";
        }
        beforeFirst();
        if (!rs.next()) {return "";}
        StringBuffer ci = new StringBuffer();
        htmTb.replaceNewLineChar(false);
        
        // RKW 04/14/09 - get the payer name and copay amount
        String payerName="Cash";
        String payerId="0";
        double copayAmount=0.0;
        double deductableAmount=0.0;
        int visitsAllowed=0;
        int visitsUsed=0;
        int visitsRemaining=0;
        boolean copayAsPercent=false;
        String insuranceNotes="";

        ResultSet insRs=io.opnRS("SELECT providerid, ifnull(providers.name,'Cash') as payerName, patientinsurance.deductable, patientinsurance.copayamount, insurancevisits, patientinsurance.copayaspercent, IFNULL(patientinsurance.notes,'') as notes FROM patientinsurance left join providers on providers.id=patientinsurance.providerid where primaryprovider and active and patientId=" + this.id);
        if(insRs.next()) {
            payerId=insRs.getString("providerid");
            payerName=insRs.getString("payerName");
            copayAmount=insRs.getDouble("copayamount");
            deductableAmount=insRs.getDouble("deductable");
            visitsAllowed=insRs.getInt("insurancevisits");
            copayAsPercent=insRs.getBoolean("copayaspercent");
            insuranceNotes=insRs.getString("notes");
        }
        insRs.close();
        insRs=null;

        ci.append(htmTb.startTable("100%", "0"));

        ci.append(htmTb.startRow());
        ci.append(htmTb.headingCell("<a href=patientmaint.jsp?id=" + getString("id") + ">" + rs.getString("firstname") + " " + rs.getString("lastname") + "</a>", "colspan=2 style=\"font-size: 12px; background-color: silver;color: black;\""));
        ci.append(htmTb.endRow());
        if(rs.getInt("resourceId") !=0) {
            ci.append(htmTb.startRow());
            ci.append(htmTb.addCell("","colspan=2"));
            ci.append(htmTb.endRow());            
            ci.append(htmTb.startRow());
            ci.append(htmTb.addCell("<b>"+getResourceName(rs.getInt("resourceid"))+"</b>", RWHtmlTable.CENTER, "colspan=2 " + style));
            ci.append(htmTb.endRow());
            ci.append(htmTb.startRow());
            ci.append(htmTb.addCell("","colspan=2"));
            ci.append(htmTb.endRow()); 
        }

        ci.append(htmTb.startRow());
        ci.append(htmTb.addCell("<b>Home: ", getPhoneFormat(0) + "width=75" + " " + style));
        ci.append(htmTb.addCell(Format.formatPhone(rs.getString("homephone")), getPhoneFormat(0) + "width=115" + " " + style));
        ci.append(htmTb.endRow());
        ci.append(htmTb.startRow());
        ci.append(htmTb.addCell("<b>Work: ",getPhoneFormat(1) + style));
        ci.append(htmTb.addCell(Format.formatPhone(rs.getString("workphone")),getPhoneFormat(1) + style));
        ci.append(htmTb.endRow());
        ci.append(htmTb.startRow());
        ci.append(htmTb.addCell("<b>Cell: ",getPhoneFormat(2) + style));
        ci.append(htmTb.addCell(Format.formatPhone(rs.getString("cellphone")),getPhoneFormat(2) + style));
        ci.append(htmTb.endRow());
        ci.append(htmTb.startRow());
        ci.append(htmTb.addCell("<b>DOB: ",style));
        ci.append(htmTb.addCell(Format.formatDate(rs.getString("dob"),  "MM/dd/yyyy"),style));
        ci.append(htmTb.endRow());
        ci.append(htmTb.startRow());
        ci.append(htmTb.addCell("<b> Age: ",style));
        ci.append(htmTb.addCell(""+getAge(rs.getDate("dob")),style));
        ci.append(htmTb.endRow());
        ci.append(htmTb.startRow());
        ci.append(htmTb.addCell("<b>Card#: ",style));
        ci.append(htmTb.addCell(rs.getString("cardnumber"),style));
        ci.append(htmTb.endRow());

        if(fontSize.equals("10px")) {
            // RKW 04/14/09 - show the payer name and copay amount

            ci.append(htmTb.startRow());
            ci.append(htmTb.addCell("<hr>","colspan=2"));
            ci.append(htmTb.endRow());            
//            ci.append(htmTb.startRow());

            ResultSet vuRs=io.opnRS("select count(*) from visits where patientid=" + id + " and `date`>=(SELECT insuranceeffective FROM patientinsurance where patientid=" + id + " and primaryprovider and active order by id desc limit 1) ");
            if(vuRs.next()) { visitsUsed=vuRs.getInt(1); }
            vuRs.close();
            vuRs = null;

            String payerColors="style=\"font-size: 12px; background-color: #cccccc; color: #000000;\"";
            if(visitsUsed>=visitsAllowed && visitsAllowed!=0) { payerColors="style=\"font-size: 12px; background-color: #ce0000; color: #ffffff;\""; }

            ci.append(htmTb.startRow(payerColors));
            ci.append(htmTb.addCell("<b>Payer: </b>" + payerName,"colspan=2 " + payerColors));
            ci.append(htmTb.endRow());

            if(deductableAmount != 0.0) {
                ci.append(htmTb.startRow());
                ci.append(htmTb.addCell("<div style=\"width: 60%; float: left;\"><b>Deductable: </b></div><div style=\"width: 40%; float: right; text-align: right;\">" + Format.formatCurrency(deductableAmount) + "</div>","colspan=2 " + style));
                ci.append(htmTb.endRow());
            }

            if(copayAmount != 0.0) {
                ci.append(htmTb.startRow());
                if(copayAsPercent) {
                    ci.append(htmTb.addCell("<div style=\"width: 60%; float: left;\"><b>Copay: </b></div><div style=\"width: 40%; float: right; text-align: right;\">" + Format.formatNumber(copayAmount*.01, "##0.00%") + "</div>","colspan=2 " + style));
                } else {
                    ci.append(htmTb.addCell("<div style=\"width: 60%; float: left;\"><b>Copay: </b></div><div style=\"width: 40%; float: right; text-align: right;\">" + Format.formatCurrency(copayAmount) + "</div>","colspan=2 " + style));
                }
                ci.append(htmTb.endRow());
            }

            if(visitsAllowed != 0) {
                ci.append("<tr><td colspan=2><table width=\"100%\" cellspacing=\"0\" cellpadding=\"0\">");
                ci.append(htmTb.startRow());
                ci.append(htmTb.addCell("<b>Visits Allowed: </b>", "width=\"75%\" " + style));
                ci.append(htmTb.addCell("" + visitsAllowed, RWHtmlTable.RIGHT, "width=\"25%\" " + style));
                ci.append(htmTb.endRow());

                ci.append(htmTb.startRow());
                ci.append(htmTb.addCell("<b>Visits Used: </b>", style));
                ci.append(htmTb.addCell("" + visitsUsed, RWHtmlTable.RIGHT, style));
                ci.append(htmTb.endRow());

                if(visitsUsed<visitsAllowed) { visitsRemaining=visitsAllowed-visitsUsed; }

                ci.append(htmTb.startRow());
                ci.append(htmTb.addCell("<b>Visits Remaining: </b>", style));
                ci.append(htmTb.addCell("" + visitsRemaining, RWHtmlTable.RIGHT, style));
                ci.append(htmTb.endRow());

                ci.append("</table></td></tr>");
            }

            if(!insuranceNotes.trim().equals("")) {
                ci.append(htmTb.startRow());
                ci.append(htmTb.addCell("<b>Notes:</b>", "colspan=2"));
                ci.append(htmTb.endRow());

                ci.append(htmTb.startRow());
                ci.append(htmTb.addCell("<div align=\"left\" style=\"width: 100%; height: 60px; overflow: auto;\">" + insuranceNotes + "</div>", "colspan=2"));
                ci.append(htmTb.endRow());
            }

            try {
                String dedQuery="SELECT YEAR(d.`date`) AS `year`, SUM(amount) AS amount " +
                        "FROM deductables d " +
                        "LEFT JOIN batches b ON b.id=d.batchid " +
                        "WHERE b.provider=" + payerId + " AND d.patientid=" + this.id + " " +
                        "GROUP BY YEAR(d.`date`) " +
                        "ORDER BY YEAR(d.`date`) DESC " +
                        "LIMIT 3";
                ResultSet dedRs=io.opnRS(dedQuery);
                while(dedRs.next()) {
                    if(dedRs.getRow()==1) {
                        htmTb.setCellVAlign("BOTTOM");
                        ci.append(htmTb.startRow("height=\"20\""));
                        ci.append(htmTb.addCell("<b>Deductables Applied</b>", htmTb.CENTER, "colspan=2"));
                        ci.append(htmTb.endRow());
                        ci.append(htmTb.startRow());
                        ci.append(htmTb.addCell("<b>Year</b>"));
                        ci.append(htmTb.addCell("<b>Amount</b>",htmTb.RIGHT));
                        ci.append(htmTb.endRow());
                        htmTb.setCellVAlign("TOP");
                    }
                    ci.append(htmTb.startRow());
                    ci.append(htmTb.addCell(dedRs.getString("year")));
                    ci.append(htmTb.addCell(Format.formatCurrency(dedRs.getDouble("amount")),htmTb.RIGHT));
                    ci.append(htmTb.endRow());
                }
                dedRs.close();
                dedRs=null;
            } catch (Exception DeductionException) {

            }

            // RKW 04/14/09 - show the current condition
            getConditions();
            if(condition.getCurrentCondition(this.id) !=0 ) {

                ci.append(htmTb.startRow());
                ci.append(htmTb.addCell("<hr/>","colspan=2"));
                ci.append(htmTb.endRow());            

                ci.append(htmTb.startRow());
                ci.append(htmTb.addCell("<b>Current Condition</b>", htmTb.CENTER,"colspan=2"));
                ci.append(htmTb.endRow());            

                ci.append(htmTb.startRow());
                ci.append(htmTb.addCell(condition.getDescription(),"colspan=2 " + style));
                ci.append(htmTb.endRow());
            }
            
            //RKW 09/16/09 - Show the treatment plan details
//            getPatientPlan();
            if(this.plan == null || this.plan.getPlanId() != 0) {
                if(this.plan == null) { getPatientPlan();}
                ci.append(htmTb.startRow());
                ci.append(htmTb.addCell("<hr>","colspan=2"));
                ci.append(htmTb.endRow());            

                ci.append(htmTb.startRow());
                ci.append(htmTb.addCell("<b>" + this.plan.getBubbleInfo(getInt("id")) + "</b>","colspan=2"));
                ci.append(htmTb.endRow());
            }
        }
        ci.append(htmTb.endTable());
//        ci.append("</td></tr></table>");

        beforeFirst();
        return ci.toString();
    }       

    public String getVisitBar() throws Exception {
        StringBuffer vb = new StringBuffer();
    
        Calendar calCalendar = Calendar.getInstance();
        calCalendar.setTime(new java.util.Date());
        String fromDate="";
        String toDate="";
        String myQuery="";
        String cellStyle="";
        int visitTotal=0;
        boolean firstTime=true;

        // Set to prior Saturday.  This will be the end date.
        while (calCalendar.get(calCalendar.DAY_OF_WEEK)!=calCalendar.SATURDAY) {
            calCalendar.add(calCalendar.DAY_OF_MONTH,-1);
        }
        
//        vb.append("<table cellpadding=0 cellspacing=0>");
        for (int i=0;i<10;i++) {

            toDate=Format.formatDate(calCalendar.getTime(), "yyyy-MM-dd");
            calCalendar.add(calCalendar.DAY_OF_MONTH,-6);
            fromDate=Format.formatDate(calCalendar.getTime(), "yyyy-MM-dd");
            calCalendar.add(calCalendar.DAY_OF_MONTH,-1);

            myQuery="select count(*) from visits where patientid=" + id + " and date between '" + fromDate + "' and '" + toDate + "'";
            ResultSet aRs = io.opnRS(myQuery);
            if (aRs.next()) {
                visitTotal=aRs.getInt(1);
            } else {
                visitTotal=0;
            }
            if (visitTotal==0) {
                cellStyle="style=\"width: 5; height: 9; border: 1px solid Black;\"";
            } else if(visitTotal==1) {
                cellStyle="style=\"width: 5; height: 9; border: 1px solid Black; background: yellow\"";
            } else if(visitTotal==2) {
                cellStyle="style=\"width: 5; height: 9; border: 1px solid Black; background: blue\"";
            } else {
                cellStyle="style=\"width: 5; height: 9; border: 1px solid Black; background: red\"";
            }

//            vb.append("<tr><td " + cellStyle + ">&nbsp;</td></tr>");
            vb.append("<div " + cellStyle + "></div>\n");
        }
//        vb.append("</table>");
        return vb.toString();
    }
    
    public String getXrays() throws Exception {
        StringBuffer xr   = new StringBuffer();
        StringBuffer pi   = new StringBuffer();
        htmTb.setWidth("800");
        htmTb.setBorder("0");
        htmTb.replaceNewLineChar(false);

        condition=null;
        symptoms=null;
        
        ResultSet lRs = io.opnRS("Select * from patientdocuments where patientId=" + id + " and documentType=1 and identifierid=1 order by seq");

        xr.append("<div style=\" height: 400; width: 650; overflow: auto;\">");
        xr.append(htmTb.startTable("550"));

        boolean leave=false;
        while (!leave) {
            xr.append(htmTb.startRow("height=200"));
            if (lRs.next()) {
                xr.append(htmTb.addCell(getImage(lRs.getString("documentpath"), lRs.getString("seq") + " - " + lRs.getString("description"), lRs.getInt("id")), htmTb.CENTER, "width=50%"));
            } else {
                xr.append(htmTb.addCell(getImage("", "", 0), htmTb.CENTER, "width=50% onClick=window.open(\"documentupload.jsp?patientid=" + id + "&documenttype=1&identifierid=1\",\"XRays\",\"width=500,height=200,left=150,top=200,toolbar=0,status=0,\"); style=\"cursor: pointer;\" "));
                leave=true;
            }
            if (lRs.next()) {
                xr.append(htmTb.addCell(getImage(lRs.getString("documentpath"), lRs.getString("seq") + " - " + lRs.getString("description"), lRs.getInt("id")), htmTb.CENTER, "width=50%"));
            } else {
                xr.append(htmTb.addCell(getImage("", "", 0), htmTb.CENTER, "width=50% onClick=window.open(\"documentupload.jsp?patientid=" + id + "&documenttype=1&identifierid=1\",\"XRays\",\"width=500,height=200,left=150,top=200,toolbar=0,status=0,\"); style=\"cursor: pointer;\" "));
                leave=true;
            }
            xr.append(htmTb.endRow());
        }
        lRs.close();

        xr.append(htmTb.endTable());
        xr.append("</div>");

        pi.append(htmTb.startTable());
        pi.append(htmTb.startRow());

//        htmTb.setWidth("100%");
        pi.append(htmTb.addCell("&nbsp;&nbsp;", "width=10"));
        
        pi.append(htmTb.startCell(htmTb.LEFT, "width=225"));
/*
        pi.append(htmTb.startTable("220"));
        pi.append(htmTb.startRow());
//        pi.append(htmTb.addCell(htmTb.getFrame("#cccccc", getSymptoms())));
        pi.append(htmTb.addCell(InfoBubble.getBubble("roundrect", "symptomsbubble", "100%", "100%", "#cccccc", getSymptoms())));
        pi.append(htmTb.endRow());
        pi.append(htmTb.startRow());
//        pi.append(htmTb.addCell(htmTb.getFrame("#cccccc", getPatientCondition())));
        pi.append(htmTb.addCell(InfoBubble.getBubble("roundrect", "conditionbubble", "100%", "100%", "#cccccc", getPatientCondition())));
        pi.append(htmTb.endRow());
        pi.append(htmTb.startRow());
//        pi.append(htmTb.addCell(htmTb.getFrame("#cccccc", getConditions())));
        pi.append(htmTb.addCell(InfoBubble.getBubble("roundrect", "conditionsbubble", "100%", "100%", "#cccccc", getConditions())));
        pi.append(htmTb.endRow());
        pi.append(htmTb.startRow());
//        pi.append(htmTb.addCell(htmTb.getFrame("#cccccc", getXrayFindings())));
        pi.append(htmTb.addCell(InfoBubble.getBubble("roundrect", "xraysbubble", "100%", "100%", "#cccccc", getXrayFindings())));
        pi.append(htmTb.endRow());
        pi.append(htmTb.startRow());
//        pi.append(htmTb.addCell(htmTb.getFrame("#cccccc", getPatientProblems())));
        pi.append(htmTb.addCell(InfoBubble.getBubble("roundrect", "problemsbubble", "100%", "100%", "#cccccc", getPatientProblems())));
        pi.append(htmTb.endRow());
        pi.append(htmTb.endTable());
*/
        pi.append(InfoBubble.getBubble("roundrect", "symptomsbubble", "100%", "100%", "#cccccc", getSymptoms()));
        pi.append("<div style=\"height: 3px; width: 100%;\"></div>");
        pi.append(InfoBubble.getBubble("roundrect", "conditionbubble", "100%", "100%", "#cccccc", getPatientCondition()));
        pi.append("<div style=\"height: 3px; width: 100%;\"></div>");
        pi.append(InfoBubble.getBubble("roundrect", "conditionsbubble", "100%", "100%", "#cccccc", getConditions()));
        pi.append("<div style=\"height: 3px; width: 100%;\"></div>");
        pi.append(InfoBubble.getBubble("roundrect", "xraysbubble", "100%", "100%", "#cccccc", getXrayFindings()));
        pi.append("<div style=\"height: 3px; width: 100%;\"></div>");
        pi.append(InfoBubble.getBubble("roundrect", "problemsbubble", "100%", "100%", "#cccccc", getPatientProblems()));

        pi.append(htmTb.endCell());
        
//        pi.append(htmTb.addCell(htmTb.getFrame("#ffffff", xr.toString())));
        pi.append(htmTb.addCell("<div style=\"overflow: none;\">" + xr.toString() + "</div>"));
        pi.append(htmTb.endRow());
        
        pi.append(htmTb.endTable());        

        return pi.toString();
    }
    
    public String getImage(String documentPath, String description, int id) throws Exception {
        String imagePath = "images/no_photo.jpg";
        String imageDescription = "No Photo";
        StringBuffer img = new StringBuffer();
        String onClickOption = "";


        if(!documentPath.equals("")) {
            imagePath        = documentPath.replaceAll("\\\\", "/");
            if(imagePath.substring(0,2).equals("//") || imagePath.substring(0,2).toUpperCase().equals("C:")) { 
                imagePath=imagePath.substring(imagePath.indexOf("/medical"));
            }
            if(imagePath.indexOf("/medical/") > -1  && imagePath.indexOf("/medicaldocs/") == -1) { imagePath = "/medicaldocs" + imagePath.substring(imagePath.lastIndexOf("/medical/") + "/medical".length()); }
            imageDescription = description;
        }

        if(id != 0) { onClickOption = "onClick=displayImage('" + id + "') style='cursor: pointer;'"; }

        htmTb.setWidth("100%");
        img.append(htmTb.startTable());
        img.append(htmTb.startRow());
        img.append(htmTb.addCell("<image src=\"" + imagePath + "\" height=180 width=180 " + onClickOption + ">", htmTb.CENTER));
        img.append(htmTb.endRow());
        img.append(htmTb.startRow());
        img.append(htmTb.addCell(imageDescription, htmTb.CENTER));
        img.append(htmTb.endRow());
        img.append(htmTb.endTable());

        return img.toString();
    }    
    
    
    public void generateAccountNumber() throws Exception {
        setUpdatable(true);
        refresh();
        if(rs.next()) {
            String accountNumber=rs.getString("firstname").substring(0,1) + rs.getString("lastname").substring(0,1);
            accountNumber += "00000".substring(0,5-rs.getString("id").length()) + rs.getString("id");
            rs.updateString("accountnumber", accountNumber);
            rs.updateRow();
        }
    }
    
    public void updatePatientPlanInfo(int planId) throws Exception {
        setResultSet(io.opnUpdatableRS("select * from patients where planid=" + planId));
        if(rs.next()) {
            rs.updateInt("planid", 0);
            rs.updateRow();
        } else {
            ResultSet pRs = io.opnRS("select id, patientid from patientplan where id=" + planId);
            if(pRs.next()) {
                rs = io.opnUpdatableRS("select * from patients where id=" + pRs.getString("patientid"));
                if(rs.next()) {
                    rs.updateInt("planid", pRs.getInt("id"));
                    rs.updateRow();
                    if(plan == null) { plan = new PatientPlan(io, 0); }
                    plan.setPlanId(planId);
                    plan.updatePlanDetails();
                }
            }
            pRs.close();
        }
    }    
    
    public void updatePatientDocumentInfo(int documentType, int identifierId, String targetFile, String description) throws Exception {
        ArrayList dp            = new ArrayList();
        ArrayList ri            = new ArrayList();
        int x                   = 0;
        
        if(document == null) {
            document = new Document(io, Integer.parseInt(id), documentType, identifierId);
        }
        
        boolean multiplesAlowed = document.areMultiplesAlowed(documentType, identifierId);
        ResultSet lRs;
        
        if(!multiplesAlowed) {
            lRs = io.opnRS("select id, documentpath from patientdocuments where patientid=" + id + " and documenttype=" + documentType);
            while(lRs.next()) {
                dp.add(lRs.getString("documentpath"));
                ri.add(lRs.getString("id"));
            }

            String target = "";
            for(x=0; x<dp.size(); x++) {
                target = (String)dp.get(x);
                if(target.equals(targetFile)) { break; }
            }

            if(!dp.contains(targetFile) && !multiplesAlowed) {

                // Write the file information to the database
                lRs = io.opnUpdatableRS("select * from patientdocuments where patientid=" + id + " and documenttype=" + documentType + " and identifierid=" + identifierId);
                if(!lRs.next()) {
                    lRs.moveToInsertRow();
                    lRs.updateInt("patientid",  Integer.parseInt(id));
                    lRs.updateInt("documenttype", documentType);
                    lRs.updateInt("identifierid", identifierId);
                    lRs.updateString("documentpath", targetFile);
                    lRs.updateString("description", description);
                    lRs.insertRow();
                } else {
                    lRs.updateString("documentpath", targetFile);
                    lRs.updateString("description", description);
                    lRs.updateRow();
                }
            } else {
                lRs = io.opnUpdatableRS("select * from patientdocuments where id=" + (String)ri.get(x));
                if(lRs.next()) {
                    lRs.updateString("description", Format.formatDate(new java.util.Date(), "MM/dd/yyyy"));
                    lRs.updateRow();
                }
            }
        } else {
        // multiples are alowed so we always want to write the file information to the database
            lRs = io.opnUpdatableRS("select * from patientdocuments where id=0");
            lRs.moveToInsertRow();
            lRs.updateInt("patientid",  Integer.parseInt(id));
            lRs.updateInt("documenttype", documentType);
            lRs.updateInt("identifierid", identifierId);
            lRs.updateString("documentpath", targetFile);
            lRs.updateString("description", description);
            lRs.insertRow();          
        }

        lRs.close();        
    }
    
    public int findAppointmentInfo() throws Exception {
        int appointmentId = 0;
        ResultSet aRs = io.opnUpdatableRS("select * from appointments where patientid=" + id + " and date=current_date and timein='0001-01-01 00:00:00' order by time");
        if(aRs.next()) {
            setTimestamp();
            appointmentId = aRs.getInt("id");
            aRs.updateTimestamp("timein",  timeStamp);
            aRs.updateRow();
        }
        aRs.close();
        return appointmentId;
    }
    
    public void findVisitInfo(Visit visit, int location) throws Exception {
        findVisitInfo(visit, location, findAppointmentInfo()); 
    }

    public void findVisitInfo(Visit visit, int location, int apptId) throws Exception {
        if(condition == null) { condition=new PatientConditions(io,0); }

        ResultSet apptRs=io.opnRS("SELECT * FROM appointments WHERE id=" + apptId);

        if(apptRs.next()) {
            visit.setResultSet(io.opnRS("select * from visits where patientid=" + id + " and date=current_date"));
            if(visit.next()) {
                visit.setId(visit.getString("id"));
            } else {
                visit.setResultSet(io.opnRS("select * from visits where appointmentId=" + apptId ));
                if(apptId>0 && visit.next()) {
                    visit.setId(visit.getString("id"));
                } else {
                    PreparedStatement newVisitPs=io.getConnection().prepareStatement("INSERT INTO visits (appointmentid, patientid, date, locationid) VALUES(?, ?, ?, ?)");
                    newVisitPs.setInt(1, apptId);
                    newVisitPs.setString(2, id);
                    newVisitPs.setString(3, apptRs.getString("date"));
                    newVisitPs.setInt(4, location);
                    newVisitPs.execute();

                    io.setMySqlLastInsertId();

                    visit.setId(io.getLastInsertedRecord());
                }
            }
            visit.beforeFirst();
            visit.setLocationId(location);
            visit.setPatientId(Integer.parseInt(id));
            if (apptId>0) {
                visit.setAppointmentId(apptId);
            }
            visit.setConditionId(condition.getCurrentCondition(this.id));
            visit.update();
        }
        apptRs.close();
        apptRs = null;
    }

    public String getSearchBubble(String submitToUrl) throws Exception {
        return getSearchBubble(submitToUrl, true);
    }
    
    public String getSearchBubble(String submitToUrl, boolean activeOnly) throws Exception {
        RWHtmlForm inputFrm = new RWHtmlForm("Search",submitToUrl);
        inputFrm.setMethod("GET");
        htmTb.replaceNLChar = false;
        htmTb.setWidth("135");
        htmTb.setBorder("0");
        StringBuffer sB = new StringBuffer();

//        sB.append("<div id='patientSearchBubble'>");
        sB.append(htmTb.startTable());
        sB.append(inputFrm.startForm());
        sB.append(htmTb.startRow());
        sB.append(htmTb.addCell("&nbsp;&nbsp;" + inputFrm.textBox("","srchString", "class=tBoxText width=90 size=25 onKeyup='doCompletion(this)'")));
//        sB.append(htmTb.addCell(frm.submitButton("go", "class=button", "gobutton")));
        sB.append(htmTb.endRow());
        sB.append(htmTb.startRow());
        sB.append(htmTb.addCell("&nbsp;&nbsp;Show Active Only&nbsp;&nbsp;" + inputFrm.checkBox(activeOnly,"","activeOnly"), "colspan=2"));
        sB.append(htmTb.endRow());
        sB.append(inputFrm.endForm());
        sB.append(htmTb.endTable());
//        sB.append("</div>");

//        return htmTb.getFrame(htmTb.BOTH, "", "white", 1, sB.toString());
        return InfoBubble.getBubble("roundrect", "patientSearchBubble", "135", "38", "#ffffff", sB.toString());
    }
    public String getSearchResults(String srchString, String rowUrl, String idField) throws Exception {
        return getSearchResults(srchString, rowUrl, idField, true);
    }
    public String getSearchResults(String srchString, String rowUrl, String idField, boolean activeOnly) throws Exception {
        htmTb.replaceNLChar = false;
        htmTb.setWidth("135");
        htmTb.setBorder("0");
        
        String cardCondition = "";
        String searchSql = "";
        String searchSql2 = "";
        String lastSrch = "";
        String firstSrch = "";
        String whereClause = "";
        int firstBlank = 0;
        int searchStringLength = 0;
        ResultSet lRs;

        try {
            cardCondition = "or cardnumber = " + Integer.parseInt(srchString) + " ";
        } catch (Exception e) {

        }
        if (!srchString.equals("*EMPTY")) {
            if(srchString.equals("")) { return ""; }

            firstBlank = srchString.indexOf(' ');
            searchStringLength = srchString.length();
            
            if (firstBlank > 0 && searchStringLength-1>firstBlank) {
                lastSrch = srchString.substring(0, firstBlank);
                firstSrch = srchString.substring(firstBlank).trim();
                whereClause = "lastname like \"" + lastSrch + "%\" and firstname like \"" + firstSrch + "%\" ";
            } else {
                whereClause = "lastname like \"%" + srchString + "%\" or " +
                    "firstname like \"%" + srchString + "%\" " + cardCondition;
            }
            searchSql = "select id as " + idField + ", lastname, firstname, convert(DATEDIFF(NOW(), dob)/365.25,UNSIGNED ) dob, active from patients where  " +
                    whereClause +
                    " order by lastname, firstname";
            searchSql2 = "select id as " + idField + ", lastname, firstname, convert(DATEDIFF(NOW(), dob)/365.25,UNSIGNED ) dob, active from patients where  (" +
                    whereClause +
                    ")";
            if (activeOnly) searchSql2 += " and active ";
            
            searchSql2 += " order by lastname, firstname";

            lRs = io.opnRS(searchSql);
            if (lRs.next()) {
                setId(lRs.getInt(1));
                if(!lRs.next()) {
//                    String miniContactInfo=htmTb.getFrame(htmTb.BOTH, "", "white", 1, getMiniContactInfo(htmTb));
                    String miniContactInfo=InfoBubble.getBubble("roundrect", "miniContactBubble", "135", "380", "#ffffff", getMiniContactInfo(htmTb));
                    lRs.close();
                    lRs=null;
                    return miniContactInfo;
                } else {
                    searchSql=searchSql2;
                    lRs = io.opnRS(searchSql);
                    if(lRs.next()) { 
                        setId(lRs.getInt(1));
                        if(!lRs.next()) {
//                            String miniContactInfo=htmTb.getFrame(htmTb.BOTH, "", "white", 1, getMiniContactInfo(htmTb));
                            String miniContactInfo=InfoBubble.getBubble("roundrect", "miniContactBubble", "135", "380", "#ffffff", getMiniContactInfo(htmTb));
                            lRs.close();
                            lRs=null;
                            return miniContactInfo;
                        }
                    }
                }
            }
        } else {
            String rv = getMiniContactInfo(htmTb);
            if (rv=="") {
                return rv;
            } else {
                return InfoBubble.getBubble("roundrect", "miniContactBubble", "135", "380", "#ffffff", rv);
//                return htmTb.getFrame(htmTb.BOTH, "", "white", 1, rv);

            }
        }

    // We don't know which ID they want..... Set it to 0.
        setId(0);
        
    // Create an RWFiltered List object to show the occupations
/*        RWFilteredList lst = new RWFilteredList(io);

    // Create an array with the column headings
        String [] columnHeadings = { "id",  "Last Name", "First Name", "DOB"};

    // Set special attributes on the filtered list object
        lst.setTableBorder("0");
        lst.setCellPadding("1");
        lst.setCellSpacing("0");
        lst.setTableWidth("130");
        lst.setAlternatingRowColors("white","lightgrey");
        lst.setUrlField(0);
        lst.setNumberOfColumnsForUrl(3);
        lst.setRowUrl(rowUrl);
        lst.setShowRowUrl(true);
        lst.setShowComboBoxes(false);
        lst.setShowColumnHeadings(false);

    // Set specific column widths
        String [] cellWidths = {"0", "10", "20","10"};
        lst.setColumnWidth(cellWidths);
 */
        beforeFirst();
    // Show the list of occupations
//        String returnValue=htmTb.getFrame(htmTb.BOTH, "","white",3,"<div style=\"width: 130; height: 357; overflow: auto;\">" + lst.getHtml(searchSql, columnHeadings) + "</div>");
        String returnValue=htmTb.getFrame(htmTb.BOTH, "","white",3,"<div style=\"width: 130; height: 357; overflow: auto;\">" + getSearchResultList(searchSql, activeOnly) + "</div>");
        returnValue=InfoBubble.getBubble("roundrect", "searchResultsBubble", "135", "367", "#ffffff", "<div style=\"width: 130; height: 365; overflow: auto;\">" + getSearchResultList(searchSql, activeOnly) + "</div>");
        return returnValue;

    }

    private String getSearchResultList(String sql, boolean activeOnly) throws Exception {
        StringBuffer sb = new StringBuffer();    

        sb.append("<table width=\"130\" border=\"0\" cellSpacing=\"0\" cellPadding=\"1\">\n");

        ResultSet lRs = io.opnRS(sql);
        String bgColor="lightgrey";
        String link="";
        String style="";
        while (lRs.next()) {
            if (!lRs.getBoolean("active")) {
                style="color: red;";
            } else {
                style="";
            }
            link="'href=\"/medical/patientmaint.jsp?srchString=*EMPTY&srchPatientId=" + lRs.getString("srchPatientId") + "\"";
            link="";
            String onClickAction=" onClick=setPatientFromSearch(" + lRs.getString("srchPatientId") + ") ";
            sb.append("<tr style='cursor: pointer; " + style + "' bgcolor=" + bgColor + onClickAction +">\n");
            sb.append("  <td align=left valign=top class=\"searchBubble\">" + lRs.getString("lastname") + "</td>\n");
            sb.append("  <td align=left valign=top class=\"searchBubble\">" + lRs.getString("firstname") + "</td>\n");
            sb.append("  <td style='" + style + "' align=left valign=top class=\"searchBubble\">" + lRs.getString("DOB") + "</td>\n");
//            sb.append("<tr style='" + style + "' bgcolor=" + bgColor +">\n");
//            sb.append("  <td align=left valign=top ><a style='" + style + "' " + link + ">" + lRs.getString("lastname") + "</a></td>\n");
//            sb.append("  <td align=left valign=top ><a style='" + style + "' " + link + ">" + lRs.getString("firstname") + "</a></td>\n");
//            sb.append("  <td style='" + style + "' align=left valign=top >" + lRs.getString("DOB") + "</td>\n");
//            sb.append(" </tr>\n");
            if (bgColor.equals("lightgrey")) {
                bgColor="white";
            } else {
                bgColor="lightgrey";
            }
        }
        sb.append("</table>\n");

        lRs.close();
        lRs=null;
        
        return sb.toString();
    }
    
    public BigDecimal getDefaultPayment(int itemId) throws Exception {
        return getDefaultPayment(itemId, 0);
    }

    public BigDecimal getDefaultPayment(int itemId, int providerId) throws Exception {
        workRs = io.opnRS("select amount from defaultpayments where itemid=" + itemId + " and patientid = " + id + " and providerid = " + providerId);
        if (workRs.next()) {
            returnAmount=workRs.getBigDecimal("amount");
            workRs.close();
            workRs=null;
            return returnAmount;
        } else {
            workRs = io.opnRS("select amount from defaultpayments where itemid=" + itemId + " and patientid = 0 and providerid = " + providerId);
            if (workRs.next()) {
                returnAmount=workRs.getBigDecimal("amount");
                workRs.close();
                workRs=null;
                return returnAmount;
            } else {
                workRs.close();
                workRs=null;
                return BigDecimal.valueOf(0);
            }
        }
    }

    public BigDecimal getCopay(int itemId, int providerId) throws Exception {
        workRs = io.opnRS("select copay from defaultpayments where itemid=" + itemId + " and patientid = " + id + " and providerid = " + providerId);
        if (workRs.next()) {
            returnAmount=workRs.getBigDecimal("copay");
            workRs.close();
            return returnAmount;
        } else {
            workRs = io.opnRS("select copay from defaultpayments where itemid=" + itemId + " and patientid = 0 and providerid = " + providerId);
            if (workRs.next()) {
                returnAmount=workRs.getBigDecimal("copay");
                workRs.close();
                return returnAmount;
            } else {
                workRs.close();
                return BigDecimal.valueOf(0);
            }
        }
    }
    
    public String getPatientAging(RWHtmlTable htmTb, String rowColor) throws Exception {
        return getPatientAging(htmTb, null, null, rowColor, 0, "");
    }
    
    public String getPatientAging(RWHtmlTable htmTb, String rowColor, String selectedCharges) throws Exception {
        return getPatientAging(htmTb, null, null, rowColor, 0, selectedCharges);
    }

    public String getPatientAging(RWHtmlTable htmTb, String rowColor, int seperatorHeight) throws Exception {
        return getPatientAging(htmTb, null, null, rowColor, seperatorHeight, "");
    }
    
    public String getPatientAging(RWHtmlTable htmTb, String headingBackgroundColor, String headingTextColor, String rowColor, int seperatorHeight) throws Exception {
        return getPatientAging(htmTb, headingBackgroundColor, headingTextColor, rowColor, seperatorHeight, "");
    }

    public String getPatientAging(RWHtmlTable htmTb, String headingBackgroundColor, String headingTextColor, String rowColor, int seperatorHeight, String selectedCharges) throws Exception {
        String baseQuery="select p.id, sum(c.chargeamount*c.quantity) charges, " +
            "sum(ifnull((select sum(amount) from payments where chargeid=c.id),0.00)) payments " +
            "from charges c " +
            "left join visits v on c.visitid=v.id " +
            "left join patients p on p.id=v.patientid ";
        String grouping=" group by p.id";
        StringBuffer pa=new StringBuffer();
        
        htmTb.setCellVAlign("BOTTOM");
        pa.append(htmTb.startTable());
        pa.append(htmTb.startRow("height=" + seperatorHeight));
        pa.append(htmTb.addCell("Aging", htmTb.CENTER, "style='font-size:14px;'"));
        pa.append(htmTb.endRow());
        pa.append(htmTb.endTable());
        
        htmTb.setBorder("1");
        htmTb.setCellVAlign("TOP");
        pa.append(htmTb.startTable());

        ResultSet ageItemRs=io.opnRS("select * from agingitems order by seq");

        if(headingBackgroundColor != null) { headingBackgroundColor = " background-color: " + headingBackgroundColor + ";"; } else { headingBackgroundColor = " background-color: #030089;"; }
        if(headingTextColor != null) { headingTextColor = " color: " + headingTextColor + ";"; } else { headingTextColor = " color: #ffffff;";  }
        
        pa.append(htmTb.startRow());
        while(ageItemRs.next()) {
            pa.append(htmTb.headingCell(ageItemRs.getString("description"), "style=\"" + headingBackgroundColor + headingTextColor + "\""));
        }
        pa.append(htmTb.headingCell("Balance", "style=\"" + headingBackgroundColor + headingTextColor + "\""));
        pa.append(htmTb.endRow());
        
        int i=0;
        double patientTotal=0.0;

        pa.append(htmTb.startRow());
        ageItemRs.beforeFirst();
        while(ageItemRs.next()) {
            String thisQuery=baseQuery;
            String where=" where p.id=" + getId() + " ";
            if(!selectedCharges.equals("")) { where += " AND c.id in " + selectedCharges; }
            if(ageItemRs.getInt("mindays")==0 && ageItemRs.getInt("maxdays") != 0) {
                where += " and v.date>DATE_SUB(CURRENT_DATE, INTERVAL '" + ageItemRs.getInt("maxdays") + "' DAY) ";
            } else if(ageItemRs.getInt("mindays") != 0 && ageItemRs.getInt("maxdays") != 0) {
                where += " and v.date between DATE_SUB(CURRENT_DATE, INTERVAL '" + ageItemRs.getInt("maxdays") + "' DAY) and DATE_SUB(CURRENT_DATE, INTERVAL '" + ageItemRs.getInt("mindays") + "' DAY) ";
            }
            
            thisQuery=thisQuery+where+grouping;

            ResultSet agingRs=io.opnRS(thisQuery);
            if(agingRs.next()) {
                double balance=agingRs.getDouble("charges");
                balance-=agingRs.getDouble("payments");
                pa.append(htmTb.addCell(Format.formatCurrency(balance), htmTb.RIGHT,"width=75 style='background: " + rowColor + "; '"));
                patientTotal += balance;
            } else {
                pa.append(htmTb.addCell(Format.formatCurrency(0.0), htmTb.RIGHT,"width=75 style='background: " + rowColor + "; '"));                
            }
            agingRs.close();
            i++;
        }
        pa.append(htmTb.addCell(Format.formatCurrency(patientTotal), htmTb.RIGHT, "width=75 style='background: " + rowColor + "; '"));

        pa.append(htmTb.endRow());
        pa.append(htmTb.endTable());
        
        ageItemRs.close();
           
        return pa.toString();
    }
    public BigDecimal getUnappliedPaymentTotal()  {
        BigDecimal total= new BigDecimal(0.00);
        try {
            ResultSet uaRs=io.opnRS("select sum(amount) from payments where chargeid=0 and patientid = " + id);
            if (uaRs.next() && uaRs.getBigDecimal(1)!=null) {
                total=uaRs.getBigDecimal(1);
            }
        } catch (Exception e) {
            
        }
        return total;
    }
    
    public void delete() throws Exception {
        if(!id.equals("0")) {
            deleteAppointments();
            deleteComments();
            deleteDefaultPayments();
            deleteDoctorNotes();
            deletePatientDocuments();
            deletePatientIndicators();
            deletePatientInsurance();
            deletePatientIndicators();
            deletePatientMessages();
            deletePatientPlan();
            deletePatientSymptoms();
            deletePayments();
            deletePaymentSchedule();
            deleteVisits();
            deleteXrayFindings();
            
            this.setUpdatable(true);
            refresh();
            rs.beforeFirst();
            if(rs.next()) { rs.deleteRow(); }
        }
    }
    
    public void deleteAppointments() throws Exception {
        if(!id.equals("0")) {
            PreparedStatement lPs=io.getConnection().prepareStatement("delete from appointments where patientid=" + id);
            lPs.execute();
        }
    }
    
    public void deleteComments() throws Exception {
        if(!id.equals("0")) {
            PreparedStatement lPs=io.getConnection().prepareStatement("delete from comments where patientid=" + id);
            lPs.execute();
        }
    }
    
    public void deleteCharges() throws Exception {
        if(!id.equals("0")) {
            PreparedStatement batchChargesPs=io.getConnection().prepareStatement("delete from batchcharges where chargeid in (select id from charges where visitid in (select id from visits where patientid=" + id + "))");
            batchChargesPs.execute();
            PreparedStatement lPs=io.getConnection().prepareStatement("delete from charges where visitid in (select id from visits where patientid=" + id + ")");
            lPs.execute();
        }
    }
    
    public void deleteDefaultPayments() throws Exception {
        if(!id.equals("0")) {
            PreparedStatement lPs=io.getConnection().prepareStatement("delete from defaultpayments where patientid=" + id);
            lPs.execute();
        }
    }
    
    public void deleteDoctorNotes() throws Exception {
        if(!id.equals("0")) {
            PreparedStatement lPs=io.getConnection().prepareStatement("delete from doctornotes where patientid=" + id);
            lPs.execute();
        }
    }
    
    public void deletePatientDocuments() throws Exception {
        if(!id.equals("0")) {
            PreparedStatement lPs=io.getConnection().prepareStatement("delete from patientdocuments where patientid=" + id);
            lPs.execute();
        }
    }
    
    public void deletePatientIndicators() throws Exception {
        if(!id.equals("0")) {
            PreparedStatement lPs=io.getConnection().prepareStatement("delete from patientindicators where patientid=" + id);
            lPs.execute();
        }
    }
    
    public void deletePatientInsurance() throws Exception {
        if(!id.equals("0")) {
            PreparedStatement lPs=io.getConnection().prepareStatement("delete from patientinsurance where patientid=" + id);
            lPs.execute();
        }
    }
    
    public void deletePatientMessages() throws Exception {
        if(!id.equals("0")) {
            PreparedStatement lPs=io.getConnection().prepareStatement("delete from patientmessages where patientid=" + id);
            lPs.execute();
        }
    }
    
    public void deletePatientPlan() throws Exception {
        if(!id.equals("0")) {
            PreparedStatement lPs=io.getConnection().prepareStatement("delete from patientplan where patientid=" + id);
            lPs.execute();
        }
    }
    
    public void deletePatientProblems() throws Exception {
        if(!id.equals("0")) {
            PreparedStatement lPs=io.getConnection().prepareStatement("delete from patientproblems where patientid=" + id);
            lPs.execute();
        }
    }
    
    public void deletePatientSymptoms() throws Exception {
        if(!id.equals("0")) {
            PreparedStatement lPs=io.getConnection().prepareStatement("delete from patientsymptoms where patientid=" + id);
            lPs.execute();
        }
    }
    
    public void deletePayments() throws Exception {
        if(!id.equals("0")) {
            PreparedStatement lPs=io.getConnection().prepareStatement("delete from payments where patientid=" + id);
            lPs.execute();
        }
    }
    
    public void deletePaymentSchedule() throws Exception {
        if(!id.equals("0")) {
            PreparedStatement lPs=io.getConnection().prepareStatement("delete from paymentschedule where patientid=" + id);
            lPs.execute();
        }
    }
    
    public void deleteVisits() throws Exception {
        if(!id.equals("0")) {
            deleteCharges();
            PreparedStatement lPs=io.getConnection().prepareStatement("delete from visits where patientid=" + id);
            lPs.execute();
        }
    }
    
    public void deleteXrayFindings() throws Exception {
        if(!id.equals("0")) {
            PreparedStatement lPs=io.getConnection().prepareStatement("delete from xrayfindings where patientid=" + id);
            lPs.execute();
        }
    }
    
    public String getResourceName(int resourceId) {
        String resourceName="";
        
        try {
            ResultSet lRs=io.opnRS("select Name from resources where id=" + resourceId);
            if(lRs.next()) {
                resourceName=lRs.getString("name");
            }
            lRs.close();
        } catch (Exception e) {
        }
        return resourceName;

    }
    
    private String getPhoneFormat(int contactMethod) throws Exception {
        if(rs.getInt("preferredcontact") == contactMethod) {
            return "bgcolor=#cccccc ";
        } else {
            return "";
        }
    }
    
    public void generateInitialCondition() {
        try {
            PreparedStatement lPs = io.getConnection().prepareStatement("insert into patientconditions (patientid, conditiontype, description, `condition`, fromdate, todate) values (?,?,?,?,?,?)");
            lPs.setInt(1, ID);
            lPs.setInt(2, 0);
            lPs.setString(3, "Initial Condition");
            lPs.setString(4, "Auto-generated by ChiroPractice");
            lPs.setString(5, Format.formatDate(new java.util.Date(), "yyyy-MM-dd"));
            lPs.setString(6, "2075-12-31");
            lPs.execute();
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }

    public boolean hasInsurance() {
        boolean i = false;
        try {
            ResultSet pRs = io.opnRS("SELECT * FROM patientinsurance where active and patientid=" + this.id);
            i=pRs.next();
            pRs.close();
            pRs=null;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return i;
    }

    public String getBillingAccountContact() {
        StringBuffer b = new StringBuffer();
        try {
            if(!getString("billingaccount").trim().equals("")) {
                ResultSet tmpRs = io.opnRS("select concat('  ',firstname, ' ', lastname) as name from patients where accountnumber='" + getString("billingaccount") + "'");
                if(tmpRs.next()) {
                    b.append(htmTb.startRow("style=\"height: 17px;\""));
                    b.append(htmTb.addCell("<b>Contact Name</b>"));
                    htmTb.setCellVAlign("MIDDLE");
                    b.append(htmTb.addCell(tmpRs.getString("name"),"style=\"border: 1px solid #7f9db9; background-color: #eaeae3;\""));
                    htmTb.setCellVAlign("TOP");
                    b.append(htmTb.endRow());
                }
                tmpRs.close();
                tmpRs = null;
            }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return b.toString();
    }

    private String getCheckinCheckout() {
        String checkinBtn = "";
        try {
            ResultSet visitRs = io.opnRS("select * from visits where `date`=current_date and patientid=" + getId());
            if(visitRs.next()) {
                String chargeQuery = "SELECT * FROM charges WHERE visitid in (select id from visits where patientid=" + getId() + " and `date` = current_date) and itemId IN (SELECT min(id) from items where copayitem)";

                ResultSet piRs = io.opnRS("SELECT * FROM patientinsurance WHERE active AND primaryprovider AND patientid=" + getId());
                if(piRs.next()) {
                    if(piRs.getBoolean("copayaspercent")) {
                        chargeQuery = "SELECT 0 as id, IFNULL(SUM(copayamount),0) as copay FROM charges WHERE visitid in (select id from visits where patientid=" + getId() + " and `date` = current_date)";
                    }
                }

                ResultSet chgRs = io.opnRS(chargeQuery);
                if(chgRs.next()) {
                    if(piRs.getBoolean("copayaspercent")) {
                        if(chgRs.getDouble("copay") != 0) {
                            checkinBtn=frm.button("check out", "class=\"button\" onClick=\"checkin()\"", "checkinButton");
                        }
                    } else {
                        ResultSet pmtRs = io.opnRS("SELECT * FROM payments where chargeid in (select Id from charges where visitid in (select id from visits where patientid=" + getId() + " and `date` = current_date))");
                        if(!pmtRs.next()) {
                            checkinBtn=frm.button("check out", "class=\"button\" onClick=\"checkin()\"", "checkinButton");
                        }
                        pmtRs.close();
                        pmtRs = null;
                    }
                }
                chgRs.close();
                chgRs = null;
            } else {
                checkinBtn=frm.button("check in", "class=\"button\" onClick=\"checkin()\"", "checkinButton");
            }
            visitRs.close();
            visitRs = null;
        } catch (Exception ex) {
            ex.printStackTrace();
        }

        return checkinBtn;
    }
}
