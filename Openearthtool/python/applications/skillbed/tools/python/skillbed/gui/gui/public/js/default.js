var startx = 0;
var nrselect = 0;
var nrtotal = 0;
var speed = "slow";

function selectAll(obj) {
	$('input[name="'+obj.value+'[]"]').attr('checked', $(obj).attr('checked'));
}

function startSlide(x) {
	startx = x;
}

function stopSlide(x) {
	diffx = Math.abs(x-startx);
	dirx = (x-startx)/diffx;
	
	if (diffx > 100) {
		slideTo(nrselect-dirx);
	}
}

function keySlide(keycode) {
	switch (keycode) {
		case 37:
		case 1:
			slideTo(nrselect+1);
			break;
		case 39:
		case -1:
			slideTo(nrselect-1);
			break;
	}
}

function slideTo(i) {
	ishift = i-nrselect;
	
	if (i >= 0 && i < nrtotal) {
		shift = -ishift*getShift();

		$("#roller").animate({"left":"+="+shift+"px"}, speed);

		nrselect = i;

		setFade();
	}
}

function getShift() {
	shift = $(".frame").outerWidth();
	shift += parseInt($(".frame").css("margin-left"));
	shift += parseInt($(".frame").css("margin-right"));
	
	return shift
}

function setFade() {
	for (i=0; i<nrtotal; i++) {
		if (i == nrselect) {
			$(".frame:eq("+i+")").fadeTo(speed, 0.8);
		} else {
			$(".frame:eq("+i+")").fadeTo(speed, 0.2);
		}
	}
}

function setFooter() {
	thefooter = new Array();
	
	titles = $(".frame").children("h3");
	
	for (i=0; i<titles.length; i++) {
		thefooter.push("<a href=\"#\" onclick=\"slideTo("+i+");\">"+titles[i].innerHTML+"</a>");
	}
	
	$("#footer").html(thefooter.join(" &middot; "));
}

function setProgress(runid) {
	p = $.ajax({url:'/interface/progress?runid='+runid,type:'GET',cache:false,async:false});
	
	if (p.responseText != 'FALSE') {
		$("#progress").html(p.responseText).scrollTop($("#progress").attr("scrollHeight"));
	}
	
	setMonitor();
	
	setTimeout("setProgress('"+runid+"');", 1000);
}

function setMonitor() {
	p = $.ajax({url:'/interface/monitor',type:'GET',cache:false,async:false});
	
	if (p.responseText != 'FALSE') {
		data = p.responseText.split("\n");
		
		servers = parseInt(data[0]);
		clients = 0;
		list = '';
		
		if (data.length > 1) {
			for (i = 1; i < data.length; i++) {
				if (data[i].length > 1) {
					clients++;
					
					datai = data[i].split('|');
					list += '<li><a href="/interface/run?runid='+datai[0]+'" title="'+datai[1]+'">'+datai[0]+'</a></li>';
				}
			}
			
			if (list == '') {
				list = '<br>No requests<br>';
			} else {
				list = '<ol>'+list+'</ol>';
			}
		}
		
		$("#monitor_title").html('Currently running <b>'+clients+'</b> client requests on <b>'+servers+'</b> servers<br>');
		
		$("#monitor_body").html(list);
	}
	
	//setTimeout("setMonitor();", 5000);
}

function toggleMonitor() {
	$("#monitor_body").slideToggle('slow');
}

$(document).ready(function() {
	$("html").mousedown(function(e){startSlide(e.clientX);});
	$("html").mouseup(function(e){stopSlide(e.clientX);});
	$("html").keydown(function(e){keySlide(e.keyCode);});
	$("html").wheel(function(e,delta){keySlide(delta>0?-1:1);});
	$("#monitor").click(function(e){toggleMonitor();});
	
	nrtotal = $(".frame").length;
	
	$(".frame").width(600).height(400);
	
	$(".checklist").width(550).height(250);
	
	$("#progress").width(550).height(200);
	
	$("#monitor").width(300);
	
	$("#roller").css("width", nrtotal*getShift());
	
	$("#roller,#title,#footer").css("left", ($(window).width()-$(".frame").outerWidth())/2);
	
	$("#monitor").fadeTo('fast', 0.5);
	$("#title,#footer").fadeTo('fast', 0.8);
	
	setFade();
	setMonitor();
	
	if (nrtotal > 1) {
		setFooter();
	}
});