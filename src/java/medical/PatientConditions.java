/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package medical;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.logging.Level;
import java.util.logging.Logger;
import tools.RWConnMgr;
import tools.RWHtmlTable;
import tools.RWInputForm;
import tools.utils.Format;

/**
 *
 * @author Randy
 */
public class PatientConditions extends MedicalResultSet {
    private int id;
    private int patientId;
    private int conditionType;
    private String description;
    private String condition;
    private String fromDate;
    private String toDate;
    private int sameOrSimilar;
    private String state;
    private String conditionTypeName;
    private String similarDate;
    private String referringDoctor;
    private String referringNPI;
    private int providerId;
    private String blanks       = "                    ";
    public String refreshObject = "patientCondition";
    
    private boolean editMode = false;

    public PatientConditions() {
    }

    public PatientConditions(RWConnMgr io, String ID) throws Exception {
        setConnMgr(io);
        setId(ID);
        setResultSet(io.opnRS("select patientconditions.*, c.description as conditiontypename from patientconditions left join conditions c on patientconditions.conditiontype=c.id where patientconditions.id=" + this.id));
    }

    public PatientConditions(RWConnMgr io, int ID) throws Exception {
        setConnMgr(io);
        setId(ID);
        setResultSet(io.opnRS("select patientconditions.*, c.description as conditiontypename from patientconditions left join conditions c on patientconditions.conditiontype=c.id where patientconditions.id=" + this.id));
    }

    public String getInputForm(String patientId) throws Exception {
    // Instantiate an RWInputForm and RWHtmlTable object
        rs.beforeFirst();
        RWInputForm frm = new RWInputForm(rs);
        RWHtmlTable htmTb = new RWHtmlTable ("100%", "0");
        htmTb.replaceNewLineChar(false);
        StringBuffer cf = new StringBuffer();
  
        setPatientId(patientId);
        
    // Set display attributes for the input form
        frm.setTableBorder("0");
        frm.setDftTextBoxSize("84");
        frm.setDftTextAreaCols("80");
        frm.setDftTextAreaRows("7");
        frm.setShowDatePicker(true);
        frm.setDisplayDeleteButton(true);
        frm.setLabelBold(true);
        frm.setUpdateButtonText("  save  ");
        frm.setDeleteButtonText("remove");

        if(getUpdateJSP() != null) { frm.setFormUrl(getUpdateJSP() + "?fileName=patientconditions"); }
        
    // If adding a comment, Put the familyId and memberId on the form as hidden fields
        if(id == 0) {
            String [] var       = { "patientid"};
            String [] val       = { patientId};
            frm.setPreLoadFields(var);
            frm.setPreLoadValues(val);
        }

    // Get an input item with the record ID to set the rcd and ID fields
        frm.setCustomDatasource(12, "Select 0 as providerid, '--- Default --' as name union select providerid, name from patientinsurance left join providers on providers.id=patientinsurance.providerid where patientid=" + patientId);
        frm.getInputItem("id");
        cf.append(frm.startForm());
        cf.append(htmTb.startTable());
        cf.append(htmTb.startRow());
        cf.append(htmTb.addCell("<b style='font-size: 12px; font-weight: bold;'>Condition for: " + getPatientInfo() + "</b>", htmTb.CENTER, "colspan=2"));
        cf.append(htmTb.endRow());
        cf.append(htmTb.startRow());
        cf.append(htmTb.addCell("", "colspan=2"));
        cf.append(htmTb.endRow());
        cf.append(htmTb.startRow());
        cf.append(htmTb.addCell("<b>Payer</b>"));
        cf.append(htmTb.addCell(frm.getInputItemOnly("providerid", "style='width: 150;'")));
        cf.append(htmTb.endRow());
        cf.append(htmTb.startRow());
        cf.append(htmTb.addCell("<b>Type</b>"));
        cf.append(htmTb.addCell(frm.getInputItemOnly("conditiontype","") + "&nbsp;&nbsp;&nbsp;<span id='conditionState'><b>State</b> " + frm.getInputItemOnly("state", "style='visibility: visible;'") + "</span>"));
        cf.append(htmTb.endRow());
        cf.append(htmTb.startRow());
        cf.append(htmTb.addCell("<b>Same or Similar</b>"));
        cf.append(htmTb.addCell(frm.getInputItemOnly("sameorsimilar") + "&nbsp;&nbsp;&nbsp;" + frm.getInputItemOnly("similardate")));
        cf.append(htmTb.endRow());
        cf.append(htmTb.startRow());
        cf.append(htmTb.addCell("<b>Referring Doctor</b>"));
        cf.append(htmTb.addCell(frm.getInputItemOnly("referringdoctor", "style='width: 150;'") + "&nbsp;&nbsp;<b>NPI</b>&nbsp;" + frm.getInputItemOnly("referringnpi", "style='width: 80;'")));
        cf.append(htmTb.endRow());
        cf.append(frm.getInputItem("fromdate"));
        cf.append(frm.getInputItem("todate"));
        cf.append(frm.getInputItem("Description"));
        cf.append(frm.getInputItem("Condition"));
        cf.append(htmTb.endTable());
        cf.append(frm.button("  save  ", "class=button onclick=\"formObj=document.getElementById('patientCondition'); processForm(this.parentNode,'SAVE'," + refreshObject + ");\""));
        if(this.id !=0 ) { cf.append("&nbsp;&nbsp;&nbsp;" + frm.button("  delete  ", "class=button onclick=\"formObj=document.getElementById('patientCondition'); processForm(this.parentNode,'DELETE'," + refreshObject + ");\"")); }
        cf.append("&nbsp;&nbsp;&nbsp;" + frm.button("  cancel  ", "class=button onclick='javascript:showHide(txtHint,\"HIDE\");'"));
        cf.append(frm.showHiddenFields());
        cf.append(frm.endForm());
        
        return cf.toString();
    }
    
