<%-- 
    Document   : showeligibilityinfo
    Created on : Mar 7, 2016, 1:43:32 PM
    Author     : Randy
--%>
<%@page import="com.pokitdok.utilities.eligibility.Limitation"%>
<%@page import="org.json.simple.parser.JSONParser"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="com.pokitdok.utilities.eligibility.Coinsurance"%>
<%@page import="com.pokitdok.utilities.eligibility.Message"%>
<%@page import="com.pokitdok.utilities.eligibility.Copay"%>
<%@page import="com.pokitdok.utilities.eligibility.EligibilityResponse"%>
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
    width: 360px;
    padding-left: 25%;
    text-align: left;
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
    width: 50%;
}

div .coverage {
    float: left;
    width: 50%;
}

div .coinsurance {
    float: right;
    width: 50%;
}

.coinsurance-details {
    padding-bottom: 5px;
}

div .limitations {
    float: right;
    width: 50%;
}
</style>

<%
    class CoinsuranceDetail {
        public String coverageLevel;
        public String inPlanNetwork;
        public double benefit_percent;
        public ArrayList serviceTypes = new ArrayList();
        public ArrayList messages = new ArrayList();
    }
    
    class LimitationDetail {
        public String coverageLevel;
        public String inPlanNetwork;
        public double benefit_amount;
        public ArrayList serviceTypes = new ArrayList();
        public ArrayList messages = new ArrayList();
    }

    ResultSet lRs = io.opnRS("CALL rwcatalog.prGetPrimaryPayer('" + io.getLibraryName() + "'," + patient.getId() + ")");

    if(lRs.next()) {
        try {
            EligibilityResponse er = EligibilityResponse.parse(lRs.getString("jsonresponse"));
            String copaymentAmount = null;

            HashMap<String, CoinsuranceDetail> serviceMap = new HashMap<String, CoinsuranceDetail>();
            HashMap<String, LimitationDetail> limitationMap = new HashMap<String, LimitationDetail>();

            for(Coinsurance c : er.data.coverage.coinsurance) {
                String key = c.coverageLevel + "-" + c.inPlanNetwork + "-" +c.benefitPercent;
                CoinsuranceDetail cd;
                if(!serviceMap.containsKey(key)) { 
                    cd = new CoinsuranceDetail();
                    cd.coverageLevel = c.coverageLevel.replaceAll("_", " ");
                    cd.inPlanNetwork = c.inPlanNetwork.replaceAll("_", " ");
                    cd.benefit_percent = c.benefitPercent;
                    serviceMap.put(key, cd); 
                } else {
                    cd = serviceMap.get(key);
                }

                for(String s : c.serviceTypes) {
                    if(!cd.serviceTypes.contains(s)) {
                        cd.serviceTypes.add(s.replaceAll("_", " "));
                    }
                }
                
                for(Message m : c.messages) {
                    if(!cd.messages.contains(m.message)) {
                        cd.messages.add(m.message);
                    }
                }
            }
            
            for(Limitation l : er.data.coverage.limitations) {
                String key = "";
                if(l.coverageLevel != null) { key += l.coverageLevel + "-"; }
                if(l.inPlanNetwork != null) {key += l.inPlanNetwork + "-"; }
                key += l.benefitAmount.amount;
                LimitationDetail ld;
                if(!limitationMap.containsKey(key)) {
                    ld=new LimitationDetail();
                    if(l.coverageLevel != null) { ld.coverageLevel = l.coverageLevel.replaceAll("_", " "); } else { l.coverageLevel = ""; }
                    ld.benefit_amount = Double.parseDouble(l.benefitAmount.amount);
                    if(l.inPlanNetwork != null) { ld.inPlanNetwork = l.inPlanNetwork.replaceAll("_", " "); } else { ld.inPlanNetwork = ""; }
                    limitationMap.put(key, ld);
                } else {
                    ld=limitationMap.get(key);
                }
                
                for(String s : l.serviceTypes) {
                    if(!ld.serviceTypes.contains(s)) {
                        ld.serviceTypes.add(s.replaceAll("_", " "));
                    }
                }
                
                for(Message m : l.messages) {
                    if(!ld.messages.contains(m.message)) {
                        ld.messages.add(m.message);
                    }
                }
            }
            
%>
<div class="copayment list-container">
    <div>
    <ul id="copay-ul">
        <li>
            <span class="left item-heading">Copayment</span>
            <span class="right item-heading left-aligned">Service Types</span>
        </li>
<%
            for(Copay cop : er.data.coverage.copay) {
                for(String serviceType : cop.serviceTypes) { 
                    String copaymentOut = "&nbsp;&nbsp;";
                    if(copaymentAmount == null || !cop.copayment.amount.equals(copaymentAmount)) { copaymentOut = "$" + cop.copayment.amount; }
                    if(copaymentAmount == null) { copaymentAmount = cop.copayment.amount; }
%>
        
        <li>
            <span class="left list-item"><%=copaymentOut%></span>
            <span class="right list-item left-aligned">
                <%= capitalize(serviceType.replaceAll("_", " ")) %></br>
                <% for(Message message : cop.messages) { 
                    out.print("<b style=\"font-weight: 8px; font-weight: normal;\">" + message.message + "</b>"); 
                   } 
                %>
            </span>
        </li>
<%
                }
            }
%> 
    </ul>
    </div>
</div>
<div class="coinsurance list-container">
    <div class="major-item">Coinsurance</div>
    <ul id="coinsurance-ul">
<%
            for(String key : serviceMap.keySet()) {
                CoinsuranceDetail cd = (CoinsuranceDetail)serviceMap.get(key);
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
<div class="coverage list-container">
    <div class="major-item">Coverage</div>
    <ul id="coverage-ul">
        <li>
            <span class="left list-item" style="padding-bottom: 3px;">Plan Start</span>
            <span class="right list-item left-aligned"  style="font-weight: normal; padding-bottom: 3px;"><%=Format.formatDate(er.data.coverage.planBeginDate,"MM/dd/yyyy")%></span>
        </li>
        <li>
            <span class="left list-item"  style="padding-bottom: 3px;">Plan End</span>
            <span class="right list-item left-aligned" style="font-weight: normal; padding-bottom: 3px;"><%=Format.formatDate(er.data.coverage.planEndDate,"MM/dd/yyyy")%></span>
        </li>
        <li>
            <span class="left list-item" style="padding-bottom: 3px;">Plan Description</span>
            <span class="right list-item left-aligned" style="font-weight: normal; padding-bottom: 3px;"><%=er.data.coverage.planDescription + "&nbsp;&nbsp;"%></span>
        </li>
    </ul>
</div>



<div class="limitations list-container">
    <div class="major-item">Limitations</div>
    <ul id="limitation-ul">
<%
            for(String key : limitationMap.keySet()) {
                LimitationDetail ld = (LimitationDetail)limitationMap.get(key);
                String network = "";
                if(ld.coverageLevel != null) { network += ld.coverageLevel.trim(); }
                if(ld.inPlanNetwork.equals("not_applicable")) { network += " not applicable"; }
                else if(ld.inPlanNetwork.equals("no")) { network += " out of network plan"; }
                else if(ld.inPlanNetwork.equals("yes")) { network += " in network plan"; }

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
                out.print("</span></li>");
//                out.print("</ul>");
            }
%>
    </ul>
</div>
<div style="padding-left: 850px; height: 25px;"><input type="button" class="button" value="check eligibility" onClick="checkEligibility(<%=lRs.getString("id")%>)"/></div>
<%
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
                sb.append(Character.toUpperCase(arr[i].charAt(0))).append(arr[i].substring(1)).append(" ");
            }          
            return sb.toString().trim();
        } else {
            return s;
        }   
    }
%>

