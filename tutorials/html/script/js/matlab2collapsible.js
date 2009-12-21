function copycontent()
  {
    // look at length of the divs in the collapsible
    var lengthch = $(".collapsible").children().length -1;
    lasthead = null;

    // Center title of document
    $(".collapsible").find('h1').css('text-align','center');

    // Loop divs and copy content
    for (i = 0; i <= lengthch; i++)
    {

      // Look if there are any headers in the div
      chldr = $($(".collapsible").children()[i]).children("h2");
      if (chldr.length==0)
        {

        // If there are headers set correct settings
        if (lasthead == null)

          {
            $($(".collapsible").children()[i]).addClass('ui-widget-content');
            $($(".collapsible").children()[i]).addClass('ui-corner-all');
            $($(".collapsible").children()[i]).css('padding','10px');
            lasthead = i;
          }

	else

          {
            var html = $($(".collapsible").children()[i]).html();
	    $($(".collapsible").children()[lasthead]).children("div").append(html);
	    $($(".collapsible").children()[i]).hide();
	  }
	}

      else

	{
	  lasthead = i;
	  $($(".accorion").children()[i]).addClass('ui-widget-content');
	  $($(".accorion").children()[i]).click();
	}

    }

    //Format header
    formatheader();
  }

function formatheader()
  {
    ch = $(".introduction").children('div');
    $(ch).each(function()
      {
        if (($(this).children('ul')).length==0)
        {
	  $(this).css('padding-left','10px');
	  $(this).css('padding-right','10px');
        }
      });

    $(".introduction").children('h1').css('text-align','center');

    if ($(".introduction").children('h2').html()=="Contents")
    {
      //There is a contents list. Lets position the header:
      $(".introduction").children('h2').css('padding-left','10px');

      // and bind the click event so that chapters automatically open...:
      listitems = $(".introduction").find('li');
      referencedobjects = $("a[name]");
      listitems.each(function()
        {
          href = $(this).find('a').attr('href');
          name = href.slice(1);
	  contentlink = $(this);

          referencedobjects.each(function()
            {
              nm = $(this).attr('name');
              header = $(this).parent();
              parentdiv = $(header).parent();

              if (nm == name)
                {
                  $($(contentlink).find('a')).bind('click',{'item':parentdiv},togglediv)
                }
            });
        });
    }
  }