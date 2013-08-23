<%@include file="globalvariables.jsp" %>
<%
   ArrayList elem = new ArrayList();
   String var = "";
   String noteList = "";
   String notesTemplate = "C:\\template\\soapnotes.pdf";

   for(Enumeration e = request.getParameterNames(); e.hasMoreElements();) {
       var=(String)e.nextElement();
       if(var.substring(0,3).equals("chk")) { elem.add(var.substring(3)); }
   }

   for(int x=0; x<elem.size(); x++) {
       if(!noteList.equals("")) { noteList += ", "; }
       noteList += "'" + (String)elem.get(x) + "'";
   }

   if(noteList != null && !noteList.equals("")) {
       String targetFile       = env.getDocumentPath();
       String targetDir        = env.getBrowserPath();
       String sourceDir        = env.getTemplatePath();
       String documentName     = sourceDir + "soapnotes.pdf";

       ResultSet notesRs = io.opnRS("select notedate, note from doctornotes where id in (" + noteList + ")");
       ResultSet patientRs = io.opnRS("select * from soapnoteheader where id=" + patient.getId());
       ResultSet dMap = io.opnRS("select * from rwcatalog.documentmap where document='soapnotes.pdf'");
       ResultSet rMap = io.opnRS("select * from rwcatalog.repeatingmap where document='soapnotes.pdf'");

       RWPDFDocument pdf = new RWPDFDocument();

       pdf.setPrinterName(env.getDefaultPrinter());
       pdf.setInputDocument(null);
       pdf.setDocumentMap(dMap);
       pdf.setRepeatingMap(rMap);
       pdf.setRepeatingData(notesRs);
       pdf.setDocumentData(patientRs);
       pdf.setDocumentNumber(1);
       pdf.clearDocumentList();
       pdf.setNumberOfRepeatingRows(2);
       pdf.setAcrobatVersion("Reader 8.0");
       pdf.setPrintFinishedDocument(true);

       pdf.replaceDocumentFields(documentName, "c:\\medical\\tempdoc.pdf");

       notesRs.close();
       patientRs.close();
       dMap.close();
       rMap.close();
       response.sendRedirect("doctornotes.jsp");
   } else {
       out.print("Could not print selected notes.");
   }


%>