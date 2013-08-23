/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
// -source 1.4 -target 1.4
package medical.edi;

import java.io.File;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.List;
import org.pb.x12.Cf;
import org.pb.x12.Loop;
import org.pb.x12.Parser;
import org.pb.x12.Segment;
import org.pb.x12.X12;
import org.pb.x12.X12Parser;
import tools.RWConnMgr;
import tools.utils.Format;


/**
 * Example showing X12 Parser reading a X12 file and looping over the segments.
 *
 * @author Prasad Balan
 *
 * <pre>
 * Example of parsing a X12 file
 *
 * This is the loop hierarchy of a 835 transaction used here.
 *
 * +--X12
 * |  +--ISA - ISA
 * |  |  +--GS - GS
 * |  |  |  +--ST - ST - 835, - 1
 * |  |  |  |  +--1000A - N1 - PR, - 1
 * |  |  |  |  +--1000B - N1 - PE, - 1
 * |  |  |  |  +--2000 - LX
 * |  |  |  |  |  +--2100 - CLP
 * |  |  |  |  |  |  +--2110 - SVC
 * |  |  |  +--SE - SE
 * |  |  +--GE - GE
 * |  +--IEA - IEA
 *
 * Cf cf835 = loadCf();
 * Parser parser = new X12Parser(cf835);
 * // The configuration Cf can be loaded using DI framework.
 * // Check the sample spring application context file provided.
 *
 * Double totalChargeAmount = 0.0;
 * X12 x12 = (X12) parser.parse(new File("C:\\test\\835.txt"));
 * List<Segment> segments = x12.findSegment("CLP");
 * for (Segment s : segments) {
 *     totalChargeAmount = totalChargeAmount + Double.parseDouble(s.getElement(3));
 * }
 * System.out.println("Total Change Amount " + s.getElement(3));
 *
 * </pre>
 */
public class Test835Parser {

