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
public class InsuranceInformationRecord extends NSFRecordType {
    public InsuranceInformationRecord(RWConnMgr io) {
        setConnMgr(io);
        initialize("DA0", fieldList, dataStructure);
    }

}
