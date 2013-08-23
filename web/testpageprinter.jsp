<%@ page import="medical.print.*, tools.*, tools.utils.*, java.sql.*, java.util.*, java.math.* " %>
<%
    String[][] stringArray=new String[2][4];
    
    stringArray[0][0]="First String";
    stringArray[0][1]="10";
    stringArray[0][2]="20";
    stringArray[0][3]="20";

    stringArray[1][0]="Second String";
    stringArray[1][1]="100";
    stringArray[1][2]="200";
    stringArray[1][3]="35";
    
    PagePrinter pp = new PagePrinter();
    pp.setStringArray(stringArray);
    pp.print();

%>