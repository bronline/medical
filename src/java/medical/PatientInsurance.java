/*
 * Symptoms.java
 *
 * Created on December 27, 2005, 1:27 PM
 *
 * To change this template, choose Tools | Options and locate the template under
 * the Source Creation and Management node. Right-click the template and choose
 * Open. You can then make changes to the template in the Source Editor.
 */

package medical;
import java.util.logging.Level;
import java.util.logging.Logger;
import tools.*;
import tools.utils.*;
import java.sql.*;
import java.util.ArrayList;

/**
 *
 * @author BR Online Solutions
 */
public class PatientInsurance extends MedicalResultSet {
    private StringBuffer ins        = new StringBuffer();
    private RWHtmlTable htmTb       = new RWHtmlTable();
    private RWInputForm frm         = new RWInputForm();
    private int id                  = 0;
    private int patientId           = 0;
    private int providerId          = 0;
    private int relationship        = 0;
    private int primaryProvider     = 4;
    private String providerNumber   = "";
    private String providerGroup    = "";
    private String planName         = "";
    private String guarantor        = "";
    private String hicfa4           = "";
    private String hicfa7Address    = "";
    private String hicfa7City       = "";
    private String hicfa7State      = "";
    private String hicfa7Zip        = "";
    private String hicfaBox19       = "";
    private double hicfa7Phone      = 0.0;
    private int hicfa7Sex           = 0;
    private int hicfaAssignment     = 0;
    private String hicfa7DOB        = "0001-01-01";
    private double copayAmount      = 0.0;
    private String referenceNumber  = "";
    private boolean active          = true;
    private boolean isPIP           = false;
    private double deductable       = 0.0;
    private String notes            = "";
    private int preAuthVisits       = 0;
    private String insuranceTermDate= "2099-12-31";
    private boolean verified        = false;
    private String insuranceBenefitsDate = Format.formatDate(new java.util.Date(), "yyyy-MM-dd");
    private Environment env;

    private String insuranceEffective = "0001-01-01";
    private int insuranceVisits     = 0;
    
    /** Creates a new instance of Symptoms */
    public PatientInsurance() {
    }
    
    public PatientInsurance(RWConnMgr newIo) throws Exception {
        setConnMgr(newIo);        
    }
    
    public void setId(int newId) throws Exception {
        id = newId;
        refresh();
    }
    
    public void setPatientId(int newId) {
        patientId = newId;
    }
    
    public void refresh() throws Exception {
        rs = io.opnUpdatableRS("select * from patientinsurance where id=" + id);
        if(next()) {
            patientId = getInt("patientid");
            providerId = getInt("providerid");
            providerNumber = getString("providernumber");
            providerGroup = getString("providerGroup");
            relationship = getInt("relationshipid");
            guarantor = getString("guarantor");
            primaryProvider = getInt("primaryprovider");
            planName = getString("planname");
            hicfa4 = getString("hicfa4");
            hicfa7Address = getString("hicfa7address");
            hicfa7City = getString("hicfa7City");
            hicfa7State = getString("hicfa7State");
            hicfa7Zip = getString("hicfa7Zip");
            hicfa7Phone = getDouble("hicfa7Phone");
            hicfa7Sex = getInt("hicfa7Sex");
            hicfa7DOB = getString("hicfa7dob");
            hicfaBox19 = getString("hicfabox19");
            hicfaAssignment = getInt("hicfaassignment");
            copayAmount = getDouble("copayamount");
            referenceNumber= getString("referencenumber");
            insuranceVisits = getInt("insurancevisits");
            insuranceEffective = getString("insuranceeffective");
            active = getBoolean("active");
            isPIP = getBoolean("ispip");
            deductable = getDouble("deductable");
            notes = getString("notes");
            preAuthVisits = getInt("preauthvisits");
            insuranceTermDate = getString("insurancetermdate");
            verified = getBoolean("verified");
            insuranceBenefitsDate = getString("insurancebenefitsdate");
        }
        
        beforeFirst();
    }
    
