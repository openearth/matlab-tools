<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
<title>Deltares test results</title>
<link type="text/css" href="script/css/custom-theme/jquery-ui-1.7.2.custom.css" rel="stylesheet" />
<script type="text/javascript" src="script/js/jquery-1.3.2.min.js"></script>
<script type="text/javascript" src="script/js/jquery-ui-1.7.2.custom.min.js"></script>
<script type="text/javascript">
	$(function(){

		// Accordion
		$("#accordion").accordion({ header: "h3" });

		// Tabs
		$('#tabs').tabs();
	});

	function loaddescription(event)
		{
			$("#result_description").load(event.data.descriptionhtml);
			$("#result_tab").fadeOut(500);
			$("#result_description").hide();
			$("#result_description").fadeIn(500);
		}

	function loadtestcase(event)
		{
			$("#tabs_description").load(event.data.descriptionhtml);
			$("#tabs_result").load(event.data.resulthtml);
			$("#result_description").fadeOut(500);
			$("#result_tab").hide();
			$("#result_tab").fadeIn(500);
		}

	$(document).ready(function ()
	{
		$("[class='MtestDescription']").each(function(i) {
			$(this).bind('click', {index:i, descriptionhtml:$(this).attr('deltares:mtestdescriptionref')}, loaddescription);
			});
		$("[class='MtestCase']").each(function(i) {
			$(this).bind('click', {index:i, descriptionhtml:$(this).attr('deltares:mtestdescriptionref'), resulthtml:$(this).attr('deltares:mtestresultsref')}, loadtestcase);
			});
		$("#result_tab").hide();
		$("#result_description").show();
	});

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

#tree_panel {
	color           : black;
	background-color: #c2d6e1;
	font-family     : salse,arial,sans-serif;
	font-size       : 12px;
	border-style    : none;
	border-width	: thin;
	position	: absolute;
	top		: 20px;
	left		: 20px;
	width		: 300px;
	height 		: 100%;
}

#result_viewer {
	color           : black;
	background-color: white;
	border-style	: none;
	font-family     : salse,arial,sans-serif;
	font-size       : 12px;
	border-width	: thin;
	position	: absolute;
	top		: 20px;
	left		: 340px;
	height		: 900px;
	width		: 800px;
}

#result_tab {
	border-style	: none;
	background-color: white;
	position	: absolute;
	top		: 0;
	left		: 0;
	width		: 800px;
	heigth		: 100%;
}

#tabs_result {
	max-height	: 800px;
	overflow	: auto;
}

#tabs_description {
	max-height	: 800px;
	overflow	: auto;
}

#result_description {
	border		: 1px solid #dddddd;
	background	: #ffffff url(script\css/custom-theme/images/ui-bg_flat_75_ffffff_40x100.png) 50% 50% repeat-x;
	color		: #444444;
	position	: absolute;
	top		: 0;
	left		: 0;
	width		: 800px;
	heigth		: 100%;
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
	<div id="tree_panel">
		<div id="accordion" deltares:mtesttype="testtree">
		<!--##BEGINTESTS-->
			<div>
				<h3><a href="#" class="MtestDescription" deltares:mtestdescriptionref = "#TESTHTML"><img class="icon_image" src="#ICON" height="12"> Test #TESTNUMBER (#TESTNAME)</a></h3>
				<div>
				</div>
			</div>
		<!--##ENDTESTS-->
		</div>
	</div>

	<div id="result_viewer">
		<div id="result_tab">
			<div id="tabs">
				<ul>
					<li><a href="#tabs_description">Description</a></li>
					<li><a href="#tabs_result">Result</a></li>
				</ul>
				<div id="tabs_description">This is the place for a description of the testcase</div>
				<div id="tabs_result">This is the place for the results.</div>
			</div>
		</div>
		<div id="result_description" class="ui-widget-content ui-corner-all">
			<h1>Test results</h1>
			Click one of the items on the left to show a test description or testcase result.
		</div>
	</div>

</div>
</body>
</html>

<!-- ##ICONS -->
<!-- #POSITIVE=img/small_green_check_transp.gif -->
<!-- #NEUTRAL=img/small_neutral_transp.gif -->
<!-- #NEGATIVE=img/small_red_cross_transp.gif -->
<!-- ##ENDICONS -->