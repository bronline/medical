<%@ page import="tools.*, java.sql.*" %>
<%
    String userName=request.getParameter("userName");

    if(userName == null || userName.trim().equals("")) {
        out.print("You are not authorized to this application");
    } else {
//	  try {
//		boolean transferToChiroPractice=false;
//		RWConnMgr io=new RWConnMgr("localhost", "medicalsecure", "rwtools", "rwtools", RWConnMgr.MYSQL);
//		ResultSet lRs=io.opnRS("select * from users where username='" + userName + "'");
//		if(lRs.next()) {
//			lRs.beforeFirst();
//			while(lRs.next()) {
//				if(request.getRemoteAddr().equals(lRs.getString("ipaddress"))) {
//					transferToChiroPractice=true;
//					break;
//				}
//			}
//		} else {
//			transferToChiroPractice=true;
//		}
//		lRs.close();
//		if(transferToChiroPractice) {
                        session.setAttribute("databaseName", userName);
			response.sendRedirect("setdbname.jsp?databaseName="+userName);
//		} else {
//			out.print("You are not authorized to this application");
//		}
//	  } catch (Exception transferException) {
//		response.sendRedirect("http://www.chiropracticeonline.net");
//	  }

    }
%>