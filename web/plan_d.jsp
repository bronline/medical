<%@ include file="globalvariables.jsp" %>
<title>Treatment Plan</title>

<script language="javascript">
  function submitForm(action) {
    var frmA=document.forms["frmInput"]
    frmA.method="POST"
    frmA.action=action
    frmA.submit()
  }
  
  function totalCharges() {
    patientPortion = parseFloat(document.forms["frmInput"].elements["patientportion"].value);
    insurancePortion = parseFloat(document.forms["frmInput"].elements["insuranceportion"].value);
    total = patientPortion + insurancePortion;
    document.forms["frmInput"].elements["totalAmount"].value = total;
    document.forms["frmInput"].elements["patientportion"].value=formatNumber(document.forms["frmInput"].elements["patientportion"].value);
    document.forms["frmInput"].elements["insuranceportion"].value=formatNumber(document.forms["frmInput"].elements["insuranceportion"].value);
    document.forms["frmInput"].elements["totalAmount"].value=formatNumber(document.forms["frmInput"].elements["totalAmount"].value);
  }
  
  function totalVisits() {
    visits           = parseInt(document.forms["frmInput"].elements["visits"].value);
    previousvisits   = parseInt(document.forms["frmInput"].elements["previousvisits"].value);
    visitsToDate     = parseInt(document.forms["frmInput"].elements["visitsToDate"].value);
    visitsAllowed    = parseInt(document.forms["frmInput"].elements["visitsallowed"].value);

    visitsRemaining  = visits-visitsToDate-previousvisits;
    remainingCovered = visitsAllowed-visitsToDate;
    
    document.forms["frmInput"].elements["visitsRemaining"].value = visitsRemaining;
    document.forms["frmInput"].elements["remainingCovered"].value = remainingCovered;
  }  
</script>

<%
// Initialize local variables
    String ID               = request.getParameter("planid");
    String patientId        = request.getParameter("patientid");

// If the id in the request is null or an empty string make it 0 to indicate an add
    if(ID == null || ID.equals("")) {
        ID = "0";
    }

// If the member id is not passed make the member id 0
    if(patientId == null || patientId.equals("")) {
        patientId = "0";
    }

// Get an input item with the record ID to set the rcd and ID fields
    PatientPlan plan = new PatientPlan(io, ID);
    out.print(plan.getInputForm(patientId));

// This will return to the return point set in the calling program
    session.setAttribute("returnUrl", "");
%>
