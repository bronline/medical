var visitId;
var timerToClearShortcut;
var shortcutText='';
var boxesChecked='';

function getNoteText(str) {
    var url="getnotetext.jsp?q="+str+"&sid="+Math.random();

    $.ajax({
        url: url,
        success: function(data){
            $(note).html(' ' + leftTrim(data.substring(1)));
        },
        error: function() {
            alert("There was a problem processing the request");
        }
    });
}

function changeResource(resourceId, v) {
    var url="ajax/changeresource.jsp?resourceId="+resourceId+"&visitId="+v+"&sid="+Math.random();

    $.ajax({
        url: url,
        success: function(data){

        },
        error: function() {
            alert("There was a problem processing the request");
        }
    });
}

function leftTrim(sString) {
    while (sString.substring(0,1) == ' ')  {
        sString = sString.substring(1, sString.length);
    }
    return sString.substring(0,sString.length-1);
}
function submitForm(what) {
    get(what.parentNode,'SAVE')
}

function duplicate() {
    var isSure = confirm('Duplicate will remove any existing notes.  Do you want to continue?');
    if (isSure==true) {
        var frmA=document.forms["frmInput"]
        frmA.method="POST"
        frmA.action="doctornotes_d.jsp?duplicate=Y"
        frmA.submit()
    }
}

function setFocus() {
    document.frmInput.comment.focus();
}


function disableAllButtons() {
    var buttons = document.getElementsByTagName("input");
    for (var i=0; i < buttons.length; i++) {
        if (buttons[i].getAttribute("type") == "button" || buttons[i].getAttribute("type") == "submit") {
            buttons[i].disabled = true;
        }
    }
}

function enableAllButtons() {
    var buttons = document.getElementsByTagName("input");
    for (var i=0; i < buttons.length; i++) {
        if (buttons[i].getAttribute("type") == "button" || buttons[i].getAttribute("type") == "submit") {
            buttons[i].disabled = false;
        }
    }
}

function shortcut() {
   if(enablePageScripts) {

      disableAllButtons();
      clearTimeout(timerToClearShortcut);
      timerToClearShortcut=setTimeout("activateShortcut()",150);
      keyPressed=window.event.keyCode;
      if (keyPressed!=27) {
        shortcutText+=String.fromCharCode(keyPressed);
      }
  }
}

function activateShortcut() {
   var elem = document.getElementById(shortcutText);
   if(enablePageScripts) {
       if (elem!=null) {
        //alert(elem.name)
        elem.disabled=false;
        elem.click();
       } else {
        alert('Button not defined!');
        var buttons = document.getElementsByTagName("input");
        for (var i=0; i < buttons.length; i++) {
            if (buttons[i].getAttribute("type") == "button" || buttons[i].getAttribute("type") == "submit") {
                buttons[i].disabled = false;
            }
        }
       }
       shortcutText='';
   }
}

function addProcedure(itemId,v) {
   visitId=v;
   var resourceId=document.getElementById("currentresource");
   var apUrl = "ajax/addchargetovisit.jsp?visitId="+visitId+"&itemId="+itemId+"&resourceId="+resourceId.value;

    $.ajax({
        url: apUrl,
        success: function(data){
            refreshProcedureList(visitId);
        },
        error: function() {
            alert("There was a problem processing the request");
        }
    });
}

function updateProcedure(itemId,v) {
   visitId=v;
   showInputForm(e,"ajax/charges_d.jsp",itemId,0,txtHint);
}

function addNote(noteId,v) {
   visitId=v;
   var anUrl = "ajax/addnotetovisit.jsp?visitId="+visitId+"&noteId="+noteId;

    $.ajax({
        url: anUrl,
        success: function(data){
            refreshNoteList(visitId);
        },
        error: function() {
            alert("There was a problem processing the request");
        }
    });
}

function showSubItemsForProcedure(itemId,subItemTypeId,v,pageHeader) {
   visitId=v;
   boxesChecked="";
   disableAllButtons();
   resourceId=document.getElementById("currentresource").value;
   var url="ajax/showsubitems.jsp?resourceId="+resourceId+"&itemId=" + itemId + "&subitemtypeid=" + subItemTypeId + "&visitId=" + visitId + "&pageHeader=" + pageHeader;

    $.ajax({
        url: url,
        success: function(data){
            $(subItemList).html(data);
            showHide(subItemList,'SHOW');
        },
        error: function() {
            alert("There was a problem processing the request");
        }
    });
}

