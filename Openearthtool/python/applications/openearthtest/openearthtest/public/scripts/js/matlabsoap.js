// Call the MatLab SOAP interface, url: SOAP address, method: name
function CallMatLabSoap(url, method, inputs)
{

	try
	{
		var pl = new SOAPClientParameters();

		// get inputs
		inputs2 = inputs.split("&");

		// Add variables from document
		pl.add("ncFilePath", inputs2[0]);
		pl.add("ncVariableName", inputs2[1]);
		pl.add("centreLatitude", pm.cent.lat.toDeg());
		pl.add("centreLongitude", pm.cent.lon.toDeg());
		pl.add("vertexLatitude", pm.rad.lat.toDeg());
		pl.add("vertexLongitude", pm.rad.lon.toDeg());
		
		// create balloon with wait-message
		var balloon = ge.createHtmlDivBalloon('');
		balloon.setFeature(pm.cent.placemark);
		var div = document.createElement('DIV');
		div.innerHTML = "<img src='http://dtvirt13/bwn/optie_compiled/images/wait.gif'>";
		balloon.setContentDiv(div);
		ge.setBalloon(balloon);

		
		SOAPClient.invoke(url, method, pl, true, CallMatLabSoapCallBack);
	}
	catch(exception)
	{
		alert(exception);
	}
}

// CallBack routine of the SOAP function
function CallMatLabSoapCallBack(result)
{
	if(result != null)
	{
	  // var balloon = ge.createHtmlStringBalloon('');
	  // balloon.setFeature(pm.cent.placemark); // optional
	  // balloon.setContentString("<img src='http://dtvirt13/bwnmatlab/" + result + "'>");

	  var balloon = ge.createHtmlDivBalloon('');
	  balloon.setFeature(pm.cent.placemark); // optional
	  var div = document.createElement('DIV');
	  div.innerHTML = "<a href='http://dtvirt13/bwnmatlab/" + result + "' TARGET='_blank'><img src='http://dtvirt13/bwnmatlab/" + result + "' width=200 height=200></a>";
	  balloon.setContentDiv(div);

	  ge.setBalloon(balloon);
	}
}

	