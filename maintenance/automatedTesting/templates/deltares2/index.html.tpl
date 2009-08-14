<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
<title>Deltares test results</title>
<link type="text/css" href="script/css/custom-theme/jquery-ui-1.7.2.custom.css" rel="stylesheet" />
<link type="text/css" href="masterstyles.css" rel="stylesheet" />
<script type="text/javascript" src="script/js/jquery-1.3.2.min.js"></script>
<script type="text/javascript" src="script/js/jquery-ui-1.7.2.custom.min.js"></script>
<script type="text/javascript" src="script/indexfunctions.js"></script>
<script type="text/javascript">

	function showhideoverview () {

	}

	$(document).ready(function ()
	{
		//draggable main window
		$("#draggable").draggable();

		// Accordion
		$("#accordion").accordion({ header: "h3" });

		// Tabs
		$('#tabs').tabs();

		assigntree()

		//Set position of draggable main window
		var position = $("#content").position();
		$("#draggable").css("top",15);
		$("#draggable").css("left",position.left);

		//Set position of overlay and hide
		$("#overviewoverlay").css("left",$("#content").position().left);
		$("#overviewoverlay").hide();

		//Set overview container and shadow
		$("#overviewcontainer").css("left",$("#content").position().left+60);
		$("#overviewcontainer").hide();
		$("#shadow").css("left",$("#content").position().left+60);
		$("#shadow").hide();

		$("#switchoverview").click(function () {
		    $("p").toggle();
		  });


	});
</script>
</head>

<body>
<div id="wrapper">
	<div id="header">
		<a href="http://www.deltares.nl" target="_new"><img id="header_image" src="img/Deltares_logo.jpg"></img></a>
	</div>

	<div id="break"></div>


	<div id="content">
		<div id="tree_panel">
			<div id="accordion" deltares:mtesttype="testtree">
			<!--##BEGINTESTS-->
				<div>
					<h3><a href="#" class="MtestDescription" deltares:mtestdescriptionref = "#TESTHTML"><img class="icon_image" src="#ICON" height="12"> #TESTNAME</a></h3>
					<div>
						<!--##BEGINTESTCASE-->
						<div>
						<img class="icon_image" src="#ICON" height="12">
							<a href="#" class = "MtestCase" deltares:mtestdescriptionref = "#DESCRIPTIONHTML" deltares:mtestresultsref = "#RESULTHTML">
								 #TESTCASENAME
							</a>
						</div>
						<!--##ENDTESTCASE-->
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
		<div id="overlaycontainer">
			<div class="ui-overlay">
				<div id="overviewoverlay" class="ui-widget-overlay ui-corner-all"></div>
				<div id="shadow" class="ui-widget-shadow ui-corner-all"></div>
			</div>
			<div id="overviewcontainer" class="ui-widget ui-widget-content ui-corner-all">
		</div>
	</div>

<div id="draggable" class="ui-widget-content ui-corner-all">
	<button id="switchoverview">
		<p deltaresaction = showoverview(200) >Show overview</p>
		<p deltaresaction = hideoverview(200) style="display: none">Hide overview</p>
	</button>

	<!--
	<lu id="mainlist" class="ui-helper-clearfix ui-widget-header ui-corner-all">
		<li class="ui-state-default ui-corner-all">Test overview</li>
		<li class="ui-state-default ui-corner-all">All tests</li>
		<li class="ui-state-default ui-corner-all">Successfull tests</li>
		<li class="ui-state-default ui-corner-all">Unsuccessfull tests</li>
		<li class="ui-state-default ui-corner-all">Tests without a testresult</li>
	</lu>
	-->
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