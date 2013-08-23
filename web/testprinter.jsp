<%@ include file="globalvariables.jsp" %>
<%
    String printer      = env.getDefaultPrinter();

    RWPDFDocument pdfDoc = new RWPDFDocument();

    pdfDoc.setPrinterName(printer);

    pdfDoc.setAcrobatVersion(PrintPdf.ACROBAT7);
    pdfDoc.setCurrentDocument("c:\\seedguide.pdf");
    pdfDoc.print();

%>
