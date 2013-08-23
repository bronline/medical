<%@ include file="globalvariables.jsp" %>
<script>
    function submitForm(action) {
      var frmA=document.forms["frmInput"]
      frmA.method="POST"
      frmA.action=action
      frmA.submit()
    }
    function addListener() {
        getChargeAmount();
        if (frmInput.itemid.addEventListener){
            frmInput.itemid.addEventListener('keypress', getChargeAmount, false); 
            frmInput.itemid.addEventListener('click', getChargeAmount, false); 
        } else if (frmInput.itemid.attachEvent){
            frmInput.itemid.attachEvent('onchange', getChargeAmount);
        }
    }
    function getChargeAmount() {
        var ajaxChargeAmount = false;
        id=frmInput.itemid.value;
        if(navigator.appName == "Microsoft Internet Explorer") { 
            ajaxChargeAmount = new ActiveXObject("Microsoft.XMLHTTP");
        } else {
            ajaxChargeAmount = new XMLHttpRequest();
        }

        ajaxChargeAmount.open("GET", "getchargeamount.jsp?id=" + id);
        ajaxChargeAmount.onreadystatechange=function() {
            if(ajaxChargeAmount.readyState == 4) {
                frmInput.chargeamount.value=ajaxChargeAmount.responseText;
            }
        }
        ajaxChargeAmount.send(null);
    }


</script>
<body  onload=addListener()>
<%
    StringBuffer entryForm=new StringBuffer();
    RWHtmlTable htmTb=new RWHtmlTable("200", "0");

    if(patient.getId() != 0) {
        RWInputForm frm=new RWInputForm(io.opnRS("select id, visitid, resourceid, itemid, quantity, chargeamount, comments from charges where id=0"));

        htmTb.replaceNewLineChar(false);
        frm.setTableBorder("0");
        frm.setTableWidth("200");
        frm.setMethod("POST");
        frm.setAction("updaterecord.jsp?fileName=charges");
        frm.setUpdateButtonText("add charge");

        frm.setCustomDatasource(1, "select id, DATE_FORMAT(date, '%m/%d/%y') from visits where patientid=" + patient.getId() + " order by date desc");
        frm.setCustomInputType(1, "COMBOBOX");
        frm.setCustomDatasource(2, "select 0 as resourceid, '*None' as name union select id as resourceid, name from resources");
        frm.setCustomInputType(2, "COMBOBOX");
        
        htmTb.setWidth("200");
        entryForm.append(htmTb.getFrame("#cccccc",frm.getInputForm()));

        frm.lRs.close();

        out.print(entryForm.toString());

        session.setAttribute("parentLocatgion", "charges.jsp");
        session.setAttribute("returnUrl", "");
    } else {
        out.print("Patient not set");
    }

%>