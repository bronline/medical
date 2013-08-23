<%-- 
    Document   : report_collections
    Created on : Apr 3, 2012, 9:54:03 AM
    Author     : rwandell
--%>
<%@include file="template/pagetop.jsp" %>
<script type="text/javascript">
    function printReport(startDate,endDate) {
        window.open("print_report_collections.jsp?startDate="+startDate+"&endDate="+endDate+"&printReport=Y","print","scrollbars=yes,resizable");
    }

    function showPaymentDetails(what,patientId) {
        var rowId=what.id.substr(4);

        if(what.innerHTML == "[-]") {
            $('#rowId'+rowId).css('visibility','hidden');
            $('#rowId'+rowId).css('display','none');
            $('#plus'+rowId).html('[+]');
        } else {
            var url = "ajax/getpatientpayments.jsp?patientId="+patientId+"&startDate="+$('#startDate').val()+"&endDate="+$('#endDate').val();
            $('#plus'+rowId).html('[-]');

            $.ajax({
                type: "POST",
                url: url,
                success: function(data) {
                    $('#rowId'+rowId).html(data);
                },
                complete: function(data) {
                    $('#rowId'+rowId).css('visibility','visible');
                    $('#rowId'+rowId).css('display','');
                }

            });
        }
    }
</script>
<%@include file="payment_collections.jsp" %>
<%
    if(!printReport) { out.print("<div align=\"center\" style=\"width: 100%; float: left;\"><input type=\"button\" value=\"print\" class=\"button\" onClick=\"printReport('"+Format.formatDate(startDate,"yyyy-MM-dd")+"','"+Format.formatDate(endDate,"yyyy-MM-dd")+"')\"></div>"); }

%>
<%@include file="template/pagebottom.jsp" %>