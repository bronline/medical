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
 * @author BR Online Solutions
 */
public class TabMenu extends RWResultSet {
    RWConnMgr io;
    private int numTabs;
    private int id = 0;
    private int sequence;
    private int submenuOf;
    private String tabDesc;
    private String tabUrl;
    private boolean selfRedirect;
    private boolean showSearch;
    public String bodyWidth = "840";
    private String context="medical";
    
    /** Creates a new instance of Location */
    public TabMenu() {
    }

    public TabMenu(RWConnMgr io, int newId) throws Exception {
        setConnMgr(io);
        setId(newId);
    }

    public TabMenu(RWConnMgr io, int newId, String context) throws Exception {
        setConnMgr(io);
        setId(newId);
        setContext(context);
    }
    
    public void setConnMgr(RWConnMgr newIo) throws Exception {
        if(io == null) {
            io = newIo;
        }
    }
    
    public void setId(int newId) throws Exception {
        id = newId;
        setResultSet(io.opnRS("select * from rwcatalog.tabmenu where id=" + id));
        refresh();
    }
    
    public void setId(String newId) throws Exception {
        setId(Integer.parseInt(newId));
    }
    
    public void refresh() throws Exception {
        if(next()) {
            setSequence(getInt("sequence"));
            setSubmenuOf(getInt("submenuof"));
            setTabDesc(getString("tabdesc"));
            setTabUrl(getString("taburl"));
            setSelfRedirect(getBoolean("selfredirect"));
            setShowSearch(getBoolean("showSearch"));
        }
        beforeFirst();
    }

    public int getId() throws Exception {
        return id;
    }
    
    public int getSequence() throws Exception {
        return sequence;
    }
    
    public int getSubmenuOf() throws Exception {
        return submenuOf;
    }
    
    public String getTabDesc() throws Exception {
        return tabDesc;
    }

    public String getTabUrl() throws Exception {
        return tabUrl;
    }
    
    public boolean getSelfRedirect() throws Exception {
        return selfRedirect;
    }
    
    public boolean getShowSearch() throws Exception {
        return showSearch;
    }

    public int getNumTabs() throws Exception {
        return numTabs;
    }

    public void setSequence(int newSequence) {
        sequence = newSequence;
    }
    
    public void setSubmenuOf(int newSubmenuOf) {
        submenuOf = newSubmenuOf;
    }
    
    public void setTabDesc(String newTabDesc) {
        tabDesc = newTabDesc;
    }
    
    public void setTabUrl(String newTabUrl) {
        tabUrl = newTabUrl;
    }
    
    public void setSelfRedirect(boolean newSelfRedirect) {
        selfRedirect = newSelfRedirect;
    }
    
    public void setShowSearch(boolean newShowSearch) {
        showSearch = newShowSearch;
    }

    public void setNumTabs(int newNumTabs) {
        numTabs = newNumTabs;
    }
    
    public void update() throws Exception {
        setResultSet(io.opnUpdatableRS("select * from rwcatalog.tabmenu where id=" + id));
        
        if(next()) {
            updateInt("sequence", sequence);
            updateInt("submenuof", submenuOf);
            updateString("tabdesc", tabDesc);
            updateString("taburl", tabUrl);
            updateBoolean("selfredirect", selfRedirect);
            updateBoolean("showsearch", showSearch);
            updateRow();
        } else {
            moveToInsertRow();
            updateInt("sequence", sequence);
            updateInt("submenuof", submenuOf);
            updateString("tabdesc", tabDesc);
            updateString("taburl", tabUrl);
            updateBoolean("selfredirect", selfRedirect);
            updateBoolean("showsearch", showSearch);
            insertRow();
        }

    }

