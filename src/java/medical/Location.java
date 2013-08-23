/*
 * Location.java
 *
 * Created on December 8, 2005, 12:46 PM
 *
 * To change this template, choose Tools | Options and locate the template under
 * the Source Creation and Management node. Right-click the template and choose
 * Open. You can then make changes to the template in the Source Editor.
 */

package medical;
import tools.*;
import java.sql.*;
 
/**
 *
 * @author rwandell
 */
public class Location extends RWResultSet {
    RWConnMgr io;
    private int id                  = 0;
    private String description;
    private String url;
    private String returnUrl;
    private boolean searchBubble    = false;
    
    /** Creates a new instance of Location */
    public Location() {
    }

    public Location(RWConnMgr io, int newId) throws Exception {
        setConnMgr(io);
        setId(id);
    }
    
    public void setConnMgr(RWConnMgr newIo) throws Exception {
        if(io == null) {
            io = newIo;
        }
    }
    
    public void setId(int newId) throws Exception {
        id = newId;
        setResultSet(io.opnRS("select * from locations where id=" + id));
        refresh();
    }
    
    public void setId(String newId) throws Exception {
        setId(Integer.parseInt(newId));
    }
    
    public void refresh() throws Exception {
        if(next()) {
            setDescription(getString("description"));
            setUrl(getString("url"));
            setReturnUrl(getString("returnUrl"));
            setSearchBubble(getBoolean("searchbubble"));
        }
        beforeFirst();
    }

    public int getId() throws Exception {
        return id;
    }
    
    public String getDescription() throws Exception {
        return description;
    }
    
    public String getUrl() throws Exception {
        return url;
    }
    
    public String getReturnUrl() throws Exception {
        return returnUrl;
    }
    
    public boolean getSearchBubble() throws Exception {
        return searchBubble;
    }
    
    public void setDescription(String newDesc) {
        description = newDesc;
    }
    
    public void setUrl(String newUrl) {
        url = newUrl;
    }
    
    public void setReturnUrl(String newUrl) {
        returnUrl = newUrl;
    }
    
    public void setSearchBubble(boolean newBol) {
        searchBubble = newBol;
    }
    
    public void update() throws Exception {
        setResultSet(io.opnUpdatableRS("select * from locations where id=" + id));
        
        if(next()) {
            updateString("description", description);
            updateString("url", url);
            updateString("returnUrl", returnUrl);
            updateRow();
        } else {
            moveToInsertRow();
            updateString("description", description);
            updateString("url", url);
            updateString("returnUrl", returnUrl);
            insertRow();
        }
    }
    
}
