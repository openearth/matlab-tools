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

	function assigntree()
		{
		$("[class='MtestDescription']").each(function(i) {
					$(this).bind('click', {index:i, descriptionhtml:$(this).attr('deltares:mtestdescriptionref')}, loaddescription);
					});
				$("[class='MtestCase']").each(function(i) {
					$(this).bind('click', {index:i, descriptionhtml:$(this).attr('deltares:mtestdescriptionref'), resulthtml:$(this).attr('deltares:mtestresultsref')}, loadtestcase);
					});
				$("#result_tab").hide();
		$("#result_description").show();
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

	function showoverview (pace)
		{
		//Set correct positions
		$("#overviewoverlay").css("left",$("#content").position().left);
		$("#overviewcontainer").css("left",$("#content").position().left+60);
		$("#shadow").css("left",$("#content").position().left+63);

		//Load contents
		$("#overviewcontainer").load("overviewtable.html");

		//fadeIn overview
		$("#overviewoverlay").fadeIn(pace);
		$("#overviewcontainer").fadeIn(pace);
		$("#shadow").fadeIn(pace);
		}

	function hideoverview (pace)
		{
		//fadeOut
		$("#overviewoverlay").fadeOut(pace);
		$("#overviewcontainer").fadeOut(pace);
		$("#shadow").fadeOut(pace);
		}
