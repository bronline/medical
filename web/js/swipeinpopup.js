
    var lastTime = "0001-01-01 00:00:00";
    var secs
    var showBubble = true
    var timerID = null
    var timerRunning = false
    var delay = 1000
    var xmlHttpObject;

    function InitializeTimer()
    {
        // Set the length of the timer, in seconds
        secs = 5
        StopTheClock()
        StartTheTimer()
    }

    function StopTheClock()
    {
        if(timerRunning)
            clearTimeout(timerID)
        timerRunning = false
    }

    function StartTheTimer()
    {
        if (secs==0)
        {
            StopTheClock()
            if(showBubble) {
                showInstantMessagesBubble();
                secs = 15;
                StartTheTimer();
            } else {
                showHide(instantMessages,"HIDE");
                showBubble = true;
                secs = 5;
                StartTheTimer();
            }
        }
        else
        {
            self.status = secs;
            secs = secs - 1;
            timerRunning = true;
            timerID = self.setTimeout("StartTheTimer()", delay);
        }
    }

    function showInstantMessagesBubble() {
        var url="ajax/getinstantmessages.jsp?startDate="+encodeURI(lastTime);
        instantMessages.innerHTML="";

        xmlHttpObject=getHttpObject();
        if (xmlHttpObject==null) {
          return;
        }

        url=url+"&sid="+Math.random();
        xmlHttpObject.getMessageBubbleResults=stateChanged;
        xmlHttpObject.open("GET",url,true);
        xmlHttpObject.send(null);
    }

    function getMessageBubbleResults() {
        showBubble = false;
        if (xmlHttpObject.readyState==4) {
            var httpResponse=xmlHttpObject.responseText;
            if(httpResult.indexOf("NONE:")>-1) {
                lastTime=httpResult.substring(5);
            } else {
                instantMessages.innerHTML=xmlHttpObject.responseText;
                showHide(instantMessages,'SHOW');
            }
        }
    }

    function getHttpObject() {
        var xmlHttp=null;
        if(xmlHttpObject == null) {
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
        } else {
            xmlHttp=xmlHttpObject;
        }
        return xmlHttp;
    }
