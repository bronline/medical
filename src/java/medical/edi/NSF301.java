/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package medical.edi;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Arrays;
import tools.RWConnMgr;
import tools.utils.Format;

/**
 *
 * @author Randy
 */
public class NSF301 {

    private RWConnMgr io;
    private int EDIBatchId=0;
    private int batchId=0;
    private int providerId=0;
    private int resourceId=0;

    private int bxxCount=0;
    private int cxxCount=0;
    private int dxxCount=0;
    private int exxCount=0;
    private int fxxCount=0;
    private int gxxCount=0;
    private int hxxCount=0;
    
    private int fileRecordCount=0;
    private int fileClaimCount=0;
    private int fileServiceLineCount=0;
    private double fileTotalCharges=0.0;
    private double fileTotalPaidAmount=0.0;
    private double fileTotalApprovedAmount=0.0;
    private int claimRecordCount=0;
    private double totalClaimCharges=0.0;
    private double totalPatientAmount=0.0;
    private double batchTotalCharges=0.0;
    
    private int batchServiceLineCount=0;
    private int batchRecordCount=0;
    private int batchClaimCount=0;
    private int batchTotalCount=0;
    
    private ArrayList ba0List=new ArrayList();
    private ArrayList ba1List=new ArrayList();
    private String EDIBatch;
    private String batch;
    private String emcProviderId;
    
    private ArrayList diagnosisCodes=new ArrayList();
    
    private PreparedStatement stm;

    private String codeQry="SELECT d.code FROM cms1500charges c " +
                       "left join items on items.code=c.code " +
                       "left join itemdiagnoses i on i.itemid=items.id " +
                       "left join diagnosiscodes d on d.id=i.diagnosisid " +
                       "where chargeid=?";
    
    
    public NSF301(RWConnMgr io, ResultSet batchListRs) throws Exception {
        this.io=io;
        stm=io.getConnection().prepareStatement(codeQry);
        getNewEDIBatch();
        formatEDIBatchId();
        FileHeaderRecord aa0=new FileHeaderRecord(io);
        setFileHeader(aa0);
        System.out.println(aa0.toString());
        
        batchListRs.beforeFirst();
        while(batchListRs.next()) {
            setResourceId(batchListRs.getInt("resourceid"));
            setBatchId(batchListRs.getInt("batchid"));
            setProviderId(batchListRs.getInt("providerId"));
            formatBatchId();
            this.bxxCount=0;
            BatchHeaderRecord0 ba0=new BatchHeaderRecord0(this.io);
            BatchHeaderRecord1 ba1=new BatchHeaderRecord1(this.io);
            setBatchHeader(ba0, ba1);
            ba0List.add(ba0);
            ba1List.add(ba1);
            this.bxxCount ++;
        }
        setFileTrailer();
        
    }
    
    private void getNewEDIBatch() throws Exception {
        PreparedStatement lPs=io.getConnection().prepareStatement("insert into edibatch (facilityname) values('test') ");
        lPs.execute();
        ResultSet lRs=io.opnRS("select last_insert_id()");
        if(lRs.next()) { setEDIBatchId(lRs.getInt(1)); }
        lRs.close();
        lRs=null;
        lPs=null;
    }
    
    private void formatEDIBatchId() {
        EDIBatch=""+EDIBatchId;
        EDIBatch="0000".substring(EDIBatch.length())+EDIBatch;
    }
    
    private void formatBatchId() {
        batch=""+batchId;
        batch="0000".substring(batch.length())+batch;
    }
    
    private void setFileHeader(FileHeaderRecord aa0) throws Exception {
        aa0.setDocumentElement(aa0.fieldList, aa0.dataStructure, "Record_ID", "AA0");
        aa0.setDocumentElement(aa0.fieldList, aa0.dataStructure, "Submitter_ID", "123456789");
        aa0.setDocumentElement(aa0.fieldList, aa0.dataStructure, "Submission_Number", EDIBatch);
        aa0.setDocumentElement(aa0.fieldList, aa0.dataStructure, "Receiver_ID", "GATEWAY EDI");
        aa0.setDocumentElement(aa0.fieldList, aa0.dataStructure, "Creation_Date", tools.utils.Format.formatDate(new java.util.Date(), "yyyyMMdd"));
        aa0.setDocumentElement(aa0.fieldList, aa0.dataStructure, "Version_Code_National", "00301");
        aa0.setDocumentElement(aa0.fieldList, aa0.dataStructure, "Test/Prod_Indicator", "TEST");
    }

