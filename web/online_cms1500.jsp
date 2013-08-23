<%-- 
    Document   : online_cms1500
    Created on : Jan 13, 2009, 8:23:07 AM
    Author     : Randy Wandell
--%>
<%@ include file="globalvariables.jsp" %>
<%@ page import="java.io.*" %>
<style type="text/css">
    BODY { margin-top: 0; margin-left: .5; margin-right: 0; margin-bottom: 0; }
    p { page-break-after: always; }
    .cms1500Form { font-family: courier; font-size: 10px; }
</style>
<style type="text/css" media="print" rel="stylesheet">
    BODY { margin-top: 0; margin-left: .5; margin-right: 0; margin-bottom: 0; }
    p { page-break-after: always; }
    .cms1500Form { font-family: courier; font-size: 10px; }
    .noPrint { visibility: hidden; }
</style>
<body>
    <div class="noPrint">
        <input type="button" class="button" onClick="window.print()" style="cursor: pointer;" value="Send to Printer">
    </div>
<%
    String str=env.getString("documentpath")+ env.getString("billingmap")+"\\" + Format.formatDate(new java.util.Date(), "yyyyMMdd") + ".txt";
    try {
        FileReader fr = new FileReader(str);
        BufferedReader br=new BufferedReader(fr);
    
        out.print("<pre class=\"cms1500Form\">");
        while((str=br.readLine())!=null){
            out.println(str);
        }
        br.close();
        out.print("</pre>");
    } catch (Exception e) {
    }
%>
</body>