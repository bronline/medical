
function loadMask() {
    for(y=0; y<document.forms.length; y++) {
        var frmA = document.forms[y];
        for(x=0; x<frmA.elements.length; x++) {
            if(frmA.elements[x].id.substring(0,9) == "maskValue") {
                mask = frmA.elements[x].id.substring(9);
                if(frmA.elements[x].value != '' && frmA.elements[x].value != '0') {
                    dFilter(21, frmA.elements[x], mask);
                } else {
                    frmA.elements[x].value = '';
                }
            }
        }
    }
}

function fillHidden(what) {
    hiddenField = what.name.substring(4);
    var obj=document.getElementById(hiddenField);
    obj.value=dFilterStrip(what.value, what.id.substring(9));
}


var dFilterStep

function dFilterStrip (dFilterTemp, dFilterMask)
{
    dFilterMask = replace(dFilterMask,'#','');
    for (dFilterStep = 0; dFilterStep < dFilterMask.length++; dFilterStep++)
		{
		    dFilterTemp = replace(dFilterTemp,dFilterMask.substring(dFilterStep,dFilterStep+1),'');
		}
		return dFilterTemp;
}

function dFilterMax (dFilterMask)
{
 		dFilterTemp = dFilterMask;
    for (dFilterStep = 0; dFilterStep < (dFilterMask.length+1); dFilterStep++)
		{
		 		if (dFilterMask.charAt(dFilterStep)!='#')
				{
		        dFilterTemp = replace(dFilterTemp,dFilterMask.charAt(dFilterStep),'');
				}
		}
		return dFilterTemp.length;
}

function dFilter (key, textbox, dFilterMask)
{
		dFilterNum = dFilterStrip(textbox.value, dFilterMask);
		
		if (key==9)
		{
		    return true;
		}
		else if (key==8&&dFilterNum.length!=0)
		{
		 	 	dFilterNum = '';
		}
 	  else if ( ((key>47&&key<58)||(key>95&&key<106)) && dFilterNum.length<dFilterMax(dFilterMask) )
		{ if(key>=96&&key<=105) {key = key -48;}
        dFilterNum=dFilterNum+String.fromCharCode(key);
		}

		var dFilterFinal='';
    for (dFilterStep = 0; dFilterStep < dFilterMask.length; dFilterStep++)
		{
        if (dFilterMask.charAt(dFilterStep)=='#')
				{
					  if (dFilterNum.length!=0)
					  {
				        dFilterFinal = dFilterFinal + dFilterNum.charAt(0);
					      dFilterNum = dFilterNum.substring(1,dFilterNum.length);
					  }
				    else
				    {
				        dFilterFinal = dFilterFinal + "";
				    }
				}
		 		else if (dFilterMask.charAt(dFilterStep)!='#')
				{
				    dFilterFinal = dFilterFinal + dFilterMask.charAt(dFilterStep); 			
				}
//		    dFilterTemp = replace(dFilterTemp,dFilterMask.substring(dFilterStep,dFilterStep+1),'');
		}


		textbox.value = dFilterFinal;
    return false;
}

function replace(fullString,text,by) {
// Replaces text with by in string
    var strLength = fullString.length, txtLength = text.length;
    if ((strLength == 0) || (txtLength == 0)) return fullString;

    var i = fullString.indexOf(text);
    if ((!i) && (text != fullString.substring(0,txtLength))) return fullString;
    if (i == -1) return fullString;

    var newstr = fullString.substring(0,i) + by;

    if (i+txtLength < strLength)
        newstr += replace(fullString.substring(i+txtLength,strLength),text,by);

    return newstr;
}
