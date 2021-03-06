/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package medical.edi;

import java.sql.ResultSet;
import tools.RWConnMgr;

/**
 *
 * @author Randy
 */
public class TestNSF301 {
    public static void main(String [] args) throws Exception {
        RWConnMgr io=new RWConnMgr("localhost", "medical_0401", "root", "root", RWConnMgr.MYSQL);
        ResultSet batchListRs=io.opnRS("SELECT distinct b.id as batchid, c.resourceid, b.provider as providerid FROM batches b left join batchcharges bc on bc.batchid=b.id left join charges c on c.id=bc.chargeid where created='2008-01-10' order by resourceid, b.provider");
//        ResultSet batchListRs=io.opnRS("SELECT distinct b.id as batchid, c.resourceid, b.provider as providerid FROM batches b left join batchcharges bc on bc.batchid=b.id left join charges c on c.id=bc.chargeid where b.id=129 and c.resourceid=3 order by resourceid, b.provider");
        NSF301 nsf301=new NSF301(io, batchListRs);
        batchListRs.close();
        io.getConnection().close();
    }
}
