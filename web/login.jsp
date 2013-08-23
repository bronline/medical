<%-- 
    Document   : login
    Created on : Nov 23, 2011, 9:11:17 AM
    Author     : rwandell
--%>

<%@page contentType="text/html" pageEncoding="windows-1252"%>
<link rel="stylesheet" type="text/css" href="css/common.css" title="stylesheet">
<%
    String databaseName = "medical";
    String userName = "";
    String errorMessage=(String)session.getAttribute("errorMessage");

    if(userName == null) { userName=""; }
    if(errorMessage == null) { errorMessage=""; }
    
%>
<body topmargin="0" leftmargin="0" style="background-color: #000066;  background-image: url('/medicaldocs/bg_page.gif'); ">
    <table height="100%" width="100%" border=0 cellpadding=0 cellspacing=0>
      <tr>
        <td height=75 colspan=2>
            <table  width=100% border=0 cellpadding=0 cellspacing=0>
                <tr>
                    <td width="45%" bgcolor=white align=left><img src="/medicaldocs/<% out.print(databaseName); %>/images/topleft.JPG" height=75 alt=""></td>
                    <td width="10%" bgcolor=white align=left><img src="/medicaldocs/<% out.print(databaseName); %>/images/topcenter.JPG" height=75 alt=""></td>
                    <td width="45%" bgcolor=white align=right><img src="/medicaldocs/<% out.print(databaseName); %>/images/topright.JPG" height=75 alt=""></td>
                </tr>
                <tr>
                    <td width="100%" colspan=3 height=3 bgcolor=navy></td>
                </tr>
            </table>
        </td>
      </tr>
      <tr>
          <td> 
            <div id="loginPage" align="center">
                <div style="width: 400px; position: absolute; top: 30%; left: 20%; height: 10em; margin-top: -5em;">
                        <div style="position: absolute; left: 5px; top: 55px;">
                        <div id="loginPanel">
                            <form name="loginForm" method="post" action="checkuser.jsp" >
                                <div style="position: relative; top: 5px;">
                                    <div style="margin-left: 10px; width: 100px; float: left;"><label>User:</label></div><div style="width: 190px; float: left;"><input type="text" name="userName" id="userName" class="tBoxText" size="15" maxlength="25" value="<%= userName %>"></div><br />
                                    <div style="margin-left: 10px; width: 100px; float: left;"><label>Password:</label></div><div style="width: 190px; float: left;"><input type="password" name="password" id="password" class="tBoxText" size="15" maxlength="25"></div><br />
                                    <div style="margin-left: 10px; width: 300px; float: left;"><input type="submit" value="login"></div>
                                </div>
                            </form>
                        </div>
                    <div style="color: red; font-weight: bold; position: absolute; left: 5px; top: 180px; text-align: center;"><%= errorMessage %></div>
                </div>
            </div>
          </td>
      </tr>
    </table>

</body>