<%@include file="template/pagetop.jsp" %>
<%@include file="ajax/ajaxstuff.jsp" %>
<script type="text/javascript">
  function submitForm(action) {
    var frmA=document.forms["frmInput"]
    frmA.action=action
    frmA.submit()
  }

  function setFocus() {
    document.frmInput.firstname.focus();
  }

  function setEditMode() {
    window.location.href='patientmaint.jsp?edit=Y'
  }

  function cancelEditMode() {
    window.location.href='patientmaint.jsp?edit=N'
  }

  function deletePatient() {
      if(confirm("ARE YOU SURE YOU WANT TO DELETE THIS PATIENT?")) {
          location.href='patientmaint.jsp?delete=Y'
      }
  }

  function checkRequiredFields() {
    var frm=document.forms["frmInput"]

    firstName=frm.elements["firstname"].value
    lastName=frm.elements["lastname"].value
    cardNumber=frm.elements["cardnumber"].value

    if(firstName.length<1) {
      alert("First name must be entered")
      return false
    }
    if(lastName.length<1) {
      alert("Last name must be entered")
      return false
    }

    if(cardNumber != "0") {
      cardNumber =replace(replace(replace(cardNumber .replace('\%',''),'$',''),'\r\n',''),'\?','');
      frm.elements["cardnumber"].value=cardNumber ;
    }
    return true
  }

  function tempCard() {
    window.open("issuetempcard.jsp","tempcard","height=100,width=250");
  }

  function makePayment() {
    today=new Date();
    window.open('paymentdetail.jsp?id=0&today='+today,'PostPayment','width=400,height=250,scrollbars=no,left=100,top=100');
  }

  function checkin() {
    var url = "";
    var btnText = $('#checkinButton').val();

    if(btnText == 'check out') {
        $('#txtHint').css('top','400px');
        $('#txtHint').css('left','400px');
        $('#txtHint').css('-moz-box-shadow','10px 10px 5px #888');
        $('#txtHint').css('-webkit-box-shadow','10px 10px 5px #888');
        $('#txtHint').css('box-shadow','10px 10px 5px #888');

        url="ajax/patientcheckout.jsp";

        $.ajax({
            type: "POST",
            url: url,
            success: function(data) {
                $('#txtHint').html(data);
            },
            complete: function(data) {
                $('#txtHint').css('visibility', 'visible');
                $('#txtHint').css('display','');
            }

        });
    } else {
        url = "ajax/patientcheckin.jsp";
        $.ajax({
            type: "POST",
            url: url,
            success: function(data) {
                alert("Patient has been checked in");
                $('#checkinButton').val('check out');
            },
            complete: function(data) {

            }

        });
    }
  }

  function closeCheckoutBubble() {
    $('#txtHint').css('visibility','hidden');
    $('#txtHint').css('display','none');
    $('#txtHint').css('-moz-box-shadow','');
    $('#txtHint').css('-webkit-box-shadow','');
    $('#txtHint').css('box-shadow','');

  }
</script>
<body onLoad="loadMask()">

<%
    if(!redirect) {
    String id       = request.getParameter("id");

    if(patient != null) {
        if(id != null) {
            patient.setId(id);
        }

        patient.setEditPatient(false);
        if (patient.getId()==0) {
            patient.setEditPatient(true);
        }
        if(request.getParameter("edit") != null && request.getParameter("edit").equals("Y")) { patient.setEditPatient(true); }
        else if(request.getParameter("edit") != null && request.getParameter("edit").equals("N")) { patient.setEditPatient(false); }
        else if(request.getParameter("delete") != null && request.getParameter("delete").equals("Y")) {
            patient.delete();
            patient.setEditPatient(false);
            patient.setId(0);
        }

        out.print(patient.getInputForm());

        session.setAttribute("returnUrl", "patientmaint.jsp");
        session.setAttribute("parentLocation", "patientmaint.jsp");
        session.setAttribute("myParent", "patientmaint.jsp");
    }
    }
%>

</body>

<%@ include file="template/pagebottom.jsp" %>