<%--
    Document   : uploadedi835
    Created on : Jun 7, 2012, 3:54:27 PM
    Author     : Randy
--%>
<%@include file="template/pagetop.jsp" %>
<%@page import="org.apache.commons.fileupload.*" %>
<title>Upload file</title>
<style type="text/css">
    #paymentpannel {
        position: absolute;
        top: 100px;
        left: 250px;
        border-radius: 10;
        height: 240px;
        width: 400px;
        visibility: hidden;
        background-color: #a6c3f8;
        box-shadow: 10px 10px 5px #666666;
    }
</style>
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

    function postPayment(id,exceptionRecord) {
        var url="ajax/postedipayment.jsp?id="+id+"&exceptionRecord="+exceptionRecord+"&sid="+Math.random();

        $.ajax({
            url: url,
            success: function(data){
                $('#paymentpannel').css('visibility','visible');
                $('#paymentpannel').html(data);
            },
            error: function() {
                alert("There was a problem processing the request");
            }
        });
    }

    function deletePayment(id,exceptionRecord) {
        var url='ajax/deleteedipayment.jsp?id='+id+'&exceptionRecord='+exceptionRecord;

        $.ajax({
            url: url,
            success: function(data){
                $('#paymentpannel').css('visibility','hidden');
                location.href="uploadedi835.jsp";
            },
            error: function() {
                alert("There was a problem processing the request");
            }
        });
    }

    function closeBubble() {
        $('#paymentpannel').css('visibility','hidden');
    }

    function postThisPayment() {
        var formData = $('#paymentForm').serialize();
        var url='ajax/postedipayment.jsp?post=Y&' + formData;

        $.ajax({
            url: url,
            success: function(data){
                $('#paymentpannel').css('visibility','hidden');
                location.href="uploadedi835.jsp";
            },
            error: function() {
                alert("There was a problem processing the request");
            }
        });
    }
