<%@include file="globalvariables.jsp" %>
<SCRIPT language=JavaScript>
<!-- 
function win(parent){
if(parent != null && parent != 'None') { window.opener.location.href=parent }
self.close();
//-->
}
</SCRIPT>
<%

// ---------------------------------------------------------------------------------------------------------- //
// Initialize Variables ------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------------------- //

    String fileName   = "";
    String uniqueKey  = "";

    String parentLocation = (String)session.getAttribute("parentLocation");
    String returnUrl = (String)session.getAttribute("returnUrl");

// ---------------------------------------------------------------------------------------------------------- //
// Receive parameters --------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------------------- //
    String recordNumber=null;
    if(request.getParameter("rcd") != null) {
        recordNumber = request.getParameter("rcd");
    }
    Document doc = new Document(io, recordNumber);
    ResultSet docRs = io.opnUpdatableRS("select * from patientdocuments where id=" + recordNumber);
    if(docRs.next()) {
       docRs.deleteRow();
    }
    docRs.close();
    doc.synchFiles();
%>
<%
    if(returnUrl.equals("")) { %>
        <body onLoad="win('<%= parentLocation %>')">
        <body>
<%    }
%>
