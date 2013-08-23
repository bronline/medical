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
    String ID               = request.getParameter("id");
    String patientId        = request.getParameter("patientid");
    String visitId          = request.getParameter("visitid");
    String commentDate      = request.getParameter("date");
    String commentType      = request.getParameter("type");

// If the id in the request is null or an empty string make it 0 to indicate an add
    if(ID == null || ID.equals("")) {
        ID = "0";
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
    if(commentType == null || commentType.equals("")) {
        commentType = "0";
    }
    
// Instantiate a comment
    Comment comment = new Comment(io, ID);
    
    if(commentDate != null && !commentDate.equals("")) {
        comment.setDate(commentDate);
        comment.setType(Integer.parseInt(commentType));
    }

// Get an input item with the record ID to set the rcd and ID fields
    out.print(comment.getInputForm(patientId, visitId));

// This will return to the return point set in the calling program
    session.setAttribute("returnUrl", "");
%>
