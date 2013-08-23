/*
 * Batch.java
 *
 * Created on February 28, 2006, 10:42 PM
 *
 * To change this template, choose Tools | Options and locate the template under
 * the Source Creation and Management node. Right-click the template and choose
 * Open. You can then make changes to the template in the Source Editor.
 */

package medical;
import java.math.BigDecimal;
import java.util.Date;
import tools.*;


/**
 *
 * @author BR Online Solutions
 */
public class BatchCharge extends RWResultSet {
    RWConnMgr io;

    private int id                  = 0;
    private int batchId;
    private int chargeId;

    /** Creates a new instance of Payment */
    public BatchCharge() {
    }

    public BatchCharge(RWConnMgr io, int newId) throws Exception {
        setConnMgr(io);
        setId(newId);
    }   
    
    public void setConnMgr(RWConnMgr newIo) throws Exception {
        if(io == null) {
            io = newIo;
        }
    }
    
    public void setId(int newId) throws Exception {
        id = newId;
        setResultSet(io.opnRS("select * from batchcharges where id=" + newId));
        refresh();
    }
    
    public void setId(String newId) throws Exception {
        setId(Integer.parseInt(newId));
    }
    
    public void refresh() throws Exception {
        if(next()) {
            setBatchId(getInt("batchId"));
            setChargeId(getInt("chargeId"));
//            setId(getInt("id"));
        }
        beforeFirst();
    }

    public int getId() throws Exception {
        return id;
    }
    
    public int getBatchId() throws Exception {
        return batchId;
    }
    
    public int getChargeId() throws Exception {
        return chargeId;
    }
    
    public void setBatchId(int newBatchId) {
        batchId = newBatchId;
    }
    
    public void setChargeId(int newChargeId) {
        chargeId = newChargeId;
    }

    public void update() throws Exception {
        setResultSet(io.opnUpdatableRS("select * from batchcharges where id=" + id));
        
        if(next()) {
            updateInt("batchid", batchId);
            updateInt("chargeid", chargeId);
            updateRow();
        } else {
            moveToInsertRow();
            updateInt("batchid", batchId);
            updateInt("chargeid", chargeId);
            insertRow();
        }
    }

    public void delete() throws Exception {
        setResultSet(io.opnUpdatableRS("select * from batchcharges where id=" + id));
        beforeFirst();
        if (next()) {
            deleteRow();
        }
        setId(0);
    }    
    
}
