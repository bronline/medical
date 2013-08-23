<%@include file="globalvariables.jsp" %>
<%@ page import="tools.print.*, tools.*, tools.utils.*, java.sql.*, java.util.*, java.math.* " %>

<%
    int i=0;

    ResultSet cms1500Doc = io.opnRS("select * from rwcatalog.sampledoc where document='cms1500'");
    cms1500Doc.last();
    String[][] stringArray=new String[cms1500Doc.getRow()][4];
    cms1500Doc.beforeFirst();
    while (cms1500Doc.next()) { 
        
        stringArray[i][0]=cms1500Doc.getString("sampletext");
        stringArray[i][1]=cms1500Doc.getString("xcoord");
        stringArray[i][2]=cms1500Doc.getString("ycoord");
        stringArray[i][3]=cms1500Doc.getString("fontsize");
        i++;
    }
    
    PagePrinter pp = new PagePrinter();

    pp.setStringArray(stringArray);
    pp.print();

%>