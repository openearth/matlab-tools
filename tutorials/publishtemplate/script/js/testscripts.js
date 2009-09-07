function copycontent() 
	{
		var lengthch = $(".accordion").children().length -1;
		lasthead = 0;
		for (i = 0; i <= lengthch; i++)
		{
			chldr = $($(".accordion").children()[i]).children("h2");
			if (chldr.length==0)
			{
				var html = $($(".accordion").children()[i]).html();
				$($(".accordion").children()[lasthead]).children("div").append(html);
				$($(".accordion").children()[i]).hide();
			}
			else
			{
				lasthead = i;
			}
		}
	}
