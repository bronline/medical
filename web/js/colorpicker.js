     var perline = 9;
     var divSet = false;
     var curId;
     var colorLevels = Array('0', '6','F');
     var colorArray = Array();
     var ie = false;
     var nocolor = 'none';
	 if (document.all) { ie = true; nocolor = ''; }
	 function getObj(id) {
		if (ie) { return document.all[id]; } 
		else {	return document.getElementById(id);	}
	 }

     function addColor(r, g, b) {
     	var red = colorLevels[r];
     	var green = colorLevels[g];
     	var blue = colorLevels[b];
     	addColorValue(red, green, blue);
     }

     function addColorValue(r, g, b) {
     	colorArray[colorArray.length] = '#' + r + r + g + g + b + b;
     }
     
     function addAColor(g, b) {
       for (r1 = 0; r1 < colorLevels.length; r1++)
       for (g1 = 0; g1 < colorLevels.length; g1++)
       for (b1 = 0; b1 < colorLevels.length; b1++) { 
         for (r = 0; r < colorLevels.length; r++) {
           colorArray[colorArray.length] = '#' + colorLevels[r1] + colorLevels[r] + colorLevels[g1] + colorLevels[r] + colorLevels[b1] + '0';
           colorArray[colorArray.length] = '#' + colorLevels[r1] + colorLevels[r] + colorLevels[g1] + colorLevels[r] + colorLevels[b1] + 'F';
         }
       }  
     }

     function setColor(color) {
     	var link = getObj(curId);
     	var field = getObj(curId + 'field');
     	var picker = getObj('colorpicker');
     	field.value = color;
     	if (color == '') {
	     	link.style.background = nocolor;
	     	link.style.color = nocolor;
	     	color = nocolor;
     	} else {
	     	link.style.background = color;
	     	link.style.color = color;
	    }
     	picker.style.display = 'none';
	    eval(getObj(curId + 'field').title);
     }
        
     function setDiv() {     
     	if (!document.createElement) { return; }
        var elemDiv = document.createElement('div');
        if (typeof(elemDiv.innerHTML) != 'string') { return; }
        genColors();
        elemDiv.id = 'colorpicker';
	    elemDiv.style.position = 'absolute';
        elemDiv.style.display = 'none';
        elemDiv.style.border = '#000000 1px solid';
        elemDiv.style.background = '#FFFFFF';
        elemDiv.innerHTML = '<span style="font-family:tahoma; font-size:9px;">Pick a color: ' 
          	+ '(<a href="javascript:setColor(\'\');">No color</a>)<br>' 
        	+ getColorTable() 
        	+ '<center></center></span>';

        document.body.appendChild(elemDiv);
        divSet = true;
     }
     
     function pickColor(id) {
     	if (!divSet) { setDiv(); }
     	var picker = getObj('colorpicker');     	
		if (id == curId && picker.style.display == 'block') {
			picker.style.display = 'none';
			return;
		}
     	curId = id;
     	var thelink = getObj(id);
     	picker.style.top = getAbsoluteOffsetTop(thelink) + 20;
     	picker.style.left = getAbsoluteOffsetLeft(thelink);     
	picker.style.display = 'block';
     }
     
     function genColors() {
	
        addAColor(0, 0);
        return colorArray;
     }

     function getColorTable() {
         var colors = colorArray;
      	 var tableCode = '';
         tableCode += '<table border="0" cellspacing="1" cellpadding="1">';
         for (i = 0; i < colors.length; i++) {
              if (i % perline == 0) { tableCode += '<tr>'; }
              tableCode += '<td bgcolor="#000000"><a style="outline: 1px solid #000000; color: ' 
              	  + colors[i] + '; background: ' + colors[i] + ';font-size: 10px;" title="' 
              	  + colors[i] + '" href="javascript:setColor(\'' + colors[i] + '\');">&nbsp;&nbsp;&nbsp;</a></td>';
              if (i % perline == perline - 1) { tableCode += '</tr>'; }
         }
         if (i % perline != 0) { tableCode += '</tr>'; }
         tableCode += '</table>';
      	 return tableCode;
     }
     function relateColor(id, color) {
     	var link = getObj(id);
     	if (color == '') {
	     	link.style.background = nocolor;
	     	link.style.color = nocolor;
	     	color = nocolor;
     	} else {
	     	link.style.background = color;
	     	link.style.color = color;
	    }
	    eval(getObj(id + 'field').title);
     }
     function getAbsoluteOffsetTop(obj) {
     	var top = obj.offsetTop;
     	var parent = obj.offsetParent;
     	while (parent != document.body) {
     		top += parent.offsetTop;
     		parent = parent.offsetParent;
     	}
     	return top;
     }
     
     function getAbsoluteOffsetLeft(obj) {
     	var left = obj.offsetLeft;
     	var parent = obj.offsetParent;
     	while (parent != document.body) {
     		left += parent.offsetLeft;
     		parent = parent.offsetParent;
     	}
     	return left;
     }

