<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html>
<head>
<style>

body {
	  	background	: white;
	  	//color	: #61604C
	  	//color		: red;
	  	font-family	: salse,arial,sans-serif;
	  	margin		: 0;
	  	padding		: 1ex;
	  	font-size	: 12px;
	}

.cell {
	float	: left;
	color		: #61604C;
	border-color: #61604C;
	border-bottom-style: solid;
	border-bottom-width: 1px;
	border-left-style: dotted;
	border-left-width: 1px;
	}

.headercell {
	float	: left;
	font-weight: bold;
	background-color : #008fc5;
	color		: #c2d6e1;
	border-color: #008fc5;
	border-left-style: dotted;
	border-left-width: 1px;
	border-top-style: solid;
	border-top-width: 2px;
	border-bottom-style: solid;
	border-bottom-width: 2px;
	}

.deltaresicon {
	text-align: center;
	}

.deltaresresult {
	width	: 40px;
	padding-left  : 2px;
	}

.deltaresname {
	width	: 200px;
	padding-left  : 2px;
	}

.deltaresdate {
	width	: 150px;
	padding-left  : 2px;
	}

.deltaresauthor {
	width	: 397px;
	padding-left  : 2px;
	}

.deltareslastcell {
	border-right-style: dotted;
	border-right-width: 1px;
	}

#hidelink {
	text-align: center;
	color: #61604C;
}

#overviewmain {
	margin	: 0 auto;
	width	: 800px;
	}
</style>
</head>

<body>
<div id="overviewmain">
	<div id="hidelink">
		<a href="#" id="hidetext">Hide overview</a>
	</div>
	<div class="headercell deltaresresult" width="40px">Result</div><div class="headercell deltaresname" width="40px">Name</div><div class="headercell deltaresdate" width="40px">Date</div><div class="headercell deltaresauthor deltareslastcell" width="40px">Last author</div>


	<!-- ##BEGINTESTS -->
	<div class="cell deltaresresult  deltaresicon"><img src="#ICON" height="12px"></div>
	<div class="cell deltaresname"><a href="#" class="deltaresreference" deltares:mtestdescriptionref ="#DESCRIPTIONHTML" deltares:mtestresultsref = "#RESULTHTML" detaresname="#TESTNAME">#TESTNAME</a></div>
	<div class="cell deltaresdate">#TESTDATE</div>
	<div class="cell deltaresauthor deltareslastcell"><a href="http://wiki.deltares.nl/display/~#TESTAUTHOR/Home" target="_new">#TESTAUTHOR</a></div>
	<!-- ##ENDTESTS -->
</div>

</body>
</html>

<!-- ##ICONS -->
<!-- #POSITIVE=img/small_green_check_transp.gif -->
<!-- #NEUTRAL=img/small_neutral_transp.gif -->
<!-- #NEGATIVE=img/small_red_cross_transp.gif -->
<!-- ##ENDICONS -->