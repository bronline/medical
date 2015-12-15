<%-- 
    Document   : savefielddata
    Created on : Sep 12, 2014, 3:16:37 PM
    Author     : Randy
--%>
<%@include file="sessioninfo.jsp" %>
<%
    String recordId = request.getParameter("id");
    String fieldName = request.getParameter("fieldName");
    String fieldValue = request.getParameter("fieldValue");
    ArrayList<String> accountFields = new ArrayList(Arrays.asList("firstname","lastname","address","city","state","zipcode","dob","phonenumber"));
    ArrayList<String> guarantorFields = new ArrayList(Arrays.asList("guarantorname","guarantoraddress","guarantorcity","guarantorstate","guarantorzipcode","guarantorphonenumber"));
    ArrayList<String> payorFields = new ArrayList(Arrays.asList("providernumber","providergroup","planname","insuranceeffective","insurancebenefitsdate","insurancetermdate"));

    if(accountFields.contains(fieldName)) {
        PreparedStatement aPs = io.getConnection().prepareStatement("update patients set " + fieldName + "=? where id=?");

        aPs.setString(1,fieldValue);
        aPs.setString(2,recordId);
        
        aPs.execute();
    }
    
    if(guarantorFields.contains(fieldName) || payorFields.contains(fieldName)) {
        if(fieldName.equals("guarantorname")) { fieldName = "hicfa4"; }
        else if(fieldName.equals("guarantoraddress")) { fieldName = "hicfa7address";  }
        else if(fieldName.equals("guarantorcity")) { fieldName = "hicfa7city";  }
        else if(fieldName.equals("guarantorstate")) { fieldName = "hicfa7state";  }
        else if(fieldName.equals("guarantorzipcode")) { fieldName = "hicfa7zip";  }
        else if(fieldName.equals("guarantorphone")) { fieldName = "hicfa7phone";  }
        else if(fieldName.equals("guarantordob")) { fieldName = "hicfa7dob";  }

        PreparedStatement gPs = io.getConnection().prepareStatement("update patientinsurance set " + fieldName + "=? where id=?");

        gPs.setString(1, fieldValue);
        gPs.setString(2, recordId);
        
        gPs.execute();
    }

%>
<%@include file="cleanup.jsp" %>
