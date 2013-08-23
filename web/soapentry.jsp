<%-- 
    Document   : soapentry
    Created on : Aug 6, 2009, 8:22:24 PM
    Author     : Randy
--%>
<%@ include file="template/pagetop.jsp" %>
<%@ include file="ajax/ajaxstuff.jsp" %>
<script type="text/javascript">
    function addNewSoapItem(soapItem,patientId) {
        showInputForm(e,"soapitementry.jsp?soapItem=Y&soapItemId="+soapItem,soapItem,patientId,txtHint);
    }
    
    function editSoapItem(soapItem,patientId) {
        showInputForm(e,"soapitementry.jsp?soapItemId="+soapItem,soapItem,patientId,txtHint);
    }
</script>
<%
    RWHtmlTable htmTb=new RWHtmlTable("400","0");
    StringBuffer sb=new StringBuffer();
    StringBuffer subjective=new StringBuffer();
    StringBuffer objective=new StringBuffer();
    StringBuffer assessment=new StringBuffer();
    StringBuffer plan=new StringBuffer();

    htmTb.replaceNewLineChar(false);
    
    subjective.append(htmTb.startTable("400"));
    subjective.append(htmTb.startRow());
    subjective.append(htmTb.addCell("<div align='center' style='height: 200; '>" + getSOAPArea(io,htmTb,"Subjective", patient.getId(),1,4781,4782) + "</div>"));
    subjective.append(htmTb.endRow());
    subjective.append(htmTb.endTable());
    
    objective.append(htmTb.startTable("400"));
    objective.append(htmTb.startRow());
    objective.append(htmTb.addCell("<div align='center' style='height: 200;'>" + getSOAPArea(io,htmTb,"Objective", patient.getId(),2,4781,4782) + "</div>"));
    objective.append(htmTb.endRow());
    objective.append(htmTb.endTable());

    assessment.append(htmTb.startTable("400"));
    assessment.append(htmTb.startRow());
    assessment.append(htmTb.addCell("<div align='center' style='height: 200;'>" + getSOAPArea(io,htmTb,"Assessment", patient.getId(),3,4781,4782) + "</div>"));
    assessment.append(htmTb.endRow());
    assessment.append(htmTb.endTable());

    plan.append(htmTb.startTable("400"));
    plan.append(htmTb.startRow());
    plan.append(htmTb.addCell("<div align='center' style='height: 200;'>" + getSOAPArea(io,htmTb,"Plan", patient.getId(),4,4781,4782) + "</div>"));
    plan.append(htmTb.endRow());
    plan.append(htmTb.endTable());

    out.print("<table><tr><td>");
    out.print(htmTb.getFrame("#ffffff", subjective.toString()));
    out.print("</td><td>");
    out.print(htmTb.getFrame("#ffffff", objective.toString()));
    out.print("</td></tr><td>");
    out.print(htmTb.getFrame("#ffffff", assessment.toString()));
    out.print("</td><td>");
    out.print(htmTb.getFrame("#ffffff", plan.toString()));
    out.print("</td></tr></table>");
%>
<%@ include file="template/pagebottom.jsp" %>
<%! public String getSOAPArea(RWConnMgr io, RWHtmlTable htmTb, String areaName, int patientId, int soapArea, int lastVisit, int thisVisit) {
        StringBuffer thing=new StringBuffer();
        thing.append(htmTb.startTable("400"));
        thing.append(htmTb.roundedTopCell(1, "#cccccc", "#030089", ""));
        thing.append(htmTb.startRow());
        thing.append(htmTb.headingCell(areaName));
        thing.append(htmTb.endRow());
        thing.append(htmTb.startRow());
        thing.append(htmTb.addCell(getSOAPAreaDetails(io,htmTb,patientId,soapArea,lastVisit,thisVisit)));
        thing.append(htmTb.endRow());
        thing.append(htmTb.endTable());

        return thing.toString();
    }

    public String getSOAPAreaDetails(RWConnMgr io, RWHtmlTable htmTb, int patientId, int soapArea, int lastVisit, int thisVisit) {
        StringBuffer s=new StringBuffer();

        String myQuery = "select s.id, p.id as patientItem, s.`text`,p.description," +
                         "ifnull((select sa.answer from patientsoapanswers pa left join soapanswers sa on sa.id=pa.answer where patientsoapitemid=p.id and visitid="+lastVisit+"),'') as answer," +
                         "ifnull((select sa.answer from patientsoapanswers pa left join soapanswers sa on sa.id=pa.answer where patientsoapitemid=p.id and visitid="+thisVisit+"),'') as lastvisit " +
                         "from soapitem s " +
                         "left join patientsoapitems p on s.id=p.soapitemid " +
                         "where p.patientid=" + patientId + " and s.soaparea=" + soapArea + " order by `sequence`";

        String description="";
        String bgColor="#e0e0e0";
        try{
            ResultSet lRs=io.opnRS(myQuery);
            s.append(htmTb.startTable("380"));

            if(soapArea==1) {
//            s.append(htmTb.startRow());
//            s.append(htmTb.addCell("","colspan=2"));
//            s.append(htmTb.addCell("<B>Last<br>Visit</b>",htmTb.CENTER,"width=50"));
//            s.append(htmTb.addCell("<b>This<br>Visit</b>",htmTb.CENTER,"width=50"));
//            s.append(htmTb.endRow());
            }

            while(lRs.next()) {
                if(!description.equals(lRs.getString("text"))) {
                    s.append(htmTb.startRow());
                    s.append(htmTb.addCell("<b>" + lRs.getString("text") + "</b>","colspan=4 style=\"cursor: pointer;\" onClick=\"addNewSoapItem(" + lRs.getString("id") + "," + patientId + ")\""));
                    s.append(htmTb.endRow());
                    description=lRs.getString("text");
                    bgColor="#e0e0e0";
                }

                s.append(htmTb.startRow("style='background: " + bgColor + ";'"));
                s.append(htmTb.addCell("","width=20"));
                s.append(htmTb.addCell(lRs.getString("description"), "width=300 style=\"cursor: pointer;\" onClick=\"editSoapItem(" + lRs.getString("patientitem") + "," + patientId + ")\""));
//                s.append(htmTb.addCell(lRs.getString("lastvisit"),htmTb.CENTER,"width=50"));
//                s.append(htmTb.addCell(lRs.getString("answer"),htmTb.CENTER,"width=50"));
                s.append(htmTb.endRow());
                if(bgColor.equals("#e0e0e0")) { bgColor="#c0c0c0"; } else { bgColor="#e0e0e0"; }
            }

            lRs.close();

            s.append(htmTb.endTable());
        } catch (Exception e) {
            s.append(e.getMessage());
        }       
        return s.toString();
    }
%>