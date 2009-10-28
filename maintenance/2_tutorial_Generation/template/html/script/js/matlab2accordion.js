function copycontent() 
  {
    // look at length of the divs in the accordion
    var lengthch = $(".accordion").children().length -1;
    lasthead = null;
    
    // Center title of document
    $(".accordion").find('h1').css('text-align','center');
    
    // Loop divs and copy content
    for (i = 0; i <= lengthch; i++)
    {
    
      // Look if there are any headers in the div
      chldr = $($(".accordion").children()[i]).children("h2");
      if (chldr.length==0)
        {
        
        // If there are headers set correct settings
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
    $(".introduction").children('h2').css('padding','10px');
    $(".introduction").children('h1').css('text-align','center');
  }
