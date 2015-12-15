<%-- 
    Document   : selectpaperbill
    Created on : Feb 7, 2013, 11:06:31 AM
    Author     : Randy
--%>
<%--
    Document   : billsecondary
    Created on : Aug 30, 2011, 9:09:59 AM
    Author     : Randy Wandell
--%>

<%@include file="sessioninfo.jsp" %>
<script type="text/javascript">
function printTypeSelected() {
    printTypeSelectForm.submit();
}
</script>
<%
    ArrayList elem = new ArrayList();
    String patientId = request.getParameter("patientId");
    String var = "";

    out.print("<h2>Select batch print type</h2>");
    out.print("<form name=\"printTypeSelectForm\" action=\"printpatientbills.jsp?patientId=" + patientId + "\" method=post>\n");
    out.print("<input type=\"radio\" name=\"batchPrintType\" id=\"batchPrintType\" value=\"1\">Electronic<br/>");
    out.print("<input type=\"radio\" name=\"batchPrintType\" id=\"batchPrintType\" value=\"2\">Paper Bill<br/>");
    out.print("<br/>");
    out.print("Resubmission Code (Box 22): <input type=\"text\" name=\"box22\" id=\"box22\" class=\"tBoxText\" value=\"\">");
    out.print("<input type=\"hidden\" name=\"patientId\" id=\"patientId\" value=\"" + patientId + "\">");
    for(Enumeration e = request.getParameterNames(); e.hasMoreElements();) {
        var=(String)e.nextElement();
        if(var.substring(0,3).equals("chk")) {
            out.print("<input type=\"hidden\" name=\"" + var + "\" id=\"" + var + "\" value=\"true\">");
        }
    }
    out.print("<br/><br/>");
    out.print("</form>");
    out.print("<input type=\"button\" class=\"button\" value=\"print\" onClick=\"printTypeSelected()\">");


%>



