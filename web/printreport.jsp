<%@ include file="globalvariables.jsp" %>
<style>
body, td, p { color: #000000;
              font-size: 12px;
              font-family: tahoma; }

th	    { font-size: 12px;
              font-family: tahoma;
	      background-color: #030089;
	      color: white;  }

</style>
<style media="print" rel="stylesheet" type="text/css">
    .navStuff { DISPLAY: none }
    a:after { content:' [' attr(href) '] ' }
</style>

<input type="submit" name="print_btn" value="print" onclick="window.print();" class="btn navStuff" >
<%
try {
    String contentType=request.getParameter("contentType");

    if(contentType != null) {
        if(contentType.toUpperCase().equals("EXCEL")) { response.setContentType("application/vnd.ms-excel"); }
        else if(contentType.toUpperCase().equals("WORD")) { response.setContentType("application/msword"); }
    }

    RWFilteredList lst = (RWFilteredList)session.getAttribute("reportToPrint");
    lst.setDivHeight(0);
    lst.setShowComboBoxes(false);    
    out.print(lst.getHtml());
} catch (Exception e) {
    out.print("No Report Found");
}
%>