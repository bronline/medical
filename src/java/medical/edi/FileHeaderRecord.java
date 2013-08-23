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
public class FileHeaderRecord extends NSFRecordType {
    ArrayList bao=new ArrayList();
    public FileHeaderRecord(RWConnMgr io) {
        setConnMgr(io);
        initialize("AA0", fieldList, dataStructure);
    }
}
