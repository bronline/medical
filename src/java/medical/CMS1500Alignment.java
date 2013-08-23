/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package medical;

import java.io.File;
import tools.document.Document;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Enumeration;
import tools.RWConnMgr;
import tools.print.FilePrinter;
import tools.print.PDFPrinter;
import tools.print.PagePrinter;
import tools.utils.Pad;

/**
 *
 * @author Randy
 */
public class CMS1500Alignment extends Document {
    
    private RWConnMgr mapIo;
    private PagePrinter pagePrinter=new PagePrinter();
    private FilePrinter filePrinter=new FilePrinter();
    private PDFPrinter pdf = new PDFPrinter();
    private String [][] documentData;
    private String [][] sortedArray;
    private int printType=2;
    private String mapDocument;
    private String textFileLocation;
    private String ediFileLocation;
    private ArrayList repeatingItems=new ArrayList();
    private int currentOffset=0;
    private int currentFormItem=0;
    private int repeatingOffset=24;
    
    public void print() throws Exception {
        fillFormFields(); 
        if(printType == 0) {
            pagePrinter.setStringArray(documentData);
            pagePrinter.setFontPlain();
            pagePrinter.print();
        } else if(printType == 1) {
            filePrinter.setStringArray(documentData);
            filePrinter.setFileName(textFileLocation + "\\0000_0000_0000.txt" );
            filePrinter.setTextFileDimensions(67, 85);
            filePrinter.print();
            filePrinter.setFileName(getEdiFileLocation());
            filePrinter.print();
        } else if(printType == 2) {
            pdf.setStringArray(documentData);
            pdf.getDocument().setMargins(36, 0, 72, 0);
            pdf.print();
            pdf.getDocument().newPage();
//                    fillFormFields(batchId, patientId);
//                    filePrinter.setStringArray(documentData);
//                    filePrinter.setFileName(textFileLocation + "\\" + patientId + "_" + resourceId + "_" + conditionId + ".txt" );
//                    filePrinter.setTextFileDimensions(67, 85);
//                    filePrinter.print();
//                    documentData[documentData.length-1][0]=htmlPageBreak;
//                    filePrinter.setStringArray(documentData);
//                    filePrinter.setFileName(getEdiFileLocation());
//                    filePrinter.print();
        }

    }
    
    private void fillFormFields() throws Exception {
        if(documentFields.size() == 0) {
            ResultSet docRs=getMapIo().opnRS("select * from documentmap where document='" + getMapDocument() + "'");            
            setDocumentMap(docRs);
            docRs.close();
            docRs=null;
        }
        
        for(Enumeration e=this.documentFields.keys(); e.hasMoreElements();) {
            String key=(String)e.nextElement();
            setDocumentFieldValue(key, "X");
        }

        String repeatingData="SELECT 0 as batchid, 0 as chargeid, 0 as patientid, 0 as resourceid, 'XX' as `month`, 'XX' as `day`, 'XX' as `year`, " +
                    "'XX' as placeofservice, 'X' as `type`, 'XXXX' as code, 'XXXX' as diagnosiscode, 99999 as dollars, 99 as cents, 99 as units, 'X' as family, " +
                    "'X' as emg, 'XXXXXXXXX' as cob, 'XXXXX' as modifier, 'X' as idqual, 'XXXXXXXXX' as medicareid, 0 as conditionid ";

        ResultSet repeatingMapRs=getMapIo().opnRS("select * from repeatingmap where document='" + getMapDocument() + "'"); 
        ResultSet repeatingDataRs=getMapIo().opnRS(repeatingData);

        setRepeatingRs(repeatingMapRs, repeatingDataRs);

        for(int a=0;a<repeatingItems.size();a+=6) {
            int numItems=documentFields.size();
            for(int b=a;b<a+6;b++) {
                if(b<repeatingItems.size()) { numItems+=((Document)repeatingItems.get(b)).documentFields.size(); }
            }

            documentData=new String[numItems][4];
            int x=0;

            // Add the repeating items and calculate the total
            Document rpt;

            for(int d=a;d<a+6;d++) {
                if(d<repeatingItems.size()) {
                    rpt=(Document)repeatingItems.get(d);

                    for(Enumeration e=rpt.documentFields.keys(); e.hasMoreElements();) {
                        String key=(String)e.nextElement();
                        documentData[x]=(String [])rpt.documentFields.get(key);
                        x++;    
                    }
                }
            }
            // Add the fields from the main document
            for(Enumeration e=documentFields.keys(); e.hasMoreElements();) {
                String key=(String)e.nextElement();
                try { documentData[x]=(String [])documentFields.get(key); } catch (Exception except) { }
                x++;
            }

        }       
        
        setDocumentFieldValue("totaldollars", "99999");            
        setDocumentFieldValue("totalcents", "99");

        setDocumentFieldValue("paiddollars", "99999");            
        setDocumentFieldValue("paidcents", "99");            

        setDocumentFieldValue("balancedollars", "99999");            
        setDocumentFieldValue("balancecents", "99");

        sortedArray=new String[documentData.length][documentData[0].length];
//            sortedArray = new String[1000][5];
        for(int z=0;z<documentData.length;z++) {
            for(int y=0;y<documentData[z].length;y++) { if(documentData[z][y] == null) { documentData[z][y]=""; } }
        }
        sortArray(documentData, 2, true);
        documentData=sortedArray;            

        
        repeatingDataRs.close();
        repeatingMapRs.close();

    }

