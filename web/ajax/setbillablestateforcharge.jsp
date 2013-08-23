<%-- 
    Document   : setbillablestateforcharge
    Created on : Aug 16, 2013, 9:47:57 AM
    Author     : Randy
--%>
<%@include file="sessioninfo.jsp" %>
<%
    String chargeId = request.getParameter("chargeId");
    String providerId = request.getParameter("providerId");

    PreparedStatement chgPs = io.getConnection().prepareStatement("update charges set billinsurance=? where id=?");
    ResultSet chgRs = io.opnRS("select * from charges where id=" + chargeId);
    if(chgRs.next()) {
        int billable = chgRs.getInt("billinsurance");
        if(chgRs.getInt("billinsurance") == 2 || chgRs.getInt("billinsurance") == 0) {
            billable = 1;
        } else {
            billable = 2;
        }
        chgPs.setInt(1, billable);
        chgPs.setString(2, chargeId);

        chgPs.execute();
    }
%>
<%@include file="cleanup.jsp" %>
