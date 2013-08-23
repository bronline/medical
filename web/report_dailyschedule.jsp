<%@include file="template/pagetop.jsp" %>
<script>
    function printReport() {
      window.open('printreport.jsp','print','height=300,width=790,scrollbars=yes,resizable');
    }
    
    function changeReportDate() {
        frmInput.submit();
    }
</script>
<%@ include file="ajax/ajaxstuff.jsp" %>
<%
   RWFilteredList lst = new RWFilteredList(io);
   RWHtmlTable htmTb = new RWHtmlTable("800", "0");
   RWHtmlForm frm = new RWHtmlForm("frmInput", self, "POST");

   String reportDate=request.getParameter("reportDate");
   String reportToDate=request.getParameter("reportToDate");
   String includeArrivalsString=request.getParameter("includeArrivals");
   String title="TodaysSchedule";

   boolean includeArrivals;
   
   if (includeArrivalsString!=null && includeArrivalsString.equalsIgnoreCase("TRUE")) {
       includeArrivals=true;
   } else {       
       includeArrivals=false;
   }
   
   if(reportDate == null || reportDate.equals("")) { reportDate=Format.formatDate(new java.util.Date(), "yyyy-MM-dd"); }
   if(reportToDate == null || reportToDate.equals("")) { reportToDate=Format.formatDate(new java.util.Date(), "yyyy-MM-dd"); }

  String datePicker = "<image src=\"images/show-calendar.gif\" " +
                     "onClick='var X=event.x; var Y=event.y; " + 
                     "var action=\"datepicker.jsp?formName=frmInput&element=reportDate" + 
                     "&month=" + Format.formatDate(reportDate, "MM") + 
                     "&year=" + Format.formatDate(reportDate, "yyyy") + 
                     "&day=" + Format.formatDate(reportDate, "dd") + "\"; " +
                     "var options=\"width=190,height=111,left=\" + X + \",top=\" + Y + \",\"; " +
                     "window.open(action, \"Date\", options);' " +
                     "style=\"cursor: pointer;\">";

  String dateToPicker = "<image src=\"images/show-calendar.gif\" " +
                     "onClick='var X=event.x; var Y=event.y; " + 
                     "var action=\"datepicker.jsp?formName=frmInput&element=reportToDate" + 
                     "&month=" + Format.formatDate(reportToDate, "MM") + 
                     "&year=" + Format.formatDate(reportToDate, "yyyy") + 
                     "&day=" + Format.formatDate(reportToDate, "dd") + "\"; " +
                     "var options=\"width=190,height=111,left=\" + X + \",top=\" + Y + \",\"; " +
                     "window.open(action, \"Date\", options);' " +
                     "style=\"cursor: pointer;\">";

   frm.setShowDatePicker(true);
   htmTb.replaceNewLineChar(false);
   out.print(frm.startForm());
   out.print(htmTb.startTable());
   out.print(htmTb.startRow());
   out.print(htmTb.addCell("<b>From Date</b>", "width=70"));
   out.print(htmTb.addCell(frm.date(Format.formatDate(reportDate, "MM/dd/yyyy"), "reportDate", "class=tBoxText") + datePicker, " width=200"));
//   out.print(htmTb.addCell(frm.button("view", "class=button onClick=changeReportDate() "), htmTb.LEFT, "width=50"));
   out.print(htmTb.addCell("<b>To Date</b>", "width=70"));
   out.print(htmTb.addCell(frm.date(Format.formatDate(reportToDate, "MM/dd/yyyy"), "reportToDate", "class=tBoxText") + dateToPicker, " width=200"));
   out.print(htmTb.addCell("<b>Include Arrivals</b>", "width=100"));
   out.print(htmTb.addCell(frm.checkBox(includeArrivals,"","includeArrivals")));
   out.print(htmTb.addCell(frm.button("view", "class=button onClick=changeReportDate() "), htmTb.LEFT, "width=50"));
