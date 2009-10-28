function matlabpreparehelprefs() 
  {
  	if (document.location.protocol.indexOf('jar') == -1)
  	{
  		$(".matlabhref").attr('href',$(".matlabhref").attr('browserhref')).attr('target','new');
  	}
  }
