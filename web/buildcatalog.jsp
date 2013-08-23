<%@ include file="globalvariables.jsp" %>
<%@ page import="tools.catalog.*" %>
<%
   String tableName = request.getParameter("tableName");

   Load ld = new Load();

   ld.setCatalogHost("localhost");
   ld.setCatalogDbName("rwcatalog");
   ld.setCatalogName("catalog");
   ld.setCatalogUser("rwtools");
   ld.setCatalogPassword("rwtools");
   ld.setCatalogDbType(io.MYSQL);

   ld.setHostName("localhost");
   ld.setDatabaseName(databaseName);
   ld.setTableName(tableName);
   ld.setUserName("rwtools");
   ld.setPassword("rwtools");
   ld.setDatabaseDbType(io.MYSQL);

   ld.generateCatalog();
%>