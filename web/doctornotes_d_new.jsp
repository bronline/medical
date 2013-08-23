<%@ include file="globalvariables.jsp" %>
<%
    if (request.getParameter("update")!=null) {

        String delete = request.getParameter("delete");
        String parentLocation = (String)session.getAttribute("parentLocation");

    // Set up work variables to process the request parameters
        String returnUrl = (String)session.getAttribute("returnUrl");
        String name;

    // Set up work variables that will be used to populate each of the payments
        int id=0;
        java.util.Date noteDate=null;
        Calendar noteDateCal=Calendar.getInstance();
        String note = "";
        int visitId = 0;
        int patientId = patient.getId();

        if (request.getParameter("rcd")!=null) {id = Integer.parseInt(request.getParameter("rcd")); }
        if (request.getParameter("notedate")!=null) {noteDate = new java.util.Date(request.getParameter("notedate")); }
        if (request.getParameter("note")!=null) {note = request.getParameter("note"); }

        noteDateCal.setTime(noteDate);
        
        DoctorNote thisDoctorNote = new DoctorNote(io, ""+id);
        if (!thisDoctorNote.next()) {
            thisDoctorNote.setPatientId(patientId);
            thisDoctorNote.setVisitId(visitId);
        }

        if (delete!=null && delete.equalsIgnoreCase("Y")) {
            thisDoctorNote.delete();
        } else {
            thisDoctorNote.setNote(note);
            thisDoctorNote.setNoteDate(noteDateCal);
            thisDoctorNote.update(); 
        } 

    } else {
    // Initialize local variables
        String ID               = request.getParameter("id");
        String patientId        = request.getParameter("patientid");
        String duplicate        = request.getParameter("duplicate");
        String noteText         = "";

    // If the id in the request is null or an empty string make it 0 to indicate an add
        if(ID == null || ID.equals("")) {
            ID = "0";
        }

    // If the patient id is not passed make the patient id 0
        if(patientId == null || patientId.equals("")) {
            patientId = "0";
        }

    // If the patient id is 0, try the id from the active patient
        if(patientId.equals("0")) {
            patientId = "" + patient.getId();
        }

    // Instantiate a Doctor Note
        DoctorNote note = new DoctorNote(io, ID);
        if (ID.equals("0")) {
            note.setVisitId(visit.getId());
        }

        if (duplicate != null && duplicate.equals("Y")) {
            ResultSet noteRs=io.opnRS("select * from doctornotes where patientid=" + patientId + " order by notedate desc limit 1");
            if(noteRs.next()) { noteText=noteRs.getString("note"); }
            noteRs.close();
            noteRs = null;
        }

    // Now list buttons
        StringBuffer items   = new StringBuffer();
        RWHtmlTable htmTb = new RWHtmlTable("100%", "0");
        htmTb.replaceNewLineChar(false);
        ResultSet lRs = io.opnRS("select id, buttontext, buttoncolor, buttontextcolor, notetext from notetemplates where showitem order by sequence desc");
        RWHtmlForm frm = new RWHtmlForm();

        htmTb.setWidth("70");

//        items.append(htmTb.startTable());

//        items.append(htmTb.startRow());
//        items.append(htmTb.addCell("SOAP", "align=center class=pageHeading"));
//        items.append(htmTb.endRow());
//        items.append(htmTb.endTable());

        items.append("<div style=\"width: 100; height: 340; overflow: auto;\">");
        items.append(htmTb.startTable());
        while (lRs.next()) {
            items.append(htmTb.startRow());
            items.append(htmTb.addCell(frm.button(lRs.getString("buttontext"), "style=\"font-size: 10px; background: " 
                + lRs.getString("buttoncolor") + "    ; color:" + lRs.getString("buttontextcolor") 
                + "; width: 80px; font-family: arial; \" onClick=getNoteText(" + lRs.getString("id") + ");frmInput.note.select()")));
            items.append(htmTb.endRow());
        }
        items.append("</div>");
        items.append(htmTb.endTable());

    // Get an input item with the record ID to set the rcd and ID fields
        out.print("<v:roundrect style='width: 800; height: 400; text-valign: middle; text-align: center;' arcsize='.05' >");
        out.print("<div align=\"right\"><b onClick=\"showHide(txtHint,'HIDE')\" style=\"cursor: pointer;\">close</b></div>");
        out.print("<table><tr>");
        out.print("<td valign=top>" + note.getAjaxInputForm(patientId, true) + "</td>");
        out.print("<td valign=\"top\">" + items.toString() + "</td>");
        out.print("</tr></table>");
        
        out.print("<input type=hidden name=parentLocation id=parentLocation value='VISITNOTE'>");
        out.print("<input type=hidden name=postLocation id=postLocation value='doctornotes_d_new.jsp'>");
        out.print("<input type=hidden name=fileName id=fileName value='doctornotes'>");
        out.print("<input type=hidden name=update id=update value='Y'>");
        out.print("<input type=hidden name=patientid id=patientid value='" + patientId + "'>");

    // This will return to the return point set in the calling program
        session.setAttribute("returnUrl", "");
        out.print("</v:roundrect>");
    }
%>