    public static void main(String [] args) {
        X12 x12 = null;
        Cf cf835 = loadCf(); // candidate for dependency injection
        Parser parser = new X12Parser(cf835);
        double totalChargeAmount = 0.0;

        try {
            RWConnMgr io = new RWConnMgr("localhost", "katchley", "rwtools", "rwtools", RWConnMgr.MYSQL);

            x12 = (X12)parser.parse(new File("C:\\107599976_ERA_835_4010_20120612.835"));

            String accountNumber = "";
            String cptCode = "";
            String dos = "";
            String paymentDate = "";
            String checkNumber = "";
            String providerNumber = "";
            double paymentAmount = 0.0;
            double adjustmentAmount = 0.0;
            double writeoffAmount = 0.0;
            double patientAmount = 0.0;
            int patientId = 0;
            int providerId = 0;

            List<Loop> loops = x12.findLoop("2100");
            for (Loop loop : loops) {
                paymentDate="";

                Loop parentLoop = loop.getParent();
                System.out.println(parentLoop.getParent().toString());
                List<Segment> patientInsurance = parentLoop.findSegment("NM1");
                for(Segment pi : patientInsurance) {
                    List<String> ins = pi.getElements();
                    boolean foundItem = false;
                    for(String s : ins) {
                        if(foundItem) { providerNumber = s; break; }
                        if(s.equals("MI")) { foundItem = true; }
                    }
                }

                Loop outerLoop = parentLoop.getParent();
                List<Segment> trn = outerLoop.findSegment("TRN");
                for(Segment s : trn) {
                    checkNumber = s.getElement(2);
                }

                Loop outerLoop1 = parentLoop.getParent();
                List<Segment> dtm = outerLoop1.findSegment("DTM");
                for(Segment s : dtm) {
                    if(s.getElement(1).equals("405")) {
                        paymentDate = s.getElement(2);
                        break;
                    }
                }
                System.out.print("Provider #: " + providerNumber);
                System.out.print(" Check #: " + checkNumber);
                System.out.println(" Account #: " + loop.getSegment(0).getElement(1));
                accountNumber = loop.getSegment(0).getElement(1);

                cptCode = "";
                dos = "";
                paymentAmount = 0.0;
                adjustmentAmount = 0.0;
                writeoffAmount = 0.0;
                patientAmount = 0.0;

                List<Loop> s2110 = loop.findLoop("2110");
                for(Loop services : s2110) {
                    System.out.println(services.toString());
                    for(Segment service : services) {
                        if(service.getElement(0).equals("SVC")) {
                            System.out.print("CPT: " + service.getElement(1).replaceFirst("HC:", ""));
                            System.out.print(" Chg Amount: $" + service.getElement(2));
                            System.out.print(" Pmt Amount: $" + service.getElement(3));

                            cptCode = service.getElement(1).replaceFirst("HC:", "");
                            paymentAmount = Double.parseDouble(service.getElement(3));

                        } else if(service.getElement(0).equals("CAS")) {
                            if(service.getElement(1).equals("CO")) {
                                adjustmentAmount = Double.parseDouble(service.getElement(3));
                                if(service.getElements().size()>4) {
                                    adjustmentAmount += Double.parseDouble(service.getElement(6));
                                }
                                System.out.print(" Adj Amount $" + service.getElement(3));
                                adjustmentAmount = Double.parseDouble(service.getElement(3));
                            }
                            if(service.getElement(1).equals("PR")) {
                                System.out.print(" PR Amount $" + service.getElement(3));
                                patientAmount = Double.parseDouble(service.getElement(3));
                            }
                        } else if(service.getElement(0).equals("DTM")) {
                            System.out.print(" DOS: " + service.getElement(2));
                            dos = Format.formatDate(service.getElement(2), "yyyy-MM-dd");
                        }
                    }

/*
                    patientId = 0;
                    providerId = 0;

                    ResultSet ptRs = io.opnRS("select * from patients where accountnumber='" + accountNumber + "'");
                    if(ptRs.next()) { patientId=ptRs.getInt("id"); }
                    ResultSet piRs = io.opnRS("select * from patientinsurance where active and patientid=" + patientId + " and providernumber='" + providerNumber + "'");
                    if(piRs.next()) {
                            providerId = piRs.getInt("providerid");
                    } else {
                        ResultSet piRs2 = io.opnRS("select count(*) as providercount from patientinsurance where active and patientid=" + patientId);
                        if(piRs2.next()) {
                            if(piRs2.getInt("providercount") == 1) {
                                ResultSet piRs3 = io.opnRS("select * from patientinsurance where active and patientid=" + patientId);
                                if(piRs3.next()) { providerId = piRs3.getInt("providerid"); }
                                piRs3.close();
                                piRs3 = null;
                            }
                        }
                        piRs2.close();
                        piRs2 = null;
                    }
                    PreparedStatement chgPs = io.getConnection().prepareStatement("insert into edipayments select null, v.patientid, ifnull(c.id,0) as chargeid, " + paymentAmount + ", " + adjustmentAmount + ", " + patientAmount + ", '" + dos + "', '" + accountNumber + "', " + providerId + ", 0, '" + checkNumber + "', '" + paymentDate + "' from visits v left join charges c on c.visitid=v.id left join items i on c.itemid=i.id where patientid=" + patientId + " and i.code='" + cptCode + "' and v.date = '" + dos + "'");
                    chgPs.execute();
                    
                    piRs.close();
                    ptRs.close();

                    piRs = null;
                    ptRs = null;
*/
                }
                System.out.println("");

            }
/*
            // Now process the payments we just added
            int adjustmentPayer = 0;
            PreparedStatement pmtPs = io.getConnection().prepareStatement("insert into payments (provider, checknumber, amount, chargeid, patientid, date, originalamount) values(?,?,?,?,?,?,?)");
            ResultSet lRs = io.opnUpdatableRS("select * from edipayments where not processed and patientid<>0 and chargeid<>0 and providerid<>0");
            ResultSet paRs = io.opnRS("select * from providers where isadjustment limit 1");
            if(paRs.next()) { adjustmentPayer = paRs.getInt("id"); }
            while(lRs.next()) {
                pmtPs.setInt(1, lRs.getInt("providerid"));
                pmtPs.setString(2, lRs.getString("checknumber"));
                pmtPs.setDouble(3, lRs.getDouble("paymentamount"));
                pmtPs.setInt(4, lRs.getInt("chargeid"));
                pmtPs.setInt(5, lRs.getInt("patientid"));
                pmtPs.setString(6, lRs.getString("paymentdate"));
                pmtPs.setDouble(7, lRs.getDouble("paymentamount"));
                pmtPs.execute();

                if(adjustmentPayer !=0) {
                    pmtPs.setInt(1, adjustmentPayer);
                    pmtPs.setString(2, lRs.getString("checknumber").trim());
                    pmtPs.setDouble(3, lRs.getDouble("adjustmentamount"));
                    pmtPs.setInt(4, lRs.getInt("chargeid"));
                    pmtPs.setInt(5, lRs.getInt("patientid"));
                    pmtPs.setString(6, lRs.getString("paymentdate"));
                    pmtPs.setDouble(7, lRs.getDouble("adjustmentamount"));
                    pmtPs.execute();
                }

                lRs.updateBoolean("processed", true);
                lRs.updateRow();
            }
            lRs.close();
            lRs = null;
*/
        } catch (Exception e1) {
                e1.printStackTrace();
        }
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
        System.out.println(cfX12);
        return cfX12;
    }

}
