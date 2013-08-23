/*
 * Charge.java
 *
 * Created on November 28, 2005, 11:46 AM
 *
 * To change this template, choose Tools | Options and locate the template under
 * the Source Creation and Management node. Right-click the template and choose
 * Open. You can then make changes to the template in the Source Editor.
 */

package medical;
import java.math.BigDecimal;
import java.math.MathContext;
import java.util.logging.Level;
import java.util.logging.Logger;
import tools.*;
import java.sql.*;
import java.text.SimpleDateFormat;

/**
 *
 * @author BR Online Solutions
 */
public class Charge extends RWResultSet {
    private String id;
    private int resourceId = 0;
    private int visitId = 0;
    private int itemId = 0;
    private BigDecimal chargeAmount;
    private BigDecimal copayAmount;
    private String comment;
    private SimpleDateFormat isoFormat = new SimpleDateFormat("yyyy-MM-dd");
    private Visit visit;
    private Patient patient;
    private PatientPlan patientPlan;
    private Payment payment;
    private BigDecimal quantity;
    private String chargeComment;

    /** Creates a new instance of Charge */
    public Charge() {
    }

    public Charge(RWConnMgr io, String ID) throws Exception {
        setConnMgr(io);
        id = ID;
        setResultSet(io.opnRS("select * from charges where id=" + id));
    }

    public void setId(int newId) throws Exception {
        id = ""+newId;
        setResultSet(io.opnRS("select * from charges where id=" + id));
    }
    
    public void setId(String newId) throws Exception {
        setId(Integer.parseInt(newId));
    }
 
    public void setResourceId(int newResourceId) throws Exception {
        resourceId = newResourceId;
    }

    public void setVisitId(int newVisitId) throws Exception {
        visitId = newVisitId;
    }

    public void setItemId(int newItemId) throws Exception {
        itemId = newItemId;
    }

    public void setChargeAmount(BigDecimal newChargeAmount) throws Exception {
        chargeAmount = newChargeAmount;
    }
    
    public void setCopayAmount(BigDecimal newAmount) throws Exception {
        copayAmount=newAmount;
    }

    public void update() throws Exception {
        
        checkForCopayAmount();
        
        setResultSet(io.opnUpdatableRS("select * from charges where id=" + id));
        rs.beforeFirst();
        if (rs.next()) {
            rs.updateInt("visitid", visitId);
            rs.updateInt("itemid", itemId);
            rs.updateInt("resourceId", resourceId);
            rs.updateBigDecimal("chargeamount", chargeAmount);
            rs.updateBigDecimal("copayamount", copayAmount);
            rs.updateBigDecimal("quantity", quantity);
            rs.updateString("comments", chargeComment);
            rs.updateRow();
        } else {
            rs.moveToInsertRow();
            rs.updateInt("visitid", visitId);
            rs.updateInt("itemid", itemId);
            rs.updateInt("resourceId", resourceId);
            rs.updateBigDecimal("chargeamount", chargeAmount);
            rs.updateBigDecimal("copayamount", copayAmount);
            rs.updateBigDecimal("quantity", quantity);
            rs.updateString("comments", chargeComment);
            rs.insertRow();
            setNewChargeId();
        }
        
        checkForPatientPlan();
        checkForItemWriteOff();
    }