    public String getInputForm() throws Exception {
        boolean useVerifiedFlag = isUseVerifyFlag();
        beforeFirst();
        ins.delete(0, ins.length());
        frm.setResultSet(this);
    
    // Set Arrays for hidden fields
        String [] var = { "patientid" };
        String [] val = { "" + patientId };
        frm.setPreLoadFields(var);
        frm.setPreLoadValues(val);
        
    // Set display attributes for the input form
        frm.setDftTextBoxSize("20");
        frm.setDftTextAreaCols("35");
        frm.setDftTextAreaRows("3");
        frm.setDisplayDeleteButton(true);
        frm.setShowDatePicker(true);
        frm.setLabelBold(true);
        frm.setUpdateButtonText("  save  ");
        frm.setDeleteButtonText("remove");

        ins.append(frm.startForm());
        frm.getInputItem("id");
        
        ins.append(htmTb.startTable("100%", "0"));

        ins.append(frm.getInputItem("providerid", "onChange=checkForNew(this,'newpayer.jsp')"));
        ins.append(frm.getInputItem("active"));
        if(useVerifiedFlag) { ins.append(frm.getInputItem("verified")); }  else { ins.append(frm.hidden("1", "verified")); }
        ins.append(frm.getInputItem("ispip"));
        ins.append(frm.getInputItem("planname"));
        ins.append(frm.getInputItem("primaryprovider"));
        ins.append(frm.getInputItem("providernumber"));
        ins.append(frm.getInputItem("providergroup"));
        ins.append(frm.getInputItem("insurancebenefitsdate"));
        ins.append(frm.getInputItem("insuranceeffective"));
        ins.append(frm.getInputItem("insurancetermdate"));
        ins.append(frm.getInputItem("insurancevisits"));
        ins.append(frm.getInputItem("groupname"));
        ins.append(frm.getInputItem("guarantor", "onChange=\"guarantorStatusChange(this)\""));
        ins.append(frm.getInputItem("relationshipid"));
        ins.append(frm.getInputItem("deductable"));
        //ins.append(frm.getInputItem("copayamount"));
        ins.append("<tr>\n");
        if(id == 0 || !getBoolean("copayaspercent")) {
            ins.append("<td id=\"copayamountlabel\"><b>Per Visit Copay Amount</b></td>");
        } else {
            ins.append("<td id=\"copayamountlabel\"><b>Co-Insurance Percent</b></td>\n");
        }
        ins.append("<td>" + frm.getInputItemOnly("copayamount") + "</td>");
        ins.append("</tr>\n");
        ins.append(frm.getInputItem("copayaspercent"));
        ins.append(htmTb.endTable());

        ins.append("<div class=\"accordionButton\" id=\"benefitNotesButton\">Benefit Notes</div>");
        ins.append("<div class=\"accordionContent\" id=\"benefitNotesContent\" style=\"display: none; background-color: #ffffff;\">");
        ins.append(htmTb.startTable("100%", "0"));
        ins.append(frm.getInputItem("notes"));
        ins.append(htmTb.endTable());
        ins.append("</div>");
        ins.append("</div>");

        ins.append("<div class=\"accordionButton\" id=\"authorizationInformationButton\">Authorization Information</div>");
        ins.append("<div class=\"accordionContent\" id=\"authorizationInformationContent\" style=\"display: none; background-color: #ffffff;\">");
        ins.append(htmTb.startTable("100%", "0"));
        ins.append(frm.getInputItem("referenceNumber"));
        ins.append(frm.getInputItem("effectivedate"));
        ins.append(frm.getInputItem("expirationdate"));
        ins.append(frm.getInputItem("preauthvisits"));
        ins.append(htmTb.endTable());
        ins.append("</div>");
        ins.append("</div>");

        ins.append("<div class=\"accordionButton\" id=\"guarantorInformationButton\">Guarantor Information</div>");
        ins.append("<div class=\"accordionContent\" id=\"guarantorInformationContent\" style=\"display: none; background-color: #ffffff;\">");
        ins.append(htmTb.startTable("100%", "0"));
        ins.append(frm.getInputItem("hicfa4"));
        ins.append(frm.getInputItem("hicfa7Address"));
        ins.append(frm.getInputItem("hicfa7City"));
        ins.append(frm.getInputItem("hicfa7State"));
        ins.append(frm.getInputItem("hicfa7Zip"));
        ins.append(frm.getInputItem("hicfa7Phone"));
        ins.append(frm.getInputItem("hicfa7Sex"));
        ins.append(frm.getInputItem("hicfa7dob"));
        ins.append(frm.getInputItem("hicfaBox19"));
        ins.append(frm.getInputItem("hicfaassignment"));
        ins.append(htmTb.endTable());
        ins.append("</div>");
        ins.append("</div>");
        
        ins.append(frm.updateButton());
        ins.append(frm.deleteButton());
        ins.append(frm.showHiddenFields());
        
        ins.append(frm.endForm());
        
        return ins.toString();
    }

