<%-- 
    Document   : soapitementry
    Created on : Oct 3, 2009, 9:29:06 PM
    Author     : Randy
--%>
<%@ include file="globalvariables.jsp" %>

<script language="javascript">
  function submitForm(action) {
    var frmA=document.forms["frmInput"]
    frmA.method="POST"
    frmA.action=action
    frmA.submit()
  }  
  
  function updateRecord() {
      frmInput.action="soapitementry.jsp?update=Y";
      frmInput.submit();
  }
</script>

<%
// Initialize local variables
    String myQuery          = "select id, soapitemid, description, answertype from patientsoapitems ";
    String soapItemId       = request.getParameter("soapItemId");
    String id               = request.getParameter("id");
    RWHtmlTable htmTb       = new RWHtmlTable("800","0");
    
// If the id in the request is null or an empty string make it 0 to indicate an add
    if(request.getParameter("soapItem") != null) {
        id = "0";
    }
    
    if(request.getParameter("update") == null) {
        myQuery += "where id=" + id;

        String [] si = { "soapitemid","soapitem" };
        String [] sv = { soapItemId, id  };

        out.print("<v:roundrect style='width: 500; height: 65; text-valign: middle; text-align: center;' arcsize='.05' fillcolor='#3399bb'>");
        out.print("<div align=\"right\" style=\"font-weight: bold; cursor: pointer;\" onClick=\"showHide(txtHint,'HIDE')\">close</div>");

    // Create a result set of the data for the form
        ResultSet lRs = io.opnRS(myQuery);
        if(lRs.next()) { soapItemId=lRs.getString("soapitemid"); lRs.beforeFirst(); }
        RWInputForm form = new RWInputForm(lRs);

        out.print("<form>");
        out.print(htmTb.startTable());
        out.print(form.getInputItem("description"));
        out.print(form.getInputItem("answertype"));
        out.print(htmTb.endTable());

    // Get an input item with the record id to set the rcd and id fields
        out.print("<input type=hidden name=parentLocation id=parentLocation value='soapentry.jsp'>");
        out.print("<input type=hidden name=postLocation id=postLocation value='soapitementry.jsp'>");
        out.print("<input type=hidden name=fileName id=fileName value='patientsoapitems'>");
        out.print("<input type=hidden name=update id=update value='Y'>");
        out.print("<input type=hidden name=patientid id=patientid value='" + patient.getId() + "'>");
        out.print("<input type=hidden name=soapItemId id=soapItemId value='" + soapItemId + "'>");
        out.print("<input type=hidden name=\"id\" id=\"id\" value='" + id + "'>");

//        out.print("<input type=\"button\" value=\"save\" onClick=\"javascript:get(this.parentNode,'SAVE');\" class=\"button\">");
//        out.print("<input type=\"button\" value=\"remove\" onClick=\"javascript:get(this.parentNode,'DELETE');\" class=\"button\">");
        out.print("<input type=\"button\" value=\"save\" onClick=\"javascript:processForm(this.parentNode,'SAVE',null);\" class=\"button\">");
        out.print("<input type=\"button\" value=\"remove\" onClick=\"javascript:processForm(this.parentNode,'DELETE',null);\" class=\"button\">");

        out.print("</form>");
        out.print("</v:roundrect>");
    } else {
        if(request.getParameter("delete") != null) {
            PreparedStatement lPs=io.getConnection().prepareStatement("delete from patientsoapitems where id=" + id);
            lPs.execute();
        } else {
            if(id.equals("0")) {
                PreparedStatement lPs=io.getConnection().prepareStatement("insert into patientsoapitems (patientid, soapitemid, description, answertype) values (?,?,?,?)");
                lPs.setInt(1, patient.getId());
                lPs.setString(2, soapItemId);
                lPs.setString(3, request.getParameter("description"));
                lPs.setString(4, request.getParameter("answertype"));
                lPs.execute();
            } else {
                PreparedStatement lPs=io.getConnection().prepareStatement("update patientsoapitems set description=?, answertype=? where id=?");
                lPs.setString(1, request.getParameter("description"));
                lPs.setString(2, request.getParameter("answertype"));
                lPs.setString(3, id);
                lPs.execute();

            }
        }
    }

    session.setAttribute("returnUrl", "");    
%>