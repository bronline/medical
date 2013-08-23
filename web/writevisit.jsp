<script type="text/javascript">
    function refreshParentWindow() {
        window.location.href='visits.jsp';
        return false;
    }
</script>
<%@page import="medical.*, tools.utils.Format, tools.*, java.sql.PreparedStatement" %>
<%
    String databaseName=(String)session.getAttribute("databaseName");
    if(databaseName != null) {

        String patientId=request.getParameter("patientId");

        RWConnMgr io=new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);

        Patient patient = new Patient(io, patientId);
        Visit visit = new Visit(io, "0");        

        if(patient.next()) {
            patient.findVisitInfo(visit, 0);
        }

//        java.sql.ResultSet lRs=io.opnRS("select id from visits where patientid=" + patient.getId() + " AND `date`=CURRENT_DATE");
//        if(lRs.next()) {
//            out.print("<script>window.open('visitactivity.jsp?visitId=" + lRs.getInt("id") + "','VisitActivity','width=1000,height=750,resizable=yes,scrollbars=no,status=no,left=0,top=0');</script>");
//        } else {
            PatientConditions patientConditions=new PatientConditions(io,0);
            PreparedStatement newVisitPs=io.getConnection().prepareStatement("INSERT INTO visits (appointmentid, patientid, date, locationid, conditionid) VALUES(?, ?, ?, ?, ?)");
            newVisitPs.setInt(1, 0);
            newVisitPs.setString(2, patientId);
            newVisitPs.setString(3, Format.formatDate(new java.util.Date(), "yyyy-MM-dd"));
            newVisitPs.setInt(4, 0);
            newVisitPs.setInt(5, patientConditions.getCurrentCondition(patientId));
            newVisitPs.execute();

            io.setMySqlLastInsertId();

            out.print("<script>window.open('visitactivity.jsp?visitId=" + io.getLastInsertedRecord() + "','VisitActivity','width=1000,height=750,resizable=yes,scrollbars=no,status=no,left=0,top=0');</script>");
//        }
//        lRs.close();
        io.getConnection().close();
        System.gc();

//        response.sendRedirect("visits.jsp");
        out.print("<script>location.href='visits.jsp'</script>");
    }
%>
