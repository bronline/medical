/*
 * CMS1500.java
 *
 * Created on August 6, 2007, 9:34 AM
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package medical;

import java.io.File;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.logging.Level;
import java.util.logging.Logger;
import tools.RWConnMgr;
import tools.document.Document;
import tools.print.FilePrinter;
import tools.print.PDFPrinter;
import tools.print.PagePrinter;
import tools.utils.Format;
import tools.utils.Pad;

/**
 *
 * @author Randy Wandell
 */
public class CMS1500 extends Document {
    private RWConnMgr io;
    private RWConnMgr mapIo;
    private PagePrinter pagePrinter=new PagePrinter();
    private FilePrinter filePrinter=new FilePrinter();
    private ResultSet batchRs;
    private ResultSet repeatingMap;
    private ResultSet repeatingRs;
    private ResultSet patientRs;
    private ResultSet resourceRs;
    private ResultSet providerRs;
    private ResultSet documentRs;
    private ResultSet repeatingMapRs;
    private ResultSet environmentRs;
    private ResultSet conditionRs;
    
    private ArrayList repeatingItems=new ArrayList();
    private Hashtable diagnosisCodes=new Hashtable();
    private int repeatingOffset=24;
    private String ediFileLocation;
    private String ediFileName;

    private int currentBillDate;
    
    private PreparedStatement stm;
    //RKW 11-11-08 - changed to remove cms1500charges
/*    private String codeQry="SELECT d.code FROM cms1500charges c " +
                       "left join items on items.code=c.code " +
                       "left join itemdiagnoses i on i.itemid=items.id " +
                       "left join diagnosiscodes d on d.id=i.diagnosisid " +
                       "where chargeid=?"; */
    private String codeQry="SELECT d.code FROM charges c " +
                        "left join itemdiagnoses i on c.itemid=i.itemid " +
                        "left join diagnosiscodes d on d.id=i.diagnosisid " +
                        "where c.id=? and d.code is not null";
    
    private int resourceId=0;
    private int conditionId=0;
    private String patientId;
    private String providerId;
    private boolean formFieldsSet = false;
    private String [][] documentData;
    private String [][] sortedArray;
    private int currentFormItem=0;
    private int lastChargeId=0;
    
    private String textFileLocation;
    private String mapDocument;
    private int printType = 0;
    private String batchId;
    private String htmlPageBreak = "<p></p>";
    private boolean fileLocationSet = false;

    private String blanks       = "                    ";
    
    private PDFPrinter pdf=new PDFPrinter();

    private Patient patient;

    public boolean allowMultipleDatesPerPage = false;
    
    private String formType;
    private boolean acaForm = false;
    public String box22;

    /** Creates a new instance of CMS1500 */
    public CMS1500() {
    }
    
    public CMS1500(RWConnMgr io, RWConnMgr mapIo) {
        setIo(io);
        setMapIo(mapIo);
    }
    
    public void print(String batchId, String patientId) throws Exception {
        if(!formFieldsSet) { fillFormFields(batchId, patientId); }
        lastChargeId=0;
        this.batchId=batchId;

        ResultSet resourceChargesRs;
        if(allowMultipleDatesPerPage) {
            resourceChargesRs=io.opnRS("select distinct resourceid, conditionid, `year`, `month`, `day` from cms1500charges where patientid=" + patientId + " and batchid=" + batchId + " order by batchid, patientid, `year`*10000+`month`*100+`day`, chargeid, resourceid, conditionid limit 1");
        } else {
            resourceChargesRs=io.opnRS("select distinct resourceid, conditionid, `year`, `month`, `day` from cms1500charges where patientid=" + patientId + " and batchid=" + batchId + " order by batchid, patientid, `year`*10000+`month`*100+`day`, chargeid, resourceid, conditionid");
        }

        while(resourceChargesRs.next()) {
            setResourceId(resourceChargesRs.getInt("resourceid"));
            setConditionId(resourceChargesRs.getInt("conditionid"));
            currentBillDate=resourceChargesRs.getInt("year")*10000+resourceChargesRs.getInt("month")*100+resourceChargesRs.getInt("day");
            setPatientId(patientId);
            if(!allowMultipleDatesPerPage) { lastChargeId=0; }
            buildTemporaryChargesTable();

            do {
                if(printType == 0) {
                    fillFormFields(batchId, patientId); 
                    pagePrinter.setStringArray(documentData);
                    pagePrinter.setFontPlain();
                    pagePrinter.print();
                } else if(printType == 1) {
                    fillFormFields(batchId, patientId); 
                    filePrinter.setStringArray(documentData);
                    checkDir(textFileLocation);
                    filePrinter.setFileName(textFileLocation + "\\" + patientId + "_" + resourceId + "_" + conditionId + ".txt" );
                    filePrinter.setTextFileDimensions(67, 85);
                    filePrinter.print();
                    filePrinter.setFileName(getTextFileLocation() + "\\" + Format.formatDate(new java.util.Date(), "yyyyMMdd") + ".txt");
                    filePrinter.print();
                } else if(printType == 2) {
                    fillFormFields(batchId, patientId); 
                    pdf.setStringArray(documentData);
                    pdf.getDocument().setMargins(36, 0, 72, 0);
                    pdf.print();
                    pdf.getDocument().newPage();
                }
                if(allowMultipleDatesPerPage) {
//                    repeatingRs =  io.opnRS("select * from tempbillingcharges where id > " + lastChargeId + " and patientid=" + patientId + " and batchid=" + batchId + " and resourceid=" + resourceId + " and conditionid=" + getConditionId() + " order by batchid, patientid, resourceid, `year`*10000+`month`*100+`day`, id");
                    repeatingRs =  io.opnRS("select * from tempbillingcharges where chargeId > " + lastChargeId + " and patientid=" + patientId + " and batchid=" + batchId + " and resourceid=" + resourceId + " and conditionid=" + getConditionId() + " order by batchid, patientid, conditionid, resourceid, chargeid");

                } else {
                    repeatingRs =  io.opnRS("select * from tempbillingcharges where id > " + lastChargeId + " and patientid=" + patientId + " and batchid=" + batchId + " and resourceid=" + resourceId + " and conditionid=" + getConditionId() + " and `year`*10000+`month`*100+`day`=" + currentBillDate + " order by batchid, patientid, `year`*10000+`month`*100+`day`, resourceid, conditionid, id");
                }
                
            } while (repeatingRs.next());
            repeatingRs.close();
            repeatingRs=null;
        }
        resourceChargesRs.close();
    }
    
