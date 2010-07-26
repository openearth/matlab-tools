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

		$(".FunctionCoverage").each(function(i) {
			$(this).css("display","none");
			$(this).css("padding-top","11px");
			$(this).css("padding-bottom","11px");
			$(this).addClass("ui-collapsible-content ui-helper-reset ui-widget-content ui-corner-bottom ui-collapsible-content-active");
		});

		$(".mtestcoverageref").each(function(i) {
			$(this).bind('click', {index:i, coveragelinkid:$(this).attr('mtest:testnameid')}, showcoverage);
		});
	});
	
	function showcoverage(event)
	{
		var d = $('[mtestcoverageid = ' + event.data.coveragelinkid + ']');

		if ($(d).css('display')=="block")
	    {
	    	// content is visible --> so hide it
		    $(d).css('display','none');
		}
		else
		{
		    // Show the content
		    $(d).css('display','block');
		}
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
	right		: 20px;
}

</style>
</head>

<body>
<div id="content">
	<div id="coveragetable" deltares:mtesttype="testtree">
		<table id="myTable" class="tablesorter"> 
			<thead> 
				<tr> 
				    <th>Coverage (%)</th> 
				    <th>Function Name</th> 
				    <th>Coverage Overview</th>
				</tr> 
			</thead> 
			<tfoot> 
				<tr> 
				    <th>Coverage (%)</th> 
				    <th>Function Name</th> 
				    <th>Coverage Overview</th>
				</tr> 
			</tfoot> 		
			<tbody> 
			<!--##BEGINFUNCTIONS-->
				<tr> 
				    <td>#COVERAGEPERCENTAGE</td> 
				    <td><a class="mtestcoverageref" href="##FUNCTIONNAME" mtest:testnameid="#FUNCTIONNAME">#FUNCTIONNAME</a></td> 
				    <td>
				    	<a name="#FUNCTIONNAME">
				    	<div mtestcoverageid="#FUNCTIONNAME" class="ui-widget-content ui-corner-all FunctionCoverage">
				    	   <h1>Coverage overview for: #FUNCTIONNAME</h1>
				    	   #COVERAGEHTML
					</div>
				    </td>
				</tr> 
			<!--##ENDFUNCTIONS-->
			</tbody> 
		</table> 
	</div>
</div>
</body>
</html>