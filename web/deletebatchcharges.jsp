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
    Enumeration parms = request.getParameterNames();
    String name;

// Set up work variables that will be used to populate each batch charge
    int batchChargeId;
    
// Instantiate some objects to represent the database relationships
    BatchCharge thisCharge = new BatchCharge(io, 0);
    
// Roll through all of the parameters. Whenever we find a checkAmount, then there's work to be done.
    while (parms.hasMoreElements()) {
        name=(String)parms.nextElement();

// If this is a checkAmount, get the suffix because that represents the charge ID
        if (name.length()>2 && name.endsWith("_cb") && name.substring(0,2).equals("cb")) {
            batchChargeId = Integer.parseInt(name.substring(2, name.indexOf("_cb")));
          
// Set up the Batch Instance
            thisCharge.setId(batchChargeId);
            thisCharge.next();

// Now, delete the batch.
            thisCharge.delete();
            
        }
    }

%>
<%
    if(returnUrl.equals("")) { %>
        <body onLoad="win('<%= parentLocation %>')">
        <body>
<%    }
%>

