<%@ page import="java.util.Enumeration, java.util.ArrayList" %>
<%
    ArrayList patients=(ArrayList)session.getAttribute("patientList");
    String currentPatient=(String)session.getAttribute("currentPatient");
    String providerId=(String)session.getAttribute("providerId");
    String patientId=(String)session.getAttribute("patientId");
    String checkNumber=(String)session.getAttribute("checkNumber");
    String checkAmount=(String)session.getAttribute("checkAmount");
    String startDate=(String)session.getAttribute("startDate");
    String endDate=(String)session.getAttribute("endDate");

    if(patients == null) {
        patients=new ArrayList();
        for(Enumeration e=request.getParameterNames(); e.hasMoreElements();) {
            String var=(String)e.nextElement();
            if(var.substring(0,3).equals("chk")) { patients.add(var.substring(3)); }
        }
    }

    if(providerId == null) { providerId=request.getParameter("providerId"); }
    if(patientId == null) { patientId=request.getParameter("patientId"); }
    if(checkNumber == null) { checkNumber=request.getParameter("checkNumber"); }
    if(checkAmount == null) { checkAmount=request.getParameter("checkAmount"); }
    if(startDate == null) { startDate=request.getParameter("startDate"); }
    if(endDate == null) { endDate=request.getParameter("endDate"); }

    if(patients.size()>0) {
        session.setAttribute("patientList", patients);
        int y=-1;
        for(int x=0; x<patients.size(); x++) {
            if(currentPatient == null) {
                currentPatient=(String)patients.get(x);
                y=x;
                break;
            } else {
                if(currentPatient.equals((String)patients.get(x))) {
                    if(x+1<patients.size()) {
                        currentPatient=(String)patients.get(x+1);
                        y=x+1;
                        break;
                    }
                }
            }
        }
        if(y != -1) {
            session.setAttribute("currentPatient", currentPatient);
//            session.setAttribute("myParent", "applymultiplepayments.jsp");
            session.setAttribute("providerId", providerId);
            session.setAttribute("patientId", patientId);
            session.setAttribute("checkNumber", checkNumber);
            session.setAttribute("checkAmount", checkAmount);
            session.setAttribute("multiplePayments", "Y");
            response.sendRedirect("applypayments.jsp?patientId=" + currentPatient + "&providerId=" + providerId + "&checkNumber=" + checkNumber + "&checkAmount=" + checkAmount );
        } else {
            session.removeAttribute("currentPatient");
            session.removeAttribute("patientList");
            session.removeAttribute("providerId");
            session.removeAttribute("patientId");
            session.removeAttribute("checkNumber");
            session.removeAttribute("checkAmount");
            session.removeAttribute("multiplePayments");
            session.removeAttribute("currentPatient");

            response.sendRedirect("paymentwizard.jsp?providerId=" + providerId);
        }
    }
%>