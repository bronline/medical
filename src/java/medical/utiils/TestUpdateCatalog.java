/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package medical.utiils;

import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author Randy
 */
public class TestUpdateCatalog {
/*
 ALTER TABLE `katchley`.`edipayments` ADD COLUMN `eobbatchid` INTEGER UNSIGNED DEFAULT 0 AFTER `paymentdate`,
 ADD INDEX batch(`eobbatchid`, `patientid`, `dos`);
*/
    public static void main(String[] args) {
        try {
            UpdateChiroDatabases u = new UpdateChiroDatabases();
            u.executeSQLScript("ALTER TABLE `medical`.`patientinsurance` ADD COLUMN `preauthvisits` INTEGER UNSIGNED NOT NULL DEFAULT 0 AFTER `notes`;");
        } catch (Exception ex) {
            Logger.getLogger(TestUpdateCatalog.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

}