</script>
<div id="paymentpannel" ></div>
<%
// Initialize the work variables
    String id                = request.getParameter("patientid");
    String type              = request.getParameter("documenttype");
    String identifier        = request.getParameter("identifierid");
    int patientId            = 0;
    int documentType         = 0;
    int identifierId         = 0;
    int exceptionRecord      = 0;
    StringBuffer uf          = new StringBuffer();
    String upload            = request.getParameter("upload");
    String typeDescription   = "";
    String identifierDescription = "";
    String parentLocation    = "billing.jsp";

    // Setup to roll through the items on the upload form
        // If upload file has not been selected, present the form
        if(upload == null) {
        // Instantiate the RWHtmlTable, RWHtmlForm and RWConnMgr objects
            RWInputForm frm = new RWInputForm();
            RWHtmlTable htmTb = new RWHtmlTable("300", "0");
            htmTb.replaceNewLineChar(false);
            frm.setName("frmInput");
            frm.setAction("uploadedi835.jsp?upload=Y");
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

            uf.append(htmTb.addCell(frm.hidden("1","documenttype")));
            uf.append(htmTb.endRow());

            uf.append(htmTb.addCell(frm.hidden("1", "description")));
            uf.append(htmTb.endRow());

            uf.append(htmTb.addCell(frm.hidden("", "targetFile")));
            uf.append(htmTb.endRow());

        // End the table
            uf.append(htmTb.endTable());

        // Show the submit button
            uf.append(frm.submitButton("  save  ", "class=button", "saveBtn"));

        // End the form
            uf.append(frm.endForm());

            out.print(uf.toString());

            String myQuery = "SELECT" +
                    "  edipayments.id," +
                    "  patients.firstname," +
                    "  patients.lastname," +
                    "  edipayments.dos," +
                    "  items.code," +
                    "  case when items.id is null then 'Item Not Found' else items.description end as description," +
                    "  charges.chargeamount," +
                    "  charges.quantity," +
                    "  edipayments.paymentamount," +
                    "  edipayments.adjustmentamount," +
                    "  edipayments.ptientamount," +
                    "  case when edipayments.providerid=0 then 'Payer Not Found' else providers.name end as payername, " +
                    "  0 as exceptionrecord " +
                    "from edipayments " +
                    "left join patients on patients.id=edipayments.patientid " +
                    "left join charges on charges.id=edipayments.chargeid " +
                    "left join providers on providers.id=edipayments.providerid " +
                    "left join items on items.id=charges.itemid " +
                    "where not processed " +
                    "union " +
                    "SELECT" +
                    "  ediexceptions.id," +
                    "  case when patients.id is null then concat(ediexceptions.accountnumber,' -') else firstname end as firstname," +
                    "  case when patients.id is null then 'Patient Not Found' else lastname end as lastname," +
                    "  case when ediexceptions.dos is null or ediexceptions.dos='' then '0001-01-01' else ediexceptions.dos end as dos," +
                    "  ediexceptions.cptcode as code," +
                    "  case when ediexceptions.cptcode is null or ediexceptions.cptcode='' then 'Procedure Not Found' else items.description end as description," +
                    "  0 as chargeamount," +
                    "  0 as quantity," +
                    "  ediexceptions.paymentamount," +
                    "  ediexceptions.adjustmentamount," +
                    "  ediexceptions.patientamount," +
                    "  case when ediexceptions.providerid=0 then 'Payer Not Found' else providers.name end as payername, " +
                    "  1 as exceptionrecord " +
                    "from ediexceptions " +
                    "left join patients on patients.accountnumber=ediexceptions.accountnumber " +
                    "left join providers on providers.id=ediexceptions.providerid " +
                    "left join items on items.code=ediexceptions.cptcode " +
                    "where not processed " +
                    "order by lastname, firstname, dos";

//            ResultSet lRs = io.opnRS("SELECT *, case when edipayments.providerid=0 then 'Payer Not Found' else providers.name end as payername from edipayments left join patients on patients.id=edipayments.patientid left join charges on charges.id=edipayments.chargeid left join providers on providers.id=edipayments.providerid left join items on items.id=charges.itemid where not processed order by lastname, firstname, dos");
            ResultSet lRs = io.opnRS(myQuery);
            out.print(htmTb.startTable("850"));
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("","width=\"50\""));
            out.print(htmTb.headingCell("Patient","width=\"100\""));
            out.print(htmTb.headingCell("Payer","width=\"150\""));
            out.print(htmTb.headingCell("DOS",htmTb.CENTER,"width=\"75\""));
            out.print(htmTb.headingCell("Procedure","width=\"250\""));
            out.print(htmTb.headingCell("CHG<br/>AMT",htmTb.RIGHT,"width=\"50\""));
            out.print(htmTb.headingCell("PMT<br/>AMT",htmTb.RIGHT,"width=\"50\""));
            out.print(htmTb.headingCell("ADJ<br/>AMT",htmTb.RIGHT,"width=\"50\""));
            out.print(htmTb.headingCell("PAT<br/>AMT",htmTb.RIGHT,"width=\"50\""));
            out.print(htmTb.endRow());
            out.print(htmTb.endTable());
            out.print("<div style=\"width: 870; height: 300; overflow: auto;\">");
            out.print(htmTb.startTable("850"));
            while(lRs.next()) {
                out.print(htmTb.startRow());
                out.print(htmTb.addCell("<a herf=\"#\" onClick=\"javascript:postPayment(" + lRs.getString("id") + "," + lRs.getString("exceptionrecord") + ")\" style=\"cursor: pointer;\">post</a> | <a herf=\"#\" onClick=\"javascript:deletePayment(" + lRs.getString("id") + ")\" style=\"cursor: pointer;\">del</a>","width=\"50\""));
                out.print(htmTb.addCell(lRs.getString("firstname") + " " + lRs.getString("lastname")));
                out.print(htmTb.addCell(lRs.getString("payername")));
                out.print(htmTb.addCell(Format.formatDate(lRs.getString("dos"),"MM/dd/yy"),htmTb.CENTER));
                out.print(htmTb.addCell(lRs.getString("code") + " - " + lRs.getString("description")));
                out.print(htmTb.addCell(Format.formatCurrency((lRs.getDouble("chargeAmount")*lRs.getDouble("quantity"))),htmTb.RIGHT));
                out.print(htmTb.addCell(Format.formatCurrency(lRs.getDouble("paymentamount")),htmTb.RIGHT));
                out.print(htmTb.addCell(Format.formatCurrency(lRs.getDouble("adjustmentamount")),htmTb.RIGHT));
                out.print(htmTb.addCell(Format.formatCurrency(lRs.getDouble("ptientamount")),htmTb.RIGHT));
                out.print(htmTb.endRow());
            }
            lRs.close();
            lRs=null;

            out.print(htmTb.endTable());
            out.print("</div>");
        } else {
            patientId  = 0;

            if(type == null) { type = (String)session.getAttribute("documenttype"); }
            identifier = (String)session.getAttribute("identifierid");

            if(type != null) { documentType = Integer.parseInt(type); }
            if(identifier != null) { identifierId = Integer.parseInt(identifier); }

            Document doc = new Document(io, patientId, documentType, identifierId);
            doc.getFileItems(request);
            doc.uploadEOB();
            session.setAttribute("documenttype", null);
            session.setAttribute("identifierid", null);
%>
        <body onLoad="win('<%= parentLocation %>')">
        <body>

<%        }
%>
<%@include file="template/pagebottom.jsp" %>