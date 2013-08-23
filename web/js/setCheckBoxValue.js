    function setCheckBoxValue(what) {
        hiddenName=what.name.substring(0,what.name.indexOf('_cb'));
        var hiddenItem=document.getElementById(hiddenName);
        hiddenItem.value=what.checked;

// Special handling
        if(hiddenName == "copayaspercent") {
            if(what.checked) {
                $('#copayamountlabel').html('<b>Co-Insurance Percent</b>');
            } else {
                $('#copayamountlabel').html('<b>Per Visit Copay Amount</b>');
            }
        }
    }