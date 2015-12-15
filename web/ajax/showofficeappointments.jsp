<%-- 
    Document   : showofficeappointments
    Created on : Feb 19, 2015, 8:54:35 PM
    Author     : Randy
--%>

<%@include file="sessioninfo.jsp" %>
<%
    RWFilteredList lst = new RWFilteredList(io);
    RWHtmlTable htmTb  = new RWHtmlTable("650", "0");
    
    String [] ch       = {"", "", "Date", "Patient", "Time", "Provider" };

    lst.setTableWidth("800");
    lst.setTableBorder("0");
    lst.setCellPadding("3");
    lst.setAlternatingRowColors("#ffffff", "#cccccc");
//    lst.setRoundedHeadings("#030089", "");
    lst.setShowComboBoxes(false);
    lst.setDivHeight(105);
    
    lst.setColumnAlignment(2, "CENTER");
    lst.setColumnAlignment(4, "CENTER");
    
    out.print("<div align=\"center\" style=\"width: 100%;\">" + lst.getHtml(request, "CALL rwcatalog.prTopSliderContent('" + io.getLibraryName() + "')", ch) + "</div>");
%>
