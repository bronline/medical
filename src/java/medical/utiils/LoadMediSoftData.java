/*
* To change this template, choose Tools | Templates
* and open the template in the editor.
*/

package medical.utiils;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import tools.RWConnMgr;
import tools.utils.Format;

/**
*
* @author rwandell
*/
public class LoadMediSoftData {
        private static RWConnMgr io=null;
        private static ResultSet casRs=null;
        private static ResultSet lRs=null;
        private static PreparedStatement casPs=null;
        private static PreparedStatement diagPs=null;
        private static PreparedStatement condPs=null;
        private static PreparedStatement sympPs=null;
        private static PreparedStatement patPs=null;
        private static PreparedStatement payerPs=null;
        private static PreparedStatement insPs=null;
        private static PreparedStatement patInsPs=null;
        private static int patientId=0;

        public static void main(String args[]) throws Exception {
            String toDatabase="bynumchiro";
            String fromDatabase="bynum";
            io=new RWConnMgr("bros2.bronlinesolutions.com", "medical", "rwtools", "rwtools", RWConnMgr.MYSQL);
            casPs=io.getConnection().prepareStatement("SELECT * FROM " + fromDatabase + ".mwcas where case_number=?");
            patPs=io.getConnection().prepareStatement("SELECT * FROM " + toDatabase + ".patients where accountnumber=?");
            diagPs=io.getConnection().prepareStatement("SELECT * FROM " + toDatabase + ".diagnosiscodes WHERE `code`=?");
            payerPs=io.getConnection().prepareStatement("SELECT * FROM " + toDatabase + ".providers WHERE `payerid`=?");
            patInsPs=io.getConnection().prepareStatement("SELECT * FROM " + toDatabase + ".patientinsurance WHERE providerid=? and patientid=?");

            condPs=io.getConnection().prepareStatement("INSERT INTO " + toDatabase + ".patientconditions (`patientid`, `conditiontype`, `description`, `condition`, `fromdate`, `todate`, `sameorsimilar`, `state`) values(?,?,?,?,?,?,?,?)");
            sympPs=io.getConnection().prepareStatement("INSERT INTO " + toDatabase + ".patientsymptoms (`patientid`, `symptom`, `diagnosisid`, `sequence`, `conditionid`) VALUES(?,?,?,?,?)");
            insPs=io.getConnection().prepareStatement("INSERT INTO " + toDatabase + ".patientinsurance (`patientid`, `providerid`, `providernumber`, `providergroup`, `relationshipid`, `primaryprovider`,`guarantor`) VALUES(?,?,?,?,?,?,?)");

            lRs=io.opnRS("select chart_number, max(case_number) as case_number from " + fromDatabase + ".mwcas group by chart_number");
//            casRs=io.opnRS("SELECT * FROM " + fromDatabase + ".mwcas1 ORDER BY `Chart_Number`, Field75");
            while(lRs.next()) {
                System.out.println("Case number: " + lRs.getString("case_number"));
                casPs.setString(1, lRs.getString("case_number"));
                casRs=casPs.executeQuery();
                if(casRs.next()) {
                    patPs.setString(1, casRs.getString("chart_number"));
                    ResultSet patRs=patPs.executeQuery();
                    if(patRs.next()) {
                        patientId=patRs.getInt("id");
                        processCAS();
                    }
                    patRs.close();
                    patRs=null;
                }
                casRs.close();
                casRs=null;
            }
        }

        private static void processCAS() throws SQLException {
            extractInsurance();
            extractCondition();
        }

        private static void extractInsurance() throws SQLException {
            if(casRs.getString("Insurance_Carrier_1") != null && !casRs.getString("Insurance_Carrier_1").equals("")) {
                payerPs.setString(1, casRs.getString("Insurance_Carrier_1"));
                ResultSet payerRs=payerPs.executeQuery();
                if(payerRs.next()) {
                    patInsPs.setInt(1, payerRs.getInt("id"));
                    patInsPs.setInt(2, patientId);
                    ResultSet patInsRs=patInsPs.executeQuery();
                    if(!patInsRs.next()) {
                        int relationshipId=1;

                        if(casRs.getString("Insured_Relationship_1").toUpperCase().equals("SPOUSE")) { relationshipId=2; }
                        if(casRs.getString("Insured_Relationship_1").toUpperCase().equals("CHILD")) { relationshipId=3; }

                        insPs.setInt(1, patientId);
                        insPs.setInt(2, payerRs.getInt("id"));
                        insPs.setString(3, casRs.getString("Policy_Number_1"));
                        insPs.setString(4, casRs.getString("Group_Number_1"));
                        insPs.setInt(5, relationshipId);
                        insPs.setBoolean(6, true);
                        insPs.setString(7, casRs.getString("Insured_1"));
                        insPs.execute();
                    }
                    patInsRs.close();
                    patInsRs=null;
                }
                payerRs.close();
                payerRs=null;

            }

            if(casRs.getString("Insurance_Carrier_2") != null && !casRs.getString("Insurance_Carrier_2").equals("")) {
                payerPs.setString(1, casRs.getString("Insurance_Carrier_2"));
                ResultSet payerRs=payerPs.executeQuery();
                if(payerRs.next()) {
                    patInsPs.setInt(1, payerRs.getInt("id"));
                    patInsPs.setInt(2, patientId);
                    ResultSet patInsRs=patInsPs.executeQuery();
                    if(!patInsRs.next()) {
                        int relationshipId=1;

                        if(casRs.getString("Insured_Relationship_2").toUpperCase().equals("SPOUSE")) { relationshipId=2; }
                        if(casRs.getString("Insured_Relationship_2").toUpperCase().equals("CHILD")) { relationshipId=3; }

                        insPs.setInt(1, patientId);
                        insPs.setInt(2, payerRs.getInt("id"));
                        insPs.setString(3, casRs.getString("Policy_Number_2"));
                        insPs.setString(4, casRs.getString("Group_Number_2"));
                        insPs.setInt(5, relationshipId);
                        insPs.setBoolean(6, false);
                        insPs.setString(7, casRs.getString("Insured_2"));
                        insPs.execute();
                    }
                    patInsRs.close();
                    patInsRs=null;
                }
                payerRs.close();
                payerRs=null;

            }

            if(casRs.getString("Insurance_Carrier_3") != null && !casRs.getString("Insurance_Carrier_3").equals("")) {
                payerPs.setString(1, casRs.getString("Insurance_Carrier_3"));
                ResultSet payerRs=payerPs.executeQuery();
                if(payerRs.next()) {
                    patInsPs.setInt(1, payerRs.getInt("id"));
                    patInsPs.setInt(2, patientId);
                    ResultSet patInsRs=patInsPs.executeQuery();
                    if(!patInsRs.next()) {
                        int relationshipId=1;

                        if(casRs.getString("Insured_Relationship_3").toUpperCase().equals("SPOUSE")) { relationshipId=2; }
                        if(casRs.getString("Insured_Relationship_3").toUpperCase().equals("CHILD")) { relationshipId=3; }

                        insPs.setInt(1, patientId);
                        insPs.setInt(2, payerRs.getInt("id"));
                        insPs.setString(3, casRs.getString("Policy_Number_3"));
                        insPs.setString(4, casRs.getString("Group_Number_3"));
                        insPs.setInt(5, relationshipId);
                        insPs.setBoolean(6, false);
                        insPs.setString(7, casRs.getString("Insured_3"));
                        insPs.execute();
                    }
                    patInsRs.close();
                    patInsRs=null;
                }
                payerRs.close();
                payerRs=null;

            }
        }

