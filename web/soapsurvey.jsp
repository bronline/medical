<%-- 
    Document   : soapsurvey
    Created on : Sep 30, 2009, 9:02:49 PM
    Author     : Randy
--%>
<%@ include file="template/pagetop.jsp" %>
<style>
    td { color: white; font-size: 12px;}
</style>
<%
    RWHtmlTable htmTb=new RWHtmlTable("400","0");
    htmTb.replaceNewLineChar(false);
    RWHtmlForm form=new RWHtmlForm();
    form.setRbPosBottom();
    String returnPoint=(String)session.getAttribute("locationReturnPoint");
    
    ArrayList a=getAnswerTypes(io);
    
    ResultSet lRs=io.opnRS("SELECT ps.id, description, answertype FROM patientsoapitems ps left join soapitem si on si.id=ps.soapitemid where soaparea=1 and patientid=" + patient.getId() + " order by sequence");
    if(request.getParameter("radio1") == null) {
        out.print(form.startForm());
        out.print(htmTb.startTable("600"));
        while(lRs.next()) {
            String [] valueList=(String[])a.get(lRs.getInt("answertype"));
            out.print(htmTb.startRow());
            out.print(htmTb.addCell(lRs.getString("description"), "style='color: white; font-weight: bold; font-size: 14px;'"));
            out.print(htmTb.endRow());
            out.print(htmTb.startRow("style='height: 50px;'"));
            out.print(htmTb.addCell(form.radioButton(valueList, "radio" + lRs.getInt("id"), "")));
            out.print(htmTb.endRow());
        }
        out.print(htmTb.endTable());
        out.print(form.submitButton("ok", "class=button"));
        out.print(form.endForm());
        lRs.close();
    } else {
        StringBuffer s=new StringBuffer();
        int visitId=0;
        while(lRs.next()) {
            if(s.length()==0) {
                s.append("Subjective:\r\n");
            } else {
                s.append("\r\n");
            }
            String [] valueList=(String[])a.get(lRs.getInt("answertype"));
            s.append("   " + lRs.getString("description") + " is " + request.getParameter("radio" + lRs.getInt("id")));
        }
        patient.findVisitInfo(visit, 0);
        ResultSet visitRs=io.opnRS("select max(id) as id from visits where patientid=" + patient.getId());
        if(visitRs.next()) { visitId=visitRs.getInt("id"); }
        visitRs.close();
        
        DoctorNote note=new DoctorNote(io, "0");
        Calendar cal=Calendar.getInstance();
        note.setNoteDate(cal);
        note.setNote(s.toString());
        note.setPatientId(patient.getId());
        note.setVisitId(visitId);
        note.update();
        lRs.close();
        
        response.sendRedirect(returnPoint);
    }

%>
<%@ include file="template/pagebottom.jsp" %>
<%! public ArrayList getAnswerTypes(RWConnMgr io) throws Exception {
        ArrayList a=new ArrayList();
        ResultSet lRs=io.opnRS("select typeid, count(id) as size from soapanswers group by typeid order by typeid");
        while(lRs.next()) {
            int x=0;
            String [] ans=new String[lRs.getInt("size")];
            ResultSet tRs=io.opnRS("select * from soapanswers where typeid=" + lRs.getInt("typeid"));
            while(tRs.next()) {
                ans[x]=tRs.getString("answer");
                x++;
            }
            a.add(ans);
            tRs.close();
        }
        lRs.close();
        return a;
    }
%>