<link rel="stylesheet" type="text/css" href="css/stylesheet.css" title="csstylesheet">
<%
    String tab          = request.getParameter("tab");
    String bgColor = "";
    RWHtmlTable tabTbl  = new RWHtmlTable("100%", "0");
    int curTab          = 0;
    String tabDesc []   = { "Address Info", "Tax Info", "PIN Information", "HCFA Items", "Standard Payments" };

    if(tab == null) { 
        tab = (String)session.getAttribute("tab");
        if(tab == null) { tab = "1"; }
    }

    curTab = Integer.parseInt(tab);

    out.print(tabTbl.startTable());

    out.print(tabTbl.startRow());
    for(int x=0; x<tabDesc.length; x++) {
        bgColor = " background: #cccccc;\"";
        if((x+1) == curTab) { bgColor = " background: #ffffff;\""; }
        out.print(tabTbl.addCell(tabDesc[x], 2, "style=\"border-left: black solid 1px; border-top: black solid 1px; border-right: black solid 1px;" + bgColor, request.getRequestURI() + "?tab=" + (x+1)));
    }
    out.print(tabTbl.endRow());

    out.print(tabTbl.startRow());
    out.print(tabTbl.addCell("", tabTbl.LEFT, "height='3px' style=\"border-left: black solid 1px; border-right: black solid 1px;\" colspan=" + tabDesc.length));
    out.print(tabTbl.endRow());
%>