var file_upload_list_flag=new Array();
var up_index=0,up_size=0,up_length,up_ok=0,up_fail=0,xhr,uploaded_size=0,time_i,time_s,free_size;
var _interval, curr_path,root_path, iframeId ;
var hf_alloc_data={};
var upload_state_interval;
var timer_delay,delay_time=200;

var agent = navigator.userAgent.toLowerCase();
var browse;
if ( (navigator.appName == 'Netscape' && navigator.userAgent.search('Trident') != -1) || (agent.indexOf("msie") != -1) ) browse = "msie";


$('document').ready(function() {
	$('#start_upload').hide();
});

function get_hf_token(id){
  var file_id=parseInt(hf_alloc_data.start_id)+id;
  file_id = file_id.toString();
  var len=file_id.length;
  if(len>6) return hf_alloc_data.token+ file_id.substr(-6);
  else return (hf_alloc_data.token+ "000000".substring(len)+file_id);

}

function ie_fileUpload(form) {
	uploaded_size = 0;
	var iframe = document.createElement("iframe");
	iframe.setAttribute("id", "upload_iframe");
	iframe.setAttribute("name", "upload_iframe");
	iframe.setAttribute("width", "0");
	iframe.setAttribute("height", "0");
	iframe.setAttribute("border", "0");
	iframe.setAttribute("style", "width: 0; height: 0; border: none;");
	form.parentNode.appendChild(iframe);
	window.frames['upload_iframe'].name = "upload_iframe";

	iframeId = document.getElementById("upload_iframe");
	$('#start_upload').hide();
	$('#cancel_upload').show();

	var eventHandler = function () {

  	if (iframeId.detachEvent) iframeId.detachEvent("onload", eventHandler);
  	else iframeId.removeEventListener("load", eventHandler, false);

  	var content;

  	if (iframeId.contentDocument) {
  		content = iframeId.contentDocument.body.innerHTML;
  	} else if (iframeId.contentWindow) {
  		content = iframeId.contentWindow.document.body.innerHTML;
  	} else if (iframeId.document) {
  		content = iframeId.document.body.innerHTML;
  	}
  	if(_interval) clearInterval(_interval);
  	if(time_s) clearInterval(time_s);
  	if(content=='<pre>upload OK</pre>') {
  	  $('.file_list_del_span').eq(0).html('OK');
   	  $('#upload_state_tips').html('<span style="color:blue;">Upload OK: 1</span>');
 	  	$('#cancel_upload').hide();
  	}
  	else if(content=='<pre>upload fail</pre>') {
    	  $('.file_list_del_span').eq(0).html('Fail');
     	  $('#upload_state_tips').html('Upload Fail: 1');
   	  	$('#cancel_upload').hide();
  	}
		setTimeout(function remove_iframe(){if(iframeId.parentNode) iframeId.parentNode.removeChild(iframeId)}, 250);
	}

	if (iframeId.addEventListener) iframeId.addEventListener("load", eventHandler, true);
	if (iframeId.attachEvent) iframeId.attachEvent("onload", eventHandler);

	var action_url = "http://"+document.domain+":61726";

	form.setAttribute("target", "upload_iframe");
	form.setAttribute("action", action_url);
	form.setAttribute("method", "post");
	form.setAttribute("enctype", "multipart/form-data");
	form.setAttribute("encoding", "multipart/form-data");
	form.submit();
}


