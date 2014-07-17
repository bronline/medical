  function submitForm(action) {
    var frmA=document.forms["thisForm"]
    frmA.method="POST"
    frmA.action=action
    frmA.submit()
  }

