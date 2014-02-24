<%-- 
    Document   : getpatientinsurance
    Created on : Sep 9, 2013, 1:31:27 PM
    Author     : Randy
--%>
<%@include file="sessioninfo.jsp" %>

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
        if(ID.equals("0")) {
            ins.setPatientId(Integer.parseInt(patientId));
        } else {
            ins.setId(Integer.parseInt(ID));
        }
        out.print(ins.getIntakeInputForm());

// This will return to the return point set in the calling program
        session.setAttribute("returnUrl", "");
    }
%>
<%@include file="cleanup.jsp" %>