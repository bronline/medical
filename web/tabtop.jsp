<style>
.highlightOn   { color: #ffffff; background-image: url('/medicaldocs/tab_background.gif'); }
.highlightOff  { color: #000000; background-image: url('/medicaldocs/tab_background_w.gif'); }
</style>
<script type="text/javascript">
    function highlightOn(what) {
        what.style.backgroundImage="url('/medicaldocs/tab_background.gif')";
        what.style.color="#ffffff";
    }
    
    function highlightOff(what) {
        what.style.backgroundImage="url('/medicaldocs/tab_background_w.gif')";
        what.style.color="#000000";
    }
</script>
<%
        boolean showTabs = false;
        int tabMenuId = 0;
        StringBuffer pageOut = new StringBuffer();
        RWHtmlTable ttHtmTb = new RWHtmlTable("800", "0");
        String srchString="*EMPTY";
        int numberOfTabs = 0;
//        boolean redirect=false;

        String srchPatientId="";
        String jsp = self.substring(self.lastIndexOf("/")+1);

        if(io != null && io.getConnection() != null) {
            ResultSet tabRs = io.opnRS("select * from rwcatalog.tabmenu where application = 'medical' and taburl = '" + jsp + "'");
            

        //    session.setAttribute("srchString", srchString);
            if (tabRs.next()) {tabMenuId=tabRs.getInt("id"); }
            TabMenu tabMenu = new TabMenu(io, tabMenuId);
            tabMenu.bodyWidth="900";

            if (request.getParameterNames().hasMoreElements()) {
                String activeOnly = "true";
                if (request.getParameter("activeOnly")!=null) {
                    activeOnly=request.getParameter("activeOnly");
                }
                session.setAttribute("activeOnly", activeOnly);
                if (request.getParameter("srchString")!=null) {
                    srchString=request.getParameter("srchString");
                    session.setAttribute("srchString", srchString);
                    redirect=true;
                }
                if (request.getParameter("srchPatientId")!=null) {
                    srchPatientId=request.getParameter("srchPatientId");
                    patient.setId(srchPatientId);
                    session.setAttribute("patient", patient);
                    session.setAttribute("srchString", srchString);
                    redirect=true;
                }
                if (tabMenu.getSelfRedirect()) {
                    redirect=true;
                }
                if (tabMenu.next() && !tabMenu.getSelfRedirect() && redirect) {
//                    response.sendRedirect(self);
                }
            }
            tabMenu.beforeFirst();
            if (!redirect) {

                if (tabMenu.getShowSearch()) {
                    srchString = (String)session.getAttribute("srchString");
                    if (srchString==null) { srchString=""; }
                    boolean activeOnly = true;
                    if (session.getAttribute("activeOnly")!=null) {
                        activeOnly=Boolean.parseBoolean((String)session.getAttribute("activeOnly"));
                    }
                    pageOut.append(patient.getSearchBubble(self, activeOnly));
                    pageOut.append("<br>");
                    pageOut.append(patient.getSearchResults(srchString, self + "?srchString=*EMPTY", "srchPatientId", activeOnly));
                    pageOut.append("</TD><TD>");
                }

                if (tabMenu.next()) {
                    showTabs=true;
                    pageOut.append(tabMenu.getTabTopHtml());
                    out.print(pageOut.toString());
                }
            }
            numberOfTabs=tabMenu.getNumTabs();
            tabRs.close();

        }
%>