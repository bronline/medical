<%-- 
    Document   : gethint.jsp
    Created on : Sep 10, 2008, 10:18:43 AM
    Author     : Randy Wandell
--%>
<%@ include file="globalvariables.jsp" %>
<table width="500" border="0" cellSpacing="0" cellPadding="0">
<tr style="height: 5px">

  <td colspan=3>
    <div id=>
      <b style="display :block; ">
        <b style="margin: 0 5px; display: block; height: 1px; overflow: hidden; background: #cccccc"></b>
        <b style="margin: 0 3px; display: block; height: 1px; overflow: hidden; background: #cccccc"></b>
        <b style="margin: 0 2px; display: block; height: 1px; overflow: hidden; background: #cccccc"></b>
        <b style="margin: 0 1px; display: block; height: 2px; overflow: hidden; background: #cccccc"></b>
      </b>
    </div>

  </td>
</tr>
 <tr bgColor=#cccccc>
  <td align=left valign=top width="3px"> </td>
  <td align=center width=300>
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

// Instantiate a comment
    PatientConditions patientConditions = new PatientConditions(io, ID);

// Get an input item with the record ID to set the rcd and ID fields
    out.print(patientConditions.getInputForm(patientId));

// This will return to the return point set in the calling program
    session.setAttribute("returnUrl", "");
%>
  </td>
  <td align=left valign=top width="3px"> </td>
<tr style="height: 5px">
  <td colspan=3>
    <div id=>
      <b style="display :block; ">

        <b style="margin: 0 1px; display: block; height: 2px; overflow: hidden; background: #cccccc"></b>
        <b style="margin: 0 2px; display: block; height: 1px; overflow: hidden; background: #cccccc"></b>
        <b style="margin: 0 3px; display: block; height: 1px; overflow: hidden; background: #cccccc"></b>
        <b style="margin: 0 5px; display: block; height: 1px; overflow: hidden; background: #cccccc"></b>
      </b>
    </div>
  </td>
</tr>
</table>