    private void setBatchHeader(BatchHeaderRecord0 ba0, BatchHeaderRecord1 ba1) throws Exception {
        ResultSet tmpRs=io.opnRS("select * from facilityaddress where id=" + getResourceId());
        if(tmpRs.next()) {
            this.cxxCount=0;
            this.claimRecordCount=0;
            this.totalClaimCharges=0.0;
            this.totalPatientAmount=0.0;
            this.emcProviderId=tmpRs.getString("emcproviderid");
            // Set items on the BA0 record
            ba0.setDocumentElement(ba0.fieldList, ba0.dataStructure, "EMC_Provider_ID", this.emcProviderId);
            ba0.setDocumentElement(ba0.fieldList, ba0.dataStructure, "Prov_Organization_Name", tmpRs.getString("facilityname"));
            ba0.setDocumentElement(ba0.fieldList, ba0.dataStructure, "Legacy_Medicare_Provider_Number", tmpRs.getString("pin"));
            ba0.setDocumentElement(ba0.fieldList, ba0.dataStructure, "Provider_Medicaid_#", tmpRs.getString("pin"));
            ba0.setDocumentElement(ba0.fieldList, ba0.dataStructure, "Provider_Champus_#", tmpRs.getString("pin"));
            ba0.setDocumentElement(ba0.fieldList, ba0.dataStructure, "Provider_Blue_Shield_#", tmpRs.getString("pin"));
            ba0.setDocumentElement(ba0.fieldList, ba0.dataStructure, "Provider_Commercial_#", tmpRs.getString("pin"));
            ba0.setDocumentElement(ba0.fieldList, ba0.dataStructure, "Provider_Last_Name", tmpRs.getString("lastname"));
            ba0.setDocumentElement(ba0.fieldList, ba0.dataStructure, "Provider_First_Name", tmpRs.getString("firstname"));
            ba0.setDocumentElement(ba0.fieldList, ba0.dataStructure, "Provider_Middle_Initial", tmpRs.getString("middleinitial"));
            ba0.setDocumentElement(ba0.fieldList, ba0.dataStructure, "Provider_Tax_ID", tmpRs.getString("taxid"));
            
            // Set items on the BA1 record
            ba1.setDocumentElement(ba1.fieldList, ba1.dataStructure, "EMC_Provider_ID", tmpRs.getString("emcproviderid"));
            ba1.setDocumentElement(ba1.fieldList, ba1.dataStructure, "Provider_Serv_Address_1", tmpRs.getString("serviceaddress1"));
            ba1.setDocumentElement(ba1.fieldList, ba1.dataStructure, "Provider_Serv_Address_2", tmpRs.getString("serviceaddress2"));
            ba1.setDocumentElement(ba1.fieldList, ba1.dataStructure, "Provider_Service_City", tmpRs.getString("servicecity"));
            ba1.setDocumentElement(ba1.fieldList, ba1.dataStructure, "Provider_Service_State", tmpRs.getString("servicestate"));
            ba1.setDocumentElement(ba1.fieldList, ba1.dataStructure, "Provider_Service_Zip", tmpRs.getString("servicezip"));
            ba1.setDocumentElement(ba1.fieldList, ba1.dataStructure, "Provider_Serv_Phone", tmpRs.getString("servicephone"));
            ba1.setDocumentElement(ba1.fieldList, ba1.dataStructure, "Provider_Pay_to_Addr_1", tmpRs.getString("paytoaddress1"));
            ba1.setDocumentElement(ba1.fieldList, ba1.dataStructure, "Provider_Pay_to_Addr_2", tmpRs.getString("paytoaddress2"));
            ba1.setDocumentElement(ba1.fieldList, ba1.dataStructure, "Provider_Pay_to_City", tmpRs.getString("paytocity"));
            ba1.setDocumentElement(ba1.fieldList, ba1.dataStructure, "Provider_Pay_to_State", tmpRs.getString("paytostate"));
            ba1.setDocumentElement(ba1.fieldList, ba1.dataStructure, "Provider_Pay_to_Zip", tmpRs.getString("paytozip"));
            ba1.setDocumentElement(ba1.fieldList, ba1.dataStructure, "Provider_Pay_to_Phone", tmpRs.getString("paytophone"));

        }
        tmpRs.close();
        tmpRs=null;
        
        ba0.setDocumentElement(ba0.fieldList, ba0.dataStructure, "Record_Type", "BA0");
        ba0.setDocumentElement(ba0.fieldList, ba0.dataStructure, "Batch_Type", "100");
        ba0.setDocumentElement(ba0.fieldList, ba0.dataStructure, "Batch_Number", batch);
        ba0.setDocumentElement(ba0.fieldList, ba0.dataStructure, "Batch_ID", "");
        ba0.setDocumentElement(ba0.fieldList, ba0.dataStructure, "Provider_Tax_ID_Type", "E");
        ba0.setDocumentElement(ba0.fieldList, ba0.dataStructure, "Provider_Specialty", "035");

        ba1.setDocumentElement(ba1.fieldList, ba1.dataStructure, "Record_Type", "BA1");
        ba1.setDocumentElement(ba1.fieldList, ba1.dataStructure, "Batch_Type", "100");
        ba1.setDocumentElement(ba1.fieldList, ba1.dataStructure, "Batch_Number", batch);
        ba1.setDocumentElement(ba1.fieldList, ba1.dataStructure, "Batch_ID", "");

        System.out.println(ba0.toString());
        this.batchRecordCount ++;
        this.fileRecordCount ++;
        System.out.println(ba1.toString());
        this.batchRecordCount ++;
        this.fileRecordCount ++;

        setClaimHeader(ba0);
        
        setClaimTrailer();
        setBatchTrailer();
    }
    
