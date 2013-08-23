   var hintComplete=true;
   var ajaxTimerId=0;
   var what;
   var browserType=whichBrs();
   var patientId;
 
   function initRequest() {
       if (window.XMLHttpRequest) {
           return new XMLHttpRequest();
       } else if (window.ActiveXObject) {
           isIE = true;
           return new ActiveXObject("Microsoft.XMLHTTP");
       }
   }
 
   function doCompletion(formField) {
        if(hintComplete && formField.value.length>0) {
            what=formField;
            window.clearTimeout(ajaxTimerId);
            ajaxTimerId = setTimeout('getRequestedInfo()', 50);
        } else {
            if(formField.value.length < 1) { hideSearchBubble(); }
        }
   }

   function setPatientFromSearch(patientId) {
        location.href=location.href + "?srchString=*EMPTY&srchPatientId=" + patientId;
    }

   function getRequestedInfo() {
       hintComplete=false;
       
       findPos(what);

       var popup=document.getElementById("menuPopup"); 

       popup.style.visibility="visible";
       popup.style.display="";     
       popup.style.zIndex="99";

       var url = "getpatienthint.jsp?formField=" + escape(what.name) + "&searchText=" + escape(what.value);

        $.ajax({
            url: url,
            success: function(data){
                popup.innerHTML=data;
                hintComplete=true;
            }
        });
   }
     
    function parseMessages(what,responseValues) {
        var popUp=document.getElementById("menuPopup");
        popUp.innerHTML=responseValues;
        hintComplete=true;
    }
    
    function setTextBoxValue(formField,fieldValue) {      
       var url = "setpatientid.jsp?id=" + escape(fieldValue);
       patientId=fieldValue;

        $.ajax({
            url: url,
            success: function(data){
                refreshPage();
            }
        });
    }
    
    function refreshPage() {
       currentLocationHref=window.location.href;
       if(currentLocationHref.indexOf("?") != -1) {
           if(currentLocationHref.indexOf("?") < currentLocationHref.length()) { currentLocationHref += "&"; }
       } else {
           currentLocationHref += "?";
       }
       location.href=currentLocationHref+'srchString=*EMPTY';
       location.href=currentLocationHref+"srchPatientId=" + patientId;
    }
    
    function findPos(obj) {
        var searchBubble=document.getElementById("menuPopup");
        findObjPos(obj,searchBubble,0,0);
    }
    
    function findObjPos(obj,searchBubble,leftOffset,topOffset) {
        var p = $(obj);
        var position = p.position();

        curleft=position.left;
        curtop=position.top;

        topOffset = topOffset+20;

        $(searchBubble).css("left", curleft+leftOffset);
        $(searchBubble).css("top", curtop+topOffset);

    }
    
    function hideSearchBubble() {
        if(whichBrs() == 'IExplorer') {

        }
        
        var popup=document.getElementById("menuPopup");       
        popup.style.visibility="hidden";
        popup.style.display="none";
        popup.innerHTML="";
        hintComplete=true;
    }
    
    function whichBrs() {
        var agt=navigator.userAgent.toLowerCase();
        if (agt.indexOf("opera") != -1) return 'Opera';
        if (agt.indexOf("staroffice") != -1) return 'Star Office';
        if (agt.indexOf("webtv") != -1) return 'WebTV';
        if (agt.indexOf("beonex") != -1) return 'Beonex';
        if (agt.indexOf("chimera") != -1) return 'Chimera';
        if (agt.indexOf("netpositive") != -1) return 'NetPositive';
        if (agt.indexOf("phoenix") != -1) return 'Phoenix';
        if (agt.indexOf("firefox") != -1) return 'Firefox';
        if (agt.indexOf("safari") != -1) return 'Safari';
        if (agt.indexOf("skipstone") != -1) return 'SkipStone';
        if (agt.indexOf("msie") != -1) return 'IExplorer';
        if (agt.indexOf("netscape") != -1) return 'Netscape';
        if (agt.indexOf("mozilla/5.0") != -1) return 'Mozilla';
        if (agt.indexOf('\/') != -1) {
        if (agt.substr(0,agt.indexOf('\/')) != 'mozilla') {
        return navigator.userAgent.substr(0,agt.indexOf('\/'));}
        else return 'Netscape';} else if (agt.indexOf(' ') != -1)
        return navigator.userAgent.substr(0,agt.indexOf(' '));
        else return navigator.userAgent;
    }    
    