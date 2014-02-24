<%-- 
    Document   : writeoffunapplied
    Created on : Nov 22, 2013, 11:47:54 AM
    Author     : Randy
--%>
<%@include file="sessioninfo.jsp" %>

<%
    StringBuffer paymentList = new StringBuffer();
    String parm;
    for( Enumeration en = request.getParameterNames(); en.hasMoreElements(); ) {
        parm = ( String) en.nextElement();
        if(paymentList.length() > 0 && parm.contains("chk")) { paymentList.append(","); }
        if(parm.contains("chk")) { paymentList.append(parm.substring(3)); }
    }

    PreparedStatement paymentPs = io.getConnection().prepareStatement("update payments set amount=0 where id in (" + paymentList.toString() + ")");
    paymentPs.execute();
    out.print(paymentList.toString());
%>
