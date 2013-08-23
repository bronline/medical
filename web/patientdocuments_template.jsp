<%@ include file="globalvariables.jsp" %>
<% 

try {
    out.print("<H1>Choose Template</H1>");
    // Set up the SQL statement 
    String myQuery = "select * from documenttemplatelist order by type, identifier"; 
    String url = "patientdocuments_u.jsp"; 
    String title = "Document Templates"; 
    String [] ch = { "", "Type", "Identifier", "Description", "Path to Template" }; 
    String [] cw = { "0", "100", "150", "150", "200" } ; 
    RWHtmlTable htmTb = new RWHtmlTable("800", "0"); 
    RWFilteredList lst = new RWFilteredList(io); 
    RWFieldSet fldSet = new RWFieldSet(); 
    htmTb.replaceNewLineChar(false); 

    lst.setTableWidth("800"); 
    lst.setTableBorder("0"); 
    lst.setAlternatingRowColors("#ffffff", "#cccccc"); 
    lst.setRoundedHeadings("#030089", ""); 
    lst.setUrlField(0); 
    lst.setNumberOfColumnsForUrl(5); 
    lst.setRowUrl(url); 
    lst.setShowRowUrl(true); 
//    lst.setOnClickAction("window.open"); 
//    lst.setOnClickOption("\"Templates\""); 
//    lst.setOnClickOption("\"Templates\",\"width=600,height=300,left=200,top=300,\"");
//    lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\""); 
    lst.setShowComboBoxes(true); 
    lst.setUseCatalog(true); 
    lst.setDivHeight(130); 
    lst.setColumnWidth(cw); 
    // Show the filtered list of available templates 
    out.print(fldSet.getFieldSet(lst.getHtml(request, myQuery, ch), "style='width: " + lst.getTableWidth() +"'", "Templates", "style='font-size: 12; font-weight: bold;' align=center"));
    out.print("<br>"); 
    out.print("<input type=button onClick=self.close() value='Done' class=button>&nbsp;");

} catch (Exception e) {
}
session.setAttribute("parentLocation","patientdocuments.jsp");
%> 

