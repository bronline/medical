<%@ include file="../../template/pagetop.jsp" %>
<body OnLoad="document.frm1.patientid.focus()";> 
<%
    RWHtmlTable tb = new RWHtmlTable();
    RWHtmlForm frm = new RWHtmlForm();
    frm.setMethod("POST");
    frm.setAction("welcome.jsp");
    tb.setBorder("0");
    tb.setWidth("100%");

    out.print(tb.startTable());
    out.print(frm.startForm());

    out.print(tb.startRow());
    out.print(tb.addCell("<br><br><br>Swipe Card or Enter Id", 2));
    out.print(tb.endRow());

    out.print(tb.startRow());
    out.print(tb.addCell("<input type=PASSWORD name=patientid>", 2));
    out.print(tb.endRow());
    
//    out.print(tb.startRow());
//    out.print(tb.addCell("<input name=date><a href=\"javascript:show_calendar('frm1.date',0,'2003');\" onmouseover=\"window.status='Select Date';return true;\" onmouseout=\"window.status='';return true;\"><img src=\"images/show-calendar.gif\" border=0></a>", 2));
//    out.print(tb.endRow());

    out.print(tb.startRow());
    out.print(tb.addCell("<input type=\"submit\" name=\"goButton\" VALUE=\"go\">", 2));
    out.print(tb.endRow());

    out.print(tb.endRow());

    out.print(frm.endForm());
 
    out.print(tb.endTable());

%>

<%@ include file="../../template/pagebottom.jsp" %>
