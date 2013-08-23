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
public class PayerInformationRecord extends NSFRecordType {
    public PayerInformationRecord(RWConnMgr io) {
        setConnMgr(io);
        initialize("DA1", fieldList, dataStructure);
    }
}