    private void checkForCopayAmount() throws Exception {
        //RKW 04/20/09 - if this is the copay item, don't set the copay amount to 0
        setCopayAmount(new BigDecimal("0.00"));
        BigDecimal hundreds = new BigDecimal("0.01");
        ResultSet itmRs=io.opnRS("select * from items where id=" + this.itemId + " and not copayitem" );
        if(itmRs.next()) {        
            ResultSet lRs=io.opnRS("select visits.id, visits.patientid, sum(chargeamount*quantity) as charges from visits left join charges on charges.visitid=visits.id where visits.id=" + visitId + " group by visits.id, visits.patientid");
            if(lRs.next()) {
                String insuranceQuery="select pi.id, pi.patientid, pi.providerid, case when pi.copayaspercent then pi.copayamount*.01 else pi.copayamount end AS copay, pi.copayaspercent from patientinsurance pi " +
                        "left join visits v on v.id=" + visitId + " " +
                        "left join patientconditions pc on pc.id=v.conditionid " +
                        "where" +
                        "  pi.providerid=case when pc.providerid<>0 THEN pc.providerid else case when pi.primaryprovider and pi.active then pi.providerid else 0 end end" +
                        "  and pi.patientId=" +lRs.getString("patientid");
//                ResultSet iRs=io.opnRS("select * from patientinsurance where patientid=" + lRs.getString("patientid"));
                ResultSet iRs=io.opnRS(insuranceQuery);
                if(iRs.next()) {
                    ResultSet dRs=io.opnRS("select * from defaultpayments where itemid=" + itemId + " and (patientid=" + lRs.getString("patientid") + " or providerid=" + iRs.getString("providerid") + ") order by patientid desc" );
                    if(dRs.next()) { 
                        if(dRs.getDouble("copay")!=0.0) {
                            setCopayAmount(dRs.getBigDecimal("copay"));
                        } else if(iRs.getBoolean("copayaspercent")) { 
                            setCopayAmount((chargeAmount.multiply(iRs.getBigDecimal("copay"))));
                        }
                    }
                    else if(iRs.getBoolean("copayaspercent") && lRs.getString("charges") != null) { setCopayAmount((lRs.getBigDecimal("charges").multiply(iRs.getBigDecimal("copay").multiply(hundreds)))); }
                    dRs.close();
                }
                iRs.close();
            }
            lRs.close();
        }
        itmRs.close();
    }
    
    private void checkForPatientPlan() throws Exception {
        if(visit == null) { visit=new Visit(io, 0); }
        if(patient == null) { patient=new Patient(io, 0); }
        
        visit.setId(visitId);
        patient.setId(visit.getPatientId());
        
        if(patient.getPatientPlan().getPlanId() != 0) {
            if(patientPlan == null) { patientPlan=patient.getPatientPlan(); }
//            patientPlan.setPlanId(patient.getInt("planid"));
            if(patientPlan.isAutoWriteOff()) {
                if(patientPlan.isVisitBased()) {
                    if(patientPlan.getVisitsToDate()>patientPlan.getInt("visits")) {
                        createWriteOffForCharge(chargeAmount.doubleValue());
                    }
                } else {
                    checkChargesToDate(); 
                }
            } else if(patientPlan.isPrepaidPlan()) {
                checkChargesToDate();
            }
        }
    }
    
    private void checkChargesToDate() throws Exception {
// 10/24/07 changed logic for including patient and insurance portions to get maximumPlanCharges
        double maximumPlanCharges=patientPlan.getDouble("patientportion");
        if(patient.getBoolean("insuranceactive")) { maximumPlanCharges+=patientPlan.getDouble("insuranceportion"); }
        if(patientPlan.isPrepaidPlan()) { maximumPlanCharges=getRemainingPrepaidAmount(); }

//        double maximumPlanCharges=(patientPlan.getDouble("patientportion") + patientPlan.getDouble("insuranceportion"));
        double currentPlanCharges=patientPlan.getPlanChargesToDate();

        if (currentPlanCharges > maximumPlanCharges && !patientPlan.isPrepaidPlan()) {
            if (chargeAmount.doubleValue()<(currentPlanCharges-maximumPlanCharges)) {
                createWriteOffForCharge(chargeAmount.doubleValue());
            } else {
                createWriteOffForCharge(currentPlanCharges-maximumPlanCharges);
            }
        } else {
            if(patientPlan.isPrepaidPlan()) {
                createPaymentForCharge(chargeAmount.doubleValue());
                if(chargeAmount.doubleValue()>maximumPlanCharges && patientPlan.isAutoWriteOff()) {
                    createWriteOffForCharge(chargeAmount.doubleValue()-maximumPlanCharges);
                }
            }
        }
    }
    
