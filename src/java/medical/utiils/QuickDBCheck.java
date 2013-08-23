/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package medical.utiils;

import com.rwtools.tools.db.utils.DBCompare;
import tools.RWConnMgr;

/**
 *
 * @author rwandell
 */
public class QuickDBCheck {

    public static void main(String [] args) throws Exception {
        String databaseUsersLocation = "chiropracticeonline.net";
        String databaseLocation = "chiropracticeonline.net";
        String sourceDatabaseLocation = "localhost";
        String sourceDatabaseName = "medical";
        String sourceDatabaseUser = "root";
        String sourceDatabasePassword = "my$ql";
        String destinationDatabaseName = "kcampbell";

        try {
            DBCompare dbCompare = new DBCompare();

            RWConnMgr fromIo = new RWConnMgr(sourceDatabaseLocation, sourceDatabaseName, sourceDatabaseUser, sourceDatabasePassword, RWConnMgr.MYSQL);
            RWConnMgr toIo = new RWConnMgr(databaseLocation, destinationDatabaseName, destinationDatabaseName, destinationDatabaseName, RWConnMgr.MYSQL);
            dbCompare.setFromIo(fromIo);
            dbCompare.setToIo(toIo);
            dbCompare.setProcessUpdates(false);
            dbCompare.compareSchemas();
        } catch (Exception e) {
            System.out.print("There was a problem comparing databases" );
        }
    }
}
