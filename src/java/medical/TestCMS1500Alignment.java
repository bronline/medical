/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package medical;

import tools.RWConnMgr;
import tools.print.PagePrinter;

/**
 *
 * @author Randy
 */
public class TestCMS1500Alignment {
    
    public static void main(String [] args) throws Exception {
        int printType=0;
        com.lowagie.text.Document document= new com.lowagie.text.Document(com.lowagie.text.PageSize.LETTER, 100, 0, 50, 50);
        com.lowagie.text.pdf.PdfWriter writer;
        
        RWConnMgr mapIo=new RWConnMgr("localhost", "rwcatalog", "rwtools", "rwtools", RWConnMgr.MYSQL);

        CMS1500Alignment a=new CMS1500Alignment();
        PagePrinter pagePrinter = new PagePrinter("\\\\192.168.1.99\\hp photosmart 7550 series");

        a.setMapIo(mapIo);
        a.setMapDocument("CMS1500");
        a.setPagePrinter(pagePrinter);
        a.setPrintType(0);
        a.setRepeatingOffset(24);
        
        if(printType == 2) {
            writer = com.lowagie.text.pdf.PdfWriter.getInstance(document, new java.io.FileOutputStream("C:\\testcms1500.pdf"));
            a.setPdfDocument(document);
            a.setWriter(writer);
            document.open();
        }
        
        a.print();
        
        if(printType == 2) { document.close(); }
    }
}
