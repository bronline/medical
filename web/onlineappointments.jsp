<%-- 
    Document   : onlineappointments.jsp
    Created on : Jun 27, 2011, 7:24:45 AM
    Author     : rwandell
--%>
<%

    String token=request.getParameter("t");
    String sid=request.getParameter("sid");
    String responseText="";
    String user="";

    try{
        int sidInt=Integer.parseInt(sid);

        try {
            tools.RWConnMgr io = new tools.RWConnMgr("localhost", "rwcatalog", "rwtools", "rwtools", 0);
            java.sql.PreparedStatement lPs=io.getConnection().prepareStatement("SELECT * FROM users WHERE token=?");
            lPs.setString(1, token);
            java.sql.ResultSet lRs=lPs.executeQuery();

            if(lRs.next()) {
                user=lRs.getString("username");
                session.setAttribute("online", "Y");
            } else {
                responseText="Invalid Token";
            }

            lRs.close();
            io.getConnection().close();
        } catch (Exception c) {
            responseText="Invalid credentials";
        }

    } catch (Exception e) {
        responseText="Invalid SID";
    }

    if(!responseText.equals("")) {
        out.println(responseText);
    } else {
        session.setAttribute("databaseName", user);
        out.print("<script type='text/javascript'>location.href='onlineappt.jsp'</script>");
    }

// out.print("<h1>This function is currently unavailable</h1>");
%>