    private void setClaimHeader(BatchHeaderRecord0 ba0) {
        String myQuery="select distinct * from batchcharges bc " +
                        "left join charges c on c.id=bc.chargeid " +
                        "left join items i on c.itemid=i.id " +
                        "left join visits v on v.id=c.visitid " +
                        "left join resources rs on rs.id=c.resourceid " +
                        "left join patients p on p.id=v.patientid " +
                        "left join patientinsurance pi on pi.patientid=p.id and primaryprovider=1 " +
                        "left join providers py on py.id=pi.providerid " +
                        "left join providercategory pc on pc.id=py.category " +
                        "left join gender g on g.id=p.gender " +
                        "left join maritalstatus ms on ms.id=p.maritalstatus " +
                        "left join occupation o on o.id=p.occupationid " +
                        "left join relationship r on r.id=pi.relationshipid " +
                        "join environment " +
                        "join edisupplierinfo " +
                        "where batchid=" + this.batchId + " and c.resourceid=" + this.resourceId +
                        " order by p.id";
        
        try {
            ResultSet chargeRs=io.opnRS(myQuery);
            while(chargeRs.next()) {
                this.dxxCount=0;
                this.exxCount=0;
                this.fxxCount=0;
                this.totalClaimCharges=0.0;
                this.totalPatientAmount=0.0;
                this.batchClaimCount++;
                
                this.fileClaimCount ++;
                
                ClaimHeaderRecord ca0=new ClaimHeaderRecord(this.io);
                ca0.setDocumentElement(ca0.fieldList, ca0.dataStructure, "Record_ID", "CA0");
                ca0.setDocumentElement(ca0.fieldList, ca0.dataStructure, "Patient_Control_Number", chargeRs.getString("accountnumber"));
                ca0.setDocumentElement(ca0.fieldList, ca0.dataStructure, "Patient_Last_Name", chargeRs.getString("lastname"));
                ca0.setDocumentElement(ca0.fieldList, ca0.dataStructure, "Patient_First_Name", chargeRs.getString("firstname"));
                ca0.setDocumentElement(ca0.fieldList, ca0.dataStructure, "Patient_Middle_Initial", chargeRs.getString("middlename"));
                ca0.setDocumentElement(ca0.fieldList, ca0.dataStructure, "Patient_Generation", chargeRs.getString("suffix"));
                ca0.setDocumentElement(ca0.fieldList, ca0.dataStructure, "Patient_Date_of_Birth", chargeRs.getString("dob"));
                ca0.setDocumentElement(ca0.fieldList, ca0.dataStructure, "Patient_Sex_Code", chargeRs.getString("g.code"));
                ca0.setDocumentElement(ca0.fieldList, ca0.dataStructure, "Patient_Address_1", chargeRs.getString("address"));
                ca0.setDocumentElement(ca0.fieldList, ca0.dataStructure, "Patient_City", chargeRs.getString("city"));
                ca0.setDocumentElement(ca0.fieldList, ca0.dataStructure, "Patient_State", chargeRs.getString("state"));
                ca0.setDocumentElement(ca0.fieldList, ca0.dataStructure, "Patient_Zip_Code", chargeRs.getString("zipcode"));
                ca0.setDocumentElement(ca0.fieldList, ca0.dataStructure, "Patient_Telephone_No", chargeRs.getString("homephone"));
                ca0.setDocumentElement(ca0.fieldList, ca0.dataStructure, "Patient_Marital_Status", chargeRs.getString("ms.code"));
                ca0.setDocumentElement(ca0.fieldList, ca0.dataStructure, "Patient_Student_Status", getEDIStudentStatus(chargeRs.getString("employer")));
                ca0.setDocumentElement(ca0.fieldList, ca0.dataStructure, "Patient_Employment_Status", chargeRs.getString("occupationid"));
                ca0.setDocumentElement(ca0.fieldList, ca0.dataStructure, "Other_Insurance", getEDIOtherInsuranceIndicator(chargeRs.getString("p.id")));
                ca0.setDocumentElement(ca0.fieldList, ca0.dataStructure, "Claim_Editing_Indicator/Plan_Type", chargeRs.getString("pc.code"));

                System.out.println(ca0.toString());
                ba0.ca0List.add(ca0);
                this.cxxCount ++;
                this.claimRecordCount ++;
                this.fileRecordCount ++;
                this.batchRecordCount++;
                setInsuranceHeader(ca0, chargeRs);
                getDiagnosisCodes(chargeRs.getString("p.id"));
                setClaimDataRecord(chargeRs);

                // the following is temporary
                int segmentSequenceNumber=1;
                getClaimRootSegment(chargeRs, segmentSequenceNumber);
                while(chargeRs.next()) {
                    segmentSequenceNumber ++;
                    getClaimRootSegment(chargeRs, segmentSequenceNumber);
                }
            }
            chargeRs.close();

        } catch (Exception CA0Exception) {
            System.out.println("Error Creating CA0 Record - " + CA0Exception.getMessage());
        }
    }
    
