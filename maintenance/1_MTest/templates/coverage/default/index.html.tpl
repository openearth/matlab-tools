<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
<title>Deltares test results</title>
<link type="text/css" href="script/css/custom-theme/jquery-ui-1.7.2.custom.css" rel="stylesheet" />
<style type="text/css">@import "script/css/tablesorter.css";</style>
<script type="text/javascript" src="script/js/jquery-1.3.2.min.js"></script>
<script type="text/javascript" src="script/js/jquery.tablesorter.min.js"></script>
<script type="text/javascript" src="script/js/jquery-ui-1.7.2.custom.min.js"></script>
<script type="text/javascript">
	$(document).ready(function ()
	{
		// Prepare table
		$("table").tablesorter(); 
		
		$("#StartMessage").show();
		
		$(".FunctionCoverage").hide();
		
		$(".mtestcoverageref").each(function(i) {
				$(this).bind('click', {index:i, coveragelinkid:$(this).attr('mtest:testnameid')}, showcoverage);
			});
	});
	
	function showcoverage(event)
	{
	// hide all divs
	$("#StartMessage").hide();
	$(".FunctionCoverage").hide();
	
	// show coverage for selected function
	$('[mtestcoverageid = ' + event.data.coveragelinkid + ']').show();
	}

</script>
<style>
body {
  	background	: white;
  	color		: black;
  	font-family	: salse,arial,sans-serif;
  	margin		: 0;
  	padding		: 1ex;
  	font-size	: 12px;
}

h1 {
	font-family	: arial;
	background	: transparent;
	color		: #008FC5;
	font-size	: 24px;
	text-align	: center;
}

#header {
	color           : white;
	font-family     : salse,arial,sans-serif;
	font-size       : 12px;
	margin		: 0 auto;
	width		: 202px;
}

#header_image {
	color           : white;
	background-color: white;
	border-style    : none;
	height		: 100px;
	margin		: 0 auto;
}

#content {
	border-style	: none;
	position	: relative;
	margin		: 0 auto;
	top		: 20px;
}

#coveragetable {
	font-family     : salse,arial,sans-serif;
	font-size       : 12px;
	position	: absolute;
	top		: 20px;
	left		: 20px;
	width		: 500px;
}

#coverage_viewer {
	color           : black;
	background-color: white;
	border-style	: none;
	font-family     : salse,arial,sans-serif;
	font-size       : 12px;
	border-width	: thin;
	position	: absolute;
	top		: 20px;
	left		: 540px;
	height		: 900px;
	width		: 900px;
}

.icon_image {
	border-style	: none;
}
</style>
</head>

<body>

<div id="header">
	<a href="http://www.deltares.nl" target="_new">
		<img id="header_image" src="img/Deltares_logo.jpg"</img>
	</a>
</div>

<div id="content">
	<div id="coveragetable" deltares:mtesttype="testtree">
		<table id="myTable" class="tablesorter"> 
			<thead> 
				<tr> 
				    <th>Function Name</th> 
				    <th>Coverage (%)</th> 
				</tr> 
			</thead> 
			<tfoot> 
				<tr> 
				    <th>Function Name</th> 
				    <th>Coverage (%)</th> 
				</tr> 
			</tfoot> 		
			<tbody> 
			<!--##BEGINFUNCTIONS-->
				<tr> 
				    <td><a class="mtestcoverageref" href="#" mtest:testnameid="#FUNCTIONNAME">#FUNCTIONNAME</a></td> 
				    <td>#COVERAGEPERCENTAGE</td> 
				</tr> 
			<!--##ENDFUNCTIONS-->
			</tbody> 
		</table> 
	</div>

	<div id="coverage_viewer">
		<div id="StartMessage" class="ui-widget-content ui-corner-all">
			<h1>Coverage overview</h1>
			Click one of the functions on the left to show its coverage overview.
		</div>
		<!--##BEGINFUNCTIONS-->
		<div mtestcoverageid="#FUNCTIONNAME" class="ui-widget-content ui-corner-all FunctionCoverage">
			<h1>Coverage overview for: #FUNCTIONNAME</h1>
			#COVERAGEHTML
		</div>
		<!--##ENDFUNCTIONS-->
	</div>
</div>
</body>
</html>