if ($.browser.msie && parseInt($.browser.version)<10)
{
	// IE suspends timeouts until after the file dialog closes
	$('#up_file').click(function(event)
	{
		setTimeout(function()	{
			if($('#up_file').val().length > 0) {
				//              alert($('#up_file').val());
				var path = $('#up_file').val();
				var file_name = path.substring(path.lastIndexOf('\\')+1,path.length);
				file_name=XSSResolveCannotParseChar(file_name);


				var list='<div style="border:1px solid gray;background:#ddd;"><span class="file_list_name">Name</span><span class="file_list_size">Size</span>Status</div>';
				list += ('<div style="border:1px solid gray;border-top:none;"><span class="file_list_name">'+file_name+'</span><span class="file_list_size">-</span><span class="file_list_del_span"><a title="cancel upload this file" class="file_list_del"><img src="_img/default.gif" /></a></span></div>');

				$('#file_list').html(list);
				$('#upload_state_tips').html('');
				$('#upload_fail_tips').html('');
				$('#start_upload').show();
//			hf_alloc_data.id_cnt=files.length;
//					hf_alloc_data.session=$(data).find("session_id").text();
			hf_alloc_data.token=document.upload_form.token.value;
			}	}, 0);
	});
}
else
{
$('#up_file').live('change',function(){

	free_size = document.upload_form.free.value;
	if(/*typeof FileReader !='undefined' &&*/ typeof FormData !='undefined' )
	{
		var files=this.files;
		if(files.length==0) return;
		file_upload_list_flag.length=0;
		var list='<div style="border:1px solid gray;background:#ddd;"><span class="file_list_name">Name</span><span class="file_list_size">Size</span>Status</div>';

		if(files.length>12)
			list += '<div style="height:310px;overflow-y:auto;">';
		var all_size =0;
		for (var i=0;i<files.length;i++){
			if( (files[i].size) > 4*1024*1024*1024){
				$('#upload_form')[0].reset();
				alert('Support for file uploads less than 4GB!');
				return;
			}  
			var up_file_name = files[i].name;
			up_file_name=XSSResolveCannotParseChar(up_file_name);
			if(up_file_name.length>30) up_file_name = up_file_name.substr(0,27)+'...';
			list +=('<div style="border:1px solid gray;border-top:none;"><span class="file_list_name">'+up_file_name+'</span><span class="file_list_size">'+Byte2Format(files[i].size)+'</span><span class="file_list_del_span"><a title="cancel upload this file" class="file_list_del"><img src="_img/default.gif" /></a></span></div>');
			file_upload_list_flag[i]=1;
			all_size+=files[i].size;
		} 

		if( (parseInt(all_size/1024)+2) > free_size){
			$('#upload_form')[0].reset();
			alert('The remaining space is not enough!');
			return;
		}

		if(files.length>12) list+="</div>";

		$('#file_list').html(list);
		$('#upload_state_tips').html('');
		$('#upload_fail_tips').html('');
		$('#start_upload').show();
			hf_alloc_data.id_cnt=files.length;
//					hf_alloc_data.session=$(data).find("session_id").text();
			hf_alloc_data.token=document.upload_form.token.value;
	}
	else
	{
		alert("Your Browser does not support html5,please setup the latest Chrome/Firefox!");
	}
});
}
$('#cancel_upload').live('click',function(){
	$('#cancel_upload').hide();
	$('#upload_form')[0].reset();
	if(xhr) xhr.abort();
	if(_interval) clearInterval(_interval);
	if(time_s) clearInterval(time_s);
  $('.file_list_del_span').eq(up_index).html('Cancel');
});	