function showSubItemsForNote(noteId,subItemTypeId,v,pageHeader) {
   visitId=v;
   boxesChecked="";
   var url="ajax/showsubitems.jsp?&noteId=" + noteId + "&subitemtypeid=" + subItemTypeId + "&visitId=" + visitId + "&pageHeader=" + pageHeader;

    $.ajax({
        url: url,
        success: function(data){
            $(subItemList).html(data);
            showHide(subItemList,'SHOW');
        },
        error: function() {
            alert("There was a problem processing the request");
        }
    });
}

function refreshProcedureList(v) {
   visitId=v;
   var plUrl = "ajax/refreshprocedurelist.jsp?visitId="+visitId;

    $.ajax({
        url: plUrl,
        success: function(data){
            $(procedureList).html(data);
            refreshNoteList(visitId);
        },
        error: function() {
            alert("There was a problem processing the request");
        }
    });
}

function refreshNoteList(v) {
   visitId=v;
   var nlUrl = "ajax/refreshnotelist.jsp?visitId="+visitId;

    $.ajax({
        url: nlUrl,
        success: function(data){
            $(noteList).html(data);
            refreshNoteList(visitId);
        },
        error: function() {
            alert("There was a problem processing the request");
        }
    });
}

function refreshConditionList(v, c) {
   visitId=v;
   var nlUrl = "ajax/refreshconditionlist.jsp?visitId="+visitId;

    $.ajax({
        url: nlUrl,
        success: function(data){
            $(patientconditionsbubble).html(data);
        },
        error: function() {
            alert("There was a problem processing the request");
        },
        complete: function() {
            refreshSymptomList(c,v);
        }
    });

}

function refreshSymptomList(conditionId,visitId) {
   var slUrl = "ajax/refreshsymptomlist.jsp?conditionId="+conditionId+"&visitId="+visitId;

    $.ajax({
        url: slUrl,
        success: function(data){
            $(patientsymptomsbubble).html(data);
        },
        error: function() {
            alert("There was a problem processing the request");
        }
    });
}

function editSOAPNote(noteId,v) {
    visitId=v;
    showInputForm(e,"doctornotes_d_new.jsp",noteId,0,txtHint);
}

  window.name="visitactivity";
  function submitForm(action) {
    var frmA=document.forms["frmInput"]
    frmA.action=action
    frmA.submit()
  }

  function setFocus() {
    document.frmInput.firstname.focus();
  }

  function closeVisit() {
      var enableSpaceBar=document.getElementById("enableSpaceBar");
      if(enableSpaceBar.value == '0') {
          window.history.back();
      } else {
          window.opener.location.href="visits.jsp";
          self.close();
      }
  }

  function displayImage(image) {
    window.open('xrays_d.jsp?image=' + image,'Image','left=70,top=50,width=600,height=700,scrollbars=no');
  }

  function changeVisitDate(v) {
    visitId=v;
    window.open('changevisitdate.jsp?visitId='+visitId,'VisitDate','height=115,width=405,menubar=no,location=no,titlebar=no,status=no,scrollbars=no');
  }

  function duplicateVisit(v) {
    visitId=v;
    var isSure = confirm('Copy last visit will remove any existing charges and notes.  Do you want to continue?');
    if (isSure==true) {
       var url = "ajax/duplicatevisit.jsp?visitId="+visitId;

        $.ajax({
            url: url,
            success: function(data){
                refreshProcedureList(visitId);
                enableAllButtons();
            },
            error: function() {
                alert("There was a problem processing the request");
            }
        });
    }
  }

  function undoVisit(v) {
    visitId=v;
    var isSure = confirm('Are you sure you want to remove all charges for this visit?');
    if (isSure==true) {
       var undoUrl = "ajax/undovisit.jsp?visitId="+visitId;

        $.ajax({
            url: undoUrl,
            success: function(data){
                refreshProcedureList(visitId);
            },
            error: function() {
                alert("There was a problem processing the request");
            }
        });
    }
    enableAllButtons();
  }

  function deleteVisit(v) {
      visitId=v;
      disableAllButtons();
      var isSure = confirm("Deleteing the visit will cause all charges, payments and notes to be removed.  Are you sure you want to delete this visit?");
      if(isSure==true) {
          location.href="deletevisit.jsp?visitId="+visitId
      }
  }
  
  function newCondition(v) {
    enablePageScripts=false;
    objectName="txtHint";

    $(txtHint).html('');

    var url="ajax/patientcondition.jsp?visitId=" + v + "&sid="+Math.random();
  
    $.ajax({
        url: url,
        success: function(data){
            $(txtHint).html(data);
            ajaxComplete=true;
            setFormPosition(e,txtHint);
            showHide(txtHint,'SHOW');
        },
        error: function() {
            alert("There was a problem processing the request");
        }
    });      

  }
  

