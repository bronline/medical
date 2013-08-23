<%-- 
    Document   : deletevisit
    Created on : Mar 2, 2009, 7:30:41 PM
    Author     : Randy
--%>
<%@ include file="globalvariables.jsp" %>
<SCRIPT language=JavaScript>
    function win(parent,errorMessage){
        if(parent != null && parent != 'None') { 
            if(errorMessage !='') {
                alert(errorMessage);
            } else {
                window.opener.location.href=parent;
            }
        }
        self.close();
    }
</SCRIPT>
<%
    String visitId=request.getParameter("visitId");
    
    if(visitId != null && !visitId.equals("0")) {
        visit.setId(visitId);
        String errorMessage=visit.deleteVisit();
        if(errorMessage.equals("")) {
            out.print("<script type='text/javascript'>win('visits.jsp','');</script>");    
        } else {
            out.print("<script type='text/javascript'>win('visits.jsp','"+errorMessage+"');</script>");    
        }
    }
    
%>
