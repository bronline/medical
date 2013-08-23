<%@ include file="globalvariables.jsp" %>
<%@ page import="javax.print.DocFlavor" %>

<%
    String targetFile  = "";
    String targetDir   = "";
    String id          = request.getParameter("id");
    String batchId     = request.getParameter("batchId");
    String today       = Format.formatDate(new java.util.Date(), "yyyyMMdd");
    String descDate    = Format.formatDate(new java.util.Date(), "MM/dd/yyyy");

    RWPDFDocument pdfDoc = new RWPDFDocument();

    if(patient.next()) {
        patient.beforeFirst();
        String myQuery = "select * from documenttemplates where id=" + id;

        ResultSet dRs = io.opnRS(myQuery);
        if(dRs.next()) {

            String documentName          = dRs.getString("pathtotemplate");
            int type                     = dRs.getInt("type");
            int identifier               = dRs.getInt("identifier");
            String description           = dRs.getString("description");
            int patientId                = patient.getId();
            targetFile                   = env.getDocumentPath();
            targetDir                    = env.getBrowserPath();
            String sourceDir             = env.getDocumentPath();
            String printer               = env.getDefaultPrinter();
            int detailLines              = 0;
            double dollars               = 0;
            double totalDollars          = 0;
            double totalCents            = 0;

            Document doc  = new Document(io, patientId, type, identifier);

            doc.checkDir(targetFile);

            targetFile = targetFile + patientId + "\\";
            targetDir += patientId + "/";
            doc.checkDir(targetFile);

            targetFile += doc.getTypeDescription() + "\\";
            targetDir += doc.getTypeDescription() + "/";
            doc.checkDir(targetFile);

            targetFile += doc.getIdentifierDescription() + "\\";
            targetDir += doc.getIdentifierDescription() + "/";
            doc.checkDir(targetFile);

            targetFile += today;

            ResultSet [] lRs = new ResultSet[2];
            ResultSet dMap = io.opnRS("select * from rwcatalog.documentmap");
            ResultSet rMap = io.opnRS("select * from rwcatalog.repeatingmap");
            lRs[0] = io.opnRS("SELECT * FROM cms1500data c where id=" + patient.getId());
            ResultSet pChg;

            if(lRs[0].next()) {
                pChg = io.opnRS("select * from cms1500charges where patientid=" + lRs[0].getString("id") + " and batchid=" + batchId);
                lRs[1] = io.opnUpdatableRS("select * from cms1500total");
                while(lRs[1].next()) {
                    lRs[1].deleteRow();
                }

                detailLines = 0;
                while(pChg.next()) {
                    if(detailLines>5) {
                        dollars = (totalCents * .01);
                        lRs[1].moveToInsertRow();
                        lRs[1].updateDouble("totaldollars", totalDollars + dollars);
                        lRs[1].updateDouble("totalcents", totalCents - dollars);
                        lRs[1].updateDouble("balancedollars", totalDollars + dollars);
                        lRs[1].updateDouble("balancecents", totalCents - dollars);
                        lRs[1].insertRow();
                        detailLines = 0;
                        totalDollars = 0;
                        totalCents = 0;
                    }
                    detailLines ++;
                    totalDollars += pChg.getDouble("dollars");
                    totalCents += pChg.getDouble("cents");
                }

                if(detailLines>0) {
                    dollars = totalCents * .01;
                    lRs[1].moveToInsertRow();
                    lRs[1].updateDouble("totaldollars", totalDollars + dollars);
                    lRs[1].updateDouble("totalcents", totalCents - dollars);
                    lRs[1].updateDouble("balancedollars", totalDollars + dollars);
                    lRs[1].updateDouble("balancecents", totalCents - dollars);
                    lRs[1].insertRow();
                    detailLines = 0;
                    totalDollars = 0;
                    totalCents = 0;
                }

                pdfDoc.setDocumentMap(dMap);
                pdfDoc.setRepeatingMap(rMap);
                pdfDoc.setDocumentData(lRs);
                pdfDoc.setRepeatingData(pChg);
                
                pdfDoc.setAcrobatVersion(PrintPdf.ACROBAT7);
                pdfDoc.setPrinterName(printer);
                pdfDoc.setPrintFinishedDocument(false);
                
                pdfDoc.setNumberOfRepeatingRows(6);
                
                pdfDoc.replaceDocumentFields(documentName, targetFile);
            }

            String [] documentList = pdfDoc.getDocumentList();
            for(int d=0; d<documentList.length; d ++) {
                patient.updatePatientDocumentInfo(type, identifier, documentList[d], "Billing batch " + batchId + " billed on " + descDate);
            }

        }

        dRs.close();

    }

%>
