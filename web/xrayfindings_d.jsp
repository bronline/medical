<%@ include file="globalvariables.jsp" %>
<title>Findings</title>

<script language="JavaScript" src="js/date-picker.js"></script>

<script language="javascript">
  function submitForm(action) {
    var frmA=document.forms["frmInput"]
    frmA.method="POST"
    frmA.action=action
    frmA.submit()
  }  
</script>
<script>
  function setFocus() {
    document.frmInput.comment.focus();
  }
</script>
<%
// Initialize local variables
    String ID               = request.getParameter("id");
    String patientId        = request.getParameter("patientid");

// If the id in the request is null or an empty string make it 0 to indicate an add
    if(ID == null || ID.equals("")) {
        ID = "0";
    }

// If the member id is not passed make the member id 0
    if(patientId == null || patientId.equals("")) {
        patientId = "0";
    }

// Instantiate a symptom
    XrayFinding finding = new XrayFinding(io, ID);

// Get an input item with the record ID to set the rcd and ID fields
    out.print(finding.getInputForm(patientId));

// This will return to the return point set in the calling program
    session.setAttribute("returnUrl", "");
%>
