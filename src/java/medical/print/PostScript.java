/*
 * PostScript.java
 *
 * Created on March 2, 2006, 8:27 PM
 *
 * To change this template, choose Tools | Options and locate the template under
 * the Source Creation and Management node. Right-click the template and choose
 * Open. You can then make changes to the template in the Source Editor.
 */

package medical.print;
import tools.*;
import java.sql.ResultSet;
import javax.print.DocFlavor;
import javax.print.attribute.HashPrintRequestAttributeSet;
import javax.print.attribute.PrintRequestAttributeSet;
import javax.print.attribute.standard.JobName;

/**
 *
 * @author BR Online Solutions
 */
public class PostScript extends RWPrintEngine {
    private String templateFile;
    private String targetFile;
    private RWDocument document;
    private ResultSet lRs;
    private DocFlavor flavor        = DocFlavor.INPUT_STREAM.AUTOSENSE;
    PrintRequestAttributeSet aset = new HashPrintRequestAttributeSet();
    JobName jn = null;
    /** Creates a new instance of PostScript */
    public PostScript() {
    }
    
    public PostScript(ResultSet rs) {
        setResultSet(rs);
    }
    
    public void setTemplateFile(String template) {
        templateFile = template;
    }
    
    public void setTargetFile(String target) {
        targetFile = target;
    }
    
    public void setResultSet(ResultSet rs) {
        lRs = rs;
    }
    
    public void  print(String template, String target) throws Exception {
        if(templateFile == null) { setTemplateFile(template); }
        if(targetFile == null) { setTargetFile(target); }
        if(document == null) { document = new RWDocument(); }
        
        document.setTemplatePath(templateFile);
        document.setResultSet(lRs);
        document.addNewLine(true);
        document.setNewLineChar("\n");
        document.writeDocument(targetFile);

        setInputFile(targetFile);
        printDoc();
        
    }
}
