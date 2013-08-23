<%-- 
    Document   : applybulkpayments
    Created on : Nov 19, 2010, 2:31:47 PM
    Author     : rwandell
--%>
<SCRIPT language=JavaScript>
    function win(parent){
        if(parent != null) { window.opener.location.href=parent }
        self.close();
    }
</SCRIPT>
<%@include file="globalvariables.jsp" %>
<%
    String checkNumber = request.getParameter("checknumber");
    String providerId = request.getParameter("provider");
    String amount = request.getParameter("amount");
    String transactionDate=request.getParameter("date");
    String parentLocation=(String)session.getAttribute("parentLocation");

    double remainingAmount = 0.0;
    double paymentAmount = 0.0;
    double totalPayments = 0.0;

    try {
        transactionDate=Format.formatDate(transactionDate, "yyyy-MM-dd");
    } catch (Exception e) {
        transactionDate=Format.formatDate(new java.util.Date(), "yyyy-MM-dd");
    }

    if(checkNumber.trim().equals("")) { checkNumber="BULK_" + Format.formatDate(transactionDate,"yyyyMMdd"); }

    String insertSQL = "INSERT INTO payments (patientid, provider, checknumber, amount, date, chargeid, parentpayment, originalamount) VALUES(?,?,?,?,?,?,?,?)";
    PreparedStatement lPs=io.getConnection().prepareStatement(insertSQL);
    lPs.setInt(1, patient.getId());
    lPs.setString(2, providerId);
    lPs.setString(3, checkNumber);
    lPs.setString(4, amount.replaceAll("\\$","").replaceAll(",",""));
    lPs.setString(5, transactionDate);
    lPs.setInt(6, 0);
    lPs.setInt(7,0);
    lPs.setString(8, amount.replaceAll("\\$","").replaceAll(",",""));
    lPs.execute();

    remainingAmount = Double.parseDouble(amount.replaceAll("\\$","").replaceAll(",",""));

    io.setMySqlLastInsertId();
    int parentPayment=io.getLastInsertedRecord();

    String chargeQuery="SELECT c.id, (c.chargeamount*quantity) as chargeamount, IFNULL((SELECT SUM(amount) FROM payments WHERE chargeid=c.id),0) AS balance " +
            "FROM visits v " +
            "LEFT JOIN charges c ON v.id=c.visitid " +
            "WHERE v.patientid=" + patient.getId() + " AND c.id IS NOT NULL " +
            "ORDER BY v.`date` DESC, c.id";

    ResultSet chgRs=io.opnRS(chargeQuery);
    while(chgRs.next() && remainingAmount>0) {
        paymentAmount=chgRs.getDouble("chargeamount")-chgRs.getDouble("balance");

        if(paymentAmount>remainingAmount) { paymentAmount=remainingAmount; }
        lPs.setDouble(4, paymentAmount);
        lPs.setInt(6, chgRs.getInt("id"));
        lPs.setInt(7, parentPayment);
        lPs.setDouble(8, paymentAmount);
        lPs.execute();

        remainingAmount-=paymentAmount;
        totalPayments+=paymentAmount;
    }

    chgRs.close();
    chgRs=null;

    PreparedStatement uPs=io.getConnection().prepareStatement("UPDATE payments SET amount=amount-? WHERE id=?");
    uPs.setDouble(1, totalPayments);
    uPs.setInt(2, parentPayment);
    uPs.execute();

%>
<body onLoad="win('<%= parentLocation %>')">
<body>