    private void setInsuranceHeader(ClaimHeaderRecord ca0, ResultSet chargeRs) {
        try {
            String sequenceNumber="" + (ca0.da0List.size()+1);
            sequenceNumber="00".substring(sequenceNumber.length()) + sequenceNumber;
            
            this.exxCount=0;

            InsuranceInformationRecord da0=new InsuranceInformationRecord(this.io);
            da0.setDocumentElement(da0.fieldList, da0.dataStructure, "Record_ID", "DA0");
            da0.setDocumentElement(da0.fieldList, da0.dataStructure, "Sequence_Number", sequenceNumber);
            da0.setDocumentElement(da0.fieldList, da0.dataStructure, "Patient_Control_Number", chargeRs.getString("accountnumber"));
            da0.setDocumentElement(da0.fieldList, da0.dataStructure, "Claim_Filing_Indicator", "I");
            da0.setDocumentElement(da0.fieldList, da0.dataStructure, "Source_of_Payment", chargeRs.getString("pc.code"));
  
            // Needs to be checked
            da0.setDocumentElement(da0.fieldList, da0.dataStructure, "Insurance_Type_Code", "12");
            // Needs to be checked
            da0.setDocumentElement(da0.fieldList, da0.dataStructure, "Payer_Organization_ID", "XXXX");
            // Needs to be checked
            da0.setDocumentElement(da0.fieldList, da0.dataStructure, "Payer_Claim_Office_No", "YYYY");
            
            da0.setDocumentElement(da0.fieldList, da0.dataStructure, "Payer_Name", chargeRs.getString("py.name"));
            da0.setDocumentElement(da0.fieldList, da0.dataStructure, "Group_Number", chargeRs.getString("py.grouptaxid"));
            da0.setDocumentElement(da0.fieldList, da0.dataStructure, "Assign_of_Benefits", "Y");
            da0.setDocumentElement(da0.fieldList, da0.dataStructure, "Patient_Signature_Source", "P");
            da0.setDocumentElement(da0.fieldList, da0.dataStructure, "Patient_Relationship_to_insured", chargeRs.getString("r.code"));
            da0.setDocumentElement(da0.fieldList, da0.dataStructure, "Insured_ID_Number", chargeRs.getString("pi.providernumber"));

            PayerInformationRecord da1=setInsuredInformation(da0, chargeRs);
            
            System.out.println(da0.toString());
            this.batchRecordCount ++;
            this.fileRecordCount ++;
            this.dxxCount ++;
            
            System.out.println(da1.toString());
            batchRecordCount ++;
            this.fileRecordCount ++;
            this.batchRecordCount++;
            
            ca0.da0List.add(da0);
            this.dxxCount ++;
            this.fileRecordCount ++;
            this.batchRecordCount++;
            
        } catch (Exception DA0Exception) {
            System.out.println("Error Creating DA0 Record - " + DA0Exception.getMessage());
        }
    }
    
