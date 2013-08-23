   var hintComplete=true;
   var ajaxTimerId=0;
   var what;
   var browserType=whichBrs();
 
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
            clearTimeout(ajaxTimerId);
            ajaxTimerId = setTimeout('getRequestedInfo()', 300);
        } else {
            if(formField.value.length < 1) { hideSearchBubble(); }
        }
   }

   function getRequestedInfo() {
       hintComplete=false;
       
       findPos(what);

       var popup=document.getElementById("menuPopup"); 

       popup.style.visibility="visible";
       popup.style.display="";     
       popup.style.zIndex="99";

       var url = "getpatienthint.jsp?formField=" + escape(what.name) + "&searchText=" + escape(what.value);
       if (document.getElementById("activeOnly").value=='true')
            url += "&activeOnly=Y"

        $.ajax({
            url: url,
            success: function(data){
                $(menuPopup).html(data);
                hintComplete=true;
            },
            error: function() {
                alert("There was a problem processing the request");
            }
        });
   }
    
    function setTextBoxValue(formField,fieldValue) {      
       var url = "setpatientid.jsp?id=" + escape(fieldValue);

        $.ajax({
            url: url,
            success: function(data){
                refreshPage();
            },
            error: function() {
                alert("There was a problem processing the request");
            }
        });

//       hideSearchBubble();
    }
    
    function refreshPage() {
       currentLocationHref=window.location.href;
       if(currentLocationHref.indexOf("?") != -1) {
           if(currentLocationHref.indexOf("?") < currentLocationHref.length()) { currentLocationHref += "&"; }
       } else {
           currentLocationHref += "?";
       }
       location.href=currentLocationHref+'srchString=*EMPTY';
    }
    
    function findPos(obj) {
        var searchBubble=document.getElementById("menuPopup");
        findObjPos(obj,searchBubble,0,0);
    }
    
    function findObjPos(obj,searchBubble,leftOffset,topOffset) {
//        var curleft = curtop = 0;

//        if (obj.offsetParent) {
//            do {
//                curleft += obj.offsetLeft;
//                curtop += obj.offsetTop;
//            } while (obj = obj.offsetParent);
//        }
//        topOffset = topOffset+20;
////        leftOffset = leftOffset - 150;
//        if(browserType == 'IExplorer') { topOffset += 10; leftOffset = leftOffset -0;}
//        searchBubble.style.marginLeft=curleft+leftOffset;
//        searchBubble.style.marginTop=curtop+topOffset;
  
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
    