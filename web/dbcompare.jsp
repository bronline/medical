<%@ page import="tools.RWConnMgr, com.rwtools.tools.db.utils.DBCompare, java.util.ArrayList, medical.utiils.*" %>
<%
    out.print("hello");
    UpdateChiroDatabases upd = new UpdateChiroDatabases();

    if(request.getParameter("update") != null && request.getParameter("update").equals("Y")) {
        upd.doUpdate();
    } else {
        upd.checkForUpdates();
    }
%>