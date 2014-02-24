<%-- 
    Document   : medications
    Created on : Sep 4, 2013, 10:16:59 AM
    Author     : Randy
--%>

<%@include file="template/pagetop.jsp" %>

<script>
    selectedItems='';
    function addItemToList(what) {
      if(what.checked) { selectedItems += "&" + what.name + "=Y"; }
      if(!what.checked) {
        fieldName="&"+what.name+"=Y";
        i=selectedItems.indexOf(fieldName);
        j=i+fieldName.length;
        k=selectedItems.length;
        selectedItems=selectedItems.substring(0,i)+selectedItems.substring(j,k);
      }

    }
    function showReceipt(printOption,detail) {
      windowUrl="printreceipt.jsp?printOption=" + printOption+"&detail="+detail+selectedItems;
      window.open(windowUrl,"statement","address=no,toolbar=yes,scrollbars=yes");
    }

    function showDeductableDetails(what,visitId) {
        var rowId=what.id.substr(3);
        var obj=document.getElementById('rowId'+rowId);

        if(what.innerHTML == "[-]") {
            obj.style.visibility="hidden";
            obj.style.display="none";
            what.innerHTML="[+]"
        } else {
            obj.style.visibility="visible";
            obj.style.display="";
            what.innerHTML="[-]";
            if(obj.innerHTML.trim() == '&nbsp;&nbsp;') {
                var url="ajax/getdeductabledetails.jsp?id="+visitId+"&sid="+Math.random();
                $.ajax({
                    url: url,
                    success: function(data){
                        $(obj).html(data);
                    },
                    error: function() {
                        alert("There was a problem processing the request");
                    }
                });
            }
        }
    }
</script>
<%
try {
// Set this as the parent location
    if(patient.next()) {

        String myQuery="SELECT medications.id, name, quantity, frequency from medications left join rwcatalog.frequency f on medications.frequency=f.id where patientid=" + patient.getId() + " order by name";

        String title = "Medications";
        String url = "medication_d.jsp";

    // Create an RWFiltered List object
        RWFilteredList lst = new RWFilteredList(io);
        RWHtmlTable htmTb  = new RWHtmlTable("700", "0");
        RWHtmlForm frm     = new RWHtmlForm();
        RWFieldSet fldSet  = new RWFieldSet();

        htmTb.replaceNewLineChar(false);

    // Set special attributes on the filtered list object
        String [] cw       = {"0", "200", "75", "100"};
        String [] ch       = {"", "Name", "Quantity", "Frequency" };

        lst.setTableWidth("375");
        lst.setTableBorder("0");
        lst.setCellPadding("0");
        lst.setAlternatingRowColors("#ffffff", "#cccccc");
        lst.setRoundedHeadings("#030089", "");

        lst.setUrlField(0);

        lst.setColumnUrl(1, url, 0);

        lst.setRowUrl(url);
        lst.setShowRowUrl(false);
        lst.setOnClickAction("window.open");
        lst.setOnClickOption("\"" + title + "\",\"width=400,height=250,scrollbars=no,left=100,top=100,\"");
        lst.setOnClickStyle("style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
        lst.setShowComboBoxes(false);
        lst.setUseCatalog(false);
        lst.setDivHeight(250);
        lst.setColumnWidth(cw);

    // Show the filtered list
        out.print("<title>" + title + "</title>");

        try {
            out.print("<fieldset style=\"width: 750px; height: 320px;\">\n");
            out.print("<legend style='font-size: 12px; font-weight: bold;' align=center>" + title + " for " + patient.getPatientName() + "</legend>\n");
            out.print(lst.getHtml(request, myQuery, ch));
            out.print("</fieldset>\n");

            out.print("<input type=\"button\" class=\"button\" onClick=\"window.open('medications_d.jsp?id=0','Medication','width=400,height=250,scrollbars=no,left=100,top=100,')\" value=\"add a medication\">");
        } catch (Exception e) {
        }
    } else {
        out.print("Patient information not set");
    }


    session.setAttribute("parentLocation", self+"?"+parmsPassed);

} catch (Exception e) {
    out.print(e);
}
%>
<%@ include file="template/pagebottom.jsp" %>