<%-- 
    Document   : paymentworksheet
    Created on : Jan 22, 2008, 9:09:16 PM
    Author     : Randy
--%>
<%@ include file="globalvariables.jsp" %>
<script>
  function submitForm(action) {
    var frmA=document.forms["worksheet"]
    frmA.method="POST"
    frmA.action=action
    frmA.submit()
  }  

    function calculatePlan() {
        var coveredVisits=worksheet.visitsCovered.value-worksheet.visitsUsed.value;
        if (coveredVisits < 0) { coveredVisits=0 }
        
        worksheet.visitsToInsurance.value=coveredVisits;
        worksheet.nonCoveredVisits.value=worksheet.plannedVisits.value-coveredVisits;

        if (worksheet.deductible.value*1 < coveredVisits*(worksheet.insurancePerVisit.value*1+worksheet.patientPortionWhileCovered.value*1)) {
            worksheet.deductibleOnCoveredVisits.value=worksheet.deductible.value;
        } else {
            worksheet.deductibleOnCoveredVisits.value=coveredVisits*(worksheet.insurancePerVisit.value*1+worksheet.patientPortionWhileCovered.value*1);
        }

        worksheet.discountedPatientPortionWhileCovered.value=worksheet.patientPortionWhileCovered.value * (1-(worksheet.discountPct.value/100));
        worksheet.discountedPatientPortionAfterExpires.value=worksheet.patientPortionAfterExpires.value * (1-(worksheet.discountPct.value/100));
        var discountedPatientPortionWhileCovered=worksheet.discountedPatientPortionWhileCovered.value*1;
        var discountedPatientPortionAfterExpires=worksheet.discountedPatientPortionAfterExpires.value*1;
        worksheet.discountedPatientPortionWhileCovered.value=discountedPatientPortionWhileCovered.toFixed(2);
        worksheet.discountedPatientPortionAfterExpires.value=discountedPatientPortionAfterExpires.toFixed(2);

        worksheet.insuranceTotal.value=(coveredVisits*worksheet.insurancePerVisit.value)-worksheet.deductibleOnCoveredVisits.value;

        worksheet.patientAmount.value=((worksheet.deductibleOnCoveredVisits.value*1)+(worksheet.visitsToInsurance.value*worksheet.discountedPatientPortionWhileCovered.value)+(worksheet.nonCoveredVisits.value*worksheet.discountedPatientPortionAfterExpires.value))*1;
//        worksheet.patientAmount.value=worksheet.patientAmount.value * (1-(worksheet.discountPct.value/100));
        worksheet.totalPlan.value=(worksheet.insuranceTotal.value*1)+(worksheet.patientAmount.value*1);
        worksheet.oneTimePayment.value=worksheet.patientAmount.value;
        worksheet.quarterlyPayment.value=worksheet.patientAmount.value/4;
        worksheet.monthlyPayment.value=worksheet.patientAmount.value/12;
        
        if(isNaN(worksheet.totalPlan.value/worksheet.plannedVisits.value)) {
            worksheet.revenuePerVisit.value=0;
        } else {
            worksheet.revenuePerVisit.value=worksheet.totalPlan.value/worksheet.plannedVisits.value;
        }
        
        var insuranceTotal=worksheet.insuranceTotal.value*1;
        var patientAmount=worksheet.patientAmount.value*1;
        var totalPlan=worksheet.totalPlan.value*1;
        var oneTimePayment=worksheet.oneTimePayment.value*1;
        var quarterlyPayment=worksheet.quarterlyPayment.value*1;
        var monthlyPayment=worksheet.monthlyPayment.value*1;
        var revenuePerVisit=worksheet.revenuePerVisit.value*1;
        
        if(insuranceTotal<0) { insuranceTotal=0; }
        
        worksheet.insuranceTotal.value=insuranceTotal.toFixed(2);
        worksheet.patientAmount.value=patientAmount.toFixed(2);
        worksheet.totalPlan.value=totalPlan.toFixed(2);
        worksheet.oneTimePayment.value=oneTimePayment.toFixed(2);
        worksheet.quarterlyPayment.value=quarterlyPayment.toFixed(2);
        worksheet.monthlyPayment.value=monthlyPayment.toFixed(2);
        worksheet.revenuePerVisit.value=revenuePerVisit.toFixed(2);
    }
