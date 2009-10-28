<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<style type="text/css">
	#header {
	text-align:left;
	test-valign:middle;
	line-height:40px;
	font-family:Sansa,Arial, Sans-serif;
	font-size:20px;
	font-weight:bold;
	color:#008FC5;

	#normaltext {
	text-align:left;
	line-height:15px;
	font-family:Sansa, Arial, Sans-serif;
	font-size:12px;
	font-weight:normal;
	color:black;
	}
</style>

</head>

<body MARGINHEIGHT="0" MARGINWIDTH="0" PADDING="0" SPACING="0" TOPMARGIN="10" LEFTMARGIN="10">
<p id="header">Test results</p>
<p id="normaltext">Number of tests executed and published: #NRTESTSTOTAL (containing #NRTESTCASESTOTAL testcases)</p>
<p id="normaltext">The tests result can be summed up as follows:
<p id="normaltext"><img src="#POSITIVEICON" border="none" height=12> #NRSUCCESSFULLTESTS Tests turned out to be <a href="successfulltests.html" target="test_tree">successfull</a></p>
<p id="normaltext"><img src="#NEGATIVEICON" border="none" height=12> #NRUNSUCCESSFULLTESTS Tests turned out to be <a href="unsuccessfulltests.html" target="test_tree">not successfull</a></p>
<p id="normaltext"><img src="#NEUTRALICON" border="none" height=12> #NRNEUTRALTESTS Tests turned out to <a href="notestresults.html" target="test_tree">have no result</a></p>

</body>
</html>

<!-- ##ICONS -->
<!-- #POSITIVE=img/small_green_check_transp.gif -->
<!-- #NEUTRAL=img/small_neutral_transp.gif -->
<!-- #NEGATIVE=img/small_red_cross_transp.gif -->
<!-- ##ENDICONS -->