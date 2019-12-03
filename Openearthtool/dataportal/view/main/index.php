<?php
/**
 * Controller handling profile functionality
 * User: Marten Janssen
 * Time: 5:45 PM
 */
$main_json = file_get_contents( BASEPATH . 'view' . DIRECTORY_SEPARATOR . 'main' . DIRECTORY_SEPARATOR . 'main_json.php' );

?>
<script>
    Deltares.Main = Deltares.Main || {};
    var _NOT_AVAILABLE = "Coming soon";
    var _JSON_DATA = <?php echo $main_json; ?>;

 	// Format link
	function formatLink( href ){
		if( href.indexOf('@') > -1 ){
			href = "mailto:" + href;
		}else if(href.indexOf('http') < 0){
			href = "http://" + href;
		}
		return href;
	};
    
    function createLargeBlock(data){
		// Format link
		var href = formatLink(data.link);
        
		var block = $("<div/>")
    		.prop("id", "dt-main-"+data.key)
    		.addClass("blockLarge")
    		.addClass("btn-default")
			.addClass("blockBorder")
			.attr('data-target','_blank')
			.attr("data-url",href)
			.attr("title", data.helptext);

		// Left(icon)
		var blockLeft = $("<div/>")
			.addClass("blockGlyphiconLarge")
			.append(
				$("<h2/>")
				.addClass("glyphicon-icon")
				.addClass(data.iconclass)
			);
		block.append(blockLeft);

		// Right (header, text, link)
		var blockRight = $("<div/>")
			.addClass("right")
			.append( 
	    		$("<h4/>")
	    			.text(data.label)
	    		)
    		.append(
	    		$("<p/>")
	    			.html(data.text) 
	    		);
		block.append(blockRight);

		return block;
    };

    function createMediumBlock(data){
    	// Format link
		var href = formatLink(data.link);
        
		var block = $("<div/>")
    		.prop("id", "dt-main-"+data.key)
    		.addClass("blockMedium")
    		.addClass("btn-default")
			.addClass("blockBorder")
			.attr('data-target','_blank')
			.attr("data-url",href)
			.attr("title", data.helptext);

		// Left(icon)
		var blockLeft = $("<div/>")
			.addClass("blockGlyphiconMedium")
			.append(
				$("<h2/>")
				.addClass("glyphicon-icon")
				.addClass(data.iconclass)
			);
		block.append(blockLeft);

		// Right (header, text, link)
		var blockRight = $("<div/>")
			.addClass("right")
			.append( 
	    		$("<h4/>")
	    			.text(data.label)
	    		)
    		.append(
	    		$("<p/>")
	    			.html(data.text) 
	    		);
		block.append(blockRight);

		return block;
    };

    function createSmallBlock(data){
    	// Format link
		var href = formatLink(data.link);
        
		var block = $("<div/>")
    		.prop("id", "dt-main-"+data.key)
    		.addClass("blockSmall")
    		.addClass("btn-default")
			.addClass("blockBorder")
			.attr('data-target','_blank')
			.attr("data-url",href)
			.attr("title", data.helptext);

		// Left(icon)
		var blockLeft = $("<div/>")
			.addClass("blockGlyphiconSmall")
			.append(
				$("<h2/>")
				.addClass("glyphicon-icon")
				.addClass(data.iconclass)
			);
		block.append(blockLeft);

		// Right (header, text, link)
		var blockRight = $("<div/>")
			.addClass("right")
			.append( 
	    		$("<h4/>")
	    			.text(data.label)
	    		)
    		.append(
	    		$("<p/>")
	    			.html(data.text) 
	    		);
		block.append(blockRight);

		return block;
    };
    

    
    $(document).on("ready", function() {
 		var even = true;
    	for(var k in _JSON_DATA['large']) {
			var field = _JSON_DATA['large'][k];

			var container = $("<div/>")
			.addClass("col-md-4")
			.addClass("btn-vert-block");

			if(even){
				container.addClass("col-md-offset-4");
				even = !even;
			}
			
			var block = createLargeBlock(field);
			container.append( block );
			$(HASH + "dt-main").append(container);
		}

    	
		var mediumBlock = $('<div/>')
			.addClass("col-md-8")
			.addClass("col-md-offset-2")
			.addClass("btn-vert-block");
		$(HASH + "dt-main").append(mediumBlock);
    	for(var k in _JSON_DATA['medium']) {
			var field = _JSON_DATA['medium'][k];
			var container = $("<div/>")
			.addClass("col-md-4")
			.addClass("btn-vert-block");

			if(even){
				container.addClass("col-md-offset-3");
				even = !even;
			}
			
			var block = createMediumBlock(field);
			container.append( block );
			mediumBlock.append(container);
		}



    	var smallBlock = $('<div class="col-md-8 col-md-offset-2 text-center " id="quickLinks"><h2 class="">Quick links to common datasets</h2></div>');
    	
    	var even = true;
    	for(var k in _JSON_DATA['small']) {
    		var field = _JSON_DATA['small'][k];
			var container = $("<div/>")
			.addClass("col-lg-3")
			.addClass("containerSmall")
			.addClass("btn-vert-block");
			

			
			var block = createSmallBlock(field);
			container.append( block );
			smallBlock.append(container);
		}
    	$(HASH + "dt-main").append(smallBlock);


    	 
    	// If data link defined, go to
    	$("div[data-url][data-url!='']").click( function( e ) {
	    	if( ! $(this).hasClass("inactive")){
	    		var url = $(this).data("url");
				e = e || window.event;
				// If target is _blank or ctrl-key is pressed
				//TODO reset
		   		if(e.ctrlKey || $(this).data("target") == "_blank" ){
					window.open( url );
				}else{
					window.location = url;
				}
    		}
    	});

    	// Show tooltip if inactive
		 $( ".blockBorder").tooltip({
			 delay: { show: 300, hide: 100 }
		 });

		 // Disable link if inactive
		 $( ".inactive a").attr('href','#');
    });
</script>
<div class="col-sm-12">
	<div class="row" id="dt-main" >
		<!-- content -->
	</div>
</div>