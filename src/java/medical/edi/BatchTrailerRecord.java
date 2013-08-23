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
public class BatchTrailerRecord extends NSFRecordType {
    public BatchTrailerRecord(RWConnMgr io) {
        setConnMgr(io);
        initialize("YA0", fieldList, dataStructure);
    }

}
