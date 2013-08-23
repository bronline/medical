<%@include file="globalvariables.jsp" %>

<title>Item</title>
<script language="JavaScript" src="js/CheckDate.js"></script>
<script language="JavaScript" src="js/CheckLength.js"></script>

<script language="javascript">
  function submitForm(action) {
    var frmA=document.forms["frmInput"]
    frmA.method="POST"
    frmA.action=action
    frmA.submit()
  }  
</script>

<%
// Initialize local variables
    String myQuery          = "select * from patientdocuments ";
    String id               = request.getParameter("id");

// If the id in the request is null or an empty string make it 0 to indicate an add
    if(id == null || id.equals("")) {
        id = "0";
    } else {
        myQuery += "where id=" + id;
    }

// Create a result set of the data for the form
    ResultSet lRs = io.opnRS(myQuery);

    lRs.next();

    String fileUrl=env.getBrowserPath() + "/" + lRs.getString("documentpath").substring(lRs.getString("documentpath").lastIndexOf(databaseName + "\\")+databaseName.length()+1); 
    if(env.getBoolean("editdocuments")) { fileUrl=env.getString("editdocumentpath") + "/" + lRs.getString("documentpath").substring(lRs.getString("documentpath").lastIndexOf(databaseName + "\\")+databaseName.length()+1); }
    
    out.println("<form name=frmInput method=post action=patientdocuments_update.jsp>");
    out.println("  <table width=600>");
    out.println("    <tr>");
    out.println("      <td><b>Document Description<b></td><td><textarea name=description id=description cols=\"60\" rows=\"3\" class=tAreaText>" + lRs.getString("description") + "</textarea></td>");
    out.println("    </tr>");
    out.println("    <tr>");
    out.println("      <td><b>Path To File<b></td><td><a href=\"" + fileUrl + "\">" + fileUrl + "</a></td>");
    out.println("    </tr>");
    out.println("  </table>");
    out.println("<input type=hidden name=rcd value="+ lRs.getString("id")+ ">");
    out.println("<input type=BUTTON name=btnSubmit value=\"  save  \" class=button onClick=submitForm('updaterecord.jsp?fileName=patientdocuments')>&nbsp;&nbsp;");
    out.println("<input type=BUTTON name=btnDelete value=\"remove\" class=button onClick=submitForm('patientdocuments_delete.jsp')>");
    out.println("</form>");

    session.setAttribute("returnUrl", "");
%>
