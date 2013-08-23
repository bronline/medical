<%@include file="template/pagetop.jsp" %>
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
    .patientHeading { font-size: 11px; font-weight: bold; }
</style>

<v:subitemlist id="subItemList" style="position: absolute; top: 50px; left: 20px; visibility: hidden; background-color: white; width: 600; height: 500;"></v:subitemlist>
<v:shadow id="shadow" style='position: absolute; text-align: center; z-index: 98; visibility: hidden; ' arcsize='.05' fillcolor='#666666' >&nbsp;&nbsp;</v:shadow>
<v:roundrect id="txtHint" arcsize='.25' style="text-align: left; position: absolute; z-index: 99; visibility: hidden;"></v:roundrect>
<%
String providerId = request.getParameter("providerId");
String showZeroBalances = request.getParameter("showZeroBalances");
if (showZeroBalances==null) showZeroBalances="false";
if (providerId==null) providerId="0";
boolean zeroBalances = (showZeroBalances.equals("false")) ? false:true;

// Get a list of providers
String providerQuery="SELECT 0 as providerid, '*All' as name union select id as providerid, substr(concat(name,' - ',REPLACE(substr(address,1,locate(_latin1'\r',address)-1),'\r\n',''),' - '," +
        "    case when substr(providers.address,length(providers.address)-4,1)='-' then" +
        "      replace(substr(address,(locate(_latin1'\r',address) + 2),length(address)-10-(locate(_latin1'\r',address) + 2)),'\r\n',' ')" +
        "    else" +
        "      replace(substr(address,(locate(_latin1'\r',address) + 2),length(address)-5-(locate(_latin1'\r',address) + 2)),'\r\n',' ')" +
        "    end),1,55) as name from providers where not reserved order by name";

ResultSet providerRs=io.opnRS(providerQuery);

// Set up an RWHtmlForm
RWHtmlForm frm = new RWHtmlForm("frmInput", "", "POST");

// Show the resource combobox
out.print(frm.startForm());
out.print("<b>Insurance: </b>" + frm.comboBox(providerRs, "providerId", "providerId", false, "1", null, providerId, "class=cBoxText") + "</b>&nbsp;&nbsp;");
if (showZeroBalances.equals("false")) {
    out.print("<input type=CHECKBOX name=showZeroBalances>" + "<b>Show Zero Balances</b>&nbsp;&nbsp;");
} else {
    out.print("<input type=CHECKBOX name=showZeroBalances CHECKED>" + "<b>Show Zero Balances</b>&nbsp;&nbsp;");
}
out.print(frm.submitButton("go", "class=button"));
out.print(frm.endForm());

