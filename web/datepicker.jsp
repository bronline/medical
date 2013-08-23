<%@page import="tools.*, tools.utils.*, java.util.Date"%>
<style>
 th             { background: #cccccc; 
                  font-size: 9px; 
                  font-family: tahoma; }
body, td, p     { color: #000000;
                  font-size: 9px;
                  font-family: tahoma; }
.cBoxText	{ font-size: 9px; 
                  font-family: tahoma;
                  vertical-align: top;}  
a               { color: #030089; 
                  text-decoration: none; }
a:hover         { color: #2c57a7; 
                  text-decoration: underline; }
        
</style>
<script language="javascript">
    function checkDateChange(what) {
        xx="datepicker.jsp?month=" + month.value + "&year=" + year.value;
        location.href=xx;
    }

</script>
<%
    String year     = request.getParameter("year");
    String month    = request.getParameter("month");
    String day      = request.getParameter("day");
    String date     = request.getParameter("date");
    String formName = request.getParameter("formName");
    String element  = request.getParameter("element");
    String bgColor  = "";

   if(date == null) {
        if(month == null) {
            month = Format.formatDate(new Date(), "MMMM");
        }

        if(day == null) {
            day = Format.formatDate(new Date(), "dd");
            bgColor="yellow";
        }

        if(year == null) {
            year = Format.formatDate(new Date(), "yyyy");
        }

        if(formName != null) { session.setAttribute("formName", formName); }
        if(element != null) { session.setAttribute("element", element); }
        RWCalendar cal = new RWCalendar(Integer.parseInt(year), month, day);
        cal.setLongDOW(false);
        cal.setLongMonth(true);
        cal.showMonthCombo(true);
        cal.showYearCombo(true);
        cal.setDayUrl("datepicker.jsp");
        cal.showDayLink(true);
        cal.setBgColorForToday("#cccccc");
        cal.setBgColorForSelected(bgColor);
        out.print(cal.getHtmlCalendar("190", "1", "0", "0", "10", ""));
        
        out.print("</body>");
    } else { 
        formName = (String)session.getAttribute("formName");
        element = (String)session.getAttribute("element");
        out.print("<script type=\"text/javascript\">");
        out.print("opener.document.getElementById('" + element + "').value = '" + Format.formatDate(date, "MM/dd/yyyy") + "';");
        out.print("self.close();");
        out.print("</script>");
    }
%>
