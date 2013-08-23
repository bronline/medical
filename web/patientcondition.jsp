<%-- 
    Document   : patientcondition
    Created on : Nov 1, 2008, 12:46:10 PM
    Author     : Randy
--%>
<%@ include file="ajax/sessioninfo.jsp" %>
<script language="JavaScript" src="js/date-picker.js"></script>
<%
// Initialize local variables
    String ID               = request.getParameter("id");
    String patientId        = request.getParameter("patientid");
    String update           = request.getParameter("update");
    String parentUrl        = request.getParameter("parentUrl");
    String getHint          = request.getParameter("hint");
    String setCondition     = request.getParameter("set");
    
    // If the id in the request is null or an empty string make it 0 to indicate an add
    if(ID == null || ID.equals("")) {
        ID = request.getParameter("rcd");
        if(ID == null || ID.equals("")) { ID = "0"; }
    }

// If the member id is not passed make the member id 0
    if(patientId == null || patientId.equals("")) {
        patientId = "0";
    }

    PatientConditions patientConditions = new PatientConditions(io, ID);
   
    if(update == null || update.trim().equals("")) {
// Instantiate a comment
        
        patientConditions.setUpdateJSP("patientcondition.jsp?update=Y");

        if(getHint != null && getHint.equals("Y")) {
            // Show the hint
            out.print("<v:roundrect style='width: 450; height: 100; text-valign: middle; text-align: center;'>");
            out.print("<div align=\"right\"><b style=\"cursor: pointer;\" onClick=\"showHide(txtHint,'HIDE')\">close</b></div>");
            out.print(patientConditions.getCondition(Integer.parseInt(ID)));
            out.print("</v:roundrect>");
        } else if(setCondition != null && setCondition.equals("Y")) {
            visit.setId(request.getParameter("visitId"));
            visit.setConditionId(Integer.parseInt(ID));
            visit.update();
            out.print(visit.getVisitCondition());
        } else {
            // Get an input item with the record ID to set the rcd and ID fields
            out.print("<v:roundrect style='width: 450; height: 270; text-valign: middle; text-align: center;'>");
            out.print(patientConditions.getInputForm(patientId));
//            out.print("<input type=hidden name=parentLocation id=parentLocation value='" + parentUrl + "'>");
            out.print("<input type=hidden name=\"parentLocation\" id=\"parentLocation\" value='CONDITION'>");
            out.print("<input type=hidden name=postLocation id=postLocation value='patientcondition.jsp'>");
            out.print("<input type=hidden name=fileName id=fileName value='patientdonditions'>");
            out.print("<input type=hidden name=update id=update value='Y'>");
            out.print("<input type=hidden name=patientid id=patientid value='" + patient.getId() + "'>");
            out.print("</v:roundrect>");
            // This will return to the return point set in the calling program
            session.setAttribute("returnUrl", "");
        }
    } else {
        if(request.getParameter("delete") == null || !request.getParameter("delete").equals("Y")) {
            patientConditions.setId(ID);
            patientConditions.setPatientId(""+patientConditions.getPatientId());
            patientConditions.setConditionType(request.getParameter("conditiontype"));
            patientConditions.setDescription(request.getParameter("description"));
            patientConditions.setCondition(request.getParameter("condition"));
            patientConditions.setFromDate(Format.formatDate(request.getParameter("fromdate"),"yyyy-MM-dd"));
            patientConditions.setToDate(Format.formatDate(request.getParameter("todate"),"yyyy-MM-dd"));
            patientConditions.setSameOrSimilar(request.getParameter("sameorsimilar"));
            patientConditions.setSimilarDate(Format.formatDate(request.getParameter("similardate"),"yyyy-MM-dd"));
            patientConditions.setReferringDoctor(request.getParameter("referringdoctor"));
            patientConditions.setReferringNPI(request.getParameter("referringnpi"));
            patientConditions.setState(request.getParameter("state"));
            patientConditions.setProviderId(request.getParameter("providerid"));
            patientConditions.update();
//            out.print(visit.getCondition());
            out.print(patientConditions.getCondition(patientConditions.getId()));
        } else {
            patientConditions.delete();
//            out.print(visit.getCondition());
            out.print(patientConditions.getCurrentCondition(patientId));
        }
        
    }
%>
