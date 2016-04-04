<%-- 
    Document   : showeligibilityinfo
    Created on : Mar 7, 2016, 1:43:32 PM
    Author     : Randy
--%>
<%@page import="com.pokitdok.utilities.eligibility.EligibilityResponse_New"%>

<%@include file="sessioninfo.jsp" %>
<style type="text/css">
ul{
    list-style: none;
    margin: 0;
    padding: 0;
}

li .list-item {
    padding-bottom: 15px;
}

span{
    
}
.left {
    float: left;
    width: 25%;
}
.right {
    float: right;
    width: 75%;
}

.left-aligned {
    text-align: left;
}

.item-heading {
    font-size: 11px;
    font-weight: bold;
    padding-bottom: 5px;
}

li .coverage-heading {
    font-size: 11px;
    font-weight: bold;
    padding-bottom: 5px;
}
.item-detail {
    font-size: 9px;
}
li .coverage-item {
    padding-bottom: 5px;
}
@media only screen and (max-width: 480px) {
    .left, .right {
/*        float: none;  */
        width: 100%;
        display:blocK;
    }
}

div .list-container {
    padding-bottom: 5px;
}

div .major-item {
    float: left;
    width: 98%;
    text-align: center;
    font-size: 14px;
    font-weight: bold;
    background-color: #909090;
}

.coinsurance-description {
    float: left;
    text-align: left;
    font-weight: bold;
    font-size: 11px;
    padding-left: 40px;
    width: 100%;
}

.limitation-description {
    float: left;
    text-align: left;
    font-weight: bold;
    font-size: 11px;
    padding-left: 40px;
    width: 100%;
}

div .copayment {
    float: left;
    width: 100%;
}

div .deductible {
    float: left;
    width: 100%;
}

div .coverage {
    float: left;
    width: 100%;
}

div .coinsurance {
    float: right;
    width: 100%;
}

.coinsurance-details {
    padding-bottom: 5px;
}

div .limitations {
    float: right;
    width: 100%;
}
</style>

