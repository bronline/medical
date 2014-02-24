/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package medical.utiils;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import medical.Patient;
import tools.RWConnMgr;
import tools.utils.Format;



/**
 *
 * @author Randy
 */
public class ApplyBulkPayments {
    
    private static RWConnMgr io;
    private static Patient patient = new Patient();

    public static void main(String [] args) throws Exception {
        io = new RWConnMgr("localhost", "mcooper", "rwtools", "rwtools", RWConnMgr.MYSQL);
        patient.setConnMgr(io);
        PreparedStatement parentPmt = io.getConnection().prepareStatement("select * from payments where patientid=? order by `date`");
        ResultSet patientList = io.opnRS("select distinct patientid from payments");
        while(patientList.next()) {
            parentPmt.setInt(1, patientList.getInt("patientId"));
            patient.setId(patientList.getInt("patientId"));
            ResultSet parentPmtRs = parentPmt.executeQuery();
            while(parentPmtRs.next()) {
                applyPayment(parentPmtRs);
            }
            parentPmtRs.close();
            parentPmtRs = null;
        }
    }

    public static void applyPayment(ResultSet parentPmtRs) throws Exception {
        try {
            String checkNumber = parentPmtRs.getString("checknumber");
            String providerId = parentPmtRs.getString("provider");
            String amount = parentPmtRs.getString("amount");
            String transactionDate = parentPmtRs.getString("date");
            double remainingAmount = 0.0;
            double paymentAmount = 0.0;
            double totalPayments = 0.0;
            try {
                transactionDate = Format.formatDate(transactionDate, "yyyy-MM-dd");
            } catch (Exception e) {
                transactionDate = Format.formatDate(new java.util.Date(), "yyyy-MM-dd");
            }
            if (checkNumber.trim().equals("")) {
                checkNumber = "BULK_" + Format.formatDate(transactionDate, "yyyyMMdd");
            }
            String insertSQL = "INSERT INTO payments (patientid, provider, checknumber, amount, date, chargeid, parentpayment, originalamount) VALUES(?,?,?,?,?,?,?,?)";
            PreparedStatement lPs = io.getConnection().prepareStatement(insertSQL);
            lPs.setInt(1, patient.getId());
            lPs.setString(2, providerId);
            lPs.setString(3, checkNumber);
            lPs.setString(5, transactionDate);

            remainingAmount = parentPmtRs.getDouble("amount");

            String chargeQuery = "SELECT c.id, (c.chargeamount*quantity) as chargeamount, IFNULL((SELECT SUM(amount) FROM payments WHERE chargeid=c.id),0) AS balance " + "FROM visits v " + "LEFT JOIN charges c ON v.id=c.visitid " + "WHERE v.patientid=" + patient.getId() + " AND c.id IS NOT NULL " + "ORDER BY v.`date` DESC, c.id";
            ResultSet chgRs = io.opnRS(chargeQuery);
            while (chgRs.next() && remainingAmount > 0) {
                paymentAmount = chgRs.getDouble("chargeamount") - chgRs.getDouble("balance");
                if (paymentAmount > remainingAmount) {
                    paymentAmount = remainingAmount;
                }
                lPs.setDouble(4, paymentAmount);
                lPs.setInt(6, chgRs.getInt("id"));
                lPs.setInt(7, parentPmtRs.getInt("id"));
                lPs.setDouble(8, paymentAmount);
                lPs.execute();
                remainingAmount -= paymentAmount;
                totalPayments += paymentAmount;
            }
            chgRs.close();
            chgRs = null;
            PreparedStatement uPs = io.getConnection().prepareStatement("UPDATE payments SET amount=amount-? WHERE id=?");
            uPs.setDouble(1, totalPayments);
            uPs.setInt(2, parentPmtRs.getInt("id"));
            uPs.execute();
        } catch (SQLException ex) {
            Logger.getLogger(ApplyBulkPayments.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
