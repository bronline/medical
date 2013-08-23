<%@include file="globalvariables.jsp" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<title>Upload file</title>
<SCRIPT language=JavaScript>
<!-- 
function win(where){
window.opener.location.href=where;
self.close();
//-->
}
</SCRIPT>

<script language="javascript">
    function check(what) {
      var frmA=document.forms["frmInput"]
      if(frmA.elements["targetFile"].value == "") {
	  tf = what.value
	  tf = tf.substring(tf.lastIndexOf("\\") + 1)
        frmA.elements["targetFile"].value = tf
      }

    }

    function typeChange() {
      var frmA=document.forms["frmInput"]
      frmA.saveBtn.click()
    }
    
</script>

<%
// Initialize the work variables
    String id                = request.getParameter("patientid");
    String type              = request.getParameter("documenttype");
    String identifier        = request.getParameter("identifierid");
    int patientId            = 0;
    int documentType         = 0;
    int identifierId         = 0;
    StringBuffer uf          = new StringBuffer();
    String upload            = request.getParameter("upload");
    String typeDescription   = "";
    String identifierDescription = "";
    String parentLocation    = (String)session.getAttribute("parentLocation");

    // Setup to roll through the items on the upload form

    if(id == null) { id=(String)session.getAttribute("patientid"); }

    if(id != null && !id.equals("")) {

        patientId = Integer.parseInt(id);
        // If upload file has not been selected, present the form
        if(upload == null) {
            ResultSet dtRs = io.opnRS("select id, description from rwcatalog.documenttypes order by sequence");
            if(type != null) {
                documentType = Integer.parseInt(type);
                ResultSet dRs = io.opnRS("select description from documenttypes where id=" + type);
                if(dRs.next()) {
                    typeDescription = dRs.getString("description");
                }
                dRs.close();
            }

            if(identifier != null) {
                identifierId = Integer.parseInt(identifier);
                ResultSet dRs = io.opnRS("select identifier from documentidentifiers where id=" + identifier + " and documenttype=" + type);
                if(dRs.next()) {
                    identifierDescription = dRs.getString("identifier");
                }
                dRs.close();
            }

        // Instantiate the RWHtmlTable, RWHtmlForm and RWConnMgr objects
            RWInputForm frm = new RWInputForm();
            RWHtmlTable htmTb = new RWHtmlTable("300", "0");
            htmTb.replaceNewLineChar(false);
            frm.setName("frmInput");
            frm.setAction("documentupload.jsp?upload=Y");
            frm.setMethod("POST");

        // Start the form and table
            uf.append(frm.startForm("encType=\"multipart/form-data\""));
            session.setAttribute("patientid", id);
            session.setAttribute("documenttype", type);
            session.setAttribute("identifierid", identifier);
            uf.append(htmTb.startTable());

            // put out the form headings
            uf.append(htmTb.roundedTop(2,"", "#030089",""));
            uf.append(htmTb.startRow());
            uf.append(htmTb.headingCell("Uploading - " + typeDescription + " " + identifierDescription, "colspan=2"));
            uf.append(htmTb.endRow());
            uf.append(htmTb.roundedBottom(2, "", "#030089", ""));

        // Request for the upload file name
            uf.append(htmTb.startRow());
            uf.append(htmTb.addCell("<b>Document to upload</b>"));
            uf.append(htmTb.addCell(frm.file("uploadFile", "onBlur=check(this) class=tBoxText")));
            uf.append(htmTb.endRow());

        // Request for the upload file type
            uf.append(htmTb.startRow());
            uf.append(htmTb.addCell("<b>Document Type</b>"));
            uf.append(htmTb.addCell(frm.comboBox(dtRs,"documenttype", "documenttype", false, "1", null)));
            uf.append(htmTb.endRow());

        // Request for the upload file description
            uf.append(htmTb.startRow());
            uf.append(htmTb.addCell("<b>Document description</b>"));
            uf.append(htmTb.addCell(frm.textBox("", "description", "size=35 class=tBoxText")));
            uf.append(htmTb.endRow());

        // Request for the target file name
            uf.append(htmTb.startRow());
            uf.append(htmTb.addCell("<b>File name for file</b>"));
            uf.append(htmTb.addCell(frm.textBox("", "targetFile", "class=tBoxText")));
            uf.append(htmTb.endRow());

        // End the table
            uf.append(htmTb.endTable());

        // Show the submit button
            uf.append(frm.submitButton("  save  ", "class=button", "saveBtn"));

        // End the form
            uf.append(frm.endForm());

            out.print(htmTb.getFrame(htmTb.BOTH,"","#ffffff",3,uf.toString()));
        } else {
            patientId  = Integer.parseInt(id);
/*
            // first check if the upload request coming in is a multipart request
            boolean isMultipart = FileUpload.isMultipartContent(request);

            DiskFileUpload frmUpload = new DiskFileUpload();

            // parse this request by the handler
            // this gives us a list of items from the request
            java.util.List items = frmUpload .parseRequest(request);

            java.util.Iterator itr = items.iterator();

            while(itr.hasNext()) {
                FileItem item = (FileItem) itr.next();

                // check if the current item is a form field or an uploaded file
                if(item.isFormField()) {

                    // get the name of the field
                    String fieldName = item.getFieldName();
                    if(fieldName.equals("documenttype")) { type=item.getString(); }
                }
            }
*/
            if(type == null) { type = (String)session.getAttribute("documenttype"); }
            identifier = (String)session.getAttribute("identifierid");

            if(type != null) { documentType = Integer.parseInt(type); }
            if(identifier != null) { identifierId = Integer.parseInt(identifier); }

            Document doc = new Document(io, patientId, documentType, identifierId);
            doc.getFileItems(request);
            doc.upload(); 
            session.setAttribute("documenttype", null);
            session.setAttribute("identifierid", null);
%>
        <body onLoad="win('<%= parentLocation %>')">
        <body>

<%        }
    }
%>
