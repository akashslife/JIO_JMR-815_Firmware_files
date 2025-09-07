if(window!=top) top.location.href="storage.html";
var del_name_array=new Array(),del_path_array=new Array(),file_upload_list_flag=new Array();
var curr_path="/",curr_page=0,curr_file,sel_path,menu_obj,curr_page_file_cnt=0,filter_num=255,filter_enable=1,is_search=0,is_dir=0
var rename_submited=0;
var video_player = null;
var music_player = null;
var flash_player = null;
var wmp_player = null;

<!--
function handleFileSelect(files) 
{
  var img_view = ['<p style="text-align: center;"><img src=img.html?path=',encodeURIComponent(files),' title="file" width=95%/ alt="image"></p>'].join('');                
  document.getElementById('list').innerHTML = img_view;
}
//-->

jQuery(function () {
  if (!("placeholder" in document.createElement("input"))) { 
    jQuery(":input[placeholder]").each(function () {
      var $this = jQuery(this);
      var pos = $this.offset();
      if (!this.id) this.id = "jQueryVirtual_" + this.name;
      if (this.id) {
        if (jQuery.browser.version  < 8) {
          $this.after("<label for='" + this.id + 
               "' id='jQueryVirtual_label_" + this.id + 
               "' class='absolute'>" + $this.attr("placeholder") + 
               "</label>");
          $("#jQueryVirtual_label_" + this.id).
               css({"left":(pos.left+5), "margin-top":3, 
               "width":$this.width()});
        }
        else {
          $this.after("<label for='" + this.id + 
           "' id='jQueryVirtual_label_" + this.id + 
           "' style='left:" + (pos.left+5) + 
           "px;margin-top:2px' class='absolute'>" + 
           $this.attr("placeholder") + "</label>");
        }
      }
    }).focus(function () {
      var $this = jQuery(this);
      $this.addClass("focusbox");
      jQuery("#jQueryVirtual_label_" + $this.attr("id")).hide();
    }).blur(function () {
      var $this = jQuery(this);
      $this.removeClass("focusbox");
      if(!jQuery.trim($this.val())) 
        jQuery("#jQueryVirtual_label_" + $this.attr("id")).show();
      else jQuery("#jQueryVirtual_label_" + $this.attr("id")).hide();
    }).trigger("blur");
  }
}); 

if($.browser.msie && parseInt($.browser.version)<10){
  $('#browser_tips').show();
  var aa = document.getElementById('ie9_div');
  aa.style.height='400px';
}

//$("document").ready(function(){
var new_folder_submited=0;

$("input.new_folder").live('keydown',function(event) {
	e = event ? event :(window.event ? window.event : null); 
	if(e.keyCode==13){
	  new_folder_handle();
	  return false;
	} 
});

$('input.new_folder').live("blur",function(){
	new_folder_handle();
  return false;
});


$('a.upload_btn').live('click',function(){
	curr_path = document.getElementById('curr_path').value;
	filter_num= document.getElementById('curr_fil').value;
	current_upload(curr_path,filter_num);

});

$('a.new_folder').live('click',function(){
  if(new_folder_submited!=0) return;
  var tbody_cont="<tr><td><input type='checkbox' name='cb'/></td><td><IMG border='0' width='16' height='16' align=ABSMIDDLE src='_img/dir.gif' atl> <input maxlength='32' class='new_folder' value='New folder'/></td><td>-</td><td>-</td><td></td></tr>"+$("#tb_body").html();
  $("#tb_body").html(tbody_cont);
  $('input.new_folder').blur();
  $('input.new_folder').focus();
  new_folder_submited=1;
});

$('#page_href a').live('click',function(){
  var target = parseInt($(this).text())-1;
  curr_page = target;
  curr_path = document.getElementById('curr_path').value;
  var post_data = curr_path;

  if(document.getElementById('curr_cmd').value=="search"){
  	search_file(" ", curr_page );
  }
  else{
    var cu_filter= document.getElementById('curr_fil').value;
    current_list(curr_path, cu_filter,curr_page );
  }

});

