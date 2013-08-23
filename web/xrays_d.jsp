<%@ include file="globalvariables.jsp" %>
<%@ page import="com.rwtools.tools.utils.*" %>

<title>Update X-Ray Information</title>

<script language="javascript">
    function deleteDocument(id) {
        var isSure = confirm('Are you sure you want to delete this x-ray image?');
        if (isSure==true) {
          var frmA=document.forms["frmInput"]
          frmA.action = 'xrays_d.jsp?image=' + id + '&delete=Y';
          frmA.submit();
        }  
    }

    function rotateImage(id) {
        var frmA=document.forms["frmInput"]
        frmA.action = 'xrays_d.jsp?image=' + id + '&rotate=Y&edit=Y';
        frmA.submit();  
    }

    function win(parent){
        if(parent != null) { window.opener.location.href=parent }
        self.close();
    }    
</script>
<%
    response.setHeader("Cache-Control","no-cache"); //HTTP 1.1
    response.setHeader("Pragma","no-cache"); //HTTP 1.0
    response.setDateHeader ("Expires", 0); //prevents caching at the proxy server

   String imageId = request.getParameter("image");
   String update  = request.getParameter("update");
   String edit    = request.getParameter("edit");
   String delete  = request.getParameter("delete");
   String rotate  = request.getParameter("rotate");
   String docPath = "";
   String imagePath = "";
   
   if(imageId != null) {
       Document doc = new Document(io, imageId);
       if(update == null && delete == null) {
            RWHtmlTable htmTb = new RWHtmlTable("800", "0");
            RWHtmlForm frm = new RWHtmlForm("frmInput", "xrays_d.jsp?image=" + imageId + "&update=Y", "POST");
            docPath = doc.getDocumentPath();
            
            if(!docPath.equals("")) {
                imagePath        = docPath.replaceAll("\\\\", "/");
                if(imagePath.substring(0,2).equals("//") || imagePath.substring(0,2).toUpperCase().equals("C:")) { 
                    imagePath=imagePath.substring(imagePath.indexOf("/medical"));
                }
                if(imagePath.indexOf("/medical/") > -1  && imagePath.indexOf("/medicaldocs/") == -1) { imagePath = "/medicaldocs" + imagePath.substring(imagePath.lastIndexOf("/medical/") + "/medical".length()); }
            }

            out.print("<image src='" + imagePath + "' height=600>\n");
            if(edit != null) {
               out.print(frm.startForm());
               out.print(htmTb.startTable());
               out.print(htmTb.startRow());
               out.print(htmTb.addCell("<b>Description"));
               out.print(htmTb.addCell(frm.textBox(doc.getDocumentDescription(),"description", "50", "50","class=tBoxText")));
               out.print(htmTb.endRow());
               out.print(htmTb.startRow());
               out.print(htmTb.addCell("<b>Sequence"));
               out.print(htmTb.addCell(frm.textBox(""+doc.getSequence(),"seq", "4", "4","class=tBoxText onBlur=\"return checkban(this)\"")));
               out.print(htmTb.endRow());
               out.print(htmTb.endTable());

               out.print(frm.submitButton("save", "class=button") + "&nbsp;&nbsp;&nbsp;" );
               out.print(frm.button("delete", "class=button onClick=deleteDocument('" + doc.getDocumentId() + "')") + "&nbsp;&nbsp;&nbsp;" );
               //out.print(frm.button("rotate 90 degrees", "class=button onClick=rotateImage('" + doc.getDocumentId() + "')"));
               out.print("<input type=checkbox name=rotate>Rotate");
               out.print(frm.endForm());
            }
       } else if(update !=  null) {
           String description = request.getParameter("description");
           int seq = Integer.parseInt(request.getParameter("seq"));

           if(description == null) { description = ""; }

           ResultSet docRs = io.opnUpdatableRS("select * from patientdocuments where id=" + imageId);
           if(docRs.next()) {
               docRs.updateString("description", description);
               docRs.updateInt("seq", seq);
               docRs.updateRow();
           }
           docRs.close();
           if (rotate!=null) {
               System.out.println(doc.getDocumentPath());
               Image90Rotator.rotate90DX(doc.getDocumentPath());
           }
           out.print("<body onLoad=win('xrays.jsp')></body>");

       } else if(delete != null) {
           ResultSet docRs = io.opnUpdatableRS("select * from patientdocuments where id=" + imageId);
           if(docRs.next()) {
               docRs.deleteRow();
           }
           docRs.close();
           doc.synchFiles();
           out.print("<body onLoad=win('xrays.jsp')></body>");
       }
   }
%>