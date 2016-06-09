/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package medical.edi;

import java.io.File;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.pb.x12.Cf;
import org.pb.x12.Loop;
import org.pb.x12.Parser;
import org.pb.x12.Segment;
import org.pb.x12.X12;
import org.pb.x12.X12Parser;
import tools.RWConnMgr;
import tools.utils.Format;

/**
 *
 * @author Randy
 */
public abstract class EDI835Parser {
    
    private static java.util.Date today = new java.util.Date();

    public static String parse(String fileName, String databaseName) {
        String batchStatus="";
        X12 x12 = null;
        Cf cf835 = loadCf(); // candidate for dependency injection
        Parser parser = new X12Parser(cf835);
        Map reasonMap = new HashMap();
        
        class ClaimReason {
            public String id;
            public String description;
            public int reasonId;
            public boolean setBatchStatus;
            
            public ClaimReason(ResultSet rs) {
                try {
                    id = rs.getString("id");
                    description = rs.getString("description");
                    reasonId = rs.getInt("reasonid");
                    setBatchStatus = rs.getBoolean("setbatchstatus");
                } catch (SQLException ex) {
                    Logger.getLogger(EDI835Parser.class.getName()).log(Level.SEVERE, null, ex);
                }
            }
        }

        try {
            RWConnMgr io = new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);
            ResultSet eobReasonRs = io.opnRS("SELECT * FROM rwcatalog.claimadjustmentreasons");
            while(eobReasonRs.next()) {
                ClaimReason cr = new ClaimReason(eobReasonRs);
                reasonMap.put(eobReasonRs.getString("id"), cr);
            }
            
            PreparedStatement eobChgPs = io.getConnection().prepareStatement("call rwcatalog.prGetChargeForEOBPayment(?,?,?,?);");
            PreparedStatement pmtPs = io.getConnection().prepareStatement("insert into payments (provider, checknumber, amount, chargeid, patientid, date, originalamount) values(?,?,?,?,?,?,?)");
            PreparedStatement dedPs = io.getConnection().prepareStatement("insert into deductables (batchid, patientid, `date`, amount) values(?,?,?,?)");
            PreparedStatement excPs = io.getConnection().prepareStatement("insert into eobexceptions (chargeid, paymentid, reasonid, amount, `date`) values(?,?,?,?,?)");
            
            eobChgPs.setString(1, databaseName);
            
            x12 = (X12)parser.parse(new File(fileName));

            String accountNumber = "";
            String cptCode = "";
            String dos = "";
            String paymentDate = "";
            String checkNumber = "";
            String providerNumber = "";
            String npi = "";
            double paymentAmount = 0.0;
            double adjustmentAmount = 0.0;
            double writeoffAmount = 0.0;
            double patientAmount = 0.0;
            double deductibleAmount = 0.0;
            int deductibleReasonId = 0;
            int patientId = 0;
            int providerId = 0;

            List<Loop> loops = x12.findLoop("2100");
            for (Loop loop : loops) {
                paymentDate="";
                npi = "";

                Loop parentLoop = loop.getParent();
                List<Segment> patientInsurance = parentLoop.findSegment("NM1");
                for(Segment pi : patientInsurance) {

                    List<String> ins = pi.getElements();
                    boolean foundItem = false;
                    for(String s : ins) {
                        if(foundItem) { providerNumber = s; break; }
                        if(s.equals("MI") || s.equals("HN")) { foundItem = true; }
                    }
                }

                Loop outerLoop = parentLoop.getParent();

                List<Segment> trn = outerLoop.findSegment("TRN");
                for(Segment s : trn) {
                    checkNumber = s.getElement(2);
                }

                List<Segment> xx = outerLoop.findSegment("N1");
                for(Segment s : xx) {
                    for(int nn=0;nn<s.size();nn++) {
                        if(s.getElement(nn).equals("XX")) {
                            npi = s.getElement(nn+1);
                            break;
                        }
                    }
                }

                ResultSet resourceRs = io.opnRS("select id from resources where box33a='" + npi + "' or box32a = '" + npi + "' " +
                                                "union " +
                                                "select id from environment where pin='" + npi + "' or box33a='" + npi + "'");
                if(resourceRs.next()) {
                    Loop outerLoop1 = parentLoop.getParent();

                    List<Segment> dtm = outerLoop1.findSegment("DTM");
                    for(Segment s : dtm) {
                        if(s.getElement(1).equals("405")) {
                            paymentDate = s.getElement(2);
                            break;
                        }
                    }

                    if(paymentDate == null || paymentDate.trim().equals("")) { paymentDate=Format.formatDate(today, "yyyy-MM-dd"); }
                    accountNumber = loop.getSegment(0).getElement(1);
                    eobChgPs.setString(2, accountNumber);
                    
                    cptCode = "";
                    dos = "";
                    paymentAmount = 0.0;
                    adjustmentAmount = 0.0;
                    writeoffAmount = 0.0;
                    patientAmount = 0.0;
                    deductibleAmount = 0.0;
                    int chargeId = 0;

                    List<Loop> s2110 = loop.findLoop("2110");;
                    
                    for(Loop services : s2110) {
                        paymentAmount = 0.0;
                        adjustmentAmount = 0.0;
                        writeoffAmount = 0.0;
                        patientAmount = 0.0;
                        deductibleAmount = 0.0;

                        for(Segment service : services) {

                            if(service.getElement(0).equals("SVC")) {

                                cptCode = service.getElement(1).replaceFirst("HC:", "").substring(0,5);
                                paymentAmount = Double.parseDouble(service.getElement(3));
                                eobChgPs.setString(4, cptCode);

                            } else if(service.getElement(0).equals("CAS")) {
                                if(service.getElement(1).equals("CO")) {
                                    adjustmentAmount = Double.parseDouble(service.getElement(3));
                                    if(service.getElements().size()>4) {
                                        if(service.getElements().size()>5) { adjustmentAmount += Double.parseDouble(service.getElement(6)); }
                                    }
                                    // chargeid, paymentid, reasonid, amount, `date`
                                    if(reasonMap.containsKey(service.getElement(2))) {
                                        int eobReasonId = ((ClaimReason)reasonMap.get(service.getElement(2))).reasonId;
                                        excPs.setInt(1, chargeId);
                                        excPs.setInt(2, 0);
                                        excPs.setInt(3, eobReasonId);
                                        excPs.setDouble(4, Double.parseDouble(service.getElement(3)));
                                        excPs.setString(5, paymentDate);
                                        
                                        excPs.execute();
                                    }
                                    
                                }
                                if(service.getElement(1).equals("PR")) {
                                    if(!service.getElement(2).equals("1")) {
                                        patientAmount = Double.parseDouble(service.getElement(3));
                                    }
                                    
                                    if(reasonMap.containsKey(service.getElement(2))) {
                                        int eobReasonId = ((ClaimReason)reasonMap.get(service.getElement(2))).reasonId;
                                        excPs.setInt(1, chargeId);
                                        excPs.setInt(2, 0);
                                        excPs.setInt(3, eobReasonId);
                                        excPs.setDouble(4, Double.parseDouble(service.getElement(3)));
                                        excPs.setString(5, Format.formatDate(paymentDate,"yyyy-MM-dd"));
                                        
                                        excPs.execute();
                                    }
                                }
                                if(((ClaimReason)reasonMap.get(service.getElement(2))).setBatchStatus)  {
                                    ResultSet pEOBRs = io.opnRS("CALL rwcatalog.prGetPatientInfoForEOB('" + io.getLibraryName() + "'," + chargeId + ")");
                                    if(pEOBRs.next()) {
                                        batchStatus += pEOBRs.getString("accountinfo");
                                        batchStatus += ": " + ((ClaimReason)reasonMap.get(service.getElement(2))).description + "\n";
                                    }
                                }
                            } else if(service.getElement(0).equals("DTM")) {
                                dos = Format.formatDate(service.getElement(2), "yyyy-MM-dd");
                                eobChgPs.setString(3, dos);
                                
                                ResultSet eobChgRs = eobChgPs.executeQuery();
                                if(eobChgRs.next()) { chargeId = eobChgRs.getInt("chargeid"); }
                                eobChgRs.close();
                                eobChgRs = null;
                            } else if(service.getElement(0).endsWith("AMT")) {
                                if(service.getElement(1).equals("B6")) {
                                    deductibleAmount += Double.parseDouble(service.getElement(2));
                                } else {
                                    if(reasonMap.containsKey(service.getElement(1))) {
                                        int eobReasonId = ((ClaimReason)reasonMap.get(service.getElement(1))).reasonId;
                                        excPs.setInt(1, chargeId);
                                        excPs.setInt(2, 0);
                                        excPs.setInt(3, eobReasonId);
                                        excPs.setDouble(4, Double.parseDouble(service.getElement(2)));
                                        excPs.setString(5, paymentDate);
                                        
                                        excPs.execute();
                                    }
                                }
                            }
                        }

                        patientId = 0;
                        providerId = 0;

                        ResultSet ptRs = io.opnRS("select * from patients where accountnumber='" + accountNumber + "'");
                        if(ptRs.next()) {
                            patientId=ptRs.getInt("id");
                            ResultSet piRs = io.opnRS("select * from patientinsurance where active and patientid=" + patientId + " and providernumber='" + providerNumber + "'");
                            if(piRs.next()) {
                                    providerId = piRs.getInt("providerid");
                            } else {
                                ResultSet piRs2 = io.opnRS("select * from patientinsurance where primaryprovider and patientid=" + patientId + " and insuranceeffective<'" + paymentDate + "' order by insuranceeffective desc limit 1");
                                if(piRs2.next()) {
                                    providerId = piRs2.getInt("providerid");
                                } else  {
                                    batchStatus += "* The patient (" + ptRs.getString("firstname") + " " + ptRs.getString("lastname") + ") does not have an insurance record for the provider\n";
                                }
                                piRs2.close();
                                piRs2 = null;
                            }

                            try {
                                PreparedStatement chgPs = io.getConnection().prepareStatement("insert into edipayments select null, v.patientid, ifnull(c.id,0) as chargeid, " + paymentAmount + ", " + adjustmentAmount + ", " + patientAmount + ", '" + dos + "', '" + accountNumber + "', " + providerId + ", 0, '" + checkNumber + "', '" + paymentDate + "',0 as eobbatchid, " + deductibleAmount + " from visits v left join charges c on c.visitid=v.id left join items i on c.itemid=i.id where patientid=" + patientId + " and i.code='" + cptCode + "' and v.date = '" + dos + "'");
                                chgPs.execute();
                            } catch (Exception ediException) {
                                PreparedStatement chgPs = io.getConnection().prepareStatement("insert into ediexceptions select null, " + patientId + ", " + cptCode + ", " + paymentAmount + ", " + adjustmentAmount + ", " + patientAmount +  ", '" + dos + "', '" + accountNumber + "', " + providerId + ", 0, '" + checkNumber + "', '" + paymentDate + "',0 ," + deductibleAmount);
                                chgPs.execute();
                            }

                            
                            piRs.close();
                            piRs = null;
                        } else {
                            batchStatus += "* A patient with the account number: " + accountNumber + " was not found\n";
                        }


                        ptRs.close();
                        ptRs = null;

                    }
                    System.out.println("");

                } else {
                    batchStatus += "* The NPI " + npi + " was not found in box 33a for a provider or practice\n";
                }
            }

            // Now process the payments we just added
            int adjustmentPayer = 0;
            ResultSet lRs = io.opnUpdatableRS("select * from edipayments where not processed and patientid<>0 and chargeid<>0 and providerid<>0");
            ResultSet paRs = io.opnRS("select * from providers where isadjustment limit 1");
            if(paRs.next()) { adjustmentPayer = paRs.getInt("id"); }
            ResultSet rsnRs = io.opnRS("select * from eobreasons where type='D' limit 1");
            if(rsnRs.next()) { deductibleReasonId = rsnRs.getInt("id"); } else { deductibleReasonId = 0; }
            while(lRs.next()) {

                int paymentId = 0;
                
                if(lRs.getDouble("paymentamount") != 0.0) {
                    pmtPs.setInt(1, lRs.getInt("providerid"));
                    pmtPs.setString(2, lRs.getString("checknumber"));
                    pmtPs.setDouble(3, lRs.getDouble("paymentamount"));
                    pmtPs.setInt(4, lRs.getInt("chargeid"));
                    pmtPs.setInt(5, lRs.getInt("patientid"));
                    pmtPs.setString(6, lRs.getString("paymentdate"));
                    pmtPs.setDouble(7, lRs.getDouble("paymentamount"));
                    pmtPs.execute();
                    
                    io.setMySqlLastInsertId();
                    paymentId = io.getLastInsertedRecord();
                }

                if(adjustmentPayer !=0) {
                    pmtPs.setInt(1, adjustmentPayer);
                    pmtPs.setString(2, lRs.getString("checknumber").trim());
                    pmtPs.setDouble(3, lRs.getDouble("adjustmentamount"));
                    pmtPs.setInt(4, lRs.getInt("chargeid"));
                    pmtPs.setInt(5, lRs.getInt("patientid"));
                    pmtPs.setString(6, lRs.getString("paymentdate"));
                    pmtPs.setDouble(7, lRs.getDouble("adjustmentamount"));
                    pmtPs.execute();
                    
                    if(paymentId == 0) {
                        io.setMySqlLastInsertId();
                        paymentId = io.getLastInsertedRecord();
                    }
                }

                if(deductibleAmount != 0.0) {
                    dedPs.setInt(1, 0);
                    dedPs.setInt(2, lRs.getInt("patientid"));
                    dedPs.setString(3, lRs.getString("paymentdate"));
                    dedPs.setDouble(4, lRs.getDouble("deductibleamount"));
                    dedPs.execute();
/*                    
                    if(deductibleReasonId != 0) {
                        excPs.setInt(1, lRs.getInt("chargeid"));
                        excPs.setInt(2, paymentId);
                        excPs.setInt(3, deductibleReasonId);
                        excPs.setDouble(4, lRs.getDouble("deductibleamount"));
                        excPs.setString(5, lRs.getString("paymentdate"));
                        excPs.execute();
                    }
*/
                }

                if(lRs.getDouble("paymentamount") != 0.0 || adjustmentPayer != 0.0) { lRs.updateBoolean("processed", true); }
                lRs.updateRow();
            }
            lRs.close();
            lRs = null;

            PreparedStatement completePs = io.getConnection().prepareStatement("update batchcharges set complete=1 where complete=0 and chargeid in (SELECT id FROM edipayments where processed and paymentamount<>0)");
            completePs.execute();
            
            if(batchStatus.equals("")) {
                batchStatus = "Posted";
            }
            
        } catch (Exception e1) {
            e1.printStackTrace();
        }
        
        return batchStatus;
    }

    // Alternately can be loaded using Spring/DI
    private static Cf loadCf() {
        Cf cfX12 = new Cf("X12");
        Cf cfISA = cfX12.addChild("ISA", "ISA");
        Cf cfGS = cfISA.addChild("GS", "GS", "HP", 1);
        Cf cfST = cfGS.addChild("ST", "ST", "835", 1);
        Cf cf2000 = cfST.addChild("2000", "LX");
        Cf cf2100 = cf2000.addChild("2100", "CLP");
        cf2100.addChild("2110", "SVC");
        cfISA.addChild("GE", "GE");
        cfX12.addChild("IEA", "IEA");
        return cfX12;
    }
}
