/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package medical.utiils;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import tools.RWConnMgr;

/**
 *
 * @author Randy
 */
public class UpdateTableContents {
    public static void main(String [] args) throws Exception {
        String tableName = "commenttypes";
        String mySql="select * from userinfo " +
                        "left join userroles on userinfo.id=userroles.rolprf " +
                        "left join roles on roles.id=userroles.role " +
                        "where roles.role='MEDICAL'";

        RWConnMgr chiroIo=new RWConnMgr("chiropracticeonline.net", "chiro_site", "chiro_site", "root", RWConnMgr.MYSQL);
        ResultSet userRs=chiroIo.opnRS(mySql);

        while(userRs.next()) {
            String databaseName=userRs.getString("secprf");
            System.out.println("Now Updating " + databaseName);

            try {
                String fieldList="";
                String fieldValues="";
                
                RWConnMgr fromIo=new RWConnMgr("localhost", "medical", "root", "root", RWConnMgr.MYSQL);
                RWConnMgr toIo=new RWConnMgr("bronlinesolutions.com", databaseName, databaseName, databaseName, RWConnMgr.MYSQL);

                ResultSet fromRs=fromIo.opnRS("SELECT * FROM `" + tableName + "`");
                for(int x=0;x<fromRs.getMetaData().getColumnCount();x++) {
                    if(x !=0) { 
                        fieldList += ", "; 
                        fieldValues += ", ";
                    }
                    fieldList += "`" + fromRs.getMetaData().getColumnName(x+1) + "`";
                    fieldValues += "?";
                }
                
                toIo.getConnection().prepareStatement("truncate table `" + tableName + "`").execute();
                PreparedStatement iPs=toIo.getConnection().prepareStatement("insert into `" + tableName + "` (" + fieldList + ") values(" + fieldValues + ")");
                while(fromRs.next()) {
                    for(int x=0;x<fromRs.getMetaData().getColumnCount();x++) {
                        iPs.setString(x+1, fromRs.getString(x+1));
                    }
                    iPs.execute();
                }
                
                fromRs.close();
            } catch (Exception e) {
                System.out.print("There was a problem updating table " + tableName + " for " + databaseName);
            }
            
            System.out.println("");
            System.out.println("");
        }
        userRs.close();
    }
}