    public String getCondition(int id) {
        RWHtmlTable htmTb = new RWHtmlTable ("100%", "0");
        StringBuffer c=new StringBuffer();
        String editScript="";
        setId(id);

        if(this.isEditMode()) { editScript=" onMouseOver=this.style.cursor='pointer' onMouseOut=this.style.cursor='normal' onClick=showInputForm(event,'ajax/patientcondition.jsp'," + this.id + "," + this.patientId + ",txtHint)"; }
        
        if(this.id != 0) {
            c.append(htmTb.startTable());
            c.append(htmTb.startRow());
            c.append(htmTb.addCell("<b>From:</b>", "style='font-size: 12px; color: #030089;'"));
            c.append(htmTb.addCell(Format.formatDate(this.fromDate,"MM/dd/yy"), "style='font-size: 12px; color: #030089;'"));
            c.append(htmTb.addCell("<b>To:</b>", "style='font-size: 12px; color: #030089;'"));
            c.append(htmTb.addCell(Format.formatDate(this.toDate,"MM/dd/yy"), "style='font-size: 12px; color: #030089;'"));
            c.append(htmTb.endRow());
            c.append(htmTb.startRow());
            c.append(htmTb.addCell("<b>Type:</b> <span id=listType>" + this.getConditionTypeName() + "</span>", "colspan=4 style='font-size: 12px; color: #030089;'"));
            c.append(htmTb.endRow());
            c.append(htmTb.startRow());
            c.append(htmTb.addCell("<b>Description:</b> <span id=listDescription>" + this.description + "</span>", "colspan=4 style='font-size: 12px; color: #030089;'" + editScript));
            c.append(htmTb.endRow());
            c.append(htmTb.startRow());
            c.append(htmTb.addCell("<div id=listCondition style='height: 80; overflow: auto; font-size: 12px; color: #030089;'" + editScript + ">" + this.condition + "</div>", "colspan=4"));
            c.append(htmTb.endRow());
            c.append(htmTb.endTable());
        } else {
            c.append(htmTb.startTable());
            c.append(htmTb.startRow());
            c.append(htmTb.addCell("<b>From:</b>", "style='font-size: 12px; color: #030089;'"));
            c.append(htmTb.addCell("", "style='font-size: 12px; color: #030089;'"));
            c.append(htmTb.addCell("<b>To:</b>", "style='font-size: 12px; color: #030089;'"));
            c.append(htmTb.addCell("", "style='font-size: 12px; color: #030089;'"));
            c.append(htmTb.endRow());
            c.append(htmTb.startRow());
            c.append(htmTb.addCell("<b>Description:</b> <div id=listDescription></div>", "colspan=4 style='font-size: 12px; color: #030089;'"));
            c.append(htmTb.endRow());
            c.append(htmTb.startRow());
            c.append(htmTb.addCell("<div id=listCondition style='height: 80; overflow: auto; font-size: 12px; color: #030089;'></div>", "colspan=4"));
            c.append(htmTb.endRow());
            c.append(htmTb.endTable());
        }
        
        return c.toString();
    }

    
    public String getConditionForHover(int id) {
        RWHtmlTable htmTb = new RWHtmlTable ("100%", "0");
        StringBuffer c=new StringBuffer();
        String editScript="";
        setId(id);

        if(this.id != 0) {
            try {
                Symptoms s = new Symptoms(io);
                
                c.append(htmTb.startTable());
                c.append(htmTb.startRow());
                c.append(htmTb.addCell("<b>From:</b>", "style='font-size: 12px; color: #030089;'"));
                c.append(htmTb.addCell(Format.formatDate(this.fromDate,"MM/dd/yy"), "style='font-size: 12px; color: #030089;'"));
                c.append(htmTb.addCell("<b>To:</b>", "style='font-size: 12px; color: #030089;'"));
                c.append(htmTb.addCell(Format.formatDate(this.toDate,"MM/dd/yy"), "style='font-size: 12px; color: #030089;'"));
                c.append(htmTb.endRow());
                c.append(htmTb.startRow());
                c.append(htmTb.addCell("<b>Type:</b> <span id=listType>" + this.getConditionTypeName() + "</span>", "colspan=4 style='font-size: 12px; color: #030089;'"));
                c.append(htmTb.endRow());
                c.append(htmTb.startRow());
                c.append(htmTb.addCell("<b>Description:</b> <span id=listDescription>" + this.description + "</span>", "colspan=4 style='font-size: 12px; color: #030089;'"));
                c.append(htmTb.endRow());
                c.append(htmTb.startRow());
                c.append(htmTb.addCell("<div id=listCondition style='height: 80; overflow: auto; font-size: 12px; color: #030089;'>" + this.condition + "</div>", "colspan=4"));
                c.append(htmTb.endRow());
                c.append(htmTb.endTable());
                c.append(s.getConditionSymptomsForHover(this.id));
            } catch (Exception ex) {
                Logger.getLogger(PatientConditions.class.getName()).log(Level.SEVERE, null, ex);
            }
        } else {
            c.append(htmTb.startTable());
            c.append(htmTb.startRow());
            c.append(htmTb.addCell("<b>From:</b>", "style='font-size: 12px; color: #030089;'"));
            c.append(htmTb.addCell("", "style='font-size: 12px; color: #030089;'"));
            c.append(htmTb.addCell("<b>To:</b>", "style='font-size: 12px; color: #030089;'"));
            c.append(htmTb.addCell("", "style='font-size: 12px; color: #030089;'"));
            c.append(htmTb.endRow());
            c.append(htmTb.startRow());
            c.append(htmTb.addCell("<b>Description:</b> <div id=listDescription></div>", "colspan=4 style='font-size: 12px; color: #030089;'"));
            c.append(htmTb.endRow());
            c.append(htmTb.startRow());
            c.append(htmTb.addCell("<div id=listCondition style='height: 80; overflow: auto; font-size: 12px; color: #030089;'></div>", "colspan=4"));
            c.append(htmTb.endRow());
            c.append(htmTb.endTable());
        }
        
        return c.toString();
    }
    
    
    public String getConditionList(boolean previousOnly) {
        StringBuffer conditionList = new StringBuffer();
        RWHtmlTable htmTb = new RWHtmlTable("200", "0");
        String setScript="";
        String editScript="";
        
        try {
            String myQuery = "select * from patientconditions where patientid=" + this.patientId;
            if(previousOnly) { myQuery += " and id<>" + getCurrentCondition(); }
            myQuery += " order by fromdate desc";
            
            ResultSet lRs=this.io.opnRS(myQuery);
            conditionList.append("<div style='width: 100%; height: 70; overflow: auto;'>");
            conditionList.append(htmTb.startTable("94%"));

            while(lRs.next()) {
                if(this.isEditMode()) { 
                    setScript=" onMouseOver=this.style.cursor='pointer' onMouseOut=this.style.cursor='normal' onClick=\"replaceContents(event,'ajax/patientcondition.jsp?set=Y'," + lRs.getString("id") + "," + lRs.getString("patientid") + ",patientCondition); refreshSymptomList(" + lRs.getString("id") + ");\"";
                    editScript=" onMouseOut=showHide(txtHint,'HIDE') onMouseOver=showItem(event,'ajax/patientcondition.jsp?hint=Y'," + lRs.getString("id") + "," + lRs.getString("patientid") + ",txtHint)";
                } else {
                    editScript=" onMouseOut=showHide(txtHint,'HIDE') onMouseOver=showItem(event,'ajax/patientcondition.jsp?hint=Y'," + lRs.getString("id") + "," + lRs.getString("patientid") + ",txtHint)";
//                    editScript=" onMouseOver=this.style.cursor='pointer' onMouseOut=this.style.cursor='normal' onClick=showInputForm(event,'ajax/patientcondition.jsp'," + lRs.getString("id") + "," + lRs.getString("patientid") + ",txtHint)";
                }
                conditionList.append(htmTb.startRow());
                conditionList.append(htmTb.addCell(Format.formatDate(lRs.getString("fromdate"), "MM/yy") + "-" + Format.formatDate(lRs.getString("todate"), "MM/yy"), "width=75 style='font-size: 12px; color: #030089;' " + setScript));
                conditionList.append(htmTb.addCell("", "width=5"));
                conditionList.append(htmTb.addCell(lRs.getString("description"), "width=115 style='font-size: 12px; color: #030089;'" + editScript));
                conditionList.append(htmTb.endRow());
            }
            conditionList.append(htmTb.endTable());
            conditionList.append("</div>");

            lRs.close();
            lRs=null;
        } catch (Exception e) {
            
        }
        return conditionList.toString();
    }
    
