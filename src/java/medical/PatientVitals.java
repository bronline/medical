/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package medical;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintStream;
import java.sql.ResultSet;
import javax.servlet.http.HttpServletRequest;
import tools.RWConnMgr;
import tools.RWInputForm;
import tools.utils.Format;
import javax.servlet.jsp.JspWriter;
import tools.RWHtmlTable;

/**
 *
 * @author rwandell
 */
public class PatientVitals extends MedicalResultSet {
    private int id=0;
    private int patientId = 0;
    private String date = "0001-01-01";
    private double weight = 0.0;
    private double inches = 0.0;
    private double fatPercent=0.0;
    private File f = new File("C:\\chiropractice\\logs\\PatientVitals.log");

    public PatientVitals() {
    }

    public PatientVitals(RWConnMgr io, int id) {
        try {
            setConnMgr(io);
            setId(id);
        } catch (Exception e) {
        }

    }
    
    public void clear() {
//        setId(0);
        setPatientId(0);
        setDate(Format.formatDate(new java.util.Date(), "MM/dd/yyyy"));
        setWeight(0.0);
        setInches(0.0);
        setFatPercent(0.0);        
    }

    public void refresh() throws Exception {
        clear();
        setResultSet(io.opnRS("select * from patientvitals where id=" + this.getId()));
        if(next()) {
            setId(getInt("id"));
            setPatientId(getInt("patientid"));
            setDate(Format.formatDate(getString("date"), "MM/dd/yyyy"));
            setWeight(getDouble("weight"));
            setInches(getDouble("inches"));
            setFatPercent(getDouble("fatpercent")*100);
        }
        beforeFirst();
    }

    public boolean update() throws FileNotFoundException {
        boolean updateSuccessful = true;

        try {
            setResultSet(io.opnUpdatableRS("select * from patientvitals where id=" + id));

            if(next()) {
                updateString("date", Format.formatDate(getDate(), "yyyy-MM-dd"));
                updateDouble("weight", getWeight());
                updateDouble("inches", getInches());
                updateDouble("fatpercent", getFatPercent());
                updateRow();
            } else {
                moveToInsertRow();
                updateInt("patientid", getPatientId());
                updateString("date", Format.formatDate(getDate(), "yyyy-MM-dd"));
                updateDouble("weight", getWeight());
                updateDouble("inches", getInches());
                updateDouble("fatpercent", getFatPercent());
                insertRow();
            }
        } catch (Exception e) {
            PrintStream ps = new PrintStream(f);
            e.printStackTrace(ps);
            updateSuccessful=false;
        }
        
        return updateSuccessful;
    }

    public boolean delete() {
        boolean deleteSuccessful = true;

        try {
            setResultSet(io.opnUpdatableRS("select * from patientvitals where id=" + id));
            if(next()) { deleteRow(); }
        } catch (Exception e) {
            deleteSuccessful = false;
        }

        return deleteSuccessful;
    }

    public boolean processInputForm(HttpServletRequest request) throws FileNotFoundException {
        setId(request.getParameter("id"));

        try {
            if(request.getParameter("update") != null && request.getParameter("update").equals("Y")) {
                setPatientId(Integer.parseInt(request.getParameter("patientid")));
                setDate(Format.formatDate(request.getParameter("date"), "yyyy-MM-dd"));
                setWeight(Double.parseDouble(request.getParameter("weight")));
                setInches(Double.parseDouble(request.getParameter("inches")));
                setFatPercent(Double.parseDouble(request.getParameter("fatpercent"))*.01);
                return update();
            } else if(request.getParameter("delete") != null && request.getParameter("delete").equals("Y")) {
                return delete();
            } else {
                return false;
            }
        } catch (Exception e) {
            PrintStream ps = new PrintStream(f);
            e.printStackTrace(ps);
            return false;
        }
    }

    public void getVitalsForm(String id, JspWriter out) throws FileNotFoundException {
        try {
            setId(id);
            refresh();
            showInputForm(out);
        } catch (Exception e) {
            PrintStream ps = new PrintStream(f);
            e.printStackTrace(ps);
        }
    }

    public void getVitalsForm(int id, JspWriter out) throws FileNotFoundException {
        try {
            setId(id);
            refresh();
            showInputForm(out);
        } catch (Exception e) {
            PrintStream ps = new PrintStream(f);
            e.printStackTrace(ps);
        }

    }

    public void getVitalsForm(JspWriter out) throws FileNotFoundException {
        showInputForm(out);
    }