    public void setRepeatingRs(ResultSet repeatingMapRs, ResultSet repeatingRs) throws Exception {
        buildRepeatingItems(repeatingMapRs, repeatingRs);
    }
    
    private void buildRepeatingItems(ResultSet repeatingMap, ResultSet repeatingRs) throws Exception {
//        String patientId="";

        repeatingRs.beforeFirst();

        if(repeatingRs.next()) {
            for(int itemCount=0;itemCount<6;itemCount ++) {
                Document document=new Document(repeatingMap);
                document.fillRepeatingFieldsWithData(repeatingRs, currentOffset);
                document.setDocumentFieldValue("frommonth", document.getDocumentFieldValue("month"));
                document.setDocumentFieldValue("fromday", document.getDocumentFieldValue("day"));
                document.setDocumentFieldValue("fromyear", document.getDocumentFieldValue("year"));
                document.setDocumentFieldYCoord("frommonth", document.getDocumentFieldYCoord("month"));
                document.setDocumentFieldYCoord("fromday", document.getDocumentFieldYCoord("day"));
                document.setDocumentFieldYCoord("fromyear", document.getDocumentFieldYCoord("year"));
                repeatingItems.add(document);
                setCurrentOffset(currentOffset + repeatingOffset);
            }
        }

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

    public File checkDir(String dir) {
    // Make the document directory if it doesn't exist
        File documentDir = new File(dir);
        if (!documentDir.exists()) {
            documentDir.mkdir();
        }
        return documentDir;
    }

    public void setEdiFileLocation(String ediFileLocation) {
        this.ediFileLocation = ediFileLocation;
        checkDir(ediFileLocation);
        this.ediFileLocation += "\\" + getMapDocument();
        checkDir(this.ediFileLocation);
        this.ediFileLocation += "\\" + tools.utils.Format.formatDate(new java.util.Date(), "yyyyMMdd") + ".txt";
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
            String [][] ddx=new String[formRow.size()][dd[k].length];
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

    public void setPdfDocument(com.lowagie.text.Document document) {
        pdf.setDocument(document);
    }

    public void setWriter(com.lowagie.text.pdf.PdfWriter writer) {
        pdf.setWriter(writer);
    }

    public RWConnMgr getMapIo() {
        return mapIo;
    }

    public void setMapIo(RWConnMgr mapIo) {
        this.mapIo = mapIo;
    }

    public void setCurrentOffset(int currentOffset) {
        this.currentOffset = currentOffset;
    }

    public void setTextFileLocation(String textFileLocation) {
        this.textFileLocation = textFileLocation;
    }

    public void setRepeatingOffset(int repeatingOffset) {
        this.repeatingOffset = repeatingOffset;
    }

    public void setPagePrinter(PagePrinter pagePrinter) {
        this.pagePrinter = pagePrinter;
    }

}