    public String getConditionList() {
        return getConditionList(false);
    }
    
    public String getConditionList(int patientId) {
        setPatientId(patientId);
        return getConditionList();
    }
    
    public String getConditionList(String patientId) {
        try {
            setPatientId(patientId);
        } catch (Exception e) {
        }
        return getConditionList();
    }
    
    public String getPreviousConditionList(int patientId) {
        setPatientId(patientId);
        return getConditionList(true);
    }
    
    public String getPreviousConditionList(String patientId) {
        try {
            setPatientId(patientId);
        } catch (Exception e) {
        }
        return getConditionList(true);
    }
    
    private String getPatientInfo() throws Exception {
        String info="";
        if(patientId != 0) {
            ResultSet lRs=io.opnRS("Select concat(firstname, ' ', lastname) as name from patients where id=" + this.patientId);
            if(lRs.next()) { info=lRs.getString("name"); }
            lRs.close();            
        } else if(id != 0) {
            ResultSet lRs=io.opnRS("select concat(firstname, ' ', lastname) as name  from patientconditions left join patients on patients.id=patientconditions.patientid where patientconditions.id=" + this.id);
            if(lRs.next()) { info=lRs.getString("name"); }
            lRs.close();                        
        }
        return info;
    }
    
    public int getCurrentCondition() {
        try {
            boolean autoCreateCondition=true;
            if(io == null || io.getConnection().isClosed()) {
                if(io.getConnection() == null) {
                    io.setConnection(io.opnmySqlConn());
                } else {
                    io.getConnection().close();
                    io.setConnection(null);
                    io.setConnection(io.opnmySqlConn());
                }
            }
            ResultSet lRs=io.opnRS("select id from patientconditions where patientid=" + this.patientId + " order by fromdate desc");
            if(lRs.next()) { 
                setId(lRs.getInt("id")); 
            } else {
                ResultSet envRs=io.opnRS("select * from environment");
                if(envRs.next()) { autoCreateCondition=envRs.getBoolean("autocreatecondition"); }
                if(autoCreateCondition) {
                    // This patient does not have a condition so create one so that the patinet has a condition for the initial date of service
                    String queryString="insert into patientconditions (patientid, conditiontype, description, `condition`, fromdate, todate, sameorsimilar, `state`) " +
                            "select " + this.patientId + ", 1,'Initial Visit', 'Auto-Generated by ChiroPractice', " +
                            "ifnull((select min(`date`) from visits where patientid=" + this.patientId + "),current_date), Date_Add(current_date, interval 1 year),0,''";
                    PreparedStatement lPs=io.getConnection().prepareStatement(queryString);
                    lPs.execute();
                    io.setMySqlLastInsertId();
                    setId(io.getLastInsertedRecord());
                }
            }
            lRs.close();
            lRs=null;
        } catch (Exception e) {
            System.out.println(io.getLibraryName() + blanks.substring(io.getLibraryName().length()) + ": " + new java.util.Date() + " - PatientConditions.getCurrentCondition() (" + e.getMessage() + ")");

        }
        return this.id;
    }
    
