/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package medical;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import tools.*;

/**
 *
 * @author Randy
 */
public class Medication extends MedicalResultSet{

    private int id;
    private int patientid;
    private double quantity;
    private String name;
    private int frequency;

    public Medication(){

    }

    public Medication(RWConnMgr io, int id) {
        this.io=io;
        setId(id);
    }

    public Medication(RWConnMgr io, String id) {
        this.io=io;
        try{
            setId(Integer.parseInt(id));
        } catch (Exception e) {

        }
    }

    /**
     * @return the id
     */
    public int getId() {
        return id;
    }

    /**
     * @param id the id to set
     */
    public void setId(int id) {
        try {
            this.id = id;
            ResultSet temp = io.opnRS("select * from medications where id=" + id);
            setResultSet(temp);
            refresh();
        } catch (Exception ex) {
            Logger.getLogger(Medication.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    public void refresh() {
        try {
            if(rs.next()) {
                this.id = rs.getInt("id");
                this.patientid = rs.getInt("patientid");
                this.quantity = rs.getDouble("quantity");
                this.name = rs.getString("name");
                this.frequency = rs.getInt("frequency");

                rs.beforeFirst();
            } else {
                this.id=0;
            }
        } catch (SQLException ex) {
            Logger.getLogger(Medication.class.getName()).log(Level.SEVERE, null, ex);

            this.id=0;
        }
    }

    public void update() {
        try {
            ResultSet temp = io.opnUpdatableRS("select * from medications where id=" + id);
            setResultSet(temp);

            if(rs.next()) {
                setFieldsFromEntity();
                updateRow();
            } else {
                rs.moveToInsertRow();
                setFieldsFromEntity();
                rs.insertRow();
            }
        } catch (Exception ex) {
            Logger.getLogger(Medication.class.getName()).log(Level.SEVERE, null, ex);
        }

    }

    private void setFieldsFromEntity() {
        try {
            rs.updateInt("patientid", this.patientid);
            rs.updateDouble("quantity", this.quantity);
            rs.updateInt("frequency", this.frequency);
            rs.updateString("name", this.name);
        } catch (SQLException ex) {
            Logger.getLogger(Medication.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    /**
     * @param id the id to set
     */
    public void setId(String id) {
        try {
           setId(Integer.parseInt(id));
        } catch (Exception e) {

        }
    }

    /**
     * @return the patientid
     */
    public int getPatientid() {
        return patientid;
    }

    /**
     * @param patientid the patientid to set
     */
    public void setPatientid(int patientid) {
        this.patientid = patientid;
    }

    /**
     * @return the quantity
     */
    public double getQuantity() {
        return quantity;
    }

    /**
     * @param quantity the quantity to set
     */
    public void setQuantity(double quantity) {
        this.quantity = quantity;
    }

    /**
     * @return the name
     */
    public String getName() {
        return name;
    }

    /**
     * @param name the name to set
     */
    public void setName(String name) {
        this.name = name;
    }

    /**
     * @return the frequency
     */
    public int getFrequency() {
        return frequency;
    }

    /**
     * @param frequency the frequency to set
     */
    public void setFrequency(int frequency) {
        this.frequency = frequency;
    }
}
