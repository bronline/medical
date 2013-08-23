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
public class BatchHeaderRecord1 extends NSFRecordType {
    public BatchHeaderRecord1(RWConnMgr io) {
        setConnMgr(io);
        initialize("BA1", fieldList, dataStructure);
    }
}
