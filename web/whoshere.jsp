<%@ page import="tools.*, medical.LocationOccupancy" %>
<link rel="stylesheet" type="text/css" href="css/stylesheet.css" title="stylesheet">

<script>
  var timer = 15;
  function countdown() {
    if(timer > 0) {
      countdown.value = timer;
      timer -= 1;
      setTimeout("countdown()",1000);
    } else {
      location.href="whoshere.jsp";
    }
  }
</script>
<title>Who is waiting</title>
<body onLoad="countdown()" topmargin="0" leftmargin="0" bottommargin="0" style="background: silver" >
<%
    String databaseName = (String)session.getAttribute("databaseName");
    String databaseUser = databaseName;

    RWConnMgr io=new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);

//    LocationOccupancy lOccup = (LocationOccupancy)session.getAttribute("whoshere");
    String id = (String)session.getAttribute("locationId");

// Create a new LocationOccupancy object if one does not exist
//    if(lOccup == null) { 
      LocationOccupancy lOccup = new LocationOccupancy(io, "whoshere.jsp", id); 
//    } else {
//        lOccup.setLocationId(id);
//    }
    
// Save the LocationOccupancy object as a session variable
//    session.setAttribute("whoshere", lOccup);
    session.setAttribute("parentLocation", "whoshere.jsp");
    session.setAttribute("returnUrl", "whoshere.jsp");

    out.print( lOccup.getLocationOccupancy() );

    io.getConnection().close();

    lOccup=null;
    io=null;

    System.gc();
%>
