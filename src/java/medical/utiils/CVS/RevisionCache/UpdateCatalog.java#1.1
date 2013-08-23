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
public class UpdateCatalog {
    public static void main(String args[]) throws Exception {
        boolean showDifference=false;
        boolean toRecordExists=false;
        
        RWConnMgr fromIo=new RWConnMgr("localhost", "rwcatalog", "root", "root", RWConnMgr.MYSQL);
        RWConnMgr toIo=new RWConnMgr("bronlinesolutions.com", "rwcatalog", "rwtools", "rwtools", RWConnMgr.MYSQL);
        
        ResultSet fromRs=fromIo.opnRS("select * from catalog order by databasehost, databasename, tablename, columnname");
        PreparedStatement toPs=toIo.getConnection().prepareStatement("select * from catalog where databasehost=? and databasename=? and tablename=? and columnname=?");
        
        while(fromRs.next()) {
            toPs.setString(1, fromRs.getString("databasehost"));
            toPs.setString(2, fromRs.getString("databasename"));
            toPs.setString(3, fromRs.getString("tablename"));
            toPs.setString(4, fromRs.getString("columnname"));
            
            ResultSet toRs=toPs.executeQuery();
            showDifference=false;
            
            if(toRs.next()) {
                for(int x=1;x<fromRs.getMetaData().getColumnCount();x++) {
                    if(!fromRs.getString(x).toUpperCase().trim().equals(toRs.getString(x).toUpperCase().trim())) {
                        showDifference=true;
                    }
                }
                toRecordExists=true;
            } else {
                showDifference=true;
                toRecordExists=false;
            }
            
            if(showDifference) {
                System.out.println("");

                for(int x=1;x<fromRs.getMetaData().getColumnCount();x++) {
                   System.out.print(fromRs.getString(x) + "           " );
                   if(toRecordExists) {
                       System.out.print(fromRs.getString(x));
                   }
                   System.out.println("");
                }
                
                System.out.println("");
            }
        }
        fromRs.close();
    }

}