    public String preview(String batchId, String patientId) throws Exception {
//        if(!formFieldsSet) { fillFormFields(batchId, patientId); }
        this.batchId=batchId;
        lastChargeId=0;
        StringBuffer pv=new StringBuffer();
        int pageNumber=1;
        String displayStyle="";
        setMapDocument("CMS1500");
        setRepeatingOffset(24);

        ResultSet tmpBatchRs = io.opnRS("select * from batches where id=" + this.batchId);
        if(tmpBatchRs.next()) {
            allowMultipleDatesPerPage = tmpBatchRs.getBoolean("allowmultipledos");
        }
        tmpBatchRs.close();
        tmpBatchRs = null;

        ResultSet resourceChargesRs;
        if(allowMultipleDatesPerPage) {
            resourceChargesRs=io.opnRS("select distinct resourceid, conditionid, `year`, `month`, `day` from cms1500charges where patientid=" + patientId + " and batchid=" + batchId + " order by batchid, patientid, `year`*10000+`month`*100+`day`, chargeid, resourceid, conditionid limit 1");
        } else {
            resourceChargesRs=io.opnRS("select distinct resourceid, conditionid, `year`, `month`, `day` from cms1500charges where patientid=" + patientId + " and batchid=" + batchId + " order by batchid, patientid, `year`*10000+`month`*100+`day`, chargeid, resourceid, conditionid");
        }

        while(resourceChargesRs.next()) {
            setResourceId(resourceChargesRs.getInt("resourceid"));
            setConditionId(resourceChargesRs.getInt("conditionid"));
            currentBillDate=resourceChargesRs.getInt("year")*10000+resourceChargesRs.getInt("month")*100+resourceChargesRs.getInt("day");
            setPatientId(patientId);
            if(!allowMultipleDatesPerPage) { lastChargeId=0; }
            buildTemporaryChargesTable();

            do {
//                currentBillDate=repeatingRs.getInt("year")*1000+repeatingRs.getInt("month")*100+repeatingRs.getInt("day");
                fillFormFields(batchId, patientId);
                pv.append("<table id=\"page" + pageNumber + "\" width=\"100%\" " + displayStyle + "><tr><td>\n");
                for(int x=0;x<documentData.length;x++) {
                    double leftPosition=0;
//                    try{ leftPosition=Integer.parseInt(documentData[x][1])*1.2; } catch (Exception e) { }
                    try{ leftPosition=Integer.parseInt(documentData[x][1]); } catch (Exception e) { }
                    if(documentData[x][0] == null) { documentData[x][0]=""; }
//                    if(documentData[x][4]== null || documentData[x][4].equals("0")) {
                        pv.append("<div style=\"font-size: 10pt; height: 10pt; font-family: courier new; position: absolute; left: " + leftPosition + "; top: " + documentData[x][2] + ";\">" + documentData[x][0] + "</div>\n");
//                    } else {
//                        pv.append("div style=\"position: absolute; left: " + leftPosition + "; top: " + documentData[x][2] + ";\"><input type=\"text\" name=\"field" + x + "\" value=\"" + documentData[x][0] + "\" size=\"" + documentData[x][4] + "\" style=\"font-size: 10pt; height: 10pt; line-height: 7pt; font-family: courier new;\"></div>\n");
//                    }
                }
                pv.append("</td></tr></table>\n");
                displayStyle="style=\"visibility: hidden; display: none;\"";
                pageNumber ++;
                if(allowMultipleDatesPerPage) {
                    repeatingRs =  io.opnRS("select * from tempbillingcharges where chargeId > " + lastChargeId + " and patientid=" + patientId + " and batchid=" + batchId + " and resourceid=" + resourceId + " and conditionid=" + getConditionId() + " order by batchid, patientid, conditionid, resourceid, chargeid");

                } else {
                    repeatingRs =  io.opnRS("select * from tempbillingcharges where id > " + lastChargeId + " and patientid=" + patientId + " and batchid=" + batchId + " and resourceid=" + resourceId + " and conditionid=" + getConditionId() + " and `year`*10000+`month`*100+`day`=" + currentBillDate + " order by batchid, patientid, `year`*10000+`month`*100+`day`, resourceid, conditionid, id");
                }
//                repeatingRs =  io.opnRS("select * from cms1500charges where chargeId > " + lastChargeId + " and patientid=" + patientId + " and batchid=" + batchId + " and resourceid=" + resourceId + " and conditionid=" + getConditionId() + " order by batchid, patientid, resourceid, chargeid");
//                repeatingRs =  io.opnRS("select * from tempbillingcharges where id > " + lastChargeId + " and patientid=" + patientId + " and batchid=" + batchId + " and resourceid=" + resourceId + " and conditionid=" + getConditionId() + " and `year`*10000+`month`*100+`day`=" + currentBillDate + " order by batchid, patientid, `year`*10000+`month`*100+`day`, resourceid, conditionid, id");


            } while (repeatingRs.next());
            repeatingRs.close();
            repeatingRs=null;
        }
            
        String pageSelection="";
        if(pageNumber>2) {
            String fontWeight="bold";
            for(int p=1;p<pageNumber;p++) {
                pageSelection += "<b onClick=\"showPage(" + p + ")\" id=\"link" + p + "\" style=\"font-weight: " + fontWeight + "; cursor: pointer;\">Page " + p + "</b>&nbsp;&nbsp;\n";
                fontWeight="normal";
            }
        }

        return pageSelection + pv.toString();
    }
    
    private void fillFormFields(String batchId, String patientId) throws Exception {
        currentFormItem=0;
        setBatchRs(batchId);
        setPatientRs(patientId);
        setProviderRs();
        documentFields.clear();
        if(documentFields.size() == 0) {
            ResultSet docRs=mapIo.opnRS("select * from documentmap where document='" + getMapDocument() + "'");            
            setDocumentMap(docRs);
            docRs.close();
            docRs=null;
        }
        
        clearDocumentFieldValues();
        
        repeatingRs=null;
        repeatingMap=null;
        resourceRs=null;
        environmentRs=null;
        repeatingMapRs=null;

        // Get default values from environment table
        environmentRs=io.opnRS("select * from environment");
        if(environmentRs.next()) { 
//            setResourceId(environmentRs.getInt("defaultresource"));
            setDocumentFieldValue("pin", environmentRs.getString("pin"));
            setDocumentFieldValue("grp", environmentRs.getString("grp"));
            setDocumentFieldValue("taxid", environmentRs.getString("taxid"));
            if(this.textFileLocation == null) { setTextFileLocation(); }
            setEdiFileLocation(environmentRs.getString("documentpath"));
            if(this.mapDocument == null) {
                setMapDocument(environmentRs.getString("billingmap"));
                setRepeatingOffset(environmentRs.getInt("billmaprptoffset"));
            }
        }
        
        batchRs=io.opnRS("select * from batches where id=" + batchId);
        if(batchRs.next()) { setProviderId(batchRs.getString("provider")); }

        allowMultipleDatesPerPage = batchRs.getBoolean("allowmultipledos");
        
        documentRs=io.opnRS("select * from cms1500data where id=" + patientId + " and providerid=" + batchRs.getString("provider"));
        if(repeatingMapRs == null) { repeatingMapRs=mapIo.opnRS("select * from rwcatalog.repeatingmap where document='" + getMapDocument() + "'"); }
//        ResultSet repeatingDataRs=io.opnRS("select * from cms1500charges where chargeId > " + lastChargeId + " and patientid=" + patientId + " and batchid=" + batchId + " and resourceid=" + resourceId + " order by batchid, patientid, resourceid, chargeid");
//        ResultSet repeatingDataRs=io.opnRS("select * from tempbillingcharges where id > " + lastChargeId + " and patientid=" + patientId + " and batchid=" + batchId + " and resourceid=" + resourceId + " order by batchid, patientid, resourceid, id");
        ResultSet repeatingDataRs;
        if(allowMultipleDatesPerPage) {
            repeatingDataRs=io.opnRS("select * from tempbillingcharges where chargeId > " + lastChargeId + " and patientid=" + patientId + " and batchid=" + batchId + " and resourceid=" + resourceId + " order by batchid, patientid, conditionid, resourceid, chargeid");
        } else {
            repeatingDataRs=io.opnRS("select * from tempbillingcharges where id > " + lastChargeId + " and patientid=" + patientId + " and batchid=" + batchId + " and resourceid=" + resourceId + " order by batchid, patientid, resourceid, id");
        }
        repeatingMapRs.beforeFirst();
        setRepeatingMap(repeatingMapRs);
        fillFieldsWithData(documentRs);

        documentData=new String[500][4];  // RKW 08/26/2013 - moved to here to accomadate 0 records in repeating recordset
        int x=0;

        setRepeatingRs(repeatingDataRs, patientId);

        for(int a=0;a<repeatingItems.size();a+=6) {
            int numItems=documentFields.size();
            for(int b=a;b<a+6;b++) {
                if(b<repeatingItems.size()) { numItems+=((Document)repeatingItems.get(b)).documentFields.size(); }
            }

//            documentData=new String[500][4]; RKW 8/26/2013 - commented do accomadate 0 records in the repeating recordset
//            int x=0;

            // Add the repeating items and calculate the total
            Document rpt;
            int dollars=0;
            int cents=0;
            for(int d=a;d<a+6;d++) {
                if(d<repeatingItems.size()) {
                    rpt=(Document)repeatingItems.get(d);

                    try { dollars += Integer.parseInt(rpt.getDocumentFieldValue("dollars")); } catch (Exception e) { }
                    try { cents += Integer.parseInt(rpt.getDocumentFieldValue("cents")); } catch (Exception e) { }
                    rpt.setDocumentFieldValue("dollars", Pad.left(rpt.getDocumentFieldValue("dollars"),5," "));
                    for(Enumeration e=rpt.documentFields.keys(); e.hasMoreElements();) {
                        String key=(String)e.nextElement();
                        documentData[x]=(String [])rpt.documentFields.get(key);
                        x++;    
                    }
                }
            }
            
            double dollarsAndCents = ((double)dollars) + ((double)cents/100);
            String dollarAmount=""+dollarsAndCents;
            String centsAmount=dollarAmount.substring(dollarAmount.indexOf(".")+1);
            dollarAmount=dollarAmount.substring(0, dollarAmount.indexOf("."));
            
            if(centsAmount.trim().length()==1) { centsAmount = "0"+centsAmount; }

            setDocumentFieldValue("totaldollars", Pad.left(dollarAmount,5," "));            
            setDocumentFieldValue("totalcents", centsAmount);

            setDocumentFieldValue("paiddollars", Pad.left("0",5," "));            
            
            setDocumentFieldValue("balancedollars", Pad.left(dollarAmount,5," "));            
            setDocumentFieldValue("balancecents", centsAmount);
        }   // RKW 08/26/2013 - moved to here to accomadate 0 records in repeating recordset

        doPatientInformation();
        doInsuredsInformation(patientId);
        doBox9();
        doBox12();
        doBox13();
        doBox14();
        doBox19(patientId);
        doBox20();
        doBox22();
        doBox23();
        doBox25();
        doBox27();
        doBox31();
        doBox32();
        doBox33();

        // Add the fields from the main document
        for(Enumeration e=documentFields.keys(); e.hasMoreElements();) {
            String key=(String)e.nextElement();
            try {
                documentData[x]=(String [])documentFields.get(key);
            } catch (Exception except) {
                System.out.println(io.getSystemName() + blanks.substring(io.getSystemName().length()) + " : " + new java.util.Date() + " - CMS1500 ***** ERROR adding items to main document***** " + except.getMessage());
            }
            x++;
        }

        sortedArray=new String[documentData.length][documentData[0].length];
//            sortedArray = new String[1000][5];
        for(int z=0;z<documentData.length;z++) {
            for(int y=0;y<documentData[z].length;y++) { if(documentData[z][y] == null) { documentData[z][y]=""; } }
        }
        sortArray(documentData, 2, true);
        documentData=sortedArray;

        removeSpecialCharactersFromData(documentData);
//            formFieldsSet=true;
//        } RKW 8/26/2013 - commented do accomadate 0 records in the repeating recordset
        
        documentRs.close();
        repeatingDataRs.close();
        repeatingMapRs.close();
        batchRs.close();
        providerRs.close();
        environmentRs.close();

        providerRs=null;
        documentRs=null;
        repeatingDataRs=null;
        batchRs=null;
        repeatingMapRs=null;
        environmentRs=null;
    }
        
