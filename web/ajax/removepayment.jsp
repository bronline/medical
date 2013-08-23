<%-- 
    Document   : removepayment
    Created on : Aug 23, 2012, 12:07:18 PM
    Author     : Randy
--%>
<%@include file="sessioninfo.jsp" %>
<%
    String id = request.getParameter("id");

    PreparedStatement childPaymentPs = io.getConnection().prepareStatement("delete from payments where parentpayment=" + id);
    PreparedStatement paymentPs = io.getConnection().prepareStatement("delete from payments where id=" + id);

    childPaymentPs.execute();
    paymentPs.execute();

%>
<%@include file="cleanup.jsp" %>