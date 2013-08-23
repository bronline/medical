

<%@include file="globalvariables.jsp" %>
<SCRIPT language=JavaScript>
<!-- 
function win(parent){
if(parent != null) { window.opener.location.href=parent }
self.close();
//-->
}
</SCRIPT>
<%
// ---------------------------------------------------------------------------------------------------------- //
// Initialize Variables ------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------------------- //

    String parentLocation = (String)session.getAttribute("parentLocation");
    String returnUrl = (String)session.getAttribute("returnUrl");
    int rcd = 0;

    if(patient.getId() != 0) {
        int patientId=patient.getId();

// ---------------------------------------------------------------------------------------------------------- //
// Receive parameters --------------------------------------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------------------- //

        if(request.getParameter("rcd") != null) {
            String recordNumber = request.getParameter("id");
            rcd = Integer.parseInt(recordNumber);
        }

// ---------------------------------------------------------------------------------------------------------- //
// Copy the highest year to the highest year plus one ------------------------------------------------------- //
// ---------------------------------------------------------------------------------------------------------- //
        Connection lCn = io.getConnection();
        ResultSet lRs = io.opnRS("select * from paymentschedule where patientid=" + patientId);
        if (lRs.next()) {
            String stm =    "insert into paymentschedule " +
                            "SELECT null, p.patientid, p.year+1, DATE_ADD(p.startdate, INTERVAL 1 year), p.plannedvisits, p.visitscovered, " +
                            "p.visitsused, p.visitstoinsurance, p.deductible, p.insurancepervisit, " +
                            "p.patientportionwhilecovered, p.patientportionafterexpires, p.discountpct, " +
                            "p.createmessages FROM paymentschedule p where patientid=" + patientId + " and " +
                            "year = (select max(year) from paymentschedule where patientid=" + patientId + ")";

            PreparedStatement lPs = lCn.prepareStatement(stm);
            lPs.executeUpdate();
        } else {
            Calendar thisCalendar = Calendar.getInstance();
            String currentYear = "" + thisCalendar.get(Calendar.YEAR);
            String stm =    "insert into paymentschedule " +
                           "(patientid, year, startdate) values(" + patientId + ", " + currentYear + ", '" + currentYear + "-01-01')";

            PreparedStatement lPs = lCn.prepareStatement(stm);
            lPs.executeUpdate();
        }
    }
    response.sendRedirect(returnUrl);

    %>
