<%-- 
    Document   : cleanup
    Created on : Jul 14, 2010, 10:14:19 AM
    Author     : rwandell
--%>
<%
    patient = null;
    visit = null;
    location = null;
    
    io.getConnection().close();

    System.gc();
%>