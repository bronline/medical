<%@include file="sessioninfo.jsp" %>
<%
    PreparedStatement lPs=io.getConnection().prepareStatement("update batches set issecondary=? where id=?");
    lPs.setString(2, request.getParameter("id"));
    if(request.getParameter("batchType").equals("PDF")) {
        lPs.setInt(1, 1);
    } else {
        lPs.setInt(1,0);
    }
    lPs.execute();
%>
<%@include file="cleanup.jsp" %>