    public int getCurrentCondition(String patientId) {
        setPatientId(patientId);
        return getCurrentCondition();
    }
    
    public void update() throws Exception {
        setResultSet(io.opnUpdatableRS("select * from patientconditions where id=" + id));
        this.rs.beforeFirst();
        if (this.rs.next()) {
            updateTableColumns();
            this.rs.updateRow();
        } else {
            this.rs.moveToInsertRow();
            updateTableColumns();
            this.rs.insertRow();
        }
    }
    
    private void updateTableColumns() {
        try {
            if(this.fromDate.equals("0000-00-00")) { this.fromDate=Format.formatDate(new java.util.Date(), "yyyy-MM-dd"); }
            
            if(this.toDate.equals("0000-00-00")) { this.toDate="2999-12-31"; }

            if(this.similarDate.equals("0000-00-00")) { this.similarDate="0001-01-01"; }
            
            this.rs.updateInt("patientid", this.patientId);
            this.rs.updateInt("conditiontype", this.conditionType);
            this.rs.updateString("description", this.description);
            this.rs.updateString("condition", this.condition);
            this.rs.updateString("fromdate", this.fromDate);
            this.rs.updateString("todate", this.toDate);
            this.rs.updateInt("sameorsimilar", this.sameOrSimilar);
            this.rs.updateString("state", this.state);
            this.rs.updateString("similarDate", this.similarDate);
            this.rs.updateString("referringdoctor", this.referringDoctor);
            this.rs.updateString("referringnpi", this.referringNPI);
            this.rs.updateInt("providerid", this.providerId);
        } catch (Exception e) {
        }
    }
    
