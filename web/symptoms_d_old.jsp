<%@ include file="globalvariables.jsp" %>
<%@ page import="tools.RWHtmlForm, java.util.Enumeration" %>
<title>Symptoms</title>
<script language="JavaScript" src="js/date-picker.js"></script>
<script language="javascript">
  function submitForm(action) {
    var frmA=document.forms["frmInput"]
    frmA.method="POST"
    frmA.action=action
    frmA.submit()
  }  

  function win(parent){
    if(parent != null && parent != 'None') { window.opener.location.href=parent }
    self.close();
  }
</SCRIPT>
<%
// Initialize local variables
    RWHtmlForm frm          = new RWHtmlForm("frmInput", "symptoms_d.jsp?update=Y", "POST");
    RWHtmlTable htmTb       = new RWHtmlTable("600","0");
    String ID               = request.getParameter("id");
    String patientId        = request.getParameter("patientid");
    String update           = request.getParameter("update");
    String parentUrl        = request.getParameter("parentUrl");
    String getHint          = request.getParameter("hint");
    String setCondition     = request.getParameter("set");
    int symptomCount        = 0;
    String parentLocation   = (String)session.getAttribute("parentLocation");
    
// If the member id is not passed make the member id 0
    if(patientId == null || patientId.equals("")) {
        patientId = "0";
    }

// Instantiate a symptom
    Symptom symptom = new Symptom(io, ID);

    if(update == null || update.trim().equals("")) {
        frm.setDftTextBoxSize("20");
        frm.setDftTextAreaCols("80");
        frm.setDftTextAreaRows("10");
        frm.setShowDatePicker(true);
        StringBuffer sy = new StringBuffer();
    
       // Get an input item with the record ID to set the rcd and ID fields
//        out.print("<v:roundrect style='width: 450; height: 100; text-valign: middle; text-align: center;'>");

        ResultSet symptomRs=io.opnRS("select * from patientsymptoms where patientId=" + patient.getId() + " order by `sequence`");
        ResultSet codeRs=io.opnRS("select 0 as diagnosisid, '*Unassigned' as description union select id as diagnosisid, concat(code, ' - ' , description) as description  from diagnosiscodes order by 2");
        
        sy.append(frm.startForm());
        sy.append(htmTb.startTable());
        
        while(symptomRs.next()) {
            sy.append(htmTb.startRow());
            sy.append(htmTb.addCell("<b>Seq</b>"));
            sy.append(htmTb.addCell(frm.textBox(symptomRs.getString("sequence"), "sequence"+symptomRs.getString("id"), "size=5 maxlength=5 class=tBoxText style='text-align: right;'")));
            sy.append(htmTb.addCell("<b>Code</b>"));
            sy.append(htmTb.addCell(frm.comboBox(codeRs, "diagnosisid"+symptomRs.getString("id"), "diagnosisid", false, "1", null, symptomRs.getString("diagnosisid"), "class=cBoxText")));
            sy.append(htmTb.endRow());
            symptomCount ++;
        }
        
        for(int x=symptomCount;x<4;x++) {
            sy.append(htmTb.startRow());
            sy.append(htmTb.addCell("<b>Seq</b>"));
            sy.append(htmTb.addCell(frm.textBox("999", "new_sequence"+symptomCount, "size=5 maxlength=5 class=tBoxText style='text-align: right;'")));
            sy.append(htmTb.addCell("<b>Code</b>"));
            sy.append(htmTb.addCell(frm.comboBox(codeRs, "new_diagnosisid"+symptomCount, "diagnosisid", false, "1", null, "", "class=cBoxText")));
            sy.append(htmTb.endRow());
            symptomCount ++;                       
        }
        sy.append(htmTb.endTable()); 

        sy.append("<br>" + frm.submitButton("  save  ", "class=button"));
        sy.append("<input type=hidden name=parentLocation id=parentLocation value='" + parentUrl + "'>");
        sy.append("<input type=hidden name=postLocation id=postLocation value='symptoms_d.jsp'>");
        sy.append("<input type=hidden name=fileName id=fileName value='patientsymptoms'>");
        sy.append("<input type=hidden name=update id=update value='Y'>");
        sy.append("<input type=hidden name=patientid id=patientid value='" + patient.getId() + "'>");
        
        sy.append(frm.endForm());

        out.print(sy.toString());
//        out.print("</v:roundrect>");
    } else {
        PreparedStatement lPs=io.getConnection().prepareStatement("update patientsymptoms set diagnosisid=?, `sequence`=?, patientid=? where id=?");
        PreparedStatement iPs=io.getConnection().prepareStatement("insert into patientsymptoms (diagnosisid,`sequence`,patientid) values(?,?,?)");
        PreparedStatement dPs=io.getConnection().prepareStatement("delete from patientsymptoms where id=?");
        
        for(Enumeration e=request.getParameterNames();e.hasMoreElements();) {
            String p=(String)e.nextElement();
            if(p.contains("diagnosisid")) {
                String sc=p.substring(11);
                if(!request.getParameter(p).equals("0")) {
                    lPs.setString(1, request.getParameter(p));
                    lPs.setString(2, request.getParameter("sequence"+sc));
                    lPs.setString(3, patientId);
                    lPs.setString(4, sc);
                    lPs.execute();
                } else {
                    dPs.setString(1, sc);
                    dPs.execute();
                }
            }
            if(p.contains("new_diagnosisid")) {
                String sc=p.substring(15);
                if(!request.getParameter(p).equals("0")) {
                    iPs.setString(1, request.getParameter(p));
                    iPs.setString(2, request.getParameter("new_sequence"+sc));
                    iPs.setString(3, patientId);
                    iPs.execute();
                }
            }

        }
        
        out.print("<script type='text/javascript'>win('" + parentLocation + "')</script>");
    }
    
// This will return to the return point set in the calling program
    session.setAttribute("returnUrl", "");
%>
