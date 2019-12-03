<%@Page Language="C#" AutoEventWireup="true"%>
<%
    var localNcFilePath = Request["ncFilePath"];
    var localNcVariableName = Request["ncVariableName"];
    var startTime = Request["startTime"];
    var stopTime = Request["stopTime"];
%>
<html>
<head>

	<link href="stylesheets/style.css" rel="stylesheet" type="text/css">
	<script type="text/javascript" src="../js/soapclient.js"></Script>
	<script type="text/javascript">
		var pm = null;

		// Call the MatLab SOAP interface, url: SOAP address, method: name
		function CallMatLabSoap(url, method)
		{
			var ncf = <%=localNcFilePath%>;
			var ncv = <%=localNcVariableName%>;
			var sta = <%=startTime%>;
			var sto = <%=stopTime%>;
			try
			{
				if ((ncf != null) && (ncv != null))
				{
					var pl = new SOAPClientParameters();
					pl.add("ncFilePath", ncf);
					pl.add("ncVariableName", ncv);
					pl.add("startTime", sta);
					pl.add("stopTime", sto);
					SOAPClient.invoke(url, method, pl, true, CallMatLabSoapCallBack);
				}
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
				// document.getElementById("inter_image").src = "http://dtvirt13/bwnmatlab/" + result;
				document.getElementById("plotarea").innerHTML ="<a href='http://dtvirt13/bwnmatlab/" + result + "' TARGET='_blank'><img src='http://dtvirt13/bwnmatlab/" + result + "' width=200 height=120></a>";
				// window.location = "http://dtvirt13/bwnmatlab/" + result
			}
		}


	</script>
</head>

<body onload="CallMatLabSoap('http://dtvirt13/BwnMatLab/BwnFunctions.asmx', 'PlotTimeSeries')" id='body'>

<div id="plotarea">
<img id="inter_image" src="../../images/wait.gif" width="200">
</div>

</body>

</html>