    public String getTabTopHtml() throws Exception {

        ResultSet tabRs = io.opnRS("select * from rwcatalog.tabmenu where application = '" + getContext() + "' and submenuof=0 order by sequence");
        ResultSet globalRs = io.opnRS("select * from rwcatalog.globalsettings where id=1");
        globalRs.next();

        RWHtmlTable ttHtmTb = new RWHtmlTable(this.bodyWidth, "0");
        int firstTab = 0;
        int currentTab = 0;
        int numTabs = 0;

        StringBuffer mnu  = new StringBuffer();
        StringBuffer pageOut = new StringBuffer();

        String cellStyle  = "";
        String cellColor  = "";
        String cellHighlight = "";
        String tabUrl     = "";
        String pageUrl    = "";
        int currentSubTab = 0;
        int tableTab      = 0;

        if (submenuOf > 0 || tabUrl == null) {
            currentTab = submenuOf;
            currentSubTab = id;
        } else {
            currentTab = id;
        }
        
        ttHtmTb.replaceNewLineChar(false);

        if(tabRs.next()) { firstTab = tabRs.getInt("id"); }
        if(currentTab == 0) { currentTab = firstTab; }
        tabRs.beforeFirst();

        pageOut.append(ttHtmTb.startTable());
        pageOut.append(ttHtmTb.startRow());

        while(tabRs.next()) { 
            if(tabRs.getInt("id") != currentTab) {
                cellColor = "#cccccc";
            } else {
                cellColor = "#e0e0e0";
            }
            pageOut.append(ttHtmTb.addCell("","style=\"background-color: " + cellColor + "; height: 6px; border-top-left-radius: 7px; border-top-right-radius: 7px;\""));
//            pageOut.append(ttHtmTb.roundedTopCell(1,"",cellColor,""));
            numTabs ++;
        }

        pageOut.append(ttHtmTb.endRow());
        pageOut.append(ttHtmTb.startRow());

        tabRs.beforeFirst();
        while(tabRs.next()) {
            cellStyle="style=\"cursor: pointer; ";
            cellHighlight = "";
            tabUrl = "";
            tableTab = tabRs.getInt("id");
            if(tableTab != currentTab) { cellStyle += "border-bottom: black 1px solid; "; }
            if(tableTab != firstTab)   { cellStyle += "border-left: black thin solid; "; }
//            if(tableTab != currentTab) { cellStyle += "background: #cccccc;"; }
            if(tableTab != currentTab) { cellStyle += "background-image: url('/medicaldocs/tab_background_w.gif\'); "; } else { cellStyle += "background-image: url('/medicaldocs/tab_background.gif'); color: #ffffff; "; }
//            if(tableTab != currentTab) { cellHighlight = " onMouseOver=\"this.className='highlightOn';\" onMouseOut=\"this.className='highlightOff';\""; }
            if(tableTab != currentTab) { cellHighlight = " onMouseOver=\"highlightOn(this);\" onMouseOut=\"highlightOff(this);\""; }
            cellStyle += "\"";
            if(tableTab != currentTab) { 
                if(tabRs.getString("taburl") ==null || tabRs.getString("taburl").equals("")) {
                    ResultSet subRs = io.opnRS("select * from rwcatalog.tabmenu where application = '" + getContext() + "' and  submenuof=" + tableTab + " order by sequence");
                    if(subRs.next()) {
                        tabUrl = subRs.getString("taburl");
                        if(tabUrl.contains("##APPLICATIONPATH##")) { tabUrl = globalRs.getString("applicationpath"); }
                        if(tabUrl.contains("##CONFIGURATIONPATH##")) { tabUrl = globalRs.getString("configurationpath"); }
                        tabUrl=tabUrl.replaceAll("##DOMAINNAME##", globalRs.getString("domainname"));
                        tabUrl=tabUrl.replaceAll("##DATABASENAME##", io.getLibraryName());
                        tabUrl = " onClick=location.href='" + tabUrl;
                    }
                    subRs.close();
                } else {
                    tabUrl = tabRs.getString("taburl");
                    if(tabUrl.contains("##APPLICATIONPATH##")) { tabUrl = globalRs.getString("applicationpath"); }
                    if(tabUrl.contains("##CONFIGURATIONPATH##")) { tabUrl = globalRs.getString("configurationpath"); }
                    tabUrl=tabUrl.replaceAll("##DOMAINNAME##", globalRs.getString("domainname"));
                    tabUrl=tabUrl.replaceAll("##DATABASENAME##", io.getLibraryName());
                    tabUrl = " onClick=location.href='" + tabUrl;
                }
            }
//            pageOut.append(ttHtmTb.addCell(tabRs.getString("tabdesc"), ttHtmTb.CENTER, "bgcolor=#e0e0e0 "+ cellHighlight + cellStyle + tabUrl + "'"));
            pageOut.append(ttHtmTb.addCell(tabRs.getString("tabdesc"), ttHtmTb.CENTER, cellHighlight + cellStyle + tabUrl + "'"));
            if(tableTab == currentTab && tabRs.getString("tabUrl") != null) { 
                pageUrl = tabRs.getString("taburl");
                if(pageUrl.contains("##APPLICATIONPATH##")) { pageUrl = globalRs.getString("applicationpath"); }
                if(pageUrl.contains("##CONFIGURATIONPATH##")) { pageUrl = globalRs.getString("configurationpath"); }
                pageUrl=pageUrl.replaceAll("##DOMAINNAME##", globalRs.getString("domainname"));
                pageUrl=pageUrl.replaceAll("##DATABASENAME##", io.getLibraryName());
            }
            if(tableTab == currentTab && (tabRs.getString("tabUrl") == null || tabRs.getString("tabUrl").equals(""))) {

                ResultSet subRs = io.opnRS("select * from rwcatalog.tabmenu where application = '" + getContext() + "' and submenuof=" + tableTab + " order by sequence");

                if(subRs.next()) { firstTab = subRs.getInt("id"); }
                if(currentSubTab == 0) { currentSubTab = firstTab; }
                subRs.beforeFirst();

                tableTab = 0;
                ttHtmTb.setWidth("100%");
                mnu.append(ttHtmTb.startTable());
                mnu.append(ttHtmTb.startRow("bgcolor=#ffffff"));

                while(subRs.next()) { 
                    if(subRs.getInt("id") != currentSubTab) {
                        cellColor = "#cccccc";
                    } else {
                        cellColor = "#e0e0e0";
                    }
                    mnu.append(ttHtmTb.addCell("","style=\"background-color: " + cellColor + "; height: 6px; border-top-left-radius: 7px; border-top-right-radius: 7px;\""));
//                    mnu.append(ttHtmTb.roundedTopCell(1,"",cellColor,""));
                }

                mnu.append(ttHtmTb.endRow());
                mnu.append(ttHtmTb.startRow());

                subRs.beforeFirst();
                while(subRs.next()) {
                    cellStyle="style=\"cursor: pointer; ";
                    cellHighlight = "";
                    tableTab = subRs.getInt("id");
                    if(tableTab != currentSubTab) { cellStyle += "border-bottom: black 1px solid; "; }
                    if(tableTab != firstTab)   { cellStyle += "border-left: black thin solid; "; }
//                    if(tableTab != currentSubTab) { cellStyle += "background: #cccccc;"; }
                    if(tableTab != currentSubTab) { cellStyle += "background-image: url('/medicaldocs/tab_background_w.gif'); "; } else { cellStyle += "background-image: url('/medicaldocs/tab_background.gif'); color: #ffffff; "; }
//                    if(tableTab != currentSubTab) { cellHighlight = " onMouseOver=\"this.className='highlightOn';\" onMouseOut=\"this.className='highlightOff';\""; }
                    if(tableTab != currentSubTab) { cellHighlight = " onMouseOver=\"highlightOn(this);\" onMouseOut=\"highlightOff(this);\""; }
                    cellStyle += "\"";
                    if(tableTab != currentSubTab) {
                        tabUrl = subRs.getString("taburl");
                        if(tabUrl.contains("##APPLICATIONPATH##")) { tabUrl = globalRs.getString("applicationpath"); }
                        if(tabUrl.contains("##CONFIGURATIONPATH##")) { tabUrl = globalRs.getString("configurationpath"); }
                        tabUrl=tabUrl.replaceAll("##DOMAINNAME##", globalRs.getString("domainname"));
                        tabUrl=tabUrl.replaceAll("##DATABASENAME##", io.getLibraryName());
                    }
//                    mnu.append(ttHtmTb.addCell(subRs.getString("tabdesc"), ttHtmTb.CENTER, "bgcolor=#e0e0e0 "+ cellHighlight + cellStyle + " onClick=location.href='" + tabUrl + "'"));
                    mnu.append(ttHtmTb.addCell(subRs.getString("tabdesc"), ttHtmTb.CENTER, cellHighlight + cellStyle + " onClick=location.href='" + tabUrl + "'"));
                    if(tableTab == currentSubTab && subRs.getString("tabUrl") != null) { 
                        pageUrl = subRs.getString("taburl");
                        if(pageUrl.contains("##APPLICATIONPATH##")) { pageUrl = globalRs.getString("applicationpath"); }
                        if(pageUrl.contains("##CONFIGURATIONPATH##")) { pageUrl = globalRs.getString("configurationpath"); }
                        pageUrl=pageUrl.replaceAll("##DOMAINNAME##", globalRs.getString("domainname"));
                        pageUrl=pageUrl.replaceAll("##DATABASENAME##", io.getLibraryName());
                    }
                }
                mnu.append(ttHtmTb.endRow());
                mnu.append(ttHtmTb.endTable());

                subRs.close();
            }
        }
        pageOut.append(ttHtmTb.endRow());

        if(mnu.toString() != null && !mnu.toString().equals("")) {
    // Put out an empty 3px row between the top row of tabs and the second row of tabs
            pageOut.append(ttHtmTb.startRow("height='3px'"));
            pageOut.append(ttHtmTb.startCell("bgcolor=#ffffff colspan=" + numTabs));
            pageOut.append(ttHtmTb.endCell());
            pageOut.append(ttHtmTb.endRow());

    // Put out the second row of tabs
            pageOut.append(ttHtmTb.startRow());
            pageOut.append(ttHtmTb.addCell(mnu.toString(), "colspan=" + numTabs));
            pageOut.append(ttHtmTb.endRow());
        }

        pageOut.append(ttHtmTb.startRow("height=10"));
        pageOut.append(ttHtmTb.addCell("", "bgcolor=#ffffff colspan=" + numTabs));
        pageOut.append(ttHtmTb.endRow());

        pageOut.append(ttHtmTb.startRow("height=375"));
        pageOut.append(ttHtmTb.startCell(ttHtmTb.CENTER, "colspan=" + numTabs +" bgcolor=#ffffff"));

        setNumTabs(numTabs);

        return pageOut.toString();
    }

    /**
     * @return the context
     */
    public String getContext() {
        return context;
    }

    /**
     * @param context the context to set
     */
    public void setContext(String context) {
        this.context = context;
    }
}
