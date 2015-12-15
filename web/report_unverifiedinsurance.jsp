<%-- 
    Document   : report_unverifiedinsurance
    Created on : Sep 5, 2014, 12:02:25 PM
    Author     : Randy
--%>
<%@page import="tools.RWFilteredList"%>
<%@include file="template/pagetop.jsp" %>
<!-- <script src="js/clienthint.js"></script>  -->
<script type="text/javascript" src="js/dFilter.js"></script>
<script>
    var currentFieldValue = "";
    
    function printReport() {
      window.open('printreport.jsp','print','height=300,width=640,scrollbars=yes,resizable');
    }

    function setInsuranceVerified(patientId,recordId,what) {
        url = "ajax/setinsuranceverified.jsp?patientId="+patientId+"&id="+recordId;
        $.ajax({
            type: "POST",
            url: url,
            success: function(data) {
                what.disabled = "disabled";
                alert("Billing has been enabled for this patient");
            },
            complete: function(data) {

            }

        });
    }
    
    function showBillingInformation(id) {
        showInputForm(event,"ajax/showincompletebillinginformation.jsp",id,0,txtHint);
        objectName="txtHint";

        if (id.length===0) {
          $(txtHint).html('');
          return;
        }

        url="ajax/showincompletebillinginformation.jsp?id="+id+"&sid="+Math.random();
        url=url+"&sid="+Math.random();

        $.ajax({
            url: url,
            success: function(data){
                $(txtHint).html(data);
                setFieldAttributes();
                showHide(txtHint,'SHOW');
            },
            error: function() {
                alert("There was a problem processing the request");
            }
        });        
    }


    function closeMe() {
        document.getElementById("txtHint").innerHTML='';            
        txtHint.style.visibility="hidden";
        txtHint.style.display="none";
        hideShadow();
        enablePageScripts=true;
    }
    
    function setCurrentValue(what) {
        currentFieldValue = what.value;
    }
    
    function saveData(what,id) {
        if(what.value !== currentFieldValue) {
            url = "ajax/setfielddata.jsp?fieldName="+what.name+"&id="+id+"&fieldValue="+what.value;
            $.ajax({
                type: "POST",
                url: url,
                success: function(data) {

                },
                complete: function(data) {
                    if(what.value !== '') {
                        $(what).css("background-color","#ffffff");
                        $(what).attr("disabled","true");
                        $(what).attr("readonly","true");
                        if($("#accountnumber").val() === $("#guarantornumber").val()) {
                            $("#guarantor"+what.name).val(what.value);
                            $("#guarantor"+what.name).css("background-color","#ffffff");
                            $("#guarantor"+what.name).attr("disabled","true");
                            $("#guarantor"+what.name).attr("readonly","true");
                        }
                    }
                }

            });
        }
    }
    
    function setAttributes(what,id) {
        if(what.value === '') {
            $(what).css("background-color","red");
            $(what).css("font-weight","bold");
        }
    }
    
    function performCheck() {
        url = "ajax/checkforbillingissues.jsp";
        $.ajax({
            type: "POST",
            url: url,
            success: function(data) {
                location.href="report_unverifiedinsurance.jsp";
            },
            complete: function(data) {

            }

        });
    }
    
    function setFieldAttributes() {
        $( "input" ).each(function( index ) {
            console.log( index + ": " + $( this ).val() + " - " + this.name + ' - ' + this.type );
            if($(this).attr('name') !== 'srchString') {
                if($(this).val() === '') { 
                    $(this).css("background-color","red"); 
                    $(this).attr("disabled",false);
                    $(this).attr("readonly",false);
                } else  if((this.name === 'maskphonenumber' || this.name === 'maskguarantorphone') && $(this).val() === '0') {
                    $(this).css("background-color","red"); 
                    $(this).attr("disabled",false);
                    $(this).attr("readonly",false);            
                } else if (this.type === 'text'){
                    $(this).attr("disabled",true);
                    $(this).attr("readonly",true);            
                }
            }
        }); 
        $( "textarea" ).each(function( index ) {
            console.log( index + ": " + $( this ).val() + " - " + this.name );
            if($(this).val() === '') { 
                $(this).css("background-color","red"); 
                $(this).attr("disabled",false);
                $(this).attr("readonly",false);
            } else {
                $(this).attr("disabled",true);
                $(this).attr("readonly",true);
            }
        });        
    }
</script>
<%@ include file="ajax/ajaxstuff.jsp" %>
<%
    out.print("<input type=\"button\" value=\"Check for new billing issues\" class=\"button\" onClick=\"performCheck()\">");

    RWHtmlTable htmTb = new RWHtmlTable("800","0");
    RWFilteredList lst = new RWFilteredList(io);

    String [] cw = { "0", "75", "75", "100", "100", "100", "50","80", "0", "0" };
    String [] ch = { "", "Last Name", "First Name", "Condition", "Payer Number", "Payer Name", "DX Codes", "Ok to Bill", "", "" };
    String myQuery = "CALL rwcatalog.prGetUnverifiedInsuranceList('" + databaseName + "')";

    lst.setAlternatingRowColors("#e0e0e0", "#cccccc");
    lst.setColumnWidth(cw);
    lst.setFormMethod("POST");
    lst.setDivHeight(300);
    lst.setTableWidth("600");
    lst.setTableBorder("0");
    lst.setUseCatalog(true);

    lst.setColumnFilterState(1, false);
    lst.setColumnFilterState(2, false);
    lst.setColumnFilterState(3, false);
    lst.setColumnFilterState(4, true);
    lst.setColumnFilterState(5, false);
    
    lst.setColumnWidth(8, "0");
    lst.setColumnWidth(9, "0");

    lst.setColumnAlignment(6, "CENTER");
    lst.setColumnAlignment(7, "CENTER");

    lst.setUrlField(0);

    lst.setOnClickAction(1, "javascript:enableMouseOut=false;ajaxComplete=false;showBillingInformation(##idColumn##) style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");
    lst.setOnClickAction(2, "javascript:enableMouseOut=false;ajaxComplete=false;showBillingInformation(##idColumn##) style=\"cursor: pointer; color: #2c57a7; font-weight: bold;\"");

    lst.setOnMouseOutAction(1, "showHide(txtHint,'HIDE')");
    lst.setOnMouseOutAction(2, "showHide(txtHint,'HIDE')");

    out.print(htmTb.startTable());
    out.print(htmTb.startRow("height=30"));
    out.print(htmTb.addCell("Patients With Incomplete Billing Information", htmTb.CENTER, "style='font-size: 16; font-weight: bold;'"));
    out.print(htmTb.endRow());
    out.print(htmTb.endTable());

    out.print(lst.getHtml(request, myQuery, ch));

    out.print("<input type=button class=button value=print onClick=printReport() name=\"printBtn\" id=\"printBtn\">");

    session.setAttribute("reportToPrint", lst);
    session.setAttribute("parentLocation", "None");
%>

<%@ include file="template/pagebottom.jsp" %>
