<%@ include file="template/pagetop.jsp" %>
<%@ include file="ajax/ajaxstuff.jsp" %>

<script language="javascript">
    function displayImage(image) {
        window.open('xrays_d.jsp?edit=Y&image=' + image,'Image','left=70,top=50width=600,height=700,scrollbars=no');
    }
    
    function refreshSymptomList(conditionId) {
       var slUrl = "ajax/refreshsymptomlist.jsp?conditionId="+conditionId;

        $.ajax({
            url: slUrl,
            success: function(data){
                $("#patient-symptoms-bubble").html(data);
            },
            error: function() {
                alert("There was a problem processing the request");
            }
        });
    }    
</script>
<%
    out.print(patient.getXrays());

    session.setAttribute("parentLocation", "xrays.jsp");
%>

<%@ include file="template/pagebottom.jsp" %>