// Only generate the report if this is a post
if (request.getMethod().equals("POST")) {
    RWConnMgr localIo = new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);
    
    RWHtmlTable htmTb=new RWHtmlTable("800","0");
    htmTb.replaceNewLineChar(false);
    
    ArrayList ageItemHeading=new ArrayList();
    String providerSQL = "select providers.id as providerid, patients.id as patientid, batches.id as batchid, patients.accountnumber, providers.name, " +
            "concat(patients.firstname, ' ', patients.lastname) as patientname, substr(concat(providers.name,' - ', " +
            "REPLACE(substr(providers.address,1,locate(_latin1'\r',providers.address)-1),'\r\n',''),' - '," +
            "   case when substr(providers.address,length(providers.address)-4,1)='-' then" +
            "     replace(substr(providers.address,(locate(_latin1'\r',providers.address) + 2),length(providers.address)-10-(locate(_latin1'\r',providers.address) + 2)),'\r\n',' ')" +
            "   else" +
            "     replace(substr(providers.address,(locate(_latin1'\r',providers.address) + 2),length(providers.address)-5-(locate(_latin1'\r',providers.address) + 2)),'\r\n',' ')" +
            "   end),1,55) as headingname," +
            "patientinsurance.providernumber, patientinsurance.providergroup, batches.billed, batches.lastbilldate, visits.`date` as dateofservice, " +
            "items.code, case when patients.ssn=0 then '' else patients.ssn end as ssn, patients.dob, providers.phonenumber, providers.extension, " +
            "SUM(charges.chargeamount*charges.quantity)-ifnull((select sum(amount) from payments where chargeid=charges.id),0) AS delinquent " +
            "from batches " +
            "left join batchcharges on batches.id=batchcharges.batchid " +
            "left join charges on charges.id=batchcharges.chargeid " +
            "left join visits on visits.id=charges.visitid " +
            "left join items on items.id=charges.itemid " +
            "left join providers on providers.id=batches.provider " +
            "left join patients on patients.id=visits.patientid " +
            "left join patientinsurance on patientinsurance.patientid=patients.id and patientinsurance.providerid=batches.provider " +
            "where (charges.chargeamount*charges.quantity)-ifnull((select sum(amount) from payments where chargeid=charges.id),0)>0 " +
            "and not complete ";

    if (!providerId.equals("0")) {
//        providerSQL="select * from providers where not reserved and id = " + providerId + " order by name";
        providerSQL += "and batches.provider=" + providerId;
//    } else {
//        providerSQL="select * from providers where not reserved order by name";
    }

    providerSQL += " GROUP BY providers.id";
    ResultSet insuranceRs=localIo.opnRS(providerSQL);
    ResultSet agingItemRs=localIo.opnRS("select * from agingitems order by seq");
    while(agingItemRs.next()) {
        ageItemHeading.add(agingItemRs.getString("description"));
    }
    ageItemHeading.add("Total");
    
    Hashtable providers=new Hashtable();
    
    out.print(htmTb.startTable());
    out.print(htmTb.startRow("height=30"));
    out.print(htmTb.addCell("Insurance Provider Aging Report", htmTb.CENTER, "style='font-size: 16; font-weight: bold;'"));
    out.print(htmTb.endRow());
    out.print(htmTb.endTable());
    
    out.print(htmTb.startTable());
    while(insuranceRs.next()) {
        String phoneNumber="";
        if(insuranceRs.getDouble("phonenumber") != 0) { phoneNumber=" - " + tools.utils.Format.formatPhone(insuranceRs.getString("phonenumber")); }
        if(insuranceRs.getInt("extension") !=0) { phoneNumber += " ext: " + insuranceRs.getString("extension"); }
        double [] providerTotals=new double[ageItemHeading.size()];
        out.print(htmTb.startRow());
        out.print(htmTb.headingCell(insuranceRs.getString("headingname") + phoneNumber, 0, "style='font-size: 14px;umber'"));
        out.print(htmTb.endRow());
        out.print(htmTb.startRow());
        out.print(htmTb.addCell(getPatientsForInsurance(zeroBalances, localIo, databaseName, htmTb, insuranceRs.getInt("providerid"), agingItemRs, providerTotals, ageItemHeading, insuranceRs.getString("name"))));
        out.print(htmTb.endRow());
        out.print(htmTb.startRow("height=35"));
        out.print(htmTb.addCell(""));
        out.print(htmTb.endRow());
        providers.put(insuranceRs.getString("providerid"), providerTotals);
    }
    
    double [] grandTotals=new double[ageItemHeading.size()];
    for(Enumeration e=providers.keys(); e.hasMoreElements();) {
        String key=(String)e.nextElement();
        double [] tmp=(double[])providers.get(key);
        for(int t=0;t<tmp.length;t++) { grandTotals[t]+=tmp[t]; }
    }
    
    out.print(htmTb.startTable());
    out.print(htmTb.startRow());
    out.print(htmTb.addCell(""));
    out.print(htmTb.endRow());
    out.print(htmTb.startRow());
    out.print(htmTb.startCell(htmTb.LEFT));
    out.print(htmTb.startTable());
    out.print(htmTb.startRow());
    out.print(htmTb.addCell("<b>Grand Totals</b>", "width=150 style='font-size: 12px; border-top: 1px solid black;'"));
    for(int t=0;t<grandTotals.length;t++) { out.print(htmTb.addCell("<b>"+Format.formatCurrency(grandTotals[t])+"</b>", htmTb.RIGHT, "width=75 style='font-size: 12px; border-top: 1px solid black;'")); }
    out.print(htmTb.endRow());
    out.print(htmTb.endTable());
    out.print(htmTb.endCell());
    
    out.print(htmTb.endTable());
    
    agingItemRs.close();
    insuranceRs.close();
    
    localIo.getConnection().close();
    localIo=null;
    System.gc();
}
%>
<%! public String getPatientsForInsurance(boolean zeroBalances, RWConnMgr localIo, String databaseName, RWHtmlTable htmTb, int providerId, ResultSet agingItemRs, double[] providerTotals, ArrayList ageItemHeading, String providerName) throws Exception {
    StringBuffer pi=new StringBuffer();

    RWConnMgr io = new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);

    ResultSet patientRs=io.opnRS("SELECT distinct p.id, lastname, firstname from patients p join patientinsurance pi on pi.patientid=p.id join providers i on pi.providerid=i.id where i.id="+providerId + " order by lastname, firstname");
    pi.append(htmTb.startTable());
    pi.append(htmTb.startRow());
    pi.append(htmTb.addCell("Patient Name", "style='font-size: 12px; border-bottom: 1px solid black;'"));
    for(int t=0;t<ageItemHeading.size();t++) {
        pi.append(htmTb.addCell((String)ageItemHeading.get(t), htmTb.RIGHT, "width=75 style='font-size: 12px; border-bottom: 1px solid black;'"));
    }
    pi.append(htmTb.endRow());
    
    int row=0;
    while(patientRs.next()) {
        String rowColor="#e0e0e0";
//        int row=patientRs.getRow();
        String infoLink="onClick=\"showBalanceInfo(event,"+patientRs.getInt("id")+","+providerId+",txtHint)\" ";
        double doubleRow=Double.parseDouble(""+row);
        if((row/2) == (doubleRow/2)) { rowColor="#f0f0f0"; }
        String agingString = getPatientAging(zeroBalances, databaseName, htmTb, providerId, agingItemRs, patientRs, providerTotals, rowColor);
        if (agingString.length()>0) {
            row++;
            pi.append(htmTb.startRow());
            pi.append(htmTb.addCell(patientRs.getString("lastname") + ", " + patientRs.getString("firstname"), "width=150 style='cursor: pointer; font-weight: bold; background: " + rowColor + ";' " + infoLink));
            pi.append(agingString);
            pi.append(htmTb.endRow());
        }
    }
    pi.append(htmTb.startRow());
    pi.append(htmTb.addCell(providerName + " Totals", "style='font-size: 12px; border-top: 1px solid black;'"));
    for(int t=0;t<providerTotals.length;t++) { pi.append(htmTb.addCell(Format.formatCurrency(providerTotals[t]), htmTb.RIGHT, "width=75 style='font-size: 12px; border-top: 1px solid black;'")); }
    pi.append(htmTb.endRow());
    pi.append(htmTb.endTable());
    
    patientRs.close();
    patientRs=null;

    io.getConnection().close();
    
    return pi.toString();
}

