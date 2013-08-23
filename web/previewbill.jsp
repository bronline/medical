<%@ include file="globalvariables.jsp" %>
<script>
    function showPage(pageNumber) {
        showHide('page'+pageNumber,'TABLE');
        linkOn('link'+pageNumber,'B');
    }
    
    function showHide(name,type) {
        var divs=document.getElementsByTagName(type);
        for(k=0;k<divs.length;k++) {
            if(divs[k].id.match(name)) {
                divs[k].style.visibility='visible';
                divs[k].style.display='';
            } else {
                divs[k].style.visibility='hidden';
                divs[k].style.display='none';
            }
        }
    }
    
    function linkOn(name,type) {
        var divs=document.getElementsByTagName(type);        
        for(k=0;k<divs.length;k++) {
            if(divs[k].id.match(name)) {
                divs[k].style.fontWeight='BOLD';
            } else {
                divs[k].style.fontWeight='NORMAL';
            }
        }
    }

</script>
<body style='margin-top: 0;'>
 <%
    String printer      = env.getDefaultPrinter();
    String id           = "";
    String batchQuery   = "";
    
    String today        = Format.formatDate(new java.util.Date(), "yyyyMMdd");
    String descDate     = Format.formatDate(new java.util.Date(), "MM/dd/yyyy");
    
    String patientId      = request.getParameter("patientId");
    String batchId        = request.getParameter("batchId");
    
    RWConnMgr mapIo = new RWConnMgr("localhost", "rwcatalog", "rwtools", "rwtools", RWConnMgr.MYSQL);
    
//    PagePrinter pagePrinter = new PagePrinter(env.getDefaultPrinter());
    CMS1500 cms1500=new CMS1500(io, mapIo);
//    cms1500.setPagePrinter(pagePrinter);
    
    batchQuery = "select * from patientsinbatch where batchid in (" + batchId + ") and patientId = " + patientId + " order by name";
    ResultSet bRs = io.opnRS(batchQuery);
    
    bRs.last();
    int patients = bRs.getRow();
    bRs.beforeFirst();
    
    if(bRs.next()) {
        out.print(cms1500.preview(bRs.getString("batchId"), bRs.getString("patientid")));
    }

    bRs.close();

    cms1500=null;
    System.gc();
    %>
</body>
