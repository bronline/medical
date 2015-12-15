<%@ include file="globalvariables.jsp" %>
<%@ include file="ajax/ajaxstuff.jsp" %>
<script type="text/javascript" src="js/accordian.js"></script>
<title>Patient Insurance Provider</title>

<script language="javascript">
  function submitForm(action) {
    var frmA=document.forms["frmInput"]
    frmA.method="POST"
    frmA.action=action
    frmA.submit()
  }

  function getId() {
    var recordId=document.getElementById("ID")
    if(recordId.value=="0") {
        var today = new Date();
        var dateString = today.toLocaleDateString();
        
        document.getElementById("effectivedate").value="01/01/0001";
        document.getElementById("expirationdate").value="01/01/0001";
        document.getElementById("hicfa7dob").value="01/01/0001";
        document.getElementById("insuranceeffective").value="01/01/0001";
        document.getElementById("insurancetermdate").value="12/31/2099";
        document.getElementById("insurancebenefitsdate").value=dateString;
    }
  }

  function changeCopayAmountLabel(what) {
      alert(what.checked);
  }

</script>
<body onLoad="getId()">
<%
// Initialize local variables
    String ID               = request.getParameter("id");
    String patientId        = request.getParameter("patientId");

// If the id in the request is null or an empty string make it 0 to indicate an add
    if(ID == null || ID.equals("")) {
        ID = "0";
    }

// If the patient id is not passed and we're trying to add then bail
    if((patientId == null || patientId.equals("")) && ID.equals("0")) {
        out.print("Patient Id is not set");
    } else {

// Get an input item with the record ID to set the rcd and ID fields
        PatientInsurance ins = new PatientInsurance(io);
        if(ID.equals("0")) { ins.setPatientId(Integer.parseInt(patientId)); }
        out.print(ins.getInputForm(ID));

// This will return to the return point set in the calling program
        session.setAttribute("returnUrl", "");
    }
%>
</body>