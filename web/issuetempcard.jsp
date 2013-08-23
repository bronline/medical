<%@ include file="globalvariables.jsp" %>

<%

    RWHtmlTable htmTb=new RWHtmlTable("100%","0");
    RWHtmlForm frm=new RWHtmlForm("frmInput", "issuetempcard.jsp","POST");
    String newCard=request.getParameter("newCard");
    String reason=request.getParameter("reason");
    
    if (newCard!=null) {
        newCard = newCard.replaceAll("%","");
        newCard = newCard.replaceAll("\\$","");
        newCard = newCard.replaceAll("\\?","");
    }
    
    if(patient.next()) {
        if((newCard == null || newCard.equals("")) || (reason != null)) {
            if(newCard == null) { newCard=""; }
            if(reason != null && reason.equals("U")) { reason="Card is in use by another patient"; }
            else { reason=""; }
            out.print(frm.startForm());
            out.print(htmTb.startTable());
            out.print(htmTb.startRow());
            out.print(htmTb.headingCell("Issue Temporary Card"));
            out.print(htmTb.endRow());
            out.print(htmTb.startRow());
            out.print(htmTb.addCell(patient.getString("firstname").trim() + " " + patient.getString("lastname")));
            out.print(htmTb.endRow());
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("Current Card #: " + patient.getString("cardnumber")));
            out.print(htmTb.endRow());
            out.print(htmTb.startRow());
            out.print(htmTb.addCell(""));
            out.print(htmTb.endRow());
            out.print(htmTb.startRow());
            out.print(htmTb.addCell(reason, "style='color: red;'"));
            out.print(htmTb.endRow());
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("Temp Card #: " + frm.textBox(newCard, "newCard", "class=tBoxText") + " " + frm.submitButton("ok", "class=button")));
            out.print(htmTb.endRow());
            out.print(htmTb.endTable());
            out.print(frm.endForm());

            out.print("<script>frmInput.newCard.focus();</script>");
        } else {
            if(!checkCardNumber(io, newCard)) {
                out.print("<script>location.href='issuetempcard.jsp?newCard=" + newCard + "&reason=U'</script>");
            } else {
//                out.print("goodcardnumber");
                assignTempCard(io, patient, newCard);
                out.print(htmTb.startTable());
                out.print(htmTb.startRow());
                out.print(htmTb.addCell("Card number " + newCard + " assigned", htmTb.CENTER));
                out.print(htmTb.endRow());
                out.print(htmTb.endTable());
            }
        }
    } else {
        out.print(htmTb.startTable());
        out.print(htmTb.startRow());
        out.print(htmTb.headingCell("Patient not selected"));
        out.print(htmTb.endRow());
        out.print(htmTb.endTable());
    }

%>
<%! public boolean checkCardNumber(RWConnMgr io, String newCard) throws Exception {
        boolean goodCardNumber=true;

        ResultSet lRs=io.opnRS("select * from patients where cardnumber=" + newCard);
        if(lRs.next()) { goodCardNumber=false; }
        lRs.close();

        return goodCardNumber;
    }

    public void assignTempCard(RWConnMgr io, Patient patient, String newCard) throws Exception {
        ResultSet tmpCard=io.opnUpdatableRS("select * from temporarycards where cardnumber=" + newCard);
        if(tmpCard.next()) {
            tmpCard.updateInt("patientid", patient.getId());
            tmpCard.updateRow();
        } else {
            tmpCard.moveToInsertRow();
            tmpCard.updateInt("patientid", patient.getId());
            tmpCard.updateString("cardnumber", newCard);
            tmpCard.insertRow();
        }
        tmpCard.close();
    }
%>