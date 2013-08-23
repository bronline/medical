<%@include file="globalvariables.jsp" %>
<%
// Set up work variables to process the request parameters
    String returnUrl = (String)session.getAttribute("returnUrl");
    Enumeration parms = request.getParameterNames();
    String name;
    int firstUnderScore=0;
    int secondUnderScore=0;
    int thirdUnderScore=0;

// Set up work variables that will be used to populate each of the payments
    int dftId;
    int itemId;
    int providerId;
    int patientId = patient.getId();
    BigDecimal defaultPayment;
    BigDecimal copay;
    String fieldSuffix="";
    String amountString="";
    String modifier="";
    String billInsurance="";
    
    PreparedStatement lPs;
    
// Roll through all of the parameters. Whenever we find a copay_, then there's work to be done.
    while (parms.hasMoreElements()) {
        name=(String)parms.nextElement();

        if (name.startsWith("copay_")) {

            firstUnderScore=name.indexOf("_");
            fieldSuffix=name.substring(firstUnderScore);

            secondUnderScore=name.indexOf("_", firstUnderScore+1);
            thirdUnderScore=name.indexOf("_", secondUnderScore+1);

            dftId=Integer.parseInt(name.substring(firstUnderScore+1,secondUnderScore));
            itemId=Integer.parseInt(name.substring(secondUnderScore+1,thirdUnderScore));
            providerId=Integer.parseInt(name.substring(thirdUnderScore+1));

            try {
              // first get the copay
                amountString = request.getParameter("copay" + fieldSuffix);
                if(amountString.substring(0,1).equals("$")) {
                    amountString=amountString.substring(1);
                }
                copay = BigDecimal.valueOf(Double.parseDouble(amountString));

              // second get the defaultPayment
                amountString = request.getParameter("defaultpayment" + fieldSuffix);
                if(amountString.substring(0,1).equals("$")) {
                    amountString=amountString.substring(1);
                }
                defaultPayment = BigDecimal.valueOf(Double.parseDouble(amountString));
                
              // third, get the modifier
                modifier = request.getParameter("modifier" + fieldSuffix);
                if (modifier==null) {modifier="";}
                
            // fourth, get billInsurance
                billInsurance = request.getParameter("billinsurance" + fieldSuffix);
                if (billInsurance==null) {billInsurance="";}
                
//                if (dftId>0 || defaultPayment.longValue()>0 || copay.longValue()>0 || !modifier.equals("") || !billInsurance.equals("true") ) {
//                    if (dftId > 0 && defaultPayment.longValue()==0 && copay.longValue()==0 && modifier.equals("") && billInsurance.equals("true")) {
//                        lPs = io.getConnection().prepareStatement("DELETE FROM DEFAULTPAYMENTS WHERE ID = " + dftId);
//                        lPs.executeUpdate();
//                    } else if (dftId > 0) {
                    if (dftId > 0) {
                        lPs = io.getConnection().prepareStatement("UPDATE DEFAULTPAYMENTS SET AMOUNT = ?, COPAY = ?, MODIFIER = ?, billInsurance=? WHERE ID = " + dftId);
                        lPs.setBigDecimal(1,defaultPayment);
                        lPs.setBigDecimal(2,copay);
                        lPs.setString(3,modifier);
                        lPs.setBoolean(4,Boolean.parseBoolean(billInsurance));
                        lPs.executeUpdate();
                    } else if (dftId == 0) {
                        lPs = io.getConnection().prepareStatement("INSERT INTO DEFAULTPAYMENTS VALUES(null,?,?,?,?,?,?,?)");
                        lPs.setInt(1,providerId);
                        lPs.setInt(2,patientId);
                        lPs.setInt(3,itemId);
                        lPs.setBigDecimal(4,defaultPayment);
                        lPs.setBigDecimal(5,copay);
                        lPs.setString(6,modifier);
                        lPs.setBoolean(7,Boolean.parseBoolean(billInsurance));
                        lPs.executeUpdate();
                    }
//                }
            } catch (Exception e) {
                
            }
        }        

    }
    response.sendRedirect(returnUrl);

%>