    private void createWriteOffForCharge(double chargeDifference) throws Exception {
        if(payment == null) { payment=new Payment(io, 0); }
        if(chargeDifference>0) {
            payment.setId(0);
            payment.setAmount(BigDecimal.valueOf(chargeDifference));
            payment.setChargeId(Integer.parseInt(id));
            payment.setCheckNumber("WO_" + tools.utils.Format.formatDate(new java.util.Date(), "yyyyMMdd"));
            payment.setDate(new java.util.Date());
            payment.setOriginalAmount(BigDecimal.valueOf(chargeDifference));
            payment.setPatientId(patient.getId());
            payment.setProvider(10);
            payment.update();
        }
    }
    
    private void createPaymentForCharge(double chargeAmount) {
        try {
            if(payment == null) { payment=new Payment(io, 0); }
            
            ResultSet paymentRs = io.opnUpdatableRS("select * from payments where chargeid=0 and amount>0 and patientId=" + this.patient.getId() + " order by `date`");
            while(paymentRs.next() && chargeAmount>0) {
                payment.setId(0);
                if(paymentRs.getDouble("amount")>=chargeAmount) {
                    payment.setAmount(BigDecimal.valueOf(chargeAmount));
                    payment.setOriginalAmount(BigDecimal.valueOf(chargeAmount));
                    paymentRs.updateDouble("amount", paymentRs.getDouble("amount")-chargeAmount);
                    chargeAmount=0;
                } else {
                    payment.setAmount(paymentRs.getBigDecimal("amount"));
                    payment.setOriginalAmount(paymentRs.getBigDecimal("amount"));
                    chargeAmount-=paymentRs.getDouble("amount");
                    paymentRs.updateDouble("amount", 0);
                }
                payment.setChargeId(Integer.parseInt(id));
                payment.setCheckNumber(paymentRs.getString("checknumber"));
                payment.setDate(new java.util.Date());
                payment.setPatientId(patient.getId());
                payment.setParentPayment(paymentRs.getInt("id"));
                payment.setProvider(paymentRs.getInt("provider"));
                payment.update();

                paymentRs.updateRow();
            }
            paymentRs.close();
            paymentRs=null;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        
    }

    private double getRemainingPrepaidAmount() {
        double prepaidAmount = 0.0;
        try {

            ResultSet paymentRs = io.opnRS("select sum(amount) as amount from payments where amount>0 and chargeid=0 and patientid=" + this.patient.getId());
            if(paymentRs.next()) {
                prepaidAmount=paymentRs.getDouble("amount");
            }
            paymentRs.close();
            paymentRs=null;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        return prepaidAmount;
    }

    private void checkForItemWriteOff() {
        try {
            ResultSet iRs = io.opnRS("select autowriteoffamount from items where id=" + itemId);
            if (iRs.next()) {
                if(iRs.getDouble("autowriteoffamount") != 0.0) {
                    createWriteOffForCharge(iRs.getDouble("autowriteoffamount"));
                }
            }
        } catch (Exception ex) {
            Logger.getLogger(Charge.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    
    private void setNewChargeId() throws Exception {
        ResultSet rs  = io.opnRS("select LAST_INSERT_ID()");
        rs.next();
        id=rs.getString(1);
        rs.close();
    }

    /**
     * @return the quantity
     */
    public BigDecimal getQuantity() {
        return quantity;
    }

    /**
     * @param quantity the quantity to set
     */
    public void setQuantity(BigDecimal quantity) {
        this.quantity = quantity;
    }

    /**
     * @return the chargeComment
     */
    public String getChargeComment() {
        return chargeComment;
    }

    /**
     * @param chargeComment the chargeComment to set
     */
    public void setChargeComment(String chargeComment) {
        this.chargeComment = chargeComment;
    }

}
