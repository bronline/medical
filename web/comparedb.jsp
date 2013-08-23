<%@ include file="globalvariables.jsp" %>
<%@ page import="com.rwtools.tools.db.utils.DBCompare" %>
<%
    String update = request.getParameter("update");
    boolean process = false;
    
    if(update != null && !update.equals("")) { process=true; }
    
    DBCompare dbCompare=new DBCompare();

    RWConnMgr fromIo=new RWConnMgr("bronlinesolutions.com", "medical", "medical", "medical", RWConnMgr.MYSQL);

    dbCompare.setFromIo(fromIo);
    dbCompare.setToIo(io);
    dbCompare.setProcessUpdates(process);

    dbCompare.compareSchemas();
    
    ArrayList msg = dbCompare.getMessages();
    for(int x=0;x<msg.size();x++) {
        out.println((String)msg.get(x) + "<br>");
    }
    
%>