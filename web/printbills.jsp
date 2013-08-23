<%
    String id           = "";
    String batchQuery   = "";

    String today        = Format.formatDate(new java.util.Date(), "yyyyMMdd");
    String descDate     = Format.formatDate(new java.util.Date(), "MM/dd/yyyy");

    RWConnMgr cms1500Io = new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", io.MYSQL);
    RWConnMgr mapIo = new RWConnMgr("localhost", "rwcatalog", "rwtools", "rwtools", io.MYSQL);
    
    int patientId      = 0;
    int type           = 0;
    int identifier     = 0;

    if (batchList!=null) {
        batchQuery = "select * from patientsinbatch where batchid in (" + batchList + ") and patientId = " + patId + " order by name";
    } else {
        batchQuery = "select * from patientsinbatch where batchid=" + batchId + " order by name";
    }
    
    ResultSet bRs = io.opnRS(batchQuery);
    bRs.last();
    int patients = bRs.getRow();
    bRs.beforeFirst();

    while(bRs.next()) {             
        cms1500Io.getConnection().close();
        mapIo.getConnection().close();
        cms1500Io.setConnection(cms1500Io.opnmySqlConn());
        mapIo.setConnection(mapIo.opnmySqlConn());

        CMS1500 cms1500=new CMS1500(cms1500Io, mapIo);
        if(thisBatch.getBillPrintType()==1) { cms1500.setPagePrinter(pagePrinter); }
        if(thisBatch.getBillPrintType()==2) { cms1500.setPdfDocument(document); cms1500.setWriter(writer); }

        cms1500.setPrintType(thisBatch.getBillPrintType());
        cms1500.setMapDocument(thisBatch.getDocumentMap());
        cms1500.setRepeatingOffset(thisBatch.getRepeatingOffset());

        cms1500.print(bRs.getString("batchId"), bRs.getString("patientid"));
        
        cms1500=null;
        System.gc();

    }
    
    cms1500Io.getConnection().close();
    cms1500Io=null;
    System.gc();

    bRs.close();

%>
<%!     public void checkDir(String documentPath, String mapFolder) {
    // Make the document directory if it doesn't exist
        java.io.File documentDir = new java.io.File(documentPath + "\\" + mapFolder);
        if (!documentDir.exists()) {
            documentDir.mkdir();
        }
    }
%>