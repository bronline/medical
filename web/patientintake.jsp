<%-- 
    Document   : patientintake
    Created on : Sep 4, 2013, 12:52:54 PM
    Author     : Randy
--%>
<%@include file="globalvariables.jsp" %>
<%@ include file="ajax/ajaxstuff.jsp" %>
<style>
    .patientName { font-size: 125%; font-weight: bold; }

    .intakeBubble {
        display: none;
        float: left;
        position: relative;
        top: 10px;
        left: 0px;
    }
    
    .mainwrapper {
        width: 100%
    }

    .contentwrapper {
        width: 600px;
    }
/*
        background-color: #a6c3f8;
        height: 300px;
        width: 500px;
        text-align: left;
        z-index: 9999;
        padding: 5px;
        border-radius: 10px;
*/
</style>
<script type="text/javascript">
    function saveAccountInformation(formId, patientId) {
        var url = "ajax/saveaccountinformation.jsp";
        var poststr = "recordId=" + patientId;

        dataString = $(formId).serialize();

        $.ajax({
            type: "POST",
            url: url,
            data: poststr + "&" + dataString,
            success: function(data) {
                alert(data);
            },
            error: function() {
                alert("There was a problem with the request");
            },
            complete: function() {

            }
        });
    }

    function editInsuranceInformation(patientId,rcd) {
        var url = "ajax/getpatientinsurance.jsp?id=" + rcd + "&patientId=" + patientId;

        $.ajax({
            type: "POST",
            url: url,
            success: function(data) {
                $('#insuranceList').css('display','none');
                $('#intakeBubble').html(data);
                $('#intakeBubble').css('visibility','visible');
                $('#intakeBubble').css('display','');

                $('#benefitNotesButton').css('display','none');
                $('#authorizationInformationButton').css('display','none');
                $('#guarantorInformationButton').css('display','none');
            },
            error: function() {
                alert("There was a problem with the request");
            },
            complete: function() {

            }
        });

    }
    
    function guarantorStatusChange(what) {
        alert($('#relationshipid option:selected').val());
        if($('#relationshipid option:selected').val()=='1') {
            $('#guarantorInformationContent').css('display','none');
        } else {
            $('#guarantorInformationContent').css('display','');
        }
    }

    function saveInsuranceInformation() {
        var url = "ajax/saveinsuranceinformation.jsp";
        var poststr = "sid=5";

        dataString = $("#patientInsuranceForm").serialize();

        $.ajax({
            type: "POST",
            url: url,
            data: poststr + "&" + dataString,
            success: function(data) {
                alert(data);
            },
            error: function() {
                alert("There was a problem with the request");
            },
            complete: function() {

            }
        });
    }

    function closeInsuranceBubble() {
        $('#insuranceList').css('display','');
        $('#intakeBubble').html('');
        $('#intakeBubble').css('display','none');
    }
</script>
<script type="text/javascript" src="js/accordian.js"></script>
<body onLoad="loadMask()">