    private void setClaimDataRecord(ResultSet chargeRs) throws Exception {
        ClaimDataRecord ea0=new ClaimDataRecord(this.io);
        try {
            ea0.setDocumentElement("Record_ID", "EA0");
            ea0.setDocumentElement("Patient_Control_Number", chargeRs.getString("accountnumber"));
            ea0.setDocumentElement("Employment_Related_Ind", "U");
            ea0.setDocumentElement("Accident_Indicator", "N");
            ea0.setDocumentElement("Release_of_Info_Info", "N");
            ea0.setDocumentElement("Same/Similar_Symptom_Ind", "N");
            ea0.setDocumentElement("Disability_Type", "4");
            ea0.setDocumentElement("Refer_Provider_NPI", chargeRs.getString("rs.pin"));
            ea0.setDocumentElement("Refer_Provider_UPIN", chargeRs.getString("rs.upin"));
            ea0.setDocumentElement("Refer_Provider_Tax_Type", "T");
            ea0.setDocumentElement("Refer_Provider_Tax_Tax_ID", chargeRs.getString("taxid"));
            ea0.setDocumentElement("Refer_Provider_Last", chargeRs.getString("rs.lastname"));
            ea0.setDocumentElement("Refer_Provider_Last", chargeRs.getString("rs.firstname"));
            ea0.setDocumentElement("Refer_Provider_MI", chargeRs.getString("rs.middleinitial"));
            ea0.setDocumentElement("Refer_Provider_Last", chargeRs.getString("rs.servicestate"));
            ea0.setDocumentElement("Lab_Ind", "N");
            ea0.setDocumentElement("Lab_Charges", "0000000");
            ea0.setDocumentElement("Provider_Assign_Ind", chargeRs.getString("rs.lastname"));
            try { ea0.setDocumentElement("Diagnosis_Code_1", (String)diagnosisCodes.get(0)); } catch (Exception e) {}
            try { ea0.setDocumentElement("Diagnosis_Code_2", (String)diagnosisCodes.get(1)); } catch (Exception e) {}
            try { ea0.setDocumentElement("Diagnosis_Code_3", (String)diagnosisCodes.get(2)); } catch (Exception e) {}
            try { ea0.setDocumentElement("Diagnosis_Code_4", (String)diagnosisCodes.get(3)); } catch (Exception e) {}
            ea0.setDocumentElement("Provider_Signature_Ind", "Y");
            ea0.setDocumentElement("Provider_Signature_Date", Format.formatDate(new java.util.Date(), "yyyyMMdd"));
            ea0.setDocumentElement("Facility/Lab_Name", chargeRs.getString("facilityname"));
            ea0.setDocumentElement("Documentation_Ind", "7");
            ea0.setDocumentElement("Type_of_Documentation", "H");
            ea0.setDocumentElement("Supervising_Provider_Ind", "N");
            ea0.setDocumentElement("Sub/Resubmission_Code", "00");
            ea0.setDocumentElement("Homebound_Ind", "N");
            ea0.setDocumentElement("IDE_Number", "IDE_Number");
            System.out.println(ea0.toString());
            this.fileRecordCount ++;
            this.claimRecordCount ++;
            this.batchRecordCount++;
            this.exxCount++;

        } catch (Exception e) {
            System.out.println("Error creating EA0 record");
        }
        setClaimDataRecord1(chargeRs);
    }
    
    private void setClaimDataRecord1(ResultSet chargeRs) throws Exception {
        try {
            ClaimDataRecord1 ea1=new ClaimDataRecord1(this.io);
            ea1.setDocumentElement("Record_ID", "EA1");
            ea1.setDocumentElement("Patient_Control_Number", chargeRs.getString("accountnumber"));
            ea1.setDocumentElement("Facility/Lab_Legacy_ID", chargeRs.getString("edisupplierinfo.name"));
            ea1.setDocumentElement("Facility_Address_1", chargeRs.getString("edisupplierinfo.address1"));
            ea1.setDocumentElement("Facility_Address_2", chargeRs.getString("edisupplierinfo.address2"));
            ea1.setDocumentElement("Facility_City", chargeRs.getString("edisupplierinfo.city"));
            ea1.setDocumentElement("Facility_State", chargeRs.getString("edisupplierinfo.state"));
            ea1.setDocumentElement("Facility_Zip_Code", chargeRs.getString("edisupplierinfo.zip"));
            System.out.println(ea1.toString());
            this.fileRecordCount ++;
            this.exxCount++;
            this.claimRecordCount ++;
            this.batchRecordCount++;
        } catch (Exception e) {
            System.out.println("Error creating EA1 record");
        }
        
    }
    
