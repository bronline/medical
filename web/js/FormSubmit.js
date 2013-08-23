<script language="javascript">
  function submitForm(action) {
    var frmA=document.forms["thisForm"]
    frmA.method="POST"
    frmA.action=action
    frmA.submit()
  }
</script>
<form name=thisForm>
</form>