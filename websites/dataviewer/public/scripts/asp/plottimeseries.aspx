<%@Page Language="C#" AutoEventWireup="true"%>
<%
    var localNcFilePath = Request["ncFilePath"];
    var localNcVariableName = Request["ncVariableName"];
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
			try
			{
				if ((ncf != null) && (ncv != null))
				{
					var pl = new SOAPClientParameters();
					pl.add("ncFilePath", ncf);
					pl.add("ncVariableName", ncv);
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
				document.getElementById("inter_image").src = "http://dtvirt13/bwnmatlab/" + result;
			}
		}


	</script>
</head>

<body onload="CallMatLabSoap('http://dtvirt13/BwnMatLab/BwnFunctions.asmx', 'PlotTimeSeries')" id='body'>

<img id="inter_image" src="../../images/wait.gif">
</body>

</html>
