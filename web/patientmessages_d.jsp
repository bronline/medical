<%@ include file="globalvariables.jsp" %>

<script>
    function messageTypes(what) {
        msgType = what.options[what.selectedIndex].text
        location.href='patientmessages_d.jsp?messageType=' + msgType
    }
    
    function submitForm(formOption) {
        var frmA = document.forms['frmInput']
        frmA.action='patientmessages_d.jsp?option=' + formOption;
        frmA.method="POST";
        frmA.submit();
    }
    
    function checkNumTimes(what) {
        var num=what.value
    }

    function win(where){
        window.opener.location.href=where;
        self.close();
    }
</script>

<%
    Messages messages   = (Messages)session.getAttribute("messages");
    String messageId    = request.getParameter("id");
    String messageType  = request.getParameter("messageType");
    String option       = request.getParameter("option");
    String saveBtnText  = " save ";
    String saveOption   = "s";

    String parentLocation = (String)session.getAttribute("parentLocation");

    if(messages == null) { messages = new Messages(io); }

    if(messageId == null) { messageId = "" + messages.getId(); }

    messages.setId(Integer.parseInt(messageId));
    messages.beforeFirst();

    session.setAttribute("messages", messages);

    RWInputForm frm     = new RWInputForm(messages);
    RWHtmlTable htmTb   = new RWHtmlTable("400", "0");

    htmTb.replaceNewLineChar(false);
    frm.setUseExternalForm(true);
    out.print(frm.startForm());

    if(messageId.equals("0") && messageType == null && option == null) {
        String [] preLoad = {"", "Single Message", "Repeating Message", "Special Message" };
        out.print(htmTb.startTable());
        out.print(htmTb.startRow());
        out.print(htmTb.addCell("<b>Message Type</b>"));
        out.print(htmTb.addCell(frm.comboBox("messageType", "", false, "1", preLoad, "", "class=cBoxText onChange=messageTypes(this)")));
        out.print(htmTb.endRow());
        out.print(htmTb.endTable());
    } else if(messageType != null && messageType.equals("Single Message")) {
        out.print(htmTb.startTable());
        out.print(frm.getInputItem("date"));
        out.print(frm.getInputItem("message"));
        out.print(frm.getInputItem("amount"));
        out.print(htmTb.endTable());
        out.print(frm.hidden("", "frequency"));
        out.print(frm.hidden("1", "numTimes"));
    } else if(messageType != null && messageType.equals("Repeating Message")) {
        String [] preLoad = { "Months", "Weeks" };
        out.print(htmTb.startTable());
        out.print(htmTb.startRow());
        out.print(htmTb.addCell("<b>Frequency</b>"));
        out.print(htmTb.addCell(frm.comboBox("frequency", "", false, "1", preLoad, "Months", "class=cBoxText")));
        out.print(htmTb.endRow());
        out.print(htmTb.startRow());
        out.print(htmTb.addCell("<b>Number of Times</b>"));
        out.print(htmTb.addCell(frm.textBox("1", "numTimes", "4", "4", "class=tBoxText onBlur=checkNumTimes(this)")));
        out.print(htmTb.endRow());
        out.print(frm.getInputItem("date"));
        out.print(frm.getInputItem("message"));
        out.print(frm.getInputItem("amount"));
        out.print(htmTb.endTable());
    } else if(messageType != null && messageType.equals("Special Message")) {
        out.print(htmTb.startTable());
        out.print(frm.getInputItem("message"));
        out.print(frm.getInputItem("onvisit"));
        out.print(frm.getInputItem("startvisit"));
        out.print(frm.getInputItem("atvisit"));
        out.print(htmTb.endTable());
        out.print(frm.hidden("", "frequency"));
        out.print(frm.hidden("1", "numTimes"));
    } else if(!messageId.equals("0") && option == null) {
        saveOption = "u";
        out.print(htmTb.startTable());
        if(!messages.getDate().equals("0001-01-01")) { out.print(frm.getInputItem("date")); }
        out.print(frm.getInputItem("message"));
        if(!messages.getDate().equals("0001-01-01")) {
            out.print(frm.getInputItem("amount"));
        } else {
            out.print(frm.getInputItem("onvisit"));
            out.print(frm.getInputItem("startvisit"));
            out.print(frm.getInputItem("atvisit"));
        }
        out.print(htmTb.endTable());
    } else if(option.equals("s") || option.equals("u")) {
        messages.setPatientId(patient.getId());
        messages.setDate(request.getParameter("date"));
        messages.setFrequency(request.getParameter("frequency"));
        messages.setNumberOfTimes(request.getParameter("numTimes"));
        messages.setMessage(request.getParameter("message"));
        messages.setAmount(request.getParameter("amount"));
        messages.setOnVisit(request.getParameter("onvisit"));
        messages.setStartVisit(request.getParameter("startvisit"));
        messages.setAtVisit(request.getParameter("atvisit"));
        if(option.equals("s")) { messages.generateMessages(); }
        if(option.equals("u")) { messages.update(); }
    } else if(option.equals("r")) {
        messages.deleteRow();
    }

    if(option == null) {
        if(messageId.equals("0")) { saveBtnText = " add "; }

        if(messageType != null || !messageId.equals("0")) { out.print(frm.button(saveBtnText, "class=button onClick=submitForm('" + saveOption + "')", "saveBtn")); }
        if(!messageId.equals("0")) { out.print(frm.button(" remove ", "class=button onClick=submitForm('r')", "removeBtn")); }

        out.print(frm.endForm());
    } else { %>
        <body onLoad="win('<%= parentLocation %>')">
        <body>    
<%    } %>