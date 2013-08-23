<%@include file="sessioninfo.jsp" %>
<div align="right" style="width: 100%;"><b style="cursor: pointer; font-weight: bold;" onClick="showHide(subItemList,'HIDE')">close</b></div>
<%
// Initialize local variables
    String myQuery          = "select id, subitem from subitems ";
    String id               = request.getParameter("subitemtypeid");
    String itemId           = request.getParameter("itemId");
    String noteId           = request.getParameter("noteId");
    String visitId          = request.getParameter("visitId");
    String resourceId       = request.getParameter("resourceId");
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

    out.print("<h1>&nbsp;&nbsp;&nbsp;&nbsp; " + pageHeader + "</h1>");

    ResultSet lRs = io.opnRS(myQuery);
    RWHtmlForm frm = new RWHtmlForm();
    RWHtmlTable htmTb = new RWHtmlTable("600");
    RWHtmlDiv div = new RWHtmlDiv();
    htmTb.setBorder("0");

    out.print(frm.startForm());

    out.print(div.startDiv(300,0,div.AUTO,div.AUTO,"style='margin-left: 10px;'"));
    out.print(htmTb.startTable());

    while (lRs.next()) {
//        cellContents = frm.checkBox(false,"","si_" + lRs.getString("id")) + "<span onClick=setSubItemCheckBox(si_" + lRs.getString("id") + "_cb)>" + lRs.getString("subitem") + "</span>";
        cellContents = "<input type=\"checkbox\" name=\"si_" + lRs.getString("id") + "\" onClick=setSubItemCheckBoxA(si_" + lRs.getString("id") + ")>&nbsp;<span onClick=setSubItemCheckBoxA(si_" + lRs.getString("id") + ")>" + lRs.getString("subitem") + "</span>";
        out.print(htmTb.startRow("style=\"height: 30px;\""));
        out.print(htmTb.addCell("","width=10"));
        out.print(htmTb.addCell(cellContents, "width=200 style=font-size:13px"));

        if (lRs.next()) {
//            cellContents = frm.checkBox(false,"","si_" + lRs.getString("id")) + "<span onClick=setSubItemCheckBox(si_" + lRs.getString("id") + "_cb)>" + lRs.getString("subitem") + "</span>";
        cellContents = "<input type=\"checkbox\" name=\"si_" + lRs.getString("id") + "\" onClick=setSubItemCheckBoxA(si_" + lRs.getString("id") + ")>&nbsp;<span onClick=setSubItemCheckBoxA(si_" + lRs.getString("id") + ")>" + lRs.getString("subitem") + "</span>";
        } else {
            cellContents = "";
        }
        out.print(htmTb.addCell(cellContents, "width=200 style=font-size:13px"));

        if (lRs.next()) {
//            cellContents = frm.checkBox(false,"","si_" + lRs.getString("id")) + "<span onClick=setSubItemCheckBox(si_" + lRs.getString("id") + "_cb)>" + lRs.getString("subitem") + "</span>";
        cellContents = "<input type=\"checkbox\" name=\"si_" + lRs.getString("id") + "\" onClick=setSubItemCheckBoxA(si_" + lRs.getString("id") + ")>&nbsp;<span onClick=setSubItemCheckBoxA(si_" + lRs.getString("id") + ")>" + lRs.getString("subitem") + "</span>";
        } else {
            cellContents = "";
        }
        out.print(htmTb.addCell(cellContents, "width=200 style=font-size:13px"));
        out.print(htmTb.endRow());
    }

    out.print(htmTb.endTable());
    out.print(div.endDiv());

//    out.print("<br>" + frm.submitButton("ok","class=button"));

    out.print("&nbsp;&nbsp;&nbsp;&nbsp;<input type='button' onclick=\"updateSubItem(this,"+visitId+")\" value=\"ok\" class=\"button\" /><br>");
    if(noteId == null) {
        out.print("<input type=hidden name=postLocation id=postLocation value='ajax/addchargetovisit.jsp'>");
    } else {
        out.print("<input type=hidden name=postLocation id=postLocation value='ajax/addnotetovisit.jsp'>");
    }
    out.print("<input type=\"hidden\" name=\"update\" id=\"update\" value=\"Y\">");
    out.print("<input type=\"hidden\" name=\"parentLocation\" id=\"parentLocation\" value=\"SUBITEM\">");
    out.print("<input type=\"hidden\" name=\"resourceId\" id=\"resourceId\" value=\"" + resourceId + "\">");
    out.print("<input type=\"hidden\" name=\"itemOrder\" id=\"itemOrder\" value=\"\">");

    if (noteId!=null) { out.print("<input type=\"hidden\" id=\"noteId\" name=\"noteId\" value=" + noteId + ">"); }
    if (itemId!=null) { out.print("<input type=\"hidden\" id=\"itemId\" name=\"itemId\" value=" + itemId + ">"); }
    if (visitId!=null) { out.print("<input type=\"hidden\" id=\"visitId\" name=\"visitId\" value=" + visitId + ">"); }

    out.print(frm.endForm());

    session.setAttribute("returnUrl", "");
%>
<%@include file="cleanup.jsp" %>
