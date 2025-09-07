<?php

function upload_response($stat, $cnt){
		if (is_ajax()) {
	 		$return["state"] = $stat;	
	 		$return["count"] = $cnt;	
	  	$return["token"] = $GLOBALS['__SESSION']['token'];
			echo json_encode($return);
		}
	 	exit;	
}

function processExists($file = false) {
    $exists= false;
    $file= $file ? $file : __FILE__;

    // Check if file is in process list
    exec("ps -C $file -o pid=", $pids);
    if (count($pids) > 1) {
    $exists = true;
    }
    return $exists;
}
function upload_state($file_count) {

	Generation_csrf();
	
	if($file_count=='0') {
//remove upload_tmp file 		
		@system('rm -rf '.$GLOBALS["home_dir"].'/.00*',$retval);
		@system('rm -rf /tmp/wifidisk/.err_*',$retval);

		$fileid = mt_rand(1111,9999);

		if (is_ajax()) {
	 		$return["state"] = 'ready';	
	 		$return["count"] = '0';	
	 		$return["fileid"] = "00".$fileid;	
	  	$return["token"] = $GLOBALS['__SESSION']['token'];
			echo json_encode($return);
		}
	 	exit;	
	}
	else if($file_count=='1') {	
		$file_id = stripslashes($GLOBALS['__POST']["file_id"]);

		$file_error = "/tmp/wifidisk/".".err_".$file_id;
		if(@file_exists($file_error)) {
			$fp = @fopen($file_error, "r");
			$buffer = fgets($fp, 12);
			@fclose($fp);
		}
		else
			$buffer = "0";

		if(@strstr($buffer, "err")) {
			if (is_ajax()) {
		 		$return["name"] = '-';	
		 		$return["error"] = $buffer;	
		  	$return["token"] = $GLOBALS['__SESSION']['token'];
				echo json_encode($return);
			}
			exit;			 
		}
		else {
			$total_size =(double)$buffer;

			$abs = get_abs_item("",".".$file_id);
			if(@file_exists($abs))
				$new_file_size = getfilesize($abs);
			else 
				$new_file_size = '0';

			$new_file_percent =((double)$new_file_size/$total_size)*100;
			if (is_ajax()) {
		 		$return["name"] = $file_id;	
		 		$return["progress"] = round($new_file_percent,0); //$new_file_size;	
		  	$return["token"] = $GLOBALS['__SESSION']['token'];
				echo json_encode($return);
			}
		 	exit;
		}
	}
	else
		upload_response('error', '0');

}

