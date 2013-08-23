<%@ include file="globalvariables.jsp" %>
<%
    int patientId=0;
    String message="";
    int startVisit=1;
    ResultSet lRs=io.opnUpdatableRS("select * from patientmessages where startvisit<>0 order by patientid, message, date");

    while(lRs.next()) {
        if(patientId != lRs.getInt("patientid") || !message.equals(lRs.getString("message"))) {
            message=lRs.getString("message");
            patientId=lRs.getInt("patientid");
            startVisit=1;
        }
        lRs.updateInt("startvisit", startVisit);
        lRs.updateRow();
        startVisit ++;
    }

    lRs.close();
%>