    public void getVitalsEntries(JspWriter out, String listType) throws FileNotFoundException {
        getVitalsEntries(out, listType, null);
    }

    public void getVitalsEntries(JspWriter out, String listType, String divHeight) throws FileNotFoundException {
        String myQuery = getQueryForList(listType);

        try {
            double weightLostFromPrevious=0.0;
            double inchesLostFromPrevious=0.0;
            double percentLostFromPrevious=0.0;
            double weightLossRunning=0.0;
            double inchesLossRunning=0.0;
            double percentLossRunning=0.0;

            String dateFormat = "MM/dd/yy";
            String dateHeading = "Date";
            String maintenanceLink = " onClick=\"showItem(event,'ajax/updatepatientvitals.jsp?',##ID##," + getPatientId() + ",txtHint)\" style=\"cursor: pointer; font-weight: bold;\" ";



            if(divHeight == null || divHeight.trim().equals("")) { divHeight="200px"; }

            if(listType.equals("W")) { dateHeading="Week<br>Beginning"; }
            else if(listType.equals("M")) { dateFormat="MMM yyyy"; dateHeading="Month"; }
            else if(listType.equals("Y")) { dateFormat="yyyy"; dateHeading="Year"; }

            if(!listType.equals("D")) { maintenanceLink=""; }

            RWHtmlTable htmTb = new RWHtmlTable("530", "0");
            ResultSet lRs = io.opnRS(myQuery);

            out.print(htmTb.startTable());
            
            out.print(htmTb.startRow());
            out.print(htmTb.headingCell("", "width=\"0\" style=\"display: none;\""));
            out.print(htmTb.headingCell(dateHeading, "width=\"80\""));
            out.print(htmTb.headingCell("Weight", "width=\"50\""));
            out.print(htmTb.headingCell("Inches", "width=\"50\""));
            out.print(htmTb.headingCell("Fat%", "width=\"50\""));
            out.print(htmTb.headingCell("Weight<br>Change", "width=\"50\""));
            out.print(htmTb.headingCell("Inches<br>Change", "width=\"50\""));
            out.print(htmTb.headingCell("Fat %<br>Change", "width=\"50\""));
            out.print(htmTb.headingCell("Total<br>Weight<br>Lost", "width=\"50\""));
            out.print(htmTb.headingCell("Total<br>Inches<br>Lost", "width=\"50\""));
            out.print(htmTb.headingCell("Total<br>Fat %<br>Lost", "width=\"50\""));
            out.print(htmTb.endRow());
            
            out.print(htmTb.endTable());
            
            out.print("<div style=\"width: 550px; height: " + divHeight + "; overflow: auto;\">\n");
            out.print(htmTb.startTable());

            while(lRs.next()) {
                if(lRs.getRow() == 1) {
                    weightLossRunning = lRs.getDouble("weight");
                    inchesLossRunning = lRs.getDouble("inches");
                    percentLossRunning = lRs.getDouble("fatpercent")*100;

                    weightLostFromPrevious = lRs.getDouble("weight");
                    inchesLostFromPrevious = lRs.getDouble("inches");
                    percentLostFromPrevious = lRs.getDouble("fatpercent")*100;
                }

                out.print(htmTb.startRow());
                out.print(htmTb.addCell(lRs.getString("id"), "width=\"0\" style=\"display: none;\""));
                out.print(htmTb.addCell(Format.formatDate(lRs.getString("date"), dateFormat), RWHtmlTable.CENTER, "width=\"80\"" + maintenanceLink.replaceAll("##ID##", lRs.getString("id"))));
                out.print(htmTb.addCell(Format.formatNumber(lRs.getDouble("weight"), "###0.00"), RWHtmlTable.RIGHT, "width=\"50\""));
                out.print(htmTb.addCell(Format.formatNumber(lRs.getDouble("inches"), "###0.00"), RWHtmlTable.RIGHT, "width=\"50\""));
                out.print(htmTb.addCell(Format.formatNumber(lRs.getDouble("fatpercent")*100, "##0.0")+"%", RWHtmlTable.RIGHT, "width=\"50\""));
                out.print(htmTb.addCell(Format.formatNumber(lRs.getDouble("weight")-weightLostFromPrevious, "###0.00"), RWHtmlTable.RIGHT, "width=\"50\""));
                out.print(htmTb.addCell(Format.formatNumber(lRs.getDouble("inches")-inchesLostFromPrevious, "###0.00"), RWHtmlTable.RIGHT, "width=\"50\""));
                out.print(htmTb.addCell(Format.formatNumber((lRs.getDouble("fatpercent")*100)-percentLostFromPrevious, "##0.0")+ "%", RWHtmlTable.RIGHT, "width=\"50\""));
                out.print(htmTb.addCell(Format.formatNumber(lRs.getDouble("weight")-weightLossRunning, "###0.00"), RWHtmlTable.RIGHT, "width=\"50\""));
                out.print(htmTb.addCell(Format.formatNumber(lRs.getDouble("inches")-inchesLossRunning, "###0.00"), RWHtmlTable.RIGHT, "width=\"50\""));
                out.print(htmTb.addCell(Format.formatNumber((lRs.getDouble("fatpercent")*100)-percentLossRunning, "##0.0")+"%", RWHtmlTable.RIGHT, "width=\"50\""));
                out.print(htmTb.endRow());

                weightLostFromPrevious = lRs.getDouble("weight");
                inchesLostFromPrevious = lRs.getDouble("inches");
                percentLostFromPrevious = lRs.getDouble("fatpercent")*100;
            }

            lRs.close();
            lRs=null;

            out.print(htmTb.endTable());
            out.print("</div>\n");

        } catch (Exception ex) {
            PrintStream ps = new PrintStream(f);
            ex.printStackTrace(ps);
        }

    }
    public String getQueryForList(String listType) {
        String myQuery="select * from patientvitals where patientid=" + getPatientId() + " order by `date`";

        if(listType.equals("W")) {
            myQuery = "select " +
            " 0 as id, " +
            "  MIN(" +
            "  CASE" +
            "    WHEN DAYOFWEEK(`date`) = 1 THEN DATE_ADD(`date`, INTERVAL 1 DAY)" +
            "    WHEN DAYOFWEEK(`date`) = 3 THEN DATE_ADD(`date`, INTERVAL -1 DAY)" +
            "    WHEN DAYOFWEEK(`date`) = 4 THEN DATE_ADD(`date`, INTERVAL -2 DAY)" +
            "    WHEN DAYOFWEEK(`date`) = 5 THEN DATE_ADD(`date`, INTERVAL -3 DAY)" +
            "    WHEN DAYOFWEEK(`date`) = 6 THEN DATE_ADD(`date`, INTERVAL -4 DAY)" +
            "    WHEN DAYOFWEEK(`date`) = 7 THEN DATE_ADD(`date`, INTERVAL -5 DAY)" +
            "  ELSE" +
            "    `date`" +
            "  END) AS `date`," +
            "  weight," +
            "  inches," +
            "  fatpercent " +
            "from patientvitals " +
            "where patientid=" + getPatientId() + " " +
            "group by WEEKOFYEAR(`date`) " +
            "ORDER BY `date`";
        } else if(listType.equals("M")) {
            myQuery = "select " +
            " 0 as id, " +
            "  MIN(`date`) AS `date`," +
            "  weight," +
            "  inches," +
            "  fatpercent " +
            "from patientvitals " +
            "where patientid=" + getPatientId() + " " +
            "group by MONTH(`date`) " +
            "ORDER BY `date`";
        }else if(listType.equals("Y")) {
            myQuery = "select " +
            " 0 as id, " +
            "  MIN(`date`) AS `date`," +
            "  weight," +
            "  inches," +
            "  fatpercent " +
            "from patientvitals " +
            "where patientid=" + getPatientId() + " " +
            "group by YEAR(`date`) " +
            "ORDER BY `date`";
        }

        return myQuery;
    }

