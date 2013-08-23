<%@include file="globalvariables.jsp" %>
<TITLE>Select Current Resource</TITLE>
<script language="javascript">
  function submitForm(action) {
    var frmA=document.forms["frmInput"]
    frmA.method="POST"
    frmA.action=action
    frmA.submit()
  } 
</script>
<%
    String[] preload2={};
    RWHtmlTable htmTb = new RWHtmlTable("300", "0");
    RWInputForm frm = new RWInputForm();
    ResultSet lRs = io.opnRS("select id, name from resources");
    StringBuffer iForm = new StringBuffer();

    htmTb.setWidth("210");
    iForm.append("<TABLE WIDTH=100% HEIGHT=100% ><TR><TD style='font-size=20' height=10% ALIGN=CENTER>");
    iForm.append("Please set the resource that will be performing procedures for the patient during this visit</TD></TR><TR><TD VALIGN=TOP ALIGN=CENTER>");
    iForm.append(frm.startForm());
    iForm.append(htmTb.startTable());
            
    iForm.append(htmTb.startRow());
    iForm.append(htmTb.addCell(frm.comboBox(lRs,"currentresource","rsc",false,"1",preload2,"1","class=cBoxText"),htmTb.CENTER,""));
    iForm.append(htmTb.endRow());

    iForm.append(htmTb.startRow());
    iForm.append(htmTb.addCell(frm.button("select","style=\"width:100\" class=button onClick=submitForm('visitactivity.jsp')"), htmTb.CENTER, "colspan=3"));
    iForm.append(htmTb.endRow());

    iForm.append(htmTb.endTable());
    iForm.append(frm.endForm());

    iForm.append("</TD></TR></TABLE>");
    out.print(iForm.toString());

%>


