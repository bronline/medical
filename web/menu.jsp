<%@include file="template/pagetop.jsp" %>

<style>
.highlightOn   { color: #ffffff; }
.highlightOff  { color: #000000; }
</style>

<%
    RWHtmlTable htmTb = new RWHtmlTable("800", "0");
    StringBuffer mnu  = new StringBuffer();
    String cellStyle  = "";
    String cellColor  = "";
    String cellHighlight = "";
    String tabUrl     = "";
    String pageUrl    = "";
    String tab        = request.getParameter("tab");
    String subTab     = request.getParameter("subtab");
    int currentTab    = 0;
    int currentSubTab = 0;
    int firstTab      = 0;
    int tableTab      = 0;
    int numTabs       = 0;
    ResultSet tabRs = io.opnRS("select * from tabmenu where submenuof=0 order by sequence");

    StringBuffer pageOut = new StringBuffer();
    
    htmTb.replaceNewLineChar(false);

    if(tab != null && !tab.equals("")) {
        currentTab = Integer.parseInt(tab);
    }

    if(subTab != null && !subTab.equals("")) {
        currentSubTab = Integer.parseInt(subTab);
    }

    if(tab == null && session.getAttribute("tab") != null) {
        tab = (String)session.getAttribute("tab");
        currentTab = Integer.parseInt(tab);
    }
    if(subTab == null && session.getAttribute("subTab") != null) {
        subTab = (String)session.getAttribute("subTab");
        currentSubTab = Integer.parseInt(subTab);
    }

    if(tabRs.next()) { firstTab = tabRs.getInt("id"); }
    if(currentTab == 0) { currentTab = firstTab; }
    tabRs.beforeFirst();

    pageOut.append(htmTb.startTable());
    pageOut.append(htmTb.startRow());

    while(tabRs.next()) { 
        if(tabRs.getInt("id") != currentTab) {
            cellColor = "#cccccc";
        } else {
            cellColor = "#e0e0e0";
        }
        pageOut.append(htmTb.roundedTopCell(1,"",cellColor,""));
        numTabs ++;
    }

    pageOut.append(htmTb.endRow());
    pageOut.append(htmTb.startRow());

    tabRs.beforeFirst();
    while(tabRs.next()) {
        cellStyle="style=\"cursor:hand;";
        cellHighlight = "";
        tableTab = tabRs.getInt("id");
        if(tableTab != currentTab) { cellStyle += "border-bottom: black 1px solid; "; }
        if(tableTab != firstTab)   { cellStyle += "border-left: black thin solid; "; }
        if(tableTab != currentTab) { cellStyle += "background: #cccccc;"; }
        if(tableTab != currentTab) { cellHighlight = " onMouseOver=\"this.className='highlightOn';\" onMouseOut=\"this.className='highlightOff';\""; }
        cellStyle += "\"";
        if(tableTab != currentTab) { tabUrl = "menu.jsp?tab=" + tableTab; }
        pageOut.append(htmTb.addCell(tabRs.getString("tabdesc"), htmTb.CENTER, "bgcolor=#e0e0e0 "+ cellHighlight + cellStyle + " onClick=location.href='" + tabUrl + "'"));
        if(tableTab == currentTab && tabRs.getString("tabUrl") != null) { pageUrl = tabRs.getString("taburl"); }
        if(tableTab == currentTab && (tabRs.getString("tabUrl") == null || tabRs.getString("tabUrl").equals(""))) {

            pageOut.append(htmTb.startRow("height='3px'"));
            pageOut.append(htmTb.startCell("bgcolor=#ffffff colspan=" + numTabs));
            pageOut.append(htmTb.endCell());
            pageOut.append(htmTb.endRow());

            ResultSet subRs = io.opnRS("select * from tabmenu where submenuof=" + tableTab + " order by sequence");

            if(subRs.next()) { firstTab = subRs.getInt("id"); }
            if(currentSubTab == 0) { currentSubTab = firstTab; }
            subRs.beforeFirst();

            tableTab = 0;
            htmTb.setWidth("100%");
            mnu.append(htmTb.startTable());
            mnu.append(htmTb.startRow("bgcolor=#ffffff"));

            while(subRs.next()) { 
                if(subRs.getInt("id") != currentSubTab) {
                    cellColor = "#cccccc";
                } else {
                    cellColor = "#e0e0e0";
                }
                mnu.append(htmTb.roundedTopCell(1,"",cellColor,""));
                ;
            }

            mnu.append(htmTb.endRow());
            mnu.append(htmTb.startRow());

            subRs.beforeFirst();
            while(subRs.next()) {
                cellStyle="style=\"cursor:hand;";
                cellHighlight = "";
                tableTab = subRs.getInt("id");
                if(tableTab != currentSubTab) { cellStyle += "border-bottom: black 1px solid; "; }
                if(tableTab != firstTab)   { cellStyle += "border-left: black thin solid; "; }
                if(tableTab != currentSubTab) { cellStyle += "background: #cccccc;"; }
                if(tableTab != currentSubTab) { cellHighlight = " onMouseOver=\"this.className='highlightOn';\" onMouseOut=\"this.className='highlightOff';\""; }
                cellStyle += "\"";
                if(tableTab != currentSubTab) { tabUrl = "menu.jsp?tab=" + tabRs.getInt("id") + "&subtab=" + tableTab; }
                mnu.append(htmTb.addCell(subRs.getString("tabdesc"), htmTb.CENTER, "bgcolor=#e0e0e0 "+ cellHighlight + cellStyle + " onClick=location.href='" + tabUrl + "'"));
                if(tableTab == currentSubTab && subRs.getString("tabUrl") != null) { pageUrl = subRs.getString("taburl"); }
            }
            mnu.append(htmTb.endRow());
            mnu.append(htmTb.endTable());

            subRs.close();
        }
    }
    pageOut.append(htmTb.endRow());

    if(mnu.toString() != null && !mnu.toString().equals("")) {
    pageOut.append(htmTb.startRow());
    pageOut.append(htmTb.addCell(mnu.toString(), "colspan=" + numTabs));
    pageOut.append(htmTb.endRow());
    }

    pageOut.append(htmTb.startRow("height=10"));
    pageOut.append(htmTb.addCell("", "bgcolor=#ffffff colspan=" + numTabs));
    pageOut.append(htmTb.endRow());

    pageOut.append(htmTb.startRow("height=375"));
    pageOut.append(htmTb.startCell(htmTb.CENTER, "colspan=" + numTabs +" bgcolor=#ffffff"));

    if (!request.getParameterNames().hasMoreElements()) {
        out.print(pageOut.toString());
    }
    if(pageUrl != null && !pageUrl.equals("")) {
%>
   <jsp:include page='<%= pageUrl %>' />
<%
    if (request.getParameterNames().hasMoreElements()) {
        response.sendRedirect(self);
    }
    
    out.print(htmTb.endCell());
    out.print(htmTb.endRow());
    out.print(htmTb.roundedBottom(numTabs,"", "#ffffff",""));
    out.print(htmTb.endTable());

    tabRs.close();

    session.setAttribute("tab", "" + currentTab);
    session.setAttribute("subTab", "" + currentSubTab);
} 
%>

<%@include file="template/pagebottom.jsp" %>