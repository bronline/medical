  function checkban(what){
   if(what.value == '') { return true; }

   var pnum=what.value
   var anum=/(^\d+$)|(^\d+\.\d+$)/
   if (anum.test(pnum))
    testresult=true
   else{
    alert("Please input a number!")
    what.focus();
   }
  }

  function enforcechar(what,limit){
   if (what.value.length>=limit)
   return false
  }
