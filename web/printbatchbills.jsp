<%@include file="globalvariables.jsp" %>
<SCRIPT language=JavaScript>
<!--
function win(where,close){
    if(where != '' && where != null) { window.opener.location.href=where; }
    if(close=='Y') {
        self.close();
    }
//-->
}
</SCRIPT>
<%
// Set up work variables that will be used to populate each of the charges in the batch
    int batchId = 0;
    String selection = request.getParameter("selectedBills");
    String batchList=null;
    String patId="";
    String batchQuery   = "";
    String printer      = "";

// Instantiate some objects to represent the database relationships
    RWConnMgr batchIo = new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);
    Batch thisBatch = new Batch(batchIo, 0);

    RWConnMgr cms1500Io = new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);
    RWConnMgr mapIo = new RWConnMgr("localhost", "rwcatalog", "rwtools", "rwtools", RWConnMgr.MYSQL);

    Environment billingEnv = new Environment(batchIo);
    billingEnv.refresh();

// Check to see if a batch ID was passed
    if(request.getParameter("id")!=null) {
        batchId=Integer.parseInt(request.getParameter("id"));
    }

    // Set up work variables to process the request parameters
    String parentLocation = (String)session.getAttribute("parentLocation");
    String returnUrl = (String)session.getAttribute("returnUrl");
    String name;
    String close="Y";
    String documentRoot="C:\\Inetpub\\vhosts\\chiropracticeonline.net\\httpdocs\\medicaldocs\\" + databaseName;
    String httpRoot="http://chiropracticeonline.net/medicaldocs/" + databaseName + "/";
    checkDir(documentRoot, thisBatch.getDocumentMap());
//    checkDir(billingEnv.getString("documentpath"), thisBatch.getDocumentMap());
    String fileName="";
    String pdfFileName="";
    String textFileName="";
    String str="";
    String backgroundImage="C:\\Inetpub\\vhosts\\chiropracticeonline.net\\httpdocs\\medicaldocs\\";
    com.lowagie.text.Document document = new com.lowagie.text.Document(com.lowagie.text.PageSize.LETTER, 100, 0, 50, 50);
    com.lowagie.text.pdf.PdfWriter writer = com.lowagie.text.pdf.PdfWriter.getInstance(document, new java.io.FileOutputStream(documentRoot + "\\sample.pdf"));
//    com.lowagie.text.pdf.PdfWriter writer = com.lowagie.text.pdf.PdfWriter.getInstance(document, new java.io.FileOutputStream(billingEnv.getString("documentpath") + "\\sample.pdf"));

    // Check to see if multiple batches were selected
    if(selection != null ) {
        String var;
        ArrayList elem = new ArrayList();
        for(Enumeration e = request.getParameterNames(); e.hasMoreElements();) {
           var=(String)e.nextElement();
           if(var.length()>3 && var.substring(0,3).equals("chk")) { elem.add(var.substring(3)); }
        }

        for(int x=0; x<elem.size(); x++) {
           if(batchList != null && !batchList.equals("")) { batchList += ", "; } else { batchList=""; }
           batchList += "'" + (String)elem.get(x) + "'";
        }
    }

    PagePrinter pagePrinter = new PagePrinter("");

