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
public  abstract class PDF {

    public static void applyBackgroundImage(String pdfIn, String pdfOut, String imageLocation) throws DocumentException {
        try {
            PdfReader reader = new PdfReader(pdfIn);
            int n = reader.getNumberOfPages();
            // Create a stamper that will copy the document to a new file
            PdfStamper stamp = new PdfStamper(reader, new FileOutputStream(pdfOut));
            int i = 1;
            PdfContentByte under;
            PdfContentByte over;
            Image img = Image.getInstance(imageLocation);
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
    }
}