    public boolean delete() {
        boolean rowDeleted = true;
        try {
            io.getConnection().prepareStatement("delete from patientconditions where id=" + this.id).execute();
        } catch(Exception e) {
            rowDeleted = false;
        }
        
        return rowDeleted;
    }
    
    public boolean delete(int id) {
        setId(id);
        return delete();
    }
    
    private void refresh() {
//        this.id=0;
        this.patientId=0;
        this.conditionType=0;
        this.description=null;
        this.condition=null;
        this.fromDate=null;
        this.toDate=null;
        try {
            this.rs=io.opnRS("select patientconditions.*, c.description as conditiontypename from patientconditions left join conditions c on patientconditions.conditiontype=c.id where patientconditions.id=" + this.id);
            if(this.rs.next()) {
//                setId(this.rs.getInt("id"));
                setPatientId(this.rs.getInt("patientid"));
                setConditionType(this.rs.getInt("conditiontype"));
                setDescription(this.rs.getString("description"));
                setCondition(this.rs.getString("condition"));
                setFromDate(this.rs.getString("fromdate"));
                setToDate(this.rs.getString("todate"));
                setSameOrSimilar(this.rs.getString("sameorsimilar"));
                setState(this.rs.getString("state"));
                setConditionTypeName(this.rs.getString("conditiontypename"));
                setProviderId(this.rs.getInt("providerid"));
            }
        } catch (Exception e) {
            System.out.println(e.getMessage());
        }
    }
      
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
        refresh();
    }
    
    public void setId(String id) {
        setId(Integer.parseInt(checkStringValueIsNumeric(id)));
    }

    public int getPatientId() {
        return patientId;
    }

    public void setPatientId(int patientId) {
        this.patientId = patientId;
    }
    
    public void setPatientId(String patientId) {
        setPatientId(Integer.parseInt(checkStringValueIsNumeric(patientId)));
    }
    
    public int getConditionType() {
        return conditionType;
    }

    public void setConditionType(int conditionType) {
        this.conditionType = conditionType;
    }
    
    public void setConditionType(String conditionType) {
        setConditionType(Integer.parseInt(checkStringValueIsNumeric(conditionType)));
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getCondition() {
        return condition;
    }

    public void setCondition(String condition) {
        this.condition = condition;
    }

    public String getFromDate() {
        return fromDate;
    }

    public void setFromDate(String fromDate) {
        this.fromDate = fromDate;
    }
    
    public void setFromDate(java.util.Date fromDate) {
        setFromDate(Format.formatDate(fromDate, "yyyy-mm-dd"));
    }

    public String getToDate() {
        return toDate;
    }

    public void setToDate(String toDate) {
        this.toDate = toDate;
    }
    public void setToDate(java.util.Date toDate) {
        setToDate(Format.formatDate(toDate, "yyyy-mm-dd"));
    }

    public boolean isEditMode() {
        return editMode;
    }

    public void setEditMode(boolean editMode) {
        this.editMode = editMode;
    }

    /**
     * @return the sameOrSimilar
     */
    public int getSameOrSimilar() {
        return sameOrSimilar;
    }

    /**
     * @param sameOrSimilar the sameOrSimilar to set
     */
    public void setSameOrSimilar(int sameOrSimilar) {
        this.sameOrSimilar = sameOrSimilar;
    }

    /**
     * @param sameOrSimilar the sameOrSimilar to set
     */
    public void setSameOrSimilar(String sameOrSimilar) {
        try {
            if(sameOrSimilar.equals("1") || sameOrSimilar.equals("on") || sameOrSimilar.equals("true")) {
                this.sameOrSimilar=1;
            } else {
                this.sameOrSimilar=0;
            }
        } catch (Exception e) {
            this.sameOrSimilar=0;
        }
    }

    /**
     * @return the state
     */
    public String getState() {
        return state;
    }

    /**
     * @param state the state to set
     */
    public void setState(String state) {
        this.state = state;
    }

    /**
     * @return the conditionTypeName
     */
    public String getConditionTypeName() {
        return conditionTypeName;
    }

    /**
     * @param conditionTypeName the conditionTypeName to set
     */
    public void setConditionTypeName(String conditionTypeName) {
        this.conditionTypeName = conditionTypeName;
    }

    /**
     * @return the similarDate
     */
    public String getSimilarDate() {
        return similarDate;
    }

    /**
     * @param similarDate the similarDate to set
     */
    public void setSimilarDate(String similarDate) {
        this.similarDate = similarDate;
    }

    /**
     * @return the referringDoctor
     */
    public String getReferringDoctor() {
        return referringDoctor;
    }

    /**
     * @param referringDoctor the referringDoctor to set
     */
    public void setReferringDoctor(String referringDoctor) {
        this.referringDoctor = referringDoctor;
    }

    /**
     * @return the referringNPI
     */
    public String getReferringNPI() {
        return referringNPI;
    }

    /**
     * @param referringNPI the referringNPI to set
     */
    public void setReferringNPI(String referringNPI) {
        this.referringNPI = referringNPI;
    }

    /**
     * @param providerId the providerId to set
    */
    public void setProviderId(int providerId) {
        this.providerId=providerId;
    }

    /**
     * @param providerId the providerId to set
    */
    public void setProviderId(String providerId) {
        setProviderId(Integer.parseInt(providerId));
    }

    /**
     * @return the providerId
    */
    public int getProviderId() {
        return this.providerId;
    }
}
