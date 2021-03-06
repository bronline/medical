/*
 * TestCMS1500.java
 *
 * Created on August 21, 2007, 9:10 AM
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package medical;

import java.sql.ResultSet;
import tools.RWConnMgr;
import tools.print.PagePrinter;

/**
 *
 * @author Randy Wandell
 */
public class TestCMS1500 {
    
    /** Creates a new instance of TestCMS1500 */
    public static void main(String [] args) throws Exception {
        PagePrinter pagePrinter=new PagePrinter();
        RWConnMgr io=new RWConnMgr("localhost", "medical", "root", "root", RWConnMgr.MYSQL);
        RWConnMgr mapIo=new RWConnMgr("localhost", "rwtools", "rwtools", "rwtools", RWConnMgr.MYSQL);
        
        CMS1500 cms1500=new CMS1500(io, mapIo);
        cms1500.setPagePrinter(pagePrinter);
        cms1500.preview("1", "1595");
        
        io.getConnection().close();
        
    }
    
}