    private void showInputForm(JspWriter out) throws FileNotFoundException {
        try {
            RWHtmlTable htmTb = new RWHtmlTable("100%","0");
            RWInputForm frm = new RWInputForm(rs);

            String calendarImage="<img style=\"cursor: pointer;\" onclick=\"var X=event.x; var Y=event.y; var action=&quot;datepicker.jsp?formName=frmInput&amp;element=dob&amp;month=05&amp;year=1958&amp;day=30&quot;; var options=&quot;width=190,height=111,left=&quot; + X + &quot;,top=&quot; + Y + &quot;,&quot;; window.open(action, &quot;Date&quot;, options);\" src=\"images/show-calendar.gif\">";

            out.print("<v:roundrect style='width: 200; height: 125; text-valign: middle; text-align: center;' arcsize='.05' fillcolor='#3399bb'>\n");
            out.print("<form name=\"frmInput\" id=\"frmInput\" action=\"\" onSubmit=\"submitForm(this)\">\n");
            out.print(htmTb.startTable("100%"));

            out.print(htmTb.startRow());
            out.print(htmTb.addCell("<b>Date</b>", "width=\"60%\""));
            out.print(htmTb.addCell(calendarImage + "&nbsp;<input type=\"text\" id=\"date\" name=\"date\" size=\"10\" maxlength=\"10\" value=\"" + getDate() + "\" class=\"tBoxText\" style=\"text-align: right;\" onblur=\"DateFormat(this,this.value,event,true,'1')\" onkeydown=\"DateFormat(this,this.value,event,false,'1')\" onfocus=\"javascript:vDateType='1'\">", RWHtmlTable.RIGHT, "width=\"40%\""));
            out.print(htmTb.endRow());

            out.print(htmTb.startRow());
            out.print(htmTb.addCell("<b>Weight</b>", "width=\"60%\""));
            out.print(htmTb.addCell("<input type=\"text\" id=\"weight\" name=\"weight\" size=\"10\" maxlength=\"10\" value=\"" + getWeight() + "\" class=\"tBoxText\" style=\"text-align: right;\" onblur=\"return checkban(this);\">", RWHtmlTable.RIGHT, "width=\"40%\""));
            out.print(htmTb.endRow());

            out.print(htmTb.startRow());
            out.print(htmTb.addCell("<b>Inches</b>", "width=\"60%\""));
            out.print(htmTb.addCell("<input type=\"text\" id=\"inches\" name=\"inches\" size=\"10\" maxlength=\"10\" value=\"" + getInches() + "\" class=\"tBoxText\" style=\"text-align: right;\" onblur=\"return checkban(this);\">", RWHtmlTable.RIGHT, "width=\"40%\""));
            out.print(htmTb.endRow());

            out.print(htmTb.startRow());
            out.print(htmTb.addCell("<b>Fat Percent</b>", "width=\"60%\""));
            out.print(htmTb.addCell("<input type=\"text\" id=\"fatpercent\" name=\"fatpercent\" size=\"10\" maxlength=\"10\" value=\"" + getFatPercent() + "\" class=\"tBoxText\" style=\"text-align: right;\" onblur=\"return checkban(this);\">", RWHtmlTable.RIGHT, "width=\"40%\""));
            out.print(htmTb.endRow());

            out.print(htmTb.endTable());

            out.print("<br/>\n");
            out.print(frm.button("save", "class=\"button\" onClick=\"submitForm(frmInput)\""));
            if(id != 0) { out.print("&nbsp;&nbsp;&nbsp;" + frm.button("remove", "class=\"button\" onClick=\"removeRecord()\"", "deleteButton")); }
            out.print("&nbsp;&nbsp;&nbsp;" + frm.button("cancel", "class=\"button\" onClick=\"cancelEdit()\""));

            out.print(frm.hidden(""+getId(), "id"));
            out.print(frm.hidden(""+getPatientId(), "patientid"));

            out.print("</form>\n");
            out.print("</v:roundrect>\n");
        } catch (Exception e) {
            PrintStream ps = new PrintStream(f);
            e.printStackTrace(ps);
            try {
                out.println("There was a problem creating the form.");
            } catch (Exception f) {
            }
        }
    }