//   out.print(htmTb.addCell("", "width=280"));
   out.print(htmTb.endRow());
   out.print(htmTb.endTable());
   out.print(frm.endForm());
   
   String [] ch = { "", "Provider", "First Name", "Last Name", "Contact Phone", "E-Mail", "Appt Type", "Date", "Time", "AM/PM", "Chk" };
   String [] cw = { "0", "150", "75", "75", "100", "100", "100", "100", "40", "40", "50" };
   String myQuery = "select p.id as patientid, ifnull(r.name,'*Unassigned') as Provider, p.LastName, p.FirstName, " +
                    "case when preferredcontact=0 then homephone when preferredcontact=1 then workphone when preferredcontact=2 then cellphone end as phonenumber, " +
                    "EMail, t.Type, DATE_FORMAT(a.date, '%m/%d/%y') as Date, TIME_FORMAT(a.Time, '%h:%i') as Time, " +
                    "case when time<'12:00' then 'AM' else 'PM' end as AMPM, " +
                    "concat('<input type=checkbox name=chk',a.id,' ', case when notified then 'checked' else '' end,'>')  as Chk " +
                    "from appointments a " +
                    "left join resources r on r.id=a.resourceid " +
                    "left join patients p on p.id=a.patientid " +
                    "left join appointmenttypes t on a.type=t.id " +
                    "where date between '" + Format.formatDate(reportDate, "yyyy-MM-dd") + "' and " +
                    "'" + Format.formatDate(reportToDate, "yyyy-MM-dd") + "' ";
    if (!includeArrivals) { myQuery += "and not exists (select * from visits where appointmentid=a.id) "; } 

    myQuery += "order by a.Date, a.time";

//   lst.setColumnFormat(3,"(###)-###-####");
   lst.setColumnFormat(4,"(###)-###-####");
//   lst.setColumnFormat(5,"(###)-###-####");
   lst.setColumnAlignment(4, "center");
   lst.setColumnAlignment(6, "center");
   lst.setColumnAlignment(7, "center");
   lst.setColumnAlignment(8, "center");
   lst.setColumnAlignment(9, "center");
   lst.setColumnFilterState(1, true);
   lst.setColumnFilterState(6, true);
   lst.setColumnFilterState(9, true);
   lst.setAlternatingRowColors("#e0e0e0", "#cccccc");
   lst.setColumnWidth(cw);
   lst.setFormMethod("POST");
   lst.setDivHeight(400);
   lst.setTableWidth("800");
   lst.setTableBorder("0");
   lst.setUseCatalog(true);

   lst.setUrlField(0);
    lst.setOnClickAction(2, "javascript:enableMouseOut=false;ajaxComplete=false;showItem(event,'comments_d_new.jsp?type=3&date=" + Format.formatDate(new java.util.Date(),"yyyy-MM-dd") + "',0,##idColumn##,txtHint) style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    lst.setOnClickAction(3, "javascript:enableMouseOut=false;ajaxComplete=false;showItem(event,'comments_d_new.jsp?type=3&date=" + Format.formatDate(new java.util.Date(),"yyyy-MM-dd") + "',0,##idColumn##,txtHint) style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    lst.setOnMouseOverAction(2, "showPhoneNumber(event,##idColumn##,txtHint)");
    lst.setOnMouseOverAction(3, "showPhoneNumber(event,##idColumn##,txtHint)");
    lst.setOnMouseOutAction(2, "showHide(txtHint,'HIDE')");
    lst.setOnMouseOutAction(3, "showHide(txtHint,'HIDE')");  

   out.print(lst.getHtml(request, myQuery, ch));
   out.print("<input type=button class=button value=print onClick=printReport()>");
   out.print("&nbsp;&nbsp;<input type=button class=button value='email notifications' onClick=emailNotifications()>");

   session.setAttribute("reportToPrint", lst);
   session.setAttribute("parentLocation", "None");
%>
<script language="javascript">
  function formSubmit() {
    var frmA=document.forms["formFilter"]
    var reportDate = document.createElement('input');
    reportDate.name='reportDate'
    reportDate.value=frmInput.reportDate.value
    frmA.appendChild(reportDate)
    var reportToDate = document.createElement('input');
    reportToDate.name='reportToDate'
    reportToDate.value=frmInput.reportToDate.value
    var includeArrivals = document.createElement('input');
    frmA.appendChild(reportToDate)
    includeArrivals.name='includeArrivals'
    includeArrivals.value=frmInput.includeArrivals.value
    frmA.appendChild(includeArrivals)
    frmA.action=""
    frmA.method="POST"
    frmA.submit()
  }
</script>
<%@ include file="template/pagebottom.jsp" %>