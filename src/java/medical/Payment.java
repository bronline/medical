/*
 * Payment.java
 *
 * Created on February 10, 2006, 10:58 PM
 *
 * To change this template, choose Tools | Options and locate the template under
 * the Source Creation and Management node. Right-click the template and choose
 * Open. You can then make changes to the template in the Source Editor.
 */

package medical;
import java.math.BigDecimal;
import java.sql.ResultSet;
import java.util.Date;
import tools.*;


/**
 *
 * @author BR Online Solutions
 */
public class Payment extends MedicalResultSet {
    RWConnMgr io;
    ResultSet childRs;
    
    private int id                  = 0;
    private int provider;
    private String checkNumber;
//    private int checkNumber;
    
    private BigDecimal amount;
    private BigDecimal originalAmount;

    private int chargeId;
    private int patientId;
    private int parentPayment;

    private Date date;
    
    /** Creates a new instance of Payment */
    public Payment() {
    }

    public Payment(RWConnMgr io, int newId) throws Exception {
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
        setResultSet(io.opnRS("select * from payments where id=" + id));
        refresh();
    }
    
    public void setId(String newId) throws Exception {
        setId(Integer.parseInt(newId));
    }
    
    public void refresh() throws Exception {
        if(next()) {
            setProvider(getInt("provider"));
//            setCheckNumber(getInt("checknumber"));
            setCheckNumber(getString("checknumber"));
            setAmount(getBigDecimal("amount"));
            setChargeId(getInt("chargeid"));
            setPatientId(getInt("patientid"));
            setDate(getDate("date"));
            setParentPayment(getInt("parentpayment"));
            setOriginalAmount(getBigDecimal("originalamount"));
        }
        beforeFirst();
    }

    public int getId() throws Exception {
        return id;
    }
    
    public int getProvider() throws Exception {
        return provider;
    }
    
//    public int getCheckNumber() throws Exception {
//        return checkNumber;
//    }
    
    public String getCheckNumber() throws Exception {
        return checkNumber;
    }
    
    public BigDecimal getAmount() throws Exception {
        return amount;
    }
    
    public int getChargeId() throws Exception {
        return chargeId;
    }

    public int getPatientId() throws Exception {
        return patientId;
    }

    public Date getDate() throws Exception {
        return date;
    }

    public int getParentPayment() throws Exception {
        return parentPayment;
    }

    public BigDecimal getOriginalAmount() throws Exception {
        return originalAmount;
    }
    
    public void setProvider(int newProvider) {
        provider = newProvider;
    }
    
//    public void setCheckNumber(int newCheckNumber) {
//        checkNumber = newCheckNumber;
//    }
    
    public void setCheckNumber(String newCheckNumber) {
        checkNumber = newCheckNumber;
    }
    
    public void setAmount(BigDecimal newAmount) {
        amount = newAmount;
    }
    
    public void setChargeId(int newChargeId) {
        chargeId = newChargeId;
    }
    
    public void setPatientId(int newPatientId) {
        patientId = newPatientId;
    }
    
    public void setDate(Date newDate) {
        date = newDate;
    }

    public void setParentPayment(int newId) {
        parentPayment = newId;
    }

    public void setOriginalAmount(BigDecimal newAmount) {
        originalAmount = newAmount;
    }
    
    public void setAmountBasedOnChildren() throws Exception {
        if (id>0) {
            childRs=io.opnRS("select ifnull(sum(amount),0) from payments where parentpayment=" + id);
            if (childRs.next()) {
                amount=originalAmount.subtract(childRs.getBigDecimal(1));
            }
        }
    }
    
    public void update() throws Exception {
        setResultSet(io.opnUpdatableRS("select * from payments where id=" + id));
        
        if(next()) {
            updateInt("provider", provider);
//            updateInt("checknumber", checkNumber);
            updateString("checknumber", checkNumber);
            updateBigDecimal("amount", amount);
            updateInt("chargeid", chargeId);
            updateInt("patientid", patientId);
            updateDate("date", new java.sql.Date(date.getTime()));
            updateInt("parentpayment", parentPayment);
            updateBigDecimal("originalamount", originalAmount);
            updateRow();
        } else {
            moveToInsertRow();
            updateInt("provider", provider);
//            updateInt("checknumber", checkNumber);
            updateString("checknumber", checkNumber);
            updateBigDecimal("amount", amount);
            updateInt("chargeid", chargeId);
            updateInt("patientid", patientId);
            updateDate("date", new java.sql.Date(date.getTime()));
            updateInt("parentpayment", parentPayment);
            updateBigDecimal("originalamount", amount);
            insertRow();
            setNewPaymentId();
        }
        
        if (parentPayment>0) {
            Payment parent = new Payment(io, parentPayment);
            if (parent.amount!=BigDecimal.valueOf(0.0)) {
                parent.setAmountBasedOnChildren();
                parent.update();
            }
        }
    }

    public void delete() throws Exception {
        deleteRow();
        if (parentPayment>0) {
            Payment parent = new Payment(io, parentPayment);
            if (parent.amount!=BigDecimal.valueOf(0.0)) {
                parent.setAmountBasedOnChildren();
                parent.update();
            }
        }
    }

    private void setNewPaymentId() throws Exception {
        ResultSet rs  = io.opnRS("select LAST_INSERT_ID()");
        rs.next();
        id=rs.getInt(1);
        rs.close();
    }
    

}