$('#start_upload').live('click',function(){

//	document.upload_form.submit();
//	return;

	var action_str = document.upload_form.action.value;
	root_path = curr_path = document.upload_form.path.value;
	var token_str = document.upload_form.token.value;
	var filter_str = document.upload_form.curr_fil.value;
if(curr_path=='/')
{
  var yymm = new Date().toISOString().slice(0,7);
 
  $.ajax({ 
		url: "storage.html",
		type: "Post", 
		timeout: 20000,
		cache: false,
		datatype: "html",
		data: { action:'mkitem',dir:curr_path,mkname:yymm,mktype:'dir',token:token_str ,filter:filter_str},
		success: function(data, status) {
			var res = eval("("+data+")");
			if(res.token=="-1"){
				top.location.reload(true); 
				return false;
			}
			token_str = document.getElementById('ie_hide_token').value = res.token;
		  curr_path = '/'+yymm;
		  $.ajax({ 
				url: "storage.html",
				type: "Post", 
				cache: false,
				timeout: 20000,
				datatype: "html",
				data: {action:action_str, dir:curr_path,token:token_str , count:'0'}, 
				success: function(data, status) {
					var res = eval("("+data+")");
					if(res.token=="-1"){
						top.location.href="storage.html";
						return false;
					}
					document.getElementById('ie_hide_token').value = res.token;
					hf_alloc_data.start_id=res.fileid;
					if(res.state=="ready") {
						$('.file_list_del').parent().html('&nbsp;');
						$('#ie_hide_path').val(curr_path);						
						if($.browser.msie && parseInt($.browser.version)<10){

							$('#upload_file_id').val(hf_alloc_data.start_id+'0');
//							$('#ie_hide_session').val(hf_alloc_data.session);
//							$('#ie_hide_token').val(get_hf_token(0));
//							$('#file_size').val('1589865');
							$('.file_list_del_span').eq(0).html('Progressing');
							ie_fileUpload($('#upload_form')[0]);
							up_index=0;
							_interval = setInterval("upload_result()",3000);
						}
						else{
							send_files(0);  
						}

					}
//					else {
//						$('#upload_state_tips').html('Another upload instance found,please wait...');
		//				upload_state_interval=setInterval(refresh_upload_state,1000);
//					}
				},
				error: function(x, t, m){
		//			if(t==="timeout")
				}
			});
		},
		error: function(x, t, m){
			alert("Please check your network!");
			current_list(curr_path,0,0);
		}
		})
}
else {

	$.ajax({ 
		url: "storage.html",
		type: "Post", 
		cache: false,
		timeout: 20000,
		datatype: "html",
		data: {action:action_str, dir:curr_path,token:token_str , count:'0'}, 
		success: function(data, status) {
			var res = eval("("+data+")");
			if(res.token=="-1"){
				top.location.href="storage.html";
				return false;
			}
			document.getElementById('ie_hide_token').value = res.token;
			hf_alloc_data.start_id=res.fileid;
			if(res.state=="ready") {
				$('.file_list_del').parent().html('&nbsp;');
				if($.browser.msie && parseInt($.browser.version)<10){
					$('#ie_hide_path').val(curr_path);
					$('#upload_file_id').val(hf_alloc_data.start_id+'0');
					$('#ie_hide_session').val(hf_alloc_data.session);
//					$('#ie_hide_token').val(get_hf_token(0));
					//        $('#upload_form').submit();
					$('.file_list_del_span').eq(0).html('Progressing');
					ie_fileUpload($('#upload_form')[0]);
					up_index=0;
					_interval = setInterval("upload_result()",3000);
				}
				else{
					send_files(0);  
				}
			}
//			else {
//				$('#upload_state_tips').html('Another upload instance found,please wait...');
//				upload_state_interval=setInterval(refresh_upload_state,1000);
//			}
		},
		error: function(x, t, m){
//			if(t==="timeout")
		}
	});
}
});

$('.file_list_del').live('click',function(){
	var index = $('#file_list .file_list_del').index($(this));
	file_upload_list_flag[index]=0;

	var list_num=0;
	$(this).parent().parent().css('display','none');
	for (var i = 0;i<file_upload_list_flag.length;i++){
		if(file_upload_list_flag[i]) list_num++;
	};
	if(!list_num) {
		if(xhr) xhr.abort();
		if(_interval) clearInterval(_interval);
		if(time_s) clearInterval(time_s);
//		$('#file_list').css('display','none');
    if (browse=="msie") $("#up_file").replaceWith( $("#up_file").clone(true) );
    else $('#up_file').val("");
		var list='<div style="border:1px solid gray;background:#ddd;"><span class="file_list_name">Name</span><span class="file_list_size">Size</span>Status</div>';
		$('#file_list').html(list);

		$('#start_upload').hide();
	}
});

