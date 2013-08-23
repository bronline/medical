<%-- 
    Document   : post.jsp
    Created on : Oct 31, 2008, 9:00:27 AM
    Author     : Randy Wandell
--%>
<%@ page import="java.util.Enumeration" %>
<%
for(Enumeration e=request.getParameterNames();e.hasMoreElements();) {
    String param=(String)e.nextElement();
    out.print(param + ": " + request.getParameter(param) + "<br>");
}
%>