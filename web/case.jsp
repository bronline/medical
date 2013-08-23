<%@include file="template/pagetop.jsp" %>
<%@ include file="ajax/ajaxstuff.jsp" %>

<script language="javascript">
  var formObj;
  function submitForm(action) {
    var frmA=document.forms["frmInput"]
    frmA.method="POST"
    frmA.action=action
    frmA.submit()
  }

  function totalCharges() {
    patientPortion = parseFloat(document.forms["frmInput"].elements["patientportion"].value);
    insurancePortion = parseFloat(document.forms["frmInput"].elements["insuranceportion"].value);
    total = patientPortion + insurancePortion;
    document.forms["frmInput"].elements["totalAmount"].value = total;
    document.forms["frmInput"].elements["patientportion"].value=formatNumber(document.forms["frmInput"].elements["patientportion"].value);
    document.forms["frmInput"].elements["insuranceportion"].value=formatNumber(document.forms["frmInput"].elements["insuranceportion"].value);
    document.forms["frmInput"].elements["totalAmount"].value=formatNumber(document.forms["frmInput"].elements["totalAmount"].value);
  }

  function totalVisits() {
    visits           = parseInt(document.forms["frmInput"].elements["visits"].value);
    previousvisits   = parseInt(document.forms["frmInput"].elements["previousvisits"].value);
    visitsToDate     = parseInt(document.forms["frmInput"].elements["visitsToDate"].value);
    visitsAllowed    = parseInt(document.forms["frmInput"].elements["visitsallowed"].value);

    visitsRemaining  = visits-visitsToDate-previousvisits;
    remainingCovered = visitsAllowed-visitsToDate;

    document.forms["frmInput"].elements["visitsRemaining"].value = visitsRemaining;
    document.forms["frmInput"].elements["remainingCovered"].value = remainingCovered;
  }
</script>
<div id="tmpObj" style="visibility: hidden;"></div>
<%
    out.print(getTabs(request.getParameter("tab"), request.getRequestURI(), session.getAttribute("tab")));
    out.print("<tr><td colspan=\"5\" valign=\"top\" style='width: 100%; height: 400px; margin-left: 10px; border-left: 1px solid black; border-right: 1px solid black;'>");
    if(request.getParameter("tab") == null || request.getParameter("tab").equals("1")) {
        out.print(getCaseInfo(io, patient.getId()));
    } else if(request.getParameter("tab").equals("2")) {
        PatientPlan plan = patient.getPatientPlan();
        out.print(plan.getInputForm(""+patient.getId()));
    } else if(request.getParameter("tab").equals("3")) {
    } else if(request.getParameter("tab").equals("4")) {
        out.print(getCondition(patient));
    } else if(request.getParameter("tab").equals("5")) {
    }
    out.print("</td></tr>");
    out.print("<tr><td colspan=\"5\" style=\"border-left: 1px solid black; border-bottom: 1px solid black; border-right: 1px solid black;\">&nbsp;&nbsp;</tr></table>");
%>
<%! public String getTabs(String tab, String requestUri, Object thisTab) {
        StringBuffer str=new StringBuffer();
        String bgColor = "";
        RWHtmlTable tabTbl  = new RWHtmlTable("800", "0");
        int curTab          = 0;
        String tabDesc []   = { "Case Info", "Limitations", "Guarantor", "Condition", "Authorization" };

        if(tab == null) {
            tab = (String)thisTab;
            if(tab == null) { tab = "1"; }
        }

        curTab = Integer.parseInt(tab);

        str.append(tabTbl.startTable());

        str.append(tabTbl.startRow());
        for(int x=0; x<tabDesc.length; x++) {
            bgColor = " background: #cccccc;\"";
            if((x+1) == curTab) { bgColor = " background: #ffffff;\""; }
            str.append(tabTbl.addCell(tabDesc[x], 2, "style=\"border-left: black solid 1px; border-top: black solid 1px; border-right: black solid 1px;" + bgColor, requestUri + "?tab=" + (x+1)));
        }
        str.append(tabTbl.endRow());

        str.append(tabTbl.startRow());
        str.append(tabTbl.addCell("", tabTbl.LEFT, "height='3px' style=\"border-left: black solid 1px; border-right: black solid 1px;\" colspan=" + tabDesc.length));
        str.append(tabTbl.endRow());

        return str.toString();
    }

    public String getCaseInfo(RWConnMgr io, int patientId) {
        StringBuffer str=new StringBuffer();
        RWHtmlTable htmTb=new RWHtmlTable("400","0");
        htmTb.replaceNewLineChar(false);
        try {
            ResultSet lRs=io.opnRS("select id, name, providerid, facilityid, referral, employerid from `case` where patientid="+patientId);
            RWInputForm frm=new RWInputForm(lRs);
            frm.setRecordSet(lRs);

            frm.setCustomDatasource(2, "select id, name from providers where id in (select providerid from patientinsurance where patientid=" + patientId + ")");

            str.append(frm.startForm());
            str.append(htmTb.startTable());
            str.append(frm.getInputItem("name", ""));
            str.append(frm.getInputItem("providerid"));
            str.append(frm.getInputItem("facilityid"));
            str.append(frm.getInputItem("referral", "onChange=checkForNew(this,'referalsource.jsp')"));
            str.append(frm.getInputItem("employerid", "onChange=checkForNew(this,'employers.jsp')"));
            str.append(frm.hidden(""+patientId, "patientId"));
            str.append(htmTb.endTable());
            str.append(frm.submitButton("save"));

            str.append(frm.endForm());
        } catch(Exception e) {
            str.append(e.getMessage());
        }
        return htmTb.getFrame("#e0e0e0", str.toString());
    }

    public String getCondition(Patient patient) {
        StringBuffer str=new StringBuffer();
        RWHtmlTable htmTb=new RWHtmlTable("500","0");
        htmTb.replaceNewLineChar(false);
        patient.condition.setEditMode(true);
        try{
            str.append(htmTb.startTable());
            str.append(htmTb.startRow());
            str.append(htmTb.addCell(patient.getPatientCondition(),"width='250'"));
            str.append(htmTb.addCell(patient.getSymptoms(),"width='250'"));
            str.append(htmTb.endRow());
            str.append(htmTb.startRow());
            str.append(htmTb.addCell(patient.getConditions()));
            str.append(htmTb.addCell(""));
            str.append(htmTb.endRow());
            str.append(htmTb.endTable());
        } catch (Exception e) {
            str.append(e.getMessage());
        }
        return str.toString();
    }
%>
<%@ include file="template/pagebottom.jsp" %>
