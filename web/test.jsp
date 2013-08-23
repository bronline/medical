<script type="text/javascript">
var dcTime=250;    // doubleclick time
 var dcDelay=100;   // no clicks after doubleclick
 var dcAt=0;        // time of doubleclick
 var savEvent=null; // save Event for handling doClick().
 var savEvtTime=0;  // save time of click event.
 var savTO=null;    // handle of click setTimeOut

 function showMe(form, txt) {
   document.forms[form].elements[0].value += txt;
 }

 function hadDoubleClick() {
   var d = new Date();
   var now = d.getTime();
   showMe(1, "Checking DC (" + now + " - " + dcAt);
   if ((now - dcAt) < dcDelay) {
     showMe(1, "*hadDC*");
     return true;
   }
   showMe(1, " OK ");
   return false;
 }

 function handleWisely(which) {
   showMe(1, which + " fired...");
   switch (which) {
     case "click":
       // If we've just had a doubleclick then ignore it
       if (hadDoubleClick()) return false;

       // Otherwise set timer to act.  It may be preempted by a doubleclick.
       savEvent = which;
       d = new Date();
       savEvtTime = d.getTime();
       savTO = setTimeout("doClick(savEvent)", dcTime);
       break;
     case "dblclick":
       doDoubleClick(which);
       break;
     default:
   }
 }

 function doClick(which) {
   // preempt if DC occurred after original click.
   if (savEvtTime - dcAt <= 0) {
     showMe(1, "ignore Click");
     return false;
   }
   showMe(1, "Handle Click.  ");
 }

 function doDoubleClick(which) {
   var d = new Date();
   dcAt = d.getTime();
   if (savTO != null) {
     clearTimeout( savTO );          // Clear pending Click
     savTO = null;
   }
   showMe(1, "Handle DoubleClick at " + dcAt);
 }
    function handleMe(which) {
        if(which=='dblclick') { alert("hello"); }
        document.forms[0].elements[0].value += which + " fired... Then ";
    }

</script>

<p>
    <a href="javascript:void(0)"
         onclick="handleMe(event.type)"
         onmousedown="handleMe(event.type)"
         onmouseup="handleMe(event.type)"
         ondblclick="handleMe(event.type)"
         style="color: blue; font-family: arial; cursor: hand">
 Click This Text Any Way You See Fit.
 </a>
 </p>

 <form>
 <table>
 <tr><td valign="top">
     Event Being Handled:
     <textarea rows="4" cols="60" wrap="soft"></textarea>
 </td></tr>
 <tr><td valign="top">
     <input type="Reset">
 </td></tr>
 </table>
 </form>