<%
    RWHtmlTable htmTb = new RWHtmlTable("500", "0");
    RWInputForm frm = new RWInputForm(patient);
    htmTb.replaceNewLineChar(false);
    frm.setDftTextBoxSize("12");
    frm.setDftTextAreaCols("41");
    frm.setDftTextAreaRows("3");
    frm.formItemOnOneRow = false;
    frm.setLabelPosition(frm.LABEL_ON_BOTTOM);

    out.print("<div align=\"center\" class=\"mainwrapper\">");
    out.print("<div align=\"left\" class=\"contentwrapper\">");
    out.print("<div align=\"left\" class=\"patientName\" style=\"float: left; width: 500px;\">" + patient.getString("firstname") + " " + patient.getString("lastname") + "</div>");

    out.print("<div align=\"left\" style=\"width: 500px; float: left;\">"); // main wrapper

    out.print("<div class=\"accordionButton\">Address Information</div>");
    out.print("<div class=\"accordionContent\" style=\"display: none; background-color: #ffffff;\">");

    out.print("<form action=\"method\" name=\"addressInformationForm\" id=\"addressInformationForm\">");

    out.print(htmTb.startTable("350"));

    out.print(htmTb.startRow());
    out.print(htmTb.addCell(frm.getInputItem("address"), "colspan=3"));
    out.print(htmTb.endRow());

    out.print(htmTb.startRow());
    out.print(htmTb.addCell(frm.getInputItem("city", "style=\"width: 125px;\"")));
    out.print(htmTb.addCell(" " + frm.getInputItem("state")));
    out.print(htmTb.addCell(frm.getInputItem("zipcode")));
    out.print(htmTb.endRow());

    out.print(htmTb.endTable());
    
    out.print(frm.buttonObject("button", "save", "class=\"button\" onClick=\"javascript:saveAccountInformation('#addressInformationForm',"  + patient.getId() + ")\"", "aiSaveBtn"));

    out.print("</form>"); // End of addresss information form

    out.print("</div>"); // end address wrapper

    out.print("<div class=\"accordionButton\">Contact Information</div>");
    out.print("<div class=\"accordionContent\" style=\"display: none; background-color: #ffffff;\">");
    frm.formItemOnOneRow=true;
    frm.setLabelPosition(frm.LABEL_ON_LEFT);

    out.print("<form action=\"method\" name=\"contactInformationForm\" id=\"contactInformationForm\">");
    out.print(htmTb.startTable("350"));
    out.print(frm.getInputItem("nickname"));

    try {
        if(patient.getString("billingaccount") != null && !patient.getString("billingaccount").equals("")) {
            // out.print(getBillingAccountContact());
        }
    } catch (Exception e) {
    }

    out.print(frm.getInputItem("homephone", "style=\"width: 125px;\""));
    out.print(htmTb.startRow());
    out.print(htmTb.addCell("<b>Work Phone</b>"));
    out.print(htmTb.startCell(htmTb.LEFT));
    out.print("<table cellspacing='0' cellpadding='0' border='0'><tr>");
    out.print(htmTb.addCell(frm.getInputItemOnly("workphone", "style=\"width: 125px;\"")));
    out.print(htmTb.addCell("&nbsp;&nbsp;<b>ext.</b> "+frm.getInputItemOnly("workext","style='width: 40px;'") + "</tr></table>"));
    out.print(htmTb.endCell());
    out.print(htmTb.endRow());
    //out.print(frm.getInputItem("workphone"));
    out.print(frm.getInputItem("cellphone", "style=\"width: 125px;\""));
    out.print(frm.getInputItem("email", "style=\"width: 200px;\""));
    out.print(frm.getInputItem("cardnumber"));
    out.print(frm.getInputItem("preferredcontact"));
    out.print(frm.getInputItem("useemail"));

    out.print(htmTb.endTable());
    out.print("</form>");

    out.print(frm.buttonObject("button", "save", "class=\"button\" onClick=\"javascript:saveAccountInformation('#contactInformationForm',"  + patient.getId() + ")\"", "ciSaveBtn"));

    out.print("</div>"); // end contact wrapper

    out.print("<div class=\"accordionButton\">Demographics</div>");
    out.print("<div class=\"accordionContent\" style=\"display: none; background-color: #ffffff;\">");

    htmTb.replaceNewLineChar(false);
    frm.setDftTextBoxSize("15");
    frm.formItemOnOneRow = false;
    frm.setRBItemOnOneRow(true);
    frm.setLabelBold(true);
    frm.setLabelPosition(frm.LABEL_ON_LEFT);
    frm.setRbPosLeft();
    htmTb.setWidth("100%");

    out.print("<form action=\"method\" name=\"demographicsForm\" id=\"demographicsForm\">");

    out.print(htmTb.startTable());
    out.print(htmTb.startRow());
    out.print(htmTb.startCell("colspan=3"));
    out.print(htmTb.startTable());
    out.print(htmTb.startRow());
    out.print(frm.getInputItem("gender"));
    out.print(htmTb.endRow());
    out.print(htmTb.endTable());
    out.print(htmTb.endCell());
    out.print(htmTb.endRow());
    out.print(htmTb.startRow());
    out.print(htmTb.startCell("colspan=3"));
    out.print(htmTb.startTable("100%"));
    out.print(htmTb.startRow());
    out.print(htmTb.addCell("<b>Marital Status</b>","width=126"));
    out.print(htmTb.addCell(frm.getInputItemOnly("maritalstatus"),"colspan=2"));
    out.print(htmTb.endRow());
    out.print(htmTb.endTable());
    out.print(htmTb.endCell());
    out.print(htmTb.endRow());
    out.print(htmTb.startRow());

    out.print(htmTb.addCell("<b>DOB</b>", "width=126"));
    out.print(htmTb.addCell(frm.getInputItemOnly("dob",""), "width=85px"));
    if(patient.getRow() !=0) {
        out.print(htmTb.addCell("Age: " + patient.getAge(patient.getDate("dob")),htmTb.LEFT, "width=\"189px\" style=\"padding-top: 3px;\""));
    } else {
        out.print(htmTb.addCell(""));
    }
    out.print(htmTb.endRow());
    out.print(htmTb.endTable());
    frm.setDftTextBoxSize("30");
    out.print(htmTb.startTable());
    if(env.getBoolean("showssn")) {
        out.print(htmTb.startRow());
        out.print(frm.getInputItem("ssn"));
        out.print(htmTb.endRow());
    }
    out.print(htmTb.startRow());
    out.print(frm.getInputItem("referredby", "onChange=checkForNew(this,'referalsource.jsp')"));
    out.print(htmTb.endRow());
    out.print(htmTb.startRow());
    out.print(frm.getInputItem("occupationid", "onChange=checkForNew(this,'occupations.jsp')"));
    out.print(htmTb.endRow());
    out.print(htmTb.startRow());
    out.print(frm.getInputItem("employer", "onChange=checkForNew(this,'employers.jsp')"));
    out.print(htmTb.endRow());
    out.print(htmTb.startRow());
    out.print(htmTb.startCell(htmTb.LEFT, "height=3px colspan=2"));
    out.print(htmTb.endCell());
    out.print(htmTb.endRow());

    out.print(htmTb.endTable());

    out.print("</form>");

    out.print(frm.buttonObject("button", "save", "class=\"button\" onClick=\"javascript:saveAccountInformation('#demographicsForm',"  + patient.getId() + ")\"", "diSaveBtn"));
    out.print("</div>");// end demographics wrapper

    out.print("<div class=\"accordionButton\">Insurance Information</div>");
    out.print("<div class=\"accordionContent\" id=\"insuranceInformationContent\" style=\"display: none; background-color: #ffffff;\">");

    out.print("<div id=\"insuranceList\" style=\"width: 475px;\">");
    PatientInsurance pi = new PatientInsurance(io);
    pi.setPatientId(patient.getId());

    out.print(htmTb.startTable("100%", "0"));
    out.print(htmTb.roundedTop(5, "", "#030089", "insurancedivision"));
    // Display the heading
    out.print(htmTb.startRow());
    out.print(htmTb.headingCell("", htmTb.LEFT, "width=5%"));
    out.print(htmTb.headingCell("Payer", htmTb.LEFT, "width=35%"));
    out.print(htmTb.headingCell("Phone", htmTb.LEFT, "width=20%"));
    out.print(htmTb.headingCell("Insured's Id", htmTb.LEFT, "width=20%"));
    out.print(htmTb.headingCell("Group Number", htmTb.LEFT, "width=20%"));
    //        out.print(htmTb.headingCell("Relationship", htmTb.LEFT, "10%"));
    out.print(htmTb.endRow());
    //  End the table for the Insurance heading
    out.print(htmTb.endTable());
    out.print(pi.getPatientInsuranceList(patient.getId(), "onClick=\"editInsuranceInformation(" + patient.getId() + ",",")\"","style=\"cursor: pointer;\""));
    out.print("</div>"); // end of insuranceList
/*
    out.print("<form action=\"method\" name=\"insuranceForm\" id=\"insuranceForm\">");

    out.print(frm.buttonObject("button", "save", "class=\"button\" onClick=\"javascript:saveInsuranceInformation('#insuranceForm',"  + patient.getId() + ")\"", "iiSaveBtn"));
    out.print("</form>");
*/
    out.print("</div>");  // end of Insurance Information
    out.print("<div id=\"intakeBubble\" style=\"display: none; float: left; position: relative; top: 10px; left: 0px;\">");
    out.print("</div>");

    out.print("</div>");  

    out.print("</div>"); // end content wrapper
    out.print("</div>"); // end main wrapper

%>
</body>