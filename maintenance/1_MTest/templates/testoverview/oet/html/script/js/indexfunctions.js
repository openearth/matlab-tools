	function correctimages(htmldiv)
		{
		htmldiv.find('img').each(function() 
			{
			$(this).attr('src',"html/"+$(this).attr('relsrc'))
			})
		}
	function loadtestcase(event)
		{
			$("#tabs_description").load(event.data.descriptionhtml,[],function() {
				$(document).ajaxStop(correctimages($(this)));
				});
			$("#tabs_result").load(event.data.resulthtml,[],function() {
				$(document).ajaxStop(correctimages($(this)));
				});
			$("#tabs_function_coverage").load(event.data.coveragehtml,[],function() {
							$(document).ajaxStop(linkcoveragenames());
				});
			if ($("#TestDocumentationContent").css('display')=="none")
				{
				$("#maincomponents").accordion('activate',1); 
				}
		}
	function loadtest(event)
		{
			// assign new html pages to tabs
			$("#tabs_description").load(event.data.descriptionhtml,[],function() {
				$(document).ajaxStop(correctimages($(this)));
				});
			$("#tabs_result").load(event.data.resulthtml,[],function() {
				$(document).ajaxStop(correctimages($(this)));
				});
			$("#tabs_function_coverage").load(event.data.coveragehtml,[],function() {
				$(document).ajaxStop(linkcoveragenames());
				});
			
			if ($("#TestDocumentationContent").css('display')=="none")
				{
				$("#maincomponents").accordion('activate',1); 
				}
		}
	
	function linkcoveragenames()
		{
			$(".RelFunctionRef").each(function(i) 
				{
					$(this).bind('click', {index:i, functioncoveragehtml:$(this).attr('deltares:functioncoverageref')}, showFunctionCoverage);
				});
		}

	function assigntree()
		{
		$("[class='Mtest']").each(function(i) {
				$(this).bind('click', {index:i, descriptionhtml:$(this).attr('deltares:mtestdescriptionref'), coveragehtml:$(this).attr('deltares:mtestcoverageref'), resulthtml:$(this).attr('deltares:mtestresultsref')}, loadtest);
			});
		$("[class='MtestCase']").each(function(i) {
				$(this).bind('click', {index:i, descriptionhtml:$(this).attr('deltares:mtestdescriptionref'), coveragehtml:$(this).attr('deltares:mtestcoverageref'), resulthtml:$(this).attr('deltares:mtestresultsref')}, loadtestcase);
			});
		$("[class='deltaresreference']").each(function(i) {
				$(this).bind('click', {index:i, descriptionhtml:$(this).attr('deltares:mtestdescriptionref'), coveragehtml:$(this).attr('deltares:mtestcoverageref'), resulthtml:$(this).attr('deltares:mtestresultsref')}, loadtest);
			});
		$("[class='FunctionCall']").each(function(i) {
				$(this).bind('click', {index:i, functioncoveragehtml:$(this).attr('deltares:mtestfunctioncoverage')}, showFunctionCoverage);
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

	function showFunctionCoverage(event)
		{
			$("#FunctionCoverageBody").load(event.data.functioncoveragehtml);
			if ($("#TestCoverageContent").css('display')=="none")
				{
				$("#maincomponents").accordion('activate',2); 
				}
		}