    public String getIntakeInputForm() throws Exception {
        beforeFirst();
        ins.delete(0, ins.length());
        frm.setResultSet(this);

    // Set Arrays for hidden fields
        String [] var = { "patientid" };
        String [] val = { "" + patientId };
        frm.setPreLoadFields(var);
        frm.setPreLoadValues(val);
        frm.setName("patientInsuranceForm");

    // Set display attributes for the input form
        frm.setDftTextBoxSize("20");
        frm.setDftTextAreaCols("35");
        frm.setDftTextAreaRows("3");
        frm.setDisplayDeleteButton(true);
        frm.setShowDatePicker(true);
        frm.setLabelBold(true);
        frm.setUpdateButtonText("  save  ");
        frm.setDeleteButtonText("remove");

        ins.append(frm.startForm());
        frm.getInputItem("id");

        ins.append(htmTb.startTable("100%", "0"));

        ins.append(frm.getInputItem("providerid", "onChange=checkForNew(this,'newpayer.jsp')"));
        ins.append(frm.getInputItem("planname"));
        ins.append(frm.getInputItem("primaryprovider"));
        ins.append(frm.getInputItem("providernumber"));
        ins.append(frm.getInputItem("providergroup"));
        ins.append(frm.getInputItem("relationshipid", "onChange=\"guarantorStatusChange(this)\""));

        ins.append(htmTb.endTable());

        ins.append("<div class=\"accordionButton\" id=\"benefitNotesButton\">Benefit Notes</div>");
        ins.append("<div class=\"accordionContent\" id=\"benefitNotesContent\" style=\"display: none; background-color: #ffffff;\">");
        ins.append(htmTb.startTable("100%", "0"));
        ins.append(frm.getInputItem("notes"));
        ins.append(htmTb.endTable());
        ins.append("</div>");
        ins.append("</div>");

        ins.append("<div class=\"accordionButton\" id=\"authorizationInformationButton\">Authorization Information</div>");
        ins.append("<div class=\"accordionContent\" id=\"authorizationInformationContent\" style=\"display: none; background-color: #ffffff;\">");
        ins.append(htmTb.startTable("100%", "0"));
        ins.append(frm.getInputItem("referenceNumber"));
        ins.append(frm.getInputItem("effectivedate"));
        ins.append(frm.getInputItem("expirationdate"));
        ins.append(frm.getInputItem("preauthvisits"));
        ins.append(htmTb.endTable());
        ins.append("</div>");
        ins.append("</div>");

//        ins.append("<div class=\"accordionButton\" id=\"guarantorInformationButton\">Guarantor Information</div>");
//        ins.append("<div class=\"accordionContent\" id=\"guarantorInformationContent\" style=\"display: none; background-color: #ffffff;\">");
        ins.append("<div id=\"guarantorInformationContent\" style=\"display: none; background-color: #ffffff;\">");
        ins.append(htmTb.startTable("100%", "0"));
        ins.append(frm.getInputItem("hicfa4"));
        ins.append(frm.getInputItem("hicfa7Address"));
        ins.append(frm.getInputItem("hicfa7City"));
        ins.append(frm.getInputItem("hicfa7State"));
        ins.append(frm.getInputItem("hicfa7Zip"));
        ins.append(frm.getInputItem("hicfa7Phone"));
        ins.append(frm.getInputItem("hicfa7Sex"));
        ins.append(frm.getInputItem("hicfa7dob"));
        ins.append(frm.getInputItem("hicfaBox19"));
        ins.append(frm.getInputItem("hicfaassignment"));
        ins.append(htmTb.endTable());
        ins.append("</div>");
        ins.append("</div>");

//        ins.append(frm.updateButton());
//        ins.append(frm.deleteButton());
        ins.append(frm.button("save", "class=\"button\" onClick=\"saveInsuranceInformation()\""));
        ins.append(frm.button("cancel", "class=\"button\" onClick=\"closeInsuranceBubble();\""));
        ins.append(frm.showHiddenFields());

        ins.append(frm.endForm());

        return ins.toString();
    }

