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
	$(document).ready(function ()
	{
		//draggable main window
		$(".deltaresdraggable").draggable();
		$(".deltaresdraggable").bind('dragstop', function(){$("#switchoverview").css('width',300)});

		// Accordion
		$("#accordion").accordion({ header: "h3" });

		// Tabs
		$('#tabs').tabs();

		assigntree()

		//Set position of overlay and hide
		$("#overviewoverlay").hide();

		//Set overview container and shadow
		$("#overviewcontainer").hide();
		$("#shadow").hide();

		$("#switchoverview").click(function () {
		    showoverview();
		  });

		//$("#tree_panel").resizable({ handles: 'e, w' });
		$("#result_tab").resizable({ handles: 'e, w' });


		//Load contents
		$("#overviewcontainer").load("overviewtable.html");

		//assign links
		$(document).ajaxStop(assignoverview);
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
		<div id="tree_panel" class="deltaresdraggable" index = "1">
			<div id="switchoverview" class="ui-widget-content ui-corner-all">
				<a href="#" deltaresaction = showoverview(200) >Show overview</a>
			</div>
			<div id="accordion" deltares:mtesttype="testtree">
			<!--##BEGINTESTS-->
				<div id="#TESTNUMBER">
					<h3><a href="#" class="Mtest" deltares:mtestdescriptionref = "#DESCRIPTIONHTML" deltares:mtestresultsref = "#RESULTHTML"><img class="icon_image" src="#ICON" height="12"> #TESTNAME</a></h3>
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
		<div id="result_viewer" class = "deltaresdraggable">
			<div id="result_tab">
				<div id="tabs" index = "2">
					<ul>
						<li><a href="#tabs_description">Description</a></li>
						<li><a href="#tabs_result">Result</a></li>
					</ul>
					<div id="tabs_description">Click one of the items on the left to show a test description or testcase result.</div>
					<div id="tabs_result">Click one of the items on the left to show a test description or testcase result.</div>
				</div>
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
<!--
<div class="ui-widget-content ui-corner-all deltaresdraggable">


	<lu id="mainlist" class="ui-helper-clearfix ui-widget-header ui-corner-all">
		<li class="ui-state-default ui-corner-all">Test overview</li>
		<li class="ui-state-default ui-corner-all">All tests</li>
		<li class="ui-state-default ui-corner-all">Successfull tests</li>
		<li class="ui-state-default ui-corner-all">Unsuccessfull tests</li>
		<li class="ui-state-default ui-corner-all">Tests without a testresult</li>
	</lu>

</div>
-->



</div>


</div>
</body>
</html>

<!-- ##ICONS -->
<!-- #POSITIVE=img/small_green_check_transp.gif -->
<!-- #NEUTRAL=img/small_neutral_transp.gif -->
<!-- #NEGATIVE=img/small_red_cross_transp.gif -->
<!-- ##ENDICONS -->