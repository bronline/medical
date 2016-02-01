/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package medical.utiils;

import com.rwtools.tools.db.utils.*;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import tools.RWConnMgr;

/**
 *
 * @author Randy
 */
public class UpdateChiroDatabases {
    public String databaseUsersLocation = "chiropracticeonline.net";
    public String databaseLocation = "chiropracticeonline.net";
    public String sourceDatabaseLocation = "chiropracticeonline.net";
    public String sourceDatabaseName = "medical";
    public String sourceDatabaseUser = "rwtools";
    public String sourceDatabasePassword = "rwtools";

    public UpdateChiroDatabases() {
    }


    public void doUpdate() {
        try {
            String mySql = "select * from userinfo " + 
                    "left join userroles on userinfo.id=userroles.rolprf " +
                    "left join roles on roles.id=userroles.role " +
                    "where roles.role in('MEDICAL','BROS2') and secprf='vmalchar' order by secprf";
            RWConnMgr chiroIo = new RWConnMgr(databaseUsersLocation, "chiro_site", "rwtools", "rwtools", RWConnMgr.MYSQL);
            ResultSet userRs = chiroIo.opnRS(mySql);
            while (userRs.next()) {
                String databaseName = userRs.getString("secprf");
                System.out.println("Now Checking " + databaseName);
                DBCompare dbCompare = new DBCompare();
                try {
                    RWConnMgr fromIo = new RWConnMgr(sourceDatabaseLocation, sourceDatabaseName, sourceDatabaseUser, sourceDatabasePassword, RWConnMgr.MYSQL);
                    RWConnMgr toIo = new RWConnMgr(databaseLocation, databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);
                    dbCompare.setFromIo(fromIo);
                    dbCompare.setToIo(toIo);
                    dbCompare.setProcessUpdates(true);
                    dbCompare.compareSchemas();
                } catch (Exception e) {
                    System.out.print("There was a problem comparing schemas for " + databaseName);
                }
                System.out.println("");
                System.out.println("");
            }
            userRs.close();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    public void checkForUpdates() throws Exception {
        try {
            String mySql = "select * from userinfo "
                    + "left join userroles on userinfo.id=userroles.rolprf "
                    + "left join roles on roles.id=userroles.role "
                    + "where roles.role in('MEDICAL','BROS2') and secactv=1 order by secprf";
            RWConnMgr chiroIo = new RWConnMgr(databaseUsersLocation, "chiro_site", "chiro_site", "root", RWConnMgr.MYSQL);
            ResultSet userRs = chiroIo.opnRS(mySql);
            while (userRs.next()) {
                String databaseName = userRs.getString("secprf");
                System.out.println("Now Checking " + databaseName);
                DBCompare dbCompare = new DBCompare();
                //            if(databaseName.toLowerCase().equals("jmaskaly")) {
                try {
                    RWConnMgr fromIo = new RWConnMgr(sourceDatabaseLocation, sourceDatabaseName, sourceDatabaseUser, sourceDatabasePassword, RWConnMgr.MYSQL);
                    RWConnMgr toIo = new RWConnMgr(databaseLocation, databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);
                    dbCompare.setFromIo(fromIo);
                    dbCompare.setToIo(toIo);
                    dbCompare.setProcessUpdates(false);
                    dbCompare.compareSchemas();
                } catch (Exception e) {
                    System.out.print("There was a problem comparing schemas for " + databaseName);
                }
                System.out.println("");
                System.out.println("");
                //            }
            }
            userRs.close();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    public void executeSQLScript(String sqlScript) throws Exception {
        try {
            String mySql = "select * from userinfo "
                    + "left join userroles on userinfo.id=userroles.rolprf "
                    + "left join roles on roles.id=userroles.role "
                    + "where roles.role in('MEDICAL','BROS2') and secactv=1 order by secprf";
            RWConnMgr chiroIo = new RWConnMgr(databaseUsersLocation, "chiro_site", "chiro_site", "root", RWConnMgr.MYSQL);
            ResultSet userRs = chiroIo.opnRS(mySql);
            while (userRs.next()) {
                String databaseName = userRs.getString("secprf");
                System.out.println("Now Checking " + databaseName);

                try {
//                    RWConnMgr fromIo = new RWConnMgr(sourceDatabaseLocation, sourceDatabaseName, sourceDatabaseUser, sourceDatabasePassword, RWConnMgr.MYSQL);
                    RWConnMgr toIo = new RWConnMgr(databaseLocation, databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);

                    PreparedStatement lPs = toIo.getConnection().prepareStatement(sqlScript);
                    lPs.execute();
                } catch (Exception e) {
                    System.out.print("There was a problem comparing schemas for " + databaseName);
                }

            }
            userRs.close();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }
}