    public String getInputForm(String newId) throws Exception {
        setId(Integer.parseInt(newId));
        return getInputForm();
    }
    
    public String getInputForm(int newId) throws Exception {
        setId(newId);
        return getInputForm();
    }

    public String getPatientInsuranceList(int patientId) {
        try {
            ResultSet ptRs = io.opnRS("select cashonly from patients where id=" + patientId);
            boolean cashOnly = false;
            if(ptRs.next()) { cashOnly = ptRs.getBoolean("cashonly"); }
            ptRs.close();
            ptRs = null;
            
            int listColumns = 6;
            int nameWidth = 200;
            if(isUseVerifyFlag()) { listColumns = 7;  nameWidth = 150; }
//            rs = io.opnRS("select * from insurancedisplay where patientid=" + patientId + " order by primaryprovider");
            rs = io.opnRS("CALL rwcatalog.prInsuranceDisplay('" + io.getLibraryName() + "'," + patientId + ")");

            ins.delete(0, ins.length());
            ins.append(htmTb.startTable("545", "0"));
            String onClickLocationA = "onClick=window.open(\"patientinsurance_d.jsp?id=";
            String onClickLocationB = "\",\"Insurance\",\"width=500,height=600,left=50,top=80,toolbar=0,status=0,\"); ";
            String linkClass = " style=\"cursor: pointer; color: #030089;\"";
            ins.append(htmTb.roundedTop(listColumns, "", "#030089", "insurancedivision"));
            // Display the heading
            ins.append(htmTb.startRow("style=\"cursor: pointer\" " + onClickLocationA + "0&patientId=" + patientId + onClickLocationB));
            ins.append(htmTb.headingCell("", htmTb.LEFT, "width=\"15px\""));
            ins.append(htmTb.headingCell("Payer", htmTb.LEFT, "width=\"" + nameWidth + "px\""));
            ins.append(htmTb.headingCell("Phone", htmTb.LEFT, "width=\"75px\""));
            ins.append(htmTb.headingCell("Insured's Id", htmTb.LEFT, "\"width=100px\""));
            ins.append(htmTb.headingCell("Group Number", htmTb.LEFT, "width=\"100px\""));
            ins.append(htmTb.headingCell("Active", htmTb.CENTER,"width=\"50px\""));
            if(isUseVerifyFlag()) { ins.append(htmTb.headingCell("Verified", htmTb.CENTER,"width=\"50px\"")); }
            //        ins.append(htmTb.headingCell("Relationship", htmTb.LEFT, "10%"));
            ins.append(htmTb.endRow());
            //  End the table for the Insurance heading
            ins.append(htmTb.endTable());
            // Start a division for the details section
            ins.append("<div style=\"width: 545; height: 64;  overflow: auto; text-align: left;\">\n");
            ins.append(htmTb.startTable("545", "0"));
            if(!cashOnly) { ins.append(getList(onClickLocationA, onClickLocationB, linkClass)); }
            ins.append(htmTb.endTable());
            // End the division
            ins.append("</div>\n");

        } catch (Exception ex) {
            Logger.getLogger(PatientInsurance.class.getName()).log(Level.SEVERE, null, ex);
        }

        return ins.toString();
    }
    
