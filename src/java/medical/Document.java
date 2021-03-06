/*
 * Document.java
 *
 * Created on November 29, 2005, 9:37 PM
 *
 * To change this template, choose Tools | Options and locate the template under
 * the Source Creation and Management node. Right-click the template and choose
 * Open. You can then make changes to the template in the Source Editor.
 */

package medical;
import java.util.*;
import java.io.*;
import java.sql.*;
import tools.*;
import tools.utils.*;
import org.apache.commons.fileupload.*;
import javax.servlet.http.*;
import medical.edi.Process835EOBs;

/**
 *
 * @author rwandell
 */
public class Document {
    private long totSize      = 0;
    private long fileSize     = 0;
    private int id            = 0;
    private boolean doUpload  = true;

    private String absoluteRoot;
    private String templateRoot;
    private long sizeMax             = 10000000;
    private long individualSizeLimit = 40000000;
    private int sizeThreshold        = 4096;
    private String repositoryPath;
    private String temporaryPath;
    private String targetFile        = "";
    private String description;
    private String documentPath;
    private DiskFileUpload fu = new DiskFileUpload();
    private Iterator i;
    private int patientId;
    private int documentType;
    private int identifierId;
    private int sequence;
    private String typeDescription   = "";
    private String identifierDescription = "";
    private RWConnMgr io;
    private Patient patient = new Patient();
    private Environment env;
    private ResultSet docRs;
    
    /** Creates a new instance of Document */
    public Document() {

    }
    
    public Document(RWConnMgr newMgr) throws Exception {
        setConnMgr(newMgr);
    }

    public Document(RWConnMgr newMgr, String newId) throws Exception {
        setConnMgr(newMgr);
        setDocumentId(newId);
    }

    public Document(RWConnMgr newMgr, int newId) throws Exception {
        setConnMgr(newMgr);
        setDocumentId(newId);
    }

    public Document(RWConnMgr newMgr, int newPatient, int newType, int newIdent) throws Exception {
        setConnMgr(newMgr);
        setPatientId(newPatient);
        setDocumentType(newType);
        setDocumentIdentifier(newIdent);
    }
    
    public void setConnMgr(RWConnMgr newIo) throws Exception {
        io=newIo;
        setEnvironment();
        patient.setConnMgr(io);
    }
    
    public void setPatientId(int newPatient) throws Exception {
        patientId = newPatient;
        patient.setId(patientId);
    }
    
    public void setDocumentType(int newType) {
        documentType = newType;
    }
    
    public void setDocumentIdentifier(int newIdentifier) {
        identifierId = newIdentifier;
    }
    
    public void setDocumentPath(String path) {
        documentPath = path;
    }
    
    public void setDocumentDescription(String newDesc) {
        description = newDesc;
    }

    public void setSequence(int newSequence) {
        sequence = newSequence;
    }

    private void setEnvironment() throws Exception {
        env = new Environment(io);
        setAbsoluteRoot();
        setTemplateRoot();
    }
    
    private void setAbsoluteRoot() throws Exception {
        absoluteRoot = env.getDocumentPath();
        repositoryPath = absoluteRoot + "\\webuploads\\tempbiguploads\\";
    }
    
    private void setTemplateRoot() throws Exception {
        templateRoot = env.getTemplatePath();
        temporaryPath = templateRoot + "\\webuploads\\tempbiguploads\\";
    }
    
    private void setMasterTableDefaults() throws Exception {
    // Try to get the defaults from the master table
        ResultSet mRs = io.opnRS("select * from mastersettings");
        if(mRs.next()) {
            if(!mRs.getString("absoluteroot").equals("")) { absoluteRoot = mRs.getString("absoluteRoot"); }
            if(mRs.getLong("maxfilesize") != 0) { sizeMax = mRs.getLong("maxfilesize"); }
            if(mRs.getInt("sizethreshold") != 0) { sizeThreshold = mRs.getInt("sizethreshold"); }
            if(!mRs.getString("repositorypath").equals("")) { repositoryPath = mRs.getString("repositorypath"); }
            if(!mRs.getString("individualsizelimit").equals("")) { individualSizeLimit = mRs.getLong("individualsizelimit"); }
        }
        mRs.close();
    }
    