//------------------------------------------------------------------------------
function upload_items($dir) {		// upload file
	if(($GLOBALS["permissions"]&01)!=01) show_error($GLOBALS["error_msg"]["accessfunc"]);

//	if($GLOBALS['WIFI_HOST']=='0') {
//	exit;
//	}
	if(Verify_csrf($GLOBALS["token"])==0) {
		show_csrf_error($GLOBALS["error_msg"]["csrferror"]);
	}
	if(isset($GLOBALS['__POST']["filter"])) $file_filter = stripslashes($GLOBALS['__POST']["filter"]);
  	else $file_filter="0";

	if(isset($GLOBALS['__POST']["count"])) { 
		$file_count = stripslashes($GLOBALS['__POST']["count"]);
		upload_state($file_count);
	}
//upload page

	if(@file_exists("/tmp/uploading")) {
			show_popup_error("Another upload instance found,please wait...");

	}

	
	$fp = @popen("df | grep /dev/mmcblk0p1 | awk '{print $2,$4}'","r");
	$fr = @fread($fp,100);
	@pclose($fp);

	if($fr == NULL)	{
		$sd_free = "0";
	}
	else {
		$cap=explode(' ',$fr);
		$sd_free = $cap[1];
	}	

//	Generation_csrf();
	echo "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\n";
	echo "<meta http-equiv=\"X-UA-Compatible\" content=\"IE=9; IE=8; IE=7; IE=EDGE,chrome=1\">\n";
	echo "<title>".$GLOBALS["messages"]["model_title"]."</title> \n";
	echo "<script src='_fscrt/jquery-1.8.3.min.js' type='text/javascript'></script>\n";
	echo "<script type=\"text/JavaScript\">\n";
	echo "function ajax(url,target) { \n";
	echo "   if (window.XMLHttpRequest) { \n";
	echo "     req = new XMLHttpRequest(); \n";
	echo "     req.onreadystatechange = function() {ajaxDone(req);}; \n";
	echo "     req.open('GET', url, true); \n";
	echo "     if(navigator.appName =='Microsoft Internet Explorer') \n";
	echo "       req.setRequestHeader('Cookie',\"ksession=\"+getCookie(\"ksession\") ); \n";
	echo "     req.send(null); \n";
	echo "  } else if (window.ActiveXObject) { \n";
	echo "     req = new ActiveXObject('MSXML2.XMLHTTP'); \n";
	echo "     if (!req) { \n";
	echo "       req = new ActiveXObject('Microsoft.XMLHTTP'); \n";
	echo "     } \n";
	echo "     req.onreadystatechange = function() {ajaxDone(req);}; \n";
	echo "      req.open('GET', url, true); \n";
	echo "     req.setRequestHeader('Cookie',\"ksession=\"+getCookie(\"ksession\") ); \n";
	echo "     req.send(null); \n";
	echo "  } \n";
	echo "} \n";
	echo "function ajaxDone(req) { \n";
	echo "} \n";
	echo "function ajaxstart() { \n";
	echo "  var timestamp = Number(new Date()); \n";
	echo "  ajax('/sess.cgi?'+ timestamp ,null); \n";
	echo "} \n";
	echo "function start_session( ) { \n";
	echo "  setInterval('ajaxstart()', 3000); \n";
	echo "} \n";
	echo "function getCookie( name ) { \n";
	echo "  var nameOfCookie = name + \"=\"; \n";
	echo "  var x = 0; \n";
	echo "  while ( x <= document.cookie.length ) { \n";  
	echo "    var y = (x+nameOfCookie.length); \n";
	echo "    if ( document.cookie.substring( x, y ) == nameOfCookie ) {  \n";      
	echo "      if ( (endOfCookie=document.cookie.indexOf( \";\", y )) == -1 )  \n";        
	echo "        endOfCookie = document.cookie.length; \n";
	echo "      return unescape( document.cookie.substring( y, endOfCookie ) ); \n";        
	echo "    } \n";
	echo "    x = document.cookie.indexOf( \" \", x ) + 1; \n";  
	echo "    if ( x == 0 ) \n";
	echo "      break; \n";
	echo "  } \n";
	echo "  return \"\"; \n";
	echo "} \n";
	echo "window.onload=function () {\n";
	echo "  start_session(); \n";
	echo "}\n";
	echo "	$(document).keydown(function(e) {\n";
	echo "  var key = (e) ? e.keyCode : event.keyCode;\n";
	echo "  var t = document.activeElement;\n";
	echo "  if ((e.ctrlKey == true && (key == 78 || key == 82)) || key == 116 ) 	{\n"; // 116 F5 17 left control 82 R 78 N
	echo "    if (e) {\n";
	echo "      e.preventDefault();\n";
	echo "    } else {\n";
	echo "      event.keyCode = 0;\n";
	echo "      event.returnValue = false;\n";
	echo "    }\n";
	echo "  }\n";
	echo "  });\n";
	echo "</script>\n";
	echo "<link rel=stylesheet type='text/css' href='_fscrt/upload.css'> \n";
	echo "</head>\n";
	echo "<body bgcolor=white text=black link=blue vlink=purple alink=red leftmargin=0 topmargin=20 background=\"_img/common_bg.jpg\">\n"; //	echo "<body bgcolor=white text=black link=blue vlink=purple alink=red leftmargin=0 topmargin=20 background=\"_img/common_bg.jpg\" oncontextmenu=\"return false\" ondragstart=\"return false\" onselectstart=\" return false\"> \n";
	echo "<table border=0 bgcolor=white width=582 height=400 cellpadding=0 cellspacing=0 align=center>";
	echo "<tr><td width=10 height=20 valign=top align=left><img src=\"_img/left_round.jpg\"></td><td width=562 height=20>&nbsp;</td>";
	echo "<td width=10 height=20 valign=top align=right><img src=\"_img/right_top_round.jpg\"></td></tr><tr><td width=10 height=340></td>";
	echo "<td width=562 height=340 align=center valign=center>";
	echo "<div id=\"upload_progress\">";
	echo "<span id=\"close_upload_div\" >Close</span>";

	echo " <div class=\"input-file\">";
	echo " <form name=\"upload_form\" id=\"upload_form\">";
	echo "  <span class=\"up_btn_name\">Browse</span>";
	echo "  <input name=\"action\" id=\"ie_hide_action\" type=\"hidden\" value=\"upload\"/>";
	echo "  <input name=\"free\" id=\"ie_hide_size\" type=\"hidden\" value=\"".$sd_free."\"/>";	
	echo "	<input name=\"curr_fil\" id=\"curr_fil\" type=hidden value='".$file_filter."' />\n";
	echo "  <input name=\"path\" id=\"ie_hide_path\" type=\"hidden\" value=\"".$dir."\"/>";
	echo "  <input name=\"upload_file_id\" id=\"upload_file_id\" type=\"hidden\" value=\"\"/>\n";
	echo "  <input name=\"token\" id=\"ie_hide_token\" type=\"hidden\" value=\"".$GLOBALS['__SESSION']['token']."\">\n";		
	echo "	<input name=\"file_size\" id=\"file_size\" type=hidden value='-1' />\n";
	echo "  <input name=\"files\" id=\"up_file\" class=\"upload\" type=\"file\"	multiple=\"multiple\" align=left/>";
	echo " </form>";
	echo "</div> ";
	
	echo "<div id=\"file_list\">";
	echo "<div class='file_list_state'><span class='file_list_name'>Name</span><span class='file_list_size'>Size</span>Status</div>";
	echo "</div>";
	echo "<div id=\"upload_fail_tips\">&nbsp;";
	echo "</div>";
	echo "<div id=\"upload_state_tips\">&nbsp;";
	echo "</div>";
	echo "<div id=\"start_upload\" style=\"height:30px; display: none;\">";
	echo "<span class=button_start>Start</span>";
	echo "</div>";
	echo "<div id=\"cancel_upload\" style=\"height:30px; display: none;\">";
	echo "<span class=button_cancel>Cancel</span>";
	echo "</div>";
	echo "</div>";

	echo "</td><td width=10 height=340></td></tr><tr><td width=10 height=20 valign=bottom  align=left><img src=\"_img/left_down_round.jpg\"></td>";
	echo "<td width=562 height=20>&nbsp;</td><td width=10 height=20 valign=bottom  align=right><img src=\"_img/right_down_round.jpg\"></td></tr></table>";
	echo "<iframe id=\"dl_iframe\" style=\"display: none;\"></iframe>\n";
	echo "<script src='_fscrt/f_upload.js' type='text/javascript' ></script>\n";
	return;
}
//------------------------------------------------------------------------------
?>
