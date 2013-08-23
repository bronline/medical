<%@ include file="globalvariables.jsp" %>
<%@ page import="com.rwtools.tools.utils.*" %>
<script>
    function win(parent){
        if(parent != null) { window.opener.location.href=parent }
        self.close();
    }    
</script>
<%
    String imageId = request.getParameter("image");
    String docPath = "";
    String imagePath = "";
    String imageToRotate = "";

    if(imageId != null) {
        Document doc = new Document(io, imageId);
        docPath = doc.getDocumentPath();
        if(!docPath.equals("")) {
            Image90Rotator.rotate90DX(docPath);
            out.print("<body onLoad=win('xrays.jsp')></body>");
        }
    } else {
        out.print("Invalid Image Id specified");
    }
%>