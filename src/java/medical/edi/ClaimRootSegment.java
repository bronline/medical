/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package medical.edi;

import tools.RWConnMgr;

/**
 *
 * @author Randy Wandell
 */
public class ClaimRootSegment extends NSFRecordType {
    public ClaimRootSegment(RWConnMgr io) {
        setConnMgr(io);
        initialize("FA0", fieldList, dataStructure);
    }
}
