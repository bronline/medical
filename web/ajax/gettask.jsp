<%-- 
    Document   : gettask
    Created on : Apr 10, 2012, 8:41:18 AM
    Author     : rwandell
--%>
<%@include file="sessioninfo.jsp" %>
<script type="text/javascript">
    function submitForm(params) {
        var url="ajax/gettask.jsp?update=Y";
        if(params.indexOf("delete")>0) {
            url += "&delete=Y";
        }

        var dataString = $(frmInput).serialize();

        $.ajax({
            type: "POST",
            url: url,
            data: dataString,
            success: function(data) {

            },
            complete: function(data) {
                location.href="tasklist.jsp";
            }

        });
    }
</script>
<%
    String id = request.getParameter("id");

    if(request.getParameter("update") == null) {
        if(id == null) { id="0"; }
        String myQuery = "select id, task, start_date, due_date, completed, assigned_to from tasklist where id=" + id;
        ResultSet lRs = io.opnRS(myQuery);
        RWInputForm frm = new RWInputForm(lRs);
        frm.setTableBorder("0");
        frm.setTableWidth("250");
        frm.setDftTextBoxSize("35");
        frm.setDftTextAreaCols("35");
        frm.setDisplayDeleteButton(true);
        frm.setLabelBold(true);
        frm.setUpdateButtonText("  save  ");
        frm.setDeleteButtonText("remove");
        out.print("<div align=\"center\" style=\"width: 100%; margin-top: 15px;\">");
        out.print("<div align=\"right\" style=\"position: relative; z-index: 999; top: -8px; right: 10px; cursor: pointer; font-weight: bold;\" onclick=\"closeTaskBubble()\">close</div>");
        out.print(frm.getInputForm());
        out.print("</div>");
    } else {
        id=request.getParameter("ID");
        if(request.getParameter("delete")!=null) {
            PreparedStatement lPs = io.getConnection().prepareStatement("delete from tasklist where id=" + id);
            lPs.execute();
        } else {
            String task = request.getParameter("task");
            String startDate = Format.formatDate(request.getParameter("start_date"),"yyyy-MM-dd");
            String dueDate = Format.formatDate(request.getParameter("due_date"),"yyyy-MM-dd");
            String completed = request.getParameter("completed");
            String assignedTo = request.getParameter("assigned_to");

            PreparedStatement uPs = io.getConnection().prepareStatement("update tasklist set task=?, start_date=?, due_date=?, completed=?, assigned_to=? where id=?");
            PreparedStatement iPs = io.getConnection().prepareStatement("insert into tasklist (task, start_date, due_date, completed, assigned_to) values(?,?,?,?,?)");
            if(id.equals("0")) {
                iPs.setString(1, task);
                iPs.setString(2, startDate);
                iPs.setString(3, dueDate);
                if(completed == null || completed.equals("false")) { iPs.setBoolean(4, false); } else { iPs.setBoolean(4, true); }
                iPs.setString(5, assignedTo);
                iPs.execute();
            } else {
                uPs.setString(1, task);
                uPs.setString(2, startDate);
                uPs.setString(3, dueDate);
                if(completed == null || completed.equals("false")) { uPs.setBoolean(4, false); } else { uPs.setBoolean(4, true); }
                uPs.setString(5, assignedTo);
                uPs.setString(6, id);
                uPs.execute();
            }
        }
    }
%>
<%@include file="cleanup.jsp" %>