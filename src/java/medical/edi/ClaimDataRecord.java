/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package medical.edi;

import tools.RWConnMgr;

/**
 *
 * @author Randy
 */
public class ClaimDataRecord extends NSFRecordType{
    public ClaimDataRecord(RWConnMgr io) {
        setConnMgr(io);
        initialize("EA0", fieldList, dataStructure);
    }

}
