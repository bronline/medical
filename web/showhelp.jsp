<%@page import="tools.*, java.sql.ResultSet"%>
<link rel="stylesheet" type="text/css" href="css/stylesheet.css" title="stylesheet">

<title>Help Text</title>

<%
    RWConnMgr catalogIo = new RWConnMgr("localhost", "rwcatalog", "rwtools", "rwtools", RWConnMgr.MYSQL);
    RWHtmlTable htmTb   = new RWHtmlTable("600", "0");
    htmTb.replaceNewLineChar(false);
    String variable = request.getParameter("fieldName");
    String table    = request.getParameter("tableName");
    StringBuffer ht = new StringBuffer();

    ResultSet cRs = catalogIo.opnRS("select * from catalog where tablename='" + table + "' and columnName='" + variable + "'");
    if(cRs.next()) {
        out.print("<b><big>" + cRs.getString("columnheading") + "</big></b>");
        ht.append(htmTb.startTable());
        ht.append(htmTb.startRow("height=95 bgcolor=#e0e0e0"));
        if(cRs.getString("helpText") != null && !cRs.getString("helptext").equals("")) {
            ht.append(htmTb.addCell(cRs.getString("helptext")));
        } else {
            ht.append(htmTb.addCell("Help text not avaiable for field"));
        }
        ht.append(htmTb.endRow());
        ht.append(htmTb.endTable());
        out.print(htmTb.getTableDiv(135, 618, "id=helpText", htmTb.getFrame(htmTb.BOTH, "", "#e0e0e0", 3, ht.toString())));
    }

    cRs.close();

%>