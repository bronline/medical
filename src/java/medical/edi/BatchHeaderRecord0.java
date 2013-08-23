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
public class BatchHeaderRecord0 extends NSFRecordType {
    public ArrayList ca0List=new ArrayList();
    
    public BatchHeaderRecord0(RWConnMgr io) {
        setConnMgr(io);
        initialize("BA0", fieldList, dataStructure);
    }
}
