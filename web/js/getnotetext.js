var noteValue="";

function getNoteText(str) {
    if (str.length==0) {
      return;
    }
    
    noteValue=$(note).val();

    var url="getnotetext.jsp";
    url=url+"?q="+str;
    url=url+"&sid="+Math.random();

    $.ajax({
        url: url,
        success: function(data){
            noteValue += leftTrim(data.substring(1,data.length-1));
            $(note).val(noteValue);
        },
        error: function() {
            alert("There was a problem processing the request");
        }
    });
} 

function setNoteText() {
    noteValue=$(note).val();
}

function leftTrim(sString) {
    while (sString.substring(0,1) == ' ') {
        sString = sString.substring(1, sString.length);
    }
    return sString;
}