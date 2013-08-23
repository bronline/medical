<%--
    Document   : gettextboxhint
    Created on : Mar 9, 2009, 1:01:05 PM
    Author     : Randy Wandell
--%>
<%@ page import="medical.*, tools.*, tools.print.*, tools.utils.*, java.sql.*, java.util.*, java.math.* " %>
<%
    String databaseName = (String)session.getAttribute("databaseName");
    RWConnMgr io=new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);

    String srchString=request.getParameter("searchText");
    String formField=request.getParameter("formField");
    String dbField=request.getParameter("dbField");
    String dbTable=request.getParameter("dbTable");
    String activeOnly=request.getParameter("activeOnly");
    StringBuffer returnValues=new StringBuffer();

    if (null==activeOnly) activeOnly="N";

    String cardCondition = "";
    String searchSql = "";
    String searchSql2 = "";
    String lastSrch = "";
    String firstSrch = "";
    String whereClause = "";
    int firstBlank = 0;
    int searchStringLength = 0;

    try {
        cardCondition = "or (cardnumber = " + Integer.parseInt(srchString) + " or workphone like \"%" + Integer.parseInt(srchString) + "%\" or homephone like \"%" + Integer.parseInt(srchString) +"%\" or cellphone like \"%" + Integer.parseInt(srchString) + "%\") ";
    } catch (Exception e) {

    }

    firstBlank = srchString.indexOf(' ');
    searchStringLength = srchString.length();

    if (activeOnly.equals("Y")) whereClause += "active) and (";

    if (firstBlank > 0 && searchStringLength-1>firstBlank) {
        lastSrch = srchString.substring(0, firstBlank);
        firstSrch = srchString.substring(firstBlank).trim();
        whereClause += "lastname like \"" + lastSrch + "%\" and firstname like \"" + firstSrch + "%\" ";
    } else {
        whereClause += "lastname like \"%" + srchString + "%\" or " +
            "firstname like \"%" + srchString + "%\" or accountnumber like('" + srchString.toUpperCase() + "%') " + cardCondition;
    }

    searchSql = "select p.id , lastname, firstname, middlename, convert(DATEDIFF(NOW(), dob)/365.25,UNSIGNED ) dob, active, " +
            "case when preferredcontact=0 then homephone when preferredcontact=1 then workphone when preferredcontact=2 then cellphone end as phonenumber, " +
            "ifnull((select max(date) from visits where patientid=p.id),'') as lastvisit, " +
            "ifnull((select min(date) from appointments where patientid=p.id and date>current_date),'') as nextappt, " +
            "ifnull(pc.description,'') as `condition` " +
            "from patients p " +
            "left join patientconditions pc on pc.patientid=p.id and pc.fromdate=(select max(fromdate) from patientconditions where patientid=p.id) " +
            "where " + whereClause +
            " order by lastname, firstname";
    searchSql2 = "select p.id, lastname, firstname, middlename, case when dob='1900-01-01' then '' else convert(DATEDIFF(NOW(), dob)/365.25,UNSIGNED )end dob, active, " +
            "case when preferredcontact=0 then homephone when preferredcontact=1 then workphone when preferredcontact=2 then cellphone end as phonenumber, " +
            "ifnull((select max(date) from visits where patientid=p.id),'') as lastvisit, " +
            "ifnull((select min(date) from appointments where patientid=p.id and date>current_date),'') as nextappt, " +
            "ifnull(pc.description,'') as `condition` " +
            "from patients p " +
            "left join patientconditions pc on pc.patientid=p.id and pc.fromdate=(select max(fromdate) from patientconditions where patientid=p.id) " +
            "where  (" +  whereClause + ")";
            searchSql2 += " order by lastname, firstname";

    ResultSet lRs=io.opnRS(searchSql2);

    returnValues.append("<div style='position: relative; top: 120px; width: 720; height: 435; background-color: #3399bb; border-radius: 15px;'>\n<div style='width: 720px; text-align: right;'><b style='cursor: pointer; color: #666666; font-size: 11px; text-decoration: none;' onClick='hideSearchBubble();'>close </b></div>\n");
    returnValues.append(" <table border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\n");
    returnValues.append("<tr><th width='200'>Patient Name</th><th width='50'>Age</th><th width='150'>Contact Number</th><th width='75'>Last Visit</th><th width='75'>Next Appt</th><th width='150'>Current Condition</td></tr>\n");
    returnValues.append("</table>\n");
    returnValues.append("<div style='width: 700; height: 400; overflow: auto;'>\n");
    returnValues.append(" <table border=\"0\" cellspacing=\"0\" cellpadding=\"0\">\n");
    while(lRs.next()) {
        String lastVisit=lRs.getString("lastvisit");
        String nextAppt=lRs.getString("nextappt");

        if(!lastVisit.equals("")) { lastVisit=Format.formatDate(lastVisit,"MM/dd/yy"); }
        if(!nextAppt.equals("")) { nextAppt=Format.formatDate(nextAppt, "MM/dd/yy"); }

        String style = "";
        if (lRs.getBoolean("active")==false) style += "style='color:#B00000;'";
        returnValues.append("  <tr onClick=setTextBoxValue('" + formField + "','" + lRs.getString("id") + "') style='font-size: 12px; font-weight: bold; cursor: pointer;'>\n ");
        returnValues.append("<td width='200' " + style + ">" + lRs.getString("lastname") + ", " + lRs.getString("firstName") + " " + lRs.getString("middlename") + "</td><td width='50' align='right'>" + lRs.getString("dob") + "</td><td align='center' width='150'>"+ Format.formatPhone(lRs.getString("phonenumber")) + "</td>");
        returnValues.append("<td width='75' align='center'>" + lastVisit + "</td><td width='75' align='center'>" + nextAppt + "</td>");
        returnValues.append("<td width='150'>" + lRs.getString("condition") + "</td>");
        returnValues.append("</tr>\n");
    }
    returnValues.append(" </table>\n</div>\n</div>\n");

    lRs.close();
    io.getConnection().close();

    response.setHeader("Cache-Control", "no-cache");

    out.print(returnValues.toString());
%>