    public void setDocumentId(int newId) throws Exception {
        id = newId;
        getDocument();
    }
    
    public void setDocumentId(String newId) throws Exception {
        try {
            setDocumentId(Integer.parseInt(newId));
        } catch (Exception e) {
            
        }
    }
    
    public void getDocument() throws Exception {
        docRs = io.opnRS("select * from patientdocuments where id=" + id);
        if(docRs.next()) {
            setPatientId(docRs.getInt("patientid"));
            setDocumentType(docRs.getInt("documenttype"));
            setDocumentIdentifier(docRs.getInt("identifierid"));
            setDocumentPath(docRs.getString("documentpath"));
            setDocumentDescription(docRs.getString("description"));
            setSequence(docRs.getInt("seq"));
        } else {
            patientId=0;
            documentType=0;
            identifierId=0;
            documentPath=null;
            description=null;
            sequence=0;
        }
    }
    
    public void getDocument(int newId) throws Exception {
        setDocumentId(newId);
    }
    
    public int getDocumentId() {
        return id;
    }
    
    public int getPatientId() {
        return patientId;
    }
    
    public int getDocumentType() {
        return documentType;
    }

    public int getDocumentIdentifier() {
       return identifierId;
    }
    
    public String getDocumentPath() {
        return documentPath;
    }
    
    public String getDocumentDescription() {
        return description;
    }
    
    public int getSequence() {
        return sequence;
    }
    
    public void getFileItems(HttpServletRequest request) throws Exception {
    // Setup to roll through the items on the upload form
        List fileItems = fu.parseRequest(request);
        i = fileItems.iterator();        
    }

    public String getTypeDescription() throws Exception {
        ResultSet dRs = io.opnRS("select description from documenttypes where id=" + documentType);
        if(dRs.next()) {
            typeDescription = dRs.getString("description");
        } else {
            typeDescription = "" + documentType;
        }
        dRs.close();

        return typeDescription;
    }

    public String getIdentifierDescription() throws Exception {
        ResultSet dRs = io.opnRS("select identifier from documentidentifiers where id=" + identifierId + " and documenttype=" + documentType);
        if(dRs.next()) {
            identifierDescription = dRs.getString("identifier");
        } else {
            identifierDescription = "" + identifierId;
        }
        dRs.close();

        return identifierDescription;
    }
   
    public void setDiskFileUpload(String newPath) {
    // Set the parameters for the DiskFileUpload object
        fu.setSizeMax(sizeMax);
        fu.setSizeThreshold(sizeThreshold);
        fu.setRepositoryPath(newPath);        
    }

    public File checkDir(String dir) {
    // Make the document directory if it doesn't exist
        File documentDir = new File(dir);
        if (!documentDir.exists()) {
            documentDir.mkdir();
        }
        return documentDir;
    }
    
    public void upload() throws Exception {
        setDiskFileUpload(repositoryPath);
        
        FileItem fi = (FileItem)i.next();
        if (fi != null) {
            fileSize = fi.getSize();
        } else {
            doUpload = false;
        }
        
    // Get the additional fields associated with the file
        while(i.hasNext()) {
            FileItem oi = (FileItem)i.next();
            String parameterName = oi.getFieldName();
            if(parameterName.equals("description")) { description = oi.getString(); }
            else if(parameterName.equals("targetFile")) { targetFile = oi.getString(); }
            else if(parameterName.equals("documenttype")) {documentType = Integer.parseInt(oi.getString()); }
            else if(parameterName.equals("identifiertype")) {identifierId = Integer.parseInt(oi.getString()); }
        }    
        
        // Make the document directory if it doesn't exist
        File documentDir = checkDir(absoluteRoot);

    // Make the patient directory if it doesn't exist
        File patientDir = checkDir(documentDir + "\\" + patientId);

    // Make the document type directory if it doesn't exist
        getTypeDescription();
        File typeDir = checkDir(patientDir + "\\" + typeDescription);
       
    // Make the document identifier directory if it doesn't exist
        getIdentifierDescription();
        File identifierDir = checkDir(typeDir + "\\" + identifierDescription);
        
        if(description == null || description.equals("")) {
    // Set the file decription to a default value
            description = Format.formatDate(new java.util.Date(), "MM/dd/yyyy");
        }

    // If no target file was sent, make the target file name the same as the upload file name
        String fileName = fi.getName();
        if(targetFile == null || targetFile.equals("")) {
            if(fileName.lastIndexOf("\\")>-1) {
                targetFile = identifierDir + fileName.substring(fileName.lastIndexOf("\\"));
            } else {
                targetFile = identifierDir + fileName;
            }
        } else {
            targetFile = identifierDir + "\\" + targetFile;
        }

    // Is the document already there?
        File uploadedFile = new File(targetFile);
        if (uploadedFile.exists() && doUpload) {
            uploadedFile.delete();
        }

        if (doUpload && !targetFile.toUpperCase().contains(".JSP") && !targetFile.toUpperCase().contains(".PHP")) {
    // Write out the target file
            fi.write(new File(targetFile));
            File targetFileObject = new File(targetFile);

            patient.updatePatientDocumentInfo(documentType, identifierId, targetFile, description);
            synchFiles();
        }
    }
    
