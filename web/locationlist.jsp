<%@ include file="template/pagetop.jsp" %>

<%
    String id="";
    session.setAttribute("returnUrl", "locationlist.jsp");
    if (request.getParameterNames().hasMoreElements()) 
    {
        id = request.getParameter( "id" );
        session.setAttribute("locationId", id);
        response.sendRedirect(self);
    } 
    else 
    {
    
        id = (String)session.getAttribute("locationId");

        LocationOccupancy lOccup = new LocationOccupancy(io, self, id);

        out.print( lOccup.getHtml() );
    }
%>

<%@ include file="template/pagebottom.jsp" %>