    private void getClaimRootSegment(ResultSet chargeRs, int segmentSequenceNumber) {
        try {
            ClaimRootSegment fa0=new ClaimRootSegment(this.io);
            fa0.setDocumentElement("Record_ID", "FA0");
            fa0.setDocumentElement("Sequence_Number", getCount(segmentSequenceNumber, 2));
            fa0.setDocumentElement("Patient_Control_Number", chargeRs.getString("accountnumber"));
            fa0.setDocumentElement("Service_From_Date", chargeRs.getString("v.date"));
            fa0.setDocumentElement("Service_To_Date", chargeRs.getString("v.date"));
            fa0.setDocumentElement("Place_of_Service", "11");
            fa0.setDocumentElement("Type_of_Service_Code", "9");
            fa0.setDocumentElement("CPT/HCPCS_Procedure", chargeRs.getString("i.code"));
            fa0.setDocumentElement("Line_Charges", getAmount(chargeRs.getDouble("c.chargeamount"),5));
            getDiagnosisPointerCodes(chargeRs.getInt("c.id"), fa0);
            fa0.setDocumentElement("Units_of_Service", getAmount(.1,3));
            fa0.setDocumentElement("Purchase_Service_Ind", "N");
            System.out.println(fa0.toString());
            this.fileRecordCount ++;
            this.claimRecordCount ++;
            this.fxxCount++;
            this.batchServiceLineCount++;
            this.batchRecordCount++;
            
            this.fileServiceLineCount++;
            
            this.totalClaimCharges += chargeRs.getDouble("chargeamount");
            this.totalPatientAmount += chargeRs.getDouble("chargeamount");
            this.batchTotalCharges += chargeRs.getDouble("chargeamount");
            this.fileTotalCharges += chargeRs.getDouble("chargeamount");
        } catch (Exception e) {
            System.out.println("Error creating FA0 record");
        }
        
        
    }
    
    private void setClaimTrailer() {
        this.fileRecordCount ++;
        ClaimTrailerRecord xa0=new ClaimTrailerRecord(this.io);
        xa0.setDocumentElement("Record_ID", "XA0");
        xa0.setDocumentElement("Sequence_Number", "01");
        xa0.setDocumentElement("Patient_Control_Number", "01");
        xa0.setDocumentElement("Record_Type_Cxx_Count", getCount(this.cxxCount,2));
        xa0.setDocumentElement("Record_Type_Dxx_Count", getCount(this.dxxCount,2));
        xa0.setDocumentElement("Record_Type_Exx_Count", getCount(this.exxCount,2));
        xa0.setDocumentElement("Record_Type_Fxx_Count", getCount(this.fxxCount,2));
        xa0.setDocumentElement("Record_Type_Gxx_Count", getCount(this.gxxCount,2));
        xa0.setDocumentElement("Record_Type_Hxx_Count", getCount(this.hxxCount,2));
        xa0.setDocumentElement("Claim_Record_Count", getCount(this.claimRecordCount,2));
        xa0.setDocumentElement("Total_Claim_Charges", getAmount(this.totalClaimCharges, 7));
        xa0.setDocumentElement("Patient_Amount_Paid", getAmount(this.totalPatientAmount, 7));
        
        System.out.println(xa0.toString());
        batchRecordCount ++;
    }
    
    private void setBatchTrailer() {
        this.fileRecordCount ++;
        BatchTrailerRecord ya0=new BatchTrailerRecord(this.io);
        ya0.setDocumentElement("Record_ID", "YA0");
        ya0.setDocumentElement("EMC_Provider_ID", this.emcProviderId);
        ya0.setDocumentElement("Batch_Type", "100");
        ya0.setDocumentElement("Batch_Number", this.batch);
        ya0.setDocumentElement("Batch_Identifier", "");
        ya0.setDocumentElement("Provider_Tax_ID", "");
        ya0.setDocumentElement("Batch_Service_Line_Count", getCount(this.batchServiceLineCount,7));
        ya0.setDocumentElement("Batch_Record_Count", getCount(this.batchRecordCount,7));
        ya0.setDocumentElement("Batch_Claim_Count", getCount(this.batchClaimCount,7));
        ya0.setDocumentElement("Batch_Total_Charges", getAmount(this.batchTotalCharges,9));
        
        System.out.println(ya0.toString());
    }
    
    private void setFileTrailer() {
        FileTrailerRecord za0=new FileTrailerRecord(this.io);
        this.fileRecordCount ++;
        za0.setDocumentElement("Record_ID", "ZA0");
        za0.setDocumentElement("Submitter_ID", this.emcProviderId);
        za0.setDocumentElement("Receiver_ID", "GATEWAY EDI");
        za0.setDocumentElement("File_Service_Line_Count", getCount(this.fileServiceLineCount,7));
        za0.setDocumentElement("File_Record_Count", getCount(this.fileRecordCount,7));
        za0.setDocumentElement("File_Claim_Count", getCount(this.fileClaimCount,7));
        za0.setDocumentElement("File_Batch_Count", getCount(this.batchServiceLineCount,7));
        za0.setDocumentElement("File_Total_Charges", getAmount(this.fileTotalCharges,9));
        za0.setDocumentElement("File_Total_Paid_Amount", getAmount(this.fileTotalPaidAmount,9));
        za0.setDocumentElement("File_Total_Approved_Amount", getAmount(this.fileTotalApprovedAmount,9));
        
        System.out.println(za0.toString());
    }
    
