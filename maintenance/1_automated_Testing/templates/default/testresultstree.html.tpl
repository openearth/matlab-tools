<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
"http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<title>Test result explorer</title>
<LINK href="stylesheet.css" rel="stylesheet" type="text/css">
<script language="javascript" src="script/tree_view.js"></script>
<script language="JavaScript" type="text/JavaScript">

function CreateTestExplorer()
{
        Initialise();

        // Build a project.

d = CreateTreeItem( rootCell, "img/folder_closed.gif", "img/folder_open.gif", "Test Results", "resultoverview_large.html", "test_viewer" );
<!-- ##BEGINTESTS -->
	d#TESTNUMBER = CreateTreeItem( d, "#ICON", "#ICON", "#TESTNAME", "#TESTHTML", "test_viewer" );
	<!-- ##BEGINTESTCASE -->
	
		d#TESTNUMBER#TESTCASENUMBER=   CreateTreeItem( d#TESTNUMBER, "#ICON", "#ICON", "#TESTCASENAME", null, null );
			d#TESTNUMBER#TESTCASENUMBER1 = CreateTreeItem( d#TESTNUMBER#TESTCASENUMBER, null, null, "Description", "#DESCRIPTIONHTML", "test_viewer" );
    			d#TESTNUMBER#TESTCASENUMBER2 = CreateTreeItem( d#TESTNUMBER#TESTCASENUMBER, null, null, "Result", "#RESULTHTML", "test_viewer" );
    			Toggle(d#TESTNUMBER#TESTCASENUMBER1.cleanid);
    			Toggle(d#TESTNUMBER#TESTCASENUMBER2.cleanid);
    	<!-- ##ENDTESTCASE -->
<!-- ##ENDTESTS -->
Toggle(d.cleanid);

}

</script>
</head>

<body onLoad="CreateTestExplorer();" class="treeview_menu" background="#50C9F6">
</body>
</html>

<!-- ##ICONS -->
<!-- #POSITIVE=img/small_green_check_transp.gif -->
<!-- #NEUTRAL=img/small_neutral_transp.gif -->
<!-- #NEGATIVE=img/small_red_cross_transp.gif -->
<!-- ##ENDICONS -->