    public void uploadTemplate() throws Exception {
        setDiskFileUpload(temporaryPath);
        
    // Make the document directory if it doesn't exist
        File documentDir = checkDir(templateRoot);

        FileItem fi = (FileItem)i.next();
        if (fi != null) {
            fileSize = fi.getSize();
        } else {
            doUpload = false;
        }

    // Get the additional fields associated with the file
        while(i.hasNext()) {
            FileItem oi = (FileItem)i.next();
            String parameterName = oi.getFieldName();
            if(parameterName.equals("description")) { setDocumentDescription(oi.getString()); }
            else if(parameterName.equals("targetFile")) { targetFile = oi.getString(); }
        }

        if(description == null || description.equals("")) {
    // Set the file decription to a default value
            description = Format.formatDate(new java.util.Date(), "MM/dd/yyyy");
        }

    // If no target file was sent, make the target file name the same as the upload file name
        targetFile = documentDir +  "\\" + targetFile;

    // Is the document already there?
        File uploadedFile = new File(targetFile);
        if (uploadedFile.exists() && doUpload) {
            uploadedFile.delete();
        }

    // Write out the target file
        fi.write(new File(targetFile));
        File targetFileObject = new File(targetFile);
        
    // Write the template information to the document template file
        ResultSet dRs = io.opnUpdatableRS("select * from documenttemplates where id=0");
        
        dRs.moveToInsertRow();
        dRs.updateInt("type", documentType);
        dRs.updateInt("identifier", identifierId);
        dRs.updateString("description", description);
        dRs.updateString("pathtotemplate", targetFile);
        dRs.insertRow();
        
        dRs.close();
    }

    public void uploadEOB() throws Exception {
        setDiskFileUpload("c:\\chiropractice\\eob\\");

        FileItem fi = (FileItem)i.next();
        if (fi != null) {
            fileSize = fi.getSize();
        } else {
            doUpload = false;
        }

    // Get the additional fields associated with the file
        while(i.hasNext()) {
            FileItem oi = (FileItem)i.next();
            String parameterName = oi.getFieldName();
            if(parameterName.equals("description")) { description = oi.getString(); }
            else if(parameterName.equals("targetFile")) { targetFile = oi.getString(); }
            else if(parameterName.equals("documenttype")) {documentType = Integer.parseInt(oi.getString()); }
            else if(parameterName.equals("identifiertype")) {identifierId = Integer.parseInt(oi.getString()); }
        }

        // Make the document directory if it doesn't exist
        File documentDir = checkDir("c:\\chiropractice\\");

    // Make the patient directory if it doesn't exist
        File eobDir = checkDir(documentDir + "\\eob");

    // Make the document type directory if it doesn't exist
        File instanceDir = checkDir(eobDir + "\\" + io.getLibraryName());

    // If no target file was sent, make the target file name the same as the upload file name
        String fileName = fi.getName();
        if(targetFile == null || targetFile.equals("")) {
            if(fileName.lastIndexOf("\\")>-1) {
                targetFile = instanceDir + fileName.substring(fileName.lastIndexOf("\\"));
            } else {
                if(instanceDir.toString().endsWith("\\")) {
                    targetFile = instanceDir + fileName;
                } else {
                    targetFile = instanceDir + "\\" + fileName;
                }
            }
        } else {
            targetFile = instanceDir + "\\" + targetFile;
        }

    // Is the document already there?
        File uploadedFile = new File(targetFile);
        if (uploadedFile.exists() && doUpload) {
            uploadedFile.delete();
        }

        if (doUpload && !targetFile.toUpperCase().contains(".JSP") && !targetFile.toUpperCase().contains(".PHP")) {
    // Write out the target file
            fi.write(new File(targetFile));
            File targetFileObject = new File(targetFile);
            Process835EOBs eob = new Process835EOBs(io.getLibraryName());
            eob.load();
        }
    }
    
