<%@include file="../template/pagetop.jsp" %>
<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.3.2/jquery.min.js"> </script>
<script type="text/javascript">

$(document).ready(function() {

	//ACCORDION BUTTON ACTION (ON CLICK DO THE FOLLOWING)
	$('.helpAccordionButton').click(function() {

		//REMOVE THE ON CLASS FROM ALL BUTTONS
		$('.helpAccordionButton').removeClass('on');

		//NO MATTER WHAT WE CLOSE ALL OPEN SLIDES
	 	$('.helpAccordionContent').slideUp('normal');

		//IF THE NEXT SLIDE WASN'T OPEN THEN OPEN IT
		if($(this).next().is(':hidden') == true) {

			//ADD THE ON CLASS TO THE BUTTON
			$(this).addClass('on');

			//OPEN THE SLIDE
			$(this).next().slideDown('normal');
		 }

	 });


	/*** REMOVE IF MOUSEOVER IS NOT REQUIRED ***/

	//ADDS THE .OVER CLASS FROM THE STYLESHEET ON MOUSEOVER
	$('.helpAccordionButton').mouseover(function() {
		$(this).addClass('over');

	//ON MOUSEOUT REMOVE THE OVER CLASS
	}).mouseout(function() {
		$(this).removeClass('over');
	});

	/*** END REMOVE IF MOUSEOVER IS NOT REQUIRED ***/


	/********************************************************************************************************************
	CLOSES ALL S ON PAGE LOAD
	********************************************************************************************************************/
	$('.helpAccordionContent').hide();

});

$(document).ready(function() {

	//ACCORDION BUTTON ACTION (ON CLICK DO THE FOLLOWING)
	$('.subHelpAccordionButton').click(function() {

		//REMOVE THE ON CLASS FROM ALL BUTTONS
		$('.subHelpAccordionButton').removeClass('on');

		//NO MATTER WHAT WE CLOSE ALL OPEN SLIDES
	 	$('.subHelpAccordionContent').slideUp('normal');

		//IF THE NEXT SLIDE WASN'T OPEN THEN OPEN IT
		if($(this).next().is(':hidden') == true) {

			//ADD THE ON CLASS TO THE BUTTON
			$(this).addClass('on');

			//OPEN THE SLIDE
			$(this).next().slideDown('normal');
		 }

	 });


	/*** REMOVE IF MOUSEOVER IS NOT REQUIRED ***/

	//ADDS THE .OVER CLASS FROM THE STYLESHEET ON MOUSEOVER
	$('.subHelpAccordionButton').mouseover(function() {
		$(this).addClass('over');

	//ON MOUSEOUT REMOVE THE OVER CLASS
	}).mouseout(function() {
		$(this).removeClass('over');
	});

	/*** END REMOVE IF MOUSEOVER IS NOT REQUIRED ***/


	/********************************************************************************************************************
	CLOSES ALL S ON PAGE LOAD
	********************************************************************************************************************/
	$('.subHelpAccordionContent').hide();

});


</script>
<style type="text/css">
#wrapper {
    width: 800px;
    height: 300px;
    margin-left: auto;
    margin-right: auto;
    overflow: auto;
}

#wrapper h1 {
    font-size: 12px;
}

.helpAccordionButton {
    width: 90%;
    float: left;
    border-bottom: 1px solid #FFFFFF;
    cursor: pointer;
    font-family: tahoma;
    font-size: 12px;
    font-weight: bold;
}

.helpAccordionContent {
    width: 90%;
    margin-left: 15px;
    float: left;
    display: none;
    font-family: tahoma;

}

.subHelpAccordionButton {
    width: 100%;
    float: left;
    margin-left: 15px;
    cursor: pointer;
    font-family: tahoma;
    font-size: 12px;
    font-weight: bold;
}

.subHelpAccordionContent {
    width: 100%;
    margin-left: 50px;
    float: left;
    display: none;
    font-family: tahoma;

}
</style>
<%
    ResultSet lRs = io.opnRS("SELECT a.id, a.topic_name, ifnull(b.`subject`,'') `subject`, ifnull(b.help_text,'<br/><br/><br/>') help_text FROM rwcatalog.help_topics a LEFT JOIN rwcatalog.system_help b ON b.topicid=a.id WHERE parent_topic_id=0 ORDER BY sequence");
    out.print("<div align=\"center\" style=\"width: 90%; height: 95%;\">\n");
    out.print("<h1>Help Items</h1>\n");
    out.print("<div id=\"wrapper\">");
    while(lRs.next()) {
        out.print("<div align=\"left\" class=\"helpAccordionButton\">" + lRs.getString("topic_name") + "</div>\n");
        out.print("<div align=\"left\" class=\"helpAccordionContent\">\n");
        out.print("<h1>" + lRs.getString("subject") + "</h1>" + lRs.getString("help_text") + "<br/>\n" + getChildItems(io,lRs.getInt("id")) + "\n<br/><br/></div>\n");
    }
    lRs.close();
    out.print("</div>\n");
    out.print("</div>\n");
%>
<%! public String getChildItems(RWConnMgr io, int parent_id) {
        StringBuffer s = new StringBuffer();
        try {
            ResultSet lRs = io.opnRS("SELECT a.id, a.topic_name, ifnull(b.`subject`,'') `subject`, ifnull(b.help_text,'<br/><br/><br/>') help_text FROM rwcatalog.help_topics a LEFT JOIN rwcatalog.system_help b ON b.topicid=a.id WHERE parent_topic_id=" + parent_id + " ORDER BY sequence");
            while(lRs.next()) {
                if(lRs.getRow()==1) { s.append("<h1>" + lRs.getString("topic_name") + "-></h1>\n"); }
                s.append("<div align=\"left\" class=\"subHelpAccordionButton\">" + lRs.getString("Subject") + "</div>\n");
                s.append("<div align=\"left\" class=\"subHelpAccordionContent\">" + lRs.getString("help_text") + "<br/><br/></div>\n");
            }
            lRs.close();
        } catch (Exception e) {
        }
        s.append("<br/><br/>");
        return s.toString();
    }
%>

<%@include file="../template/pagebottom.jsp" %>