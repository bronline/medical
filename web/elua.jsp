<%@ include file="globalvariables.jsp" %>
<title>ChiroPractice - End User License Agreement</title>
<script>
    function submitForm() {
        location.href='elua.jsp?update=Y';
    }
</script>
<%
    String userAccepts=request.getParameter("update");

    if(userAccepts == null) {
        ResultSet lRs=io.opnRS("select * from elua");

        RWHtmlTable htmTb = new RWHtmlTable("500", "0");
        RWHtmlForm frm = new RWHtmlForm();
        if(lRs.next()) {
            out.print("<div style='height:400; width:521; overflow:auto;'>\n");
            out.print(htmTb.startTable());
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("<pre style='font-family: tahoma;'>"+lRs.getString("agreement")+"</pre>"));
            out.print(htmTb.endRow());
            out.print(htmTb.endTable());
            out.print("</div>\n");
            out.print(frm.button("I Agree", "class=button onClick=submitForm()"));
        }
        lRs.close();
    } else {
        ResultSet lRs=io.opnUpdatableRS("select * from environment");
        if(lRs.next()) {
            lRs.updateBoolean("eluadisplayed", true);
            lRs.updateRow();
        }
        lRs.close();
        response.sendRedirect("index.jsp");
    }
%>