$("input.rename_target").live('keydown',function(event) {
  e = event ? event :(window.event ? window.event : null); 
  if(e.keyCode==13){
    rename_handle();
	  return false;
  } 
});


$('input.rename_target').live('blur',function(e){

  rename_handle();
  return false;
});
//})

$(document).keydown(function(e) {
	key = (e) ? e.keyCode : event.keyCode;

	var t = document.activeElement;

	if ( key == 116) { // 116 F5 17 left control 82 R 78 N
		if (e) {
			e.preventDefault();
		} else {
			event.keyCode = 0;
			event.returnValue = false;
		}
	}
});

$("span.icon").live("click",function(){
  var full_path;
  var path = $(this).find('label').text();
  var name = $(this).find('pre').text();

  if(name=="" || path=="") return;
  var file_type=checkImgType(name);

  if (path!='/') path =path+'/';

  if(file_type==1)
  {
    full_path = path + name;
    handleFileSelect(full_path);
  }
  else if(file_type==2)
  {
    full_path = path + name;
    if (!!(document.createElement('video').canPlayType) && (/\.(mp3)$/i).test(name)) {
      if(video_player!=null)    video_player.close();  
      video_player =window.open('video.html?path='+encodeURIComponent(full_path), "video_player");
    }
    else download_file(path,name); 
  }
  else if(file_type==3)
  {
    full_path = path + name;
      
    if (!!(document.createElement('video').canPlayType) && (/\.(mp4)$/i).test(name)) {
      if(video_player!=null)    video_player.close();
      video_player =window.open('video.html?path='+encodeURIComponent(full_path), "video_player");
    }
    else if (!!(document.createElement('video').canPlayType) && !($.browser.msie && parseInt($.browser.version)<10) && (/\.(mov)$/i).test(name)) {
      if(video_player!=null) video_player.close();
     video_player = window.open('video.html?path='+encodeURIComponent(full_path), "video_player");
    }
    else if((/win/i).test(navigator.platform) && (/\.(mpg|avi|wmv|3gp|mov)$/i).test(name)){
      if(wmp_player!=null) wmp_player.close();
      wmp_player = window.open('wmp.html?path='+encodeURIComponent(full_path), "wmp_player");
    }
    else if ((/\.(flv|f4v)$/i).test(name)) {
      if(flash_player!=null) flash_player.close();
      flash_player = window.open('flash.html?path='+encodeURIComponent(full_path), "flash_player");
    }
    else download_file(path,name); 
  }
  else if(file_type==4)
  {
    download_file(path,name); 
  }
  else 
  {
    download_file(path,name);
  }
});


