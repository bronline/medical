<%--
    Document   : daysheet
    Created on : Jan 31, 2012, 7:59:39 AM
    Author     : rwandell
--%>
<%@include file="template/pagetop.jsp" %>
<style type="text/css">
    .areaBubble     { border-radius: 10px; background-color: #e0e0e0; }
    checkbox        { vertical-align: middle; }
    label           { vertical-align: top; font-size: 10px; }
    .areaLabel      { font-weight: bold;
                      color: #000000;
                      display: block;
                      text-align: center;
                      position: relative;
                      top: 60%;
                      margin-top: -10px;
                      -webkit-transform: rotate(-90deg);
                      -moz-transform: rotate(-90deg); }

    input           { font-size: 10px; height: 15px; }
    textarea        { font-size: 10px; }
    select          { font-size: 10px; height: 15px; }

    .formLabel      { width: 60px; float: left; }
    .therapyLabel   { margin-left: 5px; width: 115px; float: left; }
</style>
<%
    String options= "<option>0</option><option>1</option><option>2</option><option>3</option><option>4</option><option>5</option><option>6</option><option>7</option><option>8</option><option>9</option>";

    out.print("<div id=\"boundingBox\" style=\"width: 800px; position: relative; margin-top: 0px;\">\n");

    //Chart Area
    out.print("<div id=\"chart\" class=\"areaBubble\" style=\"width: 340px; height: 410px; float: right; margin-top: 0px; margin-left: 10px;\">\n");

    out.print("<div align=\"left\" style=\"width: 165px; float: left;\">\n");
    out.print("<div style=\"height: 10px;\">&nbsp;</div><div align=\"center\" style=\"float: left; width: 10px; height: 175px; border: 1px solid black;\"><span class=\"areaLabel\">PURPOSE</span></div>\n");
    out.print("<input type=\"checkbox\" id=\"chk001\" name=\"chk001\">&nbsp;<label for=\"chk001\">decrease pain/spasms</label>\n<br/>");
    out.print("<input type=\"checkbox\" id=\"chk002\" name=\"chk002\">&nbsp;<label for=\"chk002\">increase ROM</label>\n<br/>");
    out.print("<input type=\"checkbox\" id=\"chk003\" name=\"chk003\">&nbsp;<label for=\"chk003\">increase strength</label>\n<br/>");
    out.print("<input type=\"checkbox\" id=\"chk004\" name=\"chk004\">&nbsp;<label for=\"chk004\">increase muscle function</label>\n<br/>");
    out.print("<input type=\"checkbox\" id=\"chk005\" name=\"chk005\">&nbsp;<label for=\"chk005\">reduce referred pain</label>\n<br/>");
    out.print("<input type=\"checkbox\" id=\"chk006\" name=\"chk006\">&nbsp;<label for=\"chk006\">increase blood flow</label>\n<br/>");
    out.print("<input type=\"checkbox\" id=\"chk007\" name=\"chk007\">&nbsp;<label for=\"chk007\">reduce swelling</label>\n<br/>");
    out.print("<input type=\"checkbox\" id=\"chk008\" name=\"chk008\">&nbsp;<label for=\"chk008\">improve ADL</label>\n<br/>");
    out.print("</div>\n");

    out.print("<div align=\"left\" style=\"width: 175px; float: left;\">\n");
    out.print("<div style=\"height: 10px;\">&nbsp;</div><div align=\"center\" style=\"float: left; width: 10px; height: 175px; border: 1px solid black;\"><span class=\"areaLabel\">THERAPY</span></div>\n");
    out.print("<div style=\"position: relative; margin-top: 0px;\">\n");
    out.print("<label for=\"txt001\" class=\"therapyLabel\">Heat/Ice</label><input type=\"text\" id=\"txt001\" name=\"txt001\" size=\"2\" maxlength=\"4\"><br/>\n");
    out.print("<label for=\"txt002\" class=\"therapyLabel\">MS</label><input type=\"text\" id=\"txt002\" name=\"txt002\" size=\"2\" maxlength=\"4\"><br/>\n");
    out.print("<label for=\"txt003\" class=\"therapyLabel\">IST</label><input type=\"text\" id=\"txt003\" name=\"txt003\" size=\"2\" maxlength=\"4\"><br/>\n");
    out.print("<label for=\"txt004\" class=\"therapyLabel\">US</label><input type=\"text\" id=\"txt004\" name=\"txt004\" size=\"2\" maxlength=\"4\"><br/>\n");
    out.print("<label for=\"txt005\" class=\"therapyLabel\">MT</label><input type=\"text\" id=\"txt005\" name=\"txt005\" size=\"2\" maxlength=\"4\"><br/>\n");
    out.print("<label for=\"txt006\" class=\"therapyLabel\">Rehab</label><input type=\"text\" id=\"txt006\" name=\"txt006\" size=\"2\" maxlength=\"4\"><br/>\n");
    out.print("<label for=\"txt007\" class=\"therapyLabel\">CTA</label><input type=\"text\" id=\"txt007\" name=\"txt007\" size=\"2\" maxlength=\"4\"><br/>\n");
    out.print("</div>\n");
    out.print("</div>\n");

    out.print("<div align=\"left\" style=\"float: left; width: 100%; margin-top: 5px;\">\n");
    out.print("<div align=\"center\" style=\"float: left; width: 10px; height: 215px; border: 1px solid black;\"><span class=\"areaLabel\"></span></div>\n");
    out.print("<div style=\"position: relative; width: 100%; margin-left: 15px;\">\n");
    out.print("<label for=\"txtara001\" class=\"formLabel\">Rehab Notes:</label><textarea id=\"txtara001\" name=\"txtara001\" rows=\"6\" cols=\"39\"></textarea><br/>");
    out.print("<label for=\"txtara002\" class=\"formLabel\">Comments:</label><textarea id=\"txtara002\" name=\"txtara002\" rows=\"5\" cols=\"39\"></textarea><br/>");
    out.print("<label for=\"txt008\">Keep MAS: </label><input type=\"text\" id=\"txt008\" name=\"txt008\" size=\"13\">&nbsp;&nbsp;<label for=\"txt008\">Re-exam/ Re-X-ray </label><input type=\"text\" id=\"txt008\" name=\"txt008\" size=\"15\"><br/>");
    out.print("<label for=\"txt009\">Refer To:</label><input type=\"text\" id=\"txt009\" name=\"txt009\" size=\"62\">");
    out.print("</div>\n");
    out.print("</div>\n");

    out.print("</div>\n");

    //Complaint Area
    out.print("<div id=\"complaints\" class=\"areaBubble\" style=\"width: 450px; height: 200px; float: left; margin-top: 0px; margin-left: 0px;\">\n");

    out.print("<div style=\"height: 10px;\">&nbsp;</div><div align=\"center\" style=\"float: left; width: 10px; height: 174px; border: 1px solid black;\"><span class=\"areaLabel\">COMPLAINTS</span></div>\n");
    out.print("<div style=\"height: 20px; width: 15%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 30%;\"></span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left; \"><span style=\"position: relative; top: 15%;\">1 - 10</span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 15%;\">ROM</div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 15%;\">Spasm</span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 15%;\">Paresthesia</span></div>\n");

    out.print("<div style=\"height: 20px; width: 15%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 30%;\">HA</span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left; \"><span style=\"position: relative; top: 10%;\"><select id=\"sel001\" name=\"sel001\">" + options + "</select></span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk009\" id=\"chk009\"></span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk010\" id=\"chk010\"></span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 10%;\"><input type=\"textbox\" name=\"txt010\" id=\"txt010\" size=\"15\"></span></div>\n");

    out.print("<div style=\"height: 20px; width: 15%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 30%;\">Neck</span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left; \"><span style=\"position: relative; top: 10%;\"><select id=\"sel001\" name=\"sel001\">" + options + "</select></span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk009\" id=\"chk009\"></span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk010\" id=\"chk010\"></span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 10%;\"><input type=\"textbox\" name=\"txt010\" id=\"txt010\" size=\"15\"></span></div>\n");

    out.print("<div style=\"height: 20px; width: 15%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 30%;\">Mid Back</span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left; \"><span style=\"position: relative; top: 10%;\"><select id=\"sel001\" name=\"sel001\">" + options + "</select></span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk009\" id=\"chk009\"></span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk010\" id=\"chk010\"></span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 10%;\"><input type=\"textbox\" name=\"txt010\" id=\"txt010\" size=\"15\"></span></div>\n");

    out.print("<div style=\"height: 20px; width: 15%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 30%;\">Low Back</span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left; \"><span style=\"position: relative; top: 10%;\"><select id=\"sel001\" name=\"sel001\">" + options + "</select></span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk009\" id=\"chk009\"></span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk010\" id=\"chk010\"></span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 10%;\"><input type=\"textbox\" name=\"txt010\" id=\"txt010\" size=\"15\"></span></div>\n");

    out.print("<div style=\"height: 20px; width: 15%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 30%;\">Hip</span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left; \"><span style=\"position: relative; top: 10%;\"><select id=\"sel001\" name=\"sel001\">" + options + "</select></span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk009\" id=\"chk009\"></span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk010\" id=\"chk010\"></span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 10%;\"><input type=\"textbox\" name=\"txt010\" id=\"txt010\" size=\"15\"></span></div>\n");

    out.print("<div style=\"height: 20px; width: 15%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 30%;\">UEXT</span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left; \"><span style=\"position: relative; top: 10%;\"><select id=\"sel001\" name=\"sel001\">" + options + "</select></span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk009\" id=\"chk009\"></span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk010\" id=\"chk010\"></span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 10%;\"><input type=\"textbox\" name=\"txt010\" id=\"txt010\" size=\"15\"></span></div>\n");

    out.print("<div style=\"height: 20px; width: 15%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 30%;\">LEXT</span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left; \"><span style=\"position: relative; top: 10%;\"><select id=\"sel001\" name=\"sel001\">" + options + "</select></span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk009\" id=\"chk009\"></span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk010\" id=\"chk010\"></span></div>\n");
    out.print("<div style=\"height: 20px; width: 20%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 10%;\"><input type=\"textbox\" name=\"txt010\" id=\"txt010\" size=\"15\"></span></div>\n");

    out.print("</div>\n");

    //Manipulation Area
    out.print("<div id=\"manipulation\" class=\"areaBubble\" style=\"width: 450px; height: 200px; float: left; margin-top: 10px; margin-left: 0px;\">\n");
    out.print("<div style=\"height: 10px;\">&nbsp;</div><div align=\"center\" style=\"float: left; width: 10px; height: 175px; border: 1px solid black;\"><span class=\"areaLabel\">MANIPULATION</span></div>\n");

    out.print("<div style=\"height: 25px; width: 15%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 30%;\"></span></div>\n");
    out.print("<div style=\"height: 25px; width: 11%; border: 1px solid black; float: left; \"><span style=\"position: relative; top: 15%;\">Ant</span></div>\n");
    out.print("<div style=\"height: 25px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 15%;\">Prone</div>\n");
    out.print("<div style=\"height: 25px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 15%;\">Supine</span></div>\n");
    out.print("<div style=\"height: 25px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 15%;\">Seat</span></div>\n");
    out.print("<div style=\"height: 25px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 15%;\">Drop</span></div>\n");
    out.print("<div style=\"height: 25px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 15%;\">Act</span></div>\n");
    out.print("<div style=\"height: 25px; width: 12%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 15%;\">Side</span></div>\n");

    out.print("<div style=\"height: 22px; width: 15%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 30%;\">C</span></div>\n");
    out.print("<div style=\"height: 22px; width: 11%; border: 1px solid black; float: left; \"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk011\"></span></div>\n");
    out.print("<div style=\"height: 22px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk012\"></div>\n");
    out.print("<div style=\"height: 22px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk013\"></span></div>\n");
    out.print("<div style=\"height: 22px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk014\"></span></div>\n");
    out.print("<div style=\"height: 22px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk015\"></span></div>\n");
    out.print("<div style=\"height: 22px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk016\"></span></div>\n");
    out.print("<div style=\"height: 22px; width: 12%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk017\"></span></div>\n");

    out.print("<div style=\"height: 22px; width: 15%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 30%;\">TH</span></div>\n");
    out.print("<div style=\"height: 22px; width: 11%; border: 1px solid black; float: left; \"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk011\"></span></div>\n");
    out.print("<div style=\"height: 22px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk012\"></div>\n");
    out.print("<div style=\"height: 22px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk013\"></span></div>\n");
    out.print("<div style=\"height: 22px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk014\"></span></div>\n");
    out.print("<div style=\"height: 22px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk015\"></span></div>\n");
    out.print("<div style=\"height: 22px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk016\"></span></div>\n");
    out.print("<div style=\"height: 22px; width: 12%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk017\"></span></div>\n");

    out.print("<div style=\"height: 22px; width: 15%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 30%;\">L</span></div>\n");
    out.print("<div style=\"height: 22px; width: 11%; border: 1px solid black; float: left; \"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk011\"></span></div>\n");
    out.print("<div style=\"height: 22px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk012\"></div>\n");
    out.print("<div style=\"height: 22px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk013\"></span></div>\n");
    out.print("<div style=\"height: 22px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk014\"></span></div>\n");
    out.print("<div style=\"height: 22px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk015\"></span></div>\n");
    out.print("<div style=\"height: 22px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk016\"></span></div>\n");
    out.print("<div style=\"height: 22px; width: 12%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk017\"></span></div>\n");

    out.print("<div style=\"height: 24px; width: 15%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 30%;\">S</span></div>\n");
    out.print("<div style=\"height: 24px; width: 11%; border: 1px solid black; float: left; \"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk011\"></span></div>\n");
    out.print("<div style=\"height: 24px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk012\"></div>\n");
    out.print("<div style=\"height: 24px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk013\"></span></div>\n");
    out.print("<div style=\"height: 24px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk014\"></span></div>\n");
    out.print("<div style=\"height: 24px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk015\"></span></div>\n");
    out.print("<div style=\"height: 24px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk016\"></span></div>\n");
    out.print("<div style=\"height: 24px; width: 12%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk017\"></span></div>\n");

    out.print("<div style=\"height: 24px; width: 15%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 30%;\">P</span></div>\n");
    out.print("<div style=\"height: 24px; width: 11%; border: 1px solid black; float: left; \"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk011\"></span></div>\n");
    out.print("<div style=\"height: 24px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk012\"></div>\n");
    out.print("<div style=\"height: 24px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk013\"></span></div>\n");
    out.print("<div style=\"height: 24px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk014\"></span></div>\n");
    out.print("<div style=\"height: 24px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk015\"></span></div>\n");
    out.print("<div style=\"height: 24px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk016\"></span></div>\n");
    out.print("<div style=\"height: 24px; width: 12%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk017\"></span></div>\n");

    out.print("<div style=\"height: 24px; width: 15%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 30%;\">EXT</span></div>\n");
    out.print("<div style=\"height: 24px; width: 11%; border: 1px solid black; float: left; \"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk011\"></span></div>\n");
    out.print("<div style=\"height: 24px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk012\"></div>\n");
    out.print("<div style=\"height: 24px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk013\"></span></div>\n");
    out.print("<div style=\"height: 24px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk014\"></span></div>\n");
    out.print("<div style=\"height: 24px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk015\"></span></div>\n");
    out.print("<div style=\"height: 24px; width: 11%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk016\"></span></div>\n");
    out.print("<div style=\"height: 24px; width: 12%; border: 1px solid black; float: left;\"><span style=\"position: relative; top: 0%;\"><input type=\"checkbox\" name=\"chk011\" id=\"chk017\"></span></div>\n");

    out.print("</div>\n");
    out.print("</div>\n");

%>
<%@include file="template/pagebottom.jsp" %>