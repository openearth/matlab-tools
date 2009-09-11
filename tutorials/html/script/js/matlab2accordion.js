function copycontent() 
  {
    var lengthch = $(".accordion").children().length -1;
    lasthead = null;
    $(".accordion").children().children('h1').css('text-align','center');
    for (i = 0; i <= lengthch; i++)
    {
      chldr = $($(".accordion").children()[i]).children("h2");
      if (chldr.length==0)
        {
        if (lasthead == null)
          {
            $($(".accordion").children()[i]).addClass('ui-widget-content');
            $($(".accordion").children()[i]).addClass('ui-corner-all');
            $($(".accordion").children()[i]).css('padding','10px');
            lasthead = i;
          }
	else
          {
            var html = $($(".accordion").children()[i]).html();
	    $($(".accordion").children()[lasthead]).children("div").append(html);
	    $($(".accordion").children()[i]).hide();
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
    $(".introduction").children('div').css('padding','10px');
    $(".introduction").children('h1').css('text-align','center');
  }