</script>
<body onLoad=calculatePlan()>
<%
    String id = request.getParameter("id");
    ResultSet lRs = io.opnRS("select * from paymentschedule where id=" + id);
    if (lRs.next()) {
        patient.setId(lRs.getInt("patientId"));
    } else {
        patient.setId(0);
    }    
    lRs.beforeFirst();
    if (patient.next()) {
        String patientName=patient.getString("firstname") + " " + patient.getString("lastname");
        
        session.setAttribute("returnUrl", "");
        int plannedVisits = 0;
        int visitsCovered = 0;
        int visitsUsed = 0;
        int visitsToInsurance = 0;
        int nonCoveredVisits = 0;
        BigDecimal deductible = new BigDecimal(0.00);
        BigDecimal insurancePerVisit = new BigDecimal(0.00);
        BigDecimal patientPortionWhileCovered = new BigDecimal(0.00);
        BigDecimal patientPortionAfterExpires = new BigDecimal(0.00);
        int discountPct = 0;
        String sendChecked="";
        int patientId = patient.getId();
        int rcd = 0;
        String startDate="";

        if (lRs.next()) {
            out.print("<H1>"+patientName + " - " + lRs.getString("year") + "</H1>");
            rcd=lRs.getInt("id");
            startDate=Format.formatDate(lRs.getString("startdate"), "MM/dd/yyyy");
            plannedVisits=lRs.getInt("plannedVisits");
            visitsCovered=lRs.getInt("visitsCovered");
            visitsUsed=lRs.getInt("visitsUsed");
            visitsToInsurance=lRs.getInt("visitsToInsurance");
            deductible=lRs.getBigDecimal("deductible");
            insurancePerVisit=lRs.getBigDecimal("insurancePerVisit");
            patientPortionWhileCovered=lRs.getBigDecimal("patientPortionWhileCovered");
            patientPortionAfterExpires=lRs.getBigDecimal("patientPortionAfterExpires");
            discountPct=lRs.getInt("discountPct");
            if (lRs.getBoolean("createmessages")) { sendChecked="CHECKED"; }
        }
%>
    <form name=worksheet>
        <table>
            <tr>
                <td>
                    Plan Start Date&nbsp;&nbsp;<input type=TEXT name=startDate value="<%=startDate%>" maxlength=10 size=10 class=tBoxText  onFocus="javascript:vDateType='1'" onKeyDown="DateFormat(this,this.value,event,false,'1')" >
                    <image src="images/show-calendar.gif" onClick='var X=event.x; var Y=event.y; var action="datepicker.jsp?formName=worksheet&element=startDate&month=<%=startDate.substring(0,2)%>&year=<%=startDate.substring(6)%>&day=<%=startDate.substring(3,5)%>"; var options="width=190,height=111,left=" + X + ",top=" + Y + ","; window.open(action, "Date", options);' style="cursor: pointer;">
                    <br><br>
                </td>
            </tr>
            <tr>
                <td>
                    <fieldset style='width: 600; height: 130;'><legend>Insurance and Payment Information</legend>
                        <table>
                            <tr>
                                <td valign=top>
                                    
                                    <table>
                                        <tr><td>Planned visits in one year</td><td><input type=text value="<%=plannedVisits%>" class=tBoxText name=plannedVisits onblur=calculatePlan() value=0 style='text-align: right;' size=4 maxlength=4></td></tr>
                                        <tr><td>Total visits covered in one year (all providers)</td><td><input type=text value="<%=visitsCovered%>" class=tBoxText name=visitsCovered onblur=calculatePlan() value=0 style='text-align: right;' size=4 maxlength=4></td></tr>
                                        <tr><td>Visits used outside this plan</td><td><input type=text value="<%=visitsUsed%>" class=tBoxText name=visitsUsed onblur=calculatePlan() value=0 style='text-align: right;' size=4 maxlength=4></td></tr>
                                        <tr><td>Visits in this plan that should be sent to insurance</td><td><input type=text value="<%=visitsToInsurance%>" class=tBoxText name=visitsToInsurance READONLY disabled value=0 style='text-align: right; border: none;' size=4 maxlength=4></td></tr>
                                        <tr><td>Visits in this plan not to be sent to insurance</td><td><input type=text class=tBoxText name=nonCoveredVisits READONLY disabled value=0 style='text-align: right; border: none;' size=4 maxlength=4></td></tr>
                                        <tr><td>Deductible applied to insurance visits</td><td><input type=text class=tBoxText name=deductibleOnCoveredVisits READONLY disabled value=0 style='text-align: right; border: none;' size=4 maxlength=4></td></tr>
                                    </table>
                                    
                                </td>
                                <td valign=top>
                                    <table>        
                                        <tr><td>Remaining deductible</td><td><input type=text value="<%=deductible%>" class=tBoxText name=deductible onblur=calculatePlan() value=0 style='text-align: right;' size=6 maxlength=6></td></tr>
                                        <tr><td>Insurance pays per visit (once deductible is met)</td><td><input type=text value="<%=insurancePerVisit%>" class=tBoxText name=insurancePerVisit onblur=calculatePlan() value=0 style='text-align: right;' size=6 maxlength=6></td></tr>
                                        <tr><td>Patient portion per visit while covered</td><td><input type=text value="<%=patientPortionWhileCovered%>" class=tBoxText name=patientPortionWhileCovered onblur=calculatePlan() value=0 style='text-align: right;' size=6 maxlength=6></td><td><input type=text class=tBoxText name=discountedPatientPortionWhileCovered READONLY disabled value=0 style='text-align: right; border: none;' size=4 maxlength=4></td></tr>
                                        <tr><td>Patient portion after insurance expires</td><td><input type=text value="<%=patientPortionAfterExpires%>" class=tBoxText name=patientPortionAfterExpires onblur=calculatePlan() value=0 style='text-align: right;' size=6 maxlength=6></td><td><input type=text class=tBoxText name=discountedPatientPortionAfterExpires READONLY disabled value=0 style='text-align: right; border: none;' size=4 maxlength=4></td></tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </fieldset>
                </td>
            </tr>
            <tr>
                <td colspan=2>
                    <fieldset style='width: 600; height: 50;'><legend>Discounts and Revenue</legend>
                        <table>
                            <tr>
                                <td width=150>Discount percentage</td><td width=150><input type=text value="<%=discountPct%>" class=tBoxText name=discountPct onblur=calculatePlan() value=0 style='text-align: right;' size=6 maxlength=6>%</td>
                                <td>Revenue per visit for this patient</td><td><input type=text class=tBoxText name=revenuePerVisit READONLY disabled value=0 style='text-align: right; border: none;' size=6 maxlength=6></td>
                            </tr>
                        </table>
                    </fieldset>
                </td>
                
            </tr>
            <tr>
                <td colspan=2>
                    <fieldset style='width: 600; height: 75;'><legend>Totals and Payment Plan Information</legend>
                        <table>
                            <tr>
                                <td>Total insurance payments in plan</td><td><input type=text class=tBoxText name=insuranceTotal READONLY disabled value=0 style='text-align: right; border: none;' size=6 maxlength=6></td>
                                <td>Total patient payments in plan</td><td><input type=text class=tBoxText name=patientAmount READONLY disabled value=0 style='text-align: right; border: none;' size=6 maxlength=6></td>
                                <td>Total all payments for plan</td><td><input type=text class=tBoxText name=totalPlan READONLY disabled value=0 style='text-align: right; border: none;' size=6 maxlength=6></td>
                                
                            </tr>
                            
                            <tr>
                                <td>One time payment</td><td><input type=text class=tBoxText name=oneTimePayment READONLY disabled value=0 style='text-align: right; border: none;' size=6 maxlength=6></td>
                                <td>Quarterly payment</td><td><input type=text class=tBoxText name=quarterlyPayment READONLY disabled value=0 style='text-align: right; border: none;' size=6 maxlength=6></td>
                                <td>Monthly payment</td><td><input type=text class=tBoxText name=monthlyPayment READONLY disabled value=0 style='text-align: right; border: none;' size=6 maxlength=6></td>
                                
                            </tr>
                            
                            <tr>
                            <td>Create patient messages</td><td><input type=checkbox <%=sendChecked%> name=createMessages></td>
                            <td></td><td></td>
                            <td></td><td></td>
                        </table>
                    </fieldset>
                </td>
            </tr>
        </table>
        <br>
        <input type=button value="save" class=button onClick=submitForm('updaterecord.jsp?fileName=paymentschedule')>
        <input type=button value="delete" class=button onClick=submitForm('updaterecord.jsp?fileName=paymentschedule&delete=Y')>
        <input type=HIDDEN name=rcd value="<%=rcd%>" >
        <input type=HIDDEN name=patientId value="<%=patientId%>" >
    </form>
<%
    } else {
        out.print("Patient information not set");
    }
%>
</body>
