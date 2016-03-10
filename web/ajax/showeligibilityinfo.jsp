<%-- 
    Document   : showeligibilityinfo
    Created on : Mar 7, 2016, 1:43:32 PM
    Author     : Randy
--%>
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
    font-size: 12px;
    font-weight: bold;
    padding-bottom: 5px;
}

.item-detail {
    font-size: 9px;
}

@media only screen and (max-width: 480px) {
    .left, .right {
        float: none;
        width: 100%;
        display:blocK;
    }
}

div .list-container {
    width: 100%;
    padding-bottom: 5px;
}

div .major-item {
    padding-left: 15%;
    text-align: left;
    font-size: 14px;
    font-weight: bold;
}

.coinsurance-description {
    float: left;
    text-align: left;
    font-weight: bold;
    font-size: 14px;
    padding-left: 47px;
    padding-top: 10px;
    width: 100%;
}
</style>
<%
    class CoinsuranceDetail {
        public String coverageLevel;
        public String inPlanNetwork;
        public double benefit_percent;
        public ArrayList serviceTypes = new ArrayList();
    }

    ResultSet lRs = io.opnRS("CALL rwcatalog.prGetPrimaryPayer('" + io.getLibraryName() + "'," + patient.getId() + ")");

    if(lRs.next()) {
        EligibilityResponse er = EligibilityResponse.parse(lRs.getString("jsonresponse"));
        String copaymentAmount = null;
        
       HashMap<String, CoinsuranceDetail> serviceMap = new HashMap<String, CoinsuranceDetail>();

        for(Coinsurance c : er.data.coverage.coinsurance) {
            String key = c.coverageLevel + '-' + c.inPlanNetwork + '-' +c.benefitPercent;
            CoinsuranceDetail cd;
            if(!serviceMap.containsKey(key)) { 
                cd = new CoinsuranceDetail();
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
            
//            for(Message m : c.messages) {
//                System.out.println("    " + m.message);
//            }

        }
%>
<div style="float: left;" class="list-container">
    <ul>
        <li><span class="left item-heading">Copayment</span><span class="right item-heading left-aligned">Service Types</span>
        </li>
<%
        for(Copay cop : er.data.coverage.copay) {
            for(String serviceType : cop.serviceTypes) { 
                String copaymentOut = "&nbsp;&nbsp;";
                if(copaymentAmount == null || !cop.copayment.amount.equals(copaymentAmount)) { copaymentOut = "$" + cop.copayment.amount; }
                if(copaymentAmount == null) { copaymentAmount = cop.copayment.amount; }
%>
        
        <li><span class="left list-item"><%=copaymentOut%></span><span class="right list-item left-aligned"><%= capitalize(serviceType.replaceAll("_", " ")) %></br><% for(Message message : cop.messages) { out.print("<b style=\"font-weight: 8px; font-weight: normal;\">" + message.message + "</b>"); } %></span>
        </li>
<%
            }
        }
%>        
    </ul>
</div>
<div style="float: left;" class="list-container">
<!--    <div class="major-item">Coinsurance</div>  -->
    
        
<%
        for(String key : serviceMap.keySet()) {
            CoinsuranceDetail cd = (CoinsuranceDetail)serviceMap.get(key);
            System.out.println("--" + cd.coverageLevel + "  " + cd.inPlanNetwork + "  " + cd.benefit_percent);
            String network = cd.coverageLevel.trim();
            if(cd.inPlanNetwork.equals("not_applicable")) { network += " not applicable"; }
            else if(cd.inPlanNetwork.equals("no")) { network += " out of network plan"; }
            else if(cd.inPlanNetwork.equals("yes")) { network += " in network plan"; }
            
            network = capitalize(network);
            out.print("<div align=\"left\" class=\"coinsurance-description\">" + network + "</div>");
            out.print("<ul>");
            out.print("<li><span class=\"left  item-heading\">Benefit</span><span class=\"right item-heading left-aligned\">Service Types</span></li>");
            double bpct = 0.0;
            String bpctOut = "";

            bpct = cd.benefit_percent*100;
            bpctOut = ""+bpct;
            out.print("<li>");
            out.print("<span class=\"left\">");
            out.print(bpctOut.substring(0,bpctOut.indexOf(".")) + "%");
            out.print("</span>");
            out.print("<span style=\"font-weight: normal;\" class=\"right left-aligned\">");
            for(int x=0;x<cd.serviceTypes.size();x++) {
                if(x != 0) { out.print(", "); }
                out.print(cd.serviceTypes.get(x));
            }
            out.print("</span></li>");
            out.print("</ul>");
        }
%>        
    
</div>
<%

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

