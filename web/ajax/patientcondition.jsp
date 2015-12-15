<%-- 
    Document   : patientcondition
    Created on : Nov 1, 2008, 12:46:10 PM
    Author     : Randy
--%>
<%@ include file="sessioninfo.jsp" %>
<script language="JavaScript" src="js/date-picker.js"></script>
<script type="text/javascript">
function refreshConditionList(v, c) {
   visitId=v;
   var nlUrl = "ajax/refreshconditionlist.jsp?visitId="+visitId;

    $.ajax({
        url: nlUrl,
        success: function(data){
            $(patientconditionsbubble).html(data);
        },
        error: function() {
            alert("There was a problem processing the request");
        },
        complete: function() {
            refreshSymptomList(c,v);
        }
    });

}
</script>
<%
// Initialize local variables
    String ID               = request.getParameter("id");
    String patientId        = request.getParameter("patientid");
    String update           = request.getParameter("update");
    String parentUrl        = request.getParameter("parentUrl");
    String getHint          = request.getParameter("hint");
    String setCondition     = request.getParameter("set");
    String report           = request.getParameter("report");
    String miniPanel        = request.getParameter("mini");
    String visitId          = request.getParameter("visitId");
    String xrays            = request.getParameter("xrays");
    String postLocation     = "ajax/patientcondition.jsp";
    String parentLocation   = "CONDITION";
    
    // If the id in the request is null or an empty string make it 0 to indicate an add
    if(ID == null || ID.equals("")) {
        ID = request.getParameter("rcd");
        if(ID == null || ID.equals("")) { ID = "0"; }
    }

// If the member id is not passed make the member id 0
    if(patientId == null || patientId.equals("")) {
        patientId = "" + patient.getId();
    }
    
    if(update != null) { 
        if(postLocation.indexOf("?") >= 0) {
            postLocation += "&update=Y";
        } else {
            postLocation += "?update=Y";
        }
    }
    
    if(visitId != null) {
        Visit v = new Visit(io, visitId);
        patientId = "" + v.getPatientId();
        postLocation += "?visitId=" + visitId;
    }
    
    if(miniPanel != null) { 
        if(postLocation.indexOf("?") >= 0) {
            postLocation += "&mini=Y";
        } else {
            postLocation += "?mini=Y";
        }
    }

    PatientConditions patientConditions = new PatientConditions(io, ID);
    if(miniPanel != null && patientId.equals("0")) {
        patientId = "" + patientConditions.getPatientId();
    }
    
    if(xrays != null && xrays.equals("Y")) { 
        parentLocation = "XRAYS";
        patientId = "" + patient.getId();
        patientConditions.refreshObject = "xrayPatientCondition";
        if(postLocation.indexOf("?") >= 0) {
            postLocation += "&xrays=Y";
        } else {
            postLocation += "?xrays=Y";
        }
    }
    
    if(update == null || update.trim().equals("")) {
// Instantiate a comment
        
        patientConditions.setUpdateJSP(postLocation);

        if(getHint != null && getHint.equals("Y")) {
            // Show the hint
            out.print("<v:roundrect style='width: 450px; height: 300px; text-valign: middle; text-align: center;'>");
            out.print("<div align=\"right\"><b style=\"cursor: pointer;\" onClick=\"showHide(txtHint,'HIDE')\">close</b></div>");
            out.print(patientConditions.getConditionForHover(Integer.parseInt(ID)));
            out.print("</v:roundrect>");
        } else if(setCondition != null && setCondition.equals("Y")) {
            visit.setId(request.getParameter("visitId"));
            visit.setConditionId(Integer.parseInt(ID));
            visit.update();
            out.print(visit.getVisitCondition());
        } else if(report != null && report.equals("Y")) {
            out.print("<div style='width: 100%; height: 300px; text-valign: middle; text-align: center;'>");
            out.print(patientConditions.getConditionForHover(Integer.parseInt(ID)));
            out.print("</div>");
        } else {
            // Get an input item with the record ID to set the rcd and ID fields
            out.print("<v:roundrect style='width: 450; height: 270; text-valign: middle; text-align: center;'>");
            out.print(patientConditions.getInputForm(patientId));
//            out.print("<input type=hidden name=parentLocation id=parentLocation value='" + parentUrl + "'>");
            out.print("<input type=hidden name=\"parentLocation\" id=\"parentLocation\" value='" + parentLocation + "'>");
            out.print("<input type=hidden name=postLocation id=postLocation value='" + postLocation + "'>");
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
            patientConditions.setPatientId(""+patientId);
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
            
            io.setMySqlLastInsertId();
            int newConditionId = io.getLastInsertedRecord();
            
            if(visitId != null & ID.equals("0")) {
                Visit v = new Visit(io, visitId);
                v.setConditionId(newConditionId);
                v.update();
            } else {
                newConditionId = Integer.parseInt(ID);
            }
            patientConditions.setEditMode(true);
            if(miniPanel == null) {
                out.print(patientConditions.getCondition(newConditionId));
            } else {
                out.print(patientConditions.getDescription());
            }
        } else {
            patientConditions.delete();
            Visit v = new Visit(io, visitId);
            patientId = "" + v.getPatientId();
            patientConditions.setPatientId(patientId);
            v.setConditionId(patientConditions.getCurrentCondition(patientId));
            v.update();
            
            out.print(patientConditions.getCondition(v.getCurrentCondition()));
        }
        
    }
%>
