<%@ include file="globalvariables.jsp" %>
<%@ page import="tools.RWHtmlForm, java.util.Enumeration" %>
<%
// Initialize local variables
    RWHtmlForm frm          = new RWHtmlForm("frmInput", "symptoms_d.jsp?update=Y", "POST");
    RWHtmlTable htmTb       = new RWHtmlTable("500","0");
    String ID               = request.getParameter("id");
    String patientId        = request.getParameter("patientid");
    String update           = request.getParameter("update");
    String parentUrl        = request.getParameter("parentUrl");
    String getHint          = request.getParameter("hint");
    String setCondition     = request.getParameter("set");
    int symptomCount        = 0;
    String parentLocation   = (String)session.getAttribute("parentLocation");
    String recordId         = request.getParameter("id");

// If the patient id is not passed make the patient id 0
    if(recordId == null || recordId.equals("")) {
        recordId = "0";
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
        out.print("<v:roundrect style='width: 500; height: 215; text-valign: middle; text-align: center;'>");

//       ResultSet symptomRs=io.opnRS("select * from patientsymptoms where patientId=" + patientId + " order by `sequence`");

        ResultSet symptomRs;
        if(request.getParameter("condition") == null) {
            symptomRs=io.opnRS("select * from patientsymptoms where patientId=" + recordId + " order by `sequence`");
        } else {
            symptomRs=io.opnRS("select * from patientsymptoms where conditionid=" + recordId + " order by `sequence`");
        }
        ResultSet codeRs=io.opnRS("select 0 as diagnosisid, '*Unassigned' as description union select id as diagnosisid, concat(code, ' - ' , description) as description  from diagnosiscodes order by 2");

        sy.append(frm.startForm());
        sy.append(htmTb.startTable("500"));
        sy.append(htmTb.startRow());
        sy.append(htmTb.roundedTopCell(4,"transparent","#030089",""));
        sy.append(htmTb.endRow());

        sy.append(htmTb.startRow());
        sy.append(htmTb.headingCell("Diagnosis Codes", "colspan=4"));
        sy.append(htmTb.endRow());

        while(symptomRs.next()) {
            sy.append(htmTb.startRow());
            sy.append(htmTb.addCell("<b>Seq</b>"));
            sy.append(htmTb.addCell(frm.textBox(symptomRs.getString("sequence"), "sequence"+symptomRs.getString("id"), "size=5 maxlength=5 class=tBoxText style='text-align: right;' id=sequence"+symptomRs.getString("id"))));
            sy.append(htmTb.addCell("<b>Code</b>"));
            sy.append(htmTb.addCell(frm.comboBox(codeRs, "diagnosisid"+symptomRs.getString("id"), "diagnosisid", false, "1", null, symptomRs.getString("diagnosisid"), "class=cBoxText")));
            sy.append(htmTb.endRow());
            symptomCount ++;
        }

        int sequenceNumber=symptomCount+1;

        for(int x=symptomCount;x<8;x++) {
            sy.append(htmTb.startRow());
            sy.append(htmTb.addCell("<b>Seq</b>"));
            sy.append(htmTb.addCell(frm.textBox(""+(sequenceNumber), "new_sequence"+symptomCount, "size=5 maxlength=5 class=tBoxText style='text-align: right;' id=new_sequence"+symptomCount)));
            sy.append(htmTb.addCell("<b>Code</b>"));
            sy.append(htmTb.addCell(frm.comboBox(codeRs, "new_diagnosis"+symptomCount, "diagnosisid", false, "1", null, "0", "class=cBoxText")));
            sy.append(htmTb.endRow());
            symptomCount ++;
            sequenceNumber ++;
        }
        sy.append(htmTb.endTable());

//        sy.append("<br>" + frm.button("  save  ", "class=button onclick=\"formObj=document.getElementById('patientSymptomsBubble'); get(this.parentNode,'SAVE'); \""));
        sy.append("<br>" + frm.button("  save  ", "class=button onclick=\"formObj=document.getElementById('patientsymptomsbubble'); processForm(this.parentNode,'SAVE',null); \""));
        sy.append("&nbsp;&nbsp;" + frm.button("  cancel  ", "class=button onclick=\"showHide(txtHint,'HIDE');\""));
        sy.append("<input type=hidden name=parentLocation id=parentLocation value='NONE'>");
        sy.append("<input type=hidden name=postLocation id=postLocation value='symptoms_d.jsp'>");
        sy.append("<input type=hidden name=fileName id=fileName value='patientsymptoms'>");
        sy.append("<input type=hidden name=update id=update value='Y'>");
        sy.append("<input type=hidden name=patientid id=patientid value='" + patientId + "'>");
        sy.append("<input type=hidden name=conditionId id=conditionId value='" + recordId + "'>");

        sy.append(frm.endForm());
        
        out.print(sy.toString());
        out.print("</v:roundrect>");
    } else {
        PreparedStatement lPs=io.getConnection().prepareStatement("update patientsymptoms set diagnosisid=?, `sequence`=?, patientid=? where id=?");
        PreparedStatement iPs=io.getConnection().prepareStatement("insert into patientsymptoms (diagnosisid, `sequence`, patientid, conditionid, date) values(?, ?, ?, ?, ?)");
        PreparedStatement dPs=io.getConnection().prepareStatement("delete from patientsymptoms where id=?");

        for(Enumeration e=request.getParameterNames();e.hasMoreElements();) {
            String p=(String)e.nextElement();
//            if(p.contains("diagnosisid") && !alreadyHasThisDiagnosis(io, patientId, request.getParameter(p))) {
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
            if(p.contains("new_diagnosis")) {
                String sc=p.substring(13);
                if(!request.getParameter(p).equals("0") && !alreadyHasThisDiagnosis(io, patientId, request.getParameter(p), request.getParameter("conditionId"))) {
                    iPs.setString(1, request.getParameter(p));
                    iPs.setString(2, request.getParameter("new_sequence"+sc));
                    iPs.setString(3, patientId);
                    iPs.setString(4, request.getParameter("conditionId"));
                    iPs.setString(5, Format.formatDate(new java.util.Date(), "yyyy-MM-dd"));
                    iPs.execute();
                }
            }

        }
        Symptoms symptoms=new Symptoms(io);
        out.print(symptoms.getConditionSymptoms(request.getParameter("conditionId")));

//        out.print("<script type='text/javascript'>win('" + parentLocation + "')</script>");
    }

// This will return to the return point set in the calling program
    session.setAttribute("returnUrl", "");
%>
<%! public boolean alreadyHasThisDiagnosis(RWConnMgr io, String patientId, String diagnosisId, String conditionId) throws Exception {
        String myQuery = "select * from patientsymptoms where patientid=" + patientId + " and diagnosisid=" + diagnosisId + " and conditionid=" + conditionId;
        ResultSet lRs=io.opnRS(myQuery);
        if (lRs.next()) {
            lRs.close();
            return true;
        } else {
            lRs.close();
            return false;
        }
    }
%> 