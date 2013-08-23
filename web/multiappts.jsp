<%@include file="globalvariables.jsp" %>
<TITLE>Schedule Multiple Appts</TITLE>
<script language="JavaScript" src="js/CheckLength.js"></script>

<script language="javascript">
  function submitForm(action) {
    var frmA=document.forms["frmInput"]
    frmA.method="POST"
    frmA.action=action
    frmA.submit()
  } 
   function confirmDelete(action) {
    var isSure = confirm('All Future Appointments for this patient will be deleted. Are you sure you want to continue?');
    var frmA=document.forms["frmInput"]
    frmA.method="POST"
    if (isSure==true) {
        submitForm(action)
    }    
  }

</script>
<script>
  function setFocus() {
    document.frmInput.weeks.focus();
  }
</script>

<%
    int weeks;
    String startDate;
    int apptType;
    String sunday = request.getParameter("sunday");
    String monday = request.getParameter("monday");
    String tuesday = request.getParameter("tuesday");
    String wednesday = request.getParameter("wednesday");
    String thursday = request.getParameter("thursday");
    String friday = request.getParameter("friday");
    String saturday = request.getParameter("saturday");
    String suntime=request.getParameter("suntime");
    String montime=request.getParameter("montime");
    String tuetime=request.getParameter("tuetime");
    String wedtime=request.getParameter("wedtime");
    String thutime=request.getParameter("thutime");
    String fritime=request.getParameter("fritime");
    String sattime=request.getParameter("sattime");
    String time="";
    int calendarDayOfWeek;
    if (patient.getId() == 0) {
        out.print("No Patient Is Selected.");
    } else {
        String[] preload={"*UNASSIGNED"};
        String[] preload2={};
        String[] resourceList={};
        String resourceId="0";
        
        RWHtmlTable htmTb = new RWHtmlTable("300", "0");
        RWInputForm frm = new RWInputForm();
        RWInputForm frm1 = new RWInputForm();
        ResultSet pRs = io.opnRS("select resourceid from patients where id=" + patient.getId());
        ResultSet lRs = io.opnRS("select id, description from appointmenttypes");
        ResultSet aRs = io.opnRS("select date_format(starttime,'%H:%i') as time, date_format(starttime,'%h:%i %p') from apptstarttimes ORDER BY starttime");
        ResultSet rRs = io.opnRS("select 0 as id, '*Unassigned' as name union select id, name from resources");
        frm.setShowDatePicker(true);
        StringBuffer iForm = new StringBuffer();
        htmTb.replaceNewLineChar(false);

        if(pRs.next()) { resourceId=pRs.getString("resourceid"); }
        
        frm.setDftTextBoxSize("25");
        frm.formItemOnOneRow = false;
        frm.setLabelBold(true);
        frm.setLabelPosition(frm.LABEL_ON_LEFT);
        frm.setUseExternalForm(true);

        htmTb.setWidth("210");
        out.print(patient.getMiniContactInfo(htmTb,"11"));
        out.print("<hr>");
        htmTb.setWidth("210");

        iForm.append(frm.startForm());
        iForm.append(htmTb.startTable());

        iForm.append(htmTb.startRow());
        iForm.append(htmTb.addCell("<b>Weeks"));
        iForm.append(htmTb.addCell(frm.textBox("1", "weeks","2","2","maxlength=2 onBlur=\"return checkban(this)\" class=tBoxText"), "colspan=2"));
        iForm.append(htmTb.endRow());

        iForm.append(htmTb.startRow());
        iForm.append(htmTb.addCell("<b>Start Date"));
        iForm.append(htmTb.addCell(frm.textBox(Format.formatDate(new java.util.Date(), "MM/dd/yyyy"), "startdate","13","5","class=tBoxText id=startdate") + " <image src=\"images/show-calendar.gif\" onClick='var X=event.x; var Y=event.y; var action=\"datepicker.jsp?formName=frmInput&element=startdate\"; var options=\"width=190,height=111,left=\" + X + \",top=\" + Y + \",\"; window.open(action, \"Date\", options);' style=\"cursor: pointer;\">", "colspan=2"));
        iForm.append(htmTb.endRow());

        iForm.append(htmTb.startRow());
        iForm.append(htmTb.addCell("<b>Appt Type"));
        iForm.append(htmTb.addCell(frm.comboBox(lRs,"appttype","id",false,"1",preload,"1","class=cBoxText"), "colspan=2"));
        iForm.append(htmTb.endRow());

        iForm.append(htmTb.startRow());
        iForm.append(htmTb.addCell("<b>Provider"));
        iForm.append(htmTb.addCell(frm1.comboBox(rRs,"resourceId","id",false,"1",null,resourceId,"class=cBoxText"), "colspan=2"));
        iForm.append(htmTb.endRow());

        iForm.append(htmTb.startRow());
        iForm.append(htmTb.addCell("&nbsp;"));
        iForm.append(htmTb.endRow());

        iForm.append(htmTb.startRow());
        iForm.append(htmTb.addCell("<b>Sunday"));
        iForm.append(htmTb.addCell(frm.checkBox(false,"","sunday")));
        aRs.beforeFirst();
        iForm.append(htmTb.addCell(frm.comboBox(aRs,"suntime","time",false,"1",preload2,"1","class=cBoxText")));
        iForm.append(htmTb.endRow());

        iForm.append(htmTb.startRow());
        iForm.append(htmTb.addCell("<b>Monday"));
        iForm.append(htmTb.addCell(frm.checkBox(false,"","monday")));
        aRs.beforeFirst();
        iForm.append(htmTb.addCell(frm.comboBox(aRs,"montime","time",false,"1",preload2,"1","class=cBoxText")));
        iForm.append(htmTb.endRow());

        iForm.append(htmTb.startRow());
        iForm.append(htmTb.addCell("<b>Tuesday"));
        iForm.append(htmTb.addCell(frm.checkBox(false,"","tuesday")));
        aRs.beforeFirst();
        iForm.append(htmTb.addCell(frm.comboBox(aRs,"tuetime","time",false,"1",preload2,"1","class=cBoxText")));
        iForm.append(htmTb.endRow());

        iForm.append(htmTb.startRow());
        iForm.append(htmTb.addCell("<b>Wednesday"));
        iForm.append(htmTb.addCell(frm.checkBox(false,"","wednesday")));
        aRs.beforeFirst();
        iForm.append(htmTb.addCell(frm.comboBox(aRs,"wedtime","time",false,"1",preload2,"1","class=cBoxText")));
        iForm.append(htmTb.endRow());

        iForm.append(htmTb.startRow());
        iForm.append(htmTb.addCell("<b>Thursday", "width=90"));
        iForm.append(htmTb.addCell(frm.checkBox(false,"","thursday")));
        aRs.beforeFirst();
        iForm.append(htmTb.addCell(frm.comboBox(aRs,"thutime","time",false,"1",preload2,"1","class=cBoxText")));
        iForm.append(htmTb.endRow());

        iForm.append(htmTb.startRow());
        iForm.append(htmTb.addCell("<b>Friday"));
        iForm.append(htmTb.addCell(frm.checkBox(false,"","friday")));
        aRs.beforeFirst();
        iForm.append(htmTb.addCell(frm.comboBox(aRs,"fritime","time",false,"1",preload2,"1","class=cBoxText")));
        iForm.append(htmTb.endRow());

        iForm.append(htmTb.startRow());
        iForm.append(htmTb.addCell("<b>Saturday"));
        iForm.append(htmTb.addCell(frm.checkBox(false,"","saturday")));
        aRs.beforeFirst();
        iForm.append(htmTb.addCell(frm.comboBox(aRs,"sattime","time",false,"1",preload2,"1","class=cBoxText")));
        iForm.append(htmTb.endRow());

        iForm.append(htmTb.startRow());
        iForm.append(htmTb.addCell("&nbsp;"));
        iForm.append(htmTb.endRow());

        iForm.append(htmTb.startRow());
        iForm.append(htmTb.addCell(frm.button("Add Appointments","style=\"width:210\" class=button onClick=submitForm('writemultiappts.jsp')"), "colspan=3"));
        iForm.append(htmTb.endRow());

        iForm.append(htmTb.startRow());
        iForm.append(htmTb.addCell("&nbsp;"));
        iForm.append(htmTb.endRow());

        iForm.append(htmTb.startRow());
        iForm.append(htmTb.addCell(frm.button("Delete Existing Appointments","style=\"width:210\" class=button onClick=confirmDelete('writemultiappts.jsp?delete=Y')"), "colspan=3"));
        iForm.append(htmTb.endRow());

        iForm.append(htmTb.endTable());
        iForm.append(frm.endForm());

        session.setAttribute("returnUrl", "");

        out.print(iForm.toString());
    }
%>


