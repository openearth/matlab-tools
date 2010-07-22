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
			<div id="TestCoverage">
				<h3><a>Tested Functions</a></h3>
				<div id="TestCoverageContent">
					<div id="FunctionCoverageSelection">
						<table>
							<tr>
								<th> Function Name </th>
								<th> Coverage (%) </th>
							</tr>
							<!--##BEGINFUNCTIONCALLS-->
							<tr>
								<td class="td-function"><a class="FunctionCall" href="#" deltares:mtestfunctioncoverage = "#FUNCTIONHTML">#FUNCTIONFULLNAME</a></td>
								<td class="td-function">#FUNCTIONCOVERAGE %</td>
							</tr>
							<!--##ENDFUNCTIONCALLS-->
						</table>
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