/*    
    $.ajax({
        url: "ajax/getconditiondxcodes.jsp",
        success: function(data) {
            $(patientsymptomsbubble).html(data);
        },
        error: function() {
            alert("There was a problem refreshing the diagnosis codes for this visit, please refresh");
        },
        complete: function() {
            refreshConditionList();
        }
    });
*/         


    function getPayment(v) {
        enablePageScripts=false;
        visitId=v;
        var paymentUrl = "ajax/getpayment.jsp?visitId="+visitId;

        showItemInFixedPos(window.event,paymentUrl,0,0,txtHint,100,100);
    }

function handler(e) {
    if(enablePageScripts) {

        var key;

        if(window.event) // IE
        {
            key = e.keyCode;
        }
        else if(e.which) // Netscape/Firefox/Opera
        {
            key = e.which;
        }

        // 32 is the spacebar
        if(key==32){
            var enableSpaceBar=document.getElementById("enableSpaceBar");
        //            if(enableSpaceBar.value!='0') {
            window.history.back();
        //            } else {
        //                alert('Spacebar not allowed!  No charges exist on visit');
        //            }
        } else if(key==87) { // shift-W
            window.open('whoshere.jsp','WaitingRoom','width=600,height=300');
        } else {
            shortcut()
        }
    }
}

function setSubItemCheckBoxA(what) {
    if(what.checked) {
        boxesChecked += ","+what.name;
    } else {
        boxesChecked=boxesChecked.ReplaceAll(","+what.name,"");
    }
    document.getElementById("itemOrder").value=boxesChecked;
}

function setSubItemCheckBox(what) {
    var currentCheckBox=what.name.substring(0,what.name.lastIndexOf("_"));
    if(what.checked) {
        what.checked=false;
        boxesChecked=boxesChecked.ReplaceAll(","+what.name,"");
    } else {
        what.checked=true;
        boxesChecked += ","+what.name;
    }

}

function ReplaceAll(Source,stringToFind,stringToReplace){
    var temp = Source;
    var index = temp.indexOf(stringToFind);
    while(index != -1){
        temp = temp.replace(stringToFind,stringToReplace);
        index = temp.indexOf(stringToFind);
    }
    return temp;
}

String.prototype.ReplaceAll = function(stringToFind,stringToReplace){
    var temp = this;
    var index = temp.indexOf(stringToFind);
    while(index != -1){
        temp = temp.replace(stringToFind,stringToReplace);
        index = temp.indexOf(stringToFind);
    }
    return temp;
}

function showAttentionMessagePopup() {
    var url = "ajax/updateattnmessage.jsp";
    $.ajax({
        url: url,
        success: function (data) {
            $("#txtHint").html(data);
            $("#txtHint").css("top","150");
            showHide(txtHint,"SHOW");
        },
        complete: function(data){

        },
        error: function() {
            alert("There was a problem processing the request");
        }
    });        
}

function updateAttentionMessage() {
    var url = "ajax/updateattnmessage.jsp?update=y&attentionmsg=" + $("#attentionmsg").val();
    $.ajax({
        url: url,
        success: function (data) {
            $("#attentionMessageText").html(data);
            showHide(txtHint,"HIDE");
        },
        complete: function(data){

        },
        error: function() {
            alert("There was a problem processing the request");
        }
    });        
}