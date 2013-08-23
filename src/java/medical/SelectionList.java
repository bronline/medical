/*
 * SelectionList.java
 *
 * Created on December 12, 2005, 10:27 AM
 *
 * To change this template, choose Tools | Options and locate the template under
 * the Source Creation and Management node. Right-click the template and choose
 * Open. You can then make changes to the template in the Source Editor.
 */

package medical;
import tools.*;
import tools.utils.*;

/**
 *
 * @author rwandell
 */
public class SelectionList {
    
    private RWConnMgr io;

    private StringBuffer sl                 = new StringBuffer();
    private String queryString;
    private String maintenanceUrl;
    private String pageTitle;
    private String tableName;
    private int maintWindowHeight           = 150;
    private int maintWindowWidth            = 450;
    
    /** Creates a new instance of SelectionList */
    public SelectionList(RWConnMgr io) throws Exception {
        setConnMgr(io);
    }

    public void setConnMgr(RWConnMgr newIo) throws Exception {
        io = newIo;
    }
    
    public void setQueryString(String newQuery) {
        queryString = newQuery;
    }
    
    public void setMaintenanceUrl(String newUrl) {
        maintenanceUrl = newUrl;
    }
    
    public void setPageTitle(String newTitle) {
        pageTitle = newTitle;
        tableName = pageTitle.toLowerCase();
    }
    
    public void setMaintWindowHeight(int newHeight) {
        maintWindowHeight = newHeight;
    }
    
    public void setMaintWindowWidth(int newWidth) {
        maintWindowWidth = newWidth;
    }
    
    public String getTableName() {
        return tableName;
    }
    
    public String getSelectionList() throws Exception {
        sl.delete(0, sl.length());
        RWFilteredList lst = new RWFilteredList(io);
        RWHtmlTable htmTb = new RWHtmlTable("600", "0");
        RWHtmlForm frm = new RWHtmlForm();
        
    // Set special attributes on the filtered list object
        lst.setCellPadding("3");
        lst.setAlternatingRowColors("#ffffff", "#cccccc");
        lst.setTableHeading(pageTitle);
        lst.setUrlField(0);
        lst.setNumberOfColumnsForUrl(2);
        lst.setRowUrl(maintenanceUrl);
        lst.setShowRowUrl(true);
        lst.setOnClickAction("window.open");
        lst.setOnClickOption("\"" + pageTitle + "\",\"width=" + maintWindowWidth + ",height=" + maintWindowHeight + ",scrollbars=no,left=100,top=100,\"");
        lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
        lst.setShowComboBoxes(false);
        lst.setTableHeadingOptions("");
        lst.setUseCatalog(true);
        lst.setDivHeight(300);

    // Show the filtered list
        sl.append(lst.getHtml(queryString) );

        sl.append(frm.startForm());
        sl.append(frm.button("New " + pageTitle, "class=button onClick=window.open(\"" + maintenanceUrl + "?id=0\",\"" + pageTitle.trim() + "\",\"width=450,height=150,scrollbars=no,left=100,top=100,\");" ));
        sl.append(frm.endForm());

        return sl.toString();
    }
}
