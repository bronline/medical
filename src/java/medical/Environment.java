/*
 * Environment.java
 *
 * Created on December 2, 2005, 8:03 PM
 *
 * To change this template, choose Tools | Options and locate the template under
 * the Source Creation and Management node. Right-click the template and choose
 * Open. You can then make changes to the template in the Source Editor.
 */

package medical;
import tools.*;
import tools.utils.*;
import java.sql.*;

/**
 *
 * @author rwandell
 */
public class Environment extends MedicalResultSet {
    private RWConnMgr io;
    
    /** Creates a new instance of Environment */
    public Environment(RWConnMgr newIo) throws Exception {
        io = newIo;
        refresh();
    }
    
    public void refresh() throws Exception {
        setResultSet(io.opnRS("select * from environment"));
        rs.next();
    }
    
    public String getDocumentPath() throws Exception {
        return getString("documentpath");
    }
    
    public String getBrowserPath() throws Exception {
        return getString("browserpath");
    }
    
    public String getTemplatePath() throws Exception {
        return getString("templatepath");
    }
    
    public String getDefaultPrinter() throws Exception {
        return getString("defaultprinter");
    }
    
    public int getDefaultResource() throws Exception {
        return getInt("defaultresource");
    }
}