    public void synchFiles() throws Exception {
    // Initialize variables
        String root       = absoluteRoot;
        String fileName   = "";
        String myQuery    = "";

        root += "\\" + patientId;

    // Create a file object with the starting point for the teacher
        File fl = new File(root);

    // Create an ArrayList of all files contained in the uploads database
        myQuery = "select * from patientdocuments where patientid=" + patientId;
        ResultSet lRs = io.opnUpdatableRS(myQuery);

    // Create a container to hold the list of files from the database
        ArrayList dbFiles = new ArrayList();

    // Roll through the records in the database and capture the files in the ArrayList
        while(lRs.next()) {
            fileName = lRs.getString("documentpath");
            dbFiles.add(fileName);
        }
        lRs.close();

    // Synchronize the files in the directories with the upload database
        ArrayList directoryStructure = synch(fl, dbFiles);

    // Syncrhonize the database with the files in the directory structure
        lRs = io.opnUpdatableRS("select * from patientdocuments where patientid=" + patientId);
        while(lRs.next()) {
            int sd = 0;
            fileName = lRs.getString("documentpath");
            for(sd=0; sd<directoryStructure.size(); sd++) {
                String dsFileName = (String)directoryStructure.get(sd);
                if(dsFileName.toUpperCase().equals(fileName.toUpperCase())) {
                    break;
                }
            }
            if(sd >= directoryStructure.size()) {
                lRs.deleteRow();
                lRs.beforeFirst();
            }
        }

    // Close uploads resultset
        lRs.close();

    }

    
    public ArrayList synch(File fl, ArrayList dbFiles) throws Exception {
        ArrayList ds        = new ArrayList();
        String fileName     = "";
        int j               = 0;

    // Roll through the files in the directory and delete those that do not
    // have an entry in the uploads database.
        File [] files = fl.listFiles();

    // If there is a directory structure, process the files in it
        if(files != null) {
            for(int i=0; i<files.length; i++) {

                if(files[i].isDirectory()) {
    // If this is a directory, process that part of the tree
                    ArrayList subDir = synch(files[i], dbFiles);
                    for(int sd=0; sd<subDir.size(); sd ++) {
                        String fn = (String)subDir.get(sd);
                        ds.add(fn);
                    }
                } else {
    // Check to see if the file in the directory has an entry in the database
                    fileName = files[i].getCanonicalPath();
                    for(j=0; j<dbFiles.size(); j++) {
                        String dbFileName = (String)dbFiles.get(j);
                        if(fileName.toUpperCase().equals(dbFileName.toUpperCase())) {
    // If the file is in the directory add it to the directory structure array list
                            ds.add(fileName);
                            break;
                        }
                    }
    // If the file does not have an entry in the directory structure, delete it
                    if(j >= dbFiles.size()) {
                        files[i].delete();
                        int xxxx = 0;
                    }
                }

            }

        }

    // A list of files still remaining in the directory structure
        return ds;

    }
    
    // Check to see if multiple versions of the same document are permitted
    public boolean areMultiplesAlowed(int documentType, int identifierId) throws Exception {
        boolean multiplesAllowed = false;
        ResultSet dRs = io.opnRS("SELECT * FROM documentidentifiers where documenttype=" + documentType + " and id=" + identifierId);
        if(dRs.next()) {
            multiplesAllowed = dRs.getBoolean("multiplesallowed");
        }
        dRs.close();
        
        return multiplesAllowed;
    }
}
