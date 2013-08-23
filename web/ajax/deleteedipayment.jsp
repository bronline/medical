<%--
    Document   : deleteedipayment
    Created on : Sep 7, 2012    Author     : Randy
--%>
<%@include file="sessioninfo.jsp" %>
<script type="text/javascript">

</script>
<%
    String id=request.getParameter("id");

    PreparedStatement ediPs;
    if(request.getParameter("exceptionRecord") == null || request.getParameter("exceptionRecord").equals("0")) {
        ediPs = io.getConnection().prepareStatement("update edipayments set processed=1 where id=" + id);
    } else {
        ediPs = io.getConnection().prepareStatement("update ediexceptions set processed=1 where id=" + id);
    }
    ediPs.execute();

%>
<%@include file="cleanup.jsp" %>