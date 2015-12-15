<script type="text/javascript" src="js/clienthint.js"></script>
<script type="text/javascript" src="js/prtscreen.js"></script>
<script type="text/javascript">
    var enablePageScripts=true;
    var ajaxComplete=true;
    var enableMouseOut=true;
    var parentLocation;

    var e

    function setDivPosition(e, what) {
        var bottomOfPage=0;
        var clientPosition=0;
        var objStyleHeight="";
        var objHeight=0;
        var rightPosition=0;
        var objStyleWidth="";
        var objWidth=0;
        var objRightPosition=0;

        if(whichBrs() == "IExplorer") { e=window.event; }

        bottomOfPage=posBottom();
        clientPosition=e.clientY;

        objHeight=document.getElementById(what.id).offsetHeight;
        objWidth=document.getElementById(what.id).offsetWidth;

        clientPosition=e.clientY;

        if(clientPosition<=bottomOfPage-objHeight-50) {
            what.style.top=e.clientY+10;
        } else {
            var objTopPosition=0;
            objTopPosition=e.clientY;
            objTopPosition=objTopPosition-objHeight-50
            what.style.top=objTopPosition;
        }

        rightPosition=posRight();
        clientPosition=e.clientX;

        if(clientPosition<=rightPosition-objWidth-50) {
            objRightPosition=e.clientX;
            what.style.left=objRightPosition
        } else {
            what.style.left=rightPosition-objWidth-50;
        }

    }

    function setFormPosition(e, what) {
        what.style.left=25;
        what.style.top=50;
    }

    function checkForNew(what, url) {
        if(what.value == -1) {
            formObj=what;
            showInputForm(window.event,url,0,0,txtHint);
        }
    }

    function updateList(what) {
        get(what.parentNode,'SAVE');
    }

    function updateSubItem(what,v) {
        visitId=v;
//        get(what.parentNode,'SAVE');
        processForm(what.parentNode,'SAVE',null);
    }

    function finishSubItem() {
        refreshProcedureList(visitId);
        refreshNoteList(visitId);
        showHide(subItemList,'HIDE');
    }

    function showHide(what,state) {
        if(state == "HIDE" && enableMouseOut) {
            document.getElementById("txtHint").innerHTML='';            
            what.style.visibility="hidden";
            what.style.display="none";
            hideShadow();
            enablePageScripts=true;
        } else {
            var obj=document.getElementById(what.id);
            var shadowObj=document.getElementById("shadow");
            what.style.visibility="visible";
            what.style.display="";
            what.style.zIndex="99";
            findObjPos(obj,shadowObj,10,-5);
            showShadow(obj,obj.offsetHeight,obj.offsetWidth);
        }
    }

    function showShadow(what,height,width) {
        var obj=document.getElementById("shadow");
//        findObjPos(what,obj,10,10);
        obj.style.height=height;
        obj.style.width=width;
        obj.style.visibility="visible";

//        shadow.style.height=height;
//        shadow.style.width=width;
//        shadow.style.visibility="visible";
    }

    function hideShadow() {
        shadow.style.visibility="hidden";
    }
    
    function showPhoneNumber(e,criteria,txtHint) {
        if(ajaxComplete && enableMouseOut) {
            ajaxComplete=false;
            document.getElementById("txtHint").innerHTML='';
            showHint(criteria);
            setDivPosition(e,txtHint);
        }
    }
    
    function showItem(ev,jspName,recId,patientId,obj) {
        e=ev;
        obj.innerHTML='';
 //       setDivPosition(e,obj);
        showItemDetails(jspName,recId,patientId,self.location.href,obj.id);
    }

    function showItemInFixedPos(e,jspName,recId,patientId,obj,xPos,yPos) {
        obj.innerHTML='';
        obj.style.left=xPos;
        obj.style.top=yPos;
        showItemDetailsFixed(jspName,recId,patientId,self.location.href,obj.id);
    }
    
    function replaceContents(e,jspName,recId,patientId,obj) {
//        showItemDetails(jspName,recId,patientId,self.location.href,obj.id);
        var url=jspName;
        if(jspName.indexOf("?")>-1) {
            url=url+"&";
        } else {
            url=url+"?";
        }

        url+="id="+recId+"&patientid="+patientId+"&parentUrl="+self.location.href;

        $.ajax({
            url: url,
            success: function(data){
                obj.innerHTML=data;
            }
        });
    }
    
    function showInputForm(ev,jspName,recId,patientId,txtHint) {
        e=ev;
        enablePageScripts=false;
        setFormPosition(e,txtHint);
        showForm(jspName,recId,patientId,self.location.href);
//        showHide(txtHint,'SHOW');
    }

    function resize(){  
        var frame = document.getElementById("txtHint");  
        var htmlheight = document.body.parentNode.scrollHeight;  
        var windowheight = window.innerHeight;
        var htmlwidth = document.body.parentNode.scrollwidth;  
        var windowwidth = window.innerWidth;

        document.body.style.height = htmlheight + "px"; frame.style.height = htmlheight + "px"; 
        document.body.style.width = htmlwidth + "px"; frame.style.width = htmlwidth + "px"; 

    }

    function processForm(obj,mode,refreshObject) {
        parentLocation=null;
        refreshObject=null
        try {
            parentLocation=document.getElementById("parentLocation").value;
        } catch (err) {}

        try {
            refreshObject=document.getElementById("refreshObject").value;
        } catch (err) {}

        var poststr = "update=" + encodeURI( "Y" );

        if(mode == 'DELETE') { poststr += "&delete=" + encodeURI( "Y" ); }

        dataString = $(obj).serialize();

        var conditionId=$("#rcd").val();
        $.ajax({
            type: "POST",
            url: document.getElementById("postLocation").value,
            data: poststr + "&" + dataString,
            success: function(data) {
                document.getElementById("txtHint").style.visibility='hidden'
                document.getElementById("txtHint").innerHTML='';
                if(parentLocation == null) {
                    location.href=self.location.href;
                } else if(parentLocation.toUpperCase() == 'NONE') {
                    showHide(txtHint,'HIDE');
                    $(formObj).html(data);
                } else if(parentLocation.toUpperCase() == 'SUBITEM') {
                    refreshProcedureList(visitId);
                    showHide(subItemList,'HIDE');
                } else if(parentLocation.toUpperCase() == 'VISITNOTE') {
                   showHide(txtHint,'HIDE');
                   refreshNoteList(visitId);
                } else if(parentLocation.toUpperCase() == 'CONDITION') {
                    showHide(txtHint,'HIDE');
                    $(formObj).html(data);
                    if(mode == 'DELETE') {
                        refreshConditionList(visitId,'undefined');
                    } else {
                        try{
                            refreshConditionList(visitId, conditionId);
                        } catch (err) {}
                    }
                } 

                if(refreshObject != null) {
                    $(refreshObject).html(data);
                }
            },
            error: function() {
                alert("There was a problem with the request");
            },
            complete: function() {
                ajaxComplete=true;
                enableMouseOut=true;
                if(parentLocation.toUpperCase() == 'XRAYS') {
                    location.href = "xrays.jsp";
//                    showHide(txtHint,'HIDE');
//                    $('#xrayPatientCondition').html(data);
//                    refreshXrayConditionList(conditionId);
                }                
            }
        });

    }
    
   var http_request = false;
   function makePOSTRequest(url, parameters) {

      http_request = false;
      if (window.XMLHttpRequest) { // Mozilla, Safari,...
         http_request = new XMLHttpRequest();
         if (http_request.overrideMimeType) {
         	// set type accordingly to anticipated content type
            //http_request.overrideMimeType('text/xml');
            http_request.overrideMimeType('text/html');
         }
      } else if (window.ActiveXObject) { // IE
         try {
            http_request = new ActiveXObject("Msxml2.XMLHTTP");
         } catch (e) {
            try {
               http_request = new ActiveXObject("Microsoft.XMLHTTP");
            } catch (e) {}
         }
      }
      if (!http_request) {
         alert('Cannot create XMLHTTP instance');
         return false;
      }

      http_request.onreadystatechange = alertContents;
      http_request.open('POST', url, true);
      http_request.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
      http_request.setRequestHeader("Content-length", parameters.length);
      http_request.setRequestHeader("Connection", "close");
      http_request.send(parameters);

    }
   
    function get(obj,mode) {
        parentLocation=null;
        try {
            parentLocation=document.getElementById("parentLocation").value;
        } catch (err) {}

        var poststr = "update=" + encodeURI( "Y" );       

        if(mode == 'DELETE') { poststr += "&delete=" + encodeURI( "Y" ); }
        
        // Get the values from the input items
        var names=document.getElementsByTagName('input');
        for(x=0;x<names.length;x++) { 
            try {
                if(names[x].type != 'button') {
                    if(names[x].name=='ID') {
                        names[x].name=names[x].name.toLowerCase();
                    }
                    poststr += "&" + names[x].name + "="+encodeURI( document.getElementById(names[x].name).value )
                }
            } catch (err) {}
        }
        
        // Get the values from the textarea items
        var names=document.getElementsByTagName('textarea');
        for(x=0;x<names.length;x++) { 
            try {
                poststr += "&" + names[x].name+"="+encodeURI( document.getElementById(names[x].name).value )
            } catch (err) {}
        }

        // Get the values from the select items
        var names=document.getElementsByTagName('select');
        for(x=0;x<names.length;x++) { 
            try {
                poststr += "&" + names[x].name+"="+encodeURI( document.getElementById(names[x].name).value )
            } catch (err) {}
        }

        // Get the values from the hidden items
        var names=document.getElementsByTagName('hidden');
        for(x=0;x<names.length;x++) { 
            try {
                poststr += "&" + names[x].name+"="+encodeURI( document.getElementById(names[x].name).value )
            } catch (err) {}
        }

        makePOSTRequest(document.getElementById("postLocation").value,poststr);
   }
   
   function alertContents() {
      if (http_request.readyState == 4) {
         if (http_request.status == 200) {
            result = http_request.responseText;
            document.getElementById("txtHint").style.visibility='hidden'
            document.getElementById("txtHint").innerHTML='';
            if(parentLocation == null) { location.href=self.location.href; }
            else if(parentLocation.toUpperCase() == 'NONE') {
                showHide(txtHint,'HIDE');
                formObj.innerHTML=http_request.responseText;
            } else if(parentLocation.toUpperCase() == 'SUBITEM') {
                refreshProcedureList(visitId);
                showHide(subItemList,'HIDE');
           } else if(parentLocation.toUpperCase() == 'VISITNOTE') {
               showHide(txtHint,'HIDE');
               refreshNoteList(visitId);
           } else if(parentLocation.toUpperCase() == 'CONDITION') {
               showHide(txtHint,'HIDE');
               formObj.innerHTML=result;
               refreshConditionList(visitId);
               refreshSymptomList(visitId);
           }
         } else {
            alert('There was a problem with the request. Status (' + http_request.status + ')');
         }
         ajaxComplete=true;
         enableMouseOut=true;
      }
   }

</script>
<div id="txtHint" style="text-align: left; background-color: transparent; position: absolute; visibility: hidden; display: none; z-index: 99;"></div>
<v:subitemlist id="subItemList" style="position: absolute; top: 50px; left: 20px; visibility: hidden; background-color: white; width: 600; height: 500;"></v:subitemlist>
<v:shadow id="shadow" style='position: absolute; text-align: center; z-index: 98; visibility: hidden; ' arcsize='.05' fillcolor='#666666' >&nbsp;&nbsp;</v:shadow>
