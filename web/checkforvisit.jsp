<%@page import="medical.*, tools.*" %>
<%
    String databaseName=(String)session.getAttribute("databaseName");
    if(databaseName != null) {

//        String patientId=request.getParameter("patientId");
        String responseLocation="swipeinlocation.jsp";

        RWConnMgr io=new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);

        Patient patient1 = (Patient)session.getAttribute("patient");
        Patient patient = new Patient(io, patient1.getId());
        Visit visit = new Visit(io, "0");        

        patient.beforeFirst();
        if(patient.next()) {
            patient.findVisitInfo(visit, 0);
        }

        java.sql.ResultSet lRs=io.opnRS("select max(id) as id from visits where patientid=" + patient.getId());
        if(lRs.next()) {
            responseLocation="visitactivity.jsp?visitId=" + lRs.getInt("id");
        }
        lRs.close();
        io.getConnection().close();
        System.gc();

//        response.sendRedirect("visits.jsp");
        out.print("<script>location.href='" + responseLocation + "'</script>");
    }
%>