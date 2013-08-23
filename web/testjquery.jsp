<%-- 
    Document   : testjquery
    Created on : Feb 15, 2011, 3:55:39 PM
    Author     : rwandell
--%>

 <html>
 <head>
 <script type="text/javascript" src="js/jQuery.js"></script>
 <script type="text/javascript">
$.ajax({
  url: "test.html",
  context: document.body,
  success: function(){
    $(this).addClass("done");
  }
});
 </script>
 </head>
 <body>
   <!-- we will add our HTML content here -->
 </body>
 </html>

