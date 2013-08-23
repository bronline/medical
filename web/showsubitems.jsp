<%@include file="globalvariables.jsp" %>

<TITLE>SubItems</TITLE>
<script language="JavaScript" src="js/CheckDate.js"></script>
<script language="JavaScript" src="js/CheckLength.js"></script>
<script language="JavaScript" src="js/datechecker.js"></script>

<script language="javascript">
  function submitForm(action) {
    var frmA=document.forms["frmInput"]
    frmA.method="POST"
    frmA.action=action
    frmA.submit()
  }  
  function enableParentButtons() {
    var buttons = opener.document.getElementsByTagName("input"); 
    for (var i=0; i < buttons.length; i++) { 
        if (buttons[i].getAttribute("type") == "button" || buttons[i].getAttribute("type") == "submit") { 
            buttons[i].disabled = false; 
        } 
    } 
  }  
</script>
<body onload=enableParentButtons()></body>
<%
// Initialize local variables
    String myQuery          = "select id, subitem from subitems ";
    String id               = request.getParameter("subitemtypeid");
    String itemId           = request.getParameter("itemId");
    String noteId           = request.getParameter("noteId");
    String visitId          = request.getParameter("visitId");
    String cellContents     = "";
    String pageHeader       = request.getParameter("pageHeader");

    if (pageHeader==null) {pageHeader="SubItems";}
    
// If the id in the request is null or an empty string make it 0 to indicate an add
    if(id == null || id.equals("")) {
        id = "1";
        myQuery += "where subitemtype = " + id;
    } else {
        myQuery += "where subitemtype = " + id;
    }
    myQuery += " order by subitem";
    
    out.print("<h1> " + pageHeader + "</h1>");
    
    ResultSet lRs = io.opnRS(myQuery);
    RWHtmlForm frm = new RWHtmlForm();
    RWHtmlTable htmTb = new RWHtmlTable("600");
    RWHtmlDiv div = new RWHtmlDiv();
    htmTb.setBorder("0");
    
    out.print(frm.startForm("onSubmit=\"self.close();\" method=\"post\" action=\"visitactivity.jsp\" target=\"visitactivity\""));
    
    out.print(div.startDiv(300,0,div.AUTO,div.AUTO,""));
    out.print(htmTb.startTable());
    
    while (lRs.next()) {
        cellContents = frm.checkBox(false,"","si_" + lRs.getString("id")) + lRs.getString("subitem");
        out.print(htmTb.startRow());
        out.print(htmTb.addCell(cellContents, "width=200 style=font-size:13px"));
        if (lRs.next()) {
            cellContents = frm.checkBox(false,"","si_" + lRs.getString("id")) + lRs.getString("subitem");
        } else {
            cellContents = "";
        }
        out.print(htmTb.addCell(cellContents, "width=200 style=font-size:13px"));
        if (lRs.next()) {
            cellContents = frm.checkBox(false,"","si_" + lRs.getString("id")) + lRs.getString("subitem");
        } else {
            cellContents = "";
        }
        out.print(htmTb.addCell(cellContents, "width=200 style=font-size:13px"));
        out.print(htmTb.endRow());
    }
    
    out.print(htmTb.endTable());
    out.print(div.endDiv());
    
    out.print("<br>" + frm.submitButton("ok","class=button"));
    
    if (noteId!=null) { out.print(frm.hidden(noteId, "noteId")); }
    if (itemId!=null) { out.print(frm.hidden(itemId, "itemId")); }
    if (visitId!=null) { out.print(frm.hidden(visitId, "visitId")); }

    out.print(frm.endForm());

    session.setAttribute("returnUrl", "");
%>
