<%@include file="globalvariables.jsp" %>
<SCRIPT language=JavaScript>
<!-- 
function win(where){
window.opener.location.href=where;
self.close();
//-->
}
</SCRIPT>
<%
// Set up work variables to process the request parameters
    String parentLocation = (String)session.getAttribute("parentLocation");
    String returnUrl = (String)session.getAttribute("returnUrl");
    String name;

// Set up work variables that will be used to populate each of the charges in the batch
    int batchId = Integer.parseInt(request.getParameter("id"));
    
// Instantiate some objects to represent the database relationships
    BatchCharge theseCharges = new BatchCharge(io, 0);
    BatchCharge thisCharge = new BatchCharge(io, 0);
    Batch thisBatch = new Batch(io, 0);
    
// Set up the Batch Instance
    thisBatch.setId(batchId);
    thisBatch.next();

// Now, delete the batch.
    thisBatch.delete();
            
// Now, delete the batch's charges.
    theseCharges.setResultSet(io.opnRS("select * from batchcharges where batchid = " + batchId));
    while (theseCharges.next()) {
        thisCharge = new BatchCharge(io, theseCharges.getInt("id"));
        thisCharge.delete();
    }
%>
<%
    if(returnUrl.equals("")) { %>
        <body onLoad="win('<%= parentLocation %>')">
        <body>
<%    }
%>