public String getPatientAging(boolean zeroBalances, String databaseName, RWHtmlTable htmTb, int providerId, ResultSet ageItemRs, ResultSet patientRs, double[] providerTotals, String rowColor) throws Exception {
    RWConnMgr io = new RWConnMgr("localhost", databaseName, "rwtools", "rwtools", RWConnMgr.MYSQL);
    
    String baseQuery="select p.id, sum(c.chargeamount*c.quantity) charges, " +
            "sum(ifnull((select sum(amount) from payments where chargeid=c.id),0.00)) payments " +
            "from charges c " +
            "left join visits v on c.visitid=v.id " +
            "left join patients p on p.id=v.patientid " +
            "left join " +
            "(select distinct patientid, providerid from patientinsurance) pi on pi.patientid=p.id " +
            "left join providers i on i.id=pi.providerid ";
//            "join batchcharges bc on bc.chargeid=c.id " +
//            "join batches b on b.id=bc.batchid and b.provider=i.id ";
    String grouping=" group by p.id";
    StringBuffer pa=new StringBuffer();
    
    int i=0;
    double patientTotal=0.0;
    ageItemRs.beforeFirst();
    while(ageItemRs.next()) {
        String thisQuery=baseQuery;
        String where=" where i.id=" + providerId + " and p.id=" + patientRs.getString("id");
        if(ageItemRs.getInt("mindays")==0 && ageItemRs.getInt("maxdays") != 0) {
            where += " and v.date>DATE_SUB(CURRENT_DATE, INTERVAL '" + ageItemRs.getInt("maxdays") + "' DAY) ";
            where += " and c.id in (select chargeid from batchcharges bc join batches b on b.id=bc.batchid " +
            " where b.provider=" + providerId + ") ";
        } else if(ageItemRs.getInt("mindays") != 0 && ageItemRs.getInt("maxdays") != 0) {
            where += " and v.date between DATE_SUB(CURRENT_DATE, INTERVAL '" + ageItemRs.getInt("maxdays") + "' DAY) and DATE_SUB(CURRENT_DATE, INTERVAL '" + ageItemRs.getInt("mindays") + "' DAY) ";
            where += " and c.id in (select chargeid from batchcharges bc join batches b on b.id=bc.batchid " +
            " where b.provider=" + providerId + ") ";
        } else if(ageItemRs.getInt("mindays") == 0 && ageItemRs.getInt("maxdays") == 0) {
            int batchStuff=baseQuery.indexOf("join batchcharges bc");
            thisQuery=thisQuery.substring(0, batchStuff);
            where += " and c.id not in (select chargeid from batchcharges) ";
        }

        thisQuery=thisQuery+where+grouping;
        
        ResultSet agingRs=io.opnRS(thisQuery);
        if(agingRs.next()) {
            double balance=agingRs.getDouble("charges");
            balance-=agingRs.getDouble("payments");
            pa.append(htmTb.addCell(Format.formatCurrency(balance), htmTb.RIGHT,"width=75 style='background: " + rowColor + "; '"));
            providerTotals[i]+=balance;
            providerTotals[providerTotals.length-1] += balance;
            patientTotal += balance;
        } else {
            pa.append(htmTb.addCell(Format.formatCurrency(0.0), htmTb.RIGHT,"width=75 style='background: " + rowColor + "; '"));
        }
        agingRs.close();
        agingRs=null;
        i++;
    }

    io.getConnection().close();

    pa.append(htmTb.addCell(Format.formatCurrency(patientTotal), htmTb.RIGHT, "width=75 style='background: " + rowColor + "; '"));
    if (!zeroBalances && patientTotal==0) pa.setLength(0);
    return pa.toString();
}
%>
<%@ include file="template/pagebottom.jsp" %>