<%
    ResultSet lRs = io.opnRS("CALL rwcatalog.prGetPrimaryPayer('" + io.getLibraryName() + "'," + patient.getId() + ")");

    if(lRs.next()) {
        try {
            String copaymentAmount = null;
            EligibilityResponse_New er = new EligibilityResponse_New(lRs.getString("jsonresponse"));
            HashMap<String, EligibilityResponse_New.CoinsuranceDetail>serviceMap = er.serviceMap;
            HashMap<String, EligibilityResponse_New.LimitationDetail> limitationMap = er.limitationMap;
            EligibilityResponse_New.Errors errors = er.errors;
            if(errors != null) {
%>
            <div class="copayment list-container">
                <ul id="errors-ul">
                    <li><%=errors.query%></li>
                </ul>
            </div>
            <div style="padding-left: 850px; height: 25px;"><input type="button" class="button" value="check eligibility" onClick="checkEligibility(<%=lRs.getString("id")%>)"/></div>
<%
            } else {
                if(!er.copayMap.isEmpty()) {
%>
            <div style="width: 100%; float: left;" >
                <div style="width:50%; float: left;">
        <div class="deductible list-container">
            <div class="major-item">Deductible</div>
                <table style="width: 100%; cellspacing: 3px;">
                    <tr>
                        <td style="padding-left: 30%; font-size: 14px; font-weight: bold;" colspan="2">Individual</td>
                    </tr>
                    <tr>
                        <td style="font-size: 12px; padding-left: 10px; font-weight: bold;">In Network</td>
                        <td style="font-size: 12px; font-weight: bold;">Out of Network</td>
                    </tr>
                    <td style="padding-left: 10px;">
                        Limit: <span style="width: 40%; text-align: right; float: right; padding-right: 5%;">$<%=er.deductibles.individual.inNetwork.deductible.limit%></span></br>
                        Applied: <span style="width: 40%; text-align: right; float: right; padding-right: 5%;">$<%=er.deductibles.individual.inNetwork.deductible.applied%></span></br>
                        Remaining: <span style="width: 40%; text-align: right; float: right; padding-right: 5%;">$<%=er.deductibles.individual.inNetwork.deductible.remaining%></span></br>
                    </td>
                    <td>
                        Limit: <span style="width: 40%; text-align: right; float: right; padding-right: 5%;">$<%=er.deductibles.individual.outOfNetwork.deductible.limit%></span></br>
                        Applied: <span style="width: 40%; text-align: right; float: right; padding-right: 5%;">$<%=er.deductibles.individual.outOfNetwork.deductible.applied%></span></br>
                        Remaining: <span style="width: 40%; text-align: right; float: right; padding-right: 5%;">$<%=er.deductibles.individual.outOfNetwork.deductible.remaining%></span></br>

                    </td>
                    <tr>
                        <td style="padding-left: 30%; font-size: 14px; font-weight: bold;" colspan="2">Family</td>
                    </tr>
                    <tr>
                        <td style="font-size: 12px; padding-left: 10px; font-weight: bold;">In Network</td>
                        <td style="font-size: 12px; font-weight: bold;">Out of Network</td>
                    </tr>
                    <td style="padding-left: 10px;">
                        Limit: <span style="width: 40%; text-align: right; float: right; padding-right: 5%;">$<%=er.deductibles.family.inNetwork.deductible.limit%></span></br>
                        Applied: <span style="width: 40%; text-align: right; float: right; padding-right: 5%;">$<%=er.deductibles.family.inNetwork.deductible.applied%></span></br>
                        Remaining: <span style="width: 40%; text-align: right; float: right; padding-right: 5%;">$<%=er.deductibles.family.inNetwork.deductible.remaining%></span></br>
                    </td>
                    <td>
                        Limit: <span style="width: 40%; text-align: right; float: right; padding-right: 5%;">$<%=er.deductibles.family.outOfNetwork.deductible.limit%></span></br>
                        Applied: <span style="width: 40%; text-align: right; float: right; padding-right: 5%;">$<%=er.deductibles.family.outOfNetwork.deductible.applied%></span></br>
                        Remaining: <span style="width: 40%; text-align: right; float: right; padding-right: 5%;">$<%=er.deductibles.family.outOfNetwork.deductible.remaining%></span></br>

                    </td>
                    <tr>
                        <td style="padding-left: 30%; font-size: 14px; font-weight: bold;" colspan="2">Individual (Out of Pocket)</td>
                    </tr>
                    <tr>
                        <td style="font-size: 12px; padding-left: 10px; font-weight: bold;">In Network</td>
                        <td style="font-size: 12px; font-weight: bold;">Out of Network</td>
                    </tr>
                    <td style="padding-left: 10px;">
                        Limit: <span style="width: 40%; text-align: right; float: right; padding-right: 5%;">$<%=er.deductibles.out_of_pocket.individual.inNetwork.deductible.limit%></span></br>
                        Applied: <span style="width: 40%; text-align: right; float: right; padding-right: 5%;">$<%=er.deductibles.out_of_pocket.individual.inNetwork.deductible.applied%></span></br>
                        Remaining: <span style="width: 40%; text-align: right; float: right; padding-right: 5%;">$<%=er.deductibles.out_of_pocket.individual.inNetwork.deductible.remaining%></span></br>
                    </td>
                    <td>
                        Limit: <span style="width: 40%; text-align: right; float: right; padding-right: 5%;">$<%=er.deductibles.out_of_pocket.individual.outOfNetwork.deductible.limit%></span></br>
                        Applied: <span style="width: 40%; text-align: right; float: right; padding-right: 5%;">$<%=er.deductibles.out_of_pocket.individual.outOfNetwork.deductible.applied%></span></br>
                        Remaining: <span style="width: 40%; text-align: right; float: right; padding-right: 5%;">$<%=er.deductibles.out_of_pocket.individual.outOfNetwork.deductible.remaining%></span></br>

                    </td>
                    <tr>
                        <td style="padding-left: 30%; font-size: 14px; font-weight: bold;" colspan="2">Family (Out of Pocket)</td>
                    </tr>
                    <tr>
                        <td style="font-size: 12px; padding-left: 10px; font-weight: bold;">In Network</td>
                        <td style="font-size: 12px; font-weight: bold;">Out of Network</td>
                    </tr>
                    <td style="padding-left: 10px;">
                        Limit: <span style="width: 40%; text-align: right; float: right; padding-right: 5%;">$<%=er.deductibles.out_of_pocket.family.inNetwork.deductible.limit%></span></br>
                        Applied: <span style="width: 40%; text-align: right; float: right; padding-right: 5%;">$<%=er.deductibles.out_of_pocket.family.inNetwork.deductible.applied%></span></br>
                        Remaining: <span style="width: 40%; text-align: right; float: right; padding-right: 5%;">$<%=er.deductibles.out_of_pocket.family.inNetwork.deductible.remaining%></span></br>
                    </td>
                    <td>
                        Limit: <span style="width: 40%; text-align: right; float: right; padding-right: 5%;">$<%=er.deductibles.out_of_pocket.family.outOfNetwork.deductible.limit%></span></br>
                        Applied: <span style="width: 40%; text-align: right; float: right; padding-right: 5%;">$<%=er.deductibles.out_of_pocket.family.outOfNetwork.deductible.applied%></span></br>
                        Remaining: <span style="width: 40%; text-align: right; float: right; padding-right: 5%;">$<%=er.deductibles.out_of_pocket.family.outOfNetwork.deductible.remaining%></span></br>

                    </td>
                </table>

        </div>
        <div class="copayment list-container">
            <div class="major-item">Copay</div>
            <div>
                <ul id="copay-ul">
                    <li>
                        <span class="left item-heading">Copayment</span>
                        <span class="right item-heading left-aligned">Service Types</span>
                    </li>
<%
                for(EligibilityResponse_New.Copay cop : er.copayMap.values()) {
                    for(Object serviceType : cop.service_type) { 
                        String copaymentOut = "&nbsp;&nbsp;";
                        if(copaymentAmount == null || !cop.amount.equals(copaymentAmount)) { copaymentOut = "$" + cop.amount; }
                        if(copaymentAmount == null) { copaymentAmount = cop.amount; }
%>
        
                <li>
                    <span class="left list-item"><%=copaymentOut%></span>
                    <span class="right list-item left-aligned">
                <%= capitalize(((String)serviceType+" "+cop.coverageLevel).replaceAll("_", " "))+" - "+cop.inPlanNetwork %></br>
                <%      for(Object message : cop.messages) { 
                            out.print("<b style=\"font-weight: 8px; font-weight: normal;\">" + message + "</b>"); 
                        } 
                %>
                    </span>
                </li>
<%
                        }
                    }
                }
%> 
                </ul>
            </div>
        </div>
        <div class="coverage list-container">
            <div class="major-item">Coverage</div>
            <ul id="coverage-ul">
                <li>
                    <span class="left list-item" style="padding-bottom: 3px;">Plan Start</span>
                    <span class="right list-item left-aligned"  style="font-weight: normal; padding-bottom: 3px;"><%=Format.formatDate(er.coverage.plan_begin_date,"MM/dd/yyyy")%></span>
                </li>
                <li>
                    <span class="left list-item"  style="padding-bottom: 3px;">Plan End</span>
                    <span class="right list-item left-aligned" style="font-weight: normal; padding-bottom: 3px;"><%=Format.formatDate(er.coverage.plan_end_date,"MM/dd/yyyy")%></span>
                </li>
                <li>
                    <span class="left list-item" style="padding-bottom: 3px;">Plan Description</span>
                    <span class="right list-item left-aligned" style="font-weight: normal; padding-bottom: 3px;"><%=er.coverage.group_description + "&nbsp;&nbsp;"%></span>
                </li>
            </ul>
        </div>
                </div>
                <div style="width: 50%; float: right;">
        <div class="coinsurance list-container">
            <div class="major-item">Coinsurance</div>
            <ul id="coinsurance-ul">
<%
                for(String key : serviceMap.keySet()) {
                    EligibilityResponse_New.CoinsuranceDetail cd = (EligibilityResponse_New.CoinsuranceDetail)serviceMap.get(key);
                    String network = cd.coverageLevel.trim();
                    if(cd.inPlanNetwork.equals("not_applicable")) { network += " not applicable"; }
                    else if(cd.inPlanNetwork.equals("no")) { network += " out of network plan"; }
                    else if(cd.inPlanNetwork.equals("yes")) { network += " in network plan"; }

                    network = capitalize(network);
                    out.print("<div align=\"left\" class=\"coinsurance-description\">" + network + "</div>");
    //                out.print("<ul id=\"coinsurance-ul\">");
                    out.print("<li><span class=\"left  item-heading\">Benefit</span><span class=\"right item-heading left-aligned\">Service Types</span></li>");
                    double bpct = 0.0;
                    String bpctOut = "";

                    bpct = cd.benefit_percent*100;
                    bpctOut = ""+bpct;
                    out.print("<li>");
                    out.print("<span class=\"left\">");
                    out.print(bpctOut.substring(0,bpctOut.indexOf(".")) + "%");
                    out.print("</span>");
                    out.print("<span style=\"font-weight: normal;\" class=\"right left-aligned coinsurance-details\">");
                    for(int x=0;x<cd.serviceTypes.size();x++) {
                        if(x != 0) { out.print(", "); }
                        out.print(capitalize((String)cd.serviceTypes.get(x)));
                    }
                    out.print("</br>");
                    for(int x=0;x<cd.messages.size();x++) {
                        out.print(cd.messages.get(x) + "</br>");
                    }
                    out.print("</span></li>");
    //                out.print("</ul>");
                }
%>
            </ul>
        </div>

        <div class="limitations list-container">
            <div class="major-item">Limitations</div>
            <ul id="limitation-ul">
<%
                for(String key : limitationMap.keySet()) {
                    EligibilityResponse_New.LimitationDetail ld = (EligibilityResponse_New.LimitationDetail)limitationMap.get(key);
                    String network = "";
                    if(ld.coverageLevel != null) { network += ld.coverageLevel.trim(); }
                    if(ld.inPlanNetwork != null && ld.inPlanNetwork.equals("not applicable")) { network += " not applicable"; }
                    else if(ld.inPlanNetwork != null && ld.inPlanNetwork.equals("no")) { network += " out of network plan"; }
                    else if(ld.inPlanNetwork != null && ld.inPlanNetwork.equals("yes")) { network += " in network plan"; }

                    network = capitalize(network);
                    out.print("<div align=\"left\" class=\"limitation-description\">" + network + "</div>");
    //                out.print("<ul id=\"limitation-ul\">");
                    out.print("<li><span class=\"left  item-heading\">Benefit</span><span class=\"right item-heading left-aligned\">Service Types</span></li>");

                    out.print("<li>");
                    out.print("<span class=\"left\">");
                    out.print("$" + ld.benefit_amount);
                    out.print("</span>");
                    out.print("<span style=\"font-weight: normal;\" class=\"right left-aligned limitation-details\">");
                    for(int x=0;x<ld.serviceTypes.size();x++) {
                        if(x != 0) { out.print(", "); }
                        out.print(capitalize((String)ld.serviceTypes.get(x)));
                    }
                    out.print("</br>");
                    for(int x=0;x<ld.messages.size();x++) {
                        out.print(ld.messages.get(x) + "</br>");
                    }
                    
                    if(ld.delivery.size()>0) {
                        out.print("</br>");
                        out.print("<table style=\"width: 100%; cellspacing: 0px; cellpadding: 0px; padding-bottom: 5px;\">");
                        for(Object delivery : ld.delivery) {
                            out.print("<tr>");
                            EligibilityResponse_New.Delivery d = (EligibilityResponse_New.Delivery)delivery;
                            out.print("<td style=\"width: 10%;\">Period:</td><td style=\"width: 10%; text-align: left;\">" + d.time_period + "</td>");
                            out.print("<td style=\"width: 10%;\">Qualifier:</td><td style=\"width: 10%; text-align: left;\">" + d.quantity_qualifier + "</td>");
                            out.print("<td style=\"width: 10%;\">Count:</td><td style=\"width: 3%; text-align: right; padding-right: 3px;\">" + d.period_count + "</td>");
                            out.print("<td style=\"width: 10%;\">Quantity:</td><td style=\"width: 3%; text-align: right;\">" + d.quantity + "</td>");
                            out.print("</tr>");
                        }
                        out.print("</table>");
                    }
                    out.print("</span></li>");
                }
%>
            </ul>
        </div>
                </div>
            </div>
    <div style="padding-left: 850px; height: 25px;"><input type="button" class="button" value="check eligibility" onClick="checkEligibility(<%=lRs.getString("id")%>)"/></div>
   
<%
            }
        } catch (Exception e) {
%>
            <div style="width: 970px; height: 350px; overflow: hidden">
            <div style="position: absolute; bottom: 0px; left: 850px; height: 25px;"><input type="button" class="button" value="check eligibility" onClick="checkEligibility(<%=lRs.getString("id")%>)" /></div>
            </div>
<%
        }
    }
%>

<%! public String capitalize(String s) {
        if(s != null && s.length()>0) {
            String[] arr = s.split(" ");
            StringBuffer sb = new StringBuffer();

            for (int i = 0; i < arr.length; i++) {
                try {
                    sb.append(Character.toUpperCase(arr[i].charAt(0))).append(arr[i].substring(1)).append(" ");
                } catch(Exception e) {
                    
                }
            }          
            return sb.toString().trim();
        } else {
            return s;
        }   
    }
%>

