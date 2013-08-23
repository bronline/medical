<script language = "Javascript">
var tmCh    = ":";
var minHr   = 00;
var maxHr   = 23;
var minMin  = 00;
var maxMin  = 59;
var minSec  = 00;
var maxSec  = 59;

function isInteger(s){
	var i;
    for (i = 0; i < s.length; i++){   
        // Check that current character is number.
        var c = s.charAt(i);
        if (((c < "0") || (c > "9"))) return false;
    }
    // All characters are numbers.
    return true;
}

function stripCharsInBag(s, bag){
	var i;
    var returnString = "";
    // Search through string's characters one by one.
    // If character is not in bag, append to returnString.
    for (i = 0; i < s.length; i++){   
        var c = s.charAt(i);
        if (bag.indexOf(c) == -1) returnString += c;
    }
    return returnString;
}

function isDate(tmStr){
	var pos1=tmStr.indexOf(tmCh)
	var pos2=tmStr.indexOf(tmCh,pos1+1)
	var strHour=tmStr.substring(0,pos1)
	var strMinutes=tmStr.substring(pos1+1,pos2)
	var strSeconds=tmStr.substring(pos2+1)
	strHr=strHour
	if (strMinutes.charAt(0)=="0" && strMinutes.length>1) strMinutes=strMinutes.substring(1)
	if (strSeconds.charAt(0)=="0" && strSeconds.length>1) strSeconds=strSeconds.substring(1)
	for (var i = 1; i <= 3; i++) {
		if (strHr.charAt(0)=="0" && strHr.length>1) strHr=strHr.substring(1)
	}
	hour=parseInt(strHr)
	minutes=parseInt(strMinutes)
	seconds=parseInt(strSeconds)
	if (pos1==-1 || pos2==-1){
		alert("The time should be in format: HH:MM:SS")
		return false
	}
	if (strMinutes.length<1 || minutes<minMin || minutes>maxMin){
		alert("Minutes can only be between " + minMin + " and " + maxMin)
		return false
	}
	if (strSeconds.length<1 || seconds<minSec || seconds>MaxSec){
		alert("Seconds can only be between " + minSec + " and " + maxSec)
		return false
	}
	if (strHour.length<1 || hour<minHr || hour>maxHr){
		alert("Hours must be between " + minHr + " and " + masHr)
		return false
	}
	if (tmStr.indexOf(tmCh,pos2+1)!=-1 || isInteger(stripCharsInBag(tmStr, tmCh))==false){
		alert("Please enter a valid date")
		return false
	}
return true
}

function ValidateDate(what){
	var tm=what
	if (isTime(tm.value)==false){
		tm.focus()
		return false
	}
    return true
 }
</script>