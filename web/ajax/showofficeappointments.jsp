<%-- 
    Document   : showofficeappointments
    Created on : Feb 19, 2015, 8:54:35 PM
    Author     : Randy
--%>

<%@include file="sessioninfo.jsp" %>
<%
    RWFilteredList lst = new RWFilteredList(io);
    RWHtmlTable htmTb  = new RWHtmlTable("650", "0");
    String url         = "visitactivity.jsp?";
    
    String [] ch = {"", "Date", "Patient", "Time", "Provider", "Contact Number", "Email" };
    String [] cw = {"0", "75", "100", "100", "100", "100", "100"};
    
    lst.setColumnWidth(cw);
    lst.setTableWidth("800");
    lst.setTableBorder("0");
    lst.setCellPadding("3");
    lst.setAlternatingRowColors("#ffffff", "#cccccc");
//    lst.setRoundedHeadings("#030089", "");
    lst.setShowComboBoxes(false);
    lst.setDivHeight(105);
    
    lst.setColumnAlignment(1, "CENTER");
    lst.setColumnAlignment(3, "CENTER");
    lst.setColumnAlignment(5, "CENTER");
    lst.setColumnFormat(5, "(###)-###-####");
    
    lst.setShowRowUrl(true);

    lst.setOnClickAction(1, "javascript:showVisit(##idColumn##) style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    lst.setOnClickAction(2, "javascript:showVisit(##idColumn##) style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    
    out.print("<div align=\"center\" style=\"width: 100%;\">" + lst.getHtml(request, "CALL rwcatalog.prTopSliderContent('" + io.getLibraryName() + "')", ch) + "</div>");
%>
