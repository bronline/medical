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
    String delete = request.getParameter("delete");
    String parentLocation = (String)session.getAttribute("parentLocation");
    String batchId        = request.getParameter("batchId");
    String today          = request.getParameter("today");

// Set up work variables to process the request parameters
    String returnUrl = (String)session.getAttribute("returnUrl");
    String name;

// Set up work variables that will be used to populate each of the payments
    int id=0;
    int provider=0;
    String checkNumber="";
    BigDecimal amount=null;
    int chargeId=0;
    int patientId=0;
    int parentPayment=0;
    java.util.Date date=null;
    BigDecimal originalAmount=null;

    if (request.getParameter("ID")!=null) {id = Integer.parseInt(request.getParameter("ID")); }
    if (request.getParameter("provider")!=null) {provider = Integer.parseInt(request.getParameter("provider")); }
    if (request.getParameter("checknumber")!=null&&!request.getParameter("checknumber").trim().equals("")) {checkNumber = request.getParameter("checknumber"); }
    if (request.getParameter("amount")!=null) {amount = BigDecimal.valueOf(Double.parseDouble(request.getParameter("amount"))); }
    if (request.getParameter("chargeid")!=null) {chargeId = Integer.parseInt(request.getParameter("chargeid")); }
    if (request.getParameter("patientid")!=null) {patientId = Integer.parseInt(request.getParameter("patientid")); }
    if (request.getParameter("parentpayment")!=null) {parentPayment = Integer.parseInt(request.getParameter("parentpayment")); }
    if (request.getParameter("date")!=null) {date = new java.util.Date(request.getParameter("date")); }
    if (request.getParameter("originalamount")!=null) {originalAmount = BigDecimal.valueOf(Double.parseDouble(request.getParameter("originalamount"))); }

    Payment thisPayment = new Payment(io, id);
    thisPayment.setCheckNumber("");
    if (request.getParameter("provider")!=null) {thisPayment.setProvider(provider); }
    if (request.getParameter("checknumber")!=null&&!request.getParameter("checknumber").trim().equals("")) {thisPayment.setCheckNumber(checkNumber); }
    if (request.getParameter("amount")!=null) {thisPayment.setAmount(amount); }
    if (request.getParameter("chargeid")!=null) {thisPayment.setChargeId(chargeId); }
    if (request.getParameter("patientid")!=null) {thisPayment.setPatientId(patientId); }
    if (request.getParameter("date")!=null) {thisPayment.setDate(date); }
    if (request.getParameter("parentpayment")!=null) {thisPayment.setParentPayment(parentPayment); }
    if (request.getParameter("originalamount")!=null) {thisPayment.setOriginalAmount(originalAmount); }

    if(thisPayment.getCheckNumber().trim().equals("")) { thisPayment.setCheckNumber("PMT_"+Format.formatDate(date, "yyyyMMdd")); }
    
    thisPayment.update();
    if (delete!=null && delete.equalsIgnoreCase("Y")) {
        thisPayment.delete();
        PreparedStatement eobExceptionPs=io.getConnection().prepareStatement("delete from eobexceptions where paymentid=" + id);
        PreparedStatement childPaymentPs=io.getConnection().prepareStatement("delete from payments where parentpayment=" + id);

        if(id != 0) {
            eobExceptionPs.execute();
            childPaymentPs.execute();
        }
    }
    
    if((batchId !=null && !batchId.equals("")) || (today != null && !today.equals(""))) { 
        session.setAttribute("closeWhenDone", session.getAttribute("parentLocation"));
        session.setAttribute("batchId", batchId);
        session.setAttribute("today", today);
        out.print("<script type=\"text/javascript\">self.close();window.open(\"applypayments.jsp?checkNumber=" + thisPayment.getCheckNumber() + "&parentPayment=" + thisPayment.getId() + "&checkAmount=" + thisPayment.getAmount() + "&providerId=" + thisPayment.getProvider() + "\",\"Apply\",\"width=800,height=550,scrollbars=no,left=100,top=100,\");</script>");
    }
    
    if(returnUrl.equals("")) { 
        out.print("<body onLoad=\"win('" + parentLocation + "')\"></body>");
    }
%>
