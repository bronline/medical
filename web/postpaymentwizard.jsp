<%@include file="globalvariables.jsp" %>
<SCRIPT language=JavaScript>
<!--
function win(parent){
if(parent != null) { window.opener.location.href=parent }
self.close();
//-->
}
</SCRIPT>
<%
    String parentLocation = (String)session.getAttribute("parentLocation");

    // Set up work variables to process the request parameters
    String returnUrl = (String)session.getAttribute("returnUrl");
    String batchId = request.getParameter("batchId");
    String insurancePatientId = request.getParameter("insurancePatientId");
    String eobReasonType = "";

    Enumeration parms = request.getParameterNames();
    String name;

    PreparedStatement batchChgPs = io.getConnection().prepareStatement("update batchcharges c left join batches b on b.id=c.batchid set complete=1 where c.chargeid=? and b.provider=?");
    PreparedStatement eobExceptionPs = io.getConnection().prepareStatement("insert into eobexceptions (chargeid, paymentid, reasonid, amount) values (?, ?, ?, ?)");
    PreparedStatement eobReasonPs = io.getConnection().prepareStatement("select * from eobreasons where id=?");

// Set up work variables that will be used to populate each of the payments
    int provider=0;
//    int checkNumber;
    String checkNumber="";
    BigDecimal amount;
    int chargeId=0;
    int patientId=0;
    int paymentId=0;
    int parentPayment=0;
    String amountString;
    java.util.Date date;

// Get the parent payment
    try {
        parentPayment=Integer.parseInt(request.getParameter("parentPayment"));
    } catch (Exception e) {
    }

// Instantiate some objects to represent the database relationships
    Charge thisCharge = new Charge(io, "0");
    Payment thisPayment = new Payment(io, 0);
    Visit thisVisit = new Visit(io, "0");
    Patient thisPatient = new Patient(io, "0");

