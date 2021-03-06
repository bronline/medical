/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package medical.edi;

import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Hashtable;
import tools.RWConnMgr;

/**
 *
 * @author Randy
 */
public class NSFRecordType {
    public Hashtable fieldList=new Hashtable();
    public ArrayList dataStructure=new ArrayList();
    public RWConnMgr io;
    public String recordType;

    public void setConnMgr(RWConnMgr io) {
        this.io=io;
    }
    
    // Initialize this instance
    public void initialize(String recordType, Hashtable fieldList, ArrayList dataStructure) {
        if(this.recordType==null) { this.recordType=recordType; }
        try {
            ResultSet lRs=io.opnRS("select * from nsfrecorddescriptions where recordtype='" + recordType + "' order by `sequence`");
            while(lRs.next()) {
                dataStructure.add(new char[lRs.getInt("fieldLen")]);
                fieldList.put(lRs.getString("fieldName").trim().replaceAll(" ", "_"), ""+(dataStructure.size()-1));
                setDocumentElement(fieldList, dataStructure, lRs.getString("fieldName").trim().replaceAll(" ", "_"), "");
            }
        } catch (Exception InitializeException) {
            System.out.println("Record type " + recordType + " threw exception during initialization");
        }
    }
    
    public String toString() {
        return getRecord(dataStructure);
    }   


    private String getRecord(ArrayList dataStructure) {
        StringBuffer formattedRecord=new StringBuffer();
        for(int x=0;x<dataStructure.size();x++) {
            char [] temp=(char[])dataStructure.get(x);
            formattedRecord.append(new String(temp));
        }
        return formattedRecord.toString();
    }
    
    public void setDocumentElement(String elementName, String str) {
        setDocumentElement(this.fieldList, this.dataStructure, elementName, str);
    }
    
    public void setDocumentElement(Hashtable fieldList, ArrayList dataStructure, String elementName, String str) {
        try {
        String elementNumber=(String)fieldList.get(elementName);
        char [] element=(char[])dataStructure.get(Integer.parseInt(elementNumber));
        for(int x=0; x<element.length; x++) {
            if(x<str.length()) {
                element[x]=str.charAt(x);
            } else {
                element[x]=' ';
            }
        }
        } catch (Exception SetElementException) {
            System.out.println(this.recordType + " threw an error trying to set element " + elementName);
        }
    }
    
    public String getDocumentElement(String elementName) {
        String returnValue="";
        if(fieldList.containsKey(elementName)) {
            String arrayIndex=(String)fieldList.get(elementName);
            char [] elementValue=(char [])dataStructure.get(Integer.parseInt(arrayIndex));
            returnValue=(new String(elementValue));
        }
        return returnValue;
    }

}
