    function invertSelection() {
      var checkedBoxes='';
      var inputItems = document.getElementsByTagName("input");
      for (var i=0;i<inputItems.length;i++) {
        var e = inputItems[i];
        if (e.type=='checkbox' && !e.disabled) {
          if(e.checked) {
            e.checked=false;
          } else {
            e.checked=true;
          }
        }
      }

    }
