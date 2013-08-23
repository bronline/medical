<%-- 
    Document   : patientvitals
    Created on : Dec 8, 2011, 8:10:35 AM
    Author     : rwandell
--%>
<%@include file="template/pagetop.jsp" %>
<%@include file="ajax/ajaxstuff.jsp" %>
<script type="text/javascript">
    function submitForm(obj) {
        var dataString = $(obj).serialize();
        var postUrl = "ajax/updatepatientvitals.jsp?update=Y";

        $.ajax({
            type: "POST",
            url: postUrl,
            data: "&" + dataString,
            success: function(data) {

            },
            complete: function() {
                window.location.href="patientvitals.jsp";
            },
            error: function() {
                showHide(txtHint,"HIDE");
            }
        });
    }

    function cancelEdit() {
        showHide(txtHint,"HIDE");
    }

    function removeRecord() {
        var id=$('#id').val();

        $.ajax({
            type: "POST",
            url: "ajax/updatepatientvitals.jsp?delete=Y",
            data: "&id=" + id,
            success: function(data) {
                showHide(txtHint,"HIDE");
            },
            complete: function() {
                window.location.href="patientvitals.jsp";
            },
            error: function() {
                showHide(txtHint,"HIDE");
            }
        });
    }
</script>
<%
    if(patient.next()) {
        PatientVitals pv = new PatientVitals(io,0);

        pv.setPatientId(patient.getId());

        out.print("<table width=\"100%\" cellspacing=\"0\" cellpadding=\"0\" border=\"0\">\n");

        out.print("<tr>\n");
        out.print("<td align=\"left\" valign=\"top\">\n");
        out.print("<fieldset><legend align=\"center\" style=\"font-size: 12; font-weight: bold;\">Weight Loss Details</legend>");
        out.print("<div align=\"center\" id=\"completeList\">\n");
        pv.getVitalsEntries(out, "D", "365px");
        out.print("</div><br><br>\n");
        out.print("<div align=\"center\" style=\"width: 100%;\"><input type=\"button\" value=\"new entry\" onClick=\"showItemInFixedPos(event,'ajax/updatepatientvitals.jsp',0," + patient.getId() + ",txtHint,250,200)\" class=\"button\"></div>");
        out.print("</fieldset>");
        out.print("</td>\n");

        out.print("<td width=\"15px\">&nbsp;&nbsp;</td>\n");

        out.print("<td valign=\"top\">\n");
        out.print("<fieldset><legend align=\"center\" style=\"font-size: 12; font-weight: bold;\">Weekly Weight Loss Details</legend>");
        out.print("<div align=\"center\" id=\"weeklyList\">\n");
        pv.getVitalsEntries(out, "W", "140px");
        out.print("</div>\n");
        out.print("</fieldset>");
        out.print("<br>\n");

        out.print("<fieldset><legend align=\"center\" style=\"font-size: 12; font-weight: bold;\">Monthly Weight Loss Details</legend>");
        out.print("<div align=\"center\" id=\"monthlyList\">\n");
        pv.getVitalsEntries(out, "M", "75px");
        out.print("</div>\n");
        out.print("</fieldset>");
        out.print("<br>\n");

        out.print("<fieldset><legend align=\"center\" style=\"font-size: 12; font-weight: bold;\">Annual Weight Loss Details</legend>");
        out.print("<div align=\"center\" id=\"yearlyList\">\n");
        pv.getVitalsEntries(out, "Y", "50px");
        out.print("</div>\n");
        out.print("</fieldset>");
        out.print("</td>\n");

        out.print("</tr>\n");
        out.print("</table>\n");
    } else {
        out.print("Patient information not set");
    }
%>
<%@ include file="template/pagebottom.jsp" %>
