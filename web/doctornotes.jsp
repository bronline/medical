<%@include file="template/pagetop.jsp" %>
<script>
function printNotes() {
  noteForm.submit();
}
</script>
<%
try {
// Set up the SQL statement
    if(patient.next()) {
        visit.setId(0);
        String myQuery     = "select id , " +
                                "notedate, " + 
                                "concat('<input type=checkbox name=chk', id, '>') as fld," +
                                "note from doctornotes where patientid = " + patient.getId() + " order by notedate desc";
        String url         = "doctornotes_d.jsp";
        String title       = "Doctor Notes";

    // Create an RWFiltered List object
        RWFilteredList lst = new RWFilteredList(io);
        RWHtmlTable htmTb  = new RWHtmlTable("700", "0");
        RWHtmlForm frm     = new RWHtmlForm();
        RWFieldSet fldSet  = new RWFieldSet();
        RWInputForm noteForm=new RWInputForm(io.opnRS("select id, notetype from patients where id=" + patient.getId()));

    // Set special attributes on the filtered list object
        lst.setTableWidth("700");
        lst.setTableBorder("0");
        lst.setCellPadding("3");
        lst.setAlternatingRowColors("#ffffff", "#cccccc");
        lst.setRoundedHeadings("#030089", "");
    //    lst.setTableHeading(title);
        // Set specific column widths
        String [] cellWidths = {"0", "80", "20", "600"};
        String [] cellHeadings = { "", "Date", "Print" };
        lst.setColumnWidth(cellWidths);
        lst.setUrlField(0);
        lst.setNumberOfColumnsForUrl(2);
        lst.setRowUrl(url);
        lst.setShowRowUrl(true);
        lst.setOnClickAction("window.open");
        lst.setOnClickOption("\"DoctorNotes\",\"width=850,height=470,scrollbars=no,left=100,top=100,\"");
        lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
        lst.setShowComboBoxes(false);
        lst.setUseCatalog(true);
        lst.setDivHeight(250);

        htmTb.replaceNewLineChar(false);

        out.print(patient.getIndicators());

    // Show bubble for patient note type
//        out.print(htmTb.getFrame("#cccccc", getNoteTypeForm(noteForm, htmTb)));
        out.print(InfoBubble.getBubble("roundrect", "noteTypeBubble","725","50","#cccccc", getNoteTypeForm(noteForm, htmTb)));

    // Show the filtered list
        out.print("<form name=noteForm action=printsoapnotes.jsp target=_blank method=post>\n");
        out.print(fldSet.getFieldSet(lst.getHtml(myQuery, cellHeadings), "style='width: " + lst.getTableWidth() +"'",  title + " for " + patient.getPatientName(), "style='font-size: 12; font-weight: bold;' align=center"));
        out.print("</form>");

        out.print(frm.startForm());
        out.print(frm.button("New " + title, "class=button onClick=window.open(\"" + url + "?id=0\",\"Locations\",\"width=850,height=470,scrollbars=no,left=100,top=100,\");" ));
        out.print(frm.button("Print selected notes ", "class=button onClick=printNotes()" ));
        out.print("<input type=button value='invert selection' onClick=invertSelection() class=button>");

        out.print(frm.endForm());
    } else {
        out.print("Patient information not set");
    }

    session.setAttribute("returnUrl", "doctornotes.jsp");
    session.setAttribute("parentLocation", self);

} catch (Exception e) {
    out.print(e);
}
%>
<%! public String getNoteTypeForm(RWInputForm noteForm, RWHtmlTable htmTb) throws Exception {
    StringBuffer form=new StringBuffer();
    noteForm.setTableWidth("700");
    noteForm.setTableBorder("0");
    noteForm.setAction("updaterecord.jsp?fileName=patients");
    noteForm.setMethod("POST");
    noteForm.lRcd.beforeFirst();

    if(noteForm.lRs.next()) {
        form.append(noteForm.startForm());
        form.append(noteForm.hidden(noteForm.lRs.getString("id"), "rcd"));
        form.append(htmTb.startTable());
        form.append(htmTb.startRow());
        form.append(htmTb.addCell("Note Type: "));
        form.append(noteForm.getInputItemOnly("notetype", "class=tBoxText"));
        form.append(htmTb.addCell(noteForm.submitButton("update", "class=button")));
        form.append(htmTb.endTable());
        form.append(noteForm.endForm());
    }
    return form.toString();
    }
%>
<%@ include file="template/pagebottom.jsp" %>