    private void sortArray(String [][] array, int sortField, boolean additionalSort) {
        // find distinct y-coordinates in documentData
        ArrayList sortItem=new ArrayList();
        for(int i=0;i<array.length;i++) { 
            if(!sortItem.contains("00000".substring(array[i][sortField].length())+array[i][sortField])) { 
                sortItem.add("00000".substring(documentData[i][sortField].length()) + documentData[i][sortField]); 
            } 
        }

        String [] dd1=new String[sortItem.size()];
        for(int i=0;i<sortItem.size();i++) {
            dd1[i]=(String)sortItem.get(i);
        }
        Arrays.sort(dd1);

        for(int i=0;i<dd1.length;i++) {
            int k=0;
            ArrayList formRow=new ArrayList();
            String [][] dd=new String[array.length][array[0].length];
            for(int j=0;j<array.length;j++) {
                if(("00000".substring(array[j][sortField].length()) + array[j][sortField]).equals(dd1[i])) {
                    dd[k]=array[j];
                    formRow.add(array[j]);
                    k++;
                }
            }
            String [][] ddx=new String[formRow.size()][dd[0].length];
            for(int j=0;j<ddx.length;j++) { ddx[j]=(String[])formRow.get(j); }
            if(additionalSort && ddx.length>1) { 
                ddx=sortArray(ddx, 1);
            }
            for(int j=0;j<ddx.length;j++) {
                sortedArray[currentFormItem]=ddx[j];
                currentFormItem++;
            }
        }

    }
    
    private String[][] sortArray(String [][] array, int sortField) {
        // find distinct y-coordinates in documentData
        String [][] ddx = new String[1][5];
        ArrayList sortItem=new ArrayList();
        for(int i=0;i<array.length;i++) { 
//            if(!sortItem.contains("00000".substring(array[i][sortField].length())+array[i][sortField])) { 
                sortItem.add("00000".substring(array[i][sortField].length()) + array[i][sortField]); 
//            } 
        }

        String [] dd1=new String[sortItem.size()];
        for(int i=0;i<sortItem.size();i++) {
            dd1[i]=(String)sortItem.get(i);
        }

        Arrays.sort(dd1);

        String [][] dd=new String[array.length][array[0].length];
        ArrayList sortedItems=new ArrayList();
        int k=0;
        
        for(int i=0;i<dd1.length;i++) {
            for(int j=0;j<array.length;j++) {
                if(("00000".substring(array[j][sortField].length()) + array[j][sortField]).equals(dd1[i])) {
                    dd[k]=array[j];
                    sortedItems.add(array[j]);
                    k++;
                    break;
                }
            }
        }
        
        ddx=new String[sortedItems.size()][dd[0].length];
        for(int j=0;j<ddx.length;j++) { ddx[j]=(String[])sortedItems.get(j); }
        
        return ddx;
    }

    private void clearDocumentFieldValues() {
        for(Enumeration e=documentFields.keys(); e.hasMoreElements();) {
            String key=(String)e.nextElement();
            setDocumentFieldValue(key, "");
        }
    }
    
    private void buildRepeatingItems(String patientId) throws Exception {
//        String patientId="";

        repeatingRs.beforeFirst();
//        if(repeatingRs.next()) { patientId=repeatingRs.getString("patientId"); }
        loadPatientDiagnosisCodes(patientId);

        repeatingItems.clear();
        
        stm=io.getConnection().prepareStatement(codeQry);

        repeatingRs.beforeFirst();
        int currentOffset=0;
        int itemCount=0;
        
        while(repeatingRs.next()) {
            if(itemCount == 6) { currentOffset=0; itemCount=0; break;}
//            if(repeatingRs.getInt("resourceid") != resourceId) { setResourceId(repeatingRs.getInt("resourceid")); }
            Document document=new Document(repeatingMap);
            document.fillRepeatingFieldsWithData(repeatingRs, currentOffset);

            String serviceMonth=document.getDocumentFieldValue("month");
            String serviceDay=document.getDocumentFieldValue("day");
            String serviceYear=document.getDocumentFieldValue("year");

            if(serviceMonth.length()<2) { serviceMonth="0" + serviceMonth; document.setDocumentFieldValue("month", serviceMonth); }
            if(serviceDay.length()<2) { serviceDay="0" + serviceDay; document.setDocumentFieldValue("day", serviceDay); }
            if(serviceYear.length()<2) { serviceYear="0" + serviceYear; document.setDocumentFieldValue("year", serviceYear); }

            document.setDocumentFieldValue("frommonth", document.getDocumentFieldValue("month"));
            document.setDocumentFieldValue("fromday", document.getDocumentFieldValue("day"));
            document.setDocumentFieldValue("fromyear", document.getDocumentFieldValue("year"));
            document.setDocumentFieldYCoord("frommonth", document.getDocumentFieldYCoord("month"));
            document.setDocumentFieldYCoord("fromday", document.getDocumentFieldYCoord("day"));
            document.setDocumentFieldYCoord("fromyear", document.getDocumentFieldYCoord("year"));
            document.setDocumentFieldValue("diagnosiscode", checkForDiagnosisCode(repeatingRs.getString("chargeId"), document));
            setItemModifier(repeatingRs, document);
            setProviderCPTCode(repeatingRs, document);
            repeatingItems.add(document);
            currentOffset += repeatingOffset;
            itemCount++;
//            lastChargeId = repeatingRs.getInt("chargeid");
            if(allowMultipleDatesPerPage) {
                lastChargeId = repeatingRs.getInt("chargeid");
            } else {
                lastChargeId = repeatingRs.getInt("id");
            }
            
        }

    }
    
    private void setItemModifier(ResultSet rs, Document document) throws Exception {
        document.setDocumentFieldValue("modifier", "");
        patientRs.beforeFirst();
        if(patientRs.next()) {
            // First, get the item id and modifier from the charge
            ResultSet chgRs=io.opnRS("select itemid, modifier from charges where id=" + rs.getString("chargeid"));
            if(chgRs.next()) {
                if(chgRs.getString("modifier") == null) {
                    // The modifier is not specifically set for the charge so go get it from the hierarchy
                    ResultSet lRs;
                    // First, Check to see if the is a modifier set on the item
                    lRs=io.opnRS("select modifier from items where id=" + chgRs.getString("itemid"));
                    if(lRs.next()) {
                        if(!lRs.getString("modifier").equals("")) { document.setDocumentFieldValue("modifier", lRs.getString("modifier")); }
                    }
                    lRs.close();
                    lRs=null;

                    // Override the item level if there is a modifier for this item at the provider level
                    lRs=io.opnRS("select modifier from defaultpayments where patientid=0 and providerid=" + providerId + " and itemid=" + chgRs.getString("itemid"));
                    if(lRs.next()) {
                        if(!lRs.getString("modifier").equals("")) { document.setDocumentFieldValue("modifier", lRs.getString("modifier")); }
                    }
                    lRs.close();
                    lRs=null;

                    // Finally, override the modifier if there is a modifier set for the patient
                    lRs=io.opnRS("select modifier from defaultpayments where patientid=" + patientRs.getString("id") + " and providerid=" + providerId + " and itemid=" + chgRs.getString("itemid"));
                    if(lRs.next()) {
                        if(!lRs.getString("modifier").equals("")) { document.setDocumentFieldValue("modifier", lRs.getString("modifier")); }
                    }
                    lRs.close();
                    lRs=null;
                } else {
                    // The modifier is specifically set at the charge level so use it
                    document.setDocumentFieldValue("modifier", chgRs.getString("modifier"));
                }
            }
            
            chgRs.close();
            chgRs=null;
        }
    }

    private void setProviderCPTCode(ResultSet rs, Document document) throws Exception {
        patientRs.beforeFirst();
        if(patientRs.next()) {
            // First, get the item id for the charge
            ResultSet chgRs=io.opnRS("select itemid from charges where id=" + rs.getString("chargeid"));
            if(chgRs.next()) {
                // Check to see if there is a CPT code for this item at the provider level
                ResultSet lRs=io.opnRS("select code from defaultpayments where patientid=0 and providerid=" + providerId + " and itemid=" + chgRs.getString("itemid"));
                if(lRs.next()) {
                    if(!lRs.getString("code").equals("")) { document.setDocumentFieldValue("code", lRs.getString("code")); }
                }
                
                lRs.close();
                lRs=null;
            }
            chgRs.close();
            chgRs=null;
        }
    }

