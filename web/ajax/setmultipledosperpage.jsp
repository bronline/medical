<%@include file="sessioninfo.jsp" %>
<%
    PreparedStatement lPs=io.getConnection().prepareStatement("update batches set allowmultipledos=? where id=?");
    lPs.setString(2, request.getParameter("id"));
    if(request.getParameter("allowMultipleDos").equals("true")) {
        lPs.setInt(1, 1);
    } else {
        lPs.setInt(1,0);
    }
    lPs.execute();
%>
<%@include file="cleanup.jsp" %>
