<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
<title>Deltares test results</title>
<link type="text/css" href="html/script/css/jquery-ui-1.7.2.custom.css" rel="stylesheet" />
<link type="text/css" href="html/script/css/masterstyles.css" rel="stylesheet" />
<link type="text/css" href="html/script/css/jquery.treeview.css" rel="stylesheet" />
<link type="text/css" href="html/script/css/FunctionCoverage.css" rel="stylesheet" />

<script type="text/javascript" src="html/script/js/jquery-1.3.2.min.js"></script>
<script type="text/javascript" src="html/script/js/jquery-ui-1.7.2.custom.min.js"></script>
<script type="text/javascript" src="html/script/js/indexfunctions.js"></script>
<script type="text/javascript" src="html/script/js/jquery.treeview.js"></script>
<script type="text/javascript">
	$(document).ready(function ()
	{
		//treeview
		$(".maintree").treeview({});

		// Accordion
		$(".accordion").accordion({ header: "h3" });
		$(".accordion").accordion('option', 'autoHeight', false);
		$(".accordion").accordion('option', 'collapsible', true);
		$(".accordion").accordion('activate',false);
		$(".accordion").accordion('option', 'clearStyle', true);

		// Tabs
		$('#tabs').tabs();

		assigntree()
	});
</script>
<style>
table {
	border-width: 1px;
	border-spacing: 0px;
	border-style: solid;
	border-color: gray;
	border-collapse: collapse;
	background-color: white;
}
table th {
	border-width: 1px;
	padding: 1px;
	border-style: solid;
	border-color: gray;
	background-color: white;
	-moz-border-radius: 0px;
}
table td {
	border-width: 1px;
	padding: 1px;
	border-style: solid;
	border-color: gray;
	background-color: white;
	-moz-border-radius: 0px;
}
#Testtree {
		width:	  19%;
		heigth:   100%;
        overflow: hidden;
		float:	  left;
}
#result_viewer {
	width:	  80%;
	height:   100%;
	float:	  right;
	overflow: auto;
}

</style>
</head>

<body>
<div id="wrapper">
	<div id="header">
		<a href="http://www.deltares.nl" target="_new"><img id="header_image" src="img/Deltares_logo.jpg"></img></a>
	</div>

	<div id="break"></div>


	<div id="content">
		<div id="maincomponents" class="accordion">
			<div id="TestOverview">
				<h3><a>Test Overview</a></h3>
				<div id="TestOverviewContent">
					<table border="1">
				    	<tr>
					      	<th></th>
					      	<th>Function Name</th>
					      	<th>Date</th>
					      	<th>Last Author</th>
					    </tr>
					    <!-- ##BEGINTESTS -->
					    <tr>
					      	<td><img src="#ICON" height="12px"</td>
					      	<td><a href="#" class="deltaresreference" deltares:mtestdescriptionref ="#DESCRIPTIONHTML" deltares:mtestcoverageref = "#COVERAGEHTML" deltares:mtestresultsref = "#RESULTHTML" detaresname="#TESTNAME">#TESTNAME</a></td>
					      	<td>#TESTDATE</td>
					      	<td><a href="http://wiki.deltares.nl/display/~#TESTAUTHOR/Home" target="_new">#TESTAUTHOR</a></td>
					    </tr>
					    <!-- ##ENDTESTS -->
					</table>
				</div>
			</div>
			<div id="TestDocumentation">
				<h3><a>Test Documentation</a></h3>
				<div id="TestDocumentationContent">
					<div id="Testtree" class="ui-widget ui-widget-content ui-corner-all">
						<ul id="browser" class="filetree treeview maintree">
							<!--##BEGINTESTS-->
							<li><a class="Mtest" deltares:mtestdescriptionref = "#DESCRIPTIONHTML" deltares:mtestcoverageref = "#COVERAGEHTML" deltares:mtestresultsref = "#RESULTHTML"><span class="folder"><img class="icon_image" src="#ICON" height="12">#TESTNAME</span></a>
								<ul>
									<!--##BEGINTESTCASE-->
									<li><a class = "MtestCase" deltares:mtestdescriptionref = "#DESCRIPTIONHTML" deltares:mtestcoverageref = "#COVERAGEHTML" deltares:mtestresultsref = "#RESULTHTML"><span class="file"><img class="icon_image" src="#ICON" height="12">#TESTCASENAME</span></a></li>
									<!--##ENDTESTCASE-->
								</ul>
							</li>
							<!--##ENDTESTS-->
						</ul>
					</div>
					<div id="result_viewer">
						<div id="result_tab">
							<div id="tabs" index = "2">
								<ul>
									<li><a href="#tabs_description">Description</a></li>
									<li><a href="#tabs_function_coverage">Function coverage</a></li>
									<li><a href="#tabs_result">Result</a></li>
								</ul>
								<div id="tabs_description">Click one of the items on the left to show a test description or testcase result.</div>
								<div id="tabs_function_coverage">Click one of the items on the left to show a test description or testcase result.</div>
								<div id="tabs_result">Click one of the items on the left to show a test description or testcase result.</div>
							</div>
						</div>
					</div>
				</div>
			</div>
			<div id="TestCoverage">
				<h3><a>Tested Functions</a></h3>
				<div id="TestCoverageContent">
					<div id="FunctionCoverageSelection">
						<ul id="functionlist">
							<!--##BEGINFUNCTIONCALLS-->
							<li><a class="FunctionCall" href="#" deltares:mtestfunctioncoverage = "#FUNCTIONHTML">#FUNCTIONFULLNAME (Coverage: #FUNCTIONCOVERAGE %)</a></li>
							<!--##ENDFUNCTIONCALLS-->
						</ul>
					</div>
					<div id="FunctionCoverageBody">
					Select one of the coverage reports on the left
					</div>
				</div>
			</div>
		</div>
	<div>
</div>


</div>
</body>
</html>

<!-- ##ICONS -->
<!-- #POSITIVE=img/small_green_check_transp.gif -->
<!-- #NEUTRAL=img/small_neutral_transp.gif -->
<!-- #NEGATIVE=img/small_red_cross_transp.gif -->
<!-- ##ENDICONS -->