    public void loadPatientDiagnosisCodes(String patientId) throws Exception {
        diagnosisCodes.clear();
        
//        String sqlStatement="SELECT s.diagnosisid, c.code FROM patientsymptoms s " +
//                            "join diagnosiscodes c on s.diagnosisid=c.id " +
//                            "where s.patientid=" + patientId + " order by s.sequence";

        String sqlStatement="SELECT s.diagnosisid, c.code FROM patientsymptoms s " +
                            "join diagnosiscodes c on s.diagnosisid=c.id " +
                            "where s.conditionid=" + getConditionId() +
                            " order by s.sequence";
        
        PreparedStatement lPs=io.getConnection().prepareStatement(sqlStatement);
        ResultSet lRs=lPs.executeQuery();
        
        int currentCode=1;
        int maxCode = 5;
        if(isACAForm()) { maxCode = 13; }
        while(lRs.next() && currentCode<maxCode) {
            String code=lRs.getString("code");
            String subCode="";
            
            try {
                subCode=code.substring(code.indexOf(".") +1);
                code=code.substring(0, code.indexOf("."));
            } catch (Exception subCodeException) {
            }

            if(maxCode==13) {
                setDocumentFieldValue("21_" + currentCode + "a", lRs.getString("code"));
            } else {
                setDocumentFieldValue("21_" + currentCode + "a", code);
                setDocumentFieldValue("21_" + currentCode + "b", subCode);
            }
            
            diagnosisCodes.put(lRs.getString("code"), ""+currentCode);
            currentCode ++;
        }
        
        lRs.close();
        lRs=null;
    }
    
    private String checkForDiagnosisCode(String chargeId, Document document) {
        String codeList="";
        String [] codes=new String[diagnosisCodes.size()];
        int numberOfCodesFound=0;
    
        try {
            stm.setString(1, chargeId);
            int totalPossibleCodes = 4;
            if(isACAForm()) { totalPossibleCodes=12; }
            ResultSet tmpCodes=stm.executeQuery();
            while(tmpCodes.next() && numberOfCodesFound<totalPossibleCodes) {
                if(diagnosisCodes.containsKey(tmpCodes.getString("code"))) {
                    String codeId=(String)diagnosisCodes.get(tmpCodes.getString("code"));
                    if(codeList.indexOf(codeId)<0) {
                        codeList += codeId;
                        codes[numberOfCodesFound]=codeId;
                        numberOfCodesFound ++;
                    }
                } 
            }
            tmpCodes.close();
            tmpCodes=null;
        } catch (Exception e){
        }
                       
        for(int x=0;x<codes.length;x++) { if(codes[x] == null) { codes[x]=""; } }
        
        if(codes != null && codes.length>0) { Arrays.sort(codes); }
        codeList="";
        for(int x=0;x<codes.length;x++) { codeList += codes[x]; }

        if(codeList.equals("") && !isACAForm()) {
            if(diagnosisCodes.size()>=4) { codeList="1234"; }
            else if(diagnosisCodes.size()==3) { codeList="123"; }
            else if(diagnosisCodes.size()==2) { codeList="12"; }
            else { codeList="1"; }
        } else if(codeList.equals("") && isACAForm()) {
            document.setDocumentFieldValue("diagnosiscode1", "");
            if(diagnosisCodes.size()>=12) { document.setDocumentFieldValue("diagnosiscode1", "ABCDEF"); codeList="GHIJKL"; }
            else if(diagnosisCodes.size()==11) { document.setDocumentFieldValue("diagnosiscode1", "ABCDEF"); codeList="GHIJK"; }
            else if(diagnosisCodes.size()==10) { document.setDocumentFieldValue("diagnosiscode1", "ABCDEF"); codeList="GHIJ"; }
            else if(diagnosisCodes.size()==9) { document.setDocumentFieldValue("diagnosiscode1", "ABCDEF"); codeList="GHI"; }
            else if(diagnosisCodes.size()==8) { document.setDocumentFieldValue("diagnosiscode1", "ABCDEF"); codeList="GH"; }
            else if(diagnosisCodes.size()==7) { document.setDocumentFieldValue("diagnosiscode1", "ABCDEF"); codeList="G"; }
            else if(diagnosisCodes.size()==6) { codeList="ABCDEF"; }
            else if(diagnosisCodes.size()==5) { codeList="ABCDE"; }
            else if(diagnosisCodes.size()==4) { codeList="ABCD"; }
            else if(diagnosisCodes.size()==3) { codeList="ABC"; }
            else if(diagnosisCodes.size()==2) { codeList="AB"; }
            else { codeList="A"; }
        }
        
        return codeList;
    }
    
    private void removeSpecialCharactersFromData(String [][] documentData) {
        for(int x=0;x<documentData.length;x++) {
            if(documentData[x][0] != null) {
                documentData[x][0]=documentData[x][0].replaceAll("\r","");
                documentData[x][0]=documentData[x][0].replaceAll("\n","");
            }
        }
    }
    
    private void doPatientInformation() throws Exception {
        patientRs.beforeFirst();
        if(patientRs.next()) {
            // Check to see if the patient has an insurance record with this provider on it
            ResultSet patInfoRs=io.opnRS("select * from insuranceinformation where patientid=" + this.patientId + " and providerid=" + providerId);
            if(patInfoRs.next()) {
                setDocumentFieldsFromResultSet(patInfoRs);
            } else {
                // Check to see if the patient insurance info is derrived from the billing account
                patInfoRs.close();
                patInfoRs=null;
                patInfoRs=io.opnRS("select * from insuranceinformation where patientid in (select id from patients where accountnumber='" + patientRs.getString("billingaccount") + "')");
                if(patInfoRs.next()) { setDocumentFieldsFromResultSet(patInfoRs); }
            }
            setDocumentFieldValue("patientname", patientRs.getString("lastname").trim() + ", " + patientRs.getString("firstname"));
            setDocumentFieldValue("patientaddress", patientRs.getString("address"));
            setDocumentFieldValue("patientcity", patientRs.getString("city"));
            setDocumentFieldValue("patientstate", patientRs.getString("state"));
            setDocumentFieldValue("patientzip", patientRs.getString("zipcode"));
            try {
                setDocumentFieldValue("patientareacode", patientRs.getString("homephone").substring(0,3));
                setDocumentFieldValue("patientphone", patientRs.getString("homephone").substring(3));
            } catch (Exception patientPhoneException) {
            }

            setDocumentFieldValue("patientbirthyear", "");
            setDocumentFieldValue("patientbirthmonth", "");
            setDocumentFieldValue("patientbirthday", "");
            
            if(!patientRs.getString("dob").equals("0001-01-01")) {
                setDocumentFieldValue("patientbirthyear", patientRs.getString("dob").substring(0,4));
                setDocumentFieldValue("patientbirthmonth", patientRs.getString("dob").substring(5,7));
                setDocumentFieldValue("patientbirthday", patientRs.getString("dob").substring(8));
            }

            patInfoRs.close();
            patInfoRs=null;
            
            patInfoRs=io.opnRS("select * from billingaccounts where id=" + patientRs.getString("id"));
            if(patInfoRs.next()) { setDocumentFieldsFromResultSet(patInfoRs); }

            patInfoRs.close();
            patInfoRs=null;
        }
    }
    
