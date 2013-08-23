<%@ include file="template/pagetop.jsp" %>
<%@ include file="ajax/ajaxstuff.jsp" %>

<script language="javascript">
    function displayImage(image) {
        window.open('xrays_d.jsp?edit=Y&image=' + image,'Image','left=70,top=50width=600,height=700,scrollbars=no');
    }
</script>
<%
    out.print(patient.getXrays());

    session.setAttribute("parentLocation", "xrays.jsp");
%>

<%@ include file="template/pagebottom.jsp" %>