    private String getEDIStudentStatus(String employer) {
        String studentStatus="";
        
        return studentStatus;
    }
    
    private String getEDIOtherInsuranceIndicator(String patientId) {
        String otherInsuranceIndicator="N";
        try {
            ResultSet lRs=io.opnRS("select * from patientinsurance where primaryprovider=0 and patientid=" + patientId);
            if(lRs.next()) { otherInsuranceIndicator="Y"; }
            lRs.close();
        } catch (Exception OtherInsuranceIndicator) {    
        }
        
        return otherInsuranceIndicator;
    }
    
    private PayerInformationRecord setInsuredInformation(InsuranceInformationRecord da0, ResultSet chargeRs) {
        PayerInformationRecord da1=new PayerInformationRecord(this.io);
        this.claimRecordCount ++;
        
        try {
            String patInsQuery="select case when billingaccount='' or billingaccount=accountnumber then " +
                                "  (case when guarantor='' then accountnumber else guarantor end) " +
                                "  else " +
                                "  billingaccount " +
                                "  end as guarantor " +
                                "from patients " +
                                "left join patientinsurance on patients.id=patientid where patients.id=" + chargeRs.getString("p.id") +
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
                    patInsRs=io.opnRS("select *, count(*)  as numberofproviders from insuranceinformation where patientid=" + chargeRs.getString("p.id") + " and insuranceinformation.providerid=" + providerId + " group by patientid");
                }

                ResultSet baRs=io.opnRS("select * from patients left join gender on patients.gender=gender.id where accountnumber='" + guarantor + "'");

                if(baRs.next()) {
                    da0.setDocumentElement(da0.fieldList, da0.dataStructure, "Insured_Last_Name", baRs.getString("lastname").trim());
                    da0.setDocumentElement(da0.fieldList, da0.dataStructure, "Insured_First_Name", baRs.getString("firstname").trim());
                    da0.setDocumentElement(da0.fieldList, da0.dataStructure, "Insured_Middle_Initial", baRs.getString("middlename").trim());
                    da0.setDocumentElement(da0.fieldList, da0.dataStructure, "Insured_Generation", baRs.getString("suffix").trim());
                    da0.setDocumentElement(da0.fieldList, da0.dataStructure, "Insured_Sex", baRs.getString("gender.code").trim());
                    da0.setDocumentElement(da0.fieldList, da0.dataStructure, "Insured_Date_of_Birth", tools.utils.Format.formatDate(baRs.getString("dob").trim(), "yyyyMMdd"));
                    da0.setDocumentElement(da0.fieldList, da0.dataStructure, "Insured_Empl_Status", baRs.getString("occupationid").trim());

                    patInsRs.beforeFirst();
                    if(patInsRs.next()) {
                        da1.setDocumentElement(da1.fieldList, da1.dataStructure, "Record_ID", "DA1");
                        da1.setDocumentElement(da1.fieldList, da1.dataStructure, "Sequence_Number", da0.getDocumentElement("Sequence_Number"));
                        da1.setDocumentElement(da1.fieldList, da1.dataStructure, "Patient_Control_Number", da0.getDocumentElement("Patient_Control_Number"));
                        da1.setDocumentElement(da1.fieldList, da1.dataStructure, "Payer_Address_Line_1", patInsRs.getString("payeraddress1"));
                        da1.setDocumentElement(da1.fieldList, da1.dataStructure, "Payer_Address_Line_2", patInsRs.getString("payeraddress2"));
                        da1.setDocumentElement(da1.fieldList, da1.dataStructure, "Payer_City", patInsRs.getString("payercity"));
                        da1.setDocumentElement(da1.fieldList, da1.dataStructure, "Payer_State", patInsRs.getString("payerstate"));
                        da1.setDocumentElement(da1.fieldList, da1.dataStructure, "Payer_Zip_Code", patInsRs.getString("payerzipcode"));
                    }
                }
                baRs.close();
                baRs=null;
            }
            patInsRs.close();
//            patInsRs=null;

