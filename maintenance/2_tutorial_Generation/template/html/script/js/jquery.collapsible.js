function collapsible(maindiv)
  {
    // jquery code to add span with icon to header
    var headers = $(maindiv).find('h2,h3');
    $("<span/>").addClass("ui-icon " + "ui-icon-triangle-1-e").prependTo(headers);

    // add classes to maindiv
    $(maindiv).addClass("ui-collapsible ui-widget ui-helper-reset");

    // add classes to headers
    $(headers).addClass("ui-collapsible-header ui-helper-reset ui-state-default ui-corner-all");

    // add classes to content
    cont = $(headers).parent();
    $(cont).children("div").addClass("ui-collapsible-content ui-helper-reset ui-widget-content ui-corner-bottom ui-collapsible-content-active");
    $(cont).children("div").css("display","none");
    $(cont).children("div").css("padding-top","11px");
    $(cont).children("div").css("padding-bottom","11px");

    $(maindiv).children('div').each(function(i)
  	{
  	$(this).children('h2,h3').bind('click', {index:i, item:$(this)}, togglediv);
  	});

  }


function togglediv(event)
  {
    d = event.data.item;
    try
      {
        e = event.data.expand;
      }
    catch(err)
      {
        e = false;
      }

    if (e)
      {
      if ($(d).children('div').css('display')=="block")
        {
        }
      else
        {
          $(d).children('h2,h3').toggleClass( "ui-state-default" );
	      $(d).children('h2,h3').toggleClass( "ui-corner-all" );
	      $(d).children('h2,h3').toggleClass( "ui-state-active" );
	      $(d).children('h2,h3').toggleClass( "ui-corner-top" );
	      $(d).find('span').toggleClass("ui-icon-triangle-1-s");
	      $(d).find('span').toggleClass("ui-icon-triangle-1-e");
  	      $(d).children('div').css('display','block');
  	      initgoogle($(d).children('div').children('.geapi',':has(.geapi)'));
        }
      }
    else
      {
        if ($(d).children('div').css('display')=="block")
          {
            // content is visible --> so hide it
            var containsGEApi = false;
    	    if (!geApiLoaded)
	          {
	            geapis  = $(d).children('div').children('.geapi',':has(.geapi)')
	    	    if (geapis.length > 0)
	    	      {
	    	        containsGEApi = true;
	    	      }
              }
            if (!containsGEApi)
              {
	            // Hide the thing. It does not contain any geapi!
	    	    $(d).children('h2,h3').toggleClass( "ui-state-default" );
	    	    $(d).children('h2,h3').toggleClass( "ui-corner-all" );
	    	    $(d).children('h2,h3').toggleClass( "ui-state-active" );
	         	$(d).children('h2,h3').toggleClass( "ui-corner-top" );
	    	    $(d).find('span').toggleClass("ui-icon-triangle-1-s");
	            $(d).find('span').toggleClass("ui-icon-triangle-1-e");
	    	    $(d).children('div').css('display','none');
	          }
          }
        else
          {
    	    // Show the content
    	    $(d).children('div').css('display','block');
    	    if (!geApiLoaded)
    	      {
    	        geapis  = $(d).children('div').children('.geapi',':has(.geapi)')
	            if (geapis.length > 0)
		          {
		            initgoogle(geapis);
		          }
              }
            $(d).children('h2,h3').toggleClass( "ui-state-default" );
		    $(d).children('h2,h3').toggleClass( "ui-corner-all" );
			$(d).children('h2,h3').toggleClass( "ui-state-active" );
			$(d).children('h2,h3').toggleClass( "ui-corner-top" );
			$(d).find('span').toggleClass("ui-icon-triangle-1-s");
			$(d).find('span').toggleClass("ui-icon-triangle-1-e");
          }
      }
  }