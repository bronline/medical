<%@ include file="template/pagetop.jsp"%>
<script type="text/javascript">
  function setFocus() {
    document.frmInput.cardnumber.focus();
    countdown();
  }

  var timer = 300;
  function countdown() {
    if(timer > 0) {
      document.frmInput.countdown.value = timer;
      timer -= 1;
      setTimeout("countdown()",1000);
    } else {
      location.href="swipeinlocation.jsp";
    }
  }

function handler(e) {
    if (document.all) {
        e = window.event;
    }

    var key;

    if (document.layers){
        key = e.which;
    }else{
        key = e.keyCode
    }

    // 87 is the capital w
    if(key==87){
        window.open('whoshere.jsp','WaitingList','width=400,height=200');
        e.keyCode=0;
    }
}
</script>
<body onkeypress="handler()">
    <%
    String cardNumber      = request.getParameter("cardnumber");
    String patientId       = request.getParameter("patientId");
    String displayMessage  = (String)session.getAttribute("displayMessage");
    String locationId      = request.getParameter("locationId");
    String showWaitingList = request.getParameter("showWaitingList");
    RWHtmlTable htmTb      = new RWHtmlTable("975", "0");
    RWHtmlForm frm         = new RWHtmlForm("frmInput", "swipeinlocation.jsp", "POST");

    if (cardNumber!=null) {
        cardNumber = cardNumber.replaceAll("%","");
        cardNumber = cardNumber.replaceAll("\\$","");
        cardNumber = cardNumber.replaceAll("\\?","");
    }

    if(displayMessage != null) {
        session.setAttribute("displayMessage", null);
        if(patient.next()) {
            if(location.getUrl() != null && !location.getUrl().equals("")) {
                response.sendRedirect(location.getUrl());
            } else {
                out.print("<body onload=setTimeout(\"location.href='swipeinlocation.jsp'\",5000)> ");
                htmTb.setCellVAlign("MIDDLE");
                out.print(htmTb.startTable());
                out.print(htmTb.startRow("height=400"));
                out.print(htmTb.startCell(htmTb.CENTER));

                htmTb.setCellVAlign("TOP");
                out.print(htmTb.startTable("100%"));
                out.print(htmTb.startRow());
                out.print(htmTb.addCell("Welcome " + patient.getPatientName(), htmTb.CENTER, "style=\"background: none; color: #ffffff; font-size: 16px; font-weight: bold;\""));
                out.print(htmTb.endRow());
                out.print(htmTb.endTable());

                out.print(htmTb.endCell());
                out.print(htmTb.endRow());
                out.print(htmTb.endTable());
                out.print("</body>");
            }
        } else {
            out.print("<body onload=setTimeout(\"location.href='swipeinlocation.jsp'\",5000)> ");
            htmTb.setCellVAlign("MIDDLE");
            out.print(htmTb.startTable());
            out.print(htmTb.startRow("height=400"));
            out.print(htmTb.startCell(htmTb.CENTER));

            htmTb.setCellVAlign("TOP");
            out.print(htmTb.startTable("100%"));
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("Patient Information Not Found", htmTb.CENTER, "style=\"background: none; color: #ffffff; font-size: 20px; font-weight:bold;\""));
            out.print(htmTb.endRow());
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("", htmTb.CENTER, "style=\"background: none; color: #ffffff; font-size: 14px;\""));
            out.print(htmTb.endRow());
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("Please See the Front Desk", htmTb.CENTER, "style=\"background: none; color: #ffffff; font-size: 20px; font-weight: bold;\""));
            out.print(htmTb.endRow());
            out.print(htmTb.endTable());

            out.print(htmTb.endCell());
            out.print(htmTb.endRow());
            out.print(htmTb.endTable());

            out.print("</body>");
        }
    } else if(srchString != null && !srchString.equals("*EMPTY")) {
        patient.getSearchResults(srchString, "swipeinlocation.jsp", "patientId");
        if(patient.getId() == 0) {
            out.print(patient.getSearchResults(srchString, "swipeinlocation.jsp", "patientId"));
        } else {
            if(patient.next()) {
                patient.findVisitInfo(visit, location.getId());
                cardNumber=patient.getString("cardnumber");
            }

            session.setAttribute("displayMessage", "Y");
            response.sendRedirect("swipeinlocation.jsp?cardnumber=" + cardNumber);
        }
    } else if(patientId != null && !patientId.equals("")) {
        patient.setId(patientId);

        if(patient.next()) {
            patient.findVisitInfo(visit, location.getId());
            cardNumber=patient.getString("cardnumber");
        }

        session.setAttribute("displayMessage", "Y");
        response.sendRedirect("swipeinlocation.jsp?cardnumber=" + cardNumber);

    } else if(cardNumber != null && !cardNumber.equals("") ) {
        // RKW - 12-15-09 findCardNumber throwing an error
        try {
            // First try to find the patient by the card number
            patient.findCardNumber(cardNumber);
            if(patient.next()) {
                patient.findVisitInfo(visit, location.getId());
            } else {
                // Now check to see if a temporary card is being used
                if(patientHasTempCard(io, patient, cardNumber));
                patient.findVisitInfo(visit, location.getId());
            }

            session.setAttribute("displayMessage", "Y");
            response.sendRedirect("swipeinlocation.jsp?cardnumber=" + cardNumber);
        } catch (Exception e) {
            response.sendRedirect("swipeinlocation.jsp");
        }

    } else {
        if(locationId != null) { session.setAttribute("locationId", locationId); }
        String loc=(String)session.getAttribute("locationId");
        out.print(getInputForm(io, htmTb, frm, patient, location.getSearchBubble(), loc));

        if(locationId != null) {
            location.setId(locationId);
            session.setAttribute("locationReturnPoint", location.getReturnUrl());
            response.sendRedirect("swipeinlocation.jsp");
        } else {
            session.setAttribute("locationReturnPoint", location.getReturnUrl());
        }

    }
