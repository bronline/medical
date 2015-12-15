<%-- 
    Document   : showincompletebillinginformation
    Created on : Sep 12, 2014, 12:15:29 PM
    Author     : Randy
--%>
<%@include file="sessioninfo.jsp" %>
<%
    String id=request.getParameter("id");
    String chargeId = "";
    String descWidth = "250";
    String tableWidth = "400";
    boolean showDetailsOnly=false;

    
    ResultSet piRs=io.opnRS("CALL rwcatalog.prGetPayerForCondition('" + io.getLibraryName() + "'," + id + ")");
    if(piRs.next()) {
        ResultSet lRs=io.opnRS("call rwcatalog.prCheckBillingInformation('" + io.getLibraryName() + "'," + piRs.getString("patientid") + "," + piRs.getString("providerid") + ")");
        RWHtmlTable htmTb=new RWHtmlTable(tableWidth,"0");
        RWInputForm frm = new RWInputForm(lRs);
        
//        frm.setFormItemsDisabled();
        
        
        Symptoms symptoms = new Symptoms(io);

        out.print("<div align=\"center\">\n");
        lRs.beforeFirst();
        if(lRs.next()) {
            out.print("<v:roundrect style=\"width: 950; height: 400; text-valign: middle; text-align: center;\" arcsize=\".05\">");
            out.print("<div align=\"right\"><b style=\"cursor: pointer;\" onClick=\"closeMe()\">close</b></div>");
            out.print("<div align=\"left\" style=\"margin-left: 5%; width: 90%;\">");
// Patient Information            
            out.print("<div style=\"float: left; width: 48%;\">");
            out.print(htmTb.startTable("425"));
            frm.setCustomFieldLabel(3, "Patient Account Number:");
            frm.setCustomInputType(3, "TEXTBOX");           
            out.print(frm.getInputItem("accountNumber", "style=\"width: 50px;\" READONLY DISABLED"));
            frm.setCustomFieldLabel(4, "Patient First Name:");
            frm.setCustomInputType(4, "TEXTBOX");
            out.print(frm.getInputItem("firstname", "onClick=\"setCurrentValue(this)\" onClick=\"setCurrentValue(this)\" onBlur=\"saveData(this," + lRs.getString("patientid") + ")\""));
            frm.setCustomFieldLabel(5, "Patient Last Name:");
            frm.setCustomInputType(5, "TEXTBOX");
            out.print(frm.getInputItem("lastname", "onClick=\"setCurrentValue(this)\" onBlur=\"saveData(this," + lRs.getString("patientid") + ")\""));
            frm.setCustomFieldLabel(6, "Patient Home Address:");
            frm.setCustomInputType(6, "TEXTAREA");            
            out.print(frm.getInputItem("address", "onClick=\"setCurrentValue(this)\" onBlur=\"saveData(this," + lRs.getString("patientid") + ")\""));
            frm.setCustomFieldLabel(7, "Patient City:");
            frm.setCustomInputType(7, "TEXTBOX");            
            out.print(frm.getInputItem("city", ""));
            frm.setCustomFieldLabel(8, "Patient State:");
            frm.setCustomInputType(8, "TEXTBOX");            
            out.print(frm.getInputItem("state", "onClick=\"setCurrentValue(this)\" onBlur=\"saveData(this," + lRs.getString("patientid") + ")\""));
            frm.setCustomFieldLabel(9, "Patient Zip Code:");
            frm.setCustomInputType(9, "TEXTBOX");            
            out.print(frm.getInputItem("zipcode", "onClick=\"setCurrentValue(this)\" onBlur=\"saveData(this," + lRs.getString("patientid") + ")\""));
            frm.setCustomFieldLabel(10, "Patient Phone Number:");
            frm.setCustomInputType(10, "PHONENUMBER");            
            out.print(frm.getInputItem("phonenumber", "onClick=\"setCurrentValue(this)\" onBlur=\"saveData(this," + lRs.getString("patientid") + ")\""));
            frm.setCustomFieldLabel(11, "Patient DOB:");
            frm.setCustomInputType(11, "DATE");            
            out.print(frm.getInputItem("dob", "onClick=\"setCurrentValue(this)\" onBlur=\"saveData(this," + lRs.getString("patientid") + ")\""));            
            out.print(htmTb.endTable());
            out.print("</div>");
// Guarantor Information            
            out.print("<div style=\"float: left; width: 48%;\">");
            out.print(htmTb.startTable("425"));
            frm.setCustomFieldLabel(22, "Guarantor Account Number:");
            frm.setCustomInputType(22, "TEXTBOX");           
            out.print(frm.getInputItem("guarantornumber", "style=\"width: 50px;\" READONLY DISABLED"));
            frm.setCustomFieldLabel(23, "Guarantor Name:");
            frm.setCustomInputType(23, "TEXTBOX");
            out.print(frm.getInputItem("guarantorname", "onClick=\"setCurrentValue(this)\" onBlur=\"saveData(this," + lRs.getString("ptinsuranceid") + ")\""));
            frm.setCustomFieldLabel(24, "Guarantor Home Address:");
            frm.setCustomInputType(24, "TEXTAREA");            
            out.print(frm.getInputItem("guarantoraddress", "onClick=\"setCurrentValue(this)\" onBlur=\"saveData(this," + lRs.getString("ptinsuranceid") + ")\""));
            frm.setCustomFieldLabel(25, "Guarantor City:");
            frm.setCustomInputType(25, "TEXTBOX");            
            out.print(frm.getInputItem("guarantorcity", "onClick=\"setCurrentValue(this)\" onBlur=\"saveData(this," + lRs.getString("ptinsuranceid") + ")\""));
            frm.setCustomFieldLabel(26, "Guarantor State:");
            frm.setCustomInputType(26, "TEXTBOX");            
            out.print(frm.getInputItem("guarantorstate", "onClick=\"setCurrentValue(this)\" onBlur=\"saveData(this," + lRs.getString("ptinsuranceid") + ")\""));
            frm.setCustomFieldLabel(27, "Guarantor Zip Code:");
            frm.setCustomInputType(27, "TEXTBOX");            
            out.print(frm.getInputItem("guarantorzipcode", "onClick=\"setCurrentValue(this)\" onBlur=\"saveData(this," + lRs.getString("ptinsuranceid") + ")\""));
            frm.setCustomFieldLabel(28, "Guarantor Phone Number:");
            frm.setCustomInputType(28, "PHONENUMBER");            
            out.print(frm.getInputItem("guarantorphone", "onClick=\"setCurrentValue(this)\" onBlur=\"saveData(this," + lRs.getString("ptinsuranceid") + ")\""));            
            frm.setCustomFieldLabel(29, "Guarantor DOB:");
            frm.setCustomInputType(29, "DATE");            
            out.print(frm.getInputItem("guarantordob", "onClick=\"setCurrentValue(this)\" onBlur=\"saveData(this," + lRs.getString("ptinsuranceid") + ")\""));            
            out.print(htmTb.endTable());
            out.print("</div><br/>");
            
            out.print("<div style=\"float: left; width: 100%;\"><hr></div>");
// Payer Information            
            out.print("<div style=\"float: left; width: 48%;\">");
            out.print(htmTb.startTable("425"));
            frm.setCustomFieldLabel(30, "Payer Name:");
            frm.setCustomInputType(30, "TEXTBOX");           
            out.print(frm.getInputItem("payername", "style=\"width: 250px;\" READONLY DISABLED"));
            frm.setCustomFieldLabel(12, "Payer Number:");
            frm.setCustomInputType(12, "TEXTBOX");
            out.print(frm.getInputItem("providernumber", "onClick=\"setCurrentValue(this)\" onBlur=\"saveData(this," + lRs.getString("ptinsuranceid") + ")\""));
            frm.setCustomFieldLabel(16, "Insurance Effective:");
            frm.setCustomInputType(16, "DATE");            
            out.print(frm.getInputItem("insuranceeffective"));
            frm.setCustomFieldLabel(17, "Insurance Benefits Date:");
            frm.setCustomInputType(17, "DATE");            
            out.print(frm.getInputItem("insurancebenefitsdate"));
            frm.setCustomFieldLabel(18, "Insurance Term Date:");
            frm.setCustomInputType(18, "DATE");            
            out.print(frm.getInputItem("insurancetermdate"));
            out.print(htmTb.endTable());
            out.print("</div>");
//DX Codes
            ResultSet sRs = io.opnRS("select a.id, sequence, concat(code, ' - ', description) as description, symptom from patientsymptoms a join diagnosiscodes b on a.diagnosisid=b.id where conditionid=" + piRs.getString("conditionId") + " order by sequence");
            out.print("<div align=\"center\" style=\"float: left; width: 48%;\">");
            if(sRs.next()) {
                sRs.beforeFirst();
                out.print(htmTb.startTable());
                out.print(htmTb.roundedTop(1,"","#030089",""));
                out.print(htmTb.startRow());
                out.print(htmTb.headingCell("Diagnosis",""));
                out.print(htmTb.endRow());
                out.print(htmTb.endTable());            

                out.print("<div style=\"width: 100%; height: 85;  overflow: auto; text-align: left;\">\n");

                out.print(htmTb.startTable("94%", "0"));

                while(sRs.next()) {
                    out.print(htmTb.startRow());
                    out.print(htmTb.addCell(sRs.getString("description").trim(), htmTb.LEFT, "", ""));
                    out.print(htmTb.endRow());
                }
                out.print(htmTb.endTable());
            } else {
                out.print("<b>Missing Diagnosis Codes</b>");
            }

            out.print("</div>");
            
            out.print("</div><br/>");
            
            out.print("</div>\n");
            out.print("</v:roundrect>");

        }

        out.print("<br></div>\n");

        lRs.close();
    }
    piRs.close();
%>
<script type="text/javascript">
    setFieldAttributes();
</script>
<%@include file="cleanup.jsp" %>
