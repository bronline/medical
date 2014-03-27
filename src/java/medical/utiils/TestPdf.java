/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package medical.utiils;

import com.lowagie.text.DocumentException;
import com.lowagie.text.Image;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.PdfContentByte;
import com.lowagie.text.pdf.PdfReader;
import com.lowagie.text.pdf.PdfStamper;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author Randy
 */
public class TestPdf {

    public static void main (String [] args) throws DocumentException {
        PDF.applyBackgroundImage("C:\\Inetpub\\vhosts\\chiropracticeonline.net\\httpdocs\\medicaldocs\\katchley\\ACA1500PDF\\20140311.pdf", "c:\\ACA1500PDF.pdf", "C:\\chiro\\medical\\web\\images\\Scan_Pic0003.jpg");
        /*
        try {
            PdfReader reader = new PdfReader("c:\\20121127.pdf");
            int n = reader.getNumberOfPages();
            // Create a stamper that will copy the document to a new file
            PdfStamper stamp = new PdfStamper(reader, new FileOutputStream("c:\\text1.pdf"));
            int i = 1;
            PdfContentByte under;
            PdfContentByte over;
            Image img = Image.getInstance("C:\\chiro\\medical\\web\\images\\Scan_Pic0003A.jpg");
            BaseFont bf = BaseFont.createFont(BaseFont.HELVETICA, BaseFont.WINANSI, BaseFont.EMBEDDED);
            img.setAbsolutePosition(0, 0);
            img.scaleToFit(615, 800);
            while (i < n) {
                // Watermark under the existing page
                under = stamp.getUnderContent(i);
                under.addImage(img);
                // Text over the existing page
                over = stamp.getOverContent(i);
                i++;
            }
            stamp.close();
        } catch (IOException ex) {
            Logger.getLogger(TestPdf.class.getName()).log(Level.SEVERE, null, ex);
        }
         */
    }
}
