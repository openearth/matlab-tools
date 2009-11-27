<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>

	<meta http-equiv="content-type" content="text/html; charset=iso-8859-1"/>
	<title>Tutorial overview</title>

	<link rel="stylesheet" href="html/script/css/jquery.treeview.css" />
    <link rel="stylesheet" href="html/script/css/jquery-ui-1.7.2.custom.css" />
    <link rel="stylesheet" href="html/script/css/jquery.collapsible.css" />

	<script src="html/script/js/jquery-1.3.2.min.js" type="text/javascript"></script>
	<script src="html/script/js/matlab2collapsible.js" type="text/javascript"></script>
	<script src="html/script/js/jquery-ui-1.7.2.custom.min.js" type="text/javascript"></script>
	<script src="html/script/js/jquery.treeview.js" type="text/javascript"></script>
	<script src="html/script/js/jquery.collapsible.js" type="text/javascript"></script>
    <script type="text/javascript" src="html/script/js/matlabhelp.js"></script>
	<script type="text/javascript">
	$(document).ready(function(){
		$(".maintree").treeview({});

		// bind links in treeview
		bindlinks();

		//click first item
		$($(".file")[0]).trigger('click');
	})

	function bindlinks()
		{
			$("[class='file']").each(function(i)
               {
               $(this).bind('click', {index:i, html:$(this).attr('ref')}, loadcontent);
				});
		}

	function loadcontent(event)
		{
		$("#contentspanel").load(event.data.html,"html",function()
			{
			$("document").ajaxStop(finishtutorials());
			});

		}

	function finishtutorials()
		{
				// Perform document ready operations of tutorial

				// Copy content
				copycontent();

				// validate href of links to matlab tutorials
				matlabpreparehelprefs();

				// Accordion
				collapsible($(".collapsible"));

				// link images
				linkimages();
		}

	function linkimages()
		{
		var images = $("img");
		images.each(function(i)
			{
			$(this).attr('src',"html/" + $(this).attr('relsrc'))
			});
		var relrefs = $(".relref");
		relrefs.each(function(i)
			{
			$(this).attr('href','#');
			$(this).bind('click', {index:i, html:"html/" + $(this).attr('relhref')}, loadcontent);
			});
		}

	</script>

	<style>
	#maintree {
		width:	  19%;
		heigth:   100%;
        overflow: hidden;
		float:	  left;
		}

	#contentspanel {
		width:	  80%;
		height:   100%;
		float:	  right;
		overflow: auto;
        }


	.hidden {
		visibility: hidden;
		}
	</style>

</head>
<body>

	<div id="maintree" class="ui-widget ui-widget-content ui-corner-all">
		<ul id="browser" class="filetree treeview maintree">
			<li><span class="folder">General</span>
				<ul>
				<!-- ##BEGINGENERAL -->
					<!-- ##BEGINFILEITEM -->
					<li><a><span class="file" ref="#HTMLREF">#FILENAME</span></a></li>
					<!-- ##ENDFILEITEM -->
					<!-- ##BEGINFOLDERITEM -->
					<li><span class="folder">#FOLDERNAME</span>
						<ul>
							<!-- ##BEGINFILEITEM -->
							<li><a><span class="file" ref="#HTMLREF">#FILENAME</span></a></li>
							<!-- ##ENDFILEITEM -->
						</ul>
					</li>
					<!-- ##ENDFOLDERITEM -->
				<!-- ##ENDGENERAL -->
				</ul>
			</li>
			<li><span class="folder">Applications</span>
				<ul>
				<!-- ##BEGINAPPLICATIONS -->
					<!-- ##BEGINFOLDERITEM -->
					<li><span class="folder">#FOLDERNAME</span>
						<ul>
							<!-- ##BEGINFILEITEM -->
							<li><a><span class="file" ref="#HTMLREF">#FILENAME</span></a></li>
							<!-- ##ENDFILEITEM -->
						</ul>
					</li>
					<!-- ##ENDFOLDERITEM -->
				<!-- ##ENDAPPLICATIONS -->
				</ul>
			</li>
			<div class="hidden">Extra line</div>
		</ul>
	</div>

	<div id="contentspanel" class="ui-widget">
	</div>

</body>
</html>