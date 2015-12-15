<%

        System.gc();

        String companyName=env.getString("companyname");
        String companyUrl=env.getString("companyurl");
    // If the connection is still open close it
        if(io != null) {
            if(io.getConnection() != null) { io.getConnection().close(); }
            io.setConnection(null);
        }

        if (content.equals("HTML")) {
%>
<%@ include file="/tabbottom.jsp"%>
<!-- end of body -->

          </TD>
        </TR>	
      </TABLE>
    </td>
  </tr>
  
  <tr>
    <td height="37" colspan=2 style="padding-left:30px; padding-right:25px; ">
      <table width="100%"  border="0" cellpadding="0" cellspacing="0">
        <tr>
            <td class=copyright><a href="<%= companyUrl %>" target="_blank" class="copyright"><%= companyName %></a></td>
          <td align="right" nowrap></td>
        </tr>
      </table>
    </td>
  </tr>
  
</table>
</div>
</body>

</html>

<!-- start of included methods -->

<%

        }
//    } catch (Exception xxx) {
//        System.out.println(databaseName + ": " + new java.util.Date() + " - " + request.getRemoteAddr() + " pagebottom.jsp - problem presenting page (" + xxx.getMessage() + ")");
//    }

    if(redirect) {
        out.print("<script type=\"text/javascript\">window.location.href=\"" + self + "\"</script>");
    }
       
%>