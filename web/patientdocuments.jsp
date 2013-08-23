<%@ include file="template/pagetop.jsp" %>
<script>
function uploadDocument(patientId,documentType,identifier) {
	window.open("documentupload.jsp?patientid="+patientId+"&documenttype="+documentType+"&identifierid="+identifier,"Documents","width=500,height=200,left=150,top=200,toolbar=0,status=0,")
}
function createNewDocument() {
	window.open("patientdocuments_template.jsp","Documents","width=900,height=300,left=150,top=200,toolbar=0,status=0,")
}
</script>
<% 
try {
    RWHtmlTable htmTb = new RWHtmlTable("800", "0"); 
    RWFilteredList lst = new RWFilteredList(io); 
    RWFilteredList lst1 = new RWFilteredList(io); 
    RWFieldSet fldSet = new RWFieldSet(); 
    htmTb.replaceNewLineChar(false); 

    // Set up to show the list of patient documents 
    String url = "patientdocuments_d.jsp"; 
    String myQuery = "select a.id,  a.patientid,  b.description AS type, c.identifier, " +
           "SUBSTR(a.documentpath, LENGTH(a.documentpath)-INSTR(REVERSE(a.documentpath), '\\')+2) AS filename, " +
//           "a.documentpath as filename, " +
           "a.description " +
           "from patientdocuments a " +
           "left join documenttypes b on b.id = a.documenttype " +
           "left join documentidentifiers c on c.id = a.identifierid " +
           "where patientid=" + patient.getId();

    myQuery="select id, Type, Identifier, filename, Description from patientdocumentlist where patientid=" + patient.getId();

    String [] ch1 = {"", "Type", "Identifier", "File Name", "Description"}; 
    String [] cw = { "0", "100", "100", "350", "250" } ; 
    htmTb.replaceNewLineChar(false); 

    lst1.setTableWidth("800"); 
    lst1.setTableBorder("0"); 
    lst1.setAlternatingRowColors("#ffffff", "#cccccc"); 
    lst1.setRoundedHeadings("#030089", ""); 
    lst1.setUrlField(0); 
    lst1.setNumberOfColumnsForUrl(5); 
    lst1.setRowUrl(url); 
    lst1.setShowRowUrl(true); 
//    lst1.setOnClickAction("window.open"); 
//    lst1.setOnClickOption("\"Templates\",\"width=600,height=300,left=200,top=300,\"");
//    lst1.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\""); 
    lst1.setShowComboBoxes(true); 
    lst1.setUseCatalog(true); 
    
        lst1.setOnClickAction(null); 
    lst1.setOnClickOption(null); 
    lst1.setOnClickStyle(null); 
    lst1.setFormName("formFilter1"); 
    lst1.setColumnUrl(1,url,0); 
    lst1.setUrlTarget("docviewer"); 
    lst1.setColumnUrl(2,url,0); 
    lst1.setUrlTarget("docviewer"); 
    lst1.setColumnUrl(3,url,0); 
    lst1.setUrlTarget("docviewer"); 

// 
    
    lst1.setDivHeight(330); 
    lst1.setColumnWidth(cw); 

    out.print(fldSet.getFieldSet(lst1.getHtml(request,myQuery, ch1), "style='width: " + lst1.getTableWidth() +"'", "Patient Documents" + " for " + patient.getPatientName(), "style='font-size: 12; font-weight: bold;' align=center"));
    out.print("<br><br><input type=button onClick=createNewDocument() value='create new document using template' class=button>");
    out.print("&nbsp;&nbsp;&nbsp;<input type=button onClick=uploadDocument(" + patient.getId() + ",3,7) value='upload new document' class=button>");
} catch (Exception e) {
}
session.setAttribute("parentLocation","patientdocuments.jsp");
%> 
<%@ include file="template/pagebottom.jsp" %> 

