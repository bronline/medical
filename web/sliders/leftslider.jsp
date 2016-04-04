<link rel="stylesheet" type="text/css" href="css/loading.css" title="stylesheet">
<style type="text/css">
#leftSliderWrap {
	position: absolute;
	top: 350px;
	height: 400px;
        z-index: 110;
}

#leftSlider {
	position: absolute;
	background-color: #cccccc;
	height: 400px;
	width: 1000px;
	margin-left: -1008px;
	float: right;
	border-top-right-radius: 7px;
/*	border-bottom-right-radius: 7px;  */
        border-top: 1px solid black;
        border-right: 1px solid black;
        border-bottom: 1px solid black;
}

#leftSliderContent {
	margin: 5px 5px 5px 5px;
	position: absolute;
	text-align: center;
	color: #333333;
	font-weight: bold;
	padding: 5px;
        height: 350px;
        width: 980px;
        overflow-y: auto;
        overflow-x: hidden;
}

#leftOpenCloseWrapper {
	position: absolute;
	width: 30px;
	height: 400px;
	margin-left: 1000px;
	background-color: transparent;
}

#leftOpenCloseTab {
	position: absolute;
	margin-top: 299px;
	margin-left: 1000px;
	height: 100px;
	width: 30px;
	background-color: #cccccc;
	border-top-right-radius: 7px;
	border-bottom-right-radius: 7px;
        border-top: 1px solid black;
        border-right: 1px solid black;
        border-bottom: 1px solid black;
}

#leftOpenCloseWrap {
	position: absolute;
	margin-left: 1005px;
	margin-top: 340px;
}

#leftCloseId {
	display: none;
}

#slider img {
border: 0;
}



</style>

<script type="text/javascript">
    $(document).ready(function() {

            $(".leftMenuAction").click( function() {
                    if ($("#leftCloseId").html()=="open") {
                            $("#leftSlider").animate({
                                    marginLeft: "-1008px"
                                    }, 500 );
                            $("#leftMenuImage").html('<img src="images/arrow_right.png" alt="open" height="25px"/>');
                            $("#leftCloseId").html("");

                    } else {
                            $("#leftSlider").animate({
                                    marginLeft: "-8px"
                                    }, 500 );
                            $("#leftMenuImage").html('<img src="images/arrow_left.png" alt="close" height="25px" />');
                            $("#leftCloseId").html("open");
                            setLeftContent();
                    }
            });

    });   

    function setLeftContent() {
        if($("#leftSliderContent").html() != '') {
            $.ajax({
                type: "POST",
                url: "ajax/showeligibilityinfo.jsp",
                success: function(data) {
                    $('#leftSliderContent').html(data);
                },
                complete: function(data) {

                }

            });
        }
}

    function checkEligibility(id) {
        var url="ajax/geteligibility.jsp?patientInsuranceId="+id+"&sid="+Math.random();
        $("#leftSliderContent").addClass("loading");
        $.ajax({
            url: url,
            success: function(data){
                setLeftContent();
            },
            error: function() {
                alert("There was a problem processing the request");
            }
        });
        $("#leftSliderContent").removeClass("loading");
    }
</script>

<div id="leftSliderWrap">
    <div id="leftCloseId"></div>
    <div id="leftSlider">
        <div id="leftSliderContent">
            
        </div>
        <div id="leftOpenCloseWrapper"></div>
        <div id="leftOpenCloseTab"></div>
        <div id="leftOpenCloseWrap">
            <a href="#" class="leftMenuAction" id="leftMenuImage"><img src="images/arrow_right.png" alt="open" width="25px"/></a>
        </div>

    </div>
</div>

