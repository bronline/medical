<%-- 
    Document   : getpayment
    Created on : Nov 19, 2010, 10:13:20 AM
    Author     : rwandell
--%>
<%@include file="sessioninfo.jsp" %>
<%
    visit.setId(request.getParameter("visitId"));

    if(request.getParameter("update")== null) {
    // Get an input item with the record id to set the rcd and id fields
        out.print("<v:roundrect style=\"width: 420; height: 160; text-valign: middle; text-align: center;\" arcsize=\".05\">\n");
        out.print("<div align=\"right\"><b style=\"cursor: pointer;\" onClick=\"showHide(txtHint,'HIDE')\">close</b></div>");

    // Initialize local variables
        String myQuery          = "select id, provider, checknumber, amount, date from payments ";
        String id               = request.getParameter("id");

    // If the id in the request is null or an empty string make it 0 to indicate an add
        if(id == null || id.equals("")) {
            id = "0";
        }
        myQuery += "where id=" + id;

    // Create a result set of the data for the form
        ResultSet lRs = io.opnRS(myQuery);

    // Instantiate an RWInputForm and RWHtmlTable object
        RWInputForm frm = new RWInputForm(lRs);
        frm.setFormUrl("ajax/getpayment.jsp?update=Y&visitId=" + visit.getId());
        frm.setShowDatePicker(true);

    // Set display attributes for the input form
        frm.setTableBorder("0");
        frm.setTableWidth("250");
        frm.setDftTextBoxSize("35");
        frm.setDftTextAreaCols("35");
        frm.setLabelBold(true);
        frm.setDisplayDeleteButton(false);
        frm.setDisplayUpdateButton(false);

        frm.setPreLoadFields(new String [] { "visitId" } );
        frm.setPreLoadValues(new String [] { "" + visit.getId() } );

        frm.showHiddenFields();

    // Get an input item with the record id to set the rcd and id fields
        out.print(frm.getInputForm());
//        out.print("<input type=\"button\" class=\"button\" value=\"  save  \" onClick=\"get(this.parentNode,'SAVE')\">");
        out.print("<input type=\"button\" class=\"button\" value=\"  save  \" onClick=\"processForm(frmInput,'SAVE',null)\">");

        out.print("<input type=\"hidden\" name=\"parentLocation\" id=\"parentLocation\" value='NONE'>");
        out.print("<input type=\"hidden\" name=\"postLocation\" id=\"postLocation\" value='ajax/getpayment.jsp'>");
        out.print("<input type=\"hidden\" name=\"fileName\" id=\"fileName\" value='payments'>");
        out.print("<input type=\"hidden\" name=\"patientid\" id=\"patientid\" value='" + visit.getPatientId() + "'>");
        out.print("</v:roundrect>\n");
    } else {
        String transactionDate=request.getParameter("date");
        try {
            transactionDate=Format.formatDate(transactionDate, "yyyy-MM-dd");
        } catch (Exception e) {
            transactionDate=Format.formatDate(new java.util.Date(), "yyyy-MM-dd");
        }
        String insertSQL = "INSERT INTO payments (patientid, provider, checknumber, amount, date, chargeid, parentpayment, originalamount) VALUES(?,?,?,?,?,?,?,?)";
        PreparedStatement lPs=io.getConnection().prepareStatement(insertSQL);
        lPs.setInt(1, visit.getPatientId());
        lPs.setString(2, request.getParameter("provider"));
        lPs.setString(3, request.getParameter("checknumber"));
        lPs.setString(4, request.getParameter("amount"));
        lPs.setString(5, transactionDate);
        lPs.setInt(6, 0);
        lPs.setInt(7,0);
        lPs.setString(8, request.getParameter("amount"));
        lPs.execute();
    }

%>
<%@include file="cleanup.jsp" %>