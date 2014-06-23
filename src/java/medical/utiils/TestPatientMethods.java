/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package medical.utiils;

import medical.Patient;
import tools.RWConnMgr;
import tools.RWHtmlTable;

/**
 *
 * @author Randy
 */
public class TestPatientMethods {
    /** Creates a new instance of TestCMS1500 */
    public static void main(String [] args) throws Exception {
        RWConnMgr io=new RWConnMgr("localhost", "medical", "root", "root", RWConnMgr.MYSQL);

        Patient patient = new Patient(io, "1241");
        patient.getPatientAging(new RWHtmlTable(), null, null, null, 0, "(42354,42355,49091,53410,53411)");

        io.getConnection().close();

    }
}
