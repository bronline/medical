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
import tools.*;
import tools.utils.*;
import java.sql.*;
import java.util.ArrayList;

/**
 *
 * @author BR Online Solutions
 */
public class PatientInsurance extends RWResultSet {
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
        }
        
        beforeFirst();
    }
    
    public String getInputForm() throws Exception {
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
        ins.append(frm.getInputItem("ispip"));
        ins.append(frm.getInputItem("planname"));
        ins.append(frm.getInputItem("primaryprovider"));
        ins.append(frm.getInputItem("providernumber"));
        ins.append(frm.getInputItem("providergroup"));
        ins.append(frm.getInputItem("insuranceeffective"));
        ins.append(frm.getInputItem("insurancevisits"));
        ins.append(frm.getInputItem("groupname"));
        ins.append(frm.getInputItem("guarantor"));
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

        ins.append("<div class=\"accordionButton\">Benefit Notes</div>");
        ins.append("<div class=\"accordionContent\" style=\"display: none; background-color: #ffffff;\">");
        ins.append(htmTb.startTable("100%", "0"));
        ins.append(frm.getInputItem("notes"));
        ins.append(htmTb.endTable());
        ins.append("</div>");
        ins.append("</div>");

        ins.append("<div class=\"accordionButton\">Authorization Information</div>");
        ins.append("<div class=\"accordionContent\" style=\"display: none; background-color: #ffffff;\">");
        ins.append(htmTb.startTable("100%", "0"));
        ins.append(frm.getInputItem("referenceNumber"));
        ins.append(frm.getInputItem("effectivedate"));
        ins.append(frm.getInputItem("expirationdate"));
        ins.append(frm.getInputItem("preauthvisits"));
        ins.append(htmTb.endTable());
        ins.append("</div>");
        ins.append("</div>");

        ins.append("<div class=\"accordionButton\">Guarantor Information</div>");
        ins.append("<div class=\"accordionContent\" style=\"display: none; background-color: #ffffff;\">");
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
    
    public String getInputForm(String newId) throws Exception {
        setId(Integer.parseInt(newId));
        return getInputForm();
    }
    
    public String getInputForm(int newId) throws Exception {
        setId(newId);
        return getInputForm();
    }
    
    public String getPatientInsuranceList(int patientId) throws Exception {
        rs = io.opnRS("select * from insurancedisplay where patientid=" + patientId + " order by primaryprovider");
        ins.delete(0, ins.length());
        ins.append(htmTb.startTable("545", "0"));
        String onClickLocationA = "onClick=window.open(\"patientinsurance_d.jsp?id=";
        String onClickLocationB = "\",\"Insurance\",\"width=500,height=600,left=50,top=80,toolbar=0,status=0,\"); ";
        String linkClass = " style=\"cursor: pointer; color: #030089;\"";

        ins.append(htmTb.roundedTop(5,"","#030089","insurancedivision"));

        // Display the heading
        ins.append(htmTb.startRow("style=\"cursor: pointer\" " + onClickLocationA + "0&patientId=" + patientId + onClickLocationB));
        ins.append(htmTb.headingCell("", htmTb.LEFT, "width=5%"));
        ins.append(htmTb.headingCell("Payer", htmTb.LEFT, "width=35%"));
        ins.append(htmTb.headingCell("Phone", htmTb.LEFT, "width=20%"));
        ins.append(htmTb.headingCell("Insured's Id", htmTb.LEFT, "width=20%"));
        ins.append(htmTb.headingCell("Group Number", htmTb.LEFT, "width=20%"));
//        ins.append(htmTb.headingCell("Relationship", htmTb.LEFT, "10%"));
        ins.append(htmTb.endRow());
    //  End the table for the Insurance heading
        ins.append(htmTb.endTable());

    // Start a division for the details section
        ins.append("<div style=\"width: 545; height: 44;  overflow: auto; text-align: left;\">\n");

    // List the symptoms
        ins.append(htmTb.startTable("545", "0"));

        while(next()) {
            String link = onClickLocationA + getString("id") + onClickLocationB;
            ins.append(htmTb.startRow());
            String primary="";
            if(getInt("primaryprovider")==1) { primary="*"; }
            ins.append(htmTb.addCell(primary, htmTb.CENTER, link + linkClass + " width=5%", ""));
            ins.append(htmTb.addCell(getString("name"), htmTb.LEFT, link + linkClass + " width=35%", ""));
            ins.append(htmTb.addCell(Format.formatPhone(getString("phonenumber")), htmTb.LEFT, link + linkClass + " width=20%", ""));
            ins.append(htmTb.addCell(getString("providernumber"), htmTb.LEFT, "width=20%", ""));
            ins.append(htmTb.addCell(getString("providergroup"), htmTb.LEFT, "width=20%", ""));
//            ins.append(htmTb.addCell(getString("relationship"), htmTb.LEFT, "width=10%"));
            ins.append(htmTb.endRow());
        }
        ins.append(htmTb.endTable());
    // End the division
        ins.append("</div>\n");
        
        return ins.toString();
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
}