    private void doBox9() {
        try {
            repeatingRs.beforeFirst();
            if(repeatingRs.next()) {
                String insuranceQuery="select *, " +
                        "case when guarantor='' then " +
                        "case when billingaccount<>'' then billingaccount else accountnumber end else guarantor end as insuredaccount " +
                        "from patientinsurance " +
                        "left join providers on providers.id=patientinsurance.providerid " +
                        "left join patients on patients.id=patientid " +
                        "where patientid=" + repeatingRs.getString("patientId") + " and patientinsurance.active " +
                        "order by primaryprovider";

                setDocumentFieldValue("otherhpno", "X");
                setDocumentFieldValue("otherhpyes", "");
                PreparedStatement bchPs=repeatingRs.getStatement().getConnection().prepareStatement("select * from batches where id=" + repeatingRs.getString("batchid"));
//                PreparedStatement insPs=repeatingRs.getStatement().getConnection().prepareStatement("select * from patientinsurance left join providers on providers.id=patientinsurance.providerid where patientid=" + repeatingRs.getString("patientId") + " order by primaryprovider desc");
                PreparedStatement insPs=repeatingRs.getStatement().getConnection().prepareStatement(insuranceQuery);
                ResultSet insRs=insPs.executeQuery();
                if(insRs.last()) {
                    ResultSet bchRs=bchPs.executeQuery();
                    bchRs.next();
                    int lastProvider=insRs.getRow();
                    insRs.beforeFirst();
                    while(insRs.next()) {
                        if(lastProvider>1 && insRs.getInt("providerid") != bchRs.getInt("provider")) {
                            // First set the fields from the guarantor
                            ResultSet gRs=io.opnAS400RS("select * from patients where accountnumber='" + insRs.getString("insuredaccount") + "'");
                            if(gRs.next()) {
                                setDocumentFieldValue("9", gRs.getString("lastname") + ", " + gRs.getString("firstname"));
                                if(!gRs.getString("dob").equals("0001-01-01")) {
                                    setDocumentFieldValue("9byy", gRs.getString("dob").substring(0,4));
                                    setDocumentFieldValue("9bmm", gRs.getString("dob").substring(5,7));
                                    setDocumentFieldValue("9bdd", gRs.getString("dob").substring(8));                        
                                }                                
                                if(gRs.getInt("gender") == 1) { setDocumentFieldValue("9sexm", "X"); }
                                if(gRs.getInt("gender") == 2) { setDocumentFieldValue("9sexf", "X"); }
                                
                            }
                            gRs.close();
                            gRs=null;
                            
//                            setDocumentFieldValue("9", insRs.getString("hicfa4"));
                            setDocumentFieldValue("9apolicy", insRs.getString("providernumber"));
//                            setDocumentFieldValue("9apolicy", insRs.getString("providergroup"));
                            if(!insRs.getString("hicfa7dob").equals("0001-01-01")) {
                                setDocumentFieldValue("9byy", insRs.getString("hicfa7dob").substring(0,4));
                                setDocumentFieldValue("9bmm", insRs.getString("hicfa7dob").substring(5,7));
                                setDocumentFieldValue("9bdd", insRs.getString("hicfa7dob").substring(8));                        
                            }                                
                            if(insRs.getInt("hicfa7sex") == 1) { setDocumentFieldValue("9sexm", "X"); }
                            if(insRs.getInt("hicfa7sex") == 2) { setDocumentFieldValue("9sexf", "X"); }

                            setDocumentFieldValue("9c", getDocumentFieldValue("employer"));
                            if(insRs.getString("planname") != null && !insRs.getString("planname").trim().equals("")) {
                                setDocumentFieldValue("9d", insRs.getString("planname"));
                            } else {
                                setDocumentFieldValue("9d", insRs.getString("name"));
                            }
                            setDocumentFieldValue("otherhpyes", "X");
                            setDocumentFieldValue("otherhpno", "");
                            break;
                        }
                    }
                    bchRs.close();
                    bchRs=null;
                }
                insRs.close();
                insRs=null;
            }
            
        } catch (Exception e) {
            System.out.println(io.getSystemName() + blanks.substring(io.getSystemName().length()) + " : " + new java.util.Date() + " - CMS1500 ***** ERROR doBox9() ***** " + e.getMessage());
        }
    }
    
    private void doInsuredsInformation(String patientId) throws Exception {
//        if(getDocumentFieldValue("medicare") != null && getDocumentFieldValue("medicare").equals("X")) {
        providerRs.beforeFirst();
        if(providerRs.next()) {
            if(providerRs.getBoolean("showinbox11")) {
                // Set box 11 fields
                setDocumentFieldValue("insuredgroupnumber", "NONE");
                setDocumentFieldValue("otherhpno", "");
                setDocumentFieldValue("providername", "");
                setDocumentFieldValue("employer", "");
                setDocumentFieldValue("insuredmale", "");
                setDocumentFieldValue("insuredbirthyear", "");
                setDocumentFieldValue("insuredbirthmonth", "");
                setDocumentFieldValue("insuredbirthday", "");
                setDocumentFieldValue("otherhpyes", "");
                setDocumentFieldValue("insuredfemale", "");

                // Remove the address info at the top of the form
                setDocumentFieldValue("providername", "");
                setDocumentFieldValue("provideraddress1", "");
                setDocumentFieldValue("provideraddress2", "");
                setDocumentFieldValue("provideraddress3", "");
            } else {
                setInsuredsInformation(patientId);
            }
        } else {
            setInsuredsInformation(patientId);            
        }
    }
    
    private void doBox12() throws Exception {
        if(environmentRs.getInt("defaultAddress")==0) {
            if(resourceRs == null) {
                resourceRs=io.opnRS("select * from resources where id=" + resourceId);
            }
            resourceRs.beforeFirst();
            if(resourceRs.next()) {
                setDocumentFieldValue("12sig", resourceRs.getString("signature"));
                setDocumentFieldValue("12date", tools.utils.Format.formatDate(new java.util.Date(), "yyyyMMdd"));
            }
        } else {
            setDocumentFieldValue("12date", tools.utils.Format.formatDate(new java.util.Date(), "yyyyMMdd"));
            setDocumentFieldValue("12sig", environmentRs.getString("supplierinfo"));
        }
    }
    
    private void doBox13() throws Exception {
        if(environmentRs.getInt("defaultAddress")==0) {
            if(providerRs.getString("box13signature") != null && !providerRs.getString("box13signature").trim().equals("")) {
                setDocumentFieldValue("13sig", providerRs.getString("box13signature"));
            } else if(environmentRs.getString("box13signature") != null && !environmentRs.getString("box13signature").trim().equals("")) {
                setDocumentFieldValue("13sig",environmentRs.getString("box13signature"));
            } else {
                if(resourceRs == null) {
                    resourceRs=io.opnRS("select * from resources where id=" + resourceId);
                }
                resourceRs.beforeFirst();
                if(resourceRs.next()) {
                    setDocumentFieldValue("13sig", resourceRs.getString("signature"));
                }
            }
        } else {
            if(providerRs.getString("box13signature") != null && !providerRs.getString("box13signature").trim().equals("")) {
                setDocumentFieldValue("13sig", providerRs.getString("box13signature"));
            } else if(environmentRs.getString("box13signature") != null && !environmentRs.getString("box13signature").trim().equals("")) {
                setDocumentFieldValue("13sig",environmentRs.getString("box13signature"));
            } else {
                setDocumentFieldValue("13sig",environmentRs.getString("supplierinfo"));
            }
        }
    } 
    
    private void doBox14() throws Exception {
        /* RKW 11/11/08 - Added new Condition stuff
        patientRs.beforeFirst();

        setDocumentFieldValue("14yy", "");
        setDocumentFieldValue("14mm", "");
        setDocumentFieldValue("14dd", "");

        if(patientRs.next()) {
            if(!patientRs.getString("accidentdate").equals("0001-01-01")) {
                setDocumentFieldValue("14yy", patientRs.getString("accidentdate").substring(0,4));
                setDocumentFieldValue("14mm", patientRs.getString("accidentdate").substring(5,7));
                setDocumentFieldValue("14dd", patientRs.getString("accidentdate").substring(8));
            }
        }
        */
        setDocumentFieldValue("14yy", "");
        setDocumentFieldValue("14mm", "");
        setDocumentFieldValue("14dd", "");            
        
        setDocumentFieldValue("employmentno", "X");
        setDocumentFieldValue("employmentyes", "");
        setDocumentFieldValue("autono", "X");
        setDocumentFieldValue("autoyes", "");
        setDocumentFieldValue("otherno", "X");
        setDocumentFieldValue("otheryes", "");
        setDocumentFieldValue("autostate", "");
        
        this.conditionRs=io.opnRS("select * from patientconditions where id=" + this.conditionId);
        if(conditionRs.next()) {
            if(conditionRs.getInt("conditiontype") == 2) { 
                setDocumentFieldValue("employmentno", "");
                setDocumentFieldValue("employmentyes", "X");                
            } else if(conditionRs.getInt("conditiontype") == 3) {
                setDocumentFieldValue("autono", "");
                setDocumentFieldValue("autoyes", "X");                
                setDocumentFieldValue("autostate", conditionRs.getString("state"));
            } else if(conditionRs.getInt("conditiontype") == 4) {
                setDocumentFieldValue("otherno", "");
                setDocumentFieldValue("otheryes", "X");
            }
            
            setDocumentFieldValue("14yy", conditionRs.getString("fromdate").substring(0,4));
            setDocumentFieldValue("14mm", conditionRs.getString("fromdate").substring(5,7));
            setDocumentFieldValue("14dd", conditionRs.getString("fromdate").substring(8));

            if(conditionRs.getBoolean("sameorsimilar")) {
                setDocumentFieldValue("15mm", Format.formatDate(conditionRs.getString("similardate"),"MM"));
                setDocumentFieldValue("15dd", Format.formatDate(conditionRs.getString("similardate"),"dd"));
                setDocumentFieldValue("15yy", Format.formatDate(conditionRs.getString("similardate"),"yyyy"));
            }

            setDocumentFieldValue("box17", conditionRs.getString("referringdoctor"));
            setDocumentFieldValue("box17b", conditionRs.getString("referringnpi"));
        }
        conditionRs.close();
        this.conditionRs = null;
    }

