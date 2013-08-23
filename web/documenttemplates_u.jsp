<%@ include file="globalvariables.jsp" %>
<script>
    function checkForChange(what) {
        var value= what.options[what.selectedIndex].value;
        var name = what.name;
        var frm  = document.forms["frmInput"];
        frm.action = "documenttemplates_u.jsp?" + name + "=" + value;
        frm.submit();
    }
    
    function getDocument() {
        var frm = document.forms["frmInput"];
        frm.action = "documenttemplates_u.jsp?load=Y";
        frm.submit();
    }

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
    
    function win(where) {
        window.opener.location.href=where;
        self.close();        
    }
    
</script>
<%
    String typeQuery    = "select 0 as id, ' ' as description union select id, description from documenttypes order by description";
    String identQuery   = "select 0 as id, ' ' as identifier union select id, identifier from documentidentifiers where documenttype=";
    StringBuffer uf     = new StringBuffer();

    String documentType = request.getParameter("documentType");
    String identifier   = request.getParameter("identifier");
    String description  = request.getParameter("description");
    String load         = request.getParameter("load");
    String upload       = request.getParameter("upload");

    String parentLocation = (String)session.getAttribute("parentLocation");

    if(documentType == null) { documentType = " "; }
    if(identifier == null) { identifier = " "; }
    if(description == null) { description = Format.formatDate(new java.util.Date(), "MM/dd/yyyy"); }

    if(load == null && upload == null) {

        RWHtmlForm frm      = new RWHtmlForm("frmInput", "documenttemplates_u.jsp", "POST");
        RWHtmlTable htmTb   = new RWHtmlTable("600", "0");

        ResultSet dRs       = io.opnRS(typeQuery);

        out.print(frm.startForm());

        out.print(htmTb.startTable());
        out.print(htmTb.startRow());
        out.print(htmTb.addCell("<b>Document Type</b>"));
        out.print(htmTb.addCell(frm.comboBox(dRs, "documentType", "id", false, "1", null, documentType, "class=cBoxText onChange=checkForChange(this)")));
        out.print(htmTb.endRow());

        if(!documentType.equals(" ")) {
            ResultSet iRs = io.opnRS(identQuery + documentType);
            if(iRs.last()) {
                if(iRs.getRow() > 2) {
                    iRs.beforeFirst();
                    out.print(htmTb.startRow());
                    out.print(htmTb.addCell("<b>Identifier</b>"));
                    out.print(htmTb.addCell(frm.comboBox(iRs, "identifier", "id", false, "1", null, identifier, "class=cBoxText onChange=checkForChange(this)")));
                    out.print(htmTb.endRow());
                } else {
                    iRs.absolute(2);
                    out.print(htmTb.startRow());
                    out.print(htmTb.addCell(frm.hidden(iRs.getString("id"), "identifier"), "colspan=2"));
                    out.print(htmTb.endRow());
                    identifier = iRs.getString("id");
                }
            }
        }

        if(!identifier.equals(" ")) {
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("<b>Description</b>"));
            out.print(htmTb.addCell(frm.textBox(description, "description", "35", "35", "class=tBoxText")));
            out.print(htmTb.endRow());
        }

        out.print(htmTb.endTable());

        if(!identifier.equals(" ")) {
            out.print(frm.button("load template", "class=button onClick=getDocument()"));
        }

        out.print(frm.endForm());

        dRs.close();
    } else if(upload == null) {
        String typeDescription       = "";
        String identifierDescription = "";

        ResultSet dRs = io.opnRS("select description from documenttypes where id=" + documentType);
        if(dRs.next()) {
            typeDescription = dRs.getString("description");
        }
        dRs.close();

        dRs = io.opnRS("select identifier from documentidentifiers where id=" + identifier + " and documenttype=" + documentType);
        if(dRs.next()) {
            identifierDescription = dRs.getString("identifier");
        }
        dRs.close();

    // Instantiate the RWHtmlTable, RWHtmlForm and RWConnMgr objects
        RWInputForm frm = new RWInputForm();
        RWHtmlTable htmTb = new RWHtmlTable("300", "0");
        htmTb.replaceNewLineChar(false);
        frm.setName("frmInput");
        frm.setAction("documenttemplates_u.jsp?upload=Y");
        frm.setMethod("POST");

    // Start the form and table
        uf.append(frm.startForm("encType=\"multipart/form-data\""));
        session.setAttribute("documenttype", documentType);
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

    // Request for the upload file description
        uf.append(htmTb.startRow());
        uf.append(htmTb.addCell("<b>Document description</b>"));
        uf.append(htmTb.addCell(frm.textBox(description, "description", "size=35 class=tBoxText")));
        uf.append(htmTb.endRow());

    // Request for the target file name
        uf.append(htmTb.startRow());
        uf.append(htmTb.addCell("<b>File name for file</b>"));
        uf.append(htmTb.addCell(frm.textBox("", "targetFile", "class=tBoxText")));
        uf.append(htmTb.endRow());

    // End the table
        uf.append(htmTb.endTable());

    // Show the submit button
        uf.append(frm.submitButton("store template", "class=button", "saveBtn"));

    // End the form
        uf.append(frm.endForm());

        out.print(htmTb.getFrame(htmTb.BOTH,"","#ffffff",3,uf.toString()));
    } else if(upload.equals("Y")) {
        documentType    = (String)session.getAttribute("documenttype");
        identifier      = (String)session.getAttribute("identifierid");
        int type        = 0;
        int ident       = 0;

        if(documentType != null) { type = Integer.parseInt(documentType); }
        if(identifier != null) { ident = Integer.parseInt(identifier); }

        Document doc = new Document(io, 0, type, ident);
        doc.getFileItems(request);
        doc.uploadTemplate(); %>
        <body onLoad="win('<%= parentLocation %>')">
        <body>
<%

    }
%>