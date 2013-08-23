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
    RWConnMgr cms1500Io = new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", io.MYSQL);
    RWConnMgr mapIo = new RWConnMgr("localhost", "rwcatalog", "rwtools", "rwtools", io.MYSQL);

    int patientId      = 0;
    int type           = 0;
    int identifier     = 0;

    ArrayList elem = new ArrayList();
    String var = "";
    String batchList = "";
    String batchQuery   = "";
    String patId = request.getParameter("patientId");
    String printer = env.getDefaultPrinter();
    int printType = 2;

    int batchId=0;

// Instantiate some objects to represent the database relationships
    Batch thisBatch = new Batch(io, 0);
    // Set up work variables to process the request parameters
    String parentLocation = (String)session.getAttribute("parentLocation");
    String returnUrl = (String)session.getAttribute("returnUrl");
    String batchPrintType = request.getParameter("batchPrintType");
    String name;
    String close="Y";
    String documentRoot="C:\\Inetpub\\vhosts\\chiropracticeonline.net\\httpdocs\\medicaldocs\\" + databaseName;
    String httpRoot="http://chiropracticeonline.net/medicaldocs/" + databaseName;
    checkDir(documentRoot, thisBatch.getDocumentMap());
//    checkDir(billingEnv.getString("documentpath"), thisBatch.getDocumentMap());
    String fileName="";
    String pdfFileName="";
    String textFileName="";
    String str="";
    com.lowagie.text.Document document = new com.lowagie.text.Document(com.lowagie.text.PageSize.LETTER, 100, 0, 50, 50);
    com.lowagie.text.pdf.PdfWriter writer = com.lowagie.text.pdf.PdfWriter.getInstance(document, new java.io.FileOutputStream(documentRoot + "\\sample.pdf"));

    for(Enumeration e = request.getParameterNames(); e.hasMoreElements();) {
       var=(String)e.nextElement();
       if(var.substring(0,3).equals("chk")) { elem.add(var.substring(3)); }
    }

    for(int x=0; x<elem.size(); x++) {
       if(!batchList.equals("")) { batchList += ", "; }
       batchList += "'" + (String)elem.get(x) + "'";
    }

    try {
        printType=Integer.parseInt(batchPrintType);
    } catch (Exception parseIntException) {
        printType = 2;
    }

    PagePrinter pagePrinter = new PagePrinter("");

    if(batchList != null && !batchList.equals("")) {
        batchQuery = "select * from patientsinbatch where batchid in (" + batchList + ") and patientId = " + patId + " order by name";

        ResultSet bRs = io.opnRS(batchQuery);
        bRs.last();
        int patients = bRs.getRow();
        bRs.beforeFirst();

        boolean pdfOpen=false;
        boolean fileOpen=false;

        while(bRs.next()) {
        // Set up the Batch Instance
            thisBatch.setId(bRs.getInt("batchid"));
            thisBatch.next();

            setDocumentMap(io, thisBatch);
            thisBatch.setBillPrintType(printType);
            if(printType == 2) {
                thisBatch.setRepeatingOffset(24);
            } else {
                thisBatch.setDocumentMap("CMS1500TEXT");
                thisBatch.setRepeatingOffset(2);
            }

            documentRoot=checkDir(documentRoot, patId);
            documentRoot=checkDir(documentRoot, "bills");
            
    //        checkDir(billingEnv.getString("documentpath"), thisBatch.getDocumentMap());
            if(printType==1  && !fileOpen) {
//                textFileName=thisBatch.getDocumentMap() + "/" + Format.formatDate(new java.util.Date(), "yyyyMMdd")+ "/" + Format.formatDate(new java.util.Date(), "yyyyMMdd");
                str=documentRoot;
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
            } else if(printType==2 && !pdfOpen) {
//            if(!pdfOpen) {
//                pdfFileName=thisBatch.getDocumentMap() + "/" + Format.formatDate(new java.util.Date(), "yyyyMMdd");
                str=documentRoot + "\\" + Format.formatDate(new java.util.Date(), "yyyyMMdd");
                document = new com.lowagie.text.Document(com.lowagie.text.PageSize.LETTER, 100, 0, 50, 50);
                writer = com.lowagie.text.pdf.PdfWriter.getInstance(document, new java.io.FileOutputStream(str + ".pdf"));
                document.open();
                pdfOpen=true;
            }

            cms1500Io.getConnection().close();
            mapIo.getConnection().close();
            cms1500Io.setConnection(cms1500Io.opnmySqlConn());
            mapIo.setConnection(mapIo.opnmySqlConn());

            CMS1500 cms1500=new CMS1500(cms1500Io, mapIo);
//            if(thisBatch.getBillPrintType()==0) { cms1500.setPagePrinter(pagePrinter); }
            if(thisBatch.getBillPrintType()==1) {  }
            if(thisBatch.getBillPrintType()==2) { cms1500.setPdfDocument(document); cms1500.setWriter(writer); }

            cms1500.setTextFileLocation(str);
            cms1500.setPrintType(printType);
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

            System.gc();

        // Now, update the batch.
            thisBatch.update();
        }

        out.print("<body>");
        if(pdfOpen) {
            document.close();
            out.print("<script type=\"text/javascript\">window.open(\"" + httpRoot +  "/" + patId + "/bills/" + Format.formatDate(new java.util.Date(), "yyyyMMdd") + ".pdf\",\"PDF\")</script>");
        }
        if(fileOpen) {
            out.print("<script type=\"text/javascript\">window.open(\"" + httpRoot +  "/" + patId + "/bills/" + Format.formatDate(new java.util.Date(), "yyyyMMdd") + ".txt\",\"TEXT\")</script>");
        }

        out.print("<script type=\"text/javascript\">location.href=\"bills.jsp\"</script>");
        out.print("</body>");

        cms1500Io.getConnection().close();
        cms1500Io=null;
        System.gc();

        bRs.close();
    }

//    response.sendRedirect("bills.jsp");

%>
<%! public String checkDir(String documentPath, String mapFolder) {
    // Make the document directory if it doesn't exist
        java.io.File documentDir = new java.io.File(documentPath + "\\" + mapFolder);
        if (!documentDir.exists()) {
            documentDir.mkdir();
        }

        return documentPath + "\\" + mapFolder;
    }

    public void setDocumentMap(RWConnMgr io, Batch thisBatch) {
        try {
            ResultSet lRs = io.opnRS("select paperbillmap from environment");
            if(lRs.next()) {
                thisBatch.setDocumentMap(lRs.getString("paperbillmap"));
                thisBatch.setBillPrintType(2);
                thisBatch.setRepeatingOffset(24);
            }
            lRs.close();
            lRs=null;
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }
%>