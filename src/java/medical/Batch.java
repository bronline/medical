/*
 * Batch.java
 *
 * Created on February 28, 2006, 08:41 PM
 *
 * To change this template, choose Tools | Options and locate the template under
 * the Source Creation and Management node. Right-click the template and choose
 * Open. You can then make changes to the template in the Source Editor.
 */

package medical;
import java.sql.ResultSet;
import java.util.Date;
import tools.*;

/**
 *
 * @author BR Online Solutions
 */
public class Batch extends MedicalResultSet {
    RWConnMgr io;

    private int id                  = 0;
    private int provider            = 0;

    private String description;

    private Date created;
    private Date billed;
    private Date lastBillDate;
    
    private int billPrintType           = 0;
    private String documentMap;
    private int repeatingOffset         = 0;

    private boolean secondary           = false;
    private boolean allowMultipleDOS    = false;
    
    /** Creates a new instance of Payment */
    public Batch() {
    }

    public Batch(RWConnMgr io, int newId) throws Exception {
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
        setResultSet(io.opnRS("select * from batches where id=" + id));
        refresh();
    }
    
    public void setId(String newId) throws Exception {
        setId(Integer.parseInt(newId));
    }
    
    public void refresh() throws Exception {
        if(next()) {
            setDescription(getString("description"));
            setCreated(getDate("created"));
            setBilled(getDate("billed"));
            setProvider(getInt("provider"));
            setSecondary(getBoolean("issecondary"));
            setAllowMultipleDOS(getBoolean("allowmultipledos"));
        }
        setPrintOptions();
        beforeFirst();
    }

    private void setPrintOptions() {
        if(isSecondary()) {
            try {
                ResultSet lRs = io.opnRS("select paperbillmap from environment");
                if(lRs.next()) {
                    setDocumentMap(lRs.getString("paperbillmap"));
                    setBillPrintType(2);
                    setRepeatingOffset(24);
                }
                lRs.close();
                lRs=null;
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        } else {
            String myQuery = "select case when providers.billingmap='' OR providers.billingmap is null then environment.billingmap else providers.billingmap end as billingmap, " +
                              "case when providers.billingmap='' OR providers.billingmap is null then environment.billprinttype else providers.billprinttype end as billprinttype, " +
                              "case when providers.billingmap='' OR providers.billingmap is null then environment.billmaprptoffset else providers.billmaprptoffset end as billmaprptoffset " +
                              "from providers join environment where providers.id=" + this.provider;

            try {
                ResultSet lRs=io.opnRS(myQuery);
                if(lRs.next()) {
                    setDocumentMap(lRs.getString("billingmap"));
                    setBillPrintType(lRs.getInt("billprinttype"));
                    setRepeatingOffset(lRs.getInt("billmaprptoffset"));
                }
                lRs.close();
            } catch (Exception e) {
            }
        }
        
    }
    
    public int getId() throws Exception {
        return id;
    }

    public int getProvider() throws Exception {
        return provider;
    }
    
    public String getDescription() throws Exception {
        return description;
    }
    
    public Date getCreated() throws Exception {
        return created;
    }
    
    public Date getBilled() throws Exception {
        return billed;
    }
    
    public Date getLastBillDate() throws Exception {
        return lastBillDate;
    }
    
    public void setDescription(String newDescription) {
        description = newDescription;
    }
    
    public void setCreated(Date newDate) {
        created = newDate;
    }

    public void setBilled(Date newDate) {
        billed = newDate;
    }

    public void setLastBillDate(Date newDate) {
        lastBillDate = newDate;
    }

    public void setProvider(int newProvider) {
        provider = newProvider;
    }

    public void update() throws Exception {
        setResultSet(io.opnUpdatableRS("select * from batches where id=" + id));
        java.util.Date today = new java.util.Date();

        if(next()) {
            updateString("description", description);
            updateInt("provider", provider);
            if (created!=null) {
                updateDate("created", new java.sql.Date(created.getTime()));
            } else {
                updateDate("created", null);
            }
            if (billed!=null) {
                updateDate("billed", new java.sql.Date(billed.getTime()));
            } else {
                updateDate("billed", null);
            }
            if (lastBillDate!=null) {
                updateDate("lastbilldate", new java.sql.Date(lastBillDate.getTime()));
            } else {
                updateDate("lastbilldate", null);
            }
            updateRow();
        } else {
            moveToInsertRow();
            updateString("description", description);
            updateInt("provider", provider);
            updateDate("created", new java.sql.Date(today.getTime()));
            if (billed!=null) {
                updateDate("billed", new java.sql.Date(billed.getTime()));
            } else {
                updateDate("billed", null);
            }
            if (lastBillDate!=null) {
                updateDate("lastbilldate", new java.sql.Date(lastBillDate.getTime()));
            } else {
                updateDate("lastbilldate", null);
            }
            insertRow();
            io.setMySqlLastInsertId();
            setId(io.getLastInsertedRecord());
        }
    }
    public void delete() throws Exception {
        setResultSet(io.opnUpdatableRS("select * from batches where id=" + id));
        beforeFirst();
        if (next()) {
            deleteRow();
        }
        setId(0);
    }

    public int getBillPrintType() {
        return billPrintType;
    }

    public void setBillPrintType(int billPrintType) {
        this.billPrintType = billPrintType;
    }


    public String getDocumentMap() {
        return documentMap;
    }

    public void setDocumentMap(String documentMap) {
        this.documentMap = documentMap;
    }


    public int getRepeatingOffset() {
        return repeatingOffset;
    }

    public void setRepeatingOffset(int repeatingOffset) {
        this.repeatingOffset = repeatingOffset;
    }

    /**
     * @return the isSecondary
     */
    public boolean isSecondary() {
        return secondary;
    }

    /**
     * @param isSecondary the isSecondary to set
     */
    public void setSecondary(boolean secondary) {
        this.secondary = secondary;
    }

    /**
     * @return the allowMultipleDOS
     */
    public boolean isAllowMultipleDOS() {
        return allowMultipleDOS;
    }

    /**
     * @param allowMultipleDOS the allowMultipleDOS to set
     */
    public void setAllowMultipleDOS(boolean allowMultipleDOS) {
        this.allowMultipleDOS = allowMultipleDOS;
    }
}
