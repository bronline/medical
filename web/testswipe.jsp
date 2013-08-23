<%@ include file="template/pagetop.jsp"%>

<%
    location.setId(2);
    out.print("<a href='swipeinlocation.jsp?cardnumber=11145' style='color: white;'>test</a>");

    	for(Enumeration e=request.getAttributeNames(); e.hasMoreElements();) {
		String param=(String)e.nextElement();
		out.print(param + ": " + request.getParameter(param) + "<br/>");
	}
%>

<%@ include file="template/pagebottom.jsp" %>
