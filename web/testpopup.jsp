<%-- 
    Document   : testpopup
    Created on : Jun 22, 2010, 12:29:05 PM
    Author     : Randy
--%>
<%@ include file="globalvariables.jsp" %>
<%@ include file="ajax/ajaxstuff.jsp" %>
<html>
<head>
<script src="js/clienthint.js"></script>
<script type="text/javascript">
    var secs
    var showBubble = true
    var timerID = null
    var timerRunning = false
    var delay = 1000

    function InitializeTimer()
    {
        // Set the length of the timer, in seconds
        secs = 1
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
                showItemInFixedPos(null,"ajax/getinstantmessages.jsp",0,0,instantMessages,100,10);
                showBubble = false;
                secs = 15;
                StartTheTimer();
            } else {
                showHide(instantMessages,"HIDE");
                showBubble = true;
                secs = 30;
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

</script>
</head>

<body onLoad="InitializeTimer()">
<div id="instantMessages" style="text-align: left; background-color: transparent; position: absolute; visibility: hidden; display: none; z-index: 99;"></div>
</body>
</html>
