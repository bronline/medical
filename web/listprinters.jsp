<%@ page import="javax.print.*" %>
<%
PrintService[] services = PrintServiceLookup.lookupPrintServices(null, null);

for(int i=0; i<services.length; i++) { 
    out.println(services[i].getName() + "<br>");
}
%> 