        function setshowbutton()
        	{
        	$("#switchoverview").css('width',300);
        	}
        
	function loadtestcase(event)
		{
			$("#tabs_description").load(event.data.descriptionhtml);
			$("#tabs_result").load(event.data.resulthtml);
		}
	function loadtest(event)
		{
			$("#tabs_description").load(event.data.descriptionhtml);
			$("#tabs_result").load(event.data.resulthtml);
		}

	function assigntree()
		{
		$("[class='Mtest']").each(function(i) {
				$(this).bind('click', {index:i, descriptionhtml:$(this).attr('deltares:mtestdescriptionref'), resulthtml:$(this).attr('deltares:mtestresultsref')}, loadtest);
			});
		$("[class='MtestCase']").each(function(i) {
				$(this).bind('click', {index:i, descriptionhtml:$(this).attr('deltares:mtestdescriptionref'), resulthtml:$(this).attr('deltares:mtestresultsref')}, loadtestcase);
			});
		}

	function hideandloadtest(event)
		{
			$("#accordion").accordion('activate' , event.data.index,{ header: 'h3' });
			loadtestcase(event);
			hideoverview();			
		}
		
	function hideandloadtestcase(event)
		{
			$("#accordion").accordion('activate' , event.data.index,{ header: 'h3' });
			loadtest(event);
			hideoverview();
		}
		
	function assignoverview(event)
		{
		$(".deltaresreference").each(function(i) {
				$(this).bind('click', {index:i, descriptionhtml:$(this).attr('deltares:mtestdescriptionref'), resulthtml:$(this).attr('deltares:mtestresultsref')}, hideandloadtest);
			});
		}

	function loadtreecontents (htmlpage)
		{
		//load contents in accordion
		$(document).ajaxStop($("#tree_panel").load(htmlpage));

		//correct layout
		$(document).ajaxStop($("#accordion").accordion({ header: "h3" }));

		//bind click events
		$(document).ajaxStop(assigntree());
		}

	function showoverview()
		{
		var pace = 200;
		//Set correct positions
		$("#overviewcontainer").css("left",$("#content").position().left+60);
		$("#shadow").css("left",$("#content").position().left+63);

		//fadeIn overview
		$("#overviewoverlay").fadeIn(pace);
		$("#overviewcontainer").fadeIn(pace);
		$("#shadow").fadeIn(pace);
		$("#hidetext").bind('click',{},hideoverview);
		}

	function hideoverview()
		{
		var pace = 200;
		//fadeOut
		$("#overviewoverlay").fadeOut(pace);
		$("#overviewcontainer").fadeOut(pace);
		$("#shadow").fadeOut(pace);
		}