$('#close_upload_div').attr('title','Click to close').click(function(){
	$('#upload_form')[0].reset();
	if(xhr) xhr.abort();
	if(_interval) clearInterval(_interval);
	if(time_s) clearInterval(time_s);

	{
//	curr_path = document.upload_form.path.value;
	var token_str = document.upload_form.token.value;
	var filter_str = document.upload_form.curr_fil.value;

  var form;
  form = document.createElement( "form");
  form.method = "post";
  form.action = "storage.html";
	var csrf_token = document.getElementById('ie_hide_token').value;
	
  var input = new Array();
  for(var i = 1; i <=5; i++){
    input[i] = document.createElement("input");
    $(input[i]).attr("type","hidden");
    if(i==1){
      $(input[i]).attr('name','action');
      $(input[i]).attr("value","list");
    } else if(i==2){
      $(input[i]).attr('name','dir');
      $(input[i]).attr("value",root_path);
    } else if(i==3){
      $(input[i]).attr('name','filter');
      $(input[i]).attr("value",filter_str);
    } else if(i==4){
      $(input[i]).attr('name','page');
      $(input[i]).attr("value",'0');
    } else {
      $(input[i]).attr('name','token');
      $(input[i]).attr("value",token_str);
    } 
    form.appendChild(input[i]);
  }
  document.body.appendChild(form);
  form.submit();
  return true;
	}
});


function upload_result_handle(data)
{
//	var xmldoc=data.responseXML;
	var res = eval("("+data+")");

	var new_token = res.token;  //	var new_token = xmldoc.getElementsByTagName('token')[0].childNodes[0].nodeValue;
	if(new_token=="-1"){
		top.location.reload(true); 
		return false;
	}
	document.upload_form.token.value = new_token;
//	token_index=0;
//	$("#csrf_token").val(new_token);
	var name = res.name; //var name = xmldoc.getElementsByTagName('name')[0].childNodes[0].nodeValue;
	var progress = parseInt(res.progress); //	var progress = parseInt(xmldoc.getElementsByTagName('progress')[0].childNodes[0].nodeValue);

	var rate = 1600*1024;

	if(progress && name!='-')
	{
	  if($.browser.msie && parseInt($.browser.version)<10)
		{
	    up_size = parseInt(xmldoc.getElementsByTagName('size')[0].childNodes[0].nodeValue);
	    $('.file_list_size').eq(1).html(Byte2Format(up_size));
	    time_i=3000;
	  }
//	  if(progress <= up_size)
	  {
//	    if(uploaded_size && progress) rate = Math.floor((progress - uploaded_size)*1000/time_i);
	    if(!rate) rate = 1600*1024;
//	    uploaded_size = progress;

	    var percent = progress+'%'; //	    var percent = Math.floor((progress*100)/up_size)+'%';
	    var time_need = Math.floor((up_size - progress)/rate);
	    if(time_need<=0) time_need =1;
	//    $('.file_list_del_span').eq(up_index).html(percent+Math.floor(time_need/60)+'m'+Math.floor(time_need%60)+'s');
	    if(time_s) clearInterval(time_s);
	    time_s = setInterval(function(){
	      $('.file_list_del_span').eq(up_index).html(percent);//	      $('.file_list_del_span').eq(up_index).html( (Math.floor(time_need/60)>0 ? (Math.floor(time_need/60)+'m'):'')+Math.floor(time_need%60)+'s');
	      if(time_need>1) time_need--;
	    },1000);
	  }
	}
	else if (name=='-') {
		var new_error = res.error;
	  if(new_error=="err_2\n")
	  {
	    $('.file_list_del_span').eq(up_index).html('File exists');
	  }
	  else if(new_error=="err_4\n")
	  {
	    $('.file_list_del_span').eq(up_index).html('File name too long');
	  }
		if(xhr) xhr.abort();
		if($.browser.msie && parseInt($.browser.version)<10){
	    clearInterval(_interval);
	    if(time_s) clearInterval(time_s);

  	  $('#upload_state_tips').html('Upload Fail: 1');
	    $('#cancel_upload').hide();
		}
	}
	
}

