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
public class ClaimTrailerRecord extends NSFRecordType {
    public ClaimTrailerRecord(RWConnMgr io) {
        setConnMgr(io);
        initialize("XA0", fieldList, dataStructure);
    }

}