            // Now check to see if any of the HICFA fields are overridden for this patient/provider combination
            patInsRs=io.opnRS("select * from patientinsurance left join gender on gender.id=patientinsurance.hicfa7sex where patientid=" + chargeRs.getString("p.id") + " and providerid=" + providerId);
            if(patInsRs.next()) {
                if(!chargeRs.getString("hicfa4").trim().equals("")) { 
                    String lastName=patInsRs.getString("hicfa4");
                    String firstName=lastName.substring(0, lastName.indexOf(" "));
                    lastName=lastName.substring(lastName.indexOf(" ") + 1);
                    da0.setDocumentElement(da0.fieldList, da0.dataStructure, "Insured_Last_Name", lastName);
                    da0.setDocumentElement(da0.fieldList, da0.dataStructure, "Insured_First_Name", firstName);
                    da0.setDocumentElement(da0.fieldList, da0.dataStructure, "Insured_Middle_Initial", "");
                    da0.setDocumentElement(da0.fieldList, da0.dataStructure, "Insured_Generation", "");
                    da0.setDocumentElement(da0.fieldList, da0.dataStructure, "Insured_Empl_Status", "");
                }
            
                if(patInsRs.getInt("hicfa7sex") != 0) {
                    da0.setDocumentElement(da0.fieldList, da0.dataStructure, "Insured_Sex", patInsRs.getString("gender.code").trim());
                }

                if(!patInsRs.getString("hicfa7dob").equals("0001-01-01")) {
                    da0.setDocumentElement(da0.fieldList, da0.dataStructure, "Insured_Date_of_Birth", tools.utils.Format.formatDate(patInsRs.getString("hicfa7dob"), "yyyyMMdd"));
                }
            }
            patInsRs.close();
            patInsRs=null;

        } catch (Exception box11Exception) {
            System.out.println("Error setting insured information - " + box11Exception.getMessage());
        }
        return da1;
    }
    
    private void getDiagnosisCodes(String patientId) throws Exception {
        diagnosisCodes.clear();
        
        String sqlStatement="SELECT diagnosisid, code FROM patientsymptoms " +
                            "join diagnosiscodes on diagnosisid=diagnosiscodes.id " +
                            "where patientid=" + patientId + " order by sequence";
        
        PreparedStatement lPs=io.getConnection().prepareStatement(sqlStatement);
        ResultSet lRs=lPs.executeQuery();
        
        int currentCode=1;
        while(lRs.next() && currentCode<5) {           
            diagnosisCodes.add(lRs.getString("code"));
            currentCode++;
        }
        
        lRs.close();
    }

    private String getDiagnosisPointerCodes(int chargeId, ClaimRootSegment fa0) {

        String codeList="";
        int [] codes=new int[diagnosisCodes.size()];
        int numberOfCodesFound=0;
    
        try {
            stm.setInt(1, chargeId);
            ResultSet tmpCodes=stm.executeQuery();
            while(tmpCodes.next() && numberOfCodesFound<4) {
                if(diagnosisCodes.contains(tmpCodes.getString("code"))) {
                    String codeId=(String)diagnosisCodes.get(diagnosisCodes.indexOf(tmpCodes.getString("code")));
                    if(codeList.indexOf(codeId)<0) {
                        codeList += codeId;
                        codes[numberOfCodesFound]=diagnosisCodes.indexOf(tmpCodes.getString("code"))+1;
                        numberOfCodesFound ++;
                    }
                } 
            }
            for(int x=0;x<codes.length;x++) {
                if(codes[x] != 0) { fa0.setDocumentElement("Diagnosis_Code_Pointer_"+(x+1), ""+codes[x]); }
            }

        } catch (Exception e){
        }

        return codeList;
    }
        
    private String getCount(int number, int fieldLength) {
        String count=""+number;
        try {
            String zeros="000000000000000".substring(0,fieldLength);
            count=zeros.substring(count.length())+count;
        } catch (Exception e) {
        }
        return count;
    }
    
    private String getAmount(double number, int fieldLength) {
        int value=(int)((number*100));
        String amount=""+value;
        String zeros="000000000000000".substring(0,fieldLength);
        amount=zeros.substring(amount.length())+amount;
        return amount;
    }
    
    public int getResourceId() {
        return resourceId;
    }

    public void setResourceId(int resourceId) {
        this.resourceId = resourceId;
    }

    public int getBatchId() {
        return batchId;
    }

    public void setBatchId(int batchId) {
        this.batchId = batchId;
    }

    public int getProviderId() {
        return providerId;
    }

    public void setProviderId(int providerId) {
        this.providerId = providerId;
    }

    public int getEDIBatchId() {
        return EDIBatchId;
    }

    public void setEDIBatchId(int EDIBatchId) {
        this.EDIBatchId = EDIBatchId;
    }
}
