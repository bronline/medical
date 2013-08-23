<%@page import="medical.*, tools.*, java.sql.ResultSet, java.sql.PreparedStatement" %>
<link rel="stylesheet" type="text/css" href="css/stylesheet.css" title="stylesheet">
<script type="text/javascript" src="js/date-picker.js"></script>
<script type="text/javascript" src="js/CheckDate.js"></script>
<script type="text/javascript" src="js/CheckLength.js"></script>
<script type="text/javascript" src="js/colorpicker.js"></script>
<script type="text/javascript" src="js/datechecker.js"></script>
<script type="text/javascript" src="js/dFilter.js"></script>
<script type="text/javascript" src="js/currency.js"></script>
<script type="text/javascript" src="js/checkemailaddress.js"></script>
<script type="text/javascript" src="js/invertselection.js"></script>
<script type="text/javascript" src="js/setCheckBoxValue.js"></script>
<script type="text/javascript" src="ajax/visitactivity.js"></script>
<%@include file="ajax/autocomplete.jsp" %>

<!-- Declare the VML namespace -->
<xml:namespace ns="urn:schemas-microsoft-com:vml" prefix="v" />
<body topmargin="0" leftmargin="0" style="background: #000066;  background-image: url('/medicaldocs/bg_page.gif');">
<style>
    .noteType { font-size: 12px; }
    .smallPlan { font-size: 11px; font-weight: bold; color: #2c57a7; }
</style>
<body onkeypress="handler(event)" onLoad="visitId=<%=request.getParameter("visitId")%>" style="background-image: url('/medicaldocs/bg_page.gif');">

<%
    String databaseName=(String)session.getAttribute("databaseName");
    if(databaseName != null) {
        RWConnMgr io=new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);
        Patient patient=new Patient(io, "0");
        Visit visit=new Visit(io, "0");
        Environment env=new Environment(io);

        env.refresh();
        int visitId = 0;

        String visitIdStr = (String)session.getAttribute("visitId");
        String duplicate  = request.getParameter("duplicate");
        String undo       = request.getParameter("undo");

    // If a resource was sent use it
        String currentResource = request.getParameter("currentresource");

    // If not, check the session variable
        if (currentResource==null) {
            currentResource = (String)session.getAttribute("currentResource");
            if (currentResource == null && env.getDefaultResource()>0) {
                currentResource=""+env.getDefaultResource();
            }
        }

    // Set the session variable
        if (currentResource!=null) { session.setAttribute("currentResource", currentResource); }

    // Use the session variable for the resource
        currentResource = (String)session.getAttribute("currentResource");

        if (visitIdStr != null) {
            visitId = Integer.parseInt(visitIdStr);
        }

        if (request.getParameter("visitId")!=null) {
            visitId=Integer.parseInt(request.getParameter("visitId"));
            visit.setId(visitId);
            visit.checkForPatientCopay();
        }

        session.setAttribute("returnUrl", "visitactivity.jsp?visitId=" + visitId);
        session.setAttribute("parentLocation", "visitactivity.jsp?visitId=" + visitId);

        if ( visit.getId() == 0 )
        {
            out.print( "VISIT NOT SPECIFIED" );
        }
        else
        {
            if (!visit.next())
            {
                out.print("VISIT SPECIFIED DOES NOT EXIST");
            }
            else
            {

    // Always use the patient's resource if he has one
    //            if (currentResource==null) {
                    patient.setId(visit.getPatientId());
                    patient.beforeFirst();
                    if(patient.next()) {
                        if(patient.getInt("resourceid") != 0) {
                            currentResource=patient.getString("resourceId");
                            session.setAttribute("currentResource", currentResource);
                        }
    //                    } else {
    //                        response.sendRedirect("selectresource.jsp?visitId="+visit.getId());
    //                    }
                    }
                    if(currentResource==null) {
    //                    response.sendRedirect("selectresource.jsp?visitId="+visit.getId());
                    }

    //            }
                if(duplicate == null && undo == null) {
                    //create a new instance of the VisitActivity object
                    VisitActivity vActivity = new VisitActivity( io, visit, patient, visitId, "visitactivity.jsp" );
                    if (currentResource!=null) {
                        vActivity.setResourceId(Integer.parseInt(currentResource));
                    }
                    vActivity.setVisitFontSize(env.getString("visitfontsize"));
                    if (request.getParameter("noteId")!=null)
                    {
                        int noteId=Integer.parseInt(request.getParameter("noteId"));
                        vActivity.insertNote(request, io, noteId, visit, patient);
                        io.getConnection().close();
                        response.sendRedirect("visitactivity.jsp?visitId=" + visitId);
                        return;
                    }

                    if (request.getParameter("itemId")!=null)
                    {
                        int itemId=Integer.parseInt(request.getParameter("itemId"));
                        vActivity.insertCharge(request, io, itemId, visit, patient);
                        io.getConnection().close();
                        response.sendRedirect("visitactivity.jsp?visitId=" + visitId);
                        return;
                    } else {
                        out.print(vActivity.getHtml());
                        session.setAttribute("parentLocation", "visitactivity.jsp?visitId=" + visitId);
                    }

                    // 01-24-08 New functionality show instantmessages
                    if(env.getBoolean("showmessages")) {
                        Messages messages = new Messages(io);

                        messages.setPatientId(patient.getId());
                        messages.updateDisplayed(patient.getId());

                        ResultSet mRs = io.opnRS("select * from patientmessages where display and patientid=" + patient.getId() + " and date<=current_date and date(displayed)<>'0001-01-01' and date(complete)='0001-01-01'");
                        if(mRs.next()) { out.print("<script>window.open('showmessages.jsp','visitmessages','width=820,height=50');</script>"); }
                        mRs.close();
                    }
    //                out.print("<script>window.opener.refreshParentWindow()</script>");
                } else if(duplicate != null) {
                    visit.undoVisit(visitId);
                    visit.duplicateLastVisit(visitId);
                    PreparedStatement lPs=io.getConnection().prepareStatement("update charges set resourceid=" + currentResource + " where visitid=" + visitId);
                    lPs.executeUpdate();
                    io.getConnection().close();
                    response.sendRedirect("visitactivity.jsp?visitId=" + visitId);
                    return;
                } else if(undo != null) {
                    visit.undoVisit(visitId);
                    io.getConnection().close();
                    response.sendRedirect("visitactivity.jsp?visitId=" + visitId);
                    return;
                } 
            }
        }
    }
%>
<%@ include file="ajax/ajaxstuff.jsp" %>
