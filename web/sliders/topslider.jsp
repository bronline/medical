<style type="text/css">
#topSliderWrap {
    position: absolute;
    margin: 0 auto;
    left: 100px;
    width: 1100px;
    z-index: 100;
}

#topSlider {
    position: absolute;
    background-color: #cccccc;  
    border-bottom-left-radius: 5px; 
    width: 1100px;
    height: 130px;  /*  was 159px */
    margin-top: -53px;
    border-left: 1px solid black;
    border-bottom: 1px solid black;
    border-right: 1px solid black;  
    z-index: 1;
}

#topSliderContent {
    margin: 5px 5px 5px 5px;
    position: absolute;
    text-align:center;
    color:#333333;
    font-weight:bold;
    padding: 10px;
}

#openCloseTabWrapper {
    position: absolute;
    margin: 130px 0 0 0;
    height: 30px;
    width: 1100px;
    background-color: transparent;
    z-index: 200;
}

#openCloseTab {
    position: absolute;
    margin-top: 130px;
    margin-left: 999px;
    height: 30px;
    width: 100px;
    background-color: #cccccc;
    border-bottom-left-radius: 7px;
    border-bottom-right-radius: 7px;
    border-left: 1px solid black;
    border-bottom: 1px solid black;
    border-right: 1px solid black;
    z-index: 200;
}

#openCloseWrap {
    position: absolute;
    margin-top: 130px;
    margin-left: 1040px;
    font-size:12px;
    font-weight:bold;
    z-index: 200;
}

</style>

<script type="text/javascript">
$(document).ready(function() {
    $(".topMenuAction").click( function() {
        if ($("#openCloseIdentifier").is(":hidden")) {
            $("#topSlider").animate({
                    marginTop: "-53px"
                    }, 500 );
            $("#topMenuImage").html('<img src="images/arrow_down.png" alt="open" height="25px"/>');
            $("#openCloseIdentifier").show();
        } else {
            $("#topSlider").animate({
                    marginTop: "75px"
                    }, 500 );
            $("#topMenuImage").html('<img src="images/arrow_up.png" alt="close" height="25px" />');
            $("#openCloseIdentifier").hide();
        }
    });

});
</script>




<div id="topSliderWrap">
    <div id="openCloseIdentifier"></div>
    <div id="topSlider">
        <div id="topSliderContent">
            
        </div>
        <div id="openCloseTabWrapper"></div>
        <div id="openCloseTab"></div>
        <div id="openCloseWrap">
            <a href="#" class="topMenuAction" id="topMenuImage"><img src="images/arrow_down.png" alt="open" height="25px"/></a>
        </div>
    </div>
</div>