%>
<%! public String getInputForm(RWConnMgr io, RWHtmlTable htmTb, RWHtmlForm frm, Patient patient, boolean searchBubble, String locationId) throws Exception {
    StringBuffer sf = new StringBuffer();
    String locationMessage="";

    ResultSet msgRs=io.opnRS("select `message` from locations where id=" + locationId);
    if(msgRs.next()) { locationMessage=msgRs.getString("message"); }
    msgRs.close();

    sf.append("<body onLoad=\"setFocus()\">");
    sf.append(frm.startForm());

    htmTb.setCellVAlign("MIDDLE");
    sf.append(htmTb.startTable());
    sf.append(htmTb.startRow("height=400"));
    sf.append(htmTb.startCell(htmTb.CENTER));

    htmTb.setCellVAlign("TOP");
    sf.append(htmTb.startTable());

    if(searchBubble) {
        htmTb.replaceNewLineChar(false);
        sf.append(htmTb.startRow("style='height: 70px;'"));
        sf.append(htmTb.addCell(locationMessage, htmTb.CENTER,"style='color:white; font-weight: bold; font-size: 16px;'"));
        sf.append(htmTb.endRow());
        sf.append(htmTb.addCell("Enter patient name or partial name", htmTb.CENTER, "style='color:white; font-size: 12px;'"));
        sf.append(htmTb.endRow());
        sf.append(htmTb.startRow());
        sf.append(htmTb.addCell(patient.getSearchBubble("swipeinlocation.jsp"), htmTb.CENTER));
        sf.append(htmTb.endRow());
    } else {
        sf.append(htmTb.startRow("style='height: 70px;'"));
        sf.append(htmTb.addCell(locationMessage, htmTb.CENTER,"style='color:white; font-weight: bold; font-size: 16px;'"));
        sf.append(htmTb.endRow());
        sf.append(htmTb.startRow());
        sf.append(htmTb.addCell(frm.password("", "cardnumber", "class=tBoxText") + " " + frm.submitButton("go", "class=button"), htmTb.CENTER));
        sf.append(htmTb.endRow());
        sf.append(htmTb.startRow());
        sf.append(htmTb.addCell("swipe card or enter card number", htmTb.CENTER, "style=\"color: white; font-size: 12px; \""));
        sf.append(htmTb.endRow());
    }

    sf.append(htmTb.endTable());

    sf.append(htmTb.endCell());
    sf.append(htmTb.endRow());
    sf.append(htmTb.endTable());

    sf.append(frm.hidden("", "countdown"));
    sf.append(frm.hidden(locationId, "locationId"));
    sf.append(frm.endForm());
    sf.append("</body>");

    return sf.toString();
}

    public boolean patientHasTempCard(RWConnMgr io, Patient patient, String cardNumber) throws Exception {
        boolean tempCard=false;

        ResultSet tmpCard=io.opnRS("select * from temporarycards where cardnumber=" + cardNumber);
        if(tmpCard.next()) {
            tempCard=true;
            patient.setId(tmpCard.getInt("patientid"));
        }
        tmpCard.close();

        return tempCard;
    }
%>

<%@ include file="template/pagebottom.jsp" %>