    /**
     * @return the fatPercent
     */
    public double getFatPercent() {
        return fatPercent;
    }

    /**
     * @param fatPercent the fatPercent to set
     */
    public void setFatPercent(double fatPercent) {
        this.fatPercent = fatPercent;
    }

    /**
     * @return the id
     */
    public int getId() {
        return id;
    }

    /**
     * @param id the id to set
     */
    public void setId(int id) {
        this.id = id;
    }

    /**
     * @param id the id to set
     */
    public void setId(String id) {
        this.id = Integer.parseInt(id);
    }

    /**
     * @return the patientId
     */
    public int getPatientId() {
        return patientId;
    }

    /**
     * @param patientId the patientId to set
     */
    public void setPatientId(int patientId) {
        this.patientId = patientId;
    }

    /**
     * @return the date
     */
    public String getDate() {
        return date;
    }

    /**
     * @param date the date to set
     */
    public void setDate(String date) {
        this.date = date;
    }

    /**
     * @return the weight
     */
    public double getWeight() {
        return weight;
    }

    /**
     * @param weight the weight to set
     */
    public void setWeight(double weight) {
        this.weight = weight;
    }

    /**
     * @return the inches
     */
    public double getInches() {
        return inches;
    }

    /**
     * @param inches the inches to set
     */
    public void setInches(double inches) {
        this.inches = inches;
    }

}
