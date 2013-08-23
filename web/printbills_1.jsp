<%
    String printer      = env.getDefaultPrinter();
    String id           = "";

    String today        = Format.formatDate(new java.util.Date(), "yyyyMMdd");
    String descDate     = Format.formatDate(new java.util.Date(), "MM/dd/yyyy");
    String sourceDir    = "";
    String targetFile   = "";
    String targetDir    = "";
    String documentName = "";
    String description  = "";

    int patientId      = 0;
    int type           = 0;
    int identifier     = 0;

    int detailLines    = 0;
    int dollars        = 0;
    int totalDollars   = 0;
    int totalCents     = 0;

    ResultSet cms1500Doc = io.opnRS("select * from documenttemplates where description='CMS1500'");
    if(cms1500Doc.next()) { id = cms1500Doc.getString("id"); }

    RWPDFDocument pdfDoc = new RWPDFDocument();
    Document doc = new Document(io);

    ResultSet docRs = io.opnUpdatableRS("select * from batchbills where id=0");

    if(thisBatch.getBilled() == null) {
        String myQuery = "select * from documenttemplates where id=" + id;

        ResultSet dRs = io.opnRS(myQuery);
        if(dRs.next()) {

            type = dRs.getInt("type");
            identifier = dRs.getInt("identifier");

            doc.setDocumentType(type);
            doc.setDocumentIdentifier(identifier);

            double x                = 0.000;

            ResultSet bRs = io.opnRS("select * from patientsinbatch where batchid=" + batchId + " order by name");

            bRs.last();
            int patients = bRs.getRow();
            bRs.beforeFirst();

            while(bRs.next()) {
                targetFile       = env.getDocumentPath();
                targetDir        = env.getBrowserPath();
                sourceDir        = env.getDocumentPath();
                documentName     = dRs.getString("pathtotemplate");
                description      = dRs.getString("description");

                patient.setId(bRs.getInt("patientid"));
                patient.beforeFirst();

                patientId = patient.getId();

                doc.setPatientId(patientId);

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

                targetFile += bRs.getString("batchid") + "-" + today;

                ResultSet rptRs;
                ResultSet rptDocRs;
                ResultSet totRs;

                ResultSet lRs  = io.opnUpdatableRS("SELECT * FROM cms1500data c where id=" + patient.getId());
                ResultSet dMap = io.opnRS("select * from rwcatalog.documentmap");
                ResultSet rMap = io.opnRS("select * from rwcatalog.repeatingmap");
                ResultSet tMap = io.opnRS("select * from rwcatalog.totalsmap");

                pdfDoc.setDocumentNumber(1);
                pdfDoc.clearDocumentList();

                if(lRs.next()) {
                    rptRs = io.opnRS("select * from cms1500charges where patientid=" + lRs.getString("id") + " and batchid=" + batchId + " order by chargeid");
                    rptDocRs = io.opnRS("select * from cms1500diagnosis where patientid=" + lRs.getString("id"));

                    totRs = io.opnUpdatableRS("select * from cms1500total");
                    while(totRs.next()) {
                        totRs.deleteRow();
                    }
                    totRs.close();

                    totRs = io.opnUpdatableRS("select * from cms1500total where totaldollars=0");
                    detailLines = 0;
                    while(rptRs.next()) {
                        if(detailLines>5) {
                            dollars += (totalCents * .01);
                            totRs.moveToInsertRow();
                            totRs.updateInt("totaldollars", totalDollars + dollars);
                            totRs.updateInt("totalcents", totalCents - dollars);
                            totRs.updateInt("balancedollars", totalDollars + dollars);
                            totRs.updateInt("balancecents", totalCents - dollars);
                            totRs.insertRow();
                            detailLines = 0;
                            totalDollars = 0;
                            totalCents = 0;
                            dollars = 0;
                        }
                        detailLines ++;
                        totalDollars += rptRs.getDouble("dollars");
                        totalCents += rptRs.getDouble("cents");
                    }

                    if(detailLines>0) {
                        dollars += (totalCents * .01);
                        totRs.moveToInsertRow();
                        totRs.updateInt("totaldollars", totalDollars + dollars);
                        totRs.updateInt("totalcents", totalCents - dollars);
                        totRs.updateInt("balancedollars", totalDollars + dollars);
                        totRs.updateInt("balancecents", totalCents - dollars);
                        totRs.insertRow();
                        detailLines = 0;
                        totalDollars = 0;
                        totalCents = 0;
                    }

                    totRs = io.opnRS("select * from cms1500formtotal order by id");

                    pdfDoc.setPrintFinishedDocument(false);

                    pdfDoc.setInputDocument(null);
                    pdfDoc.setDocumentMap(dMap);
                    pdfDoc.setRepeatingMap(rMap);
                    pdfDoc.setTotalsMap(tMap);
                    pdfDoc.setDocumentData(lRs);
                    pdfDoc.setRepeatingData(rptRs);
                    pdfDoc.setTotalsData(totRs);
                    pdfDoc.setRepeatingDocumentData(rptDocRs);

                    pdfDoc.setNumberOfRepeatingRows(6);

                    pdfDoc.replaceDocumentFields(documentName, targetFile);
                }

                String [] documentList = pdfDoc.getDocumentList();
                for(int d=0; d<documentList.length; d ++) {
                    patient.updatePatientDocumentInfo(type, identifier, documentList[d], "Billing batch " + batchId + " billed on " + descDate);
                    docRs.moveToInsertRow();
                    docRs.updateInt("batchid", batchId);
                    docRs.updateString("pathtodocument", documentList[d]);
                    docRs.insertRow();
                }

            }
        }

        dRs.close();

    }

    docRs = io.opnRS("select * from batchbills where batchid=" + batchId);

    pdfDoc.setPrinterName(printer);

    while(docRs.next()) {
        pdfDoc.setAcrobatVersion(PrintPdf.ACROBAT7);
        pdfDoc.setCurrentDocument(docRs.getString("pathtodocument"));
        pdfDoc.print();
    }

%>
