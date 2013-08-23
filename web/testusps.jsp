<script type="text/javascript" src="js/jQuery.js"></script>

<script type="text/javascript">
//USPS server url
var url = "http://testing.shippingapis.com/ShippingAPITest.dll";

//USPS user id
var userId = "";

//Caller address1 field name
var address1FieldName = "";

//Caller address2 field name
var address2FieldName = "";

//Caller state field name
var stateFieldName = "";

//Caller city field name
var cityFieldName = "";

//Caller zipcode field name
var zipCodeFieldName = "";

var testUrl="?API=Verify&XML=<AddressValidateRequest%20USERID=\"617BRONL1376\"><Address ID=\"0\"><Address1></Address1><Address2>6406 Ivy Lane</Address2><City>Greenbelt</City><State>MD</State><Zip5></Zip5><Zip4></Zip4></Address></AddressValidateRequest>";

//Used to get city and state based on zipcode

function GetCityStateInfo() {
    var zip5 = $("#" + zipCodeFieldName).attr("value");
    var array = $("#" + zipCodeFieldName).attr("value").split("-");
    if (array.length > 1) {
        zip5 = array[0];
    }

    $.get(
        url,
        { API: "CityStateLookup", XML: "<CityStateLookupRequest USERID=\"" + userId + "\"><ZipCode ID= \"0\"><Zip5>" + zip5 + "</Zip5></ZipCode></CityStateLookupRequest>" },
        function(data) {
            var xml = $.xmlDOM(data);
            alert(xml.toString());
            $(xml).find("ZipCode").each(
                function() {
                    var zipCode = $(this);
                    if ((zipCode.find("City").text()) != "") {
                        $("#" + cityFieldName).attr("value", (zipCode.find("City").text()));
                        var i;
                        $("#" + stateFieldName + " option").each(
                            function() {
                                var option = this;
                                if (option.text == zipCode.find("State").text()) {
                                    $("#" + stateFieldName).attr("selectedIndex", option.index);
                                    return false;
                                }
                            }
                        );
                    }
                }
            );
        }
    )
}

//function GetCityStateInfo() {
//    var zip5 = $("#" + zipCodeFieldName).attr("value");
//    var array = $("#" + zipCodeFieldName).attr("value").split("-");
//    if (array.length > 1) {
//        zip5 = array[0];
//    }

//    $.ajax({
//        url: url,
//        API: "CityStateLookup",
//        XML: "<CityStateLookupRequest USERID=\"" + userId + "\"><ZipCode ID= \"0\"><Zip5>" + zip5 + "</Zip5></ZipCode></CityStateLookupRequest>" ,
//        success: function(xml) {
//            alert(xml);
//        },
//        error: function(xml) {
//            alert(xml);
//        }

//    });

//}

//Used to get zip code info based on the full address

function GetZipCodeInfo() {
/*
    $.get(
        url,
        { API: "ZipCodeLookup", XML: "<ZipCodeLookupRequest USERID=\"" + userId + "\"><Address ID= \"0\"><Address1>" + $("#" + address1FieldName).attr("value") + "</Address1><Address2>" + $("#" + address2FieldName).attr("value") + "</Address2><City>" + $("#" + cityFieldName).attr("value") + "</City><State>" + $("#" + stateFieldName + " option:selected").text() + "</State></Address></ZipCodeLookupRequest>" },
        function(data) {
            var xml = $.xmlDOM(data);
            $(xml).find("Address").each(function() {
            var address = $(this);
            if ((address.find("Zip5").text()) != "") {
                $("#" + zipCodeFieldName).attr("value", (address.find("Zip5").text()) + "-" + (address.find("Zip4").text()));
            }
            });
        }
    )
*/
    var fullURL=url+testUrl;
    alert(fullURL);

    var xmlDocument = [create xml document];

    var xmlRequest=$.ajax({
       url: fullURL,
        processData: false,
        data: xmlDocument
//       API: "ZipCodeLookup",
//       XML: "<ZipCodeLookupRequest USERID=\"" + userId + "\"><Address ID= \"0\"><Address1>" + $("#" + address1FieldName).attr("value") + "</Address1><Address2>" + $("#" + address2FieldName).attr("value") + "</Address2><City>" + $("#" + cityFieldName).attr("value") + "</City><State>" + $("#" + stateFieldName + " option:selected").text() + "</State></Address></ZipCodeLookupRequest>" ,

    });

    xmlRequest.done(handleResponse);
    alert(xmlDocument);
}



//Used to set the address url of USPS server based on mode

function setUrlMode(mode) {
    if (mode) {
        url = "http://testing.shippingapis.com/ShippingAPITest.dll";
    } else {
        url = "http://production.shippingapis.com/ShippingAPI.dll";
    }
}

$(document).ready(function() {
    setUrlMode(true);
    userId = "617BRONL1376";
    address1FieldName = "address1";
    address2FieldName = "address2";
    cityFieldName = "city";
    stateFieldName = "state";
    zipCodeFieldName = "zipcode";
    $("#zipcode").change(function() { GetCityStateInfo(); } );

    $("#address1").change(function() { GetZipCodeInfo(); });

    $("#address2").change(function() { GetZipCodeInfo(); });

    $("#city").change(function() { GetZipCodeInfo(); });

    $("#state").change(function() { GetZipCodeInfo(); });

});



</script>


address1<br />

<input type ="text" id="address1" /><br />

address2<br />

<input type ="text" id="address2" value="6406 Ivy Lane" /><br />

city<br />

<input type ="text" id="city" value="Greenbelt" /><br />

state<br />

<input type ="text" id="state2" value="" /><br />City<br />

<select id="state" name="D1">

<option value="1" selected="selected">VA</option>

<option value="2">MD</option>

<option value="3">dc</option>

</select><br />

zipcode<br />

<input type ="text" id="zipcode" value="" />
<br/>
<input type="button" value="check" onclick="GetZipCodeInfo()">