    public String getPatientInsuranceList(int patientId, String onClickLocationA, String onClickLocationB, String linkClass) throws Exception {
        StringBuffer piList = new StringBuffer();
//        rs = io.opnRS("select * from insurancedisplay where patientid=" + patientId + " order by primaryprovider");
        rs = io.opnRS("CALL rwcatalog.prInsuranceDisplay('" + io.getLibraryName() + "'," + patientId + ")");
        piList.append(htmTb.startTable("100%","0"));
        piList.append(getList(onClickLocationA, onClickLocationB, linkClass));
        piList.append(htmTb.endTable());
        return piList.toString();
    }

    public String getList(String onClickLocationA, String onClickLocationB, String linkClass) {
        StringBuffer insList = new StringBuffer();
        try {
            int nameWidth = 200;
            if(isUseVerifyFlag()) { nameWidth = 150; }
            while (next()) {
                String link = onClickLocationA + getString("id") + onClickLocationB;
                insList.append(htmTb.startRow());
                String primary = "";
                if (getInt("primaryprovider") == 1) {
                    primary = "*";
                }
                String activeCheckbox = "<input type=\"checkbox\" name=\"active" + getInt("id") + "\" id=\"active" + getInt("id") + "\"  ";
                String verifiedCheckbox = "<input type=\"checkbox\" name=\"verified" + getInt("id") + "\" id=\"verified" + getInt("id") + "\" ";
                
                if(getBoolean("verified")) { verifiedCheckbox += "CHECKED READONLY DISABLED>"; } else { verifiedCheckbox += " style=\"cursor: pointer;\" onClick=\"setInsuranceVerified(" + getString("patientId") + "," + getInt("Id") + ",this)\">"; }
                if(getBoolean("active")) { activeCheckbox += "CHECKED"; }
                activeCheckbox += " READONLY DISABLED>";
                
                insList.append(htmTb.addCell(primary, htmTb.CENTER, link + linkClass + " width=15px", ""));
                insList.append(htmTb.addCell(getString("name"), htmTb.LEFT, link + linkClass + " width=" + nameWidth + "px", ""));
                insList.append(htmTb.addCell(Format.formatPhone(getString("phonenumber")), htmTb.LEFT, " width=75px", ""));
                insList.append(htmTb.addCell(getString("providernumber"), htmTb.LEFT, "width=100px", ""));
                insList.append(htmTb.addCell(getString("providergroup"), htmTb.LEFT, "width=100px", ""));
                insList.append(htmTb.addCell(activeCheckbox, htmTb.CENTER, "width=50px", ""));
                if(isUseVerifyFlag()) { insList.append(htmTb.addCell(verifiedCheckbox, htmTb.CENTER, "width=50px", "")); }
                insList.append(htmTb.endRow());
            }
        } catch (SQLException ex) {
            Logger.getLogger(PatientInsurance.class.getName()).log(Level.SEVERE, null, ex);
        }
        return insList.toString();
    }

    public String getHicfa4() {
        return hicfa4;
    }

    public void setHicfa4(String hicfa4) {
        this.hicfa4 = hicfa4;
    }

    public String getHicfa7Address() {
        return hicfa7Address;
    }

    public void setHicfa7Address(String hicfa7Address) {
        this.hicfa7Address = hicfa7Address;
    }

    public String getHicfa7City() {
        return hicfa7City;
    }

    public void setHicfa7City(String hicfa7City) {
        this.hicfa7City = hicfa7City;
    }

    public String getHicfa7State() {
        return hicfa7State;
    }

    public void setHicfa7State(String hicfa7State) {
        this.hicfa7State = hicfa7State;
    }

    public String getHicfa7Zip() {
        return hicfa7Zip;
    }

