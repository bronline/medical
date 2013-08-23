<%@ include file="globalvariables.jsp" %>
<%@ page import="java.io.BufferedWriter, java.io.FileWriter" %>
<SCRIPT language=JavaScript>
<!-- 
function win(where){
window.opener.location.href=where;
self.close();
//-->
}
</SCRIPT>

<%
    String targetFile   = "";
    String targetDir    = "";
    String id           = request.getParameter("id");
    String documentName = request.getParameter("documentname");
    String description = request.getParameter("documentdescription");
    String parentLocation    = (String)session.getAttribute("parentLocation");

    if(patient.next()) {
        patient.beforeFirst();
        String myQuery = "select * from documenttemplates where id=" + id;

        ResultSet dRs = io.opnRS(myQuery);
        if(dRs.next()) {

            ResultSet lRs = io.opnRS("select * from patients where id=1");

            if (documentName==null) {
                documentName             = dRs.getString("pathtotemplate");
                int x = documentName.lastIndexOf("\\");
                documentName = documentName.substring(x + 1);
                documentName = Format.formatDate(new java.util.Date(), "yyyyMMdd") + documentName;
            }

            int type                     = dRs.getInt("type");
            int identifier               = dRs.getInt("identifier");
            if (documentName==null) {
                description              = dRs.getString("description");
            }
            int patientId                = patient.getId();
            targetFile                   = env.getDocumentPath();
            targetDir                    = env.getBrowserPath();

            Document doc  = new Document(io, patientId, type, identifier);

            doc.checkDir(targetFile);

            targetFile = targetFile + patientId + "\\";
            targetDir += patientId + "/";
            doc.checkDir(targetFile);

            targetFile += doc.getTypeDescription() + "\\";
            targetDir += doc.getTypeDescription() + "/";
            doc.checkDir(targetFile);

            targetFile += doc.getIdentifierDescription() + "\\";
            targetDir += doc.getIdentifierDescription() + "/";
            doc.checkDir(targetFile);

            targetFile += documentName;
            targetDir += documentName;

            RWDocument template = new RWDocument(dRs.getString("pathtotemplate"));

//            template.setResultSet(patient);
//            template.writeDocument(targetFile);
            template.copyDocument(dRs.getString("pathtotemplate"),targetFile);

            dRs.close();

            patient.updatePatientDocumentInfo(type, identifier, targetFile, description);
        }
    }


%>
        <body onLoad="win('<%= parentLocation %>')">
        <body>

