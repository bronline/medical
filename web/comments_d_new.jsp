<%@ include file="globalvariables.jsp" %>
<title>Comments</title>

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
    RWHtmlForm frm          = new RWHtmlForm("frmInput", "comments_d_new.jsp?update=Y", "POST");
    String ID               = request.getParameter("id");
    String patientId        = request.getParameter("patientid");
    String visitId          = request.getParameter("visitid");
    String appointmentId    = request.getParameter("appointmentid");
    String commentDate      = request.getParameter("date");
    String commentType      = request.getParameter("type");
    String parentLocation   = (String)session.getAttribute("parentLocation");
    String parentUrl        = request.getParameter("parentUrl");
    String update           = request.getParameter("update");
    
// If the id in the request is null or an empty string make it 0 to indicate an add
    if(ID == null || ID.equals("")) {
        ID = request.getParameter("commentId");
        if(ID == null || ID.equals("")) { ID = "0"; }
    }

// If the patient id is not passed make the patient id 0
    if(patientId == null || patientId.equals("")) {
        patientId = "0";
    }

// If the visit id is not passed make the visit id 0
    if(visitId == null || visitId.equals("")) {
        visitId = "0";
    }
    
// If the date is not passed make the date an empty string
    if(commentDate == null) {
        commentDate = "";
    }
    
// If the type id is not passed make the type id 0
    if(commentType == null || commentType.equals("") || request.getParameter("commenttype") != null) {
        commentType = request.getParameter("commenttype");
    }

    Comment comment = new Comment(io, ID);

    if(update == null || update.trim().equals("")) {
    // Instantiate a comment

        if(commentDate != null && !commentDate.equals("")) {
            comment.setDate(commentDate);
            comment.setType(commentType);
        }

    // Get an input item with the record ID to set the rcd and ID fields
        StringBuffer sy=new StringBuffer();
        sy.append("<v:roundrect style='width: 500; height: 225; text-valign: middle; text-align: center;' arcsize='.05' fillcolor='#3399bb'>");
        sy.append("<form name=\"frmInput\" id=\"frmInput\">\n");
        sy.append(comment.getAjaxInputForm(patientId, visitId));

        if(commentType != null) { parentUrl="None"; }
//        sy.append("<input type=hidden name=parentLocation id=parentLocation value='" + parentUrl + "'>");
        sy.append("<input type=hidden name=parentLocation id=parentLocation value='NONE'>");
        sy.append("<input type=hidden name=postLocation id=postLocation value='comments_d_new.jsp'>");
        sy.append("<input type=hidden name=fileName id=fileName value='comments'>");
        sy.append("<input type=hidden name=commenttype id=commenttype value='" + commentType + "'>");
        sy.append("<input type=hidden name=update id=update value='Y'>");
        sy.append("<input type=hidden name=commentId id=commentId value=" + ID + ">");
        sy.append("<input type=hidden name=patientid id=patientid value='" + patientId + "'>");
        sy.append("<input type=hidden name=refreshObject id=refreshObject value='#patient_comments'>");
        sy.append("</form>\n");
        sy.append("</v:roundrect>");

        out.print(sy.toString());
    } else {
        if(request.getParameter("delete") == null || !request.getParameter("delete").equals("Y")) {
            comment.setId(ID);
            comment.setPatientId(patientId);
            comment.setType(commentType);
            comment.setComment(request.getParameter("comment"));
            comment.setDate(Format.formatDate(commentDate, "yyyy-MM-dd"));
            comment.setAppointmentId(appointmentId);
            comment.update();
        } else {
            comment.delete();
        }

        Comments comments = new Comments(io);

        out.print(comments.getPatientComments(patientId));
    }
    
// This will return to the return point set in the calling program
    session.setAttribute("returnUrl", "");
%>