function ajax_post(url,form_data,index) {
	var xmlpost;
	if (window.XMLHttpRequest){
		xmlpost=new XMLHttpRequest();
	}
	else{
		xmlpost=new ActiveXObject("Microsoft.XMLHTTP");
	}
	xmlpost.onreadystatechange=function()
	{
		if (xmlpost.readyState==4 && xmlpost.status==200){
			upload_result_handle(xmlpost);
		}
		if (xmlpost.readyState==4 && xmlpost.status==0){
			$('#upload_form')[0].reset();
			if(xhr) xhr.abort();
			if(_interval) clearInterval(_interval);
			if(time_s) clearInterval(time_s);
		}
	}
	xmlpost.open("POST",url,true);
	xmlpost.setRequestHeader("Content-type","application/x-www-form-urlencoded");
//	token_used=$("#csrf_token").val();
//	xmlpost.setRequestHeader("__RequestVerificationToken", token_used); 
	xmlpost.send(form_data);
}

function send_files(index){
	var i=index;
	clearInterval(_interval);
	if(index==0) {
	  up_ok=0;
	  up_fail=0;
	}
	$('#start_upload').hide();
	$('#cancel_upload').show();

	$('#up_file').attr('disabled',true);
	if (browse=="msie")
    $('.up_btn_name').eq(0).html('<font color=#eee> </font>');
	else 
	  $('.up_btn_name').html('<font color=#eee>Browse</font>');

	while(file_upload_list_flag[i]==0) i++; 
	var files = $('#up_file')[0].files;
	if(i== files.length) {
		alert('Upload Success!');//		pop_send_succ();
		return;
	}
	up_length = files.length;

	var tips_upload="";
	var ptn=/[:*?<>|]/im;

	if(ptn.test(files[i].name)) {
		up_fail++;
		$('.file_list_del_span').eq(i).html('Fail');
		if(index < (up_length-1)) send_files(index+1);
		$('#upload_fail_tips').html('File name contails :*?<>|');
		return;
	}


	$('.file_list_del_span').eq(i).html('progressing');
	//$('.file_list_del').eq(i).parent().html('progressing');
	var size_str = document.getElementById("up_file").files[index].size;
	var form = new FormData();
	form.append("path", curr_path);
	form.append("upload_file_id", hf_alloc_data.start_id+index);
//	form.append("session", hf_alloc_data.session);
	form.append("token", get_hf_token(index));
	form.append("file_size", size_str);	
	form.append("files", files[i]);

	if (window.XMLHttpRequest){
		xhr=new XMLHttpRequest();
	}
	else{
		xhr=new ActiveXObject("Microsoft.XMLHTTP");
	}

	xhr.onError=function(){
	      clearInterval(_interval);
	    if(time_s) clearInterval(time_s);
	    $('.file_list_del_span').eq(up_index).html('Fail');
	    if(up_index < (up_length-1)) send_files(up_index+1);
	    up_fail++;
	}


	xhr.onreadystatechange=function()
	{
	if (xhr.readyState==4 && xhr.status==0)
	{
	    clearInterval(_interval);
	    if(time_s) clearInterval(time_s);
//	    $('.file_list_del_span').eq(up_index).html('Fail');
	    if(up_index < (up_length-1)) send_files(up_index+1);
	    up_fail++;

  	  $('#upload_state_tips').html('<span style="color:blue;">Upload OK: '+up_ok+'</span> Upload Fail: '+up_fail);
	    if(up_index >= (up_length-1)) 	$('#cancel_upload').hide();
	}

	if (xhr.readyState==4 && xhr.status==200)
	{
	  if(xhr.responseText=="upload OK")
	  {
	    clearInterval(_interval);
	    if(time_s) clearInterval(time_s);
	    $('.file_list_del_span').eq(up_index).html('OK');
	    if(up_index < (up_length-1)) send_files(up_index+1);
	    up_ok++;
	  }
	  else if(xhr.responseText=="upload busy")
	  {
	    clearInterval(_interval);
	    if(time_s) clearInterval(time_s);
	    $('.file_list_del_span').eq(up_index).html('Progress.');
	    setTimeout(function retry_send(){if(up_index < (up_length-1)) send_files(up_index);},500);
	  }
	  else if(xhr.responseText=="upload fail")
	  {
	    clearInterval(_interval);
	    if(time_s) clearInterval(time_s);
	    $('.file_list_del_span').eq(up_index).html('Fail');
	    if(up_index < (up_length-1)) send_files(up_index+1);
	    up_fail++;
	  }
//	  else if(xhr.responseText=="upload fail, file exists")
//	  {
//	    clearInterval(_interval);
//	    if(time_s) clearInterval(time_s);
//	    $('.file_list_del_span').eq(up_index).html('File exists');
//	    if(up_index < (up_length-1)) send_files(up_index+1);
//	    up_fail++;
//	  }
	  else if(xhr.responseText=="upload fail, invalid request")
	  {
	    clearInterval(_interval);
	    if(time_s) clearInterval(time_s);
	    $('.file_list_del_span').eq(up_index).html('Invalid request');
	    if(up_index < (up_length-1)) send_files(up_index+1);
	    up_fail++;
	  }
//	  else if(xhr.responseText=="upload fail, name too long")
//	  {
//	    clearInterval(_interval);
//	    if(time_s) clearInterval(time_s);
//	    $('.file_list_del_span').eq(up_index).html('File name too long');
//	    if(up_index < (up_length-1)) send_files(up_index+1);
//	    up_fail++;
//	  }

	//    var ok_cnt=up_index-up_fail;
	    $('#upload_state_tips').html('<span style="color:blue;">Upload OK: '+up_ok+'</span> Upload Fail: '+up_fail);
	    if(up_index >= (up_length-1)) 	$('#cancel_upload').hide();
	  }

	}
	xhr.open("post", "http://"+location.hostname+":61726", true);
	xhr.send(form);

	up_index = i;
	up_size = files[i].size;
	//time_i=1000;

	if(up_size<1024*1000) time_i=1000;
	else if(up_size<1024*1000*10) time_i=1000*3;
	else time_i=10000;
	uploaded_size = 0;
	_interval = setInterval("upload_result()",time_i);
	upload_result();
}

