<%--
    Document   : charges_d
    Created on : Dec 21, 2009, 8:48:19 AM
    Author     : Randy
--%>
<%@include file="sessioninfo.jsp" %>
<%
// Initialize local variables
    String myQuery          = "select charges.id, charges.itemid, charges.resourceid, charges.quantity, charges.chargeamount, " +
            "case when charges.modifier is not null then charges.modifier else items.modifier end as modifier," +
            "case when charges.billinsurance is not null then charges.billinsurance else " +
            "case when items.billinsurance then 2 when not items.billinsurance then 1 end end as billinsurance, " +
            "comments from charges " +
            "left join items on items.id=charges.itemid ";
    String id               = request.getParameter("id");
    String update           = request.getParameter("update");
    String delete           = request.getParameter("delete");

// If the id in the request is null or an empty string make it 0 to indicate an add
    if(id == null || id.equals("")) {
        id = "0";
    } else {
        myQuery += "where charges.id=" + id;
    }

    if(update == null) {
    // Create a result set of the data for the form
        ResultSet lRs = io.opnRS(myQuery);

    // Instantiate an RWInputForm and RWHtmlTable object
        RWInputForm frm = new RWInputForm(lRs);
        frm.setShowDatePicker(true);

    // Set display attributes for the input form
        frm.setTableBorder("0");
        frm.setTableWidth("400");
        frm.setDftTextBoxSize("35");
        frm.setDftTextAreaCols("35");
        frm.setDisplayDeleteButton(false);
        frm.setDisplayUpdateButton(false);
        frm.setLabelBold(true);

        frm.setCustomFieldLabel(5, "Modifier");
        frm.setCustomInputType(5, "TEXTBOX");
        frm.setCustomFieldLabel(6, "Bill Insurance");
        frm.setCustomInputType(6, "COMBOBOX");
        frm.setCustomDatasource(6, "select 0 as billinsurance, '--Default--' as descr union select 1 as billinsurance, 'No' as descr union select 2 as billinsurance, 'Yes' as descr");

    // Get an input item with the record id to set the rcd and id fields
        out.print("<v:roundrect style=\"width: 420; height: 220; text-valign: middle; text-align: center;\" arcsize=\".05\">");
        out.print("<div align=\"right\"><b style=\"cursor: pointer;\" onClick=\"showHide(txtHint,'HIDE')\">close</b></div>");
        out.print(frm.getInputForm());
//        out.print("<input type=\"button\" class=\"button\" value=\"  save  \" onClick=\"get(this.parentNode,'SAVE')\">");
        out.print("<input type=\"button\" class=\"button\" value=\"  save  \" onClick=\"processForm(frmInput,'SAVE',null)\">");
//        out.print("<input type=\"button\" class=\"button\" value=\"  save  \" onClick=\"replaceContents(event,'ajax/charges_d.jsp?update=Y',"+id+","+patient.getId()+",procedureList)\">");

   // If payments exist for this charge, do not show the remove button
//        if(!checkForPayments(io, id) && (id != null && !id.equals("0"))) { out.print("<input type=\"button\" class=\"button\" value=\" delete \" onClick=\"formObj=document.getElementById('procedureList'); get(this.parentNode,'DELETE')\">"); }
        if(!checkForPayments(io, id) && (id != null && !id.equals("0"))) { out.print("<input type=\"button\" class=\"button\" value=\" delete \" onClick=\"formObj=document.getElementById('procedureList'); processForm(frmInput,'DELETE',null)\">"); }
//        if(!checkForPayments(io, id) && (id != null && !id.equals("0"))) { out.print("<input type=\"button\" class=\"button\" value=\" delete \" onClick=\"replaceContents(e,'ajax/charges_d.jsp?update=Y&delete=Y'," + id + "," + patient.getId() + ",procedureList)\">"); }

        out.print("<input type=\"hidden\" name=\"parentLocation\" id=\"parentLocation\" value='NONE'>");
        out.print("<input type=\"hidden\" name=\"postLocation\" id=\"postLocation\" value='ajax/charges_d.jsp?update=Y&rcd=" + id + "'>");
        out.print("<input type=\"hidden\" name=\"fileName\" id=\"fileName\" value='charges'>");
        out.print("<input type=\"hidden\" name=\"patientid\" id=\"patientid\" value='" + patient.getId() + "'>");
        out.print("</v:roundrect>");

    } else if(update.equals("Y")) {
        if(delete == null) {
            String itemId=request.getParameter("itemid");
            String resourceId=request.getParameter("resourceid");
            String chargeAmount=request.getParameter("chargeamount");
            String quantity=request.getParameter("quantity");
            String comment=request.getParameter("comments");
            String modifier=request.getParameter("modifier");
            String billInsurance=request.getParameter("billinsurance");

            id=request.getParameter("rcd");

            PreparedStatement chgPs=io.getConnection().prepareStatement("update charges set itemid=?, resourceid=?, chargeamount=?, quantity=?, comments=?, modifier=?, billinsurance=? where id=?");
            chgPs.setString(1, itemId);
            chgPs.setString(2, resourceId);
            chgPs.setString(3, chargeAmount);
            chgPs.setString(4, quantity);
            chgPs.setString(5, comment);
            chgPs.setString(6, modifier);
            chgPs.setString(7, billInsurance);
            chgPs.setString(8, id);
            chgPs.execute();

            out.print(getProcedures(io, visit, id));
        } else {
            id=request.getParameter("rcd");

            String visitId=getVisitId(io,id);

            PreparedStatement chgPs=io.getConnection().prepareStatement("delete from charges where id=" + id);
            chgPs.execute();

            ResultSet pmtRs=io.opnRS("select parentpayment, sum(amount) as amount from payments where parentpayment<>0 and chargeid=" + id + " group by parentpayment");
            PreparedStatement pmtPs=io.getConnection().prepareStatement("delete from payments where parentpayment=? and chargeid=" + id);
            PreparedStatement parentPs=io.getConnection().prepareStatement("update payments set amount=amount+? where id=?");
            while(pmtRs.next()) {
                parentPs.setDouble(1, pmtRs.getDouble("amount"));
                parentPs.setInt(2, pmtRs.getInt("parentpayment"));
                parentPs.execute();

                pmtPs.setInt(1, pmtRs.getInt("parentpayment"));
                pmtPs.execute();
            }
            pmtRs.close();
            pmtRs=null;

            visit.setId(visitId);
            out.print(visit.getProcedures());
        }
    }

    session.setAttribute("returnUrl", "");
%>
<%@include file="cleanup.jsp" %>
<%!
    public boolean checkForPayments(RWConnMgr io, String chargeId) throws Exception {
        ResultSet lRs=io.opnRS("select id from payments where provider<>10 and parentpayment=0 and chargeId=" + chargeId);
        boolean paymentsExist=lRs.next();
        lRs.close();

        return paymentsExist;
    }

    public String getProcedures(RWConnMgr io, Visit visit, String chargeId) {
        String procedureList="";

        try {
            visit.setId(getVisitId(io,chargeId));
            procedureList=visit.getProcedures();
        } catch (Exception e) {
            System.out.print("Ajax - charges__d (" + e.getMessage() + ")");
        }

        return procedureList;
    }

    public String getVisitId(RWConnMgr io, String chargeId) {
        String visitId="0";
        try {
            ResultSet lRs=io.opnRS("select visitid from charges where id=" + chargeId);
            if(lRs.next()) {
                visitId=lRs.getString("visitId");
            }
            lRs.close();
        } catch (Exception e) {
            System.out.print("Ajax - charges__d (" + e.getMessage() + ")");
        }

        return visitId;
    }
%>