// Generate the bills
    if(batchList == null) {
        batchQuery = "select * from patientsinbatch where batchid=" + batchId + " order by name";
    } else {
        batchQuery = "select * from patientsinbatch where batchid in(" + batchList + ") order by name";
    }

    String today        = Format.formatDate(new java.util.Date(), "yyyyMMdd");
    String descDate     = Format.formatDate(new java.util.Date(), "MM/dd/yyyy");

    int patientId      = 0;
    int type           = 0;
    int identifier     = 0;

    ResultSet bRs = batchIo.opnRS(batchQuery);
    bRs.last();
    int patients = bRs.getRow();
    bRs.beforeFirst();

    boolean pdfOpen=false;
    boolean fileOpen=false;

    while(bRs.next()) {
    // Set up the Batch Instance
        thisBatch.setId(bRs.getInt("batchid"));
        thisBatch.next();

        if(thisBatch.getBillPrintType() == 0) { printer=billingEnv.getDefaultPrinter(); pagePrinter=new PagePrinter(printer); }

        checkDir(documentRoot, thisBatch.getDocumentMap());
//        checkDir(billingEnv.getString("documentpath"), thisBatch.getDocumentMap());
        if(thisBatch.getBillPrintType()==1  && !fileOpen) {
            textFileName=thisBatch.getDocumentMap() + "/" + Format.formatDate(new java.util.Date(), "yyyyMMdd")+ "/" + Format.formatDate(new java.util.Date(), "yyyyMMdd");
            str=documentRoot + "\\" + thisBatch.getDocumentMap() +"\\" + Format.formatDate(new java.util.Date(), "yyyyMMdd") + "\\";
//            str=billingEnv.getString("documentpath")+ thisBatch.getDocumentMap() +"\\" + Format.formatDate(new java.util.Date(), "yyyyMMdd");
            java.io.File f = new java.io.File (str);
            String [] fileList = f.list();
            if(fileList != null) {
                for(int k=0;k<fileList.length;k++) {
                    java.io.File file = new java.io.File(str + fileList[k]);
                    if(file.isFile()) { 
                        file.delete();
                    }
                }
            }
            fileOpen=true;
        } else if(thisBatch.getBillPrintType()==2 && !pdfOpen) {
            pdfFileName=thisBatch.getDocumentMap() + "/" + Format.formatDate(new java.util.Date(), "yyyyMMdd");
            str=documentRoot + "\\" + thisBatch.getDocumentMap() +"\\" + Format.formatDate(new java.util.Date(), "yyyyMMdd");
//            str=billingEnv.getString("documentpath")+ thisBatch.getDocumentMap() +"\\" + Format.formatDate(new java.util.Date(), "yyyyMMdd");
            document = new com.lowagie.text.Document(com.lowagie.text.PageSize.LETTER, 100, 0, 50, 50);
            writer = com.lowagie.text.pdf.PdfWriter.getInstance(document, new java.io.FileOutputStream(str + ".pdf"));
            document.open();
            backgroundImage += thisBatch.getDocumentMap() + ".jpg";
            pdfOpen=true;
        }

        cms1500Io.getConnection().close();
        mapIo.getConnection().close();
        cms1500Io.setConnection(cms1500Io.opnmySqlConn());
        mapIo.setConnection(mapIo.opnmySqlConn());

        CMS1500 cms1500=new CMS1500(cms1500Io, mapIo);
        if(thisBatch.getBillPrintType()==0) { cms1500.setPagePrinter(pagePrinter); }
        if(thisBatch.getBillPrintType()==1) { cms1500.setTextFileLocation(str); }
        if(thisBatch.getBillPrintType()==2) { cms1500.setPdfDocument(document); cms1500.setWriter(writer); }

        cms1500.setPrintType(thisBatch.getBillPrintType());
        cms1500.setMapDocument(thisBatch.getDocumentMap());
        cms1500.setRepeatingOffset(thisBatch.getRepeatingOffset());

        cms1500.print(bRs.getString("batchId"), bRs.getString("patientid"));

        cms1500=null;
        System.gc();

    // Now, mark this batch as billed.
    // 03-02-08 changed to update last bill date and only update billed when null (Randy)
        if(thisBatch.getBilled() == null) {
            thisBatch.setBilled(new java.util.Date());
        }

        thisBatch.setLastBillDate(new java.util.Date());

    // Now update the insurance active flag for those patients who have reached their max number of visits for this provider
//        String updSQL="UPDATE patientinsurance " +
//                "LEFT JOIN providers ON providers.id=patientinsurance.providerid " +
//                "SET active=0 " +
//                "WHERE " +
//                "  providers.effectivedate<>'0001-01-01' AND" +
//                "  providerid=" + thisBatch.getInt("providerid") + " AND" +
//                "  active=1 and" +
//                "  patientid IN (" +
//                "    SELECT DISTINCT" +
//                "      v.patientid" +
//                "    FROM batches b" +
//                "    LEFT JOIN batchcharges bc ON b.id=bc.batchid" +
//                "    LEFT JOIN charges c ON c.id=bc.chargeid" +
//                "    LEFT JOIN visits v ON v.id=c.visitid" +
//                "    WHERE provider=576 AND v.id IS NOT NULL" +
//                "    GROUP BY v.patientid" +
//                "    HAVING COUNT(*)>(CASE WHEN patientinsurance.insurancevisits=0 THEN CASE WHEN providers.numberofvisits=0 THEN 9999 ELSE providers.numberofvisits END ELSE patientinsurance.insurancevisits END)" +
//                "  )";

//        RWConnMgr tempIo = new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);
//        PreparedStatement patInsPs=tempIo .getConnection().prepareStatement(updSQL);
//        patInsPs.execute();
//        tempIo.getConnection().close();
//        tempIo=null;

        System.gc();

    // Now, update the batch.
        thisBatch.update();
    }

    out.print("<body>");
    if(pdfOpen) {
        document.close();
        PDF.applyBackgroundImage(str + ".pfd", str + "I.pdf" , backgroundImage );
        out.print("<script type=\"text/javascript\">window.open(\"" + httpRoot +  pdfFileName + ".pdf\",\"PDF\")</script>");
//        out.print("<script type=\"text/javascript\">window.open(\"" + billingEnv.getBrowserPath() +  pdfFileName + ".pdf\",\"PDF\")</script>");
    }
    if(fileOpen) {
        out.print("<script type=\"text/javascript\">window.open(\"" + httpRoot +  textFileName + ".txt\",\"TEXT\")</script>");
//        out.print("<script type=\"text/javascript\">window.open(\"" + billingEnv.getBrowserPath() +  textFileName + ".txt\",\"TEXT\")</script>");
    }

    out.print("<br><br><b>Printing complete...</b><br><br><input type=button value=\"close\" class=\"button\" onClick=\"window.opener.location.href='batches.jsp'; self.close()\"></body>");

    cms1500Io.getConnection().close();
    cms1500Io=null;
    System.gc();

    bRs.close();
    batchIo.getConnection().close();

%>
<%!     public void checkDir(String documentPath, String mapFolder) {
    // Make the document directory if it doesn't exist
        java.io.File documentDir = new java.io.File(documentPath + "\\" + mapFolder);
        if (!documentDir.exists()) {
            documentDir.mkdir();
        }
    }
%>