function upload_result(){
	
//	var data = 'file_id='+(hf_alloc_data.start_id + up_index);
//	if(token_used!=$("#csrf_token").val()){
//		token_used=$("#csrf_token").val();
//		ajax_post('storage.html', data);
//	}

	var action_str = document.upload_form.action.value;
	curr_path = document.upload_form.path.value;
	var token_str = document.upload_form.token.value;

$.ajax({ 
		url: "storage.html",
		type: "Post", 
		cache: false,
		timeout: 20000,
		datatype: "html",
		data: {action:action_str, dir:curr_path,token:token_str , count:'1',file_id:(hf_alloc_data.start_id + up_index)}, 
		success: function(data, status) {
			upload_result_handle(data);
		},
		error: function(x, t, m){
//			if(t==="timeout")
		}
	});
}

function Byte2Format(size){
var f_size=''+size;
if(size<1024) f_size += 'B ';
else if(size<1048576) f_size = (size/1024).toFixed(1)+'KB ';
else if(size<1073741824) f_size = (size/1048576).toFixed(1)+'MB ';
else f_size = (size/1073741824).toFixed(1)+'GB ';
return f_size;
}

function XSSResolveCannotParseChar(xmlStr) {
    return xmlStr.replace(/(\&|\'|\"|\>|\<|\/|\(|\))/g, function($0, $1) {
        return {
            '&' : '&amp;',
            "'" : '&#39;',
            '"' : '&quot;',
            '<' : '&lt;',
            '>' : '&gt;',
            '/' : '&#x2F;',
            '(' : '&#40;',
            ')' : '&#41;'
        }[$1];
    }
    );
}