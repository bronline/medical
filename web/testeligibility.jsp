<%@page import="org.json.simple.JSONValue"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="com.pokitdok.utilities.eligibility.Eligibility"%>
<%@page import="com.pokitdok.PokitDok"%>
<%@ include file="globalvariables.jsp" %>
<script type="text/javascript" src="js/json-to-table.js"></script>
<%

        PokitDok pd = new PokitDok("UYOjfVWTJ0y3o1idROXd", "WYoYu4rDhjkAGskBtTUwUC26e3Tvi9yxylCEX9vW");
        pd.connect();
        
        Eligibility e = new Eligibility();
        e.member.first_name = "ASHER";
        e.member.last_name = "ALLEN";
        e.member.birth_date = "1998-06-05";
        e.member.id = "945801841";
        
        e.provider.first_name = "Rion";
        e.provider.last_name = "Marcus";
        e.provider.npi = "1124369947";
        
        e.service_types.add("health_benefit_plan_coverage");
        e.trading_partner_id = "united_health_care";

      Map eligibilityQuery = (JSONObject) JSONValue.parse(e.serialize());
      
      Map<String, Object> r = pd.eligibility(eligibilityQuery);
      
%>
<script type="textjavascript">
    ConvertJsonToTable("<%=r.toString()%>") {
</script>