function copycontent() 
	{
		var lengthch = $(".accordion").children().length -1;
		lasthead = null;
		for (i = 0; i <= lengthch; i++)
		{
			chldr = $($(".accordion").children()[i]).children("h2");
			if (chldr.length==0)
			{
			if (lasthead == null)
			{
				$($(".accordion").children()[i]).addClass('ui-widget-content');
				$($(".accordion").children()[i]).addClass('ui-corner-all');
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
			}
		}
	}
