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
public class ClaimDataRecord1 extends NSFRecordType {
    public ClaimDataRecord1(RWConnMgr io) {
        setConnMgr(io);
        initialize("EA1", fieldList, dataStructure);
    }

}