    public String getHicfaBox19() {
        return hicfaBox19;
    }

    public int getHicfaAssignment() {
        return hicfaAssignment;
    }

    public void setHicfa7Zip(String hicfa7Zip) {
        this.hicfa7Zip = hicfa7Zip;
    }

    public void setHicfaBox19(String hicfaBox19) {
        this.hicfaBox19 = hicfaBox19;
    }

    public void setHicfaAssignment(int hicfaAssignment) {
        this.hicfaAssignment = hicfaAssignment;
    }

    public double getHicfa7Phone() {
        return hicfa7Phone;
    }

    public void setHicfa7Phone(double hicfa7Phone) {
        this.hicfa7Phone = hicfa7Phone;
    }

    public double getCopayAmount() {
        return copayAmount;
    }

    public void setCopayAmount(double copayAmount) {
        this.copayAmount = copayAmount;
    }

    public String getReferenceNumber() {
        return referenceNumber;
    }

    public void setReferenceNumber(String referenceNumber) {
        this.referenceNumber = referenceNumber;
    }

    /**
     * @return the insuranceEffective
     */
    public String getInsuranceEffective() {
        return insuranceEffective;
    }

    /**
     * @param insuranceEffective the insuranceEffective to set
     */
    public void setInsuranceEffective(String insuranceEffective) {
        this.insuranceEffective = insuranceEffective;
    }

    /**
     * @return the insuranceVisits
     */
    public int getInsuranceVisits() {
        return insuranceVisits;
    }

    /**
     * @param insuranceVisits the insuranceVisits to set
     */
    public void setInsuranceVisits(int insuranceVisits) {
        this.insuranceVisits = insuranceVisits;
    }

    /**
     * @return the active
     */
    public boolean isActive() {
        return active;
    }

    /**
     * @param active the active to set
     */
    public void setActive(boolean active) {
        this.active = active;
    }

    /**
     * @return the isPIP
     */
    public boolean isIsPIP() {
        return isPIP;
    }

    /**
     * @param isPIP the isPIP to set
     */
    public void setIsPIP(boolean isPIP) {
        this.isPIP = isPIP;
    }

    /**
     * @return the deductible
     */
    public double getDeductable() {
        return deductable;
    }

    /**
     * @param deductible the deductible to set
     */
    public void setDeductable(double deductable) {
        this.deductable = deductable;
    }

    /**
     * @return the notes
     */
    public String getNotes() {
        return notes;
    }

    /**
     * @param notes the notes to set
     */
    public void setNotes(String notes) {
        this.notes = notes;
    }

    /**
     * @return the preAuthVisits
     */
    public int getPreAuthVisits() {
        return preAuthVisits;
    }

    /**
     * @param preAuthVisits the preAuthVisits to set
     */
    public void setPreAuthVisits(int preAuthVisits) {
        this.preAuthVisits = preAuthVisits;
    }

    /**
     * @return the insuranceTermDate
     */
    public String getInsuranceTermDate() {
        return insuranceTermDate;
    }

    /**
     * @param insuranceTermDate the insuranceTermDate to set
     */
    public void setInsuranceTermDate(String insuranceTermDate) {
        this.insuranceTermDate = insuranceTermDate;
    }

    /**
     * @return the verified
     */
    public boolean isVerified() {
        return verified;
    }

    /**
     * @param verified the verified to set
     */
    public void setVerified(boolean verified) {
        this.verified = verified;
    }
    
    private boolean isUseVerifyFlag() {

        boolean flag = false;

            try {
                if(env == null) {
                    env = new Environment(this.io);
                }
                env.refresh();
                flag = env.getBoolean("verifyinsurance");
                
            } catch (SQLException ex) {
                Logger.getLogger(PatientInsurance.class.getName()).log(Level.SEVERE, null, ex);
            } catch (Exception ex) {
                Logger.getLogger(PatientInsurance.class.getName()).log(Level.SEVERE, null, ex);
            }
 
        return flag;
    }
}
