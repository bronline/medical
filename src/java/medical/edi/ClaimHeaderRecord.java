/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package medical.edi;

import java.util.ArrayList;
import tools.RWConnMgr;

/**
 *
 * @author Randy
 */
public class ClaimHeaderRecord extends NSFRecordType {
    public ArrayList da0List=new ArrayList();
    public ClaimHeaderRecord(RWConnMgr io) {
        setConnMgr(io);
        initialize("CA0", fieldList, dataStructure);
    }

}
