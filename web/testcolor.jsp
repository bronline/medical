<%@ page import="tools.*" %>

<script language="JavaScript" src="js/colorpicker.js"></script>
<script language="JavaScript" src="js/datechecker.js"></script>
<script language="JavaScript" src="js/dFilter.js"></script>
<script language="JavaScript" src="js/currency.js"></script>
<script language="JavaScript" src="js/checkemailaddress.js"></script>


<body onLoad="loadMask()">

<form name=frmInput>

<!-- flooble Color Picker end -->
<%
    RWHtmlForm frm = new RWHtmlForm();
    out.print(frm.colorPicker("#030089", "thing6", ""));
    out.print(frm.date("", "date", "") + "<br>");
    out.print(frm.mask("181561751", "mask", "###-##-####") + "<br>");
    out.print(frm.phoneNumber("5707481048", "phone") + "<br>");
    out.print(frm.zipCode("177458255", "zip") + "<br>");
    out.print(frm.ssn("177566216", "ssn"));
%>

<input type=text name=emailaddress onBlur="return emailCheck(this)">
<br>
<form name=currencyform>
Enter a number then click the button: <input type=text name=input size=10 value="1000434.23">
<input type=button value="Convert" onclick="this.form.input.value=formatCurrency(this.form.input.value);">
<br><br>
or enter a number and click another field: <input type=text name=input2 size=10 value="0.00" onBlur="this.value=formatCurrency(this.value);">

</form>
<table width=200>
    
    <tr>
        <td><fieldset style="border: 2px solid #666; padding: 15px;"><legend><b>Top</b></legend>
        test<br>
        this<br>
        out<br>
        </fieldset>
        </td>
    </tr>
    <tr>
        <td><fieldset style="border: 2px solid #666; padding: 15px;"><legend><b>Bottom</b></legend>
        Still<br>
        another<br>
        test<br>
        </fieldset>
        </td>
    </tr>

</table>

</body>