        private static void extractCondition() throws SQLException {
            try {
                int conditionType = 1;
                boolean sameOrSimilar = false;
                String state = "";
                String condition = "";
                if(casRs.getString("Related_To_Accident") != null) {
                    if (casRs.getString("Related_To_Accident").toUpperCase().equals("AUTO")) {
                        conditionType = 3;
                    }
                    if (casRs.getString("Related_To_Accident").toUpperCase().equals("YES")) {
                        conditionType = 4;
                    }
                }
                if (casRs.getString("Same_or_Similar_Symptoms").toUpperCase().equals("TRUE")) {
                    sameOrSimilar = true;
                }
                condition = "Case Number : " + casRs.getString("Case_Number") + "\r\n";
                if (casRs.getString("Illness_Indicator") != null && !casRs.getString("Illness_Indicator").equals("")) {
                    condition += "Case type: " + casRs.getString("Illness_Indicator") + "\r\n";
                }
                if (casRs.getString("Local_Use_B") != null && !casRs.getString("Local_Use_B").equals("")) {
                    condition += "Addtl Info: " + casRs.getString("Local_Use_B") + "\r\n";
                }
                if (casRs.getString("Last_XRay_Date") != null && !casRs.getString("Last_XRay_Date").equals("")) {
                    condition += "Last X-Ray: " + casRs.getString("Last_XRay_Date") + "\r\n";
                }
                if (casRs.getString("Notes") != null && !casRs.getString("Notes").equals("")) {
                    condition += "Notes: " + casRs.getString("Notes") + "\r\n";
                }
                condPs.setInt(1, patientId);
                condPs.setInt(2, conditionType);
                condPs.setString(3, casRs.getString("Description"));
                condPs.setString(4, condition);
                condPs.setString(5, Format.formatDate(casRs.getString("Field75"), "yyyy-MM-dd"));
                condPs.setString(6, "2099-12-31");
                condPs.setBoolean(7, sameOrSimilar);
                condPs.setString(8, state);
                condPs.execute();
                io.setMySqlLastInsertId();
                extractDiagnosisCodes(io.getLastInsertedRecord());
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }

        private static void extractDiagnosisCodes(int conditionId) throws SQLException {
            int sequence=1;
            if(casRs.getString("Diagnosis_1") != null && !casRs.getString("Diagnosis_1").equals("")) {
                createSymptom(conditionId, casRs.getString("Diagnosis_1"), sequence);
                sequence ++;
            }
            if(casRs.getString("Diagnosis_2") != null && !casRs.getString("Diagnosis_2").equals("")) {
                createSymptom(conditionId, casRs.getString("Diagnosis_2"), sequence);
                sequence ++;
            }
            if(casRs.getString("Diagnosis_3") != null && !casRs.getString("Diagnosis_3").equals("")) {
                createSymptom(conditionId, casRs.getString("Diagnosis_3"), sequence);
                sequence ++;
            }
            if(casRs.getString("Diagnosis_4") != null && !casRs.getString("Diagnosis_4").equals("")) {
                createSymptom(conditionId, casRs.getString("Diagnosis_4"), sequence);
                sequence ++;
            }
        }

        private static void createSymptom(int conditionId, String code, int sequence) {
            try {
                diagPs.setString(1, code);
                ResultSet diagRs = diagPs.executeQuery();
                if (diagRs.next()) {
                    sympPs.setInt(1, patientId);
                    sympPs.setString(2, "");
                    sympPs.setInt(3, diagRs.getInt("id"));
                    sympPs.setInt(4, sequence);
                    sympPs.setInt(5, conditionId);
                    sympPs.execute();
                }
                diagRs.close();
                diagRs=null;
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
}

