<%--
    Document   : report_insurance_aging
    Created on : Jul 7, 2010, 9:40:53 AM
    Author     : rwandell
--%>
<%@include file="template/pagetop.jsp" %>
<script type="text/javascript">
    var enablePageScripts=true;
    var ajaxComplete=true;
    var enableMouseOut=true;
    var parentLocation;

    var e

    function printAgingReport(providerId,patientType) {
        window.open("print_insurance_aging.jsp?printReport=Y&providerId=" + providerId+"&patientType="+patientType,"AgingReport");
    }

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
        what.style.left=100;
        what.style.top=100;
    }

    function checkForNew(what, url) {
        if(what.value == -1) {
            formObj=what
            showInputForm(window.event,url,0,0,txtHint);
        }
    }

    function updateList(what) {
        get(what.parentNode,'SAVE');
    }

    function updateSubItem(what,v) {
        visitId=v;
        get(what.parentNode,'SAVE');
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
        showItemDetails(jspName,recId,patientId,self.location.href,obj.id);
    }

    function replaceContents(e,jspName,recId,patientId,obj) {
//        showItemDetails(jspName,recId,patientId,self.location.href,obj.id);
        var url=jspName;
        if(jspName.indexOf("?")>-1) {
            url=url+"&";
        } else {
            url=url+"?";
        }
        url+="id="+recId+"&patientid="+patientId+"&parentUrl="+self.location.href
        var req = initRequest();
        req.onreadystatechange = function() {
            if (req.readyState == 4) {
                if (req.status == 200) {
                    obj.innerHTML=req.responseText;
                }
            }
        }
        req.open("POST", url, true);
        req.send(null);
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

    function showBalanceInfo(ev,patientId,providerId,txtHint) {
        windowEvent=ev;
        getBalanceInfo(ev,patientId,providerId);
    }

    function getBalanceInfo(windowEvent,patientId,providerId) {
        objectName="txtHint";
        var url="ajax/patientbalanceinfo.jsp?patientId="+patientId+"&providerId="+providerId;
        url=url+"&sid="+Math.random();
        var req = initRequest();
        req.onreadystatechange = function() {
            if (req.readyState == 4) {
                if (req.status == 200) {
                    var posy=0;
                    var bottomOfPage=0;

                    var obj=document.getElementById("txtHint");
                    obj.innerHTML=req.responseText;

//                    findWindowPosition(e);
                    posy=windowEvent.clientY;
                    bottomOfPage=posBottom();

                    if(posy + 350 > bottomOfPage) { posy=posy-350; }
                    if(posy - 350 < 0) { posy=posy+10; }

                    obj.style.top=posy;
                    obj.style.left="300";
                    obj.style.backgroundColor="#a6c3f8";
                    showHide(obj,'SHOW');
                }
            }
        }
        req.open("GET", url, true);
        req.send(null);

    }

    function findWindowPosition(e) {
        alert("hello")
	if (!e) var e = window.event;
	if (e.pageX || e.pageY) 	{
		posx = e.pageX;
		posy = e.pageY;
	}
	else if (e.clientX || e.clientY) 	{
		posx = e.clientX + document.body.scrollLeft
			+ document.documentElement.scrollLeft;
		posy = e.clientY + document.body.scrollTop
			+ document.documentElement.scrollTop;
	}
	// posx and posy contain the mouse position relative to the document
	// Do something with this information
    }
// Browser Window Size and Position
function pageWidth() {
    return window.innerWidth != null?
    window.innerWidth :
    document.documentElement && document.documentElement.clientWidth ?
    document.documentElement.clientWidth :
    document.body != null ? document.body.clientWidth : null;
}

function pageHeight() {
    return  window.innerHeight != null? window.innerHeight :
    document.documentElement && document.documentElement.clientHeight ?
    document.documentElement.clientHeight : document.body != null?
    document.body.clientHeight : null;
}

function posLeft() {
    return typeof window.pageXOffset != 'undefined' ?
    window.pageXOffset :document.documentElement && document.documentElement.scrollLeft ?
    document.documentElement.scrollLeft : document.body.scrollLeft ? document.body.scrollLeft : 0;
}

function posTop() {
    return typeof window.pageYOffset != 'undefined' ?
    window.pageYOffset : document.documentElement && document.documentElement.scrollTop ?
    document.documentElement.scrollTop : document.body.scrollTop ?
    document.body.scrollTop : 0;
}

function posRight() {
    return posLeft()+pageWidth();
}

function posBottom() {
    return posTop()+pageHeight();
}


</script>
<style type="text/css">
    .providerTotals { font-size: 11px; }
    .grandTotals { font-size: 11px; }
</style>
<v:subitemlist id="subItemList" style="position: absolute; top: 50px; left: 20px; visibility: hidden; background-color: white; width: 600; height: 500;"></v:subitemlist>
<v:shadow id="shadow" style='position: absolute; text-align: center; z-index: 98; visibility: hidden; ' arcsize='.05' fillcolor='#666666' >&nbsp;&nbsp;</v:shadow>
<v:roundrect id="txtHint" arcsize='.25' style="text-align: left; position: absolute; z-index: 99; visibility: hidden;"></v:roundrect>
<%
String providerId = request.getParameter("providerId");
String showZeroBalances = request.getParameter("showZeroBalances");
String patientKey = "";
String providerKey = "";
String providerName = "";
String patientName = "";
String patientId = "";
String rowColor="#e0e0e0";
String delinquentDays = request.getParameter("delinquentDays");
String patientTypeSelection = "";
String pType = request.getParameter("patientType");


if (showZeroBalances==null) showZeroBalances="false";
if (providerId==null) providerId="0";
if (delinquentDays==null) delinquentDays="0";
boolean zeroBalances = (showZeroBalances.equals("false")) ? false:true;
boolean pipOnly = false;
boolean insuranceOnly = false;

if(request.getParameter("patientType") != null) {
    if(request.getParameter("patientType").equals("P")) { patientTypeSelection = " and patientinsurance.ispip "; }
    if(request.getParameter("patientType").equals("I")) { patientTypeSelection = " and not patientinsurance.ispip "; }
}

// Get a list of providers
String myQuery="select providers.id as providerid, patients.id as patientid, batches.id as batchid, patients.accountnumber, providers.name, concat(patients.firstname, ' ', patients.lastname) as patientname, DATEDIFF(current_date,billed) as daysold, " +
        "  substr(concat(providers.name,' - ',REPLACE(substr(providers.address,1,locate(_latin1'\r',providers.address)-1),'\r\n',''),' - ', " +
        "   case when substr(providers.address,length(providers.address)-4,1)='-' then " +
        "     replace(substr(providers.address,(locate(_latin1'\r',providers.address) + 2),length(providers.address)-10-(locate(_latin1'\r',providers.address) + 2)),'\r\n',' ') " +
        "   else " +
        "     replace(substr(providers.address,(locate(_latin1'\r',providers.address) + 2),length(providers.address)-5-(locate(_latin1'\r',providers.address) + 2)),'\r\n',' ') " +
        "   end),1,55) as headingname, providers.address, " +
        "patientinsurance.providernumber, patientinsurance.providergroup, batches.billed, batches.lastbilldate, visits.`date` as dateofservice, items.code, case when patients.ssn=0 then '' else patients.ssn end as ssn, patients.dob, providers.phonenumber, providers.extension, " +
        "(charges.chargeamount*charges.quantity)-ifnull((select sum(amount) from payments where chargeid=charges.id),0) AS delinquent " +
        "from batches " +
        "left join batchcharges on batches.id=batchcharges.batchid " +
        "left join charges on charges.id=batchcharges.chargeid " +
        "left join visits on visits.id=charges.visitid " +
        "left join items on items.id=charges.itemid " +
        "left join providers on providers.id=batches.provider " +
        "left join patients on patients.id=visits.patientid " +
        "left join patientinsurance on patientinsurance.patientid=patients.id and patientinsurance.providerid=batches.provider " +
        "where (charges.chargeamount*charges.quantity)-ifnull((select sum(amount) from payments where chargeid=charges.id),0)>0 " +
        "and not complete " +
        patientTypeSelection +
        "and DATEDIFF(current_date,billed)>=" + delinquentDays;

String providerQuery="SELECT 0 as providerid, '*All' as name union select id as providerid, substr(concat(name,' - ',REPLACE(substr(address,1,locate(_latin1'\r',address)-1),'\r\n',''),' - '," +
        "    case when substr(providers.address,length(providers.address)-4,1)='-' then" +
        "      replace(substr(address,(locate(_latin1'\r',address) + 2),length(address)-10-(locate(_latin1'\r',address) + 2)),'\r\n',' ')" +
        "    else" +
        "      replace(substr(address,(locate(_latin1'\r',address) + 2),length(address)-5-(locate(_latin1'\r',address) + 2)),'\r\n',' ')" +
        "    end),1,55) as name from providers where not reserved order by name";

ResultSet providerRs=io.opnRS(providerQuery);
ResultSet agingComboRs=io.opnRS("select mindays as delinquentDays from agingitems order by seq");
ResultSet patientTypeRs=io.opnRS("select 'A' as patientType, 'All' As description union select 'I' as patientType, 'Insurance' As description union select 'P' as patientType, 'PIP' As description");

// Set up an RWHtmlForm
RWHtmlForm frm = new RWHtmlForm("frmInput", "", "POST");

out.print(patientTypeSelection);

// Show the resource combobox
out.print(frm.startForm());
out.print("<b>Insurance: </b>" + frm.comboBox(providerRs, "providerId", "providerId", false, "1", null, providerId, "class=cBoxText") + "</b>&nbsp;&nbsp;");
//out.print("<b>Delinquent Days: </b>" + frm.comboBox(agingComboRs, "delinquentDays", "delinquentDays", false, "1", null, delinquentDays, "class=cBoxText") + "</b>&nbsp;&nbsp;");

//out.print("<b>Delinquent Days</b>&nbsp;&nbsp;<input type=\"text\" value=\"" + delinquentDays + "\" name=\"delinquentDays\" size=\"3\" maxlength=\"3\" id=\"delinquentDays\" class=\"tBoxText\" style=\"text-align: right;\">&nbsp;&nbsp;");
out.print("<b>Patient Type: " + frm.comboBox(patientTypeRs, "patientType", "patientType", false, "1", null, pType, "class=cBoxText") + "</b>&nbsp;&nbsp;");

out.print(frm.submitButton("go", "class=button"));
out.print(frm.endForm());

// Only generate the report if this is a post
if (request.getMethod().equals("POST")) {
    RWConnMgr localIo = new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);

    RWHtmlTable htmTb=new RWHtmlTable("800","0");
    htmTb.replaceNewLineChar(false);

    ArrayList ageItemHeading=new ArrayList();
    ArrayList ageItemMaxDays=new ArrayList();
    ArrayList ageItemMinDays=new ArrayList();
    String providerSQL;
    if (!providerId.equals("0")) {
        myQuery += " and batches.provider = " + providerId;
    }
    myQuery += " order by providers.name, providers.address, CONCAT(patients.lastname, patients.firstname)";
    ResultSet insuranceRs=io.opnRS(myQuery);

    ResultSet agingItemRs=io.opnRS("select * from agingitems order by seq");
    while(agingItemRs.next()) {
        ageItemHeading.add(agingItemRs.getString("description"));
        ageItemMaxDays.add(agingItemRs.getString("maxdays"));
        ageItemMinDays.add(agingItemRs.getString("mindays"));
    }
    ageItemHeading.add("Total");

    double [] patientTotals = new double[ageItemHeading.size()];
    double [] payerTotals = new double[ageItemHeading.size()];
    double [] grandTotals = new double[ageItemHeading.size()];

    Hashtable providers=new Hashtable();
%>
<%@include file="insurance_aging_body.jsp" %>
<%
//    out.print(htmTb.endTable());

    out.print("<br><input type=\"button\" onClick=\"printAgingReport(" + providerId + ",'" + pType + "')\" value=\"print\" class=\"button\">");
    agingItemRs.close();
    insuranceRs.close();

    localIo.getConnection().close();
    localIo=null;
    System.gc();
}
%>
<%! public String getPatientHeading(ResultSet lRs) {
        return "";
    }
%>
<%@ include file="template/pagebottom.jsp" %>