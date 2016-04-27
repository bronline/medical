/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package medical.edi;

import java.io.File;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.logging.Level;
import java.util.logging.Logger;
import tools.RWConnMgr;
import tools.RWJarFile;
import tools.utils.Format;

/**
 *
 * @author Randy
 */
public class Process835EOBs {
    public RWConnMgr io;
    public String dateProcessed;
    public String databaseName;
    public String eobLocation = "c:\\chiropractice\\eob";
    public String batchStatus = "";
    public boolean processed = false;

    public Process835EOBs() {

    }

    public Process835EOBs(String databaseName) {
        setDatabaseName(databaseName);
    }

    public void setDatabaseName(String databaseName) {
        this.databaseName = databaseName;
    }

    public boolean load() {
        boolean loaded = false;
        try {
            dateProcessed = Format.formatDate(new java.util.Date(), "yyyy-MM-dd");
            io = new RWConnMgr("localhost", this.databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);
            checkEOBFolders(io);
            loaded=true;
        } catch (Exception ex) {
            Logger.getLogger(Process835EOBs.class.getName()).log(Level.SEVERE, null, ex);
        }
        return loaded;
    }

    public void checkEOBFolders(RWConnMgr io) throws Exception {
        PreparedStatement lPs = io.getConnection().prepareStatement("insert into eobbatches (batchname, dateprocessed, status, processed) values(?,?,?,?)");
        PreparedStatement pmtPs = io.getConnection().prepareStatement("update edipayments set eobbatchid=? where eobbatchid=0");
        PreparedStatement expPs = io.getConnection().prepareStatement("update ediexceptions set eobbatchid=? where eobbatchid=0");
        PreparedStatement dedPs = io.getConnection().prepareStatement("update deductables set batchid=? where batchid=0");

        File eobDir = new File(this.eobLocation + "\\" + io.getLibraryName());
        File [] fileList = eobDir.listFiles();
        for(int i=0;i<fileList.length;i++) {
            File f = fileList[i];
            if(f.isFile() && f.getName().endsWith(".zip")) {
                ResultSet lRs = io.opnRS("select * from eobbatches where batchname='" + f.getName().substring(0,f.getName().indexOf(".zip")) + "'");
                if(!lRs.next()) {
                    RWJarFile zipFile = new RWJarFile(f.getCanonicalPath());
                    zipFile.extractIntoDirectory(this.eobLocation + "\\" + io.getLibraryName() + "\\" + f.getName().substring(0,f.getName().indexOf(".zip")));
                    File thisFileDir = new File(this.eobLocation + "\\" + io.getLibraryName() + "\\" + f.getName().substring(0,f.getName().indexOf(".zip")));
                    File [] extractedFileList = thisFileDir.listFiles();
                    for(int j=0;j<extractedFileList.length;j++) {
                        if(extractedFileList[j].isFile() && extractedFileList[j].getName().endsWith(".835")) {
                            batchStatus = EDI835Parser.parse(extractedFileList[j].getCanonicalPath(), io.getLibraryName());
                            if(batchStatus.equals("Posted")) { processed = true; }
                        }
                    }
                    
                }
                
                String path = f.getCanonicalPath();
                File filePath = new File(path);
                filePath.delete();
                
                lPs.setString(1, f.getName().substring(0,f.getName().indexOf(".zip")));
                lPs.setString(2,dateProcessed);
                lPs.setString(3, batchStatus);
                lPs.setBoolean(4, processed);
                lPs.execute();

                io.setMySqlLastInsertId();
                pmtPs.setInt(1, io.getLastInsertedRecord());
                pmtPs.execute();

                expPs.setInt(1, io.getLastInsertedRecord());
                expPs.execute();

                dedPs.setInt(1, io.getLastInsertedRecord());
                dedPs.execute();
            }
        }
    }
}