    private void doBox19(String patientId) {

        try {
            StringBuffer codeList=new StringBuffer();
//            String sqlStatement="SELECT diagnosisid, code FROM patientsymptoms " +
//                                "join diagnosiscodes on diagnosisid=diagnosiscodes.id " +
//                                "where patientid=" + patientId + " and code not in(";

            String sqlStatement="SELECT s.diagnosisid, c.code FROM patientsymptoms s " +
                            "join diagnosiscodes c on s.diagnosisid=c.id " +
                            "where s.conditionid=" + getConditionId();
//                            " order by s.sequence";

            boolean firstTime=true;
            for(Enumeration e=diagnosisCodes.keys(); e.hasMoreElements();) {
                if(!firstTime) { codeList.append(", "); }
                codeList.append("'" + (String)e.nextElement() + "'");
                firstTime=false;
            }
            
            if(!firstTime) { sqlStatement += " and c.code not in ("; }

            codeList.append(") order by sequence");

            PreparedStatement lPs=io.getConnection().prepareStatement(sqlStatement + codeList.toString());
            ResultSet lRs=lPs.executeQuery();

            codeList.delete(0,codeList.length());

            while(lRs.next()) {
                codeList.append(lRs.getString("code") + " ");
            }

            lRs.close();
            lRs=null;
            
         // If there is a patient specific override, use it. Otherwise, use the provider level value for box 19
            ResultSet patInfoRs=io.opnRS("select * from patientinsurance where patientid=" + patientId + " and providerid=" + providerId);
            if(patInfoRs.next() && !patInfoRs.getString("hicfabox19").trim().equals("")) {
                setDocumentFieldValue("field19", patInfoRs.getString("hicfabox19"));
            } else {
                patInfoRs.close();
                patInfoRs=null;
                patInfoRs=io.opnRS("select * from insuranceinformation where patientid=" + this.patientId + " and providerid=" + providerId);
                if(patInfoRs.next()) {
                    setDocumentFieldValue("field19", patInfoRs.getString("box19"));
                } else {
                    // Check to see if the patient insurance info is derrived from the billing account
                    patInfoRs.close();
                    patInfoRs=null;
                    patInfoRs=io.opnRS("select * from insuranceinformation where patientid in (select id from patients where accountnumber='" + patientRs.getString("billingaccount") + "')");
                    if(patInfoRs.next()) { setDocumentFieldValue("field19", patInfoRs.getString("box19")); }
                }
            }
                 
            patInfoRs.close();
            patInfoRs=null;

            if(codeList.length()>0) {
                String temp=getDocumentFieldValue("field19");
                setDocumentFieldValue("field19",  codeList.toString() + " " + temp);
            }
        } catch (Exception excpt) {
            System.out.println(io.getSystemName() + blanks.substring(io.getSystemName().length()) + " : " + new java.util.Date() + " - CMS1500 ***** ERROR doBox19() ***** " + excpt.getMessage());
        }        
    }
    
    private void doBox20() {
        setDocumentFieldValue("field20n", "X");
    }
    
    private void doBox22() {
        if(box22 != null) { setDocumentFieldValue("22code", box22); }
    }
    
    private void doBox23() {
        try {
            ResultSet lRs=io.opnRS("select referencenumber from patientinsurance where patientid=" + this.patientId);
            if(lRs.next()) {
                if(lRs.getString("referencenumber")!= null && !lRs.getString("referencenumber").equals("")) { setDocumentFieldValue("23auth", lRs.getString("referencenumber")); }
            }
            lRs.close();
        } catch (Exception e) {
            
        }
    }
    
    private void doBox25() throws Exception {
        int facilityResource=resourceId;
        if(environmentRs.getInt("defaultresource") != 0) { facilityResource=environmentRs.getInt("defaultresource"); }        
        if(resourceRs == null) {
            resourceRs=io.opnRS("select * from resources where id=" + resourceId);
        }
        resourceRs.beforeFirst();
        if(resourceRs.next()) {
            setDocumentFieldValue("taxid", resourceRs.getString("taxid"));
        }
        
        setDocumentFieldValue("taxidssn", "");
        setDocumentFieldValue("taxidein", "");
        if(environmentRs.getInt("ssn")==0) {
            setDocumentFieldValue("taxidein", "X");
        } else {
            setDocumentFieldValue("taxidssn", "X");                                
        }

        if(providerRs == null) {
            providerRs=io.opnRS("select * from providers where providerId=" + providerId);
        }
        providerRs.beforeFirst();
        if(providerRs.next()) {
            if(providerRs.getString("grouptaxid") != null && !providerRs.getString("grouptaxid").equals("")) {
                setDocumentFieldValue("taxid", providerRs.getString("grouptaxid"));
                setDocumentFieldValue("taxidssn", "");
                setDocumentFieldValue("taxidein", "");
                if(providerRs.getInt("isssn")==0) {
                    setDocumentFieldValue("taxidein", "X");
                } else {
                    setDocumentFieldValue("taxidssn", "X");
                }
            }
        }
    }

    private void doBox27() throws Exception {
     // If there is a patient specific override, use it. Otherwise, use the provider level value for box 27
        ResultSet patInfoRs=io.opnRS("select * from patientinsurance where patientid=" + patientId + " and providerid=" + providerId);
        if(patInfoRs.next()) {
            switch (patInfoRs.getInt("hicfaassignment")) {
                case 0:
                    break;
                case 1:
                    setDocumentFieldValue("assignmentyes", "X");
                    setDocumentFieldValue("assignmentno", "");
                    break;
                case 2:
                    setDocumentFieldValue("assignmentyes", "");
                    setDocumentFieldValue("assignmentno", "X");
                    break;
            }
        }
        patInfoRs.close();
        patInfoRs=null;
    }
    
    private void doBox31() throws Exception {
        if(resourceRs == null) {
            resourceRs=io.opnRS("select * from resources where id=" + resourceId);
        }
        resourceRs.beforeFirst();
        if(resourceRs.next()) {
            setDocumentFieldValue("31sig", resourceRs.getString("name"));
        }

        if(batchRs.getString("billed") == null) {
        setDocumentFieldValue("31date", tools.utils.Format.formatDate(new java.util.Date(),"MM dd yyyy"));
        } else {
        setDocumentFieldValue("31date", tools.utils.Format.formatDate(batchRs.getString("billed"),"MM dd yyyy"));
        }
    }
    
    // Supplier Address Information
    private void doBox32() throws Exception {
        ResultSet tmpRs;
        try {
            tmpRs=io.opnRS("select * from supplieraddress where providerid=" + providerId);
        } catch (Exception supplierException) {
            tmpRs=io.opnRS("select * from supplieraddress");
        }
        if(tmpRs.next()) { setDocumentFieldsFromResultSet(tmpRs); }
        tmpRs.close();
        tmpRs=null;

        tmpRs=io.opnRS("  select `r`.`id` AS `resourceid`, CASE WHEN r.officename ='' then `e`.`suppliername` else r.officename end AS `suppliername`, " +
                "case when r.serviceaddress1 = '' then `e`.`supplier` else r.serviceaddress1 end AS `supplier`, " +
                "(case when (isnull(`r`.`serviceaddress2`) or (`r`.`serviceaddress2` = _latin1'')) then substr(`e`.`supplieraddress`,1,(locate(_latin1'\r',`e`.`supplieraddress`) - 1)) else r.serviceaddress2 end) AS `supplieraddress`, " +
                "(case when (isnull(`r`.`servicecity`) or (`r`.`servicecity` = _latin1'')) then substr(`e`.`supplieraddress`,(locate(_latin1'\r',`e`.`supplieraddress`) + 2)) else concat(servicecity,', ',servicestate,'  ',servicezip) end) AS `suppliercsz`, " +
                "CASE WHEN servicephone = 0 then `e`.`supplierphone` else servicephone end AS `supplierphone`, " +
                "CASE WHEN (r.box32a IS NULL OR TRIM(r.box32a)='') AND (r.pin IS NULL OR TRIM(r.pin)='') THEN e.pin ELSE CASE WHEN r.box32a IS NULL OR TRIM(box32a)='' THEN r.pin ELSE r.box32a END END AS `32a` " +
                "from `resources` `r` join `environment` `e` where r.id=" + resourceId);
        if(tmpRs.next()) {
            if(tmpRs.getString("supplier") != null && !tmpRs.getString("supplier").equals("")) { setDocumentFieldValue("supplier", tmpRs.getString("supplier")); }
            if(tmpRs.getString("supplieraddress") != null && !tmpRs.getString("supplieraddress").equals("")) { setDocumentFieldValue("supplieraddress", tmpRs.getString("supplieraddress")); }
            if(tmpRs.getString("suppliercsz") != null && !tmpRs.getString("suppliercsz").equals("")) { setDocumentFieldValue("suppliercsz", tmpRs.getString("suppliercsz")); }
            if(tmpRs.getString("32a") != null && !tmpRs.getString("32a").equals("")) { setDocumentFieldValue("32a", tmpRs.getString("32a")); }
        }
        tmpRs.close();
        tmpRs=null;
    }

