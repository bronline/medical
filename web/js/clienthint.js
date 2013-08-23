var xmlHttp
var objectName

function showHint(str) {
    objectName="txtHint";
    if (str.length==0) {
      document.getElementById("txtHint").innerHTML="";
      return;
    }

    var url="gethint.jsp";
    url=url+"?q="+str;
    url=url+"&sid="+Math.random();

    $.ajax({
        url: url,
        success: function(data){
            document.getElementById(objectName).innerHTML=data;
            ajaxComplete=true;
            var obj=document.getElementById(objectName);
            showHide(obj,'SHOW');
            setDivPosition(e,obj);
            showHide(obj,'SHOW');
        },
        error: function() {
            alert("There was a problem processing the request");
        }
    });
}

function showItemDetails(jspName,recId,patientId,parentUrl,objName) {
    objectName=objName
    var obj=document.getElementById(objName);
    if (recId.length==0) {
      obj.innerHTML="";
      return;
    }

    var url=jspName;

    if(jspName.indexOf("?")>-1) {
        url=url+"&";
    } else {
        url=url+"?";
    }

    url=url+"id="+recId+"&patientid="+patientId+"&parentUrl="+parentUrl;
    url=url+"&sid="+Math.random();

    $.ajax({
        url: url,
        success: function(data){
            $(obj).html(data);
            ajaxComplete=true;
            showHide(obj,'SHOW');
            setDivPosition(e,obj);
            showHide(obj,'SHOW');
        },
        error: function() {
            alert("There was a problem processing the request");
        }
    });
}

function showItemDetailsFixed(jspName,recId,patientId,parentUrl,objName) {
    objectName=objName
    var obj=document.getElementById(objName);
    if (recId.length==0) {
      obj.innerHTML="";
      return;
    }

    var url=jspName;

    if(jspName.indexOf("?")>-1) {
        url=url+"&";
    } else {
        url=url+"?";
    }

    url=url+"id="+recId+"&patientid="+patientId+"&parentUrl="+parentUrl;
    url=url+"&sid="+Math.random();

    $.ajax({
        url: url,
        success: function(data){
            $(obj).html(data);
            ajaxComplete=true;
            showHide(obj,'SHOW');
        },
        error: function() {
            alert("There was a problem processing the request");
        }
    });
}

function showForm(jspName,recId,patientId,parentUrl) {
    objectName="txtHint";

    if (recId.length==0) {
      $(txtHint).html('');
      return;
    }

    var url=jspName;
    if(jspName.indexOf("?")>-1) {
        url=url+"&";
    } else {
        url=url+"?";
    }

    url=url+"id="+recId+"&patientid="+patientId+"&parentUrl="+parentUrl;
    url=url+"&sid="+Math.random();
  
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

function stateChanged() {
    if (xmlHttp.readyState==4) {
        document.getElementById(objectName).innerHTML=xmlHttp.responseText;
        ajaxComplete=true;
        var obj=document.getElementById(objectName);
        showHide(obj,'SHOW');
        setDivPosition(e,obj);
        showHide(obj,'SHOW');
    }
}

function stateChangedFixed() {
    if (xmlHttp.readyState==4) {
        document.getElementById(objectName).innerHTML=xmlHttp.responseText;
        ajaxComplete=true;
        var obj=document.getElementById(objectName);
        showHide(obj,'SHOW');
    }
}

function formStateChanged() {
    if (xmlHttp.readyState==4) {
        document.getElementById(objectName).innerHTML=xmlHttp.responseText;
        ajaxComplete=true;
        var obj=document.getElementById(objectName);
        setFormPosition(e,obj);
        showHide(obj,'SHOW');
    }
}

function GetXmlHttpObject() {
    var xmlHttp=null;
    try  {
      // Firefox, Opera 8.0+, Safari
      xmlHttp=new XMLHttpRequest();
    } catch (e) {
      // Internet Explorer
      try {
        xmlHttp=new ActiveXObject("Msxml2.XMLHTTP");
      } catch (e) {
        xmlHttp=new ActiveXObject("Microsoft.XMLHTTP");
      }
    }
    return xmlHttp;
}