function checkImgType(ths){
  if (ths == "") return 0;
  ths = ths.toLowerCase();
  if (/\.(gif|jpg|jpeg|png|bmp)$/.test(ths)) return 1;
  else if (/\.(mp3)$/.test(ths)) return 2;
  else if (/\.(mp4|avi|rmvb|mov|mpg|f4v|flv|3gp|wmv)$/.test(ths)) return 3;
  else if (/\.(pdf)$/.test(ths)) return 4;
  else if (/\.(txt)$/.test(ths)) return 5;  
  return 255;  
}
function new_folder_handle(){
  if(new_folder_submited!=1) return;
  new_folder_submited=2;
  var foldername= $('input.new_folder').val();
  if(!foldername.length)
  {
    $('input.new_folder').focus();
    new_folder_submited=1;
    return false;
  }
  curr_path = document.getElementById('curr_path').value;
  filter_num= document.getElementById('curr_fil').value;
  var csrf_token = document.getElementById('token').value;

  if(curr_path=='/' && filter_num!=0)
  {
    var yymm = new Date().toISOString().slice(0,7);
    $.ajax({ 
  		url: "storage.html",
  		type: "Post", 
  		timeout: 20000,
  		cache: false,
  		datatype: "html",
  		data: { action:'mkitem',dir:curr_path,mkname:yymm,mktype:'dir',token:csrf_token ,filter:filter_num},
  		success: function(data, status) {
  			var res = eval("("+data+")");
  			if(res.token=="-1"){
  				top.location.reload(true); 
  				return false;
  			}
  			csrf_token = document.getElementById('token').value = res.token;
  		  curr_path = '/'+yymm;
  			$.ajax({ 
  				url: "storage.html",
  				type: "Post", 
  				timeout: 20000,
  				cache: false,
  				datatype: "html",
  				data: { action:'mkitem',dir:curr_path,mkname:foldername,mktype:'dir',token:csrf_token ,filter:filter_num},
  				success: function(data, status) {
  					var res = eval("("+data+")");
  					if(res.token=="-1"){
  						top.location.reload(true); 
  						return false;
  					}
  					document.getElementById('token').value = res.token;
  					if(res.result=="success")
  						current_list(curr_path,0,0);
  					else {
  						alert(res.result);
  						current_list(curr_path,0,0);
  					}
  				},
  				error: function(x, t, m){
  					alert("Please check your network!");
  					current_list(curr_path,0,0);
  				}
  				})
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
      timeout: 20000,
      cache: false,
      datatype: "html",
      data: { action:'mkitem',dir:curr_path,mkname:foldername,mktype:'dir',token:csrf_token ,filter:filter_num},
      success: function(data, status) {
      	var res = eval("("+data+")");
      	if(res.token=="-1"){
      		top.location.reload(true); 
      		return false;
      	}
      	document.getElementById('token').value = res.token;
      	if(res.result=="success")
      		current_list(curr_path,0,0);
      	else {
      		alert(res.result);
      		current_list(curr_path,0,0);
      	}
      },
      error: function(x, t, m){
      	alert("Please check your network!");
      	current_list(curr_path,0,0);
      }
    })
  }
}

function rename_handle(){
  if(rename_submited!=1) return;
  rename_submited=2;
  var newname= $('.rename_target')[1].value;
  var result = 3;
	curr_path = document.getElementById('curr_path').value;
	filter_num= document.getElementById('curr_fil').value;

  if(del_name_array[0]==newname)
  {
  	rename_submited=0;
		current_list(curr_path,filter_num,0);
  	return;
  }
  if(newname.length && newname.lastIndexOf('.'))
  {
  	var csrf_token = document.getElementById('token').value;
  	$.ajax({ 
  		url: "storage.html",
  		type: "Post", 
  		datatype: "html",
  		timeout: 20000,
  		cache: false,
  		data: { action:'rename', dir:del_path_array[0],old_name:del_name_array[0],new_name:newname,token:csrf_token}, 
  		success: function(data, status) {
    		rename_submited=0;
    		var res = eval("("+data+")");
    		if(res.token=="-1"){
    			top.location.reload(true); 
    			return false;
    		}
    		document.getElementById('token').value = res.token;
    		if(res.result=="success")
    			current_list(curr_path,filter_num,0);
    		else {
    			alert(res.result);
    			current_list(curr_path,filter_num,0);
    		}
  		},
  		error: function(x, t, m){
  			alert("Please check your network!");
  			current_list(curr_path,filter_num,0);	}
  	});
  }
}

function current_upload(dir,filt)
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
      $(input[i]).attr("value","upload");
    } else if(i==2){
      $(input[i]).attr('name','dir');
      $(input[i]).attr("value",dir);
    } else if(i==3){
      $(input[i]).attr('name','filter');
      $(input[i]).attr("value",filt);
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

function current_list(dir,filt, page)
{
	if(rename_submited==1)
		return true;
  var form;
  form = document.createElement( "form");
  form.method = "post";
  form.action = "storage.html";
	var csrf_token = document.getElementById('token').value;
	
  var input = new Array();
  for(var i = 1; i <=5; i++){
    input[i] = document.createElement("input");
    $(input[i]).attr("type","hidden");
    if(i==1){
      $(input[i]).attr('name','action');
      $(input[i]).attr("value","list");
    } else if(i==2){
      $(input[i]).attr('name','dir');
      $(input[i]).attr("value",dir);
    } else if(i==3){
      $(input[i]).attr('name','filter');
      $(input[i]).attr("value",filt);
    } else if(i==4){
      $(input[i]).attr('name','page');
      $(input[i]).attr("value",page);
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

function download_file(dir,down_name)
{
  var form;
  form = document.createElement( "form");
  form.method = "post";
  form.action = "download.html";
	var csrf_token = document.getElementById('token').value;
	
  var input = new Array();
  for(var i = 1; i <=4; i++){
    input[i] = document.createElement("input");
    $(input[i]).attr("type","hidden");
    if(i==1){
      $(input[i]).attr('name','action');
      $(input[i]).attr("value","download");
    } else if(i==2){
      $(input[i]).attr('name','dir');
      $(input[i]).attr("value",dir);
    } else if(i==3){
      $(input[i]).attr('name','item');
      $(input[i]).attr("value",down_name);
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

function Delete_item(dir, item, nfolder)
{
	if(nfolder==1)
	var ans = confirm('Are you sure you want to delete this folder \''+item+'\'');
	else
	var ans = confirm('Are you sure you want to delete this file \''+item+'\'');
	if(ans == true) {
		var csrf_token = document.getElementById('token').value;
  	curr_path = document.getElementById('curr_path').value;
  	filter_num= document.getElementById('curr_fil').value;

	  $.ajax({ 
      url: "storage.html",
      type: "Post", 
      timeout: 20000,
      cache: false,
      datatype: "html",
      data: { action:'delete',dir:dir,item:item,token:csrf_token},
      success: function(data, status) {
      	var res = eval("("+data+")");
      	if(res.token=="-1"){
      		top.location.reload(true); 
      		return false;
      	}
      	document.getElementById('token').value = res.token;
  			alert(res.result);
  			current_list(curr_path,filter_num,0);
      },
      error: function(x, t, m){
      	alert("Please check your network!");
      	current_list(curr_path,filter_num,0);
      }
    })
		return true;
	}
	return ;
}

function Rename_file(dir,item)
{
	var i=0;
	for(i=0; i<$('a.rename').length;i++)
	{
		if($('a.rename')[i].title==item)
		break;
	}

	if($('a.rename')[i].className=='rename')  {
	  menu_obj=$($('a.rename')[i]).closest('tr').children('td:eq(1)'); 
	  if($($('a.rename')[i]).closest('tr').children('td:eq(3)').html()=="-") is_dir=1;
	  else is_dir=0;
		del_name_array.length=0;
		del_path_array.length=0;
		del_name_array[0] =  item;
		del_path_array[0] =  dir;
	}
  $(menu_obj).children().html("<input maxlength='50' class='rename_target' style='width:"+(item.length*9)+"px;' >");
  $('input.rename_target').val(del_name_array[0]);
  $('input.rename_target').blur();
  $('input.rename_target').focus();
  
  rename_submited=1;

}


function log_out()
{
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
      $(input[i]).attr("value","logout");
    } else {
	    $(input[i]).attr('name','token');
	    $(input[i]).attr("value",csrf_token);
	  } 
 
    form.appendChild(input[i]);
  }
  document.body.appendChild(form);
  form.submit();
}

function search_file(search_name, page)
{
	if(search_name.length) {
	 	var form =document.getElementById('form_search');
	  form.method = "post";
	  form.action = "storage.html";
		var csrf_token = document.getElementById('token').value;
		
	  var input = new Array();
	  for(var i = 1; i <=3; i++){
	    input[i] = document.createElement("input");
	    $(input[i]).attr("type","hidden");
	    if(i==1){
	      $(input[i]).attr('name','action');
	      $(input[i]).attr("value","search");
	    } else if(i==2){
	      $(input[i]).attr('name','page');
	      $(input[i]).attr("value",page);	    
	    } else {
		    $(input[i]).attr('name','token');
		    $(input[i]).attr("value",csrf_token);
	  	} 
	    form.appendChild(input[i]);
	  }
	  document.body.appendChild(form);
	  form.submit();
	}
}

function sd_set()
{
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
      $(input[i]).attr("value","sd_system");
    } else {
	    $(input[i]).attr('name','token');
	    $(input[i]).attr("value",csrf_token);
	  } 
    form.appendChild(input[i]);
  }
  document.body.appendChild(form);
  form.submit();
}

function Delete_lists() {

	var num=NumChecked();
	if(num==0) {
		alert("You haven't selected any item(s).");
		return;
	}
	if(confirm("Are you sure you want to delete these "+num+" item(s)?")) {
		document.selform.token.value = document.getElementById('token').value;
    var params = $("#selform").serialize();
    	var csrf_token = document.getElementById('token').value;
  	curr_path = document.getElementById('curr_path').value;
  	filter_num= document.getElementById('curr_fil').value;

	  $.ajax({ 
      url: "storage.html",
      type: "Post", 
      timeout: 20000,
      cache: false,
      datatype: "html",
      data: params,
      success: function(data, status) {
      	var res = eval("("+data+")");
      	if(res.token=="-1"){
      		top.location.reload(true); 
      		return false;
      	}
      	document.getElementById('token').value = res.token;
  			alert(res.result);
  			current_list(curr_path,filter_num,0);
      },
      error: function(x, t, m){
      	alert("Please check your network!");
      	current_list(curr_path,filter_num,0);
      }
    })
	}
}


function Toggle(e) {
	if(e.checked) {
		Highlight(e);
		document.selform.toggleAllC.checked = AllChecked();
	} else {
		UnHighlight(e);
		document.selform.toggleAllC.checked = false;
	}
}

function ToggleAll(e) {
	if(e.checked) CheckAll();
	else ClearAll();
}
	
function CheckAll() {
	var ml = document.selform;
	var len = ml.elements.length;
	for(var i=0; i<len; ++i) {
		var e = ml.elements[i];
		if(e.name == "selitems[]") {
			e.checked = true;
			Highlight(e);
		}
	}
	ml.toggleAllC.checked = true;
}

function ClearAll() {
	var ml = document.selform;
	var len = ml.elements.length;
	for (var i=0; i<len; ++i) {
		var e = ml.elements[i];
		if(e.name == "selitems[]") {
			e.checked = false;
			UnHighlight(e);
		}
	}
	ml.toggleAllC.checked = false;
}
   
function AllChecked() {
	ml = document.selform;
	len = ml.elements.length;
	for(var i=0; i<len; ++i) {
		if(ml.elements[i].name == "selitems[]" && !ml.elements[i].checked) return false;
	}
	return true;
}
	
function NumChecked() {
	ml = document.selform;
	len = ml.elements.length;
	num = 0;
	for(var i=0; i<len; ++i) {
		if(ml.elements[i].name == "selitems[]" && ml.elements[i].checked) ++num;
	}
	return num;
}

function Highlight(e) {
	var r = null;
	if(e.parentNode && e.parentNode.parentNode) {
		r = e.parentNode.parentNode;
	} else if(e.parentElement && e.parentElement.parentElement) {
		r = e.parentElement.parentElement;
	}
	if(r && r.className=="rowdata") {
		r.className = "rowdatasel";
	}
}

function UnHighlight(e) {
	var r = null;
	if(e.parentNode && e.parentNode.parentNode) {
		r = e.parentNode.parentNode;
	} else if (e.parentElement && e.parentElement.parentElement) {
		r = e.parentElement.parentElement;
	}
	if(r && r.className=="rowdatasel") {
		r.className = "rowdata";
	}
}
