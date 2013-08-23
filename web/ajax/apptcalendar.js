    var currentAppointmentCell;
    var apptId;
    var apptPatient;

    function submitForm(action) {
        dataString = $(frmInput).serialize();

        $.ajax({
        type: "POST",
        url: action,
        data: dataString,
        success: function(data) {

        },
        complete: function() {
            showHide(txtHint,'HIDE');

            apptId=0;

            $.ajax({
                url: "ajax/releaseappointment.jsp",
                success: function(){
                    currentAppointmentCell.style.border="none";
                },
                complete: function() {
                    location.href="apptcalendar.jsp";
                }
            });

        },
        error: function() {
            alert("There was a problem updating this appointment");
        }

        });

    }

    function deleteAppointment(action) {
        var frmA=document.forms["frmInput"]
        document.getElementById("delete").value="Y";
        frmA.method="POST"
        frmA.action=action
        frmA.submit()
    }

    function closeAppointmentEditBubble() {
        showHide(txtHint,'HIDE');

        apptId=0;

        $.ajax({
            url: "ajax/releaseappointment.jsp",
            context: document.body,
            success: function(){
                currentAppointmentCell.style.border="none";
            }
        });

    }

    function moveCurrentAppointment(apptDate,resourceId,apptTime) {
        if(apptPatient!=null) {
            window.location.href='?apptId=' + apptId + '&patientId=' + apptPatient + '&apptTime=' + apptTime + '&resourceId=' + resourceId + '&apptDate=' + apptDate
        } else {
            alert("No patient selected");
        }
    }

    function showVisit(appointmentId) {
        closeAppointmentEditBubble();
        window.open('gotovisit.jsp?&apptId=' + appointmentId,'VisitActivity','width=1000,height=750,resizable=yes,scrollbars=no,left=50,top=20,');
        closeAppointmentEditBubble();
    }

    function checkDateChange(what) {
        xx="apptcalendar.jsp?" + what.name + "=" + what.options[what.selectedIndex].text;
        location.href=xx;
    }

    function confirmAppointment(resourceId,apptDate,apptTime,patientId) {
        var isSure=confirm("This patient already has an appointment for this date.  Are you sure you want to schedule another appointment on this date?");
        if(isSure) {
            location.href="apptcalendar.jsp?resourceId="+resourceId+"&apptDate="+apptDate+"&apptTime="+apptTime+"&sched=y"
        } else {
            location.href="apptcalendar.jsp"
        }
    }

    function showForResource(what) {
        location.href='apptcalendar.jsp?calendarResourceId=' + what.value
    }

    function showItem(ev,jspName,recId,patientId,obj) {
        e=ev;
        obj.innerHTML='';
        showItemDetails(jspName,recId,patientId,self.location.href,obj.id);
    }

    function showAppointmentEditBubble(what,e,jspName,recId,patientId) {

        $.ajax({
		url: 'ajax/getpatientcontactinfo.jsp?appointmentId=' + recId,
		success: function(data) {
                    $('#miniContactBubble').html(data);
                }
        });

        showItemInFixedPos(what,e,jspName,recId,patientId,txtHint,155,270);
    }

    function showItemInFixedPos(what,e,jspName,recId,patientId,obj,xPos,yPos) {
        what.style.border="solid #cc99ff 3px";
        currentAppointmentCell=what;
        apptId=recId;
        apptPatient=patientId;
        obj.innerHTML='';
        obj.style.left=xPos;
        obj.style.top=yPos;
        showItemDetailsFixedPosition(jspName,recId,patientId,self.location.href,obj.id);
    }

    function showItemDetails(jspName,recId,patientId,parentUrl,objName) {
        var obj=document.getElementById(objName);

        obj.innerHTML="";

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
		success: function(data) {
                    obj.innerHTML=data;
                }
        });

    }

    function showItemDetailsFixedPosition(jspName,recId,patientId,parentUrl,objName) {
        var obj=document.getElementById(objName);

        obj.innerHTML="";

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
		success: function(data) {
                    obj.innerHTML=data;
                    showHide(obj, 'SHOW');
                }
        });

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
        obj.style.height=height;
        obj.style.width=width;
        obj.style.visibility="visible";
    }

    function hideShadow() {
        shadow.style.visibility="hidden";
    }

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

        if(clientPosition <= bottomOfPage-objHeight-50) {
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

