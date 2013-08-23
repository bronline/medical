<%@include file="globalvariables.jsp" %>
<style>
    .headingLabel { font-size: 14px; }
    .headingItem { font-size: 14px; font-weight: bold; }
    .note { font-size: 12px; }
</style>
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
        String insuranceNumberLabel="";
        String insuranceNumber="";
        String insuranceGroupLabel="";
        String insuranceGroup="";

        RWHtmlTable htmTb=new RWHtmlTable("800", "0");

        ResultSet notesRs = io.opnRS("select notedate, note from doctornotes where id in (" + noteList + ") order by notedate");
        ResultSet patientRs = io.opnRS("select * from soapnoteheader where id=" + patient.getId());
        ResultSet insRs = io.opnRS("select * from patientinsurance where primaryprovider and patientid=" + patient.getId());
        ResultSet envRs = io.opnRS("select * from environment");

        if(patientRs.next()) {
            envRs.next();
            out.print(htmTb.startTable("800"));
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("Patient Name", "width=100 class=headingLabel"));
            out.print(htmTb.addCell(patientRs.getString("patientname"), "width=200 class=headingItem"));
            out.print(htmTb.addCell("", "width=50"));
            out.print(htmTb.addCell("Account Number", "width=150 class=headingLabel"));
            out.print(htmTb.addCell(patientRs.getString("accountnumber"), "width=250 class=headingItem"));
            out.print(htmTb.endRow());
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("Address", "class=headingLabel"));
            out.print(htmTb.addCell(patientRs.getString("patientaddress"), "class=headingItem"));
            out.print(htmTb.addCell(""));
            out.print(htmTb.addCell("Doctor Name", "class=headingLabel"));
            out.print(htmTb.addCell(patientRs.getString("doctorname"), "class=headingItem"));
            out.print(htmTb.endRow());
            out.print(htmTb.endRow());
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("", "class=headingLabel"));
            out.print(htmTb.addCell(patientRs.getString("patientcsz"), "class=headingItem"));
            out.print(htmTb.addCell("", "width=50"));
            out.print(htmTb.addCell("", "class=headingLabel"));
            out.print(htmTb.addCell(envRs.getString("supplieraddress"), "class=headingItem"));
            out.print(htmTb.endRow());
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("DOB", "class=headingLabel"));
            out.print(htmTb.addCell(Format.formatDate(patientRs.getString("dob"), "MM/dd/yyyy"), "class=headingItem"));
            out.print(htmTb.addCell("", "width=50"));
            out.print(htmTb.addCell("", "class=headingLabel"));
            out.print(htmTb.addCell("", "class=headingItem"));
            out.print(htmTb.endRow());

            if(insRs.next()) {
                insuranceNumberLabel="Insurance ID";
                insuranceNumber=insRs.getString("providernumber");
                insuranceGroupLabel="Group ID";
                insuranceGroup=insRs.getString("providergroup");
            }

            out.print(htmTb.startRow());
            out.print(htmTb.addCell(insuranceNumberLabel, "width=100 class=headingLabel"));
            out.print(htmTb.addCell(insuranceNumber, "width=250 class=headingItem"));
            out.print(htmTb.addCell("&nbsp;&nbsp;", "width=50"));
            out.print(htmTb.addCell("NPI", "width=125 class=headingLabel"));
            out.print(htmTb.addCell(patientRs.getString("NPI"), "width=300 class=headingItem"));
            out.print(htmTb.endRow());

            out.print(htmTb.startRow());
            out.print(htmTb.addCell(insuranceGroupLabel, "width=100 class=headingLabel"));
            out.print(htmTb.addCell(insuranceGroup, "width=250 class=headingItem"));
            out.print(htmTb.addCell("&nbsp;&nbsp;", "width=50"));
            out.print(htmTb.addCell("Phone", "width=125 class=headingLabel"));
            out.print(htmTb.addCell(patientRs.getString("phone"), "width=300 class=headingItem"));
            out.print(htmTb.endRow());

            out.print(htmTb.endTable());
            out.print("<br><br><hr><br>");

            out.print(htmTb.startTable("600"));
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("Date", htmTb.CENTER, "width=100 class=note"));
            out.print(htmTb.addCell("Notes", htmTb.CENTER, "width=500 class=note"));
            out.print(htmTb.endRow());
            out.print(htmTb.startRow());
            out.print(htmTb.addCell("", htmTb.CENTER, " colspan=2 class=note"));
            out.print(htmTb.endRow());

            while(notesRs.next()) {
                out.print(htmTb.startRow());
                out.print(htmTb.addCell(tools.utils.Format.formatDate(notesRs.getString("notedate"), "MM/dd/yyyy"), "class=note"));
                out.print(htmTb.addCell(notesRs.getString("note"), "class=note"));
                out.print(htmTb.endRow());
                out.print(htmTb.startRow());
                out.print(htmTb.addCell("", "colspan=2"));
                out.print(htmTb.endRow());

            }
            out.print(htmTb.endTable());
        }

   } else {
       out.print("Could not print selected notes.");
   }


%>