<%-- 
    Document   : updaterecord_ajax
    Created on : Nov 1, 2008, 1:31:33 PM
    Author     : Randy
--%>
<%@include file="globalvariables.jsp" %>
<SCRIPT language=JavaScript>
<!-- 
function win(parent){
alert(opener.location.href)
var txtHint=opener.document.getElementById("txtHint")
txtHint.style.visibility="hidden";
opener.location.href="test1.jsp"
//-->
}
</SCRIPT>
<%

// ---------------------------------------------------------------------------------------------------------- //
// Initialize Variables ------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------------------- //

//    String dbHost     = "localhost";
//    String dbDatabase = "medical";
//    String dbUser     = "rwtools";
//    String dbPass     = "rwtools";
    String fileName   = "";
    String uniqueKey  = "";
    String deleteRcd  = "";

    String parentLocation = (String)session.getAttribute("parentLocation");

    int rcd           = 0;

// ---------------------------------------------------------------------------------------------------------- //
// Receive parameters --------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------------------- //

    if(request.getParameter("rcd") != null) {
        String recordNumber = request.getParameter("rcd");
        rcd = Integer.parseInt(recordNumber);
	uniqueKey = "ID=" + rcd;
    }

    if(request.getParameter("fileName") != null && !request.getParameter("fileName").trim().equals("")) {
        fileName = request.getParameter("fileName");
    } else {
        fileName = (String)session.getAttribute("fileName");
    }

    if(request.getParameter("delete") != null && !request.getParameter("delete").trim().equals("")) {
        deleteRcd = request.getParameter("delete");
    }

    String returnUrl = (String)session.getAttribute("returnUrl");

// ---------------------------------------------------------------------------------------------------------- //
// If Filename and Database Name were passed, process the update request ------------------------------------ //
// ---------------------------------------------------------------------------------------------------------- //

    if(fileName != null && !fileName.trim().equals("")) {
//        RWConnMgr io = new RWConnMgr(dbHost, dbDatabase, dbUser, dbPass);
	Connection lCn = io.getConnection();

// ---------------------------------------------------------------------------------------------------------- //
// Process Delete request ----------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------------------- //

        if(deleteRcd.equals("Y")) {
            if(fileName.toLowerCase().equals("patientplan")) {
//                Patient patient = new Patient(io, "0");
                patient.updatePatientPlanInfo(rcd);
            } else if(fileName.toLowerCase().equals("charges") && rcd != 0) {
                PreparedStatement pmtPs=lCn.prepareStatement("DELETE FROM PAYMENTS WHERE CHARGEID=" + rcd);
                pmtPs.executeUpdate();
            }
            PreparedStatement lPs = lCn.prepareStatement("DELETE FROM " + fileName + " WHERE " + uniqueKey);
            lPs.executeUpdate();
//            lCn.close();
            if(returnUrl != null && !returnUrl.equals("")) { response.sendRedirect(returnUrl); }
        } else {

// ---------------------------------------------------------------------------------------------------------- //
// Process update request ----------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------------------- //

            if(io.updateRecord(request, fileName, rcd, uniqueKey)) {
                if(fileName.equals("patients")) {
                    if(rcd == 0) {
                        rcd = io.getLastInsertedRecord();
//                        Patient patient = new Patient(io, "" + rcd, true);
                        patient.setId(rcd);
                        patient.generateAccountNumber();
                    }
                    if(!returnUrl.equals("visits.jsp") && !returnUrl.equals("doctornotes.jsp")) {
                        returnUrl = "patientmaint.jsp?id=" + rcd;
                    }
                } 
                else if(fileName.toLowerCase().equals("patientplan") && rcd == 0) {
//                    Patient patient = new Patient(io, "0");
                    patient.updatePatientPlanInfo(io.getLastInsertedRecord());
                }

//                lCn.close();
                if(returnUrl != null && !returnUrl.equals("")) {
                    response.sendRedirect(returnUrl);
                }
            } else {
                out.print("Error updating record");
//                lCn.close();
            }
        }
    }
%>
<body onLoad="win('')"></body>