    // Facility Address Information
    private void doBox33() throws Exception {
//        ResultSet supplierRs=io.opnRS("select * from supplieraddress");
//        if(supplierRs.next()) {
//            setDocumentFieldsFromResultSet(supplierRs);
//        }
//        supplierRs.close();
//        supplierRs=null;

        if(environmentRs.getInt("defaultaddress")==0) {
            int facilityResource=resourceId;
            if(environmentRs.getInt("defaultresource") != 0) { facilityResource=environmentRs.getInt("defaultresource"); }
            ResultSet tmpRs=io.opnRS("select * from facilityaddress where id=" + facilityResource);
            if(tmpRs.next()) { 
                setDocumentFieldValue("facilityname", tmpRs.getString("facilityname"));
                setDocumentFieldValue("facilityaddress", tmpRs.getString("facilityaddress"));
                setDocumentFieldValue("facilitycsz", tmpRs.getString("facilitycsz"));
                setDocumentFieldValue("practicenpi", tmpRs.getString("practicenpi"));
                setDocumentFieldValue("providernpi", tmpRs.getString("providernpi"));
//                setDocumentFieldsFromResultSet(tmpRs);
            }
            tmpRs.close();
            tmpRs=null;

            ResultSet box33Resource=io.opnRS("select * from resources where id=" + facilityResource);

            if(providerRs == null) {
                documentRs.beforeFirst();
                documentRs.next();
//                providerRs=io.opnRS("select * from providers where id=" + providerId);
            }

            box33Resource.beforeFirst();
            if(box33Resource.next()) {
                String box33a = box33Resource.getString("box33a");
                String box33b = box33Resource.getString("grp");
                if(box33a == null || box33a.trim().equals("")) { box33Resource.getString("pin"); }

                setDocumentFieldValue("supplier", box33Resource.getString("name"));
                setDocumentFieldValue("practicenpi", box33a);
                setDocumentFieldValue("grp", box33b);
            }

            providerRs.beforeFirst();
            if(providerRs.next()) {
                if(providerRs.getString("practice") != null && !providerRs.getString("practice").trim().equals("")) { setDocumentFieldValue("grp", providerRs.getString("practice")); }
                if(providerRs.getString("grouppractice") != null && !providerRs.getString("grouppractice").trim().equals("")) { setDocumentFieldValue("practicenpi", providerRs.getString("grouppractice")); }
                if(providerRs.getString("grouptaxid") != null && !providerRs.getString("grouptaxid").trim().equals("")) { setDocumentFieldValue("taxid", providerRs.getString("grouptaxid")); }                
            }

            box33Resource.close();
            box33Resource=null;
        } else {           
            ResultSet facilityRs=io.opnRS("select * from facilityaddress where id=0");
            if(facilityRs.next()) {
                setDocumentFieldValue("facilityname", facilityRs.getString("facilityname"));
                setDocumentFieldValue("facilityaddress", facilityRs.getString("facilityaddress"));
                setDocumentFieldValue("facilitycsz", facilityRs.getString("facilitycsz"));
                setDocumentFieldValue("practicenpi", facilityRs.getString("practicenpi"));
                setDocumentFieldValue("providernpi", facilityRs.getString("providernpi"));
//                setDocumentFieldsFromResultSet(facilityRs);
            }
            
            providerRs.beforeFirst();
            if(providerRs.next()) {
                if(providerRs.getString("practice") != null && !providerRs.getString("practice").trim().equals("")) { setDocumentFieldValue("providernpi", providerRs.getString("practice")); }
                if(providerRs.getString("grouppractice") != null && !providerRs.getString("grouppractice").trim().equals("")) { setDocumentFieldValue("practicenpi", providerRs.getString("grouppractice")); }
                if(providerRs.getString("grouptaxid") != null && !providerRs.getString("grouptaxid").trim().equals("")) { setDocumentFieldValue("taxid", providerRs.getString("grouptaxid")); }
            }

            facilityRs.close();
            facilityRs=null;
        }

    }
    
    private void setDocumentFieldsFromResultSet(ResultSet rs) throws Exception{
        for(int x=1;x<=rs.getMetaData().getColumnCount();x++) {
            if(documentFields.containsKey(rs.getMetaData().getColumnName(x))) {
                setDocumentFieldValue(rs.getMetaData().getColumnName(x),rs.getString(x));
            }
        }
    }
    
    private void setInsuredsInformation(String patientId) {
            try {
                String patInsQuery="select case when billingaccount is null or billingaccount='' or billingaccount=accountnumber then " +
                                    "  (case when guarantor='' then accountnumber else guarantor end) " +
                                    "  else " +
                                    "  billingaccount " +
                                    "  end as guarantor " +
                                    "from patients " +
                                    "left join patientinsurance on patients.id=patientid where patients.id=" + patientId +
                                    " and patientinsurance.providerid=" + providerId;
                
                ResultSet patInsRs=io.opnRS(patInsQuery);
                if(patInsRs.next()) {
                    String guarantor=patInsRs.getString("guarantor");
                    patInsRs.close();
                    patInsRs=null;
                    // Try to get the insurance info based on the guarantor 
                    patInsRs=io.opnRS("select i.*, (select count(*) from insuranceinformation where patientid=i.patientId) as numberofproviders from insuranceinformation i join patients p on p.id=i.patientid where accountnumber='" + guarantor + "'  and i.providerid=" + providerId );
                    // If the guarantor does not have an insurance record, then check to see if it's held on the patient
                    if(!patInsRs.next()) {
                        patInsRs.close();
                        patInsRs=null;
                        patInsRs=io.opnRS("select *, count(*)  as numberofproviders from insuranceinformation where patientid=" + patientId + " and insuranceinformation.providerid=" + providerId + " group by patientid");
                    }
                    
                    ResultSet baRs=io.opnRS("select * from patients left join gender on patients.gender=gender.id where accountnumber='" + guarantor + "'");
                    
                    if(baRs.next()) {
                        String birthYear="";
                        String birthMonth="";
                        String birthDay="";
                        String otherHpNo="X";
                        String otherHpYes="";
                        String male="";
                        String female="";

                        // Check other healthcare provider
//                        if(patInsRs.getInt("numberofproviders")>1) {
//                            otherHpYes="X";
//                            otherHpNo="";
//                        }

                        // Check DOB information
                        if(!baRs.getString("dob").equals("0001-01-01") && !baRs.getString("dob").equals("1899-12-30")) {
                            birthYear=baRs.getString("dob").substring(0,4);
                            birthMonth=baRs.getString("dob").substring(5,7);
                            birthDay=baRs.getString("dob").substring(8);
                        }

                        try {
                            if(baRs.getString("gender.gender").toUpperCase().equals("MALE")) { male="X"; }
                            if(baRs.getString("gender.gender").toUpperCase().equals("FEMALE")) { female="X"; }
                        } catch (Exception genderException) {
                        }

                        setDocumentFieldValue("insuredname", baRs.getString("lastname").trim() + ", " + baRs.getString("firstname"));
                        setDocumentFieldValue("insuredaddress", baRs.getString("address"));
                        setDocumentFieldValue("insuredcity", baRs.getString("city"));
                        setDocumentFieldValue("insuredstate", baRs.getString("state"));
                        setDocumentFieldValue("insuredzip", baRs.getString("zipcode"));
                        try {
                            setDocumentFieldValue("insuredareacode", baRs.getString("homephone").substring(0,3));
                            setDocumentFieldValue("insuredphonenumber", baRs.getString("homephone").substring(3));
                        } catch (Exception phoneException) {
                        }
                        setDocumentFieldValue("insuredmale", male);
                        setDocumentFieldValue("insuredbirthyear", birthYear);
                        setDocumentFieldValue("insuredbirthmonth", birthMonth);
                        setDocumentFieldValue("insuredbirthday", birthDay);
                        setDocumentFieldValue("insuredfemale", female);

                        patInsRs.beforeFirst();
                        if(patInsRs.next()) {
                            setDocumentFieldValue("insuredgroupnumber", patInsRs.getString("providergroup"));
                            setDocumentFieldValue("providernumber", patInsRs.getString("providernumber"));
                            setDocumentFieldValue("planname", patInsRs.getString("planname"));
                            setDocumentFieldValue("providername", patInsRs.getString("providerName"));
                            setDocumentFieldValue("provideraddress1", patInsRs.getString("provideraddress1"));
                            setDocumentFieldValue("provideraddress2", patInsRs.getString("provideraddress2"));
                            setDocumentFieldValue("provideraddress3", patInsRs.getString("provideraddress3"));
                        }
                    }
                    baRs.close();
                    baRs=null;
                }
                patInsRs.close();
//                patInsRs=null;

                // Now check to see if any of the HICFA fields are overridden for this patient/provider combination
                patInsRs=io.opnRS("select * from patientinsurance where patientid=" + patientId + " and providerid=" + providerId);
                if(patInsRs.next()) {
                    if(!patInsRs.getString("hicfa4").trim().equals("")) { setDocumentFieldValue("insuredname", patInsRs.getString("hicfa4")); }
                    if(!patInsRs.getString("hicfa7address").trim().equals("")) { setDocumentFieldValue("insuredaddress", patInsRs.getString("hicfa7address")); }
                    if(!patInsRs.getString("hicfa7city").trim().equals("")) { setDocumentFieldValue("insuredcity", patInsRs.getString("hicfa7city")); }
                    if(!patInsRs.getString("hicfa7state").trim().equals("")) { setDocumentFieldValue("insuredstate", patInsRs.getString("hicfa7state")); }
                    if(!patInsRs.getString("hicfa7zip").trim().equals("")) { setDocumentFieldValue("insuredzip", patInsRs.getString("hicfa7zip")); }
                    if(patInsRs.getString("hicfa7phone").length()>4) {
                        if(!patInsRs.getString("hicfa7phone").trim().equals("")) { setDocumentFieldValue("insuredareacode", patInsRs.getString("hicfa7phone").substring(0,3)); }
                        if(!patInsRs.getString("hicfa7phone").trim().equals("")) { setDocumentFieldValue("insuredphonenumber", patInsRs.getString("hicfa7phone").substring(3)); }
                    }
                    if(patInsRs.getInt("hicfa7sex") != 0) {
                        setDocumentFieldValue("insuredmale", "");
                        setDocumentFieldValue("insuredfemale", "");
                        if(patInsRs.getInt("hicfa7sex") == 1) { setDocumentFieldValue("insuredmale", "X"); }
                        if(patInsRs.getInt("hicfa7sex") == 2) { setDocumentFieldValue("insuredfemale", "X"); }
                    }
                    if(!patInsRs.getString("hicfa7dob").equals("0001-01-01")) {
                        setDocumentFieldValue("insuredbirthyear", patInsRs.getString("hicfa7dob").substring(0,4));
                        setDocumentFieldValue("insuredbirthmonth", patInsRs.getString("hicfa7dob").substring(5,7));
                        setDocumentFieldValue("insuredbirthday", patInsRs.getString("hicfa7dob").substring(8));                        
                    }
                }
                patInsRs.close();
                patInsRs=null;
            } catch (Exception box11Exception) {
                System.out.println(io.getSystemName() + blanks.substring(io.getSystemName().length()) + " : " + new java.util.Date() + " - CMS1500 ***** ERROR setInsuredsInformation()***** " +box11Exception.getMessage());
            }
    }

    public PagePrinter getPagePrinter() {
        return pagePrinter;
    }

    public void setPagePrinter(PagePrinter pagePrinter) {
        this.pagePrinter = pagePrinter;
    }

    public ResultSet getRepeatingRs() {
        return repeatingRs;
    }

    public void setRepeatingRs(ResultSet repeatingRs, String patientId) throws Exception {
        this.repeatingRs = repeatingRs;
        buildRepeatingItems(patientId);
    }

    public ResultSet getRepeatingMap() {
        return repeatingMap;
    }

    public void setRepeatingMap(ResultSet repeatingMap) {
        this.repeatingMap = repeatingMap;
    }

    public RWConnMgr getIo() {
        return io;
    }

    public void setIo(RWConnMgr io) {
        this.io = io;
    }

    private void setBatchRs(String batchId) throws Exception {
        if(batchRs == null) {
            this.batchRs=io.opnRS("select * from batches where id=" + batchId); 
            if(!batchRs.next()) {
                throw new Exception("Batch " + batchId + " does not exist");
            } else {
                providerId=batchRs.getString("provider");
            }
        }

    }
    
    private void setProviderRs() throws Exception {
        if(providerRs == null) {
            providerRs=io.opnRS("select * from providers where id=" + providerId);
        }
    }
    
    private void setPatientRs(String patientId) throws Exception {
        patientRs=io.opnRS("select * from patients where id=" + patientId);
    }

    public int getRepeatingOffset() {
        return repeatingOffset;
    }

    public void setRepeatingOffset(int repeatingOffset) {
        this.repeatingOffset = repeatingOffset;
    }

    private void setResourceId(int resourceId) {
        this.resourceId = resourceId;
    }

    public String getProviderId() {
        return providerId;
    }

    public void setProviderId(String providerId) {
        this.providerId = providerId;
    }

    public int getConditionId() {
        return conditionId;
    }

    public void setConditionId(int conditionId) {
        this.conditionId = conditionId;
    }

    public RWConnMgr getMapIo() {
        return mapIo;
    }

    public void setMapIo(RWConnMgr mapIo) {
        this.mapIo = mapIo;
    }

    public String getTextFileLocation() {
        return this.textFileLocation;
    }

    public void setTextFileLocation(String textFileLocation) {
        this.textFileLocation=textFileLocation;
        this.fileLocationSet=true;
    }

    public void setTextFileLocation() throws Exception {
        if(!isFileLocationSet()) {
            this.textFileLocation = environmentRs.getString("documentpath");
            checkDir(this.textFileLocation);
            this.textFileLocation += "bills";
            checkDir(this.textFileLocation);
            this.textFileLocation += "\\" + this.batchId;
            checkDir(this.textFileLocation);
            this.textFileLocation += "\\" + tools.utils.Format.formatDate(new java.util.Date(),"yyyy-MM-dd");
            checkDir(textFileLocation);
            this.fileLocationSet=true;
        }
    }

    public File checkDir(String dir) {
    // Make the document directory if it doesn't exist
        File documentDir = new File(dir);
        if (!documentDir.exists()) {
            documentDir.mkdir();
        }
        return documentDir;
    }

    public String getPatientId() {
        return patientId;
    }

    public void setPatientId(String patientId) {
        this.patientId = patientId;
    }

    public String getMapDocument() {
        return mapDocument;
    }

    public void setMapDocument(String mapDocument) {
        this.mapDocument = mapDocument;
    }

    public int getPrintType() {
        return printType;
    }

    public void setPrintType(int printType) {
        this.printType = printType;
    }

    public String getEdiFileLocation() {
        return ediFileLocation;
    }

    public void setEdiFileLocation(String ediFileLocation) {
        this.ediFileLocation = ediFileLocation;
        checkDir(ediFileLocation);
        this.ediFileLocation += getMapDocument();
        checkDir(this.ediFileLocation);
        if(ediFileName == null) {
            this.ediFileLocation += "\\" + tools.utils.Format.formatDate(new java.util.Date(), "yyyyMMdd") + ".txt";
        } else {
            this.ediFileLocation += "\\" + this.ediFileName + ".txt";
        }
    }

    public String getHtmlPageBreak() {
        return htmlPageBreak;
    }

    public void setHtmlPageBreak(String htmlPageBreak) {
        this.htmlPageBreak = htmlPageBreak;
    }

    public void setPdfDocument(com.lowagie.text.Document document) {
        pdf.setDocument(document);
    }

    public void setWriter(com.lowagie.text.pdf.PdfWriter writer) {
        pdf.setWriter(writer);
    }

    /**
     * @return the ediFileName
     */
    public String getEdiFileName() {
        return ediFileName;
    }

    /**
     * @param ediFileName the ediFileName to set
     */
    public void setEdiFileName(String ediFileName) {
        this.ediFileName = ediFileName;
    }

    private void buildTemporaryChargesTable() throws SQLException {
        String queryString="insert into tempbillingcharges " +
                "select null, batchid, chargeid, patientid, resourceid, month, day, year, placeofservice, typeofservice, " +
                "code, diagnosiscode, dollars, cents, units, familyplan, emg, cob, modifier, idqual, medicareid, conditionid, " +
                "box24unusual, '' AS diagnosiscode1 " +
                "from cms1500charges " +
                "where billinsurance<>1 and chargeId > " + lastChargeId + " and patientid=" + patientId +
                " and batchid=" + batchId + " and resourceid=" + resourceId +
                " and conditionid=" + getConditionId() +
                " and `year`*10000+`month`*100+`day`=" + currentBillDate +
                " order by batchid, patientid, resourceid, `year`*10000+`month`*100+`day`, chargeid";

        if(allowMultipleDatesPerPage) {
            queryString = "insert into tempbillingcharges " +
                "select null, batchid, chargeid, patientid, resourceid, month, day, year, placeofservice, typeofservice, " +
                "code, diagnosiscode, dollars, cents, units, familyplan, emg, cob, modifier, idqual, medicareid, conditionid, " +
                "box24unusual, '' AS diagnosiscode1 " +
                "from cms1500charges " +
                "where billinsurance<>1 and chargeId > " + lastChargeId + " and patientid=" + patientId +
                " and batchid=" + batchId + " and resourceid=" + resourceId +
                " and conditionid=" + getConditionId() +
                " order by batchid, patientid, conditionid, resourceid, chargeid";
        }

        PreparedStatement dPs=io.getConnection().prepareStatement("delete from tempbillingcharges where batchid=? and patientid=?");
        PreparedStatement iPs=io.getConnection().prepareStatement(queryString);

        dPs.setString(1, batchId);
        dPs.setString(2, patientId);
        dPs.execute();
        iPs.execute();
    }

    /**
     * @return the fileLocationSet
     */
    public boolean isFileLocationSet() {
        return fileLocationSet;
    }

    /**
     * @param fileLocationSet the fileLocationSet to set
     */
    public void setFileLocationSet(boolean fileLocationSet) {
        this.fileLocationSet = fileLocationSet;
    }

    public boolean isACAForm() {
        if(formType == null) {
            formType = "standard";
            try {
                ResultSet acaFormRs = io.opnRS("select distinct document, ACAForm from rwcatalog.documentmap where document='" + getMapDocument() + "' LIMIT 1");
                if(acaFormRs.next()) { 
                    acaForm = acaFormRs.getBoolean("ACAForm");
                    formType = "ACAForm";
                }
                acaFormRs.close();
                acaFormRs=null;
            } catch (Exception ex) {
                Logger.getLogger(CMS1500.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        return acaForm;
    }
}