// Roll through all of the parameters. Whenever we find a checkAmount, then there's work to be done.
    while (parms.hasMoreElements()) {
        name=(String)parms.nextElement();

// If this is a checkAmount, get the suffix because that represents the charge ID
        if (name.length()>11 && name.substring(0,11).equals("checkAmount")) {

            chargeId = Integer.parseInt(name.substring(11));

// Set up the Charge Instance
            thisCharge.setId(chargeId);
            thisCharge.next();

// Set up the Visit Instance
            thisVisit.setId(thisCharge.getInt("visitid"));
            thisVisit.next();

// Set up the Patient Instance
            thisPatient.setId(thisVisit.getInt("patientId"));
            thisPatient.next();

// Now, populate the payment fields, but only if the amount is greater than zero
            amountString = request.getParameter("checkAmount"+chargeId);
            if(amountString != null) {
                amountString=amountString.replaceAll("\\$", "").replaceAll(",","");
            }
            amount = BigDecimal.valueOf(Double.parseDouble(amountString));
//            if (amount.longValue() > 0.0) {
            if (amount.doubleValue() > 0.0) {
                  provider=0;
                  if(request.getParameter("providerId"+chargeId) != null && !request.getParameter("providerId"+chargeId).equals("")) {
                      provider = Integer.parseInt(request.getParameter("providerId"+chargeId));
                  }
                  patientId = thisPatient.getId();
                  amountString = request.getParameter("checkAmount"+chargeId);

                  try {
                      date = (java.util.Date)java.sql.Date.valueOf(request.getParameter("date"+chargeId));
                  } catch (Exception dExcp) {
                      date = new java.util.Date();
                  }
                  if(amountString != null) {
                      amountString=amountString.replaceAll("\\$", "").replaceAll(",","");
                  }
                  checkNumber=request.getParameter("checkNumber"+chargeId);
        //              checkNumber = Integer.parseInt(request.getParameter("checkNumber"+chargeId));

                  thisPayment.setId(0);
                  thisPayment.setProvider(provider);
                  thisPayment.setCheckNumber(checkNumber);
                  thisPayment.setAmount(amount);
                  thisPayment.setChargeId(chargeId);
                  thisPayment.setPatientId(patientId);
                  thisPayment.setDate(date);
                  thisPayment.setParentPayment(parentPayment);
                  thisPayment.setOriginalAmount(amount);
                  thisPayment.update();

            }
// Now, populate the WRITEOFF fields, but only if the amount is greater than zero
            amountString = request.getParameter("woAmount"+chargeId);
            if(amountString !=  null) {
                amountString=amountString.replaceAll("\\$", "").replaceAll(",","");
            } else {
                amountString="0.0";
            }
            amount = BigDecimal.valueOf(Double.parseDouble(amountString));

            paymentId=0;

            eobReasonType=request.getParameter("eobReasonType" + chargeId);

            if (amount.longValue() > 0.0 && (eobReasonType == null || eobReasonType.trim().equals("A"))) {
                provider = 10; // 10 is WRITEOFF\

                // Check to see if the eob reason assigns to another
                if(eobReasonType != null && eobReasonType.trim().equals("A")) {
                    eobReasonPs.setString(1, request.getParameter("eobReasonId" + chargeId));
                    ResultSet eobReasonRs=eobReasonPs.executeQuery();
                    if(eobReasonRs.next()) {
                        if(eobReasonRs.getInt("providerid") != 0) { provider=eobReasonRs.getInt("providerid"); }
                    }
                    eobReasonRs.close();
                    eobReasonRs = null;
                }

                patientId = thisPatient.getId();
                amountString = request.getParameter("woAmount"+chargeId);

                try {
                    date = (java.util.Date)java.sql.Date.valueOf(request.getParameter("date"+chargeId));
                } catch (Exception dExcp) {
                    date = new java.util.Date();
                }

                if(amountString != null) {
                  amountString=amountString.replaceAll("\\$", "").replaceAll(",","");
                }
                checkNumber=request.getParameter("checkNumber"+chargeId);

                thisPayment.setId(0);
                thisPayment.setProvider(provider);
                thisPayment.setCheckNumber(checkNumber);
                thisPayment.setAmount(amount);
                thisPayment.setChargeId(chargeId);
                thisPayment.setPatientId(patientId);
                thisPayment.setDate(date);
                thisPayment.setParentPayment(0);
                thisPayment.setOriginalAmount(amount);
                thisPayment.update();

                io.setMySqlLastInsertId();
                paymentId=io.getLastInsertedRecord();
            }

            if(eobReasonType != null && !eobReasonType.trim().equals("")) {
                eobExceptionPs.setInt(1, chargeId);
                eobExceptionPs.setInt(2, paymentId);
                eobExceptionPs.setString(3, request.getParameter("eobReasonId" + chargeId));
                eobExceptionPs.setBigDecimal(4, amount);
                eobExceptionPs.execute();
            }
        } else if(name.length()>3 && name.substring(0,3).equals("chk")) {
            // 2010-07-12 (Mark the batch charges record as complete so it does not pull into reports or payment wizard)
            chargeId = Integer.parseInt(name.substring(3));
            provider = Integer.parseInt(request.getParameter("providerId"+chargeId));
            if(request.getParameter("chk" + chargeId) != null) {
                batchChgPs.setInt(1, chargeId);
                batchChgPs.setInt(2, provider);
                batchChgPs.execute();
            }
        } else if(name.length()>10 && name.substring(0,10).equals("deductable")) {
            if(insurancePatientId != null) {
                amountString = request.getParameter(name);
                if(amountString !=  null) {
                    amountString=amountString.replaceAll("\\$", "").replaceAll(",","");
                } else {
                    amountString="0.0";
                }
                amount = BigDecimal.valueOf(Double.parseDouble(amountString));
                if (amount.longValue() > 0.0) {
                    PreparedStatement dedPs=io.getConnection().prepareStatement("INSERT INTO deductables (batchid, patientid, `date`, amount) VALUES(?,?,?,?) ON DUPLICATE KEY UPDATE amount=amount+?");
                    dedPs.setString(1, batchId);
                    dedPs.setString(2, insurancePatientId);
                    dedPs.setString(3, Format.formatDate(name.substring(10),"yyyy-MM-dd"));
                    dedPs.setLong(4, amount.longValue());
                    dedPs.setLong(5, amount.longValue());
                    dedPs.execute();
                }
            }
        }
    }
//    if (returnUrl != null) {
//        if(returnUrl.contains("?")) {
//            response.sendRedirect(returnUrl+"&posted=Y");
//        } else {
//            response.sendRedirect(returnUrl+"?posted=Y");
//        }
//    } else if(parentLocation != null) {
        out.print("<script type=\"text/javascript\">self.close();</script>");
        session.removeAttribute("batchId");
        session.removeAttribute("today");
//    }
%>
