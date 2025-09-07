function back()
{
	var form;
	form = document.createElement( "form");
	form.method = "post";
	form.action = "storage.html";
	var csrf_token = document.getElementById('token').value;
	
	var input = new Array();
	for(var i = 1; i <=4; i++){
    input[i] = document.createElement("input");
    $(input[i]).attr("type","hidden");
    if(i==1){
      $(input[i]).attr('name','action');
      $(input[i]).attr("value","list");
    } else if(i==2){
      $(input[i]).attr('name','dir');
      $(input[i]).attr("value",'/');
    } else if(i==3){
      $(input[i]).attr('name','filter');
      $(input[i]).attr("value",'0');
    } else {
	    $(input[i]).attr('name','token');
	    $(input[i]).attr("value",csrf_token);
	  }  
    form.appendChild(input[i]);
  }
	document.body.appendChild(form);
	form.submit();	
	return true;
}

function format_check()
{
  var ans = confirm('Are you sure you want to format?\n\nWARNING: Formatting will erase ALL data on this SD Card.');
  if(ans == true) {
		var form;
		form = document.createElement( "form");
		form.method = "post";
		form.action = "storage.html";
		var csrf_token = document.getElementById('token').value;
		
		var input = new Array();
		for(var i = 1; i <=2; i++){
		input[i] = document.createElement("input");
		$(input[i]).attr("type","hidden");
		if(i==1){
		  $(input[i]).attr('name','action');
		  $(input[i]).attr("value","do_format");
		} else {
	    $(input[i]).attr('name','token');
	    $(input[i]).attr("value",csrf_token);
	  }   
		form.appendChild(input[i]);
		}
		document.body.appendChild(form);
		form.submit();	
		return true;
  }
	return false;
}