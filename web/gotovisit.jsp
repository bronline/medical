<%@page import="medical.*, tools.*" %>
<%
    String databaseName=(String)session.getAttribute("databaseName");
    String blanks       = "                    ";

    if(databaseName != null) {
        RWConnMgr io=new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);
        Patient patient=new Patient(io, "0");
        Visit visit=new Visit(io, "0");

        int apptId=0;
        if(request.getParameter("apptId") != null) {
           apptId=Integer.parseInt(request.getParameter("apptId"));
        }
        Appointment appt=new Appointment(io, apptId);
        appt.next();
        patient.setId(appt.getInt("patientid"));
        patient.findVisitInfo(visit, 0, apptId);
        visit.beforeFirst();
        visit.next();

        int visitId=visit.getInt("id");

        io.getConnection().close();
        System.gc();

        AppointmentPage thisPage = (AppointmentPage)session.getAttribute("appointmentpage");
        if(thisPage != null) {
            try {
                thisPage.setPatient(patient);
                thisPage.setAppointmentId(0);
                session.setAttribute("appointmentpage", thisPage);
            } catch (Exception bbbbb) {
                System.out.println(databaseName + blanks.substring(databaseName.length()) + " : " + new java.util.Date() + " - " + request.getRemoteAddr() + " - Problem setting appointment page class (patientId: " + patient.getId() + ")");

            }
        }

        session.setAttribute("patient", patient);
        response.sendRedirect("visitactivity.jsp?&visitId="+visitId);
    }
%>
