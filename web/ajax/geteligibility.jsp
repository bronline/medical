<%-- 
    Document   : geteligibility
    Created on : Mar 14, 2016, 6:08:43 PM
    Author     : Randy
--%>
<%@include file="sessioninfo.jsp" %>
<%@page import="org.json.simple.JSONValue"%>
<%@page import="org.json.simple.JSONObject"%>
<%@page import="java.util.Map"%>
<%@page import="com.pokitdok.utilities.eligibility.Eligibility"%>
<%@page import="com.pokitdok.PokitDok"%>
<%
    String patientInsuranceId = request.getParameter("patientInsuranceId");
    
    ResultSet pdRs = io.opnRS("SELECT * FROM rwcatalog.pokitdok WHERE Id=1");
    if(pdRs.next()) {
        ResultSet pRs = io.opnRS("CALL rwcatalog.prGetPatientForEligibility('" + io.getLibraryName() + "'," + patient.getId() + ")");
        ResultSet piRs = io.opnRS("SELECT pi.id, pi.providernumber, p.ediid FROM patientinsurance pi LEFT JOIN providers p ON p.id=pi.providerid WHERE pi.id=" + patientInsuranceId);
        
        if(pRs.next()) {
//            System.out.println("------ AUTHORIZING POKITDOK API ------");
            if(piRs.next()) {
                PokitDok pd = new PokitDok(pdRs.getString("clientId"), pdRs.getString("clientsecret"));
                pd.connect();
//                System.out.println("------ CALLING POKITDOK CONNECTED ------");
                
                Eligibility e = new Eligibility();
                e.member.first_name = pRs.getString("firstname");
                e.member.last_name = pRs.getString("lastname");
                e.member.birth_date = pRs.getString("dob");
                e.member.id = piRs.getString("providernumber");

                e.provider.first_name = pRs.getString("providerfirstname");
                e.provider.last_name = pRs.getString("providerlastname");
                e.provider.npi = pRs.getString("providernpi");

                e.service_types.add("chiropractic_office_visits");
//                e.service_types.add("34");
//                e.service_types.add("health_benefit_plan_coverage");
//                e.service_types.add("general_benefits");
//                e.service_types.add("medical_care");
                e.trading_partner_id = piRs.getString("ediid");

                Map eligibilityQuery = (JSONObject) JSONValue.parse(e.serialize());

//                System.out.println("------ CALLING POKITDOK API ------");
                Map<String, Object> pokitDokResponse = pd.eligibility(eligibilityQuery);
//                System.out.println("------ POKITDOK API RESPONSE: " + pokitDokResponse.toString());
                
                PreparedStatement lPs = io.getConnection().prepareStatement("INSERT INTO insuranceeligibility (patientinsuranceid, jsonresponse) values(?,?) ON DUPLICATE KEY UPDATE jsonresponse=?");
                lPs.setString(1, patientInsuranceId);
                lPs.setString(2, pokitDokResponse.toString());
                lPs.setString(3, pokitDokResponse.toString());
                lPs.execute();
            }
        }
    }
%>
