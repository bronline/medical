<%@ include file="globalvariables.jsp" %>
<%@ page import="java.io.BufferedWriter, java.io.FileWriter" %>

<%
    String targetFile  = "";
    String targetDir   = "";
    String id          = request.getParameter("id");

    if(patient.next()) {
        patient.beforeFirst();
        String myQuery = "select * from documenttemplates where id=" + id;

        ResultSet dRs = io.opnRS(myQuery);
        if(dRs.next()) {

            String templateName          = dRs.getString("pathtotemplate");
            int type                     = dRs.getInt("type");
            int identifier               = dRs.getInt("identifier");
            String description           = dRs.getString("description");
            int patientId                = patient.getId();
            targetFile                   = env.getDocumentPath();
            targetDir                    = env.getBrowserPath();

            int x = templateName.lastIndexOf("\\");
            templateName = templateName.substring(x + 1);
            String documentName = Format.formatDate(new java.util.Date(), "yyyyMMdd") + "-" + templateName;

            out.println("<H1>Create New Document Using Template: \"" + description + "\"</H1>");
            out.println("<form action=patientdocuments_create.jsp>");
            out.println("  <table>");
            out.println("    <tr>");
            out.println("    <td>Document Name</td><td><input size=80 class=tboxtext type=text name=documentname value='" + documentName + "'</td>");            
            out.println("    </tr>");
            out.println("    <tr>");
            out.println("    <td>Document Description</td><td><input size=80 type=text class=tboxtext name=documentdescription value='" + documentName + "'</td>");            
            out.println("    </tr>");
            out.println("  </table>");
            out.println("<br><br>");
            out.print("<input type=hidden name=id value='" + id + "'>");
            out.print("<input type=button onClick=self.close() value='cancel' class=button>&nbsp;");
            out.print("<input type=submit value='create' class=button>&nbsp;");
            out.println